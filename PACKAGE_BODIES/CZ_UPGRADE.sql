--------------------------------------------------------
--  DDL for Package Body CZ_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_UPGRADE" AS
/*	$Header: czupgrdb.pls 120.2 2008/06/05 20:42:40 misheehy ship $	*/

currentmodelid     NUMBER;

base_expl_id       NUMBER;
next_expl_id       NUMBER;
base_node_id       NUMBER;
next_node_id       NUMBER;

current_expl_id    NUMBER;
local_expl_id      NUMBER;
current_node_id    NUMBER;

root_model_id      NUMBER;

-- generate cz_xfr_project_bills for references
PROCEDURE generate_xfr_reference_bills IS

BEGIN

 FOR c_devl IN (SELECT devl_project_id, orig_sys_ref FROM cz_devl_projects p
                  WHERE deleted_flag = flag_not_deleted
                  AND devl_project_id <> 0
                  AND orig_sys_ref is not NULL
                  AND EXISTS (SELECT NULL FROM cz_rp_entries
                              WHERE object_id = p.devl_project_id
                              AND object_type = 'PRJ'
                              AND deleted_flag = flag_not_deleted)
                  AND NOT EXISTS (SELECT NULL FROM cz_xfr_project_bills
                  WHERE model_ps_node_id = p.devl_project_id )
 )
 LOOP

   INSERT INTO cz_xfr_project_bills (model_ps_node_id,
                                     organization_id,
                                     top_item_id,
                                     explosion_type,
                                     deleted_flag,
                                     source_server,
                                     last_import_date)
   SELECT c_devl.devl_project_id,
            substr(c_devl.orig_sys_ref, instr(c_devl.orig_sys_ref, ':') + 1, instr(c_devl.orig_sys_ref, ':', 1, 2) - instr(c_devl.orig_sys_ref, ':') - 1),
            substr(c_devl.orig_sys_ref, instr(c_devl.orig_sys_ref, ':', -1, 1) + 1),
            substr(c_devl.orig_sys_ref, 1, instr(c_devl.orig_sys_ref, ':', 1) - 1),
            '0',
            0,
            sysdate
   FROM dual;

 END LOOP;

END generate_xfr_reference_bills;

-----------------------------------------------------
-----------------------------------------------------

PROCEDURE AUTO_PUBLISH(p_server_id NUMBER) IS

TYPE devl_project_id_table	IS TABLE OF cz_devl_projects.devl_project_id%TYPE INDEX BY BINARY_INTEGER;
TYPE orig_sys_ref_table		IS TABLE OF cz_devl_projects.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
TYPE last_import_date_table	IS TABLE OF cz_xfr_project_bills.last_import_date%TYPE INDEX BY BINARY_INTEGER;

APPLET				constant VARCHAR2(3) := '3';
DHTML					constant VARCHAR2(3) := '0';
v_models_to_be_published	devl_project_id_table;
v_orig_sys_ref			orig_sys_ref_table;
v_last_import_date		last_import_date_table;
v_application_id			cz_ext_applications_v.application_id%TYPE;
v_to_publish_id			cz_model_publications.publication_id%TYPE;
v_ui_def_id				NUMBER;
v_run_id				NUMBER;
v_ui_def_id_tmp			NUMBER;
v_applet_ui_def_id		NUMBER;
v_dhtml_ui_def_id			NUMBER;
v_ui_style	                  VARCHAR2(3);
v_product_key			cz_model_publications.product_key%TYPE;
v_top_item_id			NUMBER;
v_org_id				NUMBER;
v_pr_orig_sys_ref			cz_devl_projects.orig_sys_ref%TYPE := 'DUMMY';
v_pb_run_id				NUMBER;
v_pb_status				VARCHAR2(3);
v_base_language			cz_pb_languages.language%TYPE;
xERROR				BOOLEAN:=FALSE;


CURSOR to_publish_cur	IS
			SELECT publication_id
			FROM	cz_model_publications
			WHERE	cz_model_publications.export_status = 'PEN'
			AND	cz_model_publications.product_key like '%:%';

CURSOR ui_def_cur(v_models	 cz_devl_projects.devl_project_id%TYPE) IS
			SELECT ui_def_id, ui_style
 			FROM cz_ui_defs
			WHERE  cz_ui_defs.devl_project_id = v_models
			AND    deleted_flag = '0'
			order by LAST_UPDATE_DATE desc;

CURSOR appl_cur(v_preferred_ui_style VARCHAR2) IS
			SELECT distinct application_id, application_short_name
			FROM cz_ext_applications_v
			WHERE preferred_ui_style = v_preferred_ui_style;

PROCEDURE get_base_language(x_base_lang OUT NOCOPY VARCHAR2)
AS
BEGIN
     ---select base language from fnd languages
	SELECT UPPER(language_code) INTO x_base_lang
	FROM   fnd_languages
	WHERE  fnd_languages.installed_flag IN ('B');
EXCEPTION
WHEN NO_DATA_FOUND THEN
	cz_pb_mgr.log_pb_errors(SQLERRM,1,'LANGUAGE: AUTO PUBLISH',SQLCODE);
END;

PROCEDURE insert_publication(p_ui_def_id	NUMBER,
			p_ui_style VARCHAR2,
			p_models cz_devl_projects.devl_project_id%TYPE) AS
v_application_id			cz_ext_applications_v.application_id%TYPE;
v_application_short_name	cz_ext_applications_v.application_short_name%TYPE;
BEGIN
	get_base_language(v_base_language);

	INSERT INTO cz_model_publications(
		PUBLICATION_ID,
		MODEL_ID,
		SERVER_ID,
		PRODUCT_KEY,
		organization_id,
		top_item_id,
		PUBLICATION_MODE,
		ui_def_id,
		UI_STYLE,
		APPLICABLE_FROM,
		APPLICABLE_UNTIL,
		EXPORT_STATUS,
		DELETED_FLAG,
		SOURCE_TARGET_FLAG,
		REMOTE_PUBLICATION_ID
	     )
	VALUES ( cz_model_publications_s.NEXTVAL,
		p_models,
		p_server_id,
		v_product_key,
	      v_org_id,
            v_top_item_id,
		'P',
		p_ui_def_id,
		p_ui_style,
		sysdate,
		CZ_UTILS.EPOCH_END,
		'PEN',
		'0',
		'S',
		null
		);

	OPEN appl_cur(p_ui_style);
	LOOP
		FETCH appl_cur INTO v_application_id, v_application_short_name;
		EXIT WHEN appl_cur%NOTFOUND;
		BEGIN
			INSERT INTO cz_pb_client_apps( PUBLICATION_ID,
 								FND_APPLICATION_ID,
				 				APPLICATION_SHORT_NAME,
 								NOTES
								)
				VALUES (cz_model_publications_s.CURRVAL,
					v_application_id,
					v_application_short_name,
					NULL
					);
		EXCEPTION
		WHEN OTHERS THEN
			cz_pb_mgr.log_pb_errors(SQLERRM,1,'AUTO PUBLISH',SQLCODE);
		END;

		INSERT INTO cz_pb_languages (publication_id,language)
		values (cz_model_publications_s.CURRVAL,v_base_language);
	END LOOP;
	CLOSE appl_cur;

	INSERT INTO cz_publication_usages ( PUBLICATION_ID,
							USAGE_ID
							)
		VALUES (cz_model_publications_s.CURRVAL,
			  -1
			  );
END;


BEGIN

	v_models_to_be_published.DELETE;

	SELECT devl_project_id, orig_sys_ref, last_import_date
	BULK
	COLLECT
	INTO	v_models_to_be_published,
		v_orig_sys_ref,
		v_last_import_date
	FROM    cz_devl_projects, cz_rp_entries, cz_xfr_project_bills
	WHERE   cz_devl_projects.ORIG_SYS_REF IS NOT NULL
	AND     cz_devl_projects.deleted_flag = '0'
	AND     cz_devl_projects.devl_project_id = cz_rp_entries.object_id
	AND     cz_rp_entries.object_type = 'PRJ' and cz_rp_entries.deleted_flag = '0'
	AND     cz_devl_projects.devl_project_id = cz_xfr_project_bills.model_ps_node_id(+)
	ORDER BY orig_sys_ref, last_import_date DESC;

	IF   (v_models_to_be_published.COUNT > 0 ) THEN

	     FOR I IN v_models_to_be_published.FIRST..v_models_to_be_published.LAST
	     LOOP

		IF   (v_last_import_date(i) IS NULL or v_orig_sys_ref(i) = v_pr_orig_sys_ref) THEN
		  xERROR:=CZ_UTILS.REPORT('The model ' || v_models_to_be_published(i) || ' has not been published.  Another model based on the same BOM will be published',1,'CZ_AUTO_PUBLISH',11222);
		ELSE
		  v_pr_orig_sys_ref := v_orig_sys_ref(i);
		  v_ui_def_id_tmp := NULL;
		  v_applet_ui_def_id := NULL;
		  v_dhtml_ui_def_id := NULL;
		  BEGIN
			  OPEN ui_def_cur(v_models_to_be_published(i));
			  FETCH ui_def_cur INTO v_ui_def_id_tmp, v_ui_style;

			  WHILE ui_def_cur%FOUND AND (v_applet_ui_def_id IS NULL OR v_dhtml_ui_def_id IS NULL) LOOP
			  	IF (v_ui_style = APPLET AND v_applet_ui_def_id IS NULL) THEN
					v_applet_ui_def_id := v_ui_def_id_tmp;
				ELSIF (v_ui_style = DHTML AND v_dhtml_ui_def_id IS NULL) THEN
					v_dhtml_ui_def_id := v_ui_def_id_tmp;
			  	END IF;
				FETCH ui_def_cur INTO v_ui_def_id_tmp, v_ui_style;
			  END LOOP;
			  CLOSE ui_def_cur;

			  IF (v_applet_ui_def_id IS NULL) THEN
			     v_applet_ui_def_id := 0;
			  END IF;

			  IF (v_dhtml_ui_def_id IS NULL) THEN
			     v_dhtml_ui_def_id := 0;
			  END IF;

		  END;


		  BEGIN
            	    select substr(v_orig_sys_ref(i), instr(v_orig_sys_ref(i), ':')+1) into
                	    v_product_key from dual;
		  EXCEPTION
		  WHEN OTHERS THEN
		    v_product_key := NULL;
		  END;

		  BEGIN
			  select substr(v_product_key, instr(v_product_key, ':')+1) into
                 	  v_top_item_id from dual;
		  EXCEPTION
		  WHEN OTHERS THEN
		    v_top_item_id := NULL;
	  	  END;

		  BEGIN
			  select substr(v_product_key, 1, instr(v_product_key, ':')-1) into
                 	  v_org_id from dual;
		  EXCEPTION
		  WHEN OTHERS THEN
		    v_org_id := NULL;
		  END;

		  BEGIN

		  IF (v_applet_ui_def_id > 0) THEN
			insert_publication(v_applet_ui_def_id, APPLET, v_models_to_be_published(i));
		  END IF;

		  IF (v_dhtml_ui_def_id > 0) THEN

			IF (v_applet_ui_def_id = 0) THEN
				insert_publication(v_dhtml_ui_def_id, APPLET, v_models_to_be_published(i));
                                -- publication has incorrect ui_style at this point, need to update it
				-- to DHTML
				update cz_model_publications set ui_style = DHTML where ui_def_id
                                  = v_dhtml_ui_def_id;
			END IF;

			insert_publication(v_dhtml_ui_def_id, DHTML, v_models_to_be_published(i));

		  END IF;

		  IF (v_applet_ui_def_id = 0 AND v_dhtml_ui_def_id = 0) THEN
			cz_ui_generator.createui(v_models_to_be_published(i), v_ui_def_id, v_run_id, APPLET,
			                         30, 640, 480, '0', '1', 'BLAF', 10, '0');

			BEGIN
				get_base_language(v_base_language);
	  			INSERT INTO cz_model_publications(
							PUBLICATION_ID
							,MODEL_ID
							,SERVER_ID
							,PRODUCT_KEY
							,organization_id
							,top_item_id
							,PUBLICATION_MODE
							,ui_def_id
							,UI_STYLE
							,APPLICABLE_FROM
							,APPLICABLE_UNTIL
							,EXPORT_STATUS
							,DELETED_FLAG
							,SOURCE_TARGET_FLAG
							,REMOTE_PUBLICATION_ID
							     )
						VALUES ( cz_model_publications_s.NEXTVAL,
							 v_models_to_be_published(i),
							 p_server_id,
							 v_product_key,
						       v_org_id,
                                           v_top_item_id,
							 'P',
							 v_ui_def_id,
							 APPLET,
							 sysdate,
							 CZ_UTILS.EPOCH_END,
							 'PEN',
							 '0',
							 'S',
							 null
							);

				BEGIN
					SELECT application_id
					INTO   v_application_id
					FROM   fnd_application
					WHERE  application_short_name = 'ONT';
				EXCEPTION
				WHEN OTHERS THEN
				v_application_id := -50;
				END;


				INSERT INTO cz_pb_client_apps( PUBLICATION_ID
 							  ,FND_APPLICATION_ID
 							  ,APPLICATION_SHORT_NAME
 							  ,NOTES
							 )
						VALUES ( cz_model_publications_s.CURRVAL,
							 v_application_id,
							 'ONT',
							  null
							);


				INSERT INTO cz_publication_usages ( PUBLICATION_ID
								,USAGE_ID
							      )
						   VALUES (cz_model_publications_s.CURRVAL,
							   -1
							  );

				INSERT INTO cz_pb_languages (publication_id,language)
				values (cz_model_publications_s.CURRVAL,v_base_language);
			EXCEPTION
			WHEN OTHERS THEN
				cz_pb_mgr.log_pb_errors(SQLERRM,1,'AUTO PUBLISH',SQLCODE);
			END;
		  END IF;

		  EXCEPTION
		  WHEN OTHERS THEN
			cz_pb_mgr.log_pb_errors(SQLERRM,1,'AUTO PUBLISH',SQLCODE);
		  END;
		END IF;
	    END LOOP;
	    COMMIT;
	END IF;


	OPEN to_publish_cur;
	LOOP
		FETCH to_publish_cur INTO v_to_publish_id;
		EXIT WHEN to_publish_cur%NOTFOUND;
		BEGIN
			cz_pb_mgr.publish_model(v_to_publish_id, v_pb_run_id, v_pb_status);
		EXCEPTION
		WHEN OTHERS THEN
			cz_pb_mgr.log_pb_errors(SQLERRM,1,'AUTO PUBLISH',SQLCODE);
		END;
	END LOOP;

	-- insert cz_xfr_project_bills records for references
	generate_xfr_reference_bills;
	COMMIT;

EXCEPTION
WHEN OTHERS THEN
cz_pb_mgr.log_pb_errors(SQLERRM,1,'AUTO PUBLISH',SQLCODE);
END AUTO_PUBLISH;

-----------------------------------------------------
-----------------------------------------------------

PROCEDURE CZBOMSORT(p_model_id   IN INTEGER,
                    p_sort_width IN INTEGER,
                    p_batch_size IN INTEGER) IS

v_ps_node_id     INTEGER;
numRecord        INTEGER:=0;
BatchSize        INTEGER:=p_batch_size;
var_bom_sort     CZ_PS_NODES.bom_sort_order%TYPE;
xERROR BOOLEAN:=FALSE;


FUNCTION getNum(p_number IN INTEGER) RETURN VARCHAR2 IS
    ret VARCHAR2(100);
BEGIN
    SELECT LPAD(TO_CHAR(p_number),p_sort_width,'0') INTO ret FROM dual;
    RETURN ret;
END getNum;

PROCEDURE populate(p_ps_node_id IN INTEGER,p_string1 IN VARCHAR2,p_string2 IN VARCHAR2) IS
    var_token   VARCHAR2(1);
    var_string1 CZ_PS_NODES.bom_sort_order%TYPE;
    var_string2 CZ_PS_NODES.component_sequence_path%TYPE;
BEGIN
    FOR i IN (SELECT ps_node_id,parent_id,tree_seq,ps_node_type,
              component_sequence_id,component_sequence_path FROM CZ_PS_NODES
              WHERE parent_id=p_ps_node_id AND ps_node_type IN(263,436,437,438)
              AND deleted_flag='0')
    LOOP
       IF p_string2='' OR p_string2 IS NULL THEN
          var_token:='';
       ELSE
          var_token:='-';
       END IF;
       var_string1:=p_string1||getNum(i.tree_seq);
       var_string2:=p_string2||var_token||TO_CHAR(i.component_sequence_id);
       UPDATE CZ_PS_NODES SET bom_sort_order=var_string1
       WHERE ps_node_id=i.ps_node_id AND bom_sort_order is NULL;
       UPDATE CZ_PS_NODES SET component_sequence_path=var_string2
       WHERE ps_node_id=i.ps_node_id AND component_sequence_path is NULL;
       populate(i.ps_node_id,var_string1,var_string2);
       IF numRecord>BatchSize THEN
          COMMIT;
          numRecord:=0;
       ELSE
          numRecord:=numRecord+1;
       END IF;
    END LOOP;
