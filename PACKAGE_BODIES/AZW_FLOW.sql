--------------------------------------------------------
--  DDL for Package Body AZW_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZW_FLOW" AS
/* $Header: AZWFLOWB.pls 115.13 2002/12/27 23:59:49 angupta ship $: */

--
-- application_not_found
--
-- Private function.  Called by populate_product_flows.
-- Given an application id, return TRUE if it exists in az_product_phases
--

  FUNCTION application_not_found(p_application_id NUMBER) RETURN BOOLEAN IS

    ret BOOLEAN DEFAULT FALSE;
    v_cnt INTEGER DEFAULT 0;

  BEGIN
	    SELECT COUNT(*)
	    INTO   v_cnt
	    FROM   az_product_phases azpp
	    WHERE  application_id = p_application_id;

    IF (v_cnt = 0) THEN
      ret := TRUE;
    ELSE
      ret := FALSE;
    END IF;
    RETURN ret;

  EXCEPTION
    WHEN app_exception.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('error: process_not_found: ' || SQLERRM);
    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
    fnd_message.set_token('AZW_ERROR_PROC','azw_flow.application_not_found');
    fnd_message.set_token('AZW_ERROR_STMT','select count(*) from az_product_phases');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END application_not_found;


--
-- POPULATE_PRODUCT_FLOWS
--
-- Public procedure.
-- Retrieve all workflow processes and store them in AZ_PRODUCT_FLOWS.
--

  PROCEDURE populate_product_flows IS

    CURSOR processes_cursor IS
      SELECT   wav.item_type, wav.name,
               waav.text_default application_id,
               waav1.text_default display_order,
               waav2.text_default ctxt_type,
               waav3.text_default parent_id,
               waav4.text_default process_type
      FROM     wf_activities_vl wav,
               wf_activity_attributes_vl waav,
               wf_activity_attributes_vl waav1,
	       wf_activity_attributes_vl waav2,
	       wf_activity_attributes_vl waav3,
	       wf_activity_attributes_vl waav4
      WHERE    wav.item_type like 'AZW%'
      AND      wav.type = 'PROCESS'
      AND      wav.runnable_flag = 'Y'
      AND      wav.end_date is null
      AND      waav.activity_item_type = wav.item_type
      AND      waav.activity_name = wav.name
      AND      waav.name = 'AZW_IA_WFPROD'
      AND      waav.activity_version =
               (SELECT MAX(activity_version)
                FROM   wf_activity_attributes_vl
                WHERE  activity_item_type = wav.item_type
                AND    activity_name = wav.name
                AND    name = 'AZW_IA_WFPROD')
      AND      waav1.activity_item_type = wav.item_type
      AND      waav1.activity_name = wav.name
      AND      waav1.name = 'AZW_IA_VAWM'
      AND      waav1.text_default IS NOT NULL
      AND      waav1.activity_version =
               (SELECT MAX(activity_version)
                FROM   wf_activity_attributes_vl
                WHERE  activity_item_type = wav.item_type
                AND    activity_name = wav.name
                AND    name = 'AZW_IA_VAWM')
      AND      waav2.activity_item_type = wav.item_type
      AND      waav2.activity_name = wav.name
      AND      waav2.name = 'AZW_IA_CTXTYP'
      AND      exists
	       (SELECT lookup_code
                FROM   fnd_lookups
                where  lookup_code = waav2.text_default
                AND    lookup_type = 'AZ_CONTEXT_TYPE')
      AND      waav2.activity_version =
               (SELECT MAX(activity_version)
                FROM   wf_activity_attributes_vl
                WHERE  activity_item_type = wav.item_type
                AND    activity_name = wav.name
                AND    name = 'AZW_IA_CTXTYP')
      AND      waav3.activity_item_type = wav.item_type
      AND      waav3.activity_name = wav.name
      AND      waav3.name = 'AZW_IA_PARENTID'
      AND      exists
	       (SELECT group_id
                FROM   az_groups ag
                WHERE  ag.group_id = waav3.text_default
		AND    ag.process_type = fnd_profile.value('AZ_CURRENT_MODE'))
      AND      waav3.activity_version =
               (SELECT MAX(activity_version)
                FROM   wf_activity_attributes_vl
                WHERE  activity_item_type = wav.item_type
                AND    activity_name = wav.name
                AND    name = 'AZW_IA_PARENTID')
	-- Start : added by Swarup
      AND      waav4.activity_item_type = wav.item_type
      AND      waav4.activity_name = wav.name
      AND      waav4.name = 'AZW_IA_FLOWTYPE'
      AND      exists
	       (SELECT meaning
                FROM   fnd_lookups
                where  lookup_code = waav4.text_default
                AND    lookup_type = 'AZ_PROCESS_TYPE')
      AND      waav4.activity_version =
               (SELECT MAX(activity_version)
                FROM   wf_activity_attributes_vl
                WHERE  activity_item_type = wav.item_type
                AND    activity_name = wav.name
                AND    name = 'AZW_IA_FLOWTYPE')
	-- End : added by Swarup
      ORDER BY waav1.text_default;

     CURSOR applications_cursor IS
      SELECT distinct application_id
      FROM   fnd_application;

     v_application_id NUMBER DEFAULT 0;
     v_item_type      wf_activities_vl.item_type%TYPE DEFAULT NULL;
     v_process_name   wf_activities_vl.name%TYPE DEFAULT NULL;
     v_application_ids wf_activity_attributes_vl.text_default%TYPE DEFAULT NULL;
     v_display_order  wf_activity_attributes_vl.text_default%TYPE DEFAULT NULL;
     v_ctxt_type      wf_activity_attributes_vl.text_default%TYPE DEFAULT NULL;
     v_parent_id      wf_activity_attributes_vl.text_default%TYPE DEFAULT NULL;
     v_process_type   wf_activity_attributes_vl.text_default%TYPE DEFAULT NULL;
     v_installed_prod_id fnd_product_installations.application_id%TYPE DEFAULT NULL;
     id_count         INTEGER DEFAULT 0;
     v_display_number NUMBER(5) DEFAULT 0;

   BEGIN

    DELETE
    FROM   az_product_flows;
    COMMIT;
    -- populate defaults of phase 1 for all installed products into
    -- az_product_phases

    --DBMS_OUTPUT.PUT_LINE('trying to open cursor1');

	BEGIN
	    OPEN applications_cursor;
	    FETCH applications_cursor INTO v_installed_prod_id;

	    WHILE applications_cursor%FOUND LOOP
	      --DBMS_OUTPUT.PUT_LINE('application id ' || v_installed_prod_id);
	      IF application_not_found(v_installed_prod_id) THEN
		INSERT INTO az_product_phases
		  (application_id, phase, last_update_date, last_updated_by,
		   creation_date, created_by)
		VALUES(v_installed_prod_id, 1, sysdate, 1, sysdate, 1);
	      END IF;

	      FETCH applications_cursor INTO v_installed_prod_id;
	    END LOOP;
	    CLOSE applications_cursor;
	EXCEPTION
	    WHEN app_exception.application_exception THEN
		RAISE;
	    WHEN OTHERS THEN
	        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     		fnd_message.set_token('AZW_ERROR_PROC','azw_flow.populate_product_flows');
		fnd_message.set_token('AZW_ERROR_STMT','CURSOR applications_cursor');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;


	BEGIN
	    OPEN processes_cursor;
	    FETCH processes_cursor
	    INTO  v_item_type, v_process_name, v_application_ids,
		  v_display_order, v_ctxt_type, v_parent_id, v_process_type;

		--DBMS_OUTPUT.PUT_LINE('item_type: ' || v_item_type || ' apps ' ||
				 --v_application_ids);

	    WHILE processes_cursor%FOUND LOOP
		 id_count         := id_count + 1;
		 v_display_number := v_display_number + 1;

		--DBMS_OUTPUT.PUT_LINE('trying to insert process :' || id_count);

		 v_application_id :=
		     AZW_PROC.parse_application_ids(v_application_ids, id_count);

		 WHILE (v_application_id > -1) LOOP
		 --DBMS_OUTPUT.PUT_LINE('application id: into az_product_flows ' ||
				      --v_application_id);

		   INSERT INTO az_product_flows(application_id, item_type, process_name,
		     display_order, context_type, parent_id, process_type)
		   VALUES(v_application_id, v_item_type, v_process_name,
			  v_display_number , v_ctxt_type, v_parent_id,
					NVL(v_process_type,'IMP'));

		--DBMS_OUTPUT.PUT_LINE('inserted: '||v_process_name);
		   id_count := id_count + 1;
		   v_application_id :=
		       AZW_PROC.parse_application_ids(v_application_ids, id_count);
		END LOOP;

		 id_count := 0;
		 FETCH processes_cursor
		 INTO  v_item_type, v_process_name, v_application_ids,
		  v_display_order, v_ctxt_type, v_parent_id, v_process_type;

	    END LOOP;

	    CLOSE processes_cursor;

	EXCEPTION
	    WHEN app_exception.application_exception THEN
		RAISE;
	    WHEN OTHERS THEN
	        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     		fnd_message.set_token('AZW_ERROR_PROC','azw_flow.populate_product_flows');
		fnd_message.set_token('AZW_ERROR_STMT','CURSOR processes_cursor');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    --Do a clean-up of AZ_PROCESSES for processes not in AZ_PRODUCT_FLOWS

	BEGIN
	    DELETE from az_processes ap
	    WHERE  not exists
		   (SELECT item_type from AZ_PRODUCT_FLOWS apf
		    where  apf.item_type = ap.item_type)
	       OR  not exists
		   (SELECT process_name from AZ_PRODUCT_FLOWS apf
		    where  apf.process_name = ap.process_name);
	EXCEPTION
	    WHEN app_exception.application_exception THEN
		RAISE;
            WHEN OTHERS THEN
	        fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	        fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	        fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     		fnd_message.set_token('AZW_ERROR_PROC','azw_flow.populate_product_flows');
		fnd_message.set_token('AZW_ERROR_STMT','delete from az_processes');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END;

    COMMIT;

    EXCEPTION
	WHEN app_exception.application_exception THEN
	    RAISE;
        WHEN OTHERS THEN
	    fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	    fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	    fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     	    fnd_message.set_token('AZW_ERROR_PROC','azw_flow.populate_product_flows');
	    fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	    APP_EXCEPTION.RAISE_EXCEPTION;
END populate_product_flows;

END AZW_FLOW;

/