END populate;

BEGIN
    var_bom_sort:=getNum(1);

    UPDATE CZ_PS_NODES SET component_sequence_path=NULL,bom_sort_order=var_bom_sort
    WHERE ps_node_id = p_model_id;

    populate(p_model_id,var_bom_sort,'');

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
WHEN OTHERS THEN
     NULL;
END CZBOMSORT;

-----------------------------------------------------
-----------------------------------------------------

PROCEDURE generate_explosion IS

  v_origsysref  cz_ps_nodes.orig_sys_ref%TYPE;
  x_error       BOOLEAN;

  schema_version NUMBER;

BEGIN

 --Initialize id allocation for model explosions ids

 SELECT cz_model_ref_expls_s.NEXTVAL INTO base_expl_id FROM dual;
 next_expl_id := base_expl_id;

 --Initialize id allocation for ps_node ids

 SELECT cz_ps_nodes_s.NEXTVAL INTO base_node_id FROM dual;
 next_node_id := base_node_id;

 --Set the virtual_flag for all the nodes

 UPDATE cz_expression_nodes SET consequent_flag = flag_not_consequent;
 COMMIT;

--Updates consequent flags in a bunch for all projects in the schema

 UPDATE cz_expression_nodes SET consequent_flag = flag_is_consequent
 WHERE expr_node_id IN
 (SELECT child1.expr_node_id
    FROM cz_rules rule, cz_expression_nodes parent, cz_expression_nodes child1,
         cz_expression_nodes child2
   WHERE
 --Parent is not deleted and is operator dot
         parent.deleted_flag = flag_not_deleted
     AND parent.expr_type = expr_node_type_operator
     AND parent.expr_subtype = operator_dot
 --Rule is not deleted or disabled
     AND rule.deleted_flag = flag_not_deleted
     AND rule.disabled_flag = flag_not_disabled
 --Both children are not deleted and are children of the parent
     AND child1.deleted_flag = flag_not_deleted
     AND child2.deleted_flag = flag_not_deleted
     AND child1.expr_parent_id = parent.expr_node_id
     AND child2.expr_parent_id = parent.expr_node_id
 --Parent is the consequent expression for the rule
     AND rule.consequent_id = parent.express_id
 --One child is a node expression node
     AND child1.expr_type = expr_node_type_node
 --Another child is system property, min or max
     AND child2.expr_type = expr_node_type_sysprop
     AND child2.expr_subtype IN (sys_prop_min, sys_prop_max)
 );

 COMMIT;

 UPDATE cz_ps_nodes SET virtual_flag = flag_virtual
 WHERE ps_node_type IN (ps_node_type_product, ps_node_type_component, ps_node_type_bom_model);

 COMMIT;

 UPDATE cz_ps_nodes SET virtual_flag = flag_non_virtual WHERE ps_node_id IN (
 SELECT structure.ps_node_id
 FROM cz_ps_nodes structure, cz_ps_nodes parent
 WHERE structure.ps_node_type IN (ps_node_type_product, ps_node_type_component, ps_node_type_bom_model)
   AND parent.ps_node_id = structure.parent_id
   AND (structure.ps_node_type IN (ps_node_type_product, ps_node_type_component) OR parent.ps_node_type <> ps_node_type_product)
   AND structure.deleted_flag = flag_not_deleted
   AND (structure.ps_node_type = ps_node_type_bom_model OR (
       (structure.minimum <> 1 OR structure.maximum <> 1 OR EXISTS
    --Expressions are joined to bring in project
        (SELECT NULL
           FROM cz_expressions expr, cz_expression_nodes node
          WHERE expr.devl_project_id = structure.devl_project_id
            AND node.ps_node_id = structure.ps_node_id
            AND expr.deleted_flag = flag_not_deleted
            AND node.deleted_flag = flag_not_deleted
    --Consequent flag '1' guarantees existence of a rule
            AND node.consequent_flag = flag_is_consequent
   )))));

 COMMIT;

 FOR c_devl IN (SELECT devl_project_id, orig_sys_ref FROM cz_devl_projects p
                WHERE deleted_flag = flag_not_deleted
                  AND devl_project_id <> 0
                  AND EXISTS (
                   SELECT NULL FROM cz_ps_nodes
                   WHERE deleted_flag = flag_not_deleted
                   AND ps_node_type = ps_node_type_product
                   AND devl_project_id = p.devl_project_id)
                  AND NOT EXISTS
                  (SELECT NULL FROM cz_model_ref_expls
                    WHERE model_id = p.devl_project_id)
 ) LOOP

  IF(c_devl.orig_sys_ref IS NOT NULL)THEN

    UPDATE cz_devl_projects SET
     orig_sys_ref =
      (SELECT nvl(substr(parent.orig_sys_ref,instr(parent.orig_sys_ref,':',-1,3)+1),
                  substr(child.orig_sys_ref,instr(child.orig_sys_ref,':',-1,3)+1))
         FROM cz_ps_nodes parent, cz_ps_nodes child
        WHERE parent.ps_node_id = c_devl.devl_project_id
          AND parent.ps_node_type = 258
          AND child.ps_node_type IN (258, 436)
          AND parent.ps_node_id = child.parent_id
          AND ROWNUM = 1)
    WHERE devl_project_id = c_devl.devl_project_id;

    UPDATE cz_ps_nodes SET
     orig_sys_ref =
      (SELECT orig_sys_ref FROM cz_devl_projects WHERE devl_project_id = c_devl.devl_project_id)
    WHERE ps_node_id = c_devl.devl_project_id
    returning orig_sys_ref INTO v_origsysref;

    INSERT INTO cz_xfr_project_bills (model_ps_node_id,
                                      organization_id,
                                      top_item_id,
                                      explosion_type,
                                      deleted_flag,
                                      source_server,
						  last_import_date) -- fix for bug # 2406244
    SELECT c_devl.devl_project_id,
           substr(v_origsysref, instr(v_origsysref, ':') + 1, instr(v_origsysref, ':', 1, 2) - instr(v_origsysref, ':') - 1),
           substr(v_origsysref, instr(v_origsysref, ':', -1, 1) + 1),
           substr(v_origsysref, 1, instr(v_origsysref, ':') - 1),
           '0',
           0,
	     sysdate -- fix for bug # 2406244
    FROM dual
    WHERE NOT EXISTS (SELECT NULL FROM cz_xfr_project_bills
                       WHERE model_ps_node_id = c_devl.devl_project_id);

  END IF;

   generate_model_tree(c_devl.devl_project_id);
 END LOOP;

 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    x_error:=cz_utils.report(SQLERRM,1,'CZ_EXPLS_GEN.GENERATE_EXPLOSION',11500);
END generate_explosion;
---------------------------------------------------------------------------------------
PROCEDURE generate_model_tree(indevlprojectid IN NUMBER) IS
  npsnodeid    NUMBER;
  nminimum     NUMBER;
  nmaximum     NUMBER;
  x_error      BOOLEAN;
BEGIN

  --Start off the recursion

  root_model_id := indevlprojectid;
  generate_component_tree(indevlprojectid, 0, NULL, NULL, NULL);

--Handle here the exceptions that should terminate the model tree generation
--process or the logic generation at all. An exception that is not re-raised
--here will terminate just the model tree generation and go on with logic
--generation. Exceptions that are re-raised should be caught in the calling
--routine.

COMMIT;

EXCEPTION
  WHEN OTHERS THEN
--***May require change before final
    x_error:=cz_utils.report(SQLERRM,1,'CZ_EXPLS_GEN.GENERATE_MODEL_TREE',11500);
END generate_model_tree;
---------------------------------------------------------------------------------------
PROCEDURE generate_component_tree(incomponentid       IN NUMBER,
                                  inlogicnetlevel     IN NUMBER,
                                  inparentexplid      IN NUMBER,
                                  inparentcomponentid IN NUMBER,
                                  inreferringnodeid   IN NUMBER)
IS

 TYPE tpsnodeid             IS TABLE OF cz_ps_nodes.ps_node_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tpsnodetype           IS TABLE OF cz_ps_nodes.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tinitialvalue         IS TABLE OF cz_ps_nodes.initial_value%TYPE INDEX BY BINARY_INTEGER;
 TYPE tinitnumval           IS TABLE OF cz_ps_nodes.initial_num_value%TYPE INDEX BY BINARY_INTEGER; -- sselahi
 TYPE tparentid             IS TABLE OF cz_ps_nodes.parent_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tvirtualflag          IS TABLE OF cz_ps_nodes.virtual_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tfeaturetype          IS TABLE OF cz_ps_nodes.feature_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tname                 IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
 TYPE tdescriptionid        IS TABLE OF cz_ps_nodes.intl_text_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tminimumsel           IS TABLE OF cz_ps_nodes.minimum_selected%TYPE INDEX BY BINARY_INTEGER;
 TYPE tmaximumsel           IS TABLE OF cz_ps_nodes.maximum_selected%TYPE INDEX BY BINARY_INTEGER;
 TYPE tbomrequired          IS TABLE OF cz_ps_nodes.bom_required_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE treferenceid          IS TABLE OF cz_ps_nodes.reference_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE ttreeseq              IS TABLE OF cz_ps_nodes.tree_seq%TYPE INDEX BY BINARY_INTEGER;
 TYPE torigsysref           IS TABLE OF cz_ps_nodes.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
 TYPE teffectivefrom        IS TABLE OF cz_ps_nodes.effective_from%TYPE INDEX BY BINARY_INTEGER;
 TYPE teffectiveuntil       IS TABLE OF cz_ps_nodes.effective_until%TYPE INDEX BY BINARY_INTEGER;
 TYPE tcomponentsequenceid  IS TABLE OF cz_ps_nodes.component_sequence_id%TYPE INDEX BY BINARY_INTEGER;

 ntpsnodeid                 tpsnodeid;
 ntpsnodetype               tpsnodetype;
 nvpsnodetype               tpsnodetype;
 ntinitialvalue             tinitialvalue;
 ntinitnumval               tinitnumval; --sselahi
 ntparentid                 tparentid;
 ntvirtualflag              tvirtualflag;
 ntfeaturetype              tfeaturetype;
 ntname                     tname;
 ntdescriptionid            tdescriptionid;
 ntminimumsel               tminimumsel;
 ntmaximumsel               tmaximumsel;
 ntbomrequired              tbomrequired;
 ntreferenceid              treferenceid;
 nttreeseq                  ttreeseq;
 ntorigsysref               torigsysref;
 nteffectivefrom            teffectivefrom;
 nteffectiveuntil           teffectiveuntil;
 ntcomponentsequenceid      tcomponentsequenceid;

 npsnodetype       NUMBER;
 svirtualflag      VARCHAR2(1);
 save_expl_id      NUMBER;
 localmodelid      NUMBER;
 modelpsnodeid     NUMBER;
 ncount            NUMBER;
 genname           cz_ps_nodes.name%TYPE;

 stopitemid        VARCHAR2(25);
 ncutstart         PLS_INTEGER;

 correct_expl_id   NUMBER;
 x_error           BOOLEAN;

BEGIN

  current_expl_id := next_expl_id;
  IF(next_expl_id = base_expl_id)THEN
     SELECT cz_model_ref_expls_s.NEXTVAL INTO base_expl_id FROM dual;
  END IF;
  next_expl_id := next_expl_id + 1;

  IF(inparentexplid IS NULL)THEN
    currentmodelid := incomponentid;
  END IF;

  SELECT ps_node_type, virtual_flag INTO npsnodetype, svirtualflag
  FROM cz_ps_nodes WHERE ps_node_id = incomponentid;

  localmodelid := currentmodelid;
  IF(npsnodetype IN (ps_node_type_bom_model/*, ps_node_type_product*/))THEN
   localmodelid := incomponentid;
  END IF;

  INSERT INTO cz_model_ref_expls
   (model_ref_expl_id, parent_expl_node_id, component_id, model_id,
    node_depth, virtual_flag, deleted_flag, ps_node_type)
  SELECT
    current_expl_id,
    decode(npsnodetype, ps_node_type_bom_model, NULL, /*PS_NODE_TYPE_PRODUCT, NULL,*/ inparentexplid),
    incomponentid,
    localmodelid,
    decode(npsnodetype, ps_node_type_bom_model, 0, /*PS_NODE_TYPE_PRODUCT, 0,*/ inlogicnetlevel),
    decode(inlogicnetlevel, 0, flag_virtual, svirtualflag),
    flag_not_deleted, npsnodetype
   FROM dual WHERE NOT EXISTS
    (SELECT NULL FROM cz_model_ref_expls WHERE model_id = localmodelid AND component_id = incomponentid);

  correct_expl_id := current_expl_id;

  IF(npsnodetype IN (ps_node_type_bom_model/*, ps_node_type_product*/))THEN

    FOR expl IN (SELECT model_ref_expl_id, node_depth, model_id FROM cz_model_ref_expls
                 WHERE component_id = inparentcomponentid) LOOP

     BEGIN

      local_expl_id := next_expl_id;
      IF(next_expl_id = base_expl_id)THEN
         SELECT cz_model_ref_expls_s.NEXTVAL INTO base_expl_id FROM dual;
      END IF;
      next_expl_id := next_expl_id + 1;

      IF(expl.model_id = root_model_id)THEN correct_expl_id := local_expl_id; END IF;

      INSERT INTO cz_model_ref_expls
       (model_ref_expl_id, parent_expl_node_id, node_depth, ps_node_type, virtual_flag,
        component_id, model_id, referring_node_id, child_model_expl_id, deleted_flag)
      SELECT
        local_expl_id, expl.model_ref_expl_id, expl.node_depth + 1, ps_node_type_reference,
        flag_virtual, incomponentid, expl.model_id, inreferringnodeid, current_expl_id,
        flag_not_deleted
      FROM dual WHERE NOT EXISTS
       (SELECT NULL FROM cz_model_ref_expls
        WHERE component_id = incomponentid
          AND model_id = expl.model_id
          AND referring_node_id = inreferringnodeid
          AND child_model_expl_id = current_expl_id);

     EXCEPTION
       WHEN OTHERS THEN
--***May require change before final
         x_error:=cz_utils.report(SQLERRM,1,'CZ_EXPLS_GEN.GENERATE_COMPONENT_TREE1',11500);
     END;
    END LOOP;

  END IF;

  --This select statement reads the whole 'virtual' tree under a non-virtual component
  --which doesn't include the chief non-virtual component itself, although it includes
  --non-virtual components underneath in order to recurse,this function will be called
  --for every non-virtual component found underneath.
  --The resulting order provided by this statement will be used later when generating
  --list of options for an option feature.

  SELECT ps_node_id, parent_id, name, intl_text_id, tree_seq,
         minimum, maximum, ps_node_type, initial_value, initial_num_value, -- sselahi
         virtual_flag, feature_type, bom_required_flag, reference_id, orig_sys_ref,
         effective_from, effective_until, component_sequence_id
  bulk collect INTO ntpsnodeid, ntparentid, ntname, ntdescriptionid, nttreeseq,
                    ntminimumsel, ntmaximumsel, ntpsnodetype, ntinitialvalue, ntinitnumval, -- sselahi
                    ntvirtualflag, ntfeaturetype, ntbomrequired, ntreferenceid, ntorigsysref,
                    nteffectivefrom, nteffectiveuntil, ntcomponentsequenceid
  FROM cz_ps_nodes
  WHERE deleted_flag = flag_not_deleted
  START WITH parent_id = incomponentid
  CONNECT BY
   (PRIOR virtual_flag IS NULL OR PRIOR virtual_flag = flag_virtual)
   AND PRIOR ps_node_id = parent_id;

  UPDATE cz_expression_nodes SET model_ref_expl_id = correct_expl_id
  WHERE ps_node_id = incomponentid AND deleted_flag = flag_not_deleted;

  UPDATE cz_func_comp_specs SET model_ref_expl_id = correct_expl_id
  WHERE component_id = incomponentid AND deleted_flag = flag_not_deleted;

  UPDATE cz_combo_features SET model_ref_expl_id = correct_expl_id
  WHERE feature_id = incomponentid AND deleted_flag = flag_not_deleted;

  UPDATE cz_des_chart_features SET model_ref_expl_id = correct_expl_id
  WHERE feature_id = incomponentid AND deleted_flag = flag_not_deleted;

  UPDATE cz_des_chart_cells SET secondary_feat_expl_id = correct_expl_id
  WHERE secondary_feature_id = incomponentid AND deleted_flag = flag_not_deleted;

  UPDATE cz_ui_nodes SET model_ref_expl_id = correct_expl_id
  WHERE ps_node_id = incomponentid AND deleted_flag = flag_not_deleted;

  --Make sure there is some data returned

  IF(ntpsnodeid.last IS NOT NULL)THEN

  FOR i IN ntpsnodeid.first..ntpsnodeid.last LOOP

  UPDATE cz_expression_nodes SET model_ref_expl_id = correct_expl_id
  WHERE ps_node_id = ntpsnodeid(i) AND deleted_flag = flag_not_deleted;

  UPDATE cz_func_comp_specs SET model_ref_expl_id = correct_expl_id
  WHERE component_id = ntpsnodeid(i) AND deleted_flag = flag_not_deleted;

  UPDATE cz_combo_features SET model_ref_expl_id = correct_expl_id
  WHERE feature_id = ntpsnodeid(i) AND deleted_flag = flag_not_deleted;

  UPDATE cz_des_chart_features SET model_ref_expl_id = correct_expl_id
  WHERE feature_id = ntpsnodeid(i) AND deleted_flag = flag_not_deleted;

  UPDATE cz_des_chart_cells SET secondary_feat_expl_id = correct_expl_id
  WHERE secondary_feature_id = ntpsnodeid(i) AND deleted_flag = flag_not_deleted;

  UPDATE cz_ui_nodes SET model_ref_expl_id = correct_expl_id
  WHERE ps_node_id = ntpsnodeid(i) AND deleted_flag = flag_not_deleted;

  END LOOP;

  save_expl_id := current_expl_id;

  FOR i IN ntpsnodeid.first..ntpsnodeid.last LOOP

   modelpsnodeid := ntpsnodeid(i);

  IF(ntpsnodetype(i) IN (ps_node_type_component, ps_node_type_product, ps_node_type_bom_model) AND
     ntvirtualflag(i) = flag_non_virtual)THEN

    IF(ntpsnodetype(i) IN (ps_node_type_bom_model/*, ps_node_type_product*/))THEN

     genname := ntname(i);

     BEGIN
      SELECT object_id INTO ncount FROM cz_rp_entries
       WHERE deleted_flag = flag_not_deleted
         AND object_type = 'PRJ'
         AND name = ntname(i);

      ncount := NULL;
      BEGIN
       SELECT MAX(cz_utils.conv_num(substr(name, 7, instr(name, ')') - 7))) INTO ncount
         FROM cz_rp_entries
        WHERE deleted_flag = flag_not_deleted
          AND object_type = 'PRJ'
          AND name LIKE 'Copy (%) of ' || ntname(i);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF(ncount IS NULL)THEN ncount := 0; END IF;
      genname := 'Copy (' || to_char(ncount + 1) || ') of ' || ntname(i);

     EXCEPTION
       WHEN OTHERS THEN
         genname := ntname(i);
     END;

     current_node_id := next_node_id;
     IF(next_node_id = base_node_id)THEN
       SELECT cz_ps_nodes_s.NEXTVAL INTO base_node_id FROM dual;
     END IF;
     next_node_id := next_node_id + 1;

     BEGIN

--Insert the reference node

      INSERT INTO cz_ps_nodes
       (ps_node_id, parent_id, ps_node_type, minimum, maximum, minimum_selected, maximum_selected,
        name, tree_seq, deleted_flag, devl_project_id, virtual_flag, reference_id,
        system_node_flag, ui_omit, effective_from, effective_until, orig_sys_ref,
        component_sequence_id)
      SELECT
       current_node_id, ntparentid(i), ps_node_type_reference, 1, 1, ntminimumsel(i), ntmaximumsel(i),
       genname, nttreeseq(i), flag_not_deleted, localmodelid, flag_virtual, modelpsnodeid,
       '0', '0', nteffectivefrom(i), nteffectiveuntil(i), ntorigsysref(i),
       ntcomponentsequenceid(i)
      FROM dual;

       ncutstart := instr(ntorigsysref(i), '-', -1, 1) + 1;
       stopitemid := substr(ntorigsysref(i),ncutstart,instr(ntorigsysref(i),':')-ncutstart);

       UPDATE cz_ps_nodes SET
         parent_id = NULL,
         minimum = 0,
         maximum = -1,
         tree_seq = 1,
         component_sequence_id = NULL,
         virtual_flag = flag_virtual
       WHERE ps_node_id = ntpsnodeid(i);

       UPDATE cz_ps_nodes SET
          devl_project_id = ntpsnodeid(i),
          --orig_sys_ref = SUBSTR(orig_sys_ref, INSTR(orig_sys_ref, '-', 1, inLogicNetLevel + 2) + 1)
          orig_sys_ref = substr(substr(orig_sys_ref, ncutstart),1,instr(substr(orig_sys_ref, ncutstart),':',-1,1)) || stopitemid
       WHERE ps_node_id IN
        (SELECT ps_node_id FROM cz_ps_nodes
         WHERE deleted_flag = flag_not_deleted
         START WITH ps_node_id = ntpsnodeid(i)
         CONNECT BY PRIOR ps_node_id = parent_id);

--Insert into cz_rule_folders

       INSERT INTO cz_rule_folders
        (rule_folder_id,name,tree_seq,devl_project_id,created_by,last_updated_by,
         creation_date,last_update_date,deleted_flag)
       SELECT cz_rule_folders_s.NEXTVAL,ntname(i)||' Rules',0,
         ntpsnodeid(i),UID,UID,SYSDATE,SYSDATE,'0'
       FROM dual WHERE NOT EXISTS
       (SELECT 1 FROM cz_rule_folders WHERE
        devl_project_id=ntpsnodeid(i) AND
        parent_rule_folder_id IS NULL AND name=ntname(i)||' Rules');

--Insert and take care of orig_sys_ref

       INSERT INTO cz_devl_projects
        (devl_project_id, name, persistent_project_id, deleted_flag, orig_sys_ref)
       SELECT
        ntpsnodeid(i), genname, ntpsnodeid(i), flag_not_deleted,
        substr(ntorigsysref(i),instr(ntorigsysref(i),':',-1,3)+1,instr(ntorigsysref(i),':',-1,2)-instr(ntorigsysref(i),':',-1,3)-1) || ':' ||
        substr(ntorigsysref(i),instr(ntorigsysref(i),':',-1,2)+1,instr(ntorigsysref(i),':',-1,1)-instr(ntorigsysref(i),':',-1,2)-1) || ':' ||
        stopitemid /*substr(ntOrigSysRef(i),instr(ntOrigSysRef(i),':',-1,1)+1)*/
       FROM dual WHERE NOT EXISTS
        (SELECT NULL FROM cz_devl_projects WHERE devl_project_id = ntpsnodeid(i));

--Insert into cz_rp_entries

       INSERT INTO cz_rp_entries
        (object_type,object_id,enclosing_folder,name,description,deleted_flag)
       SELECT 'PRJ',ntpsnodeid(i),0,
        genname,genname,'0'
       FROM dual WHERE NOT EXISTS
        (SELECT 1 FROM cz_rp_entries WHERE
         (object_type='PRJ' AND object_id=ntpsnodeid(i)) OR
         (enclosing_folder=0 AND name=genname));

     EXCEPTION
       WHEN OTHERS THEN
--***May require change before final
         x_error:=cz_utils.report(SQLERRM,1,'CZ_EXPLS_GEN.GENERATE_COMPONENT_TREE2',11500);
     END;

    END IF;

    --This is another non-virtual component. Call this function for it - recursion

     generate_component_tree(modelpsnodeid, inlogicnetlevel + 1, save_expl_id, incomponentid, current_node_id);

  END IF;

  END LOOP;

  END IF;

END generate_component_tree;
---------------------------------------------------------------------------------------
------procedures used for upgrading logic from builds 14,15,16,17 to 18 to more
------function that gets the major schema version from db settings table

FUNCTION get_major_version
RETURN VARCHAR2
IS

v_schema_version cz_db_settings.value%TYPE;
BEGIN
	SELECT value
	INTO   cz_upgrade.v_schema_version
	FROM   cz_db_settings
	WHERE  cz_db_settings.setting_id = MAJOR_SCHEMA_VERSION;
	RETURN cz_upgrade.v_schema_version;
EXCEPTION
WHEN OTHERS THEN
	cz_upgrade.v_schema_version := 0;
	RETURN cz_upgrade.v_schema_version;
END get_major_version;
------------------------
---------procedure that logs errors to cz_db_logs.
PROCEDURE report_upgrade_logic_errors(p_from_schema VARCHAR2,
				    p_to_schema VARCHAR2,
				    p_lce_header_id NUMBER,
				    p_err_message VARCHAR2,
				    p_message_flag VARCHAR2
				    )
IS
v_message VARCHAR2(4000);
v_run_id cz_db_logs.run_id%TYPE;
v_caller cz_db_logs.caller%TYPE;

BEGIN
	SELECT cz_xfr_run_infos_s.nextval into v_run_id FROM dual;

	v_message := 'Logic upgrade from schema '||p_from_schema||' for lce_header_id '||p_lce_header_id||' : '||p_err_message ;
	v_message := SUBSTR(v_message,1,2000);

	IF (p_message_flag = 'LOGIC_UPGRADE') THEN
		v_caller := 'UPGRADE_LOGIC';
	ELSIF (p_message_flag = 'VERIFY_LOGIC') THEN
		v_caller := 'VERIFY_LOGIC';
	END IF;

	INSERT INTO cz_db_logs (LOGTIME,LOGUSER,URGENCY,CALLER,STATUSCODE,MESSAGE,CREATED_BY,CREATION_DATE,SESSION_ID
					,MESSAGE_ID,RUN_ID)
		      VALUES (sysdate,'upgrade_logic_user',1,v_caller,0,v_message,-1,sysdate,1,1,v_run_id);
	COMMIT;
END report_upgrade_logic_errors;
----------------------------
--------procedure that upgrades logic from a 14 build to a 18 build
PROCEDURE upgrade_logic_from_14
IS

TYPE tDevlProjectId IS TABLE OF cz_devl_projects.devl_project_id%TYPE;
runId          number;
devlProjectId  tDevlProjectId;
v_rule_count   number := 0;

begin
	------------select all source models to generate logic
	SELECT devl_project_id
	BULK
	COLLECT
	INTO  devlProjectId
	FROM  cz_devl_projects
	WHERE cz_devl_projects.deleted_flag = '0'
	AND   cz_devl_projects.devl_project_id  IN (SELECT object_id
						    FROM   cz_rp_entries
						    WHERE  cz_rp_entries.deleted_flag = '0'
						    AND    cz_rp_entries.object_type = 'PRJ');

	IF (devlProjectId.COUNT > 0) THEN
		FOR i IN devlProjectId.FIRST..devlProjectId.LAST
		LOOP
		   -- delete cz_lce_headers for component_id = devl_project_id with model_ref_expl_flag = -1
		   -- Bug #2369725
		   update cz_lce_headers set deleted_flag = '1'
			where component_id = devlProjectId(i)
			and deleted_flag = '0'
			and model_ref_expl_id = -1;
			commit;
		   cz_logic_gen.generate_logic(devlProjectId(i), runId);
		END LOOP;
	END IF;
end upgrade_logic_from_14;
--------------------------------
-------------function that does a check if load_specs has to be populated
FUNCTION has_to_populate_load_specs(p_lce_header_id IN NUMBER)
RETURN BOOLEAN
IS

v_count PLS_INTEGER := 0;
BEGIN
	SELECT count(*)
	INTO   v_count
	FROM   cz_lce_load_specs
	WHERE  cz_lce_load_specs.lce_header_id = p_lce_header_id
	AND    cz_lce_load_specs.deleted_flag = '0';

	IF (v_count > 0) THEN
		SELECT count(*)
		INTO   v_count
		FROM   cz_lce_load_specs
		WHERE  cz_lce_load_specs.lce_header_id = p_lce_header_id
		AND    cz_lce_load_specs.attachment_expl_id > 0
		AND    cz_lce_load_specs.required_expl_id > 0
		AND    cz_lce_load_specs.attachment_comp_id > 0
		AND    cz_lce_load_specs.model_id > 0
		AND    cz_lce_load_specs.net_type > 0
		AND    cz_lce_load_specs.deleted_flag = '0';

		IF (v_count = 0) THEN
			update cz_lce_load_specs
			 set   deleted_flag = '1'
			where  cz_lce_load_specs.lce_header_id = p_lce_header_id
			and    cz_lce_load_specs.deleted_flag = '0';
			commit;
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	ELSE
	      RETURN TRUE;
	END IF;
EXCEPTION
WHEN OTHERS THEN
	RETURN TRUE;
END has_to_populate_load_specs;
--------------------------------------
-----------------
---------procedure that gets valid LCE headers for source and published models
---------p_model_flag is 'S' for a source model and 'P' for a published model
---------x_lce_header_tbl is the table of valid lce headers.

PROCEDURE get_lce_headers(p_model_flag IN VARCHAR2, x_lce_header_tbl IN OUT NOCOPY  cz_upgrade.t_ref, x_err_message IN OUT NOCOPY VARCHAR2)
IS

v_published_root_models_tbl	cz_upgrade.t_ref;
v_all_published_models_tbl	cz_upgrade.t_ref;
v_child_models_tbl		cz_upgrade.t_ref;
v_lce_hdrs_tbl			cz_upgrade.t_ref;
v_published_model_count		NUMBER := 0;

BEGIN
	IF (p_model_flag = 'S') THEN

		BEGIN
			SELECT lce_header_id
			BULK
			COLLECT
			INTO	 x_lce_header_tbl
			FROM	 cz_lce_headers
			WHERE  cz_lce_headers.deleted_flag = '0'
			AND    cz_lce_headers.component_id IN
								(
								  SELECT ps_node_id
								  FROM   cz_ps_nodes
								  WHERE  cz_ps_nodes.deleted_flag = '0'
								  AND    cz_ps_nodes.devl_project_id IN
													(
													  SELECT object_id
													  FROM   cz_rp_entries
													  WHERE  cz_rp_entries.deleted_flag = '0'
													  AND    cz_rp_entries.object_type = 'PRJ'
													)
								);
		EXCEPTION
		WHEN OTHERS THEN
			RAISE;
		END;

	ELSIF (p_model_flag = 'P') THEN

		------get model_id of all valid target publications
		BEGIN
			SELECT model_id
			BULK
			COLLECT
			INTO   v_published_root_models_tbl
			FROM   cz_model_publications
			WHERE  cz_model_publications.deleted_flag = '0'
			AND    cz_model_publications.export_status = 'OK'
			AND    cz_model_publications.source_target_flag = 'T';
		EXCEPTION
		WHEN OTHERS THEN
			RAISE;
		END;

		------get the child model(s) of the published models
		v_all_published_models_tbl.DELETE;
		IF (v_published_root_models_tbl.COUNT > 0) THEN
			FOR rootModel IN v_published_root_models_tbl.FIRST..v_published_root_models_tbl.LAST
			LOOP
				IF (v_published_root_models_tbl(rootModel) IS NOT NULL) THEN
					v_child_models_tbl.DELETE;
					BEGIN
						SELECT component_id
						BULK
						COLLECT
						INTO   v_child_models_tbl
						FROM   cz_model_ref_expls
						WHERE  cz_model_ref_expls.model_id = v_published_root_models_tbl(rootModel)
						AND    cz_model_ref_expls.deleted_flag = '0';
						-----AND    cz_model_ref_expls.ps_node_type = '263';
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						x_err_message := substr(SQLERRM,1,2000);
					WHEN OTHERS THEN
						x_err_message := substr(SQLERRM,1,2000);
					END;
					IF (v_child_models_tbl.COUNT > 0) THEN
						FOR childModel IN v_child_models_tbl.FIRST..v_child_models_tbl.LAST
						LOOP
						      v_published_model_count := v_all_published_models_tbl.COUNT + 1;
							v_all_published_models_tbl(v_published_model_count) := v_child_models_tbl(childModel);
						END LOOP;
					END IF;

			  	      v_published_model_count := v_all_published_models_tbl.COUNT + 1;
					v_all_published_models_tbl(v_published_model_count) := v_published_root_models_tbl(rootModel);
				 END IF;
			 END LOOP;
		  END IF;

		  IF (v_all_published_models_tbl.COUNT > 0) THEN
			FOR pubLceHdr IN v_all_published_models_tbl.FIRST..v_all_published_models_tbl.LAST
			LOOP
				BEGIN
					SELECT  lce_header_id
					BULK
					COLLECT
					INTO    v_lce_hdrs_tbl
					FROM    cz_lce_headers
					WHERE   cz_lce_headers.component_id = v_all_published_models_tbl(pubLceHdr)
					AND     cz_lce_headers.deleted_flag = '0';
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					x_err_message := 'The lce_header_id  for component '||v_all_published_models_tbl(pubLceHdr)||' does not have data in cz_lce_headers';
				WHEN OTHERS THEN
					RAISE;
				END;

				IF (v_lce_hdrs_tbl.COUNT > 0) THEN
					FOR k IN v_lce_hdrs_tbl.FIRST..v_lce_hdrs_tbl.LAST
					LOOP
						v_published_model_count := x_lce_header_tbl.COUNT + 1;
						x_lce_header_tbl(v_published_model_count) := v_lce_hdrs_tbl(k);
					END LOOP;
				END IF;
			END LOOP;
		 END IF;
	END IF;


	x_err_message := NULL;
EXCEPTION
WHEN OTHERS THEN
	x_err_message := substr(SQLERRM,1,2000);
	RAISE;
END get_lce_headers;
---------------------------------------------
---------procedure that inserts LCE data into cz_lce_load_specs table
---------
PROCEDURE cz_populate_lce_load_specs(p_lce_header_id IN NUMBER,
				      	 x_populate_error_flag IN OUT NOCOPY VARCHAR2,
		                         x_populate_error_msg  IN OUT NOCOPY VARCHAR2)
IS

v_lce_header_id		cz_lce_headers.lce_header_id%TYPE;
v_component_id		cz_lce_headers.component_id%TYPE;
v_model_ref_expl_id	cz_lce_headers.model_ref_expl_id%TYPE;
v_net_type			cz_lce_headers.net_type%TYPE;
v_devl_project_id		cz_lce_headers.devl_project_id%TYPE;
v_model_id			cz_lce_headers.devl_project_id%TYPE;
v_exception_err		NUMBER := 0;

BEGIN
	IF (p_lce_header_id IS NOT NULL) THEN
		BEGIN
			SELECT lce_header_id
				,component_id
				,model_ref_expl_id
				,net_type
				,devl_project_id
			INTO   v_lce_header_id
				,v_component_id
				,v_model_ref_expl_id
				,v_net_type
				,v_devl_project_id
			FROM   cz_lce_headers
			WHERE  cz_lce_headers.lce_header_id = p_lce_header_id
			AND    cz_lce_headers.deleted_flag = '0';
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_populate_error_msg  := 'The lce_deader_id '||p_lce_header_id||' does not have data in cz_lce_headers';
			RAISE;
		WHEN OTHERS THEN
			RAISE;
		END;

		IF (v_net_type = 1) THEN
			----get the devl_project_id from cz_ps_nodes where ps_node_id is the v_component_id
			BEGIN
				SELECT devl_project_id
				INTO   v_model_id
				FROM   cz_ps_nodes
				WHERE  cz_ps_nodes.deleted_flag = '0'
				AND    cz_ps_nodes.ps_node_id = v_component_id;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_populate_error_msg  := 'The component_id  '||v_component_id||' of lce_header_id '||p_lce_header_id||' does not have associated record in cz_ps_nodes';
				RAISE;
			WHEN OTHERS THEN
				RAISE;
			END;

			-----get explosion id for above selected v_model_id
			BEGIN
				SELECT model_ref_expl_id
				INTO   v_model_ref_expl_id
				FROM   cz_model_ref_expls
				WHERE  cz_model_ref_expls.model_id = v_model_id
				AND    cz_model_ref_expls.component_id = v_component_id
				AND    cz_model_ref_expls.deleted_flag = '0';
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_populate_error_msg  := 'The component_id  '||v_component_id||' of lce_header_id '||p_lce_header_id||' does not have associated record in cz_model_ref_expls for model_id '||v_model_id;
				RAISE;
			WHEN OTHERS THEN
				RAISE;
			END;

		ELSIF (v_net_type = 2) THEN
			------get the component_id from cz_model_ref_expls for v_model_ref_expl_id
			BEGIN
				SELECT component_id
				INTO   v_component_id
				FROM   cz_model_ref_expls
				WHERE  cz_model_ref_expls.model_ref_expl_id = v_model_ref_expl_id
				AND    cz_model_ref_expls.deleted_flag = '0';
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_populate_error_msg  := 'The component_id  '||v_component_id||' of lce_header_id '||p_lce_header_id||' does not have associated record in cz_ps_nodes';
				RAISE;
			WHEN OTHERS THEN
				RAISE;
			END;

			------get the component_id from cz_model_ref_expls for v_model_ref_expl_id
			BEGIN
				SELECT devl_project_id
				INTO   v_model_id
				FROM   cz_ps_nodes
				WHERE  cz_ps_nodes.deleted_flag = '0'
				AND    cz_ps_nodes.ps_node_id = v_component_id;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_populate_error_msg  := 'The component_id  '||v_component_id||' of lce_header_id '||p_lce_header_id||' does not have associated record in cz_ps_nodes';
				RAISE;
			WHEN OTHERS THEN
				RAISE;
			END;

		END IF;  /* end if of net_type */
	END IF; /* end if of p_lce_header_id is not null */

	BEGIN
		insert into cz_lce_load_specs ( ATTACHMENT_EXPL_ID
							  ,LCE_HEADER_ID
							  ,REQUIRED_EXPL_ID
							  ,ATTACHMENT_COMP_ID
							  ,MODEL_ID
							  ,NET_TYPE )
				values ( v_model_ref_expl_id
					  ,v_lce_header_id
					  ,v_model_ref_expl_id
					  ,v_component_id
					  ,v_model_id
					  ,v_net_type );

		UPDATE cz_lce_headers
		SET    model_ref_expl_id  = v_model_ref_expl_id,
			 devl_project_id    = v_model_id,
			 NBR_REQUIRED_EXPLS = 0
		WHERE  lce_header_id = v_lce_header_id;
	EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
	END;
	x_populate_error_flag := '0';
	x_populate_error_msg  := SQLERRM;

COMMIT;
EXCEPTION
WHEN OTHERS THEN
	cz_upgrade.v_lce_hdr := p_lce_header_id ;
	x_populate_error_flag := '1';
	report_upgrade_logic_errors(cz_upgrade.v_schema_version,'18',cz_upgrade.v_lce_hdr,x_populate_error_msg,'LOGIC_UPGRADE' );
END cz_populate_lce_load_specs;
-------------------------------------------
----------procedure that upgrades the existing logic files to 18 schema

PROCEDURE upgrade_logic_files_to_18
IS

v_source_lce_headers_tbl	cz_upgrade.t_ref;
v_published_lce_headers_tbl	cz_upgrade.t_ref;
x_populate_flag			VARCHAR2(1);
x_populate_error			VARCHAR2(2000);
v_major_version			cz_db_settings.value%TYPE;


BEGIN
	-----get the existing major version of the schema
	v_major_version := LTRIM(RTRIM(get_major_version));

	IF (v_major_version = '14') THEN
		-----logic is generated for all source models.  No published models exist in a 14 build
		upgrade_logic_from_14;

	ELSIF (v_major_version IN ('15','16','17')) THEN

		-----get valid lce headers for all source models
		get_lce_headers('S', v_source_lce_headers_tbl,x_populate_error);

		-----get valid lce headers for all published models
		get_lce_headers('P', v_published_lce_headers_tbl,x_populate_error);

		-------upgrade logic files of source models
		IF (v_source_lce_headers_tbl.COUNT > 0) THEN
			FOR sourceLceHeader IN v_source_lce_headers_tbl.FIRST..v_source_lce_headers_tbl.LAST
			LOOP
				IF (has_to_populate_load_specs(v_source_lce_headers_tbl(sourceLceHeader))) THEN
					cz_populate_lce_load_specs(v_source_lce_headers_tbl(sourceLceHeader), x_populate_flag, x_populate_error);
				END IF;
			END LOOP;
		END IF;

		-------upgrade logic files of published models
		IF (v_published_lce_headers_tbl.COUNT > 0) THEN
			FOR publishedLceHeader IN v_published_lce_headers_tbl.FIRST..v_published_lce_headers_tbl.LAST
			LOOP
				IF (has_to_populate_load_specs(v_published_lce_headers_tbl(publishedLceHeader))) THEN
					cz_populate_lce_load_specs(v_published_lce_headers_tbl(publishedLceHeader), x_populate_flag,x_populate_error);
				END IF;
			END LOOP;
		END IF;
	ELSE
		x_populate_error := 'Logic upgrade is not required when upgrading from an 18 to 18 schema or a higher version' ;
		report_upgrade_logic_errors(v_major_version,'18',cz_upgrade.v_lce_hdr,x_populate_error,'LOGIC_UPGRADE');
	END IF;
EXCEPTION
WHEN OTHERS THEN
	  report_upgrade_logic_errors(v_major_version,'18',cz_upgrade.v_lce_hdr,x_populate_error,'LOGIC_UPGRADE');
END upgrade_logic_files_to_18;
--------------------------------------------
--------------procedure that verifies upgraded logic
PROCEDURE verify_logic (x_logic_status IN OUT NOCOPY VARCHAR2)
IS

v_source_lce_headers_tbl	cz_upgrade.t_ref;
v_published_lce_headers_tbl	cz_upgrade.t_ref;
v_all_lce_headers			cz_upgrade.t_ref;
v_attachment_expl_id_tbl	cz_upgrade.t_ref;
v_net_type_tbl			cz_upgrade.t_ref;
v_required_expl_tbl		cz_upgrade.t_ref;
x_error_msg				VARCHAR2(2000);
allHeadersCount			NUMBER := 0;
SOURCELCEHEADER			NUMBER := 0;
publishedLceHeader		NUMBER := 0;
allLceHeader			NUMBER := 0;
x_error_status			NUMBER := 0;
v_required_expl_chk_count	NUMBER := 0;
V_ATTACHMENT_EXPL_ID		NUMBER := 0;


BEGIN

	-----get valid lce headers for all source models
	get_lce_headers('S', v_source_lce_headers_tbl,x_error_msg);

	-----get valid lce headers for all published models
	get_lce_headers('P', v_published_lce_headers_tbl,x_error_msg);

	----accumulate source and published lce headers into one array
	v_all_lce_headers.DELETE;
	IF (v_source_lce_headers_tbl.COUNT > 0) THEN
		FOR sourceLceHeader IN v_source_lce_headers_tbl.FIRST..v_source_lce_headers_tbl.LAST
		LOOP
			allHeadersCount := v_all_lce_headers.COUNT + 1;
			v_all_lce_headers(allHeadersCount) := v_source_lce_headers_tbl(sourceLceHeader);
		END LOOP;
	END IF;

	IF (v_published_lce_headers_tbl.COUNT > 0) THEN
		FOR publishedLceHeader IN v_published_lce_headers_tbl.FIRST..v_published_lce_headers_tbl.LAST
		LOOP
			allHeadersCount := v_all_lce_headers.COUNT + 1;
			v_all_lce_headers(allHeadersCount) := v_published_lce_headers_tbl(publishedLceHeader);
		END LOOP;
	END IF;

	----validate all lce_headers
	IF (v_all_lce_headers.COUNT > 0) THEN
		-------validate attachment expl id
		FOR allLceHeader IN v_all_lce_headers.FIRST..v_all_lce_headers.LAST
		LOOP
			v_attachment_expl_id_tbl.DELETE;
			BEGIN
				SELECT distinct attachment_expl_id
				BULK
				COLLECT
				INTO   v_attachment_expl_id_tbl
				FROM   cz_lce_load_specs
				WHERE  cz_lce_load_specs.lce_header_id = v_all_lce_headers(allLceHeader)
				AND    cz_lce_load_specs.deleted_flag = '0';
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_error_msg := 'No attachment expl id found in cz_lce_load_specs for lce_header_id '||v_all_lce_headers(allLceHeader);
				report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
			WHEN OTHERS THEN
				x_error_status := -1;
				x_error_msg := 'Error in retrieving attachment expl id from cz_load_specs for lce_header_id '||v_all_lce_headers(allLceHeader)||' '||SQLERRM;
				report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
			END;

			v_net_type_tbl.DELETE;
			BEGIN
				SELECT distinct net_type
				BULK
				COLLECT
				INTO   v_net_type_tbl
				FROM   cz_lce_load_specs
				WHERE  cz_lce_load_specs.lce_header_id = v_all_lce_headers(allLceHeader)
				AND    cz_lce_load_specs.deleted_flag = '0';
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_error_msg := 'No net_type found in cz_lce_load_specs for lce_header_id '||v_all_lce_headers(allLceHeader);
				report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
			WHEN OTHERS THEN
				x_error_status := -1;
				x_error_msg := 'Error in retrieving net type from cz_load_specs for lce_header_id '||v_all_lce_headers(allLceHeader)||' '||SQLERRM;
				report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
			END;


			-----all records with the same lce header id must have the same attachment expl id and net type
			IF (v_attachment_expl_id_tbl.COUNT > 1) THEN
				x_error_status := -1;
				x_error_msg := 'For the same lce header id '||v_all_lce_headers(allLceHeader)||' attachment expl id is not the same';
				report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
			END IF;

			-----all records with the same lce header id must have the same attachment expl id and net type
			IF (v_net_type_tbl.COUNT > 1) THEN
				x_error_status := -1;
				x_error_msg := 'For the same lce header id '||v_all_lce_headers(allLceHeader)||' net type is not the same';
				report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
			END IF;

			-----required expl id is the same expl node or a descendant expl node of attachment expl id
			v_required_expl_tbl.DELETE;
			BEGIN
				SELECT distinct required_expl_id
				BULK
				COLLECT
				INTO   v_required_expl_tbl
				FROM   cz_lce_load_specs
				WHERE  cz_lce_load_specs.lce_header_id = v_all_lce_headers(allLceHeader)
				AND    cz_lce_load_specs.deleted_flag = '0';
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_error_msg := 'No required_expl_id found in cz_lce_load_specs for lce_header_id '||v_all_lce_headers(allLceHeader);
				report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
			WHEN OTHERS THEN
				x_error_status := -1;
				x_error_msg := 'Error in retrieving required_expl_id from cz_load_specs for lce_header_id '||v_all_lce_headers(allLceHeader)||' '||SQLERRM;
				report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
			END;

			IF (v_required_expl_tbl.COUNT > 0) THEN
				FOR reqdExplId IN v_required_expl_tbl.FIRST..v_required_expl_tbl.LAST
				LOOP
					BEGIN
						SELECT attachment_expl_id
						INTO   v_attachment_expl_id
						FROM   cz_lce_load_specs
						WHERE  cz_lce_load_specs.required_expl_id = v_required_expl_tbl(reqdExplId)
						AND    cz_lce_load_specs.lce_header_id = v_all_lce_headers(allLceHeader)
						AND    cz_lce_load_specs.deleted_flag = '0';
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						x_error_msg := 'No attachment expl id found in cz_lce_load_specs for lce_header_id '||v_all_lce_headers(allLceHeader)||' and required_expl_id '||v_required_expl_tbl(reqdExplId);
						report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
					WHEN OTHERS THEN
						x_error_status := -1;
						x_error_msg := 'Error in retrieving attachment expl id from cz_load_specs for lce_header_id '||v_all_lce_headers(allLceHeader)||' '||SQLERRM;
						report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
					END;

					IF (v_attachment_expl_id IS NOT NULL)  THEN
						v_required_expl_chk_count := 0;
						SELECT count(*)
						INTO   v_required_expl_chk_count
						FROM   cz_model_ref_expls
						WHERE  cz_model_ref_expls.model_id = (SELECT model_id
												  FROM   cz_model_ref_expls t
												  WHERE  t.model_ref_expl_id = v_attachment_expl_id
												  AND    t.deleted_flag = '0')
						AND    cz_model_ref_expls.model_ref_expl_id = v_required_expl_tbl(reqdExplId)
						AND    cz_model_ref_expls.deleted_flag = '0';

						IF (v_required_expl_chk_count = 0) THEN
							x_error_status := -1;
							x_error_msg := 'The required expl id '||v_required_expl_tbl(reqdExplId)||' is not in the explosion tree of root expl id '||v_attachment_expl_id;
							report_upgrade_logic_errors(NULL,NULL,v_all_lce_headers(allLceHeader),x_error_msg,'VERIFY_LOGIC');
						END IF;
					END IF;
				END LOOP;
			 END IF;
		END LOOP;
	END IF;

	IF (x_error_status = -1) THEN
		x_logic_status := 'Verification logic has errors for some lce headers. Check cz_db_logs using the query select message from cZ_db_logs where caller = VERIFY_LOGIC';
	ELSE
		x_logic_status := 'Verification logic reported no errors';
	END IF;
END verify_logic ;
---------------------------------------------------------------------------------------
PROCEDURE VERIFY_RULES(inDevlProjectId IN NUMBER,
                       thisRunId       IN OUT NOCOPY NUMBER)
IS

  TYPE tShortStringArray IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
  GenHeader VARCHAR2(100) := '$Header: czupgrdb.pls 120.2 2008/06/05 20:42:40 misheehy ship $';

  TYPE tIntegerArray   IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
  TYPE tIntegerArray_idx_vc2 IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(15);  --jonatara:int2long:bug6054920
  TYPE tStringArray    IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE tNumberArray    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tDateArray      IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  TYPE tPsNodeId       IS TABLE OF cz_ps_nodes.ps_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tItemId         IS TABLE OF cz_ps_nodes.item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPersistentId   IS TABLE OF cz_ps_nodes.persistent_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPersistentId_idx_vc2 IS TABLE OF cz_ps_nodes.persistent_node_id%TYPE INDEX BY VARCHAR2(15);  --jonatara:int2long:bug6054920
  TYPE tPsNodeType     IS TABLE OF cz_ps_nodes.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tInitialValue   IS TABLE OF cz_ps_nodes.initial_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tInitNumVal     IS TABLE OF cz_ps_nodes.initial_num_value%TYPE INDEX BY BINARY_INTEGER;  -- sselahi
  TYPE tParentId       IS TABLE OF cz_ps_nodes.parent_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMinimum        IS TABLE OF cz_ps_nodes.minimum%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMaximum        IS TABLE OF cz_ps_nodes.maximum%TYPE INDEX BY BINARY_INTEGER;
  TYPE tVirtualFlag    IS TABLE OF cz_ps_nodes.virtual_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tFeatureType    IS TABLE OF cz_ps_nodes.feature_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tName           IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDescriptionId  IS TABLE OF cz_ps_nodes.intl_text_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMinimumSel     IS TABLE OF cz_ps_nodes.minimum_selected%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMaximumSel     IS TABLE OF cz_ps_nodes.maximum_selected%TYPE INDEX BY BINARY_INTEGER;
  TYPE tBomRequired    IS TABLE OF cz_ps_nodes.bom_required_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tReferenceId    IS TABLE OF cz_ps_nodes.reference_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tReferenceId_idx_vc2 IS TABLE OF cz_ps_nodes.reference_id%TYPE INDEX BY VARCHAR2(15);  --jonatara:int2long:bug6054920
  TYPE tUsageMask      IS TABLE OF cz_ps_nodes.effective_usage_mask%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDecimalQty     IS TABLE OF cz_ps_nodes.decimal_qty_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDecimalQty_idx_vc2 IS TABLE OF cz_ps_nodes.decimal_qty_flag%TYPE INDEX BY VARCHAR2(15);  --jonatara:int2long:bug6054920

  TYPE tSetEffFrom     IS TABLE OF cz_effectivity_sets.effective_from%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSetEffUntil    IS TABLE OF cz_effectivity_sets.effective_until%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSetEffId       IS TABLE OF cz_effectivity_sets.effectivity_set_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSetName        IS TABLE OF cz_effectivity_sets.name%TYPE INDEX BY BINARY_INTEGER;

  TYPE tHeaderId       IS TABLE OF cz_lce_headers.lce_header_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExplNodeId     IS TABLE OF cz_model_ref_expls.model_ref_expl_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExplNodeId_idx_vc2 IS TABLE OF cz_model_ref_expls.model_ref_expl_id%TYPE INDEX BY VARCHAR2(15);

  IsLogicGenerated     tIntegerArray_idx_vc2; --jonatara:int2long:bug6054920

  glPsNodeId           tPsNodeId;
  glItemId             tItemId;
  glPersistentId       tPersistentId_idx_vc2; --jonatara:int2long:bug6054920
  glReferenceId        tReferenceId_idx_vc2; --jonatara:int2long:bug6054920
  glPsNodeType         tPsNodeType;
  glIndexByPsNodeId    tIntegerArray_idx_vc2; --jonatara:int2long:bug6054920
  glLastChildIndex     tIntegerArray;
  glParentId           tParentId;
  glFeatureType        tFeatureType;
  glName               tName;
  glBomRequired        tBomRequired;
  glHeaderByPsNodeId   tNumberArray;
  glEffFrom            tDateArray;
  glEffUntil           tDateArray;
  glUsageMask          tUsageMask;
  glMinimum            tMinimum;
  glMaximum            tMaximum;
  glMinimumSel         tMinimumSel;
  glMaximumSel         tMaximumSel;
  glVirtualFlag        tVirtualFlag;
  glDecimalQty         tDecimalQty_idx_vc2; --jonatara:int2long:bug6054920
  featOptionsCount     tIntegerArray;

  v_NodeIdByComponent  tExplNodeId_idx_vc2; --jonatara:int2long:bug6054920

  globalCount          PLS_INTEGER := 1;
 --Just to support debugging
  nDebug               PLS_INTEGER := 7777777;
 --Auxiliery parameters for reporting
  nParam               PLS_INTEGER;
  errorMessage         VARCHAR2(2000);

--Referencing level indicator and model stack
  globalLevel          PLS_INTEGER := 0;
  globalStack          tIntegerArray;
---------------------------------------------------------------------------------------
--Reporting procedure

PROCEDURE REPORT(inMessage IN VARCHAR2, inUrgency IN PLS_INTEGER) IS
BEGIN

  INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id)
  VALUES (SUBSTR(inMessage, 1, 2000), nDebug, 'Rules Verification', inUrgency, thisRunId);
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE CZ_G_UNABLE_TO_REPORT_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_COMPONENT_TREE(inComponentId         IN NUMBER,
                                  inProjectId           IN NUMBER)
IS

 TYPE tNodeDepth      IS TABLE OF cz_model_ref_expls.node_depth%TYPE INDEX BY BINARY_INTEGER;
 TYPE tNodeType       IS TABLE OF cz_model_ref_expls.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tVirtualFlag    IS TABLE OF cz_model_ref_expls.virtual_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tParentId       IS TABLE OF cz_model_ref_expls.parent_expl_node_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tPsNodeId       IS TABLE OF cz_model_ref_expls.component_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tChildModelExpl IS TABLE OF cz_model_ref_expls.child_model_expl_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExplNodeType   IS TABLE OF cz_model_ref_expls.expl_node_type%TYPE INDEX BY BINARY_INTEGER;

 ntPsNodeId           tPsNodeId;
 ntItemId             tItemId;
 ntPersistentId       tPersistentId;
 ntPsNodeType         tPsNodeType;
 ntInitialValue       tInitialValue;
 ntInitNumVal         tInitNumVal; -- sselahi
 ntParentId           tParentId;
 ntMinimum            tMinimum;
 ntMaximum            tMaximum;
 ntVirtualFlag        tVirtualFlag;
 ntFeatureType        tFeatureType;
 ntName               tName;
 ntDescriptionId      tDescriptionId;
 ntMinimumSel         tMinimumSel;
 ntMaximumSel         tMaximumSel;
 ntBomRequired        tBomRequired;
 ntReferenceId        tReferenceId;
 dtEffFrom            tDateArray;
 dtEffUntil           tDateArray;
 vtUsageMask          tUsageMask;
 ntEffSetId           tSetEffId;
 ntDecimalQty         tDecimalQty;

 v_tNodeDepth         tNodeDepth;
 v_tNodeType          tNodeType;
 v_tVirtualFlag       tVirtualFlag;
 v_tParentId          tParentId;
 v_tPsNodeId          tPsNodeId;
 v_tReferringId       tPsNodeId;
 v_tChildModelExpl    tChildModelExpl;
 v_tExplNodeType      tExplNodeType;
 v_NodeId             tExplNodeId;

 v_IndexByNodeId      tIntegerArray;
 v_TypeByExplId       tExplNodeType;

 thisComponentExplId  cz_model_ref_expls.model_ref_expl_id%TYPE;
 thisProjectId        cz_devl_projects.devl_project_id%TYPE;
 thisRootExplIndex    PLS_INTEGER;

 i                    PLS_INTEGER;
 j                    PLS_INTEGER;
 localCount           PLS_INTEGER;
 optionCounter        PLS_INTEGER;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_RULES IS

 TYPE tExprType       IS TABLE OF cz_expression_nodes.expr_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExprSubtype    IS TABLE OF cz_expression_nodes.expr_subtype%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExprId         IS TABLE OF cz_expression_nodes.expr_node_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExprParentId   IS TABLE OF cz_expression_nodes.expr_parent_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExpressId      IS TABLE OF cz_expression_nodes.express_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExprDataValue  IS TABLE OF cz_expression_nodes.data_value%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExprDataNumValue  IS TABLE OF cz_expression_nodes.data_num_value%TYPE INDEX BY BINARY_INTEGER; -- sselahi
 TYPE tExprPropertyId IS TABLE OF cz_expression_nodes.property_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tPresentType    IS TABLE OF cz_expressions.present_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tGridColId      IS TABLE OF cz_combo_features.grid_col_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tOptionId       IS TABLE OF cz_grid_cells.ps_node_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tConsequentFlag IS TABLE OF cz_expression_nodes.consequent_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tDesFeatureType IS TABLE OF cz_des_chart_features.feature_type%TYPE INDEX BY BINARY_INTEGER;

 --The cursor returns all the rules assigned in this project (model)

 CURSOR c_rules IS
  SELECT rule_id, rule_type, antecedent_id, consequent_id, name, reason_id,
         expr_rule_type, rule_folder_id
  FROM cz_rules
  WHERE devl_project_id = inComponentId
    AND deleted_flag = FLAG_NOT_DELETED
    AND disabled_flag = FLAG_NOT_DISABLED;

 v_tExpressionId      tExpressId;
 v_tPresentType       tPresentType;

 v_tExplNodeId        tExplNodeId;
 v_tExprType          tExprType;
 v_tExprSubtype       tExprSubtype;
 v_tExprId            tExprId;
 v_tExprParentId      tExprParentId;
 v_tExpressId         tExpressId;
 v_tExprPsNodeId      tExplNodeId;
 v_tExprDataValue     tExprDataValue;
 v_tExprDataNumValue  tExprDataNumValue; -- sselahi
 v_tExprPropertyId    tExprPropertyId;
 v_tGridColId         tGridColId;
 v_tConsequentFlag    tConsequentFlag;
 v_tFeatureType       tDesFeatureType;
 v_LoadConditionId    tExplNodeId;

 v_isExprAdvanced     tIntegerArray;
 v_InstByLevel        tIntegerArray;
 v_IndexByExprNodeId  tIntegerArray;
 v_Assignable         tIntegerArray;
 v_Participant        tIntegerArray;
 v_DistinctIndex      tIntegerArray;
 v_ParticipantIndex   tIntegerArray;
 v_BeneathNodes       tIntegerArray;
 v_BeneathCount       tIntegerArray;
 v_MarkLoadCondition  tIntegerArray;
 v_tIsHeaderGenerated tIntegerArray;
 v_tSequenceNbr       tIntegerArray;
 v_tLogicNetType      tIntegerArray;

 v_NodeLogicLevel     tIntegerArray;
 v_NodeAssignable     tIntegerArray;
 v_IsConnectorNet     tIntegerArray;
 v_ChildrenIndex      tIntegerArray;
 v_NumberOfChildren   tIntegerArray;
 v_MaxRuleExists      tIntegerArray;
 v_ProhibitInRules    tIntegerArray;
 v_ProhibitConnector  tIntegerArray;
 v_NodeIndexPath      tIntegerArray;
 v_NodeDownPath       tStringArray;
 v_AssignedDownPath   tStringArray;
 v_NodeUpPath         tStringArray;
 v_RuleQualifiedName  tStringArray;

 v_LoadHeaders        tHeaderId;
 v_LoadConditions     tStringArray;

 nAntecedentId        cz_rules.antecedent_id%TYPE;
 nConsequentId        cz_rules.consequent_id%TYPE;
 nRuleId              cz_rules.rule_id%TYPE;
 nRuleFolderId        cz_rules.rule_folder_id%TYPE;
 nRuleType            cz_rules.rule_type%TYPE;
 nRuleOperator        cz_rules.expr_rule_type%TYPE;
 nReasonId            cz_rules.reason_id%TYPE;
 vRuleName            cz_rules.name%TYPE;
 vUsageMask           cz_rules.effective_usage_mask%TYPE;
 MaxDepthId           cz_model_ref_expls.model_ref_expl_id%TYPE;
 nAux                 cz_model_ref_expls.model_ref_expl_id%TYPE;
 MaxDepthValue        cz_model_ref_expls.node_depth%TYPE;
 nHeaderId            cz_lce_headers.lce_header_id%TYPE;
 nPreviousHeaderId    cz_lce_headers.lce_header_id%TYPE;
 nNewLogicFileFlag    PLS_INTEGER := 0;
 nRuleAssignedLevel   PLS_INTEGER;
 MaxDepthIndex        PLS_INTEGER;
 logicNetType         PLS_INTEGER;

 ConnectorIndex       PLS_INTEGER;
 InstantiableIndex    PLS_INTEGER;
 AssignableIndex      PLS_INTEGER;

 jAntecedentRoot      PLS_INTEGER;
 jConsequentRoot      PLS_INTEGER;
 jAntecedentRootCount PLS_INTEGER;
 jConsequentRootCount PLS_INTEGER;
 ListType             PLS_INTEGER;
 nLocalDefaults       PLS_INTEGER := 1000;

 nCounter             PLS_INTEGER;
 distinctCount        PLS_INTEGER;
 participantCount     PLS_INTEGER;
 localFeatureType     PLS_INTEGER;
 localMinimum         PLS_INTEGER;
 auxIndex             PLS_INTEGER;
 auxCount             PLS_INTEGER;
 localString          VARCHAR2(2000);
---------------------------------------------------------------------------------------
--This function returns fully qualified rule name given rule_folder_id of a rule
--and puts generated names into a hash table for reuse.
FUNCTION RULE_NAME RETURN VARCHAR2 IS
  vQualified  VARCHAR2(2000) := '.';
  nRuleName   PLS_INTEGER;
BEGIN
  IF(nRuleFolderId IS NULL OR nRuleFolderId = -1)THEN RETURN vRuleName; END IF;
  IF(v_RuleQualifiedName.EXISTS(nRuleFolderId))THEN RETURN v_RuleQualifiedName(nRuleFolderId) || vRuleName; END IF;
  nRuleName := LENGTH(vRuleName);
  FOR folder IN (SELECT name FROM cz_rule_folders
                  WHERE deleted_flag = FLAG_NOT_DELETED
                    AND parent_rule_folder_id IS NOT NULL
                 START WITH rule_folder_id = nRuleFolderId
                 CONNECT BY PRIOR parent_rule_folder_id = rule_folder_id)LOOP
     IF(LENGTH(folder.name) + LENGTH(vQualified) + 1 < 2000 - nRuleName)THEN
      vQualified := '.' || folder.name || vQualified;
     ELSE
      EXIT;
     END IF;
  END LOOP;
  v_RuleQualifiedName(nRuleFolderId) := vQualified;
  RETURN vQualified || vRuleName;
END;
---------------------------------------------------------------------------------------
BEGIN --GENERATE_RULES

nDebug := 1000007;

  FOR i IN v_NodeId.FIRST..v_NodeId.LAST LOOP

nDebug := 1000008;

    --Here we will construct model level downpaths, which do not depend on a particular rule,
    --but only on explosion id within the model's explosion tree. When a particular rule is
    --assigned, downpaths of its participants may be prepended with segments including all A
    --type nodes from assignee to assignable. This corrected downpaths are always used when
    --generating names of the rule's participants.

    nAux := v_NodeId(i);
    auxIndex := v_tNodeDepth(i) + 1;

    IF(NOT v_NodeDownPath.EXISTS(nAux))THEN

nDebug := 1000009;

      v_NodeDownPath(nAux) := ''; --start building the downpath
      v_NodeIndexPath.DELETE; --reset the table

      --These all are index values in v_NodeIndexPath.

      ConnectorIndex := 0;
      InstantiableIndex := auxIndex;
      nCounter := 1;
      auxCount := 0;

      --Go all the way up from the explosion id and find the deepest D node and the
      --shallowest connector.

      WHILE(nAux IS NOT NULL) LOOP

        auxCount := auxCount + 1;
        IF(auxCount > 1000)THEN RAISE CZ_S_MODEL_IGNORED; END IF;

        IF(v_TypeByExplId(nAux) = EXPL_NODE_TYPE_CONNECTOR)THEN

          ConnectorIndex := nCounter;
        ELSIF(v_TypeByExplId(nAux) = EXPL_NODE_TYPE_INSTANTIABLE AND InstantiableIndex = auxIndex)THEN

          InstantiableIndex := nCounter;
        END IF;

       v_NodeIndexPath(nCounter) := v_IndexByNodeId(nAux);
       nCounter := nCounter + 1;

       nAux := v_tParentId(v_IndexByNodeId(nAux));
      END LOOP;

      IF(InstantiableIndex < ConnectorIndex)THEN

        --There are D nodes under connectors on the path - this explosion cannot participate
        --in any rule because it would be impossible to assign such a rule. No downpath.
        --For reporting purposes store the cz_ps_nodes indexes of the instantiable component
        --and the connector, corresponding exception/message is CZ_R_UNASSIGNABLE_RULE.

        v_ProhibitInRules(v_NodeId(i)) := glIndexByPsNodeId(v_tPsNodeId(v_NodeIndexPath(InstantiableIndex)));
        v_ProhibitConnector(v_NodeId(i)) := glIndexByPsNodeId(v_tReferringId(v_NodeIndexPath(ConnectorIndex)));
      ELSE

nDebug := 1000010;

        AssignableIndex := InstantiableIndex;

        --Find the deepest A node between the deepest D node and the shallowest connector.
        --This node is the assignable for the explosion id (can be the D node itself).

        FOR n IN ConnectorIndex + 1..InstantiableIndex LOOP
          IF(v_tExplNodeType(v_NodeIndexPath(n)) = EXPL_NODE_TYPE_OPTIONAL)THEN

            AssignableIndex := n;
            EXIT;
          END IF;
        END LOOP;

        v_NodeLogicLevel(v_NodeId(i)) := v_tNodeDepth(v_NodeIndexPath(AssignableIndex));

        --Store the explosion node's assignable in the form of the main index.

        v_NodeAssignable(v_NodeId(i)) := v_NodeIndexPath(AssignableIndex);

nDebug := 1000011;

        --Finally, construct the downpath from the assignable to the explosion id.

        FOR n IN 1..AssignableIndex - 1 LOOP
          IF(v_tExplNodeType(v_NodeIndexPath(n)) IN (EXPL_NODE_TYPE_OPTIONAL, EXPL_NODE_TYPE_MANDATORY))THEN

           --This is a mandatory reference or optional component, add N_<persistent_node_id>
           --to the path.

           v_NodeDownPath(v_NodeId(i)) := PATH_DELIMITER || 'N_' ||
             TO_CHAR(glPersistentId(NVL(v_tReferringId(v_NodeIndexPath(n)), v_tPsNodeId(v_NodeIndexPath(n))))) ||
             v_NodeDownPath(v_NodeId(i));
          ELSIF(v_tExplNodeType(v_NodeIndexPath(n)) = EXPL_NODE_TYPE_CONNECTOR)THEN

           --This is a connector, add C_<model_ref_expl_id> to the path.

           v_NodeDownPath(v_NodeId(i)) := PATH_DELIMITER || 'C_' ||
             TO_CHAR(v_NodeId(v_NodeIndexPath(n))) || v_NodeDownPath(v_NodeId(i));

           --We will stop here, we do not want anything above the deepest connector to be reflected
           --in the path. Set a flag for this explosion because we do not want to prepend downpaths
           --for these explosions after the rule is assigned either.

           v_IsConnectorNet(v_NodeId(i)) := v_NodeIndexPath(n);
           EXIT;

          END IF;
        END LOOP;
      END IF;
    END IF;
  END LOOP;

nDebug := 2;

  OPEN c_rules;
  LOOP
  BEGIN

    FETCH c_rules INTO
     nRuleId, nRuleType, nAntecedentId, nConsequentId, vRuleName,
     nReasonId, nRuleOperator, nRuleFolderId;
    EXIT WHEN c_rules%NOTFOUND;

   --Do nothing for those rules.

   IF(nRuleType NOT IN (RULE_TYPE_FUNC_COMP, RULE_TYPE_RULE_FOLDER))THEN

    v_tExplNodeId.DELETE;
    v_tExprType.DELETE;
    v_tExprSubtype.DELETE;
    v_InstByLevel.DELETE;
    v_Assignable.DELETE;
    v_Participant.DELETE;
    v_DistinctIndex.DELETE;
    v_ParticipantIndex.DELETE;
    v_BeneathNodes.DELETE;
    v_BeneathCount.DELETE;
    v_MarkLoadCondition.DELETE;
    v_LoadConditionId.DELETE;
    v_tExprId.DELETE;
    v_tExprParentId.DELETE;
    v_tExpressId.DELETE;
    v_tExprPsNodeId.DELETE;
    v_tExprDataValue.DELETE;
    v_tExprDataNumValue.DELETE; -- sselahi
    v_tExprPropertyId.DELETE;
    v_tGridColId.DELETE;
    v_ChildrenIndex.DELETE;
    v_NodeUpPath.DELETE;
    v_IndexByExprNodeId.DELETE;
    v_NumberOfChildren.DELETE;

    jAntecedentRoot := NULL;
    jConsequentRoot := NULL;

nDebug := 3;

    --Get the rule participants, differently for different types of rules

    IF(nRuleType IN (RULE_TYPE_LOGIC_RULE, RULE_TYPE_NUMERIC_RULE, RULE_TYPE_COMPARISON_RULE))THEN

     --Read all the expression nodes for the current rule into memory,
     --will be generating from there

     SELECT model_ref_expl_id, expr_type, expr_node_id, expr_parent_id, -- sselahi
            express_id, expr_subtype, ps_node_id, data_value, data_num_value, property_id, consequent_flag
     BULK COLLECT INTO v_tExplNodeId, v_tExprType, v_tExprId, v_tExprParentId,
                       v_tExpressId, v_tExprSubtype, v_tExprPsNodeId,
                       v_tExprDataValue, v_tExprDataNumValue, v_tExprPropertyId, v_tConsequentFlag
     FROM cz_expression_nodes
     WHERE express_id IN (nAntecedentId, nConsequentId)
       AND expr_type <> EXPR_NODE_TYPE_PUNCT
       AND deleted_flag = FLAG_NOT_DELETED
     ORDER BY expr_parent_id, seq_nbr;

nDebug := 31;

     --The COUNT attribute can never be NULL, it will be 0 if nothing has been read
     IF(v_tExprType.COUNT = 0)THEN
       RAISE CZ_R_RULE_IGNORED;
     END IF;

     FOR i IN v_tExprType.FIRST..v_tExprType.LAST LOOP

     --If this rule is against max of some component, mark this component as having such a rule.
     --Later we will generate INC for this component's actual max.

       IF(v_tExprType(i) = EXPR_NODE_TYPE_SYSPROP AND v_tExprSubtype(i) = SYS_PROP_MAX AND
           v_tConsequentFlag(i) = FLAG_IS_CONSEQUENT)THEN

          v_MaxRuleExists(v_tExplNodeId(i)) := 1;

       END IF;

     --Add the indexing option.

       v_IndexByExprNodeId(v_tExprId(i)) := i;
     END LOOP;

    ELSIF(nRuleType = RULE_TYPE_COMPAT_TABLE)THEN

     --Read all the features

     SELECT model_ref_expl_id, feature_id, grid_col_id, EXPR_NODE_TYPE_NODE
     BULK COLLECT INTO v_tExplNodeId, v_tExprPsNodeId, v_tGridColId, v_tExprType
     FROM cz_combo_features
     WHERE rule_id = nRuleId
       AND deleted_flag = FLAG_NOT_DELETED;

nDebug := 32;

     --The COUNT property can never be NULL, it will be 0 if nothing has been read
     IF(v_tExprType.COUNT < 2)THEN
       RAISE CZ_R_RULE_IGNORED;
     END IF;

    ELSIF(nRuleType = RULE_TYPE_COMPAT_RULE)THEN

     SELECT model_ref_expl_id, expr_type, expr_node_id, expr_parent_id, -- sselahi
            express_id, expr_subtype, ps_node_id, data_value, data_num_value, property_id
     BULK COLLECT INTO v_tExplNodeId, v_tExprType, v_tExprId, v_tExprParentId,
                       v_tExpressId, v_tExprSubtype, v_tExprPsNodeId,
                       v_tExprDataValue, v_tExprDataNumValue, v_tExprPropertyId
     FROM cz_expression_nodes
     WHERE express_id = nAntecedentId
     AND expr_type <> EXPR_NODE_TYPE_PUNCT
     AND deleted_flag = FLAG_NOT_DELETED
     ORDER BY expr_parent_id, seq_nbr;

nDebug := 33;

     --The COUNT attribute can never be NULL, it will be 0 if nothing has been read
     IF(v_tExprType.COUNT = 0)THEN
       RAISE CZ_R_RULE_IGNORED;
     END IF;

     FOR i IN v_tExprType.FIRST..v_tExprType.LAST LOOP

     --Add the indexing option.

       v_IndexByExprNodeId(v_tExprId(i)) := i;
     END LOOP;

    ELSIF(nRuleType = RULE_TYPE_DESIGNCHART_RULE)THEN

     --Read all the features

     SELECT model_ref_expl_id, feature_id, feature_type, EXPR_NODE_TYPE_NODE
     BULK COLLECT INTO v_tExplNodeId, v_tExprPsNodeId, v_tFeatureType, v_tExprType
     FROM cz_des_chart_features
     WHERE rule_id = nRuleId
       AND deleted_flag = FLAG_NOT_DELETED;

nDebug := 34;

     --The COUNT attribute can never be NULL, it will be 0 if nothing has been read
     IF(v_tExprType.COUNT < 2)THEN
       RAISE CZ_R_RULE_IGNORED;
     END IF;

    ELSE

     --Unknown rule type
     RAISE CZ_R_RULE_IGNORED;
    END IF;

    --General rule data validation section - all rule types----------------------------Start

    FOR i IN v_tExprType.FIRST..v_tExprType.LAST LOOP

      IF(v_tExprPsNodeId(i) IS NOT NULL)THEN

        IF(NOT glIndexByPsNodeId.EXISTS(v_tExprPsNodeId(i)))THEN

nDebug := 35;

     --Every participating node must actually exist in the product structure

          RAISE CZ_R_RULE_IGNORED;
        END IF;

        IF(v_tExplNodeId(i) IS NULL)THEN

nDebug := 36;

    --Every not null ps_node_id should have a not null assosiated model_ref_expl_id (data corruption)

          RAISE CZ_R_RULE_IGNORED;

        ELSIF(NOT v_IndexByNodeId.EXISTS(v_tExplNodeId(i)))THEN

nDebug := 37;

    --All the participants' model_ref_expl_id must be in the current model's explosion table (data corruption)

          RAISE CZ_R_RULE_IGNORED;

        END IF;
      END IF;

nDebug := 38;

      IF(v_tExprType(i) = EXPR_NODE_TYPE_NODE)THEN
       IF(v_tExprPsNodeId(i) IS NULL)THEN

nDebug := 381;

      --Every node type node must have assosiated ps_node_id

        RAISE CZ_R_RULE_IGNORED;
       END IF;
      ELSIF(v_tExprType(i) = EXPR_NODE_TYPE_LITERAL)THEN
       IF(v_tExprDataValue(i) IS NULL AND v_tExprDataNumValue(i) IS NULL)THEN

nDebug := 382;

      --Every literal must have not null value

        RAISE CZ_R_RULE_IGNORED;
       END IF;
      ELSIF(v_tExprType(i) = EXPR_NODE_TYPE_FEATPROP)THEN
       IF(v_tExprPsNodeId(i) IS NULL)THEN

nDebug := 383;

      --Every feature property node must have assosiated ps_node_id

        RAISE CZ_R_RULE_IGNORED;
       ELSIF(v_tExprPropertyId(i) IS NULL)THEN

nDebug := 384;

      --Every feature property node must have assosiated property_id

        RAISE CZ_R_RULE_IGNORED;
       END IF;
      END IF;
    END LOOP;
    --General rule data validation section-----------------------------------------------End

nDebug := 40;

    nCounter := 0;
    distinctCount := 0;
    participantCount := 0;
    MaxDepthValue := 0;
    MaxDepthIndex := thisRootExplIndex;

    FOR i IN v_tExprType.FIRST..v_tExprType.LAST LOOP
     IF(v_tExprPsNodeId(i) IS NOT NULL)THEN

      participantCount := participantCount + 1;

      --Soft fix the explosion nodes whenever necessary:

      --When a rule has a reference node as a participant,Developer would put the explosion id
      --of the reference node itself instead of the explosion id of its parent. This should be
      --fixed in some cases (see below).
      --If a participant is a component, then it's the component's MIN,MAX or COUNT and actual
      --participant should be it's parent. However,it can also be features of the component or
      --some other (new) operator. That's why we make sure that the parent of the component is
      --the operator DOT and, in addition, the component is non-virtual.

      --Later remark:
      --A reference, as well as a component, should be fixed only when they are in combination
      --with system property. So, it's not enough to check that the parent operator is DOT, we
      --also have to make sure that the another operand is EXPR_SYS_PROP with MIN,MAX or COUNT
      --subtype.

      auxIndex := glIndexByPsNodeId(v_tExprPsNodeId(i));

      IF(glPsNodeType(auxIndex) = PS_NODE_TYPE_REFERENCE OR
         (glPsNodeType(auxIndex) = PS_NODE_TYPE_COMPONENT AND glVirtualFlag(auxIndex) = FLAG_NON_VIRTUAL))THEN

         IF(v_tExprParentId(i) IS NOT NULL AND
            v_tExprType(v_IndexByExprNodeId(v_tExprParentId(i))) = EXPR_NODE_TYPE_OPERATOR AND
            v_tExprSubtype(v_IndexByExprNodeId(v_tExprParentId(i))) = OPERATOR_DOT  AND
            v_tExprType.EXISTS(i + 1) AND
            v_tExprType(i + 1) = EXPR_NODE_TYPE_SYSPROP AND
            v_tExprSubtype(i + 1) IN (SYS_PROP_MIN, SYS_PROP_MAX, SYS_PROP_COUNT)
         )THEN

           v_tExplNodeId(i) := v_tParentId(v_IndexByNodeId(v_tExplNodeId(i)));

         ELSIF(glPsNodeType(auxIndex) = PS_NODE_TYPE_REFERENCE)THEN

           --If we are here, than this is a reference to a BOM model, because it should be prohibited
           --for a reference to a component to participate with anything other than it's MIN or MAX.
           --We will fix the corresponding PS_NODE_ID value to be not the reference node's PS_NODE_ID
           --but the PS_NODE_ID of the referenced BOM model.This is necessary to generate the correct
           --object name.

           v_tExprPsNodeId(i) := glReferenceId(v_tExprPsNodeId(i));

         END IF;
      END IF;

nDebug := 41;

      --Select a participant and get its explosion id.

      nAux := v_tExplNodeId(i);

      IF(v_ProhibitInRules.EXISTS(nAux))THEN

        --This explosion node has D nodes under connectors on the way up in the explosion table.
        --It will be impossible to assign this rule, so just stop here.

        localString := glName(glIndexByPsNodeId(v_tExprPsNodeId(i)));
        auxIndex := v_ProhibitInRules(nAux);
        auxCount := v_ProhibitConnector(nAux);
        RAISE CZ_R_RULE_IGNORED;
      END IF;

nDebug := 43;

      IF(NOT v_Participant.EXISTS(nAux))THEN

        --Add to the list of indexes of distinct participants' explosions.

        v_Participant(nAux) := 1;
        distinctCount := distinctCount + 1;
        v_ParticipantIndex(distinctCount) := v_IndexByNodeId(nAux);

        --Make a rule-specific copy of this explosion downpath which may have to be prepended
        --after the rule is assigned. It is this copy that will be used for name generation.

        v_AssignedDownPath(nAux) := v_NodeDownPath(nAux);
      END IF;

      --The node is not prohibited from participating in rules, so assignable exists.

      auxIndex := v_NodeAssignable(nAux);

      --Select and store all the distinct assignables for all the current rule's participants.
      --Main indexes are stored in v_DistinctIndex. Also find the deepest D node among all of
      --participants here. MaxDepthValue is initialized to the root (0), so that if there are
      --no D nodes, the root node will act as one.

nDebug := 44;

      IF(NOT v_Assignable.EXISTS(auxIndex))THEN

        v_Assignable(auxIndex) := 1;
        nCounter := nCounter + 1;
        v_DistinctIndex(nCounter) := auxIndex;

        IF(v_tExplNodeType(auxIndex) = EXPL_NODE_TYPE_INSTANTIABLE AND
           v_tNodeDepth(auxIndex) > MaxDepthValue)THEN

           MaxDepthValue := v_tNodeDepth(auxIndex);
           MaxDepthIndex := auxIndex;
        END IF;
      END IF;
     END IF;
    END LOOP;

nDebug := 45;

    --Now populate the <index in memory>(NODE_DEPTH) table for assignables of any type which
    --are above the deepest D component. They should form a chain, without duplicates on the
    --same level. Here we verify that there are no two components on the same level. This is
    --necessary but not sufficient for the rule to be valid.

    FOR i IN 1..v_DistinctIndex.COUNT LOOP

      auxIndex := v_DistinctIndex(i);

      IF(v_tNodeDepth(auxIndex) <= MaxDepthValue)THEN
        IF(v_InstByLevel.EXISTS(v_tNodeDepth(auxIndex)))THEN

          --There is already a node on this level. Two or more non-virtual components on the
          --same level are prohibited.

          auxCount := glIndexByPsNodeId(v_tPsNodeId(auxIndex));
          auxIndex := glIndexByPsNodeId(v_tPsNodeId(v_InstByLevel(v_tNodeDepth(auxIndex))));
          RAISE CZ_R_RULE_IGNORED;
        ELSE

          --This level is now occupied by a node with memory index auxIndex.

          v_InstByLevel(v_tNodeDepth(auxIndex)) := auxIndex;
        END IF;
      END IF;
    END LOOP;

nDebug := 46;

    --Now we make sure that if we move up from the deepest D assignable, we will step over
    --all other assignable which are above this D, so they all form a chain.
    --We start with the deepest D component and move up to its parent and so on thus going
    --through every level in the hierarchy. On every level, if an assignable exists there,
    --we make sure that this node is what we expect - the parent we just moved up to.

    nCounter := 0;
    auxIndex := MaxDepthIndex;

    LOOP
      IF(v_InstByLevel.EXISTS(v_tNodeDepth(auxIndex)))THEN
         IF(v_InstByLevel(v_tNodeDepth(auxIndex)) <> auxIndex)THEN

           --Incorrect node on the level. The rule goes across non-virual boundaries.

           auxCount := glIndexByPsNodeId(v_tPsNodeId(v_InstByLevel(v_tNodeDepth(auxIndex))));
           auxIndex := glIndexByPsNodeId(v_tPsNodeId(MaxDepthIndex));
           RAISE CZ_R_RULE_IGNORED;
         END IF;
         nCounter := nCounter + 1;
      END IF;

      EXIT WHEN nCounter = v_InstByLevel.COUNT OR v_tParentId(auxIndex) IS NULL;
      auxIndex := v_IndexByNodeId(v_tParentId(auxIndex));
    END LOOP;

nDebug := 47;

    --We verified that on the way up from the deepest D node we pass ONLY through eligible
    --assignables. Now lets see if we passed through ALL of them.

    IF(nCounter <> v_InstByLevel.COUNT)THEN

      --Not all the assignables have been passed on the way up. The rule goes across
      --non-virual boundaries.

      RAISE CZ_R_RULE_IGNORED;
    END IF;

    --So, there exists the deepest type D assignable (it can be the root node) and we verified
    --that above it there is no non-virtual boundaries crossing. However, if there are A type
    --assignables beneath that D node, we want to assign the rule to the shallowest of them.
    --Or there may be not assignables but just regular A nodes between assignables and D.

    --First of all, let us see if there are connector's nets attached to the deepest component
    --among the rule participants, because if there are, then the rule will be assigned to the
    --deepst D already found and there's no need to work with A type components. Example:

    --  M
    --  |_D
    --    |_A0
    --    | |_A
    --    | | |_F2
    --    | |_A
    --    |   |_F3
    --    |
    --    |_Connector->M1-F4

    --For both rules relating either (F2, F3) or (F2, F3, F4), D is the deepest D node. However,
    --the first rule should be assigned to A0 while the second rule should be assigned to D.
    --Reference bug #2188507.

    --We also identify possible connector's nets attached to a node above the deepest D node.
    --Such explosions will have assignables above the deepest D and so may have passed all the
    --tests above, but a rule may still cross non-virual boundaries. Example:

    --  M
    --  |_D
    --  | |_A
    --  |   |_F2
    --  |
    --  |___Connector->M1-F4

    --F4 has M as its assignable, and although M and D form a good chain, an (F2, F4) rule is
    --prohibited.
    --Reference bug #2190399.

    auxCount := 0;

    FOR i IN 1..v_ParticipantIndex.COUNT LOOP

      nAux := v_NodeId(v_ParticipantIndex(i));

      IF(v_IsConnectorNet.EXISTS(nAux))THEN
        IF(v_tNodeDepth(v_NodeAssignable(nAux)) < MaxDepthValue)THEN

          --This is a connector's net attached to a node above the deepest D assignable, report
          --the rule.

          auxCount := glIndexByPsNodeId(v_tReferringId(v_IsConnectorNet(nAux)));
          auxIndex := glIndexByPsNodeId(v_tPsNodeId(MaxDepthIndex));
          RAISE CZ_R_RULE_IGNORED;
        ELSIF(v_NodeAssignable(nAux) = MaxDepthIndex)THEN

          --This is a connector's net attached to the D, so the rule will be assigned to the D.

          auxCount := 1;

          --Just one attached net is enough, but we cannot exit here because we need to examine
          --all other participants on account of connector's nets attached above the D node
          --(the previous IF does that).
        END IF;
      END IF;
    END LOOP;

    IF(auxCount = 0)THEN

    --We start with identifying all the A type nodes beneath the deepest D node. From every of
    --them we go up the hierarchy and make sure that we end up with the deepest D on its level.

nDebug := 48;

    auxCount := 0;
    nCounter := 0;

    FOR i IN 1..v_DistinctIndex.COUNT LOOP

      auxIndex := v_DistinctIndex(i);
      nAux := v_tNodeDepth(auxIndex);

      IF(v_tExplNodeType(auxIndex) = EXPL_NODE_TYPE_OPTIONAL AND nAux > MaxDepthValue)THEN

         nCounter := nCounter + 1;

         --This is an A type node beneath the deepest D. We want to know how many such nodes
         --there are OUT NOCOPY there.

         auxCount := auxCount + 1;
         v_BeneathNodes(auxCount) := auxIndex;

         --We want to know how many pathes from other A type nodes will pass through this
         --node, because if it happens to be exactly the number of all other A type nodes,
         --then this node is an ancestor of them all. Initialize the counter array here.

         IF(NOT v_BeneathCount.EXISTS(auxIndex))THEN

           v_BeneathCount(auxIndex) := 1;
         ELSE

           v_BeneathCount(auxIndex) := v_BeneathCount(auxIndex) + 1;
         END IF;

         --Lets now go up from the node and make sure we will come to D on level MaxDepthValue.

         FOR n IN REVERSE MaxDepthValue + 1..nAux LOOP

           auxIndex := v_IndexByNodeId(v_tParentId(auxIndex));

           --If parent is an A type node, increment its descendant count array because this
           --path goes through it. Also include it into the list of all the A descendants.

           IF(v_tExplNodeType(auxIndex) = EXPL_NODE_TYPE_OPTIONAL)THEN
             IF(NOT v_BeneathCount.EXISTS(auxIndex))THEN

               auxCount := auxCount + 1;
               v_BeneathNodes(auxCount) := auxIndex;

               v_BeneathCount(auxIndex) := 1;
             ELSE

               v_BeneathCount(auxIndex) := v_BeneathCount(auxIndex) + 1;
             END IF;
           END IF;
         END LOOP;

         IF(auxIndex <> MaxDepthIndex)THEN

           --The way up from the A node doesn't pass through the D node on level MaxDepthValue.
           --Crossing of non-virtual boundaries detected.

           auxCount := glIndexByPsNodeId(v_tPsNodeId(v_DistinctIndex(i)));
           auxIndex := glIndexByPsNodeId(v_tPsNodeId(MaxDepthIndex));
           RAISE CZ_R_RULE_IGNORED;
         END IF;
      END IF;
    END LOOP;

nDebug := 49;

    --Now lets see if there is one A node that is ancestor of all other A nodes, that is we
    --passed through this node on the way up from any other A node. If there are several of
    --them, we want to select the deepest.

    auxIndex := MaxDepthValue;

    FOR i IN 1..v_BeneathNodes.COUNT LOOP
      IF(v_BeneathCount(v_BeneathNodes(i)) = nCounter)THEN
        IF(v_tNodeDepth(v_BeneathNodes(i)) > auxIndex)THEN

          --This may be the A node under the deepest D node we want to assign the rule to.

          auxIndex := v_tNodeDepth(v_BeneathNodes(i));
          MaxDepthIndex := v_BeneathNodes(i);
        END IF;
      END IF;
    END LOOP;
    END IF;

nDebug := 50;

    --The rule is assigned to this component (identified by model_ref_expl_id). This variable
    --is used mostly for identification of rule logic files, but also in rule generation code.

    MaxDepthId := v_NodeId(MaxDepthIndex);
    MaxDepthValue := v_tNodeDepth(MaxDepthIndex);

    --We need to prepend downpaths for all the distinct participating explosions. If the
    --assignable of an explosion id is deeper than the rule's assignee, we are going to
    --prepend the downpath with all optional (type A) components or mandatory references
    --on the way down from the assignee to the assignable. We do not need to change the
    --node's logic level.
    --We do not prepend downpaths for explosions corresponding to connectors.

    FOR i IN 1..v_ParticipantIndex.COUNT LOOP

      nAux := v_NodeId(v_ParticipantIndex(i));

      IF(NOT v_IsConnectorNet.EXISTS(nAux))THEN

        auxIndex := v_NodeAssignable(nAux);

        WHILE(v_tNodeDepth(auxIndex) > MaxDepthValue)LOOP
          IF(v_tExplNodeType(auxIndex) IN (EXPL_NODE_TYPE_OPTIONAL, EXPL_NODE_TYPE_MANDATORY))THEN

            v_AssignedDownPath(nAux) := PATH_DELIMITER || 'N_' ||
                TO_CHAR(glPersistentId(NVL(v_tReferringId(auxIndex), v_tPsNodeId(auxIndex)))) ||
                                        v_AssignedDownPath(nAux);
          END IF;

          auxIndex := v_IndexByNodeId(v_tParentId(auxIndex));
        END LOOP;
      END IF;
    END LOOP;

nDebug := 51;

    --Now we can go ahead and collect the load conditions for this rule. Those would be all
    --type A (optional) and C (connector) descendants of the rule assignee. To collect them
    --we need to go up from each (distinct) rule participant's explosion id (index).
    --There may also be no load conditions at all and then this is the 'standard' rule file
    --identified by explosion id of the assignee as a load condition (NET_TYPE = 2).

    FOR i IN 1..v_ParticipantIndex.COUNT LOOP

      auxIndex := v_ParticipantIndex(i);

      WHILE(v_tNodeDepth(auxIndex) > MaxDepthValue AND v_tParentId(auxIndex) IS NOT NULL) LOOP

        IF(v_tExplNodeType(auxIndex) IN (EXPL_NODE_TYPE_OPTIONAL, EXPL_NODE_TYPE_CONNECTOR))THEN

          --It is enough to just mark the index as a load condition.

          v_MarkLoadCondition(auxIndex) := 1;
        END IF;

        auxIndex := v_IndexByNodeId(v_tParentId(auxIndex));
      END LOOP;
    END LOOP;

    IF(v_MarkLoadCondition.COUNT <> 0)THEN

      --UPDATE cz_rules SET disabled_flag = '1' WHERE rule_id = nRuleId;
      RAISE CZ_R_RULE_REPORTED; --This rule should be reported.

    END IF;
   END IF; --Not a rule folder or functional companion

  --This block handles the exceptions during a rule generation. Every such exception
  --will stop generation only for the particular rule if not re-raised here.

  EXCEPTION
     WHEN CZ_R_RULE_IGNORED THEN
       NULL;
     WHEN CZ_R_RULE_REPORTED THEN
--'Upgrade of rule ''%RULENAME'' in model ''%MODELNAME'' may cause a change in behavior of the model
-- at run-time. The rule has been disabled.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_RULE_REPORTED', 'RULENAME', RULE_NAME, 'MODELNAME', inProjectId || '->' || glName(glIndexByPsNodeId(inProjectId))), 1);
     WHEN OTHERS THEN
       NULL;
  END;
  END LOOP;
  CLOSE c_rules;
END; --GENERATE_RULES
---------------------------------------------------------------------------------------
BEGIN --GENERATE_COMPONENT_TREE - Product Structure Generation

nDebug := 1110000;

  IF(NOT IsLogicGenerated.EXISTS(inComponentId))THEN

    --Read the explosions table here. It will be extensively used in rule generation.

    IF(inComponentId = inProjectId)THEN

      --If this is the root model, read the table and populate project's id and explosion id
      --variables, and hash tables.

      SELECT model_ref_expl_id, parent_expl_node_id, node_depth,
             ps_node_type, virtual_flag, component_id, referring_node_id,
             child_model_expl_id, expl_node_type
      BULK COLLECT INTO v_NodeId, v_tParentId, v_tNodeDepth,
                        v_tNodeType, v_tVirtualFlag, v_tPsNodeId, v_tReferringId,
                        v_tChildModelExpl, v_tExplNodeType
      FROM cz_model_ref_expls
      WHERE model_id = inComponentId and deleted_flag = FLAG_NOT_DELETED;

      FOR i IN 1..v_NodeId.COUNT LOOP

nDebug := 1110001;

        --Add another indexing option - by model_ref_expl_id

        v_IndexByNodeId(v_NodeId(i)) := i;

        --Store the explosion id and the index of the root node - the project node itself.

        IF(v_tNodeDepth(i) = 0)THEN
          thisComponentExplId := v_NodeId(i);
          thisRootExplIndex := i;
        END IF;

        --Create the EXPL_NODE_TYPE(MODEL_REF_EXPL_ID) hash table. Other explosion columns
        --are currently indexed through v_IndexByNodeId. Using direct hash may provide for
        --some performance improvement.

        v_TypeByExplId(v_NodeId(i)) := v_tExplNodeType(i);

        --Build the MODEL_REF_EXPL_ID(COMPONENT_ID) hash table for all the components
        --inside this project (not inside referenced projects). All such components
        --have CHILD_MODEL_EXPL_ID null. We need this table to populate MODEL_REF_EXPL_ID
        --in CZ_LCE_HEADERS records for structure file of this component.

        IF(v_tChildModelExpl(i) IS NULL)THEN
          v_NodeIdByComponent(v_tPsNodeId(i)) := v_NodeId(i);
        END IF;
      END LOOP;

      BEGIN

        --Get the project name for reporting purposes

        SELECT name INTO errorMessage
        FROM cz_devl_projects
        WHERE devl_project_id = inProjectId;

      EXCEPTION
        WHEN OTHERS THEN
          errorMessage := NULL;
      END;

    ELSE

nDebug := 1110002;

      --This is a non-virtual component inside this project, so the value in the
      --hash table exists.
      --We do not have to populate thisRootExplIndex, because it is used only in
      --rule generation and this will not be called for a non-root component.
      --Have to populate the other two variables though as they are used here in
      --the structure generation.

      thisComponentExplId := v_NodeIdByComponent(inComponentId);
    END IF;

    thisProjectId := inProjectId;

  END IF;

nDebug := 1110004;

  --This select statement reads the whole 'virtual' tree under a non-virtual component
  --which doesn't include the chief non-virtual component itself, although it includes
  --non-virtual components underneath in order to recurse,this function will be called
  --for every non-virtual component found underneath.
  --The resulting order provided by this statement will be used later when generating
  --list of options for an option feature.

  SELECT ps_node_id, parent_id, item_id, minimum, maximum, name, intl_text_id,
         minimum_selected, maximum_selected, ps_node_type, initial_value, initial_num_value, -- sselahi
         virtual_flag, feature_type, bom_required_flag, reference_id, persistent_node_id,
         effective_from, effective_until, effective_usage_mask, effectivity_set_id, decimal_qty_flag
  BULK COLLECT INTO ntPsNodeId, ntParentId, ntItemId, ntMinimum, ntMaximum, ntName, ntDescriptionId,
                    ntMinimumSel, ntMaximumSel, ntPsNodeType, ntInitialValue, ntInitNumVal, -- sselahi
                    ntVirtualFlag, ntFeatureType, ntBomRequired, ntReferenceId, ntPersistentId,
                    dtEffFrom, dtEffUntil, vtUsageMask, ntEffSetId, ntDecimalQty
  FROM cz_ps_nodes
  WHERE deleted_flag = FLAG_NOT_DELETED
  START WITH ps_node_id = inComponentId
  CONNECT BY
   (PRIOR virtual_flag IS NULL OR PRIOR virtual_flag = FLAG_VIRTUAL OR
    PRIOR ps_node_id = inComponentId)
   AND PRIOR ps_node_id = parent_id;

nDebug := 1110005;

  --Make sure there is some data returned

  IF(ntPsNodeId.LAST IS NOT NULL)THEN

nDebug := 1110006;

  --Check if the logic already exists (or has been considered up-to-date).

  IF(isLogicGenerated.EXISTS(inComponentId))THEN

    --If the value is 0, it has been pre-populated in GENERATE_LOGIC_ procedure because
    --logic for this model was considered up-to-date. Report the message and change the
    --value to 1 which is the constant used within this procedure (bug #1941626).

    IF(isLogicGenerated(inComponentId) = 0)THEN

      --We want no message about skipping a model displayed, bug #2055845

      isLogicGenerated(inComponentId) := 1;
    END IF;

nDebug := 1110007;

    --Logic exists, just follow the references and connectors.

    FOR i IN ntPsNodeId.FIRST..ntPsNodeId.LAST LOOP
      IF(ntPsNodeType(i) IN (PS_NODE_TYPE_REFERENCE, PS_NODE_TYPE_CONNECTOR))THEN

        --Check for circularity.

        localCount := 0;

        FOR n IN 1..globalLevel LOOP
         IF(globalStack(n) = ntReferenceId(i))THEN

           --Circularity detected.

           localCount := 1;
           EXIT;
         END IF;
        END LOOP;

        IF(localCount = 0)THEN

          globalLevel := globalLevel + 1;
          globalStack(globalLevel) := ntReferenceId(i);

          GENERATE_COMPONENT_TREE(ntReferenceId(i), ntReferenceId(i));
          globalLevel := globalLevel - 1;
        END IF;
      END IF;
    END LOOP;

nDebug := 1110008;

  END IF;

nDebug := 1110009;

  --Having this dummy boundary node eliminates the necessity of potentially time
  --consuming boundary checks during the option feature options' list generation

  ntParentId(ntPsNodeId.LAST + 1) := NEVER_EXISTS_ID;

  --Prepare to start the main cycle

  i := ntPsNodeId.FIRST;

  WHILE(i <= ntPsNodeId.LAST) LOOP --Start the main structure generating cycle

   BEGIN

   --Populate the 'global' arrays - required for rules generation

nDebug := 1110010;

    IF(NOT glIndexByPsNodeId.EXISTS(ntPsNodeId(i)))THEN

     glPsNodeId(globalCount) := ntPsNodeId(i);
     glItemId(globalCount) := ntItemId(i);
     glPsNodeType(globalCount) := ntPsNodeType(i);
     glParentId(globalCount) := ntParentId(i);
     glFeatureType(globalCount) := ntFeatureType(i);
     glName(globalCount) := ntName(i);
     glBomRequired(globalCount) := ntBomRequired(i);
     glMinimum(globalCount) := ntMinimum(i);
     glMaximum(globalCount) := ntMaximum(i);
     glMinimumSel(globalCount) := ntMinimumSel(i);
     glMaximumSel(globalCount) := ntMaximumSel(i);
     glVirtualFlag(globalCount) := ntVirtualFlag(i);

   --Indexing by ps_node_id, will be used in expressions generation to get back to
   --the structure

     glIndexByPsNodeId(ntPsNodeId(i)) := globalCount;

   --These global arrays will be indexed differently because we only need to get
   --persistent_node_id or reference_id by ps_node_id. Probably, good indexing
   --option for some of the other global arrays, too.

     glPersistentId(ntPsNodeId(i)) := ntPersistentId(i);
     glReferenceId(ntPsNodeId(i)) := ntReferenceId(i);
     glDecimalQty(ntPsNodeId(i)) := ntDecimalQty(i);

     globalCount := globalCount + 1;
    END IF;

nDebug := 1110011;

    IF(isLogicGenerated.EXISTS(inComponentId))THEN

      --We need to call the procedure for any non-virtual component (bug #2065239).

      IF(ntVirtualFlag(i) = FLAG_NON_VIRTUAL AND
         ntPsNodeType(i) IN (PS_NODE_TYPE_COMPONENT, PS_NODE_TYPE_PRODUCT) AND
         ntPsNodeId(i) <> inComponentId)THEN

        --We emulate the component as a model with generated logic because we do not want to
        --generate anything but still want to follow everything underneath this component.

        IsLogicGenerated(ntPsNodeId(i)) := 1;

        --We can pass logic header as NULL because it will never be actually used.

        GENERATE_COMPONENT_TREE(ntPsNodeId(i), inProjectId);
      END IF;

    --If no logic already exists, generate the structure.

    ELSE

    IF(ntPsNodeType(i) IN (PS_NODE_TYPE_COMPONENT, PS_NODE_TYPE_PRODUCT) AND
       ntVirtualFlag(i) = FLAG_NON_VIRTUAL)THEN

nDebug := 1110030;

     --We don't want to go into an infinite cycle - don't call the procedure for the current
     --root component

     IF(ntPsNodeId(i) <> inComponentId)THEN

      GENERATE_COMPONENT_TREE(ntPsNodeId(i), inProjectId);
     END IF;

    ELSIF(ntPsNodeType(i) IN (PS_NODE_TYPE_REFERENCE, PS_NODE_TYPE_CONNECTOR))THEN

nDebug := 1110031;

     localCount := 0;

     FOR n IN 1..globalLevel LOOP
      IF(globalStack(n) = ntReferenceId(i))THEN

        --Circularity detected.

        localCount := 1;
        EXIT;
      END IF;
     END LOOP;

     IF(localCount = 0)THEN

       globalLevel := globalLevel + 1;
       globalStack(globalLevel) := ntReferenceId(i);

       GENERATE_COMPONENT_TREE(ntReferenceId(i), ntReferenceId(i));
       globalLevel := globalLevel - 1;
     END IF;
    END IF;
    END IF; --End of the IF block of 'if logic does not already exist' inside the main loop
   END;

   --Increase the main cycle counter

   i := i + 1;

  END LOOP; --End of the main structure generation cycle

nDebug := 1110038;

  ELSE --IF 'there is some data returned'

    --The project is empty, stop here
    RAISE CZ_S_MODEL_IGNORED;
  END IF; --Ends the ELSE block of IF 'there is some data returned'

nDebug := 1110039;

  --If a model, generate rules and set the logic generated flag.

  IF(inComponentId = inProjectId)THEN

    --Generate model's rules and expressions if necessary

    IF(NOT IsLogicGenerated.EXISTS(inComponentId))THEN
      GENERATE_RULES;
      IsLogicGenerated(inComponentId) := 1;
    END IF;
  END IF;
END; --GENERATE_COMPONENT_TREE
---------------------------------------------------------------------------------------
BEGIN --VERIFY_RULES

  --Get the logic generation run id. If a valid value has been passed as a parameter, use it,
  --else generate a new value.

  IF(thisRunId IS NULL OR thisRunId = 0)THEN
    SELECT cz_xfr_run_infos_s.NEXTVAL INTO thisRunId FROM DUAL;
  END IF;

   globalLevel := globalLevel + 1;
   globalStack(globalLevel) := inDevlProjectId;

  --Start off the recursion

  GENERATE_COMPONENT_TREE(inDevlProjectId, inDevlProjectId);

EXCEPTION
  WHEN CZ_G_UNABLE_TO_REPORT_ERROR THEN
   REPORT(SQLERRM, 0);
  WHEN OTHERS THEN
    NULL;
END;
---------------------------------------------------------------------------------------
PROCEDURE CZNATIVEBOMSORT(p_sort_width IN INTEGER,
                          p_batch_size IN INTEGER) IS

v_config_item_id    INTEGER;
startRec            PLS_INTEGER;
endRec              PLS_INTEGER;
BatchSize           INTEGER:=p_batch_size;
var_bom_sort        cz_config_items.bom_sort_order%TYPE;
xERROR              BOOLEAN:=FALSE;

TYPE tConfigItemId  IS TABLE OF cz_config_items.config_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tConfigHdrId   IS TABLE OF cz_config_items.config_hdr_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tConfigRevNbr  IS TABLE OF cz_config_items.config_rev_nbr%TYPE INDEX BY BINARY_INTEGER;
TYPE tBomSortOrder  IS TABLE OF cz_config_items.bom_sort_order%TYPE INDEX BY BINARY_INTEGER;

tabConfigItemId     tConfigItemId;
tabConfigHdrId      tConfigHdrId;
tabConfigRevNbr     tConfigRevNbr;
tabBomSortOrder     tBomSortOrder;

globalIndex         PLS_INTEGER := 0;

FUNCTION getNum(p_number IN INTEGER) RETURN VARCHAR2 IS
    ret VARCHAR2(100);
BEGIN
    SELECT LPAD(TO_CHAR(p_number),p_sort_width,'0') INTO ret FROM dual;
    RETURN ret;
END getNum;

PROCEDURE populate(p_config_item_id IN INTEGER,
		       p_config_hdr_id  IN INTEGER,
			 p_config_rev_nbr IN INTEGER,
		       p_string1 IN VARCHAR2)
IS

var_string1 CZ_PS_NODES.bom_sort_order%TYPE;
sequenceNbr  PLS_INTEGER := 1;

BEGIN
    FOR i IN (SELECT config_item_id
              FROM   cz_config_items
              WHERE parent_config_item_id = p_config_item_id
		  AND   config_hdr_id  = p_config_hdr_id
		  AND   config_rev_nbr = p_config_rev_nbr
		  AND   (ps_node_id IS NULL OR ps_node_id < 0))
    LOOP
       var_string1 := p_string1 || getNum(sequenceNbr);
       sequenceNbr := sequenceNbr + 1;

       globalIndex := globalIndex + 1;
       tabConfigItemId(globalIndex) := i.config_item_id;
       tabConfigHdrId(globalIndex) := p_config_hdr_id;
       tabConfigRevNbr(globalIndex) := p_config_rev_nbr;
       tabBomSortOrder(globalIndex) := var_string1;

       populate(i.config_item_id, p_config_hdr_id, p_config_rev_nbr, var_string1);
    END LOOP;
END populate;

BEGIN
    var_bom_sort:=getNum(1);

    FOR c_native IN (SELECT config_hdr_id,
				    config_rev_nbr,
				    config_item_id
                      FROM  cz_config_details_v c
                      WHERE (ps_node_id IS NULL OR ps_node_id < 0)
                        AND bom_sort_order IS NULL
                        AND  parent_config_item_id NOT IN
                            (SELECT config_item_id FROM cz_config_details_v
                              WHERE config_hdr_id = c.config_hdr_id
                                AND config_rev_nbr = c.config_rev_nbr))LOOP

      globalIndex := globalIndex + 1;
      tabConfigItemId(globalIndex) := c_native.config_item_id;
      tabConfigHdrId(globalIndex) := c_native.config_hdr_id;
      tabConfigRevNbr(globalIndex) := c_native.config_rev_nbr;
      tabBomSortOrder(globalIndex) := var_bom_sort;

      populate(c_native.config_item_id, c_native.config_hdr_id, c_native.config_rev_nbr, var_bom_sort);
   END LOOP;

   startRec := 1;

   WHILE(startRec <= globalIndex)LOOP

      endRec := startRec + BatchSize;
      IF(endRec > globalIndex)THEN endRec := globalIndex; END IF;

      FORALL i IN startRec..endRec
        UPDATE cz_config_items
          SET bom_sort_order = tabBomSortOrder(i)
        WHERE config_item_id = tabConfigItemId(i)
          AND config_hdr_id  = tabConfigHdrId(i)
          AND config_rev_nbr = tabConfigRevNbr(i)
          AND bom_sort_order is NULL
          AND deleted_flag = '0';

      startRec := endRec + 1;
      COMMIT;
   END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
WHEN OTHERS THEN
     RAISE;
END CZNATIVEBOMSORT;

----------------------------------------------
-------this procedure is a fix for bug# 3854632
-------this procedure republished the following models
-------Envoy Custom Laptop(204 143), Sentinal Custom Desktop(204 137)
-------Server System(204 3791)
PROCEDURE publish_vision_models
IS

  TYPE t_varchar_tbl IS TABLE OF VARCHAR2(255) index by binary_integer;
  TYPE t_number_tbl  IS TABLE OF NUMBER index by binary_integer;

  t_model_names_tbl t_varchar_tbl;
  t_models_tbl      t_number_tbl;
  t_model_ids_tbl   t_number_tbl;
  t_publ_ids_tbl    t_number_tbl;
  t_publ_ids_ref    t_number_tbl;
  t_uis_ref	    	  t_number_tbl;
  rec_count	    	  NUMBER := 0;
  l_runId	    	  NUMBER := 0;
  l_status   	  VARCHAR2(3);
  l_message	        VARCHAr2(2000);
begin
   ------initialize vision model names
   t_model_names_tbl.DELETE;
   t_model_names_tbl(1) := 'Envoy Custom Laptop(204 143)';
   t_model_names_tbl(2) := 'Sentinal Custom Desktop(204 137)';
   t_model_names_tbl(3) := 'Server System(204 3791)';

   -----get model id(s) from cz_rp_entries
   IF (t_model_names_tbl.COUNT > 0) THEN
	t_model_ids_tbl.DELETE;
	FOR I IN t_model_names_tbl.FIRST..t_model_names_tbl.LAST
	LOOP
	   t_models_tbl.DELETE;
	   BEGIN
	    SELECT object_id
	    BULK
	    COLLECT
	    INTO   t_models_tbl
	    FROM   cz_rp_entries
	    WHERE  object_type = 'PRJ'
	    AND    deleted_flag = '0'
	    AND    name = t_model_names_tbl(i);
	   EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      NULL;
	   END;
	   IF (t_models_tbl.COUNT > 0) THEN
		rec_count := t_model_ids_tbl.COUNT;
		FOR J IN t_models_tbl.FIRST..t_models_tbl.LAST
		LOOP
			rec_count := rec_count + 1;
			t_model_ids_tbl(rec_count) := t_models_tbl(j);
	      END LOOP;
	    END IF;
	END LOOP;
   END IF;

   -----get publication id(s) for the above model id(s),
   -----generate logic for each model (top level only)
   ---- refresh UI(s) including the child UI(s)

   IF (t_model_ids_tbl.COUNT > 0) THEN
	t_publ_ids_ref.DELETE;
	FOR I IN t_model_ids_tbl.FIRST..t_model_ids_tbl.LAST
	LOOP
	    t_publ_ids_tbl.DELETE;
	    SELECT publication_id
	    BULK
	    COLLECT
	    INTO   t_publ_ids_tbl
	    FROM   cz_model_publications
	    WHERE  deleted_flag = '0'
	    AND    source_target_flag = 'S'
	    AND    export_status = 'OK'
	    AND    trunc(creation_date) < TO_DATE('12/31/2002', 'mm/dd/yyyy')
	    AND    object_id = t_model_ids_tbl(i);

	    IF (t_publ_ids_tbl.COUNT > 0) THEN
		rec_count := t_publ_ids_ref.COUNT;
		FOR J IN t_publ_ids_tbl.FIRST..t_publ_ids_tbl.LAST
		LOOP
		    rec_count := rec_count + 1;
		    t_publ_ids_ref(rec_count) := t_publ_ids_tbl(j);
		END LOOP;

	    	------generate logic
	      cz_logic_gen.generate_logic(t_model_ids_tbl(i), l_runId);
 	      COMMIT;

	    	------refresh UI(S)
	    	t_uis_ref.DELETE;
	    	BEGIN
 	    		SELECT ui_def_id
	    		BULK
	    		COLLECT
	    		INTO    t_uis_ref
	    		FROM    cz_ui_defs
	    		WHERE   cz_ui_defs.devl_project_id IN (SELECT COMPONENT_ID
						   FROM   CZ_MODEL_REF_EXPLS
						   WHERE  model_id = t_model_ids_tbl(i)
						   AND    deleted_flag = '0')
			AND     cz_ui_defs.deleted_flag = '0'
			AND     cz_ui_defs.ui_style = '0';
	    	EXCEPTION
	    	WHEN NO_DATA_FOUND THEN
			NULL;
	    	END;

	    	IF (t_uis_ref.COUNT > 0) THEN
			FOR J IN t_uis_ref.FIRST..t_uis_ref.LAST
			LOOP
		   	 cz_ui_generator.refresh_UI(t_uis_ref(j));
		   	 COMMIT;
			END LOOP;
	    	END IF;
	    END IF;
	 END LOOP;
    END IF;

    -------for the above publication id(s) reset the publications
    IF (t_publ_ids_ref.COUNT > 0) THEN
	FOR I IN t_publ_ids_ref.FIRST..t_publ_ids_ref.LAST
	LOOP
	  update cz_model_publications set remote_publication_id = NULL where publication_id = t_publ_ids_ref(i);
	  update cz_model_publications set export_status = 'PEN' where publication_id =   t_publ_ids_ref(i);
	  update cz_model_publications set creation_date = sysdate where publication_id =   t_publ_ids_ref(i);
	  delete from cz_pb_model_exports where publication_id =   t_publ_ids_ref(i);
	  delete from cZ_model_publications where remote_publication_id = t_publ_ids_ref(i);
	END LOOP;
 	COMMIT;

	----publish models
	FOR J IN t_publ_ids_ref.FIRST..t_publ_ids_ref.LAST
	LOOP
	   cz_pb_mgr.publish_model(t_publ_ids_ref(j),l_runId,l_status);
	END LOOP;
	COMMIT;
    END IF;
EXCEPTION
WHEN OTHERS THEN
   l_message := SQLERRM;
   insert into cz_db_logs (LOGTIME,message,caller)
	values (sysdate,l_message,'PBVISIONMODELS');
   commit;
END;
--------------------------------------------------------------------------------------
END CZ_UPGRADE;

/
