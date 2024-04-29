--------------------------------------------------------
--  DDL for Package Body CZ_CF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_CF_API" AS
/*  $Header: czcfapib.pls 120.15.12010000.8 2010/04/14 00:33:40 smanna ship $        */
------------------------------------------------------------------------------------------
  G_PKG_NAME   CONSTANT VARCHAR2(30) := 'CZ_CF_API';

  TYPE str255_tbl_type  IS TABLE OF VARCHAR2(255)  INDEX BY PLS_INTEGER; -- name, ...
  TYPE str1200_tbl_type IS TABLE OF VARCHAR2(1200) INDEX BY PLS_INTEGER; -- component code,...

  last_hdr_allocated    INTEGER :=NULL;
  next_hdr_to_use       INTEGER :=0;
  last_msg_seq_allocated  NUMBER := NULL;
  next_msg_seq_to_use     NUMBER := 0;
  id_increment          INTEGER;
  DEFAULT_INCR          CONSTANT PLS_INTEGER :=20;

  c_application_id      VARCHAR2(255);
  c_usage_name          VARCHAR2(255);

  UI_STYLE_DHTML        CONSTANT VARCHAR2(3) := '0';
  UI_STYLE_APPLET       CONSTANT VARCHAR2(3) := '3';
  UI_STYLE_JRAD         CONSTANT VARCHAR2(3) := '7';
  UI_STYLE_WEGA         CONSTANT VARCHAR2(3) := '8';

  NATIVEBOM_UI_TYPE     CONSTANT VARCHAR2(20) := 'JRAD';

  BOM_ITEM_TYPE_MODEL   CONSTANT NUMBER := 1;

  PS_NODE_TYPE_REFERENCE  CONSTANT NUMBER := 263;

  ANY_APPLICATION_ID    CONSTANT NUMBER := -1;
  ANY_USAGE_ID          CONSTANT NUMBER := -1;
  ANY_USAGE_NAME        CONSTANT VARCHAR2(20) := 'Any Usage';
  TARGET_PUBLICATION    CONSTANT VARCHAR2(1) := 'T';

  -- model_type/model_instantiation_type
  NETWORK CONSTANT VARCHAR2(1) := 'N';

  -- component_instance_type
  ROOT                  CONSTANT VARCHAR2(1) := 'R';
  GENERIC_INSTANCE_ROOT CONSTANT VARCHAR2(1) := 'C';
  NETWORK_INSTANCE_ROOT CONSTANT VARCHAR2(1) := 'I';
  INCLUDED              CONSTANT VARCHAR2(1) := 'T';

  INVALID_OPTION_EXCEPTION  EXCEPTION;
  ZERO_RESPONSE_LENGTH      EXCEPTION;
  WRONG_ARRAYS_LENGTH       EXCEPTION;
  CONFIG_HDR_TYPE_EXC       EXCEPTION;
  --vsingava 03 Sep '09 ER8689105
  MODEL_POOL_EFFINITY_EXC   EXCEPTION;
  transferTimeout           PLS_INTEGER := NULL;
  defaultTimeout            PLS_INTEGER := NULL;

  ----constants used in check deltas
  ITEM_DELETE_MESSAGE  CONSTANT VARCHAR2(30) := 'CZ_BATCH_VAL_ITEM_DELETED';
  ITEM_ADD_MESSAGE     CONSTANT VARCHAR2(30) := 'CZ_BATCH_VAL_ITEM_ADDED';
  QTY_CHANGE_MESSAGE   CONSTANT VARCHAR2(30) := 'CZ_BATCH_VAL_DIFF';

  -- operation code for the old bv behavior: set quantity
  BV_OPERATION_OLD    CONSTANT  INTEGER := 0;

  -- pseudo model type
  BV_MODEL_TYPE CONSTANT  VARCHAR2(1) := 'C';

--------------------------------------------------------------------------------
FUNCTION get_db_setting (p_section_name IN VARCHAR2, p_setting IN VARCHAR2)
  RETURN VARCHAR2 IS
     l_ret_value cz_db_settings.value%TYPE;
BEGIN
   SELECT value INTO l_ret_value FROM cz_db_settings WHERE Upper(section_name)
     = Upper(p_section_name) AND Upper(setting_id) = Upper(p_setting);
   RETURN l_ret_value;
END;

------------------------------------------------------------------------------------------------
FUNCTION usage_id_from_usage_name (p_usage_name IN VARCHAR2)
RETURN NUMBER
IS
  v_usage_id NUMBER;
BEGIN

    IF p_usage_name IS NOT NULL THEN
        BEGIN
                SELECT model_usage_id
                 INTO  v_usage_id
                FROM  CZ_MODEL_USAGES
                WHERE  LTRIM(RTRIM(UPPER(CZ_MODEL_USAGES.name))) = LTRIM(RTRIM(UPPER(p_usage_name)))
            AND   cz_model_usages.in_use = '1';
        EXCEPTION
        WHEN OTHERS THEN
            v_usage_id := ANY_USAGE_ID;
        END;
    ELSE
        v_usage_id := ANY_USAGE_ID;
    END IF;

RETURN v_usage_id;
END usage_id_from_usage_name;

------------------------------------------------------------------------------------------
-- The next two functions convert between ui_style ('0' and '3')
-- and the ui_type input ('DHTML' and 'APPLET')

FUNCTION ui_style_from_ui_type (ui_type IN VARCHAR2)
RETURN VARCHAR2 IS
  v_ui_style VARCHAR2(3);
BEGIN
     SELECT DECODE(ui_type, 'APPLET', UI_STYLE_APPLET, 'DHTML', UI_STYLE_DHTML,
                            'JRAD', UI_STYLE_JRAD, 'WEGA', UI_STYLE_WEGA, NULL)
     INTO  v_ui_style
     FROM  dual;
     RETURN v_ui_style;
END;

------------------------------------------------------------------------------------------

FUNCTION ui_type_from_ui_style (ui_style IN VARCHAR2)
RETURN VARCHAR2 IS
  v_ui_type VARCHAR2(30);
BEGIN
     SELECT DECODE(ui_style, UI_STYLE_APPLET, 'APPLET', UI_STYLE_DHTML, 'DHTML',
                             UI_STYLE_JRAD, 'JRAD', UI_STYLE_WEGA, 'WEGA', NULL)
     INTO  v_ui_type
     FROM  dual;
     RETURN v_ui_type;
END;

------------------------------------------------------------------------------------------
FUNCTION NEXT_CONFIG_HDR_ID RETURN INTEGER IS
    ID_to_return INTEGER;
BEGIN
    IF ( (last_hdr_allocated IS NULL)
         OR
         (next_hdr_to_use = (NVL(last_hdr_allocated, 0) + id_increment)) ) THEN
        SELECT cz_config_hdrs_s.NEXTVAL
          INTO last_hdr_allocated
          FROM dual;
        next_hdr_to_use := last_hdr_allocated;
    END IF;
    id_to_return := next_hdr_to_use;
    next_hdr_to_use := next_hdr_to_use + 1;
    RETURN id_to_return;
END ;

--------------------------------------------------------------------------------
FUNCTION get_next_msg_seq RETURN NUMBER
IS
  l_msg_seq  NUMBER;

BEGIN
  IF ((last_msg_seq_allocated IS NULL) OR
      (next_msg_seq_to_use = last_msg_seq_allocated + id_increment)) THEN
    SELECT cz_config_messages_s.NEXTVAL INTO last_msg_seq_allocated FROM dual;
    next_msg_seq_to_use := last_msg_seq_allocated;
  END IF;

  l_msg_seq := next_msg_seq_to_use;
  next_msg_seq_to_use := next_msg_seq_to_use + 1;
  RETURN l_msg_seq;
END get_next_msg_seq;

------------------------------------------------------------------------------------------
-- Note: Returns a message having maiximum length of 1000 chars, i.e., message will be
--       trancated if its length is more than 1000.
FUNCTION retrieve_log_msg(p_run_id  IN NUMBER) RETURN VARCHAR2
IS
  l_msg VARCHAR2(3000) := 'RUN_ID=' || to_char(p_run_id) || ':';

  CURSOR log_msg_csr IS
    SELECT message
    FROM cz_db_logs
    WHERE run_id = p_run_id
    ORDER BY logtime;

BEGIN
  FOR msg_rec IN log_msg_csr LOOP
    l_msg := l_msg || ' ' || msg_rec.message;
    EXIT WHEN (length(l_msg) > 999) OR log_msg_csr%NOTFOUND;
  END LOOP;

  RETURN substr(l_msg, 1, 1000);
END retrieve_log_msg;

------------------------------------------------------------------------------------
PROCEDURE copy_configuration(config_hdr_id       IN      NUMBER,
                             config_rev_nbr      IN      NUMBER,
                             new_config_flag     IN      VARCHAR2,
                             out_config_hdr_id   IN  OUT NOCOPY NUMBER,
                             out_config_rev_nbr  IN  OUT NOCOPY NUMBER,
                             error_message       IN  OUT NOCOPY VARCHAR2,
                             return_value        IN  OUT NOCOPY NUMBER,
                             handle_deleted_flag IN  VARCHAR2 DEFAULT NULL,
                             new_name            IN  VARCHAR2 DEFAULT NULL)
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_copy_mode  VARCHAR2(1);
  l_ret_status VARCHAR2(1);
  l_msg_count  INTEGER;

  l_orig_item_id_tbl  CZ_API_PUB.number_tbl_type;
  l_new_item_id_tbl   CZ_API_PUB.number_tbl_type;
  API_CALL_EXC  EXCEPTION;

BEGIN
  IF ((new_config_flag IS NOT NULL) AND
      (new_config_flag='0')) THEN
    l_copy_mode := CZ_API_PUB.G_NEW_REVISION_COPY_MODE;
  ELSE
    l_copy_mode := CZ_API_PUB.G_NEW_HEADER_COPY_MODE;
  END IF;

  cz_config_api_pub.copy_configuration
                      (l_api_version
                      ,config_hdr_id
                      ,config_rev_nbr
                      ,l_copy_mode
                      ,out_config_hdr_id
                      ,out_config_rev_nbr
                      ,l_orig_item_id_tbl
                      ,l_new_item_id_tbl
                      ,l_ret_status
                      ,l_msg_count
                      ,error_message
                      ,handle_deleted_flag
                      ,new_name
                      );

  IF (l_ret_status = FND_API.G_RET_STS_SUCCESS) THEN
    IF (l_orig_item_id_tbl.count > 0) THEN
       RAISE API_CALL_EXC;
    END IF;
    return_value := 1;
  ELSE
    return_value := 0;
  END IF;

EXCEPTION
  WHEN API_CALL_EXC THEN
    return_value:=0;
    error_message:=CZ_UTILS.GET_TEXT('CZ_INCOMPAT_COPY_CFG');
    -- xERROR:=CZ_UTILS.REPORT(error_message,1,'CZ_CF_API: copy configuration',11276);
    cz_utils.log_report('CZ_CF_API', 'copy_configuration', null,
                         error_message, fnd_log.LEVEL_ERROR);

  WHEN OTHERS THEN
    return_value:=0;
    error_message:=SQLERRM;
    -- xERROR:=CZ_UTILS.REPORT(error_message,1,'CZ_CF_API: copy configuration',11276);
    cz_utils.log_report('CZ_CF_API', 'copy_configuration', null,
                         error_message, fnd_log.LEVEL_UNEXPECTED);
END copy_configuration;

-------------------------------------------------------------------------------------
PROCEDURE copy_configuration_auto(config_hdr_id  IN      NUMBER,
                             config_rev_nbr      IN      NUMBER,
                             new_config_flag     IN      VARCHAR2,
                             out_config_hdr_id   IN  OUT NOCOPY NUMBER,
                             out_config_rev_nbr  IN  OUT NOCOPY NUMBER,
                             Error_message       IN  OUT NOCOPY VARCHAR2,
                             Return_value        IN  OUT NOCOPY NUMBER,
                             handle_deleted_flag IN  VARCHAR2 DEFAULT NULL,
                             new_name            IN  VARCHAR2 DEFAULT NULL)
IS

PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    CZ_CF_API.copy_configuration(config_hdr_id,config_rev_nbr,new_config_flag,out_config_hdr_id,
                        out_config_rev_nbr,Error_message,Return_value,handle_deleted_flag, new_name);
    COMMIT;
END copy_configuration_auto;

------------------------------------------------------------------------------------------
PROCEDURE delete_configuration(config_hdr_id  IN       NUMBER,
                               config_rev_nbr IN       NUMBER,
                               usage_exists   IN   OUT NOCOPY NUMBER,
                               Error_message  IN   OUT NOCOPY VARCHAR2,
                               Return_value   IN   OUT NOCOPY NUMBER)
IS
  in_config_hdr_id  NUMBER := config_hdr_id;
  in_config_rev_nbr NUMBER := config_rev_nbr;
  l_model_instantiation_type  cz_config_hdrs.model_instantiation_type%TYPE;
  l_component_instance_type   cz_config_hdrs.component_instance_type%TYPE;
  l_instance_hdr_id_tbl   number_tbl_indexby_type;
  l_instance_rev_nbr_tbl  number_tbl_indexby_type;
  l_run_id    NUMBER;
  l_ndebug    NUMBER := 0;

  del_ib_config_exc     EXCEPTION;
  ib_exception     EXCEPTION;
  l_active_instances_found NUMBER;
  l_number_of_active_instances NUMBER;
  l_return_revision NUMBER;
  l_ib_error NUMBER;

  TYPE instype_tbl_type IS TABLE OF cz_config_hdrs.component_instance_type%TYPE INDEX BY PLS_INTEGER;
  l_instance_type_tbl  instype_tbl_type;

BEGIN
  Return_value:=1;
  Error_message:='';
  usage_exists:=1;
  l_active_instances_found := 0;
  l_number_of_active_instances := 0;
  l_ib_error := 0;

  SAVEPOINT start_transaction;

  -- input config must be network container or non-network config
  -- i.e., component_instance_type must be 'R'
  BEGIN
    SELECT model_instantiation_type, component_instance_type
      INTO l_model_instantiation_type, l_component_instance_type
    FROM   cz_config_hdrs
    WHERE  config_hdr_id = in_config_hdr_id AND config_rev_nbr = in_config_rev_nbr;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END;

  l_ndebug := 1;
  IF (l_component_instance_type <> ROOT) THEN
    RAISE CONFIG_HDR_TYPE_EXC;
  END IF;

  SELECT instance_hdr_id, instance_rev_nbr, component_instance_type
  BULK COLLECT INTO l_instance_hdr_id_tbl, l_instance_rev_nbr_tbl, l_instance_type_tbl
  FROM cz_config_items
  WHERE config_hdr_id = in_config_hdr_id AND config_rev_nbr = in_config_rev_nbr
    AND deleted_flag = '0'
    AND component_instance_type IN (GENERIC_INSTANCE_ROOT, NETWORK_INSTANCE_ROOT);

  l_ndebug := 2;

  -- lkattamu; bug 5289742; Loop through the config instances
  IF (l_model_instantiation_type = NETWORK AND l_instance_hdr_id_tbl.COUNT > 0) THEN
    FOR i IN l_instance_hdr_id_tbl.FIRST..l_instance_hdr_id_tbl.LAST LOOP
      l_ndebug := 3;
     IF l_instance_type_tbl(i) = NETWORK_INSTANCE_ROOT THEN
      EXECUTE IMMEDIATE
      'DECLARE ' ||
      '  p_install_config_rec csi_cz_int.config_rec; ' ||
      '  p_return_status VARCHAR2(10); ' ||
      '  p_return_message VARCHAR2(2000); ' ||
      '  p_instance_level VARCHAR2(1000); ' ||
      '  api_result NUMBER := 0; ' ||
      '  l_ib_errored NUMBER := 0; ' ||
      'BEGIN ' ||
      '  csi_cz_int.get_configuration_revision ( ' ||
      '    p_config_header_id       => :instance_hdr_id, ' ||
      '    p_target_commitment_date => NULL, ' ||
      '    px_instance_level        => p_instance_level, ' ||
      '    x_install_config_rec     => p_install_config_rec, ' ||
      '    x_return_status          => p_return_status, ' ||
      '    x_return_message         => p_return_message ' ||
      '  ); ' ||
      '  IF (p_return_status <> fnd_api.g_ret_sts_success) THEN ' ||
      '    l_ib_errored := 1; ' ||
      '  ELSE ' ||
      '    IF (p_install_config_rec.config_inst_rev_num IS NULL) THEN ' ||
      '      api_result := 0; ' ||
      '    ELSE ' ||
      '     api_result := 1; ' ||
      '    END IF; ' ||
      '  END IF; ' ||
      '  :result := api_result; ' ||
      '  :l_return_revision := p_install_config_rec.config_inst_rev_num; ' ||
      '  :l_ib_error := l_ib_errored; ' ||
      '  :error_message := p_return_message; ' ||
       'END; '
         USING IN l_instance_hdr_id_tbl(i), OUT l_active_instances_found, OUT l_return_revision, OUT l_ib_error, OUT error_message;
      IF (l_ib_error = 1) THEN
        -- Return to the caller, without processing other instances, when there is an IB exception
        RAISE ib_exception; -- This call just takes control to WHEN OTHERS exception handler
      END IF;
      -- Check if the active instance's revision is same as the revision in the config instance
      IF ((l_active_instances_found = 1) AND (l_instance_rev_nbr_tbl(i) = l_return_revision)) THEN
        l_number_of_active_instances := 1;
        EXIT;
      END IF;
     END IF;
    END LOOP;
  END IF;

  l_ndebug := 4;
  IF (l_number_of_active_instances = 0) THEN
    usage_exists:=0;
    -- No ative instance exists, go ahead and delete
    DELETE FROM CZ_CONFIG_ATTRIBUTES
    WHERE CONFIG_HDR_ID=in_config_hdr_id
      AND CONFIG_REV_NBR=in_config_rev_nbr;

    DELETE FROM CZ_CONFIG_ITEMS
    WHERE CONFIG_HDR_ID=in_config_hdr_id
      AND CONFIG_REV_NBR=in_config_rev_nbr;

    DELETE FROM CZ_CONFIG_INPUTS
    WHERE CONFIG_HDR_ID=in_config_hdr_id
    AND CONFIG_REV_NBR=in_config_rev_nbr;

    DELETE FROM CZ_CONFIG_MESSAGES
    WHERE CONFIG_HDR_ID=in_config_hdr_id
    AND CONFIG_REV_NBR=in_config_rev_nbr;

    l_ndebug := 5;

    IF (l_model_instantiation_type = NETWORK AND l_instance_hdr_id_tbl.COUNT > 0) THEN
      FOR i IN l_instance_hdr_id_tbl.FIRST .. l_instance_hdr_id_tbl.LAST LOOP
        IF l_instance_type_tbl(i) = NETWORK_INSTANCE_ROOT THEN
          DELETE FROM CZ_CONFIG_EXT_ATTRIBUTES
          WHERE CONFIG_HDR_ID = l_instance_hdr_id_tbl(i)
          AND CONFIG_REV_NBR = l_instance_rev_nbr_tbl(i);
        END IF;
      END LOOP;
    END IF;

    l_ndebug := 6;

    l_instance_hdr_id_tbl(l_instance_hdr_id_tbl.COUNT+1) := in_config_hdr_id;
    l_instance_rev_nbr_tbl(l_instance_rev_nbr_tbl.COUNT+1) := in_config_rev_nbr;
    FORALL i IN l_instance_hdr_id_tbl.FIRST .. l_instance_hdr_id_tbl.LAST
      DELETE FROM CZ_CONFIG_HDRS
      WHERE CONFIG_HDR_ID = l_instance_hdr_id_tbl(i)
      AND CONFIG_REV_NBR = l_instance_rev_nbr_tbl(i);

    l_ndebug := 7;

    -- delete ib data if necessary
    cz_ib_transactions.remove_ib_config(p_session_config_hdr_id => in_config_hdr_id
                                       ,p_session_config_rev_nbr => in_config_rev_nbr
                                       ,x_run_id => l_run_id
                                       );
    IF (l_run_id <> 0) THEN
      RAISE del_ib_config_exc;
    END IF;
  ELSE
    -- Mark the configuration session as "To Be Deleted" as few config instances are still active
    UPDATE cz_config_hdrs
    SET    to_be_deleted_flag = '1'
    WHERE  config_hdr_id=in_config_hdr_id and
           config_rev_nbr = in_config_rev_nbr;
  END IF;

EXCEPTION
   WHEN CONFIG_HDR_TYPE_EXC THEN
     Return_value:=0;
     Error_message:=CZ_UTILS.GET_TEXT('CZ_CFG_DEL_HDR_TYPE', 'id', in_config_hdr_id,
                    'revision', in_config_rev_nbr, 'type', l_component_instance_type);
     -- xERROR:=CZ_UTILS.REPORT(Error_message,1,'CZ_CF_API.delete_configuration',11276);
     cz_utils.log_report('CZ_CF_API', 'delete_configuration', l_ndebug, error_message,
                         fnd_log.LEVEL_ERROR);

   WHEN del_ib_config_exc THEN
     Return_value := 0;
     Error_message := retrieve_log_msg(l_run_id);
     ROLLBACK TO start_transaction;
     cz_utils.log_report('CZ_CF_API', 'delete_configuration', l_ndebug, error_message,
                         fnd_log.LEVEL_ERROR);

   WHEN OTHERS THEN
     Return_value:=0;
     IF (error_message IS NOT NULL) THEN
       Error_message := CZ_UTILS.GET_TEXT('CZ_CFG_DEL_ERROR', 'HDRID', in_config_hdr_id, 'REVNBR', in_config_rev_nbr, 'ERRMSG', error_message);
     ELSE
     Error_message := CZ_UTILS.GET_TEXT('CZ_CFG_DEL_ERROR', 'HDRID', in_config_hdr_id, 'REVNBR', in_config_rev_nbr, 'ERRMSG', SQLERRM);
     END IF;
     ROLLBACK TO start_transaction;
     -- xERROR:=CZ_UTILS.REPORT(Error_message,1,'CZ_CF_API.delete_configuration',11276);
     cz_utils.log_report('CZ_CF_API', 'delete_configuration', l_ndebug, error_message, fnd_log.LEVEL_UNEXPECTED);
 END delete_configuration;

------------------------------------------------------------------------------------------
PROCEDURE delete_configuration_usage(calling_application_id      IN  NUMBER,
                                     calling_application_ref_key IN  NUMBER,
                                     Error_message               IN OUT NOCOPY VARCHAR2,
                                     Return_value                IN OUT NOCOPY NUMBER)
IS
 in_calling_application_id      NUMBER:=calling_application_id;
 in_calling_application_ref_key NUMBER:=calling_application_ref_key;

BEGIN
  Return_value:=1;
  Error_message:='';
  SAVEPOINT start_transaction;
  DELETE FROM CZ_CONFIG_USAGES WHERE CALLING_APPLICATION_ID=in_calling_application_id AND
  CALLING_APPLICATION_REF_KEY=in_calling_application_ref_key;
EXCEPTION
  WHEN OTHERS THEN
    Return_value:=0;
    Error_message:=SQLERRM;
    ROLLBACK TO start_transaction;
    -- xERROR:=CZ_UTILS.REPORT(Error_message,1,'CZ_CF_API: delete configuration usage',11276);
    cz_utils.log_report('CZ_CF_API', 'delete_configuration_usage', 1, error_message,
                         fnd_log.LEVEL_UNEXPECTED);
END delete_configuration_usage;
------------------------------------------------------------------------------------------
PROCEDURE update_configuration_usage(calling_application_id      IN  NUMBER,
                                     calling_application_ref_key IN  NUMBER,
                                     config_hdr_id               IN  NUMBER,
                                     config_rev_nbr              IN  NUMBER,
                                     config_item_id              IN  NUMBER,
                                     uom_code                    IN  VARCHAR2,
                                     list_price                  IN  NUMBER,
                                     discounted_price            IN  NUMBER,
                                     auto_discount_id            IN  NUMBER,
                                     auto_discount_line_id       IN  NUMBER,
                                     auto_discount_pct           IN  NUMBER,
                                     manual_discount_id          IN  NUMBER,
                                     manual_discount_line_id     IN  NUMBER,
                                     manual_discount_pct         IN  NUMBER,
                                     Error_message               IN OUT NOCOPY VARCHAR2,
                                     Return_value                IN OUT NOCOPY NUMBER)

IS
  in_calling_application_id      NUMBER:=calling_application_id;
  in_calling_application_ref_key NUMBER:=calling_application_ref_key;
  in_config_hdr_id               NUMBER:=config_hdr_id;
  in_config_rev_nbr              NUMBER:=config_rev_nbr;
  in_config_item_id              NUMBER:=config_item_id;
  in_uom_code                    VARCHAR2(3):=uom_code;
  in_list_price                  NUMBER:=list_price;
  in_discounted_price            NUMBER:=discounted_price;
  in_auto_discount_id            NUMBER:=auto_discount_id;
  in_auto_discount_line_id       NUMBER:=auto_discount_line_id;
  in_auto_discount_pct           NUMBER:=auto_discount_pct;
  in_manual_discount_id          NUMBER:=manual_discount_id;
  in_manual_discount_line_id     NUMBER:=manual_discount_line_id;
  in_manual_discount_pct         NUMBER:=manual_discount_pct;

BEGIN
  Return_value:=1;
  Error_message:='';
  SAVEPOINT start_transaction;
  UPDATE CZ_CONFIG_USAGES SET
     LIST_PRICE=in_list_price,
     AUTO_DISCOUNT_ID=in_auto_discount_id,
     AUTO_DISCOUNT_LINE_ID=in_auto_discount_line_id,
     AUTO_DISCOUNT_PCT=in_auto_discount_pct,
     MANUAL_DISCOUNT_ID=in_manual_discount_id,
     MANUAL_DISCOUNT_LINE_ID=in_manual_discount_line_id,
     MANUAL_DISCOUNT_PCT=in_manual_discount_pct,
     DISCOUNTED_PRICE=in_discounted_price,
     UOM_CODE=in_uom_code
WHERE
     CALLING_APPLICATION_ID=in_calling_application_id AND
     CALLING_APPLICATION_REF_KEY=in_calling_application_ref_key AND
     CONFIG_HDR_ID=in_config_hdr_id AND
     CONFIG_REV_NBR=in_config_rev_nbr AND
     CONFIG_ITEM_ID=in_config_item_id;
EXCEPTION
  WHEN OTHERS THEN
    Return_value:=0;
    Error_message:=SQLERRM;
    ROLLBACK TO start_transaction;
    -- xERROR:=CZ_UTILS.REPORT(Error_message,1,'CZ_CF_API: update configuration usage',11276);
    cz_utils.log_report('CZ_CF_API', 'update_configuration_usage', 1, error_message,
                         fnd_log.LEVEL_UNEXPECTED);
END update_configuration_usage;
------------------------------------------------------------------------------------------
PROCEDURE  get_config_hdr(p_xml_string       IN VARCHAR2,
                		  p_config_header_id IN OUT NOCOPY NUMBER,
                  	  p_config_rev_nbr IN OUT NOCOPY   NUMBER)
AS

v_search_string		VARCHAR2(200) :=  'config_header_id';
v_occurence_position    NUMBER	  :=  0;
v_pattern_found		VARCHAR2(5)	  :=  'FALSE';
v_occurence_number	NUMBER	  :=  1;
l_hdr_str               VARCHAR2(30);
l_rev_str               VARCHAR2(30);

BEGIN
	WHILE ( INSTR(v_pattern_found,'FALSE') > 0)
	LOOP
    		v_occurence_position    :=  INSTR(p_xml_string,v_search_string,1,v_occurence_number);
                IF v_occurence_position = 0 THEN
                  p_config_header_id := 0;
                  p_config_rev_nbr := 0;
                  RETURN;
                END IF;
    		v_occurence_position    :=  v_occurence_position+16;

		v_pattern_found := 'TRUE';
	    	while((ASCII(SUBSTR(p_xml_string,v_occurence_position,1))<48) OR (ASCII(SUBSTR(p_xml_string,v_occurence_position,1))>57))
    		LOOP
			IF( NOT((ASCII(SUBSTR(p_xml_string,v_occurence_position,1))=32) OR (ASCII(SUBSTR(p_xml_string,v_occurence_position,1))=34) OR (ASCII(SUBSTR(p_xml_string,v_occurence_position,1))=62))) THEN
				v_pattern_found := 'FALSE';
				EXIT;
			END IF;
    			v_occurence_position  := v_occurence_position+1;
	        END LOOP;
		v_occurence_number	:=	v_occurence_number+1;
	END LOOP;

	l_hdr_str        := '';
	while((ASCII(SUBSTR(p_xml_string,v_occurence_position,1))>47) AND (ASCII(SUBSTR(p_xml_string,v_occurence_position,1))<58))
	LOOP
		l_hdr_str      := l_hdr_str||SUBSTR(p_xml_string,v_occurence_position,1);
	    	v_occurence_position  := v_occurence_position+1;
	END LOOP;

	v_pattern_found		:= 'FALSE';
	v_search_string         := 'config_rev_nbr';
	v_occurence_number	:= 1;

	WHILE ( INSTR(v_pattern_found,'FALSE') > 0)
	LOOP
    		v_occurence_position    :=  INSTR(p_xml_string,v_search_string,1,v_occurence_number);
                IF v_occurence_position = 0 THEN
                  p_config_header_id := 0;
                  p_config_rev_nbr := 0;
                  RETURN;
                END IF;
    		v_occurence_position    :=  v_occurence_position+15;

		v_pattern_found := 'TRUE';
	    	while((ASCII(SUBSTR(p_xml_string,v_occurence_position,1))<48) OR (ASCII(SUBSTR(p_xml_string,v_occurence_position,1))>57))
    		LOOP
			IF( NOT((ASCII(SUBSTR(p_xml_string,v_occurence_position,1))=32) OR (ASCII(SUBSTR(p_xml_string,v_occurence_position,1))=34) OR (ASCII(SUBSTR(p_xml_string,v_occurence_position,1))=62))) THEN
				v_pattern_found := 'FALSE';
				EXIT;
			END IF;
    			v_occurence_position  := v_occurence_position+1;
	      END LOOP;
		v_occurence_number	:=	v_occurence_number+1;
	END LOOP;


	l_rev_str        := '';
	while((ASCII(SUBSTR(p_xml_string,v_occurence_position,1))>47) AND (ASCII(SUBSTR(p_xml_string,v_occurence_position,1))<58))
	LOOP
		l_rev_str      := l_rev_str||SUBSTR(p_xml_string,v_occurence_position,1);
	    	v_occurence_position  := v_occurence_position+1;
	END LOOP;

	p_config_header_id := to_number(l_hdr_str);
        p_config_rev_nbr   := to_number(l_rev_str);
EXCEPTION
WHEN OTHERS THEN
    p_config_header_id := 0;
    p_config_rev_nbr   := 0;
END get_config_hdr;
------------------------------------------------------------
PROCEDURE append_instance_nbr(p_node_identifier IN VARCHAR2,
                              x_node_identifier OUT NOCOPY VARCHAR2,
                              x_item_depth OUT NOCOPY NUMBER)
IS
  l_instr INTEGER;
  l_count PLS_INTEGER;
  l_str   cz_config_items.node_identifier%TYPE;
  l_ecc   cz_config_items.node_identifier%TYPE;

BEGIN
  l_count := 1;
  l_ecc := '';
  l_str := p_node_identifier;
  l_instr := INSTR(l_str,'-') - 1;
  WHILE l_instr > 0 LOOP
    l_ecc := l_ecc||SUBSTR(l_str,1,l_instr)||'|1-';
    l_str := SUBSTR(l_str,l_instr+2);
    l_instr := INSTR(l_str,'-') - 1;
    l_count := l_count + 1;
  END LOOP;
  x_node_identifier := l_ecc||l_str||'|1';
  x_item_depth := l_count;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END append_instance_nbr;

--------------------------------------------------------------------------------
PROCEDURE get_ext_comp_code(p_config_hdr_id  IN NUMBER
                           ,p_config_rev_nbr IN NUMBER
                           ,p_config_item_id IN NUMBER
                           ,x_ecc_code   OUT NOCOPY VARCHAR2
                           ,x_item_depth OUT NOCOPY NUMBER)
IS
  l_ecc                cz_config_items.node_identifier%TYPE;
  l_inventory_item_id  NUMBER;
  l_instance_nbr       NUMBER;
  l_depth              PLS_INTEGER;
  CURSOR ecc_cur(p_config_item_id NUMBER) IS
    SELECT  inventory_item_id, instance_nbr
    FROM    cz_config_items
    WHERE   deleted_flag = '0'
    AND     inventory_item_id IS NOT NULL
    AND     config_hdr_id =  p_config_hdr_id
    AND     config_rev_nbr = p_config_rev_nbr
    START WITH config_hdr_id = p_config_hdr_id and config_rev_nbr = p_config_rev_nbr and config_item_id = p_config_item_id
    CONNECT BY PRIOR parent_config_item_id = config_item_id and config_hdr_id = p_config_hdr_id and config_rev_nbr = p_config_rev_nbr
    ORDER BY ROWNUM DESC;
BEGIN
  l_ecc := '';
  l_depth := 0;
  OPEN ecc_cur(p_config_item_id);
  LOOP
    FETCH ecc_cur INTO  l_inventory_item_id,l_instance_nbr;
    EXIT WHEN ecc_cur%NOTFOUND;
    SELECT decode(l_instance_nbr, -1,1,0,1,l_instance_nbr) into l_instance_nbr from dual;
    l_ecc   := l_ecc||l_inventory_item_id||'|'||nvl(l_instance_nbr,1)||'-';
    l_depth := l_depth + 1;
  END LOOP;
  CLOSE ecc_cur;
  l_ecc := RTRIM(l_ecc, '-');
  x_ecc_code := l_ecc;
  x_item_depth := l_depth;
EXCEPTION
  WHEN OTHERS THEN
    CLOSE ecc_cur;
    RAISE;
END get_ext_comp_code;

------------------------------------------------------
------procedure that parses the output terminate message for the output
------header,revision and config status
PROCEDURE  parse_output_xml  (p_xml			   	   IN  LONG,
			            x_valid_config       	   OUT NOCOPY VARCHAR2,
			            x_complete_config    	   OUT NOCOPY VARCHAR2,
					x_config_header_id   	   OUT NOCOPY NUMBER,
					x_config_rev_nbr     	   OUT NOCOPY NUMBER,
					x_return_status      	   OUT NOCOPY VARCHAR2,
				      x_error_message		   OUT NOCOPY VARCHAR2)
IS

l_valid_config_start_tag 	VARCHAR2(30) := '<VALID_CONFIGURATION>';
l_valid_config_end_tag   	VARCHAR2(30) := '</VALID_CONFIGURATION>';
l_valid_config_start_pos      NUMBER;
l_valid_config_end_pos        NUMBER;
l_complete_config_start_tag   VARCHAR2(30) := '<COMPLETE_CONFIGURATION>';
l_complete_config_end_tag     VARCHAR2(30) := '</COMPLETE_CONFIGURATION>';
l_complete_config_start_pos   NUMBER;
l_complete_config_end_pos     NUMBER;
l_config_header_id_start_tag  VARCHAR2(20) := '<CONFIG_HEADER_ID>';
l_config_header_id_end_tag    VARCHAR2(20) := '</CONFIG_HEADER_ID>';
l_config_header_id_start_pos  NUMBER;
l_config_header_id_end_pos    NUMBER;
l_config_rev_nbr_start_tag    VARCHAR2(20) := '<CONFIG_REV_NBR>';
l_config_rev_nbr_end_tag      VARCHAR2(20) := '</CONFIG_REV_NBR>';
l_config_rev_nbr_start_pos    NUMBER;
l_config_rev_nbr_end_pos      NUMBER;
l_config_header_id            NUMBER;
l_config_rev_nbr              NUMBER;
l_valid_config                VARCHAR2(10);
l_complete_config             VARCHAR2(10);
l_header_id                   NUMBER;
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN
  l_valid_config_start_pos    := INSTR(UPPER(p_xml),l_valid_config_start_tag,1, 1)
						 + length(l_valid_config_start_tag);
  l_valid_config_end_pos      := INSTR(UPPER(p_xml), l_valid_config_end_tag,1, 1) - 1;
  l_valid_config  	      := SUBSTR(p_xml,l_valid_config_start_pos,
						   l_valid_config_end_pos - l_valid_config_start_pos + 1);
  l_complete_config_start_pos := INSTR(UPPER(p_xml),
						   l_complete_config_start_tag,1, 1) + length(l_complete_config_start_tag);
  l_complete_config_end_pos   := INSTR(UPPER(p_xml), l_complete_config_end_tag,1, 1) - 1;
  l_complete_config 	      := SUBSTR( p_xml, l_complete_config_start_pos,
						   l_complete_config_end_pos - l_complete_config_start_pos + 1);

  -- get the latest config_header_id, and rev_nbr
  l_config_header_id_start_pos := INSTR(UPPER(p_xml),
					    l_config_header_id_start_tag, 1, 1)
					    + length(l_config_header_id_start_tag);
  l_config_header_id_end_pos   := INSTR(UPPER(p_xml), l_config_header_id_end_tag, 1, 1) - 1;
  l_config_header_id 	       := to_number(SUBSTR(p_xml,l_config_header_id_start_pos,
					    l_config_header_id_end_pos - l_config_header_id_start_pos + 1));
  l_config_rev_nbr_start_pos   := INSTR(UPPER(p_xml), l_config_rev_nbr_start_tag, 1, 1)
					    + length(l_config_rev_nbr_start_tag);
  l_config_rev_nbr_end_pos     := INSTR(UPPER(p_xml), l_config_rev_nbr_end_tag, 1, 1) - 1;
  l_config_rev_nbr 		 := to_number(SUBSTR(p_xml,l_config_rev_nbr_start_pos,
					    l_config_rev_nbr_end_pos - l_config_rev_nbr_start_pos + 1));

  x_return_status    := l_return_status;
  x_config_header_id := l_config_header_id;
  x_config_rev_nbr   := l_config_rev_nbr;
  x_complete_config  := nvl(l_complete_config, 'FALSE');
  x_valid_config     := nvl(l_valid_config, 'FALSE');

EXCEPTION
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_error_message := SQLERRM;
END Parse_output_xml;
-------------------------------------------------------------------
-------procedure that checks if the passed in init message
-------has a save config behaviour as new_revision.
-------if it is new_revision x_param_flag is set to 'YES'
PROCEDURE check_if_new_revision(p_init_message  IN VARCHAR2,
			 		  x_param_flag    IN OUT NOCOPY VARCHAR2)
IS

l_new_rev_tag VARCHAR2(20)  := 'new_revision';
l_save_rev_tag VARCHAR2(30) := 'save_config_behavior';
l_new_rev_instr          NUMBER := 0;
l_save_config_instr      NUMBER := 0;

BEGIN
    x_param_flag := 'YES';
    IF (p_init_message IS NOT NULL) THEN
      ------check if 'save_config_behavior' tag exists
	l_save_config_instr := INSTR(p_init_message,l_save_rev_tag);
	----if it does not exist, then default is new revision
      ----if it exists then check for new_revision
      IF (l_save_config_instr = 0) THEN
		x_param_flag := 'YES';
	ELSE
    	     l_new_rev_instr := INSTR(p_init_message,l_new_rev_tag);
    	     IF (l_new_rev_instr = 0) THEN
			x_param_flag := 'NO';
    	     END IF;
      END IF;
    END IF;
END check_if_new_revision;

-----------------------------------------------
------Procedure that retrieves description and item name
------from mtl_system_items_kfv for an inventory_item_id and organization_id
PROCEDURE get_item_description_and_name (p_inventory_item_id IN mtl_system_items.inventory_item_id%TYPE,
						     p_organization_id   IN mtl_system_items.organization_id%TYPE,
						     x_description OUT NOCOPY mtl_system_items_kfv.description%TYPE,
						     x_item_name   OUT NOCOPY mtl_system_items_kfv.concatenated_segments%TYPE)
IS

BEGIN
	----get description,itemname from mtl_system_items
	SELECT description,concatenated_segments
	INTO   x_description,x_item_name
	FROM   mtl_system_items_kfv
	WHERE  mtl_system_items_kfv.inventory_item_id = p_inventory_item_id
	AND    mtl_system_items_kfv.organization_id = p_organization_id;
END;

--------------------------------------------------
------procedure that logs a delta message to
------cz_config_messages
PROCEDURE log_delta_message (p_inventory_item_id IN mtl_system_items.inventory_item_id%TYPE,
				     p_organization_id   IN mtl_system_items.organization_id%TYPE  ,
				     p_component_code    IN cz_config_details_v.component_code%TYPE,
				     p_current_quantity  IN NUMBER,
				     p_new_quantity      IN NUMBER,
				     p_config_hdr		 IN NUMBER,
				     p_config_rev        IN NUMBER,
				     p_message_name      IN fnd_new_messages.message_name%TYPE)

IS

l_description        mtl_system_items_kfv.description%TYPE;
l_new_item_name	   mtl_system_items_kfv.concatenated_segments%TYPE;
v_OracleSequenceIncr NUMBER := 20;
l_msg_seq		   NUMBER := 0;
l_delta_message	   VARCHAR2(2000);

BEGIN
	----get description,itemname from mtl_system_items
      get_item_description_and_name (p_inventory_item_id,
						 p_organization_id,
						 l_description,
						 l_new_item_name);
      l_msg_seq := get_next_msg_seq;

	IF ( (p_message_name = ITEM_DELETE_MESSAGE) OR (p_message_name = ITEM_ADD_MESSAGE ) )  THEN
		l_delta_message := CZ_UTILS.GET_TEXT(p_message_name,
							'ITEMNAME',l_new_item_name,
    				 			'QUANTITY',p_current_quantity,
							'COMPONENTCODE',p_component_code,
							'DESCRIPTION',l_description);
      ELSIF (p_message_name = QTY_CHANGE_MESSAGE ) THEN
		l_delta_message := CZ_UTILS.GET_TEXT(p_message_name,
								 'ITEMNAME',l_new_item_name,
		  	    					  'CURRENT_QUANTITY',p_current_quantity,
								  'NEW_QUANTITY',p_new_quantity,
								  'COMPONENTCODE',p_component_code,
								  'DESCRIPTION',l_description );
	END IF;

      insert into cz_config_messages (config_hdr_id,config_rev_nbr,constraint_type,
						  message,message_seq,deleted_flag)
	values (p_config_hdr,p_config_rev,'ITEM DELTA',l_delta_message,l_msg_seq, '0');
END;

----------------------------------------------------------------------------------------------
-----  changes for batch validation failure processing
-----  this block would set the validation status to fail if
----- the config_input_list is empty and validation_status is CONFIG_PROCESSED
------ and if there are configured item changes
------ The changes are logged to cz_config_messages
------@p_config_input_list input list passed to validate proc
------@p_validation_status --- validation status after BV
------@p_init_message --- init message passed by calling application
------@x_config_messages OUTPUT config_messages
------@x_return_status -- validation status is set to 4 if deltas exist
------ Quoting ER #9348864 implementation ---------------------------------------------------
------@p_check_config_flag passed from caller VALIDATE Proc. Valid value : 'Y'
------@x_return_config_changed will be passed to the caller VALIDATE Proc.
------ Valid values: 'Y' (Changed) and 'N' (Not Changed) when p_check_config_passed. NULL when check flag not passed.
------ For any existing VALIDATE API, IN param is hard coded to 'N' and OUT param is overwritten to NULL
------ Also we will not have any check for new OUT param for any VALIDATE API other than the new Quoting specific API.
----------------------------------------------------------------------------------------------
PROCEDURE check_deltas(    p_init_message      IN VARCHAR2,
                           p_check_config_flag IN VARCHAR2 DEFAULT 'N',
		           x_config_messages   IN OUT NOCOPY CFG_OUTPUT_PIECES,
		           x_return_status	 IN OUT NOCOPY VARCHAR2,
                           x_return_config_changed OUT NOCOPY VARCHAR2)
IS

v_header_id			cz_config_hdrs.config_hdr_id%TYPE;
v_rev_nbr			cz_config_hdrs.config_rev_nbr%TYPE;
v_output_cfg_hdr_id	cz_config_hdrs.config_hdr_id%TYPE  := 0;
v_output_cfg_rev_nbr	cz_config_hdrs.config_rev_nbr%TYPE := 0;
l_prev_item             cz_config_items.config_item_id%TYPE := 0;
l_prev_rev			cz_config_hdrs.config_rev_nbr%TYPE;
l_prev_qty			NUMBER := 0;
l_description 		mtl_system_items.description%TYPE;
l_new_item              cz_config_items.config_item_id%TYPE:= 0;
l_new_rev			cz_config_hdrs.config_rev_nbr%TYPE := 0;
l_new_component_code	cz_config_details_v.component_code%TYPE;
l_new_qty			NUMBER := 0;
l_new_inventory_item_id mtl_system_items.inventory_item_id%TYPE;
l_new_organization_id   mtl_system_items.organization_id%TYPE;
v_valid_config          VARCHAR2(30);
v_complete_config       VARCHAR2(30);
v_parse_status		VARCHAR2(1);
l_param_value   		VARCHAR2(3);
v_xml_str			LONG := NULL;
l_config_err_msg		VARCHAR2(2000);
PARSE_XML_ERROR		EXCEPTION;
NO_INPUT_HDR_EXCEP	EXCEPTION;
l_new_item_name		cz_config_items.name%TYPE;
l_bv_profile		VARCHAR2(100);
v_parse_message		VARCHAR2(2000);
l_len				NUMBER := 2000;
l_delta_exists	      VARCHAR2(3) := 'NO';
l_qty_changed		BOOLEAN := FALSE;
l_prev_count 		NUMBER := 0;
l_config_true_tag 	VARCHAR2(30) := '<valid_configuration>true';
l_config_false_tag   	VARCHAR2(30) := '<valid_configuration>false';
l_prev_inventory_item_id mtl_system_items.inventory_item_id%TYPE;
l_prev_organization_id   mtl_system_items.organization_id%TYPE;
l_prev_component_code	 cz_config_details_v.component_code%TYPE;

CURSOR c_config_delta (p_old_hdr NUMBER,p_old_rev NUMBER,p_new_hdr NUMBER,p_new_rev NUMBER)
			IS select config_rev_nbr,config_item_id,quantity,
				    component_code,inventory_item_id,organization_id
			   from cz_config_details_v
			   where (config_hdr_id,config_item_id,quantity)
					 IN (
					    (select config_hdr_id,config_item_id,quantity from cz_config_details_v
     						where config_hdr_id = p_old_hdr and config_rev_nbr = p_old_rev
   					     minus
   					    select config_hdr_id,config_item_id,quantity from cz_config_details_v
   					    where config_hdr_id = p_new_hdr and  config_rev_nbr = p_new_rev )
  					    union
   					  (select config_hdr_id,config_item_id,quantity from cz_config_details_v
   					   where  config_hdr_id = p_new_hdr  and config_rev_nbr = p_new_rev
   					   minus
  					   select config_hdr_id,config_item_id,quantity from cz_config_details_v
  					   where config_hdr_id = p_old_hdr  and  config_rev_nbr = p_old_rev )
					   )
			  and config_rev_nbr IN (p_old_rev, p_new_rev)
			  ORDER BY config_item_id,config_hdr_id,config_rev_nbr;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     FOR I IN 1..1
     LOOP

	----check profile setting
------  Quoting ER #9348864. Even if profile value is N, calculate delta if
--------the new IN param p_check_config_flag = Y (Making this ER implementation independent of this profile value)
	l_bv_profile := FND_PROFILE.VALUE('CZ_BV_DELTA');

	IF (NVL(UPPER(l_bv_profile), 'N') = 'N' AND NVL(UPPER(p_check_config_flag),'N') = 'N') THEN
		EXIT;
	END IF;

	-----check if the init message contains the parameter
	-----save_config_behavior = new revision
	check_if_new_revision(p_init_message,l_param_value);

      IF (l_param_value <> 'YES') THEN
		EXIT;
	END IF;

	-----get previous config_hdr_id and config_rev_nbr
	get_config_hdr(p_init_message,v_header_id,v_rev_nbr);

      -----if the init message does not contain input header
      -----then no need to compute deltas and check_delta must return a
      -----status of SUCCESS
      IF (v_header_id = 0) THEN
	    RAISE NO_INPUT_HDR_EXCEP;
	END IF;

	------get new config_hdr_id and revision
 	IF (x_config_messages.COUNT > 0) THEN
	   FOR xmlStr IN x_config_messages.FIRST..x_config_messages.LAST
	   LOOP
		v_xml_str := v_xml_str||x_config_messages(xmlStr);
	   END LOOP;
      END IF;

	parse_output_xml (v_xml_str	 	,
	 	         v_valid_config		,
			   v_complete_config	,
		         v_output_cfg_hdr_id	,
		         v_output_cfg_rev_nbr	,
		         v_parse_status	      ,
			   v_parse_message)	;

	----if error in parsing xml raise an exception
	IF (v_parse_status <> FND_API.G_RET_STS_SUCCESS) THEN
		RAISE PARSE_XML_ERROR;
	END IF;

	IF (UPPER(v_valid_config) NOT IN ('TRUE', 'Y')) THEN
		EXIT;
	END IF;

 	OPEN c_config_delta (v_header_id,v_rev_nbr,v_output_cfg_hdr_id,v_output_cfg_rev_nbr);
	LOOP
	    FETCH c_config_delta INTO l_new_rev,l_new_item,l_new_qty,l_new_component_code,
						l_new_inventory_item_id,l_new_organization_id;
	    EXIT WHEN(c_config_delta%NOTFOUND);

	    IF ( l_qty_changed = FALSE ) THEN

		 IF ( (l_prev_item <> 0) AND (l_prev_item <> l_new_item) ) THEN

		 	IF (l_prev_rev = v_rev_nbr) THEN
				--item deleted
				l_delta_exists  := 'YES';

				log_delta_message (l_prev_inventory_item_id,
				     			 l_prev_organization_id,
				     			 l_prev_component_code,
				     			 l_prev_qty,
				     			 NULL,
				     			 v_output_cfg_hdr_id,
				     			 v_output_cfg_rev_nbr,
				     			ITEM_DELETE_MESSAGE);

			ELSIF (l_prev_rev = v_output_cfg_rev_nbr) THEN
				--- item added
				l_delta_exists  := 'YES';

				log_delta_message (l_prev_inventory_item_id,
				     			 l_prev_organization_id,
				     			 l_prev_component_code,
				     			 l_prev_qty,
				     			 NULL,
				     			 v_output_cfg_hdr_id,
				     			 v_output_cfg_rev_nbr,
				     	            ITEM_ADD_MESSAGE);

			END IF;

		 ELSIF (l_prev_item = l_new_item) THEN
			---qty changed
			l_qty_changed  := TRUE;
			l_delta_exists := 'YES';

			log_delta_message (l_prev_inventory_item_id,
			     			 l_prev_organization_id,
			     			 l_new_component_code,
			     			 l_prev_qty,
			     			 l_new_qty,
			     			 v_output_cfg_hdr_id,
			     			 v_output_cfg_rev_nbr,
			     	             QTY_CHANGE_MESSAGE );
 		 END IF;

	    ELSE
		  l_qty_changed := FALSE;
	    END IF;
	    l_prev_item := l_new_item; l_prev_rev := l_new_rev; l_prev_qty := l_new_qty;
          l_prev_inventory_item_id := l_new_inventory_item_id; l_prev_organization_id   := l_new_organization_id;
          l_prev_component_code    := l_new_component_code;
	END LOOP;
	CLOSE c_config_delta ;

	----this block of code process the last record if add or delete item
	IF ( l_qty_changed = FALSE ) THEN
		IF (l_new_rev = v_rev_nbr) THEN
				--item deleted
				l_delta_exists  := 'YES';

				log_delta_message (l_prev_inventory_item_id,
				     			 l_prev_organization_id,
				     			 l_prev_component_code,
				     			 l_prev_qty,
				     			 NULL,
				     			 v_output_cfg_hdr_id,
				     			 v_output_cfg_rev_nbr,
				     			ITEM_DELETE_MESSAGE);
		ELSIF (l_new_rev = v_output_cfg_rev_nbr) THEN
				--- item added
				l_delta_exists  := 'YES';

				log_delta_message (l_prev_inventory_item_id,
				     			 l_prev_organization_id,
				     			 l_prev_component_code,
				     			 l_prev_qty,
				     			 NULL,
				     			 v_output_cfg_hdr_id,
				     			 v_output_cfg_rev_nbr,
				     	            ITEM_ADD_MESSAGE);
		END IF;
	END IF;

---Quting ER. Initializing the x_return_config_changed flag to N only when the p_check_config_flag is pass to 'Y'.
--- This retunr flag will be reassigned to Y below when there is change in config.
--- If p_check_config_flag is not passed by caller then x_return_config_flag will be NULL

        IF UPPER(p_check_config_flag) = 'Y' THEN
           x_return_config_changed := 'N';
        END IF;

	IF (l_delta_exists = 'YES') THEN
          IF  (NVL(UPPER(p_check_config_flag),'N') = 'N') THEN
 	      v_xml_str := REPLACE(v_xml_str,l_config_true_tag,l_config_false_tag);
          ELSE
              x_return_config_changed := 'Y';
          END IF;
	   x_config_messages.DELETE;
	   FOR I IN 1..LENGTH(v_xml_str)
	   LOOP
--Bug9562050- Need to Check NULL length and convert to 0, else LOOP will continue unnesssarily
		EXIT WHEN NVL(LENGTH(v_xml_str),0)  = 0;
		IF (LENGTH(v_xml_str) <= 2000) THEN
		   l_len := LENGTH(v_xml_str);
		ELSE
		   l_len := 2000;
		END IF;
		x_config_messages(i) := substr(v_xml_str,1,l_len);
	      v_xml_str := substr(v_xml_str,l_len + 1);
	   END LOOP;
      END IF;
   END LOOP;
   COMMIT;
EXCEPTION
WHEN NO_INPUT_HDR_EXCEP THEN
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
WHEN PARSE_XML_ERROR THEN
    ROLLBACK;
    -- l_report_status := CZ_UTILS.REPORT (v_parse_message,1,'ITEM DELTA',1);
    cz_utils.log_report('CZ_CF_API', 'check_deltas', null, v_parse_message,
                         fnd_log.LEVEL_ERROR);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    ROLLBACK;
    l_config_err_msg := SQLERRM;
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    -- l_report_status := CZ_UTILS.REPORT (l_config_err_msg,1,'ITEM DELTA',1);
    cz_utils.log_report('CZ_CF_API', 'check_deltas', null, l_config_err_msg,
                         fnd_log.LEVEL_UNEXPECTED);
END check_deltas;
-------------------------------------------------------------------------
FUNCTION batchurlencode(p_str varchar2)
RETURN VARCHAR2
IS

l_tmp varchar2(100);
l_hex varchar2(16) default '0123456789ABCDEF';
l_num number;
l_bad varchar2(100) default ' >%}\~];?@&<#{|^[`/:=$+''"'; l_char char(1);

begin

IF (p_str is null) THEN
	return null;
END IF;

FOR I IN 1 .. length(p_str)
LOOP
 l_char := substr(p_str, i, 1);
	IF (instr(l_bad, l_char) ) > 0 THEN
	   l_num := ascii(l_char);
	   l_tmp := l_tmp || '%' || substr(l_hex, mod(trunc (l_num / 16), 16) + 1, 1)
			|| substr(l_hex, mod(l_num, 16) + 1, 1); else l_tmp := l_tmp || l_char;
	END IF;
END LOOP;

RETURN l_tmp;

end;

-----------------------------------------
-----This procedure is used as a workaround for bug# 2687938 which is
-----utl_http_request_failed error from network API during batch validation
------although the logs show that the validation was successful

-------Changes to this procedure is made for SSL implementation
-------Changes are implemented as suggested in bug# 3594440, 3785732,3785687

PROCEDURE return_html_pieces(FinalURL IN  VARCHAR2, pool_identifier IN VARCHAR2,
       config_messages IN OUT NOCOPY CFG_OUTPUT_PIECES)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_ssl_profile_option VARCHAR2(2000);          ----SSL profile option value, if ssl then 'https'
l_wallet_path        VARCHAR2(2000);          ----directory path of the wallet
l_wallet_passwd      VARCHAR2(2000) := NULL;  ---- password is not necessary for the default wallet
l_cookies        UTL_HTTP.COOKIE_TABLE;
l_cookie         UTL_HTTP.COOKIE;
l_start_index NUMBER;
l_end_index NUMBER;

BEGIN
  l_ssl_profile_option := FND_PROFILE.VALUE('APPS_SERVLET_AGENT');
  l_wallet_path        := FND_PROFILE.VALUE('FND_DB_WALLET_DIR');
  l_wallet_path        := 'file:'||l_wallet_path ;

  IF (transferTimeout IS NOT NULL AND defaultTimeout IS NOT NULL) THEN
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.SET_TRANSFER_TIMEOUT(:1); END;' USING IN transferTimeout;
  END IF;
      IF(UPPER(TRIM(FND_PROFILE.VALUE('CZ_ADD_MODEL_ROUTING_COOKIE'))) LIKE 'Y%') THEN
        IF pool_identifier IS NULL THEN
          RAISE MODEL_POOL_EFFINITY_EXC;
        END IF;
        l_start_index := INSTR(FinalURL, '//');
        l_end_index := INSTR(FinalURL, '/', l_start_index+2);
	l_cookie.domain :=SUBSTR(FinalURL, l_start_index+2,  l_end_index - (l_start_index+2));
	IF INSTR(l_cookie.domain, ':') > 0 THEN
	 l_cookie.domain := SUBSTR(l_cookie.domain, 1, INSTR(l_cookie.domain, ':')-1);
	END IF;
	l_start_index := l_end_index;
	l_end_index := INSTR(FinalURL, '/', l_start_index+1);
	l_cookie.path := SUBSTR(FinalURL, l_start_index, l_end_index-l_start_index);
	UTL_HTTP.GET_COOKIES(l_cookies);
	l_cookie.name   := 'czPoolToken';
	l_cookie.value   := pool_identifier;
	l_cookie.expire := SYSDATE+99999;
	--l_cookie.path :='/OA_HTML';
	IF (UPPER(TRIM(FinalURL)) LIKE ('HTTPS%')) THEN
		l_cookie.secure := TRUE;
	ELSE
		l_cookie.secure := FALSE;
	END IF;
	l_cookie.version := 1;
	l_cookies(l_cookies.count+1) := l_cookie;
	utl_http.clear_cookies;
	utl_http.add_cookies(l_cookies);
      END IF;
      --vsingava 14 Jul '09 bug7674190
      -----if the FinalURL is SSL then
  -----pass in the wallet path and wallet passwd
  -----otherwise pass in the URL only
      IF (UPPER(TRIM(FinalURL)) LIKE ('HTTPS%')) THEN
    config_messages := UTL_HTTP.request_pieces(url => FinalURL,
                   wallet_path     => l_wallet_path,
                   wallet_password => l_wallet_passwd);
  ELSE
    config_messages := UTL_HTTP.request_pieces(url => FinalURL);
  END IF;

  IF (transferTimeout IS NOT NULL AND defaultTimeout IS NOT NULL) THEN
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.SET_TRANSFER_TIMEOUT(:1); END;' USING IN defaultTimeout;
  END IF;
  COMMIT;
EXCEPTION
  WHEN MODEL_POOL_EFFINITY_EXC THEN
    CZ_UTILS.LOG_REPORT('cz_cf_api', 'return_html_pieces', null, 'Model to Pool Effinity is not properly defined', FND_LOG.LEVEL_EXCEPTION);
    ROLLBACK;
    RAISE;
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END return_html_pieces;

--------------------------------------------------------------------------------
procedure delete_bv_records(p_pseudo_hdr_id    IN NUMBER
                           ,p_check_db_setting IN BOOLEAN
                           ,p_delete_ext_attr  IN BOOLEAN)
IS
  l_no_config_del cz_db_settings.value%TYPE;
BEGIN
  l_no_config_del := 'NO';
  IF p_check_db_setting THEN
    BEGIN
      SELECT upper(value) INTO l_no_config_del
      FROM cz_db_settings
      WHERE setting_id = 'BatchValConfigInputDelete';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;

  IF l_no_config_del = 'YES' THEN
    RETURN;
  END IF;

  IF p_delete_ext_attr THEN
    DELETE FROM CZ_CONFIG_EXT_ATTRIBUTES
    WHERE config_hdr_id = p_pseudo_hdr_id AND config_rev_nbr = 1;
  END IF;
  DELETE FROM CZ_CONFIG_ITEMS
  WHERE config_hdr_id = p_pseudo_hdr_id AND config_rev_nbr = 1;
  DELETE FROM CZ_CONFIG_HDRS
  WHERE config_hdr_id = p_pseudo_hdr_id AND config_rev_nbr = 1;
  COMMIT;
END delete_bv_records;
--------------------------------------------------------------------------------
PROCEDURE publication_for_init_message (p_init_str IN VARCHAR2 ,x_publication_id OUT NOCOPY NUMBER ,x_product_key OUT NOCOPY VARCHAR2)
IS
l_param_name VARCHAR2(50);
l_param_value VARCHAR2(100);
l_model_identifier VARCHAR2(100);
l_index1 NUMBER;
l_index2 NUMBER;
p_creation_date DATE;
p_effective_date DATE;
mHasProductId BOOLEAN := false;
mHasRestoreParams BOOLEAN := false;
mHasNativeBOMParams BOOLEAN := false;
l_domparser  xmlparser.parser;
l_xmldoc  xmldom.DOMDocument;
l_nodelist xmldom.DOMNodeList;
nl xmldom.DOMNodeList;
len1 number;
len2 number;
l_node xmldom.DOMNode;
l_node2 xmldom.DOMNode;
e xmldom.DOMElement;
l_nodeelement xmldom.DOMElement;
l_nnodemap xmldom.DOMNamedNodeMap;
attrname varchar2(100);
attrval varchar2(100);
--
p_calling_application_id VARCHAR2(10) := NULL;
p_config_model_lookup_date VARCHAR2(50) := NULL;
p_config_effective_usage VARCHAR2(3) := NULL;
p_publication_mode VARCHAR(1):= NULL;
p_product_id VARCHAR(10):= NULL;
p_inventory_item_id VARCHAR(10) := NULL;
p_context_org_id VARCHAR(10) := NULL;
p_config_header_id VARCHAR2(10) := NULL;
p_config_rev_nbr VARCHAR2(10) := NULL;
--
MISSING_CAL_APPL EXCEPTION;
NO_MODEL_INFO_FOUND EXCEPTION;

--
PROCEDURE set_init_param(p_param_name VARCHAR2, p_param_value VARCHAR2) IS
BEGIN
  IF LOWER(p_param_name) = 'calling_application_id' THEN
    p_calling_application_id := p_param_value;
  ELSIF LOWER(p_param_name) = 'config_model_lookup_date' THEN
    p_config_model_lookup_date := p_param_value;
  ELSIF LOWER(p_param_name) = 'config_effective_usage' THEN
    p_config_effective_usage := p_param_value;
  ELSIF LOWER(p_param_name) = 'publication_mode' THEN
    p_publication_mode := p_param_value;
  ELSIF LOWER(p_param_name) = 'product_id' THEN
    p_product_id := p_param_value;
  ELSIF LOWER(p_param_name) = 'inventory_item_id' OR LOWER(p_param_name) = 'model_id' THEN --TODO : Check documentation
    p_inventory_item_id := p_param_value;
  ELSIF LOWER(p_param_name) = 'context_org_id' THEN
    p_context_org_id := p_param_value;
  ELSIF LOWER(p_param_name) = 'config_header_id' THEN
    p_config_header_id := p_param_value;
  ELSIF LOWER(p_param_name) = 'config_rev_nbr' THEN
    p_config_rev_nbr := p_param_value;
  END IF;
END set_init_param;
--
BEGIN

l_domparser := xmlparser.newParser;
xmlparser.parseBuffer(l_domparser, p_init_str);
l_xmldoc := xmlparser.getDocument(l_domparser);
l_nodeelement := xmldom.getDocumentElement(l_xmldoc);
--l_nodelist := xmldom.getElementsByTagName(l_xmldoc, '*');
l_nodelist := xmldom.getChildrenByTagName(l_nodeelement, '*');
len1 := xmldom.getLength(l_nodelist);
FOR i IN 0..len1-1 LOOP
l_node := xmldom.ITEM(l_nodelist, i);
  IF  LOWER(xmldom.getNodeName(l_node)) = 'param' THEN
    l_nnodemap := xmldom.getAttributes(l_node);
    IF (xmldom.isNull(l_nnodemap) = FALSE) THEN -- Check if attr are none
      len2 := xmldom.getLength(l_nnodemap);
      FOR l_atrrcount IN 0..len2-1 LOOP
        l_node2 := xmldom.item(l_nnodemap, l_atrrcount);
        IF LOWER(xmldom.getNodeName(l_node2)) = 'name' THEN
          l_param_name := xmldom.getNodeValue(l_node2);
          EXIT;
        END IF;
      END LOOP; --loop for attributes
      IF l_param_name IS NOT NULL AND xmldom.HASCHILDNODES(l_node) = TRUE THEN
        l_param_value := xmldom.getNodeValue(xmldom.getfirstchild(l_node));
        set_init_param(l_param_name, l_param_value);
      END IF;
    END IF;--attributes
  END IF;
END LOOP; --loop for all doc children
xmlparser.freeParser(l_domparser);
/*IF p_calling_application_id IS NULL THEN
  RAISE MISSING_CAL_APPL;
END IF;
IF p_config_effective_usage IS NULL THEN
  RAISE MISSING_CAL_APPL;
END IF;*/
--Do not care of call_application_id, usage, publication_mode,
--Only check for config_model_lookup_date

	IF p_product_id IS NOT NULL THEN
		mHasProductId := TRUE;
	  IF p_config_model_lookup_date IS NULL THEN
	      default_new_cfg_dates(p_creation_date, p_config_model_lookup_date, p_effective_date);
	  END IF;
	  x_publication_id := publication_for_product(p_product_id,
						      p_config_model_lookup_date,
						      p_calling_application_id,
						      p_config_effective_usage,
						      p_publication_mode
						      );--check if launguage is a valid param in init message
	ELSIF p_inventory_item_id IS NOT NULL AND  p_context_org_id IS NOT NULL THEN
		mHasNativeBOMParams := TRUE;
	  IF p_config_model_lookup_date IS NULL THEN
	      default_new_cfg_dates(p_creation_date, p_config_model_lookup_date, p_effective_date);
	  END IF;
	  x_publication_id := publication_for_item(p_inventory_item_id,
						      p_context_org_id,
						      p_config_model_lookup_date,
						      p_calling_application_id,
						      p_config_effective_usage,
						      p_publication_mode
						      );--check if launguage is a valid param in init message
	ELSIF p_config_header_id IS NOT NULL AND  p_config_rev_nbr IS NOT NULL THEN
	  IF p_config_model_lookup_date IS NULL THEN
	      default_restored_cfg_dates(p_config_header_id, p_config_rev_nbr, p_creation_date, p_config_model_lookup_date, p_effective_date);
	  END IF;
	  mHasRestoreParams := TRUE;
	  x_publication_id := publication_for_saved_config(p_config_header_id,
						      p_config_rev_nbr,
						      p_config_model_lookup_date,
						      p_calling_application_id,
						      p_config_effective_usage,
						      p_publication_mode
						      );--check if launguage is a valid param in init message
	ELSE
	  RAISE NO_MODEL_INFO_FOUND;
	END IF;

	IF x_publication_id IS NULL THEN
		IF mHasProductId = TRUE THEN
			x_product_key := p_product_id;
		ELSIF mHasNativeBOMParams = TRUE THEN
			x_product_key := p_context_org_id || ':' || p_inventory_item_id;
		ELSIF mHasRestoreParams = TRUE OR (p_config_header_id IS NOT NULL AND p_config_rev_nbr IS NOT NULL) THEN
		--12816:204:2008/07/06 05:05
			SELECT model_identifier INTO l_model_identifier FROM cz_config_hdrs
				WHERE config_hdr_id = p_config_header_id AND config_rev_nbr = p_config_rev_nbr AND deleted_flag = 0;
				IF l_model_identifier IS NOT NULL THEN
					l_index1 := INSTR(l_model_identifier, ':');
					p_inventory_item_id := SUBSTR(l_model_identifier, 1, l_index1-1);
					l_index2 := INSTR(l_model_identifier, ':', l_index1+1);
					p_context_org_id := SUBSTR(l_model_identifier, l_index1+1, (l_index2-1)-l_index1);
					x_product_key := p_context_org_id || ':' || p_inventory_item_id;
				END IF;
		END IF;

	ELSE
		SELECT product_key INTO x_product_key FROM cz_model_publications WHERE publication_id = x_publication_id;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
	  cz_utils.log_report('cz_cf_api', 'publication_for_init_message', null,
	    SQLERRM, fnd_log.LEVEL_EXCEPTION);
	  RAISE;
END publication_for_init_message;

-------------------------------------------------------------------------------- pvt
procedure validate(p_pseudo_hdr_id   IN NUMBER
                  ,p_url             IN VARCHAR2
                  ,p_init_msg        IN VARCHAR2
                  ,p_validation_type IN VARCHAR2
                  ,x_validation_status OUT NOCOPY NUMBER
                  ,x_config_xml_msg    OUT NOCOPY CFG_OUTPUT_PIECES
                  ,v_detailed_error_message OUT NOCOPY varchar2
                  )
IS
  l_url  VARCHAR2(32767);
  l_publication_id NUMBER;
  l_product_key VARCHAR2(255);
  l_index NUMBER;
  l_init_message VARCHAR2(32767);
  l_pool_identifier cz_model_pool_mappings.pool_identifier%TYPE := NULL;

  -- XML building blocks:
  l_xml_message_header     VARCHAR2(40) := '?XMLmsg=';
  l_batch_validate_open    VARCHAR2(80) := '<batch_validate>';
  l_batch_validate_close   VARCHAR2(40) := '</batch_validate>';
  l_config_inputs_open     VARCHAR2(40) := '<config_inputs>';
  l_config_inputs_close    VARCHAR2(40) := '</config_inputs>';
  l_config_header_id_open  VARCHAR2(40) := '<config_header_id>';
  l_config_header_id_close VARCHAR2(40) := '</config_header_id>';
  l_config_rev_nbr_open    VARCHAR2(40) := '<config_rev_nbr>';
  l_config_rev_nbr_close   VARCHAR2(40) := '</config_rev_nbr>';
  l_terminate_open         VARCHAR2(40) := '<terminate>';
  l_config_info_str        VARCHAR2(250):= '';
  detailed_excp_flag       boolean;
  -- n0 integer; n1 integer; n2 integer; msg varchar2(255);

BEGIN
  UTL_HTTP.get_detailed_excp_support (detailed_excp_flag);

  IF detailed_excp_flag<>true
  THEN
    UTL_HTTP.set_detailed_excp_support(enable =>TRUE);
  END IF;

  --Need to avoid this if possible
  l_init_message := p_init_msg;
  --For now we shall augument the init message with publication_id, only when this EMC-LBR-ER solution is enabled
  --Once this '+' logic works fine for quite some time, we can allow this unconditionally
  IF(UPPER(TRIM(FND_PROFILE.VALUE('CZ_ADD_MODEL_ROUTING_COOKIE'))) LIKE 'Y%') THEN
    l_init_message := REPLACE(p_init_msg,'+',' ');
    publication_for_init_message (l_init_message, l_publication_id, l_product_key);

    IF l_publication_id IS NULL THEN
      l_publication_id := '-666';
    END IF;

    l_index := INSTR(LOWER(p_init_msg), '<initialize>') + LENGTH('<initialize>');
    l_init_message := SUBSTR(p_init_msg, 1, l_index-1) || '<param+name="publication_id">' || l_publication_id || '</param>' || SUBSTR(p_init_msg , l_index);
    --l_init_message := REPLACE(l_init_message,' ','+');
  END IF;

  IF p_pseudo_hdr_id IS NOT NULL THEN
    l_config_info_str := l_config_header_id_open || TO_CHAR(p_pseudo_hdr_id)
                      || l_config_header_id_close || l_config_rev_nbr_open
                      || '1' || l_config_rev_nbr_close;
  END IF;

  -- Backdoor for providing an alternate URL through a db setting
  BEGIN
    l_url := get_db_setting('ORAAPPS_INTEGRATE','ALTBATCHVALIDATEURL');
  EXCEPTION
    WHEN OTHERS THEN
      l_url := p_url;
  END;

  -- append validation type to batch validate tag
  IF p_validation_type IS NULL OR p_validation_type = CZ_API_PUB.VALIDATE_ORDER THEN
    l_batch_validate_open := batchurlencode('<batch_validate validation_type="validate_order">');

  ELSIF (p_validation_type = CZ_API_PUB.VALIDATE_FULFILLMENT) THEN
    l_batch_validate_open := batchurlencode('<batch_validate validation_type="validate_fulfillment">');
  ELSIF (p_validation_type = CZ_API_PUB.INTERACTIVE) THEN
    l_batch_validate_open := batchurlencode('<batch_validate validation_type="interactive">');
  ELSE
    l_batch_validate_open := batchurlencode('<batch_validate validation_type="validate_return">');
  END IF;

  l_url := l_url || l_xml_message_header || l_batch_validate_open || l_init_message;

  IF(l_config_info_str IS NOT NULL)THEN

    l_url := l_url || l_config_inputs_open || l_config_info_str || l_config_inputs_close;
  END IF;

  l_url := l_url || l_batch_validate_close;

/*
n0 := 1;
n1 := instr(l_url, '</', n0);
WHILE n1 > 0 LOOP
  n2 := instr(l_url, '>', n1) + 1;
  msg := substr(l_url, n0, (n2-n0));
  dbms_output.put_line(msg);
  n0 := n2;
  n1 := instr(l_url, '</', n0);
END LOOP;
IF n0 < length(l_url) THEN
  msg := substr(l_url, n0);
  dbms_output.put_line(msg);
END IF;
*/
  IF (LENGTH(l_url) > INIT_MESSAGE_LIMIT) THEN
    ROLLBACK;
    x_validation_status := INIT_TOO_LONG;
    RETURN;
  END IF;
  COMMIT; -- pseudo config recs

  IF(UPPER(TRIM(FND_PROFILE.VALUE('CZ_ADD_MODEL_ROUTING_COOKIE'))) LIKE 'Y') THEN
    l_pool_identifier := pool_token_for_product_key(l_product_key);
  END IF;
  return_html_pieces(l_url, l_pool_identifier, x_config_xml_msg);
  IF (x_config_xml_msg.COUNT = 0) THEN
    x_validation_status := CONFIG_EXCEPTION;
    RETURN;
    -- RAISE ZERO_RESPONSE_LENGTH;
  END IF;

  IF (INSTR(x_config_xml_msg(x_config_xml_msg.FIRST),l_terminate_open)<>0) THEN
    x_validation_status := CONFIG_PROCESSED;
  ELSE
    x_validation_status := CONFIG_PROCESSED_NO_TERMINATE;
  END IF;

EXCEPTION
  WHEN UTL_HTTP.INIT_FAILED THEN
    v_detailed_error_message:=' SQLCODE:'||UTL_HTTP.GET_DETAILED_SQLCODE||' ERROR:'||UTL_HTTP.GET_DETAILED_SQLERRM;
    x_validation_status := UTL_HTTP_INIT_FAILED;

    IF detailed_excp_flag<>true
    THEN
      UTL_HTTP.set_detailed_excp_support(enable =>FALSE);
    END IF;

  WHEN UTL_HTTP.REQUEST_FAILED OR UTL_HTTP.BAD_ARGUMENT
      OR UTL_HTTP.BAD_URL OR UTL_HTTP.PROTOCOL_ERROR
      OR UTL_HTTP.UNKNOWN_SCHEME OR UTL_HTTP.HEADER_NOT_FOUND
      OR UTL_HTTP.END_OF_BODY OR UTL_HTTP.ILLEGAL_CALL
      OR UTL_HTTP.HTTP_CLIENT_ERROR OR UTL_HTTP.HTTP_SERVER_ERROR
      OR UTL_HTTP.TOO_MANY_REQUESTS OR UTL_HTTP.PARTIAL_MULTIBYTE_CHAR
     OR UTL_HTTP.TRANSFER_TIMEOUT  THEN
    v_detailed_error_message:=' SQLCODE:'||UTL_HTTP.GET_DETAILED_SQLCODE||' ERROR:'||UTL_HTTP.GET_DETAILED_SQLERRM;
    x_validation_status:=UTL_HTTP_REQUEST_FAILED;

    IF detailed_excp_flag<>true
    THEN
      UTL_HTTP.set_detailed_excp_support(enable =>FALSE);
    END IF;

  WHEN OTHERS THEN
    IF detailed_excp_flag<>true
    THEN
      UTL_HTTP.set_detailed_excp_support(enable =>FALSE);
    END IF;

    IF sqlcode='-12545'
    then
      x_validation_status:=UTL_HTTP_REQUEST_FAILED;
    ELSE
     RAISE;
    END IF;
END validate; -- pvt

--------------------------------------------------------------------------------

procedure validate(p_api_version         IN  NUMBER
                  ,p_config_item_tbl     IN  config_item_tbl_type
                  ,p_config_ext_attr_tbl IN  config_ext_attr_tbl_type
                  ,p_url                 IN  VARCHAR2
                  ,p_init_msg            IN  VARCHAR2
                  ,p_validation_type     IN  VARCHAR2
                  ,x_config_xml_msg  OUT NOCOPY CFG_OUTPUT_PIECES
                  ,x_return_status   OUT NOCOPY VARCHAR2
                  ,x_msg_count       OUT NOCOPY NUMBER
                  ,x_msg_data        OUT NOCOPY VARCHAR2
                  )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'validate:new';
  l_miss_num     CONSTANT INTEGER := -2147483648; -- java's Integer.MIN_VALUE
  l_nDebug       PLS_INTEGER;
  l_idx          PLS_INTEGER;
  l_msg          VARCHAR2(1000);
  l_start        INTEGER;
  l_end          INTEGER;

  l_log_stmt     BOOLEAN;
  l_has_item     BOOLEAN;
  l_has_attr     BOOLEAN;

  l_url               VARCHAR2(32767);
  l_validation_type   VARCHAR2(1);
  l_validation_status INTEGER;
  l_pseudo_hdr_id     cz_config_hdrs.config_hdr_id%TYPE;
  l_operation_code    VARCHAR2(40);
  l_rec1_seq          INTEGER;
  l_config_hdr_id     cz_config_hdrs.config_hdr_id%TYPE;
  l_config_rev_nbr    cz_config_hdrs.config_rev_nbr%TYPE;
  l_ext_comp_code     cz_config_items.node_identifier%TYPE;
  l_item_depth        INTEGER;

  l_upd_item_map      NUMBER_TBL_INDEXBY_CHAR_TYPE;
  l_item_seq_map      NUMBER_TBL_INDEXBY_TYPE;
  l_config_item_tbl   NUMBER_TBL_INDEXBY_TYPE;
  l_ecc_tbl           str1200_tbl_type;
  l_seq_nbr_tbl       NUMBER_TBL_INDEXBY_TYPE;
  l_rec_seq_tbl       NUMBER_TBL_INDEXBY_TYPE;
  l_operation_tbl     NUMBER_TBL_INDEXBY_TYPE;
  l_quantity_tbl      NUMBER_TBL_INDEXBY_TYPE;
  l_instance_name_tbl str255_tbl_type;
  l_loc_id_tbl        NUMBER_TBL_INDEXBY_TYPE;
  l_loc_type_code_tbl str255_tbl_type;
  l_attr_nam_tbl      str255_tbl_type;
  l_attr_grp_tbl      str255_tbl_type;
  l_attr_val_tbl      str255_tbl_type;
  v_detailed_error_message varchar2(2000);
  v_return_config_changed varchar2(2) := NULL;

  procedure set_message(p_msg_name IN VARCHAR2
                       ,p_token_name1  IN VARCHAR2
                       ,p_token_value1 IN VARCHAR2
                       ,p_token_name2  IN VARCHAR2
                       ,p_token_value2 IN VARCHAR2
                       ,p_token_name3  IN VARCHAR2
                       ,p_token_value3 IN VARCHAR2
                       ,p_token_name4  IN VARCHAR2
                       ,p_token_value4 IN VARCHAR2
                       ) IS
  BEGIN
    fnd_message.set_name('CZ', p_msg_name);
    fnd_message.set_token(p_token_name1, p_token_value1);
    fnd_message.set_token(p_token_name2, p_token_value2);
    fnd_message.set_token(p_token_name3, p_token_value3);
    fnd_message.set_token(p_token_name4, p_token_value4);
    fnd_msg_pub.add;
  END set_message;

BEGIN
  l_nDebug := 1;

  IF (NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME)) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_validation_type := p_validation_type;
  IF l_validation_type IS NULL THEN
    l_validation_type := CZ_API_PUB.VALIDATE_ORDER;
  ELSIF l_validation_type NOT IN
       (CZ_API_PUB.VALIDATE_ORDER, CZ_API_PUB.VALIDATE_FULFILLMENT,
        CZ_API_PUB.INTERACTIVE, CZ_API_PUB.VALIDATE_RETURN) THEN
    fnd_message.set_name('CZ', 'CZ_BV_INVALID_TYPE');
    fnd_message.set_token('TYPE', l_validation_type);
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_init_msg IS NULL OR length(p_init_msg) = 0 THEN
    fnd_message.set_name('CZ', 'CZ_BV_NULL_INITMSG');
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_url := p_url;
  IF l_url IS NULL THEN
    l_url := FND_PROFILE.Value('CZ_UIMGR_URL');
  END IF;

  l_log_stmt := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF l_log_stmt AND p_init_msg IS NOT NULL THEN
    CZ_UTILS.log_report(G_PKG_NAME,l_api_name,l_nDebug,'URL='||l_url,FND_LOG.LEVEL_STATEMENT);
    l_start := 1;
    l_end := instr(p_init_msg, '</param>', l_start);
    WHILE l_end > 0 LOOP
      l_end := l_end + 8;
      l_msg := substr(p_init_msg, l_start, (l_end - l_start));
      -- dbms_output.put_line(l_msg);
      CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_STATEMENT);
      l_start := l_end;
      l_end := instr(p_init_msg, '</param>', l_start);
    END LOOP;
    IF l_start < length(p_init_msg) THEN
      l_msg := substr(p_init_msg, l_start);
      CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_STATEMENT);
      -- dbms_output.put_line(l_msg);
    END IF;
    CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug,
       'Validate type: ' || p_validation_type, FND_LOG.LEVEL_STATEMENT);
  END IF;

  l_nDebug := 2;
  l_has_item := p_config_item_tbl IS NOT NULL AND p_config_item_tbl.COUNT > 0;
  l_has_attr := p_config_ext_attr_tbl IS NOT NULL AND p_config_ext_attr_tbl.COUNT > 0;
  IF l_has_item OR l_has_attr THEN
    -- create pseudo hdr rec
    l_pseudo_hdr_id := next_config_hdr_id;
    INSERT INTO CZ_CONFIG_HDRS (config_hdr_id
                               ,config_rev_nbr
                               ,name
                               ,effective_usage_id
                               ,component_instance_type
                               ,model_instantiation_type
                               ,CONFIG_DELTA_SPEC
                               ,deleted_flag
                               ,HAS_FAILURES
                               )
    VALUES (l_pseudo_hdr_id
           ,1
           ,'new batch'
           ,ANY_USAGE_ID
           ,ROOT
           ,BV_MODEL_TYPE
           ,0
           ,'0'
           ,'0'
           );

    IF l_log_stmt THEN
      CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, 'pseudo hdr=' ||
                          l_pseudo_hdr_id, FND_LOG.LEVEL_STATEMENT);
    END IF;

    l_nDebug := 3;
    l_idx := 0;
    -- Note: if supporting new config in the future, then needs either to move the
    -- get_config_hdr call or to chg the method to handle no hdr info in init msg
    get_config_hdr(p_init_msg, l_config_hdr_id, l_config_rev_nbr);

    l_nDebug := 4;
    IF l_has_item THEN
      l_rec1_seq := p_config_item_tbl(p_config_item_tbl.FIRST).sequence_nbr;
      IF l_rec1_seq = FND_API.G_MISS_NUM THEN
        l_rec1_seq := NULL;
      END IF;

      FOR i IN p_config_item_tbl.FIRST..p_config_item_tbl.LAST
      LOOP
        IF l_log_stmt THEN
          l_msg := 'item rec ' || i || ':id=' || p_config_item_tbl(i).config_item_id ||
                   ',seq=' || p_config_item_tbl(i).sequence_nbr  ||
                   ',opc=' || p_config_item_tbl(i).operation     ||
                   ',qty=' || p_config_item_tbl(i).quantity      ||
                   ',nam=' || p_config_item_tbl(i).instance_name ||
                   ',lid=' || p_config_item_tbl(i).location_id   ||
                   ',ltc=' || p_config_item_tbl(i).location_type_code;
          CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_STATEMENT);
        END IF;

        IF p_config_item_tbl(i).config_item_id IS NULL OR
           p_config_item_tbl(i).config_item_id = FND_API.G_MISS_NUM THEN
          set_message('CZ_BV_NULL_VAL', 'COLUMN', 'CONFIG_ITEM_ID', 'TYPE', 'ITEM',
                      'IDX', i, 'SEQ', p_config_item_tbl(i).sequence_nbr);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_config_item_tbl(i).operation IS NULL OR
           p_config_item_tbl(i).operation = FND_API.G_MISS_NUM THEN
          set_message('CZ_BV_NULL_VAL', 'COLUMN', 'OPERATION', 'TYPE', 'ITEM',
                      'IDX', i, 'SEQ', p_config_item_tbl(i).sequence_nbr);
          RAISE FND_API.G_EXC_ERROR;
        ELSIF p_config_item_tbl(i).operation NOT IN (BV_OPERATION_UPDATE,BV_OPERATION_DELETE) THEN
          IF p_config_item_tbl(i).operation = BV_OPERATION_INSERT THEN
            l_operation_code := 'INSERT';
          ELSIF p_config_item_tbl(i).operation = BV_OPERATION_REVERT THEN
            l_operation_code := 'REVERT';
          ELSE
            l_operation_code := to_char(p_config_item_tbl(i).operation);
          END IF;
          fnd_message.set_name('CZ', 'CZ_BV_INVALID_OP');
          fnd_message.set_token('CODE', l_operation_code);
          fnd_message.set_token('IDX', i);
          fnd_message.set_token('SEQ', p_config_item_tbl(i).sequence_nbr);
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF p_config_item_tbl(i).operation = BV_OPERATION_UPDATE AND
              p_config_item_tbl(i).instance_name = FND_API.G_MISS_CHAR THEN
          set_message('CZ_BV_NULL_VAL', 'COLUMN', 'INSTANCE_NAME', 'TYPE', 'ITEM',
                      'IDX', i, 'SEQ', p_config_item_tbl(i).sequence_nbr);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_rec1_seq IS NULL AND p_config_item_tbl(i).sequence_nbr IS NOT NULL OR
           l_rec1_seq IS NOT NULL AND (p_config_item_tbl(i).sequence_nbr IS NULL OR
                   p_config_item_tbl(i).sequence_nbr=FND_API.G_MISS_NUM) THEN
          set_message('CZ_BV_NULL_VAL', 'COLUMN', 'SEQUENCE_NBR', 'TYPE', 'ITEM',
                      'IDX', i, 'SEQ', p_config_item_tbl(i).sequence_nbr);
          RAISE FND_API.G_EXC_ERROR;
        ELSIF p_config_item_tbl(i).sequence_nbr IS NOT NULL THEN
          IF l_item_seq_map.exists(p_config_item_tbl(i).sequence_nbr) THEN
            fnd_message.set_name('CZ', 'CZ_BV_DUP_SEQ');
            fnd_message.set_token('SEQ', p_config_item_tbl(i).sequence_nbr);
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            l_item_seq_map(p_config_item_tbl(i).sequence_nbr) := i;
          END IF;
        END IF;

        -- construct extended component code
        get_ext_comp_code(l_config_hdr_id, l_config_rev_nbr,
                          p_config_item_tbl(i).config_item_id,
                          l_ext_comp_code, l_item_depth);

        IF l_ext_comp_code IS NULL OR length(l_ext_comp_code) = 0 THEN
          fnd_message.set_name('CZ', 'CZ_BV_INVALID_ITEM');
          fnd_message.set_token('HDR', l_config_hdr_id);
          fnd_message.set_token('REV', l_config_rev_nbr);
          fnd_message.set_token('ID', p_config_item_tbl(i).config_item_id);
          fnd_message.set_token('TYPE', 'ITEM');
          fnd_message.set_token('IND', i);
          fnd_message.set_token('SEQ', p_config_item_tbl(i).sequence_nbr);
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF p_config_item_tbl(i).operation = BV_OPERATION_UPDATE THEN
          l_upd_item_map(p_config_item_tbl(i).config_item_id) := p_config_item_tbl(i).config_item_id;
        END IF;

        l_idx := l_idx + 1;
        l_config_item_tbl(l_idx) := p_config_item_tbl(i).config_item_id;
	l_ecc_tbl(l_idx) := l_ext_comp_code;
	l_seq_nbr_tbl(l_idx) := NVL(p_config_item_tbl(i).sequence_nbr, l_item_depth);
	l_operation_tbl(l_idx) := p_config_item_tbl(i).operation;
	l_quantity_tbl(l_idx) := p_config_item_tbl(i).quantity;
	IF l_quantity_tbl(l_idx) = FND_API.G_MISS_NUM THEN
	  l_quantity_tbl(l_idx) := l_miss_num;
	END IF;
        l_instance_name_tbl(l_idx) := p_config_item_tbl(i).instance_name;
        l_loc_id_tbl(l_idx) := p_config_item_tbl(i).location_id;
	IF l_loc_id_tbl(l_idx) = FND_API.G_MISS_NUM THEN
	  l_loc_id_tbl(l_idx) := l_miss_num;
	END IF;
	l_loc_type_code_tbl(l_idx) := p_config_item_tbl(i).location_type_code;
	l_rec_seq_tbl(l_idx) := i;

      END LOOP;

      l_nDebug := 5;
      FORALL i IN l_config_item_tbl.first .. l_config_item_tbl.lAST
        INSERT INTO CZ_CONFIG_ITEMS
                (config_hdr_id
                ,config_rev_nbr
                ,config_item_id
                ,sequence_nbr
                ,value_type_code
                ,node_identifier
                ,item_num_val
                ,INSTANCE_HDR_ID
                ,INSTANCE_REV_NBR
                ,COMPONENT_INSTANCE_TYPE
                ,CONFIG_DELTA
                ,name
                ,location_id
                ,location_type_code
               )
        VALUES (l_pseudo_hdr_id
               ,1
               ,l_config_item_tbl(i)
               ,l_seq_nbr_tbl(i)
               ,l_operation_tbl(i)
               ,l_ecc_tbl(i)
               ,l_quantity_tbl(i)
               ,l_pseudo_hdr_id
               ,1
               ,'T'
               ,l_rec_seq_tbl(i)
               ,l_instance_name_tbl(i)
               ,l_loc_id_tbl(i)
               ,l_loc_type_code_tbl(i)
               );

      -- reoder sequences if generated by this proc
      l_nDebug := 6;
      IF l_rec1_seq IS NULL THEN
        SELECT config_item_id BULK COLLECT INTO l_config_item_tbl
        FROM cz_config_items
        WHERE config_hdr_id = l_pseudo_hdr_id AND config_rev_nbr = 1
        ORDER BY sequence_nbr, config_delta;

        FOR i IN l_config_item_tbl.FIRST .. l_config_item_tbl.LAST LOOP
          l_seq_nbr_tbl(i) := i;
        END LOOP;

        FORALL i IN l_config_item_tbl.FIRST .. l_config_item_tbl.LAST
          UPDATE cz_config_items
          SET    sequence_nbr = l_seq_nbr_tbl(i)
          WHERE  config_hdr_id = l_pseudo_hdr_id AND config_rev_nbr = 1
          AND    config_item_id = l_config_item_tbl(i);
        IF l_log_stmt THEN
          CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, 'item sequences reordered',
                              FND_LOG.LEVEL_STATEMENT);
        END IF;
      END IF;
    END IF;

    l_nDebug := 7;
    -- processing  extended attributes
    IF l_has_attr THEN
      IF l_rec1_seq IS NULL AND NOT l_has_item THEN
        l_rec1_seq := p_config_ext_attr_tbl(p_config_ext_attr_tbl.FIRST).sequence_nbr;
        IF l_rec1_seq = FND_API.G_MISS_NUM THEN
          l_rec1_seq := NULL;
        END IF;
      END IF;

      l_idx := 0;
      l_config_item_tbl.DELETE;
      l_ecc_tbl.DELETE;
      l_seq_nbr_tbl.DELETE;
      FOR i In p_config_ext_attr_tbl.FIRST .. p_config_ext_attr_tbl.LAST LOOP
        IF l_log_stmt THEN
          l_msg := 'attr rec ' || i || ': id=' || p_config_ext_attr_tbl(i).config_item_id ||
                   ', seq=' || p_config_ext_attr_tbl(i).sequence_nbr    ||
                   ', nam=' || p_config_ext_attr_tbl(i).attribute_name  ||
                   ', grp=' || p_config_ext_attr_tbl(i).attribute_group ||
                   ', val=' || p_config_ext_attr_tbl(i).attribute_value;
          CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_STATEMENT);
        END IF;

        IF p_config_ext_attr_tbl(i).config_item_id IS NULL OR
           p_config_ext_attr_tbl(i).config_item_id = FND_API.G_MISS_NUM THEN
          set_message('CZ_BV_NULL_VAL', 'COLUMN', 'CONFIG_ITEM_ID', 'TYPE', 'ATTRIBUTE',
                      'IDX', i, 'SEQ', p_config_ext_attr_tbl(i).sequence_nbr);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_rec1_seq IS NULL AND p_config_ext_attr_tbl(i).sequence_nbr IS NOT NULL OR
           l_rec1_seq IS NOT NULL AND (p_config_ext_attr_tbl(i).sequence_nbr IS NULL OR
                 p_config_ext_attr_tbl(i).sequence_nbr=FND_API.G_MISS_NUM) THEN
          set_message('CZ_BV_NULL_VAL', 'COLUMN', 'SEQUENCE_NBR', 'TYPE', 'ATTRIBUTE',
                      'IDX', i, 'SEQ', p_config_ext_attr_tbl(i).sequence_nbr);
          RAISE FND_API.G_EXC_ERROR;
        ELSIF p_config_ext_attr_tbl(i).sequence_nbr IS NOT NULL THEN
          IF l_item_seq_map.exists(p_config_ext_attr_tbl(i).sequence_nbr) THEN
            fnd_message.set_name('CZ', 'CZ_BV_DUP_SEQ');
            fnd_message.set_token('SEQ', p_config_ext_attr_tbl(i).sequence_nbr);
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            l_item_seq_map(p_config_ext_attr_tbl(i).sequence_nbr) := i;
          END IF;
        END IF;

        IF p_config_ext_attr_tbl(i).attribute_name IS NULL OR
           p_config_ext_attr_tbl(i).attribute_name = FND_API.G_MISS_CHAR THEN
          set_message('CZ_BV_NULL_VAL', 'COLUMN', 'ATTRIBUTE_NAME', 'TYPE', 'ATTRIBUTE',
                       'IDX', i, 'SEQ', p_config_ext_attr_tbl(i).sequence_nbr);
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF p_config_ext_attr_tbl(i).attribute_value IS NULL THEN
          set_message('CZ_BV_NULL_VAL', 'COLUMN', 'ATTRIBUTE_VALUE', 'TYPE', 'ATTRIBUTE',
                       'IDX', i, 'SEQ', p_config_ext_attr_tbl(i).sequence_nbr);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF NOT l_upd_item_map.exists(p_config_ext_attr_tbl(i).config_item_id) THEN
          get_ext_comp_code(l_config_hdr_id, l_config_rev_nbr,
                            p_config_ext_attr_tbl(i).config_item_id,
                            l_ext_comp_code, l_item_depth);

          IF l_ext_comp_code IS NULL OR length(l_ext_comp_code) = 0 THEN
            fnd_message.set_name('CZ', 'CZ_BV_INVALID_ITEM');
            fnd_message.set_token('HDR', l_config_hdr_id);
            fnd_message.set_token('REV', l_config_rev_nbr);
            fnd_message.set_token('ID', p_config_ext_attr_tbl(i).config_item_id);
            fnd_message.set_token('TYPE', 'ATTRIBUTE');
            fnd_message.set_token('IND', i);
            fnd_message.set_token('SEQ', p_config_ext_attr_tbl(i).sequence_nbr);
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- Create a dummy item with no-op for now, this part of code will be removed
          -- or modified after changing to not generate ecc
          -- If we do need to keep ecc, do a single bulk insert for both the item recs from
          -- inputs and the dummy recs here by adding the dummies to the tbls used in processing
          -- inputs and then moving bulk ins stmt to the end of processing attr
          INSERT INTO CZ_CONFIG_ITEMS
                (config_hdr_id
                ,config_rev_nbr
                ,config_item_id
                ,sequence_nbr
                ,value_type_code
                ,node_identifier
                ,INSTANCE_HDR_ID
                ,INSTANCE_REV_NBR
                ,COMPONENT_INSTANCE_TYPE
                ,CONFIG_DELTA
               )
          VALUES (l_pseudo_hdr_id
                 ,1
                 ,p_config_ext_attr_tbl(i).config_item_id
                 ,i -- do not matter for no-op item
                 ,BV_OPERATION_UPDATE
                 ,l_ext_comp_code
                 ,l_pseudo_hdr_id
                 ,1
                 ,'T'
                 ,l_item_depth
                 );
          l_upd_item_map(p_config_ext_attr_tbl(i).config_item_id) := p_config_ext_attr_tbl(i).config_item_id;
        END IF;

        l_idx := l_idx + 1;
        l_config_item_tbl(l_idx) := p_config_ext_attr_tbl(i).config_item_id;
        l_attr_nam_tbl(l_idx) := p_config_ext_attr_tbl(i).attribute_name;
        l_attr_grp_tbl(l_idx) := p_config_ext_attr_tbl(i).attribute_group;
        l_attr_val_tbl(l_idx) := p_config_ext_attr_tbl(i).attribute_value;
        l_seq_nbr_tbl(l_idx) := NVL(p_config_ext_attr_tbl(i).sequence_nbr, i);
      END LOOP;

      l_nDebug := 8;
      FORALL i IN l_config_item_tbl.first .. l_config_item_tbl.lAST
        INSERT INTO cz_config_ext_attributes(config_hdr_id
                                            ,config_rev_nbr
                                            ,config_item_id
                                            ,attribute_name
                                            ,attribute_group
                                            ,attribute_value
                                            ,sequence_nbr
                                            )
        VALUES(l_pseudo_hdr_id
              ,1
              ,l_config_item_tbl(i)
              ,l_attr_nam_tbl(i)
              ,l_attr_grp_tbl(i)
              ,l_attr_val_tbl(i)
              ,l_seq_nbr_tbl(i)
              );

      -- reorder sequences if generated by this proc
      l_nDebug := 9;
      IF l_rec1_seq IS NULL THEN
        l_config_item_tbl.DELETE;
        l_seq_nbr_tbl.DELETE;
        SELECT attr.config_item_id BULK COLLECT INTO l_config_item_tbl
        FROM cz_config_ext_attributes attr, cz_config_items item
        WHERE attr.config_hdr_id = l_pseudo_hdr_id AND attr.config_rev_nbr = 1
        AND attr.config_hdr_id = item.config_hdr_id AND attr.config_rev_nbr = item.config_rev_nbr
        AND attr.config_item_id = item.config_item_id
        ORDER BY nvl(length(translate(item.node_identifier,'-0123456789','A')),0), attr.sequence_nbr;

        FOR i IN l_config_item_tbl.FIRST .. l_config_item_tbl.LAST LOOP
          l_seq_nbr_tbl(i) := i + l_idx;
        END LOOP;

        FORALL i IN l_config_item_tbl.FIRST .. l_config_item_tbl.LAST
          UPDATE cz_config_ext_attributes
          SET    sequence_nbr = l_seq_nbr_tbl(i)
          WHERE  config_hdr_id = l_pseudo_hdr_id AND config_rev_nbr = 1
          AND    config_item_id = l_config_item_tbl(i);

        IF l_log_stmt THEN
          CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, 'attr sequences reordered',
                              FND_LOG.LEVEL_STATEMENT);
        END IF;
      END IF;

    END IF;
  END IF;

  l_nDebug := 10;
  validate(l_pseudo_hdr_id
          ,l_url
          ,p_init_msg
          ,l_validation_type
          ,l_validation_status
          ,x_config_xml_msg
          ,v_detailed_error_message
          );

  CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, 'validation status: ' ||
                      l_validation_status||v_detailed_error_message, FND_LOG.LEVEL_PROCEDURE);

  IF l_validation_status = INIT_TOO_LONG THEN
    fnd_message.set_name('CZ', 'CZ_BV_ERR_INIT_MSG');
    fnd_message.SET_TOKEN('ERROR_MSG', v_detailed_error_message);
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_validation_status = UTL_HTTP_INIT_FAILED THEN
    fnd_message.set_name('CZ', 'CZ_BV_ERR_HTTP_INIT');
    fnd_message.SET_TOKEN('ERROR_MSG', v_detailed_error_message);
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_validation_status = UTL_HTTP_REQUEST_FAILED THEN
    fnd_message.set_name('CZ', 'CZ_BV_ERR_HTTP_REQ');
    fnd_message.SET_TOKEN('ERROR_MSG', v_detailed_error_message);
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_validation_status = CONFIG_PROCESSED_NO_TERMINATE OR
        l_validation_status = CONFIG_EXCEPTION  THEN
    FOR i IN (SELECT message FROM cz_config_messages
              WHERE config_hdr_id = l_pseudo_hdr_id AND config_rev_nbr = 1
              ORDER BY message_seq) LOOP
      fnd_msg_pub.Add_Exc_Msg(p_error_text => i.message);
    END LOOP;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_nDebug := 11;
  IF l_validation_status = CONFIG_PROCESSED AND l_validation_type = CZ_API_PUB.VALIDATE_ORDER
       AND NOT (l_has_item OR l_has_attr) THEN
-- Added 2 new params as per the Quoting ER#9348864 as said earlier. But for
-- this call they are not required though for this VALIDATE API.
    check_deltas(p_init_msg,'N',x_config_xml_msg,x_return_status,v_return_config_changed);
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      fnd_msg_pub.Add_Exc_Msg(p_error_text => 'Error from check_delta:');
      FOR i IN (SELECT message FROM cz_config_messages
                WHERE config_hdr_id = l_pseudo_hdr_id AND config_rev_nbr = 1
                ORDER BY message_seq) LOOP
        fnd_msg_pub.Add_Exc_Msg(p_error_text => i.message);
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  l_nDebug := 12;
  delete_bv_records(l_pseudo_hdr_id, TRUE, TRUE);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    ROLLBACK;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    delete_bv_records(l_pseudo_hdr_id, FALSE, TRUE);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    delete_bv_records(l_pseudo_hdr_id, FALSE, TRUE);
END validate; -- new

--------------------------------------------------------------------------------
-- Quoting ER#9348864. Retaining the existing API so that there should NOT be
-- any problem for any existing customer/applications.
-- created a new VALIDATE API for the ER maintioned with extra one IN and one OUT param (right below).
-- So, any existing caller will continue to call this APIi but this will be wrapper of the new VALIDATE API
-- that was created for quote. Hence the new VALIDATE API is called inside this orginal VALIDATE API
---------------------------------------------------------------------------------
PROCEDURE VALIDATE (config_input_list IN CFG_INPUT_LIST,
                    init_message      IN VARCHAR2,
                    config_messages   IN OUT NOCOPY CFG_OUTPUT_PIECES,
                    validation_status IN OUT NOCOPY NUMBER,
                    URL               IN VARCHAR2 DEFAULT FND_PROFILE.Value('CZ_UIMGR_URL'),
                    p_validation_type IN VARCHAR2 DEFAULT CZ_API_PUB.VALIDATE_ORDER)

IS
p_check_config_flag VARCHAR2(2) := 'N';
x_return_config_changed VARCHAR2(2) := NULL;

BEGIN

CZ_CF_API.VALIDATE (config_input_list ,
                    init_message      ,
                    config_messages   ,
                    validation_status ,
                    URL               ,
                    p_validation_type ,
                    p_check_config_flag ,
                    x_return_config_changed );


 -- NO need to handle exception here as the original API has taken care of this
END VALIDATE;
--------------------------------------------------------------------------------------
-- This is the new API created for Quoting ER#9348864
-- Added 2 new params, one IN and one OUT as per designed
-- new IN param: p_check_config_flag should be passed 'Y' by the caller to get the new behavior.
-- passing 'N' will result the same behavior as other VALIDATE signature.
-- new OUT param: p_return_config_changed. Valid values are : 'Y'(Changed), 'N' (Unchanged) and NULL (no request from caller)
-- If the p_check_config_flag is Y then x_return_config_changed will be Y or N depending on change in configuration
-- Else, it will return NULL when  p_check_config_flag is not passed by the caller.
-- Purpose: As per the ER, when there is a change in configuration (means delta
-- exists) during BV call, the new VALIDATE should NOT fail but return an indicator to caller saying there is
-- a change in configuration. Details are in ER.
--------------------------------------------------------------------------------------
PROCEDURE VALIDATE (config_input_list IN CFG_INPUT_LIST,
                    init_message      IN VARCHAR2,
                    config_messages   IN OUT NOCOPY CFG_OUTPUT_PIECES,
                    validation_status IN OUT NOCOPY NUMBER,
                    URL               IN VARCHAR2 DEFAULT FND_PROFILE.Value('CZ_UIMGR_URL'),
                    p_validation_type IN VARCHAR2 DEFAULT CZ_API_PUB.VALIDATE_ORDER,
                    p_check_config_flag IN VARCHAR2 DEFAULT 'N',
                    x_return_config_changed OUT NOCOPY VARCHAR2)

IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name           CONSTANT VARCHAR2(20) := 'validate:old';
  l_nDebug             PLS_INTEGER;
  l_log_stmt           BOOLEAN;
  l_msg                VARCHAR2(2000);

  l_pseudo_hdr_id      NUMBER;
  l_pseudo_item_id     PLS_INTEGER;
  l_rec1_seq           NUMBER;
  l_hdr_id             NUMBER;
  l_rev_nbr            NUMBER;
  l_item_id            NUMBER;
  l_ext_comp_code      cz_config_items.node_identifier%TYPE;
  l_item_depth         INTEGER;
  l_delta_status       VARCHAR2(1);
  l_check_db_setting   BOOLEAN;

  l_ecc_tbl            str1200_tbl_type;
  l_item_id_tbl        NUMBER_TBL_INDEXBY_TYPE;
  l_quantity_tbl       NUMBER_TBL_INDEXBY_TYPE;
  l_input_seq_tbl      NUMBER_TBL_INDEXBY_TYPE;
  l_item_depth_tbl     NUMBER_TBL_INDEXBY_TYPE;

  v_detailed_error_message varchar2(2000);

  DELTA_CHECK_FAILURE  EXCEPTION;

BEGIN
  l_nDebug := 1;
  l_log_stmt := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF l_log_stmt THEN
    l_msg := 'Number of inputs=' || config_input_list.COUNT;
    CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_STATEMENT);
  END IF;

  IF config_input_list.COUNT > 0 THEN
    BEGIN
      l_pseudo_hdr_id := next_config_hdr_id;
      INSERT INTO CZ_CONFIG_HDRS (config_hdr_id
                                 ,config_rev_nbr
                                 ,name
                                 ,effective_usage_id
                                 ,deleted_flag
                                 ,CONFIG_DELTA_SPEC
                                 ,COMPONENT_INSTANCE_TYPE
                                 ,MODEL_INSTANTIATION_TYPE
                                 ,HAS_FAILURES)
      VALUES (l_pseudo_hdr_id
             ,1
             ,'old batch'
             ,ANY_USAGE_ID
             ,'0'
             ,0
             ,ROOT
             ,BV_MODEL_TYPE
             ,'0');

      l_rec1_seq := config_input_list(config_input_list.FIRST).input_seq;
      IF l_log_stmt THEN
        l_msg := '1st rec input_seq=' || l_rec1_seq;
        CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_STATEMENT);
        l_msg := 'pseudo hdr=' || l_pseudo_hdr_id;
        CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_STATEMENT);
      END IF;

      l_nDebug := 2;
      l_hdr_id := 0;
      l_pseudo_item_id := -1;
      FOR i IN config_input_list.FIRST..config_input_list.LAST
      LOOP
        IF config_input_list(i).component_code IS NULL OR
           config_input_list(i).quantity IS NULL  THEN
          l_msg := 'The component code or quantity passed in rec ' || i || ' is NULL';
          CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_ERROR);
          RAISE INVALID_OPTION_EXCEPTION;
        END IF;

        l_quantity_tbl(i) := config_input_list(i).quantity;

        IF l_rec1_seq IS NULL THEN
          l_input_seq_tbl(i) := i;
        ELSE
          l_input_seq_tbl(i) := config_input_list(i).input_seq;
        END IF;

        IF (config_input_list(i).config_item_id IS NOT NULL) THEN
          l_item_id := config_input_list(i).config_item_id;
          IF l_hdr_id = 0 THEN
            get_config_hdr(init_message, l_hdr_id, l_rev_nbr);
            IF l_log_stmt THEN
              l_msg := 'hdr in init msg=' || l_hdr_id || ',' || l_rev_nbr;
              CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_STATEMENT);
            END IF;
          END IF;
          get_ext_comp_code(l_hdr_id, l_rev_nbr, l_item_id, l_ext_comp_code, l_item_depth);
          IF l_ext_comp_code IS NULL OR l_ext_comp_code = '' THEN
            l_msg := 'The config item id '||l_item_id||' passed in rec '||i||' for config header id '||
                     l_hdr_id || ' and rev nbr ' || l_rev_nbr || ' is invalid';
            CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_ERROR);
            RAISE INVALID_OPTION_EXCEPTION;
          END IF;
        ELSE
          append_instance_nbr(config_input_list(i).component_code, l_ext_comp_code, l_item_depth);
          l_item_id := l_pseudo_item_id;
          l_pseudo_item_id := l_pseudo_item_id - 1;
        END IF;

        l_item_id_tbl(i) := l_item_id;
        l_ecc_tbl(i) := l_ext_comp_code;
        l_item_depth_tbl(i) := l_item_depth;
      END LOOP;

      l_nDebug := 3;
      FORALL i IN l_item_id_tbl.first .. l_item_id_tbl.lAST
        INSERT INTO CZ_CONFIG_ITEMS(config_hdr_id
                                   ,config_rev_nbr
                                   ,config_item_id
                                   ,sequence_nbr
                                   ,node_identifier
                                   ,item_num_val
                                   ,value_type_code
                                   ,INSTANCE_HDR_ID
                                   ,INSTANCE_REV_NBR
                                   ,COMPONENT_INSTANCE_TYPE
                                   ,CONFIG_DELTA
                                   )
        VALUES (l_pseudo_hdr_id
               ,1
               ,l_item_id_tbl(i)
               ,l_input_seq_tbl(i)
               ,l_ecc_tbl(i)
               ,l_quantity_tbl(i)
               ,BV_OPERATION_OLD
               ,l_pseudo_hdr_id
               ,1
               ,INCLUDED
               ,l_item_depth_tbl(i)
               );

      l_nDebug := 4;
      -- Ideally reorder inputs only if the sequences are generated locally
      -- But the sequences OM passes to us are actually meaningless. So
      -- unfortunately we have to take this performance hit and to reorder
      -- the inputsregardless of who generates the seq
      -- IF l_rec1_seq IS NULL THEN
      l_item_id_tbl.delete;
      l_input_seq_tbl.delete;
      SELECT config_item_id BULK COLLECT INTO l_item_id_tbl
      FROM   cz_config_items
      WHERE  config_hdr_id = l_pseudo_hdr_id
      AND    config_rev_nbr = 1
      ORDER BY config_delta, sequence_nbr;

      FOR i IN l_item_id_tbl.FIRST .. l_item_id_tbl.LAST LOOP
        l_input_seq_tbl(i) := i;
      END LOOP;

      FORALL i IN l_item_id_tbl.FIRST .. l_item_id_tbl.LAST
        UPDATE cz_config_items
        SET    sequence_nbr = l_input_seq_tbl(i)
        WHERE  config_hdr_id = l_pseudo_hdr_id
        AND    config_rev_nbr = 1
        AND    config_item_id = l_item_id_tbl(i);
      -- END IF;

    EXCEPTION
      WHEN INVALID_OPTION_EXCEPTION THEN
        validation_status:=INVALID_OPTION_REQUEST;
        ROLLBACK;
        RETURN;

      WHEN OTHERS THEN
        validation_status:=DATABASE_ERROR;
        ROLLBACK;
        l_msg := SQLERRM;
        CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg, FND_LOG.LEVEL_ERROR);
        RETURN;
    END;

  END IF;

  l_nDebug := 5;
  validate(l_pseudo_hdr_id
          ,URL
          ,init_message
          ,p_validation_type
          ,validation_status
          ,config_messages
          ,v_detailed_error_message
          );

   CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, 'validation status: ' ||
                      validation_status||v_detailed_error_message, FND_LOG.LEVEL_PROCEDURE);

  l_nDebug := 6;
  -- this block would set the config status status in the terminate message to FALSE
  -- if the config_input_list is empty and validation_status is CONFIG_PROCESSED
  -- and if there are configured item changes. The changes are logged to cz_config_messages
  IF validation_status = CONFIG_PROCESSED AND p_validation_type = CZ_API_PUB.VALIDATE_ORDER AND
     config_input_list.COUNT = 0 THEN
-- Added 2 new params as per the Quoting ER#9348864 as said earlier
    check_deltas(init_message,p_check_config_flag,config_messages,l_delta_status,x_return_config_changed);
    IF (l_delta_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE DELTA_CHECK_FAILURE;
    END IF;
  END IF;

  l_nDebug := 7;
  -- delete based on setting in cz_db_settings
  l_check_db_setting := TRUE;
  IF validation_status = UTL_HTTP_INIT_FAILED OR
     validation_status = UTL_HTTP_REQUEST_FAILED THEN
    l_check_db_setting := FALSE;
  END IF;

  delete_bv_records(l_pseudo_hdr_id, l_check_db_setting, FALSE);

EXCEPTION
  WHEN DELTA_CHECK_FAILURE THEN
    validation_status:=CONFIG_EXCEPTION;
    COMMIT;
    l_msg := 'DELTA_CHECK_FAILURE';
    CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg||v_detailed_error_message, FND_LOG.LEVEL_ERROR);

  WHEN OTHERS THEN
    delete_bv_records(l_pseudo_hdr_id, FALSE, FALSE);
    validation_status:=CONFIG_EXCEPTION;
    l_msg := SQLERRM;
    CZ_UTILS.log_report(G_PKG_NAME, l_api_name, l_nDebug, l_msg||v_detailed_error_message, FND_LOG.LEVEL_ERROR);
END validate; -- old

------------------------------------------------------------------------------------------
FUNCTION model_for_item(inventory_item_id   NUMBER,
            organization_id     NUMBER,
            config_creation_date    DATE,
            user_id         NUMBER,
            responsibility_id   NUMBER,
            calling_application_id  NUMBER
            )

RETURN NUMBER
IS
BEGIN
  RETURN config_model_for_item(inventory_item_id, organization_id,
                               config_creation_date, calling_application_id,
                               NULL);
END model_for_item;

--------------------------------------------------------------------------------------------
FUNCTION config_model_for_item (inventory_item_id       IN  NUMBER,
                organization_id         IN  NUMBER,
                config_lookup_date      IN  DATE,
                calling_application_id      IN  NUMBER,
                usage_name          IN  VARCHAR2,
                publication_mode        IN  VARCHAR2 DEFAULT NULL,
                language            IN  VARCHAR2 DEFAULT NULL
                )
RETURN NUMBER
IS

v_publication_id        NUMBER;

BEGIN

  v_publication_id := publication_for_item(inventory_item_id,organization_id,
                       config_lookup_date,
                       calling_application_id,usage_name,
                       publication_mode,
                       language);

  IF v_publication_id IS NULL THEN
    RETURN NULL;
  ELSE
    RETURN model_for_publication_id(v_publication_id);
  END IF;

END config_model_for_item;

--------------------------------------------------------------------------------
FUNCTION config_models_for_items (inventory_item_id     IN  NUMBER_TBL_TYPE,
                organization_id         IN  NUMBER_TBL_TYPE,
                config_lookup_date      IN  DATE_TBL_TYPE,
                calling_application_id      IN  NUMBER_TBL_TYPE,
                usage_name          IN  VARCHAR2_TBL_TYPE,
                publication_mode        IN  VARCHAR2_TBL_TYPE,
                language            IN  VARCHAR2_TBL_TYPE
                )
RETURN NUMBER_TBL_TYPE
IS

t_models_for_items   NUMBER_TBL_TYPE := NUMBER_TBL_TYPE();

nof_inventory_item_id   NUMBER;
nof_organization_id NUMBER;
nof_config_lookup_date  NUMBER;
nof_calling_application_id  NUMBER;
nof_usage_name  NUMBER;
nof_language    NUMBER;
nof_publication_mode    NUMBER;

BEGIN

  nof_inventory_item_id := inventory_item_id.COUNT;
  nof_organization_id := organization_id.COUNT;
  nof_config_lookup_date := config_lookup_date.COUNT;
  nof_calling_application_id := calling_application_id.COUNT;
  nof_usage_name := usage_name.COUNT;
  nof_language := language.COUNT;
  nof_publication_mode := publication_mode.COUNT;

  IF ( (nof_inventory_item_id <> nof_organization_id) OR
       (nof_inventory_item_id <> nof_config_lookup_date) OR
       (nof_inventory_item_id <> nof_calling_application_id) OR
       (nof_inventory_item_id <> nof_usage_name) OR
       (nof_inventory_item_id <> nof_language) OR
       (nof_inventory_item_id <> nof_publication_mode) ) THEN
    RAISE WRONG_ARRAYS_LENGTH;
  END IF;

  t_models_for_items.extend(nof_inventory_item_id);

  FOR i IN 1..nof_inventory_item_id LOOP
    t_models_for_items(i) := config_model_for_item(inventory_item_id(i), organization_id(i),
                                                config_lookup_date(i), calling_application_id(i),
                                                usage_name(i), publication_mode(i), language(i));
  END LOOP;
  RETURN t_models_for_items;
EXCEPTION
  WHEN WRONG_ARRAYS_LENGTH THEN
    -- xERROR:=CZ_UTILS.REPORT('The size of input arrays should be the same',1,'CZ_CF_API.CONFIG_MODELS_FOR_ITEMS',11222);
    cz_utils.log_report('CZ_CF_API', 'config_models_for_items', null,
                        'The size of input arrays should be the same',
                         fnd_log.LEVEL_EXCEPTION);
    RAISE_APPLICATION_ERROR (-20001,
      'The size of input arrays should be the same');
 WHEN OTHERS THEN
    -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_CF_API.CONFIG_MODELS_FOR_ITEMS',11222);
    cz_utils.log_report('CZ_CF_API', 'config_models_for_items', null, SQLERRM,
                         fnd_log.LEVEL_UNEXPECTED);
END config_models_for_items;

----------------------------------------------------------------------------------------
-- Returns the ui (ui_def_id and ui type) specified by input publication_id.
-- If input publication_id is null, inventory_item_id and organization_id will be used
-- to decide whether to return the seeded native bom ui or not.
--
FUNCTION config_ui_for_item_pvt(p_publication_id     IN NUMBER
                               ,px_ui_type  IN OUT NOCOPY VARCHAR2
                               ,p_inventory_item_id  IN NUMBER
                               ,p_organization_id   IN NUMBER
                               )
    RETURN NUMBER
IS
  l_ui_style      CZ_MODEL_PUBLICATIONS.ui_style%TYPE;
  l_pub_ui_style  CZ_MODEL_PUBLICATIONS.ui_style%TYPE;
  l_dummy         INTEGER;

BEGIN
  IF p_publication_id IS NULL THEN
    IF p_inventory_item_id IS NOT NULL AND p_organization_id IS NOT NULL THEN
      BEGIN
        SELECT 1 INTO l_dummy
        FROM mtl_system_items
        WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND bom_item_type = BOM_ITEM_TYPE_MODEL;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          px_ui_type := NULL;
          RETURN NULL;
      END;

      px_ui_type := NATIVEBOM_UI_TYPE;
      RETURN NATIVEBOM_UI_DEF;
    ELSE
      px_ui_type := NULL;
      RETURN NULL;
    END IF;

  ELSE
    SELECT ui_style INTO l_pub_ui_style
    FROM CZ_MODEL_PUBLICATIONS
    WHERE publication_id = p_publication_id;

    IF px_ui_type IS NOT NULL THEN
      -- If input ui_type is APPLET, either APPLET or DHTML or JRAD is OK.
      -- If input ui_type is JRAD or DHTML, the UI associated with the publication
      -- MUST be either JRAD, or DHTML, or WEGA.  If not, return NULL.
      l_ui_style := ui_style_from_ui_type(px_ui_type);
      IF l_ui_style IS NULL OR l_ui_style<>UI_STYLE_APPLET AND l_pub_ui_style=UI_STYLE_APPLET THEN
        px_ui_type := NULL;
        RETURN NULL;
      END IF;
    END IF;

    px_ui_type := ui_type_from_ui_style(l_pub_ui_style);
    RETURN ui_for_publication_id(p_publication_id);
  END IF;
END config_ui_for_item_pvt;

--------------------------------------------------------------------------------------------
FUNCTION ui_for_item(inventory_item_id   NUMBER,
             organization_id         NUMBER,
             config_creation_date    DATE,
             ui_type             VARCHAR2,
             user_id             NUMBER,
             responsibility_id       NUMBER,
             calling_application_id  NUMBER
            )
RETURN NUMBER
IS
   v_ui_type VARCHAR2(30) := ui_type;
   l_return_ui_def_id cz_ui_defs.ui_def_id%TYPE;
   l_return_ui_profile VARCHAR2(3);
BEGIN
  l_return_ui_def_id := config_ui_for_item(inventory_item_id, organization_id,
                            config_creation_date, v_ui_type,
                            calling_application_id, NULL);
  IF ( (l_return_ui_def_id IS NOT NULL)
	 AND (l_return_ui_def_id = NATIVEBOM_UI_DEF) ) THEN
       l_return_ui_profile := FND_PROFILE.value('CZGENERICBOMUIPROFILE');
       IF (UPPER(l_return_ui_profile) IN ('N', 'NO') )  THEN
	   l_return_ui_def_id := NULL;
       END IF;
  END IF;
  RETURN l_return_ui_def_id;
END ui_for_item;
------------------------------------------------------------------------------

FUNCTION config_ui_for_item(inventory_item_id       IN  NUMBER,
                            organization_id         IN  NUMBER,
                            config_lookup_date      IN  DATE,
                            ui_type                 IN OUT NOCOPY  VARCHAR2,
                            calling_application_id  IN  NUMBER,
                            usage_name              IN  VARCHAR2,
                            publication_mode        IN  VARCHAR2 DEFAULT NULL,
                            language                IN  VARCHAR2 DEFAULT NULL
                           )
RETURN NUMBER
IS
  l_publication_id  NUMBER;

BEGIN
   l_publication_id := publication_for_item(inventory_item_id,
                                            organization_id,
                                            config_lookup_date,
                                            calling_application_id,
                                            usage_name,
                                            publication_mode,
                                            language);
  RETURN config_ui_for_item_pvt(l_publication_id, ui_type, inventory_item_id,
                                organization_id);
END config_ui_for_item;

---------------------------------------------------------------------------

FUNCTION config_ui_for_item_lf (inventory_item_id   IN  NUMBER,
                    organization_id     IN  NUMBER,
                    config_lookup_date  IN  DATE,
                    ui_type         IN OUT NOCOPY  VARCHAR2,
                    calling_application_id  IN  NUMBER,
                    usage_name          IN  VARCHAR2,
                    look_and_feel       OUT NOCOPY VARCHAR2,
                    publication_mode        IN  VARCHAR2 DEFAULT NULL,
                    language            IN  VARCHAR2 DEFAULT NULL
                    )
RETURN NUMBER
IS

v_ui_def_id     NUMBER;

BEGIN
  v_ui_def_id := config_ui_for_item(inventory_item_id, organization_id, config_lookup_date,
        ui_type, calling_application_id, usage_name, publication_mode, language);

  IF v_ui_def_id IS NULL THEN
    look_and_feel := NULL;
  ELSE
    SELECT look_and_feel INTO look_and_feel FROM cz_ui_defs WHERE ui_def_id = v_ui_def_id;
  END IF;
  RETURN v_ui_def_id;

END config_ui_for_item_lf;

---------------------------------------------------------------------------

FUNCTION config_uis_for_items (inventory_item_id    IN  NUMBER_TBL_TYPE,
                     organization_id            IN  NUMBER_TBL_TYPE,
                     config_lookup_date     IN  DATE_TBL_TYPE,
                     ui_type                IN OUT NOCOPY  VARCHAR2_TBL_TYPE,
                     calling_application_id     IN  NUMBER_TBL_TYPE,
                     usage_name             IN  VARCHAR2_TBL_TYPE,
                     publication_mode       IN  VARCHAR2_TBL_TYPE,
                     language               IN  VARCHAR2_TBL_TYPE
                    )
RETURN NUMBER_TBL_TYPE
IS
t_uis_for_items NUMBER_TBL_TYPE := NUMBER_TBL_TYPE();

nof_inventory_item_id   NUMBER;
nof_organization_id NUMBER;
nof_config_lookup_date  NUMBER;
nof_ui_type     NUMBER;
nof_calling_application_id  NUMBER;
nof_usage_name  NUMBER;
nof_language    NUMBER;
nof_publication_mode    NUMBER;

BEGIN

  nof_inventory_item_id := inventory_item_id.COUNT;
  nof_organization_id := organization_id.COUNT;
  nof_config_lookup_date := config_lookup_date.COUNT;
  nof_ui_type := ui_type.COUNT;
  nof_calling_application_id := calling_application_id.COUNT;
  nof_usage_name := usage_name.COUNT;
  nof_language := language.COUNT;
  nof_publication_mode := publication_mode.COUNT;

  IF ( (nof_inventory_item_id <> nof_organization_id) OR
       (nof_inventory_item_id <> nof_config_lookup_date) OR
       (nof_inventory_item_id <> nof_ui_type) OR
       (nof_inventory_item_id <> nof_calling_application_id) OR
       (nof_inventory_item_id <> nof_usage_name) OR
       (nof_inventory_item_id <> nof_language) OR
       (nof_inventory_item_id <> nof_publication_mode) ) THEN
    RAISE WRONG_ARRAYS_LENGTH;
  END IF;
  t_uis_for_items.extend(nof_inventory_item_id);
  FOR i IN 1..nof_inventory_item_id LOOP
    t_uis_for_items(i) := config_ui_for_item(inventory_item_id(i), organization_id(i),
                                    config_lookup_date(i), ui_type(i), calling_application_id(i),
                                    usage_name(i), publication_mode(i), language(i));
  END LOOP;
  RETURN t_uis_for_items;

EXCEPTION
  WHEN WRONG_ARRAYS_LENGTH THEN
    -- xERROR:=CZ_UTILS.REPORT('The size of input arrays should be the same',1,'CZ_CF_API.CONFIG_UIS_FOR_ITEMS',11222);
    cz_utils.log_report('CZ_CF_API', 'config_uis_for_items', null,
                        'The size of input arrays should be the same',
                         fnd_log.LEVEL_EXCEPTION);
    RAISE_APPLICATION_ERROR (-20001,
      'The size of input arrays should be the same');
  WHEN OTHERS THEN
    -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_CF_API.CONFIG_UIS_FOR_ITEMS',11222);
    cz_utils.log_report('CZ_CF_API', 'config_uis_for_items', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
END config_uis_for_items;

---------------------------------------------------------------------------
FUNCTION model_for_publication_id (publication_id NUMBER)
RETURN NUMBER
IS

v_publication_id    NUMBER := publication_id;
v_model_id      NUMBER ;

BEGIN
    SELECT model_id
    INTO   v_model_id
    FROM   CZ_MODEL_PUBLICATIONS
    WHERE  CZ_MODEL_PUBLICATIONS.publication_id = v_publication_id
    AND    CZ_MODEL_PUBLICATIONS.export_status = 'OK'
    AND    CZ_MODEL_PUBLICATIONS.deleted_flag = '0';

    IF v_model_id IS NULL THEN
       RETURN NULL;
    ELSE
       RETURN v_model_id;
    END IF;

END;
--------------------------------------------------------------------------------------------------------------

FUNCTION ui_for_publication_id (publication_id NUMBER)
RETURN NUMBER
IS

v_publication_id    NUMBER := publication_id;
v_ui_def_id     NUMBER ;

BEGIN
    SELECT ui_def_id
    INTO   v_ui_def_id
    FROM   CZ_MODEL_PUBLICATIONS
    WHERE  CZ_MODEL_PUBLICATIONS.publication_id = v_publication_id
    AND    CZ_MODEL_PUBLICATIONS.export_status = 'OK'
    AND    CZ_MODEL_PUBLICATIONS.deleted_flag = '0';

    IF v_ui_def_id IS NULL THEN
       RETURN NULL;
    ELSE
       RETURN v_ui_def_id;
    END IF;
END;

----------------------------------------------------------------------------------------------------------
FUNCTION config_model_for_product ( product_key     IN  VARCHAR2,
                    config_lookup_date  IN  DATE,
                    calling_application_id  IN  NUMBER,
                    usage_name          IN  VARCHAR2,
                    publication_mode        IN  VARCHAR2 DEFAULT NULL,
                    language            IN  VARCHAR2 DEFAULT NULL
                  )
RETURN NUMBER
IS

  v_publication_id NUMBER;

BEGIN

    v_publication_id := publication_for_product(product_key,
                                                config_lookup_date,
                                                calling_application_id,
                                                usage_name,
                                                publication_mode,
                                                language);

    IF v_publication_id IS NULL THEN
          RETURN NULL;
        ELSE
          RETURN model_for_publication_id(v_publication_id);
        END IF;

END config_model_for_product;

--------------------------------------------------------------------------------------------
FUNCTION config_models_for_products ( product_key   IN  VARCHAR2_TBL_TYPE,
                    config_lookup_date      IN  DATE_TBL_TYPE,
                    calling_application_id      IN  NUMBER_TBL_TYPE,
                    usage_name          IN  VARCHAR2_TBL_TYPE,
                    publication_mode        IN  VARCHAR2_TBL_TYPE,
                    language            IN  VARCHAR2_TBL_TYPE
                  )
RETURN NUMBER_TBL_TYPE
IS

t_models_for_products   NUMBER_TBL_TYPE := NUMBER_TBL_TYPE();

nof_product_key NUMBER;
nof_config_lookup_date  NUMBER;
nof_calling_application_id  NUMBER;
nof_usage_name  NUMBER;
nof_language    NUMBER;
nof_publication_mode    NUMBER;

BEGIN

  nof_product_key := product_key.COUNT;
  nof_config_lookup_date := config_lookup_date.COUNT;
  nof_calling_application_id := calling_application_id.COUNT;
  nof_usage_name := usage_name.COUNT;
  nof_language := language.COUNT;
  nof_publication_mode := publication_mode.COUNT;

  IF ( (nof_product_key <> nof_config_lookup_date) OR
       (nof_product_key <> nof_calling_application_id) OR
       (nof_product_key <> nof_usage_name) OR
       (nof_product_key <> nof_language) OR
       (nof_product_key <> nof_publication_mode) ) THEN
    RAISE WRONG_ARRAYS_LENGTH;
  END IF;

  t_models_for_products.extend(nof_product_key);

  FOR i IN 1..nof_product_key LOOP
    t_models_for_products(i) := config_model_for_product(product_key(i), config_lookup_date(i), calling_application_id(i), usage_name(i), publication_mode(i), language(i));
  END LOOP;
  RETURN t_models_for_products;
EXCEPTION
  WHEN WRONG_ARRAYS_LENGTH THEN
    -- xERROR:=CZ_UTILS.REPORT('The size of input arrays should be the same',1,'CZ_CF_API.CONFIG_MODELS_FOR_PRODUCTS',11222);
    cz_utils.log_report('CZ_CF_API', 'config_models_for_products', null,
       'The size of input arrays should be the same', fnd_log.LEVEL_EXCEPTION);
    RAISE_APPLICATION_ERROR (-20001,
      'The size of input arrays should be the same');
 WHEN OTHERS THEN
    -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_CF_API.CONFIG_MODELS_FOR_PRODUCTS',11222);
    cz_utils.log_report('CZ_CF_API', 'config_models_for_products', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
END config_models_for_products;

-----------------------------------------------------------------------------------

FUNCTION config_ui_for_product(product_key             IN  VARCHAR2,
                               config_lookup_date      IN  DATE,
                               ui_type                 IN OUT NOCOPY  VARCHAR2,
                               calling_application_id  IN  NUMBER,
                               usage_name              IN  VARCHAR2,
                               publication_mode        IN  VARCHAR2 DEFAULT NULL,
                               language                IN  VARCHAR2 DEFAULT NULL
                              )
RETURN NUMBER
IS
  l_publication_id  NUMBER;

  l_inventory_item_id  NUMBER := NULL;
  l_organization_id    NUMBER := NULL;
  l_colon_pos          INTEGER;

BEGIN
  l_publication_id := publication_for_product(product_key,
                                              config_lookup_date,
                                              calling_application_id,
                                              usage_name,
                                              publication_mode,
                                              language);

  IF l_publication_id IS NULL THEN
    l_colon_pos := instr(product_key, ':');
    IF l_colon_pos > 0 THEN
      l_organization_id := cz_utils.conv_num(substr(product_key, 1, l_colon_pos-1));
      l_inventory_item_id := cz_utils.conv_num(substr(product_key, l_colon_pos+1));
    END IF;

    IF l_organization_id IS NULL OR l_inventory_item_id IS NULL THEN
      ui_type := NULL;
      RETURN NULL;
    END IF;
  END IF;

  RETURN config_ui_for_item_pvt(l_publication_id, ui_type, l_inventory_item_id,
                                l_organization_id);
END config_ui_for_product;

--------------------------------------------------------------------------------------------

FUNCTION config_uis_for_products (product_key       IN  VARCHAR2_TBL_TYPE,
                        config_lookup_date      IN  DATE_TBL_TYPE,
                        ui_type             IN OUT NOCOPY  VARCHAR2_TBL_TYPE,
                        calling_application_id      IN  NUMBER_TBL_TYPE,
                        usage_name          IN  VARCHAR2_TBL_TYPE,
                        publication_mode        IN  VARCHAR2_TBL_TYPE,
                        language            IN  VARCHAR2_TBL_TYPE
                       )
RETURN NUMBER_TBL_TYPE
IS

t_uis_for_products   NUMBER_TBL_TYPE := NUMBER_TBL_TYPE();

nof_product_key NUMBER;
nof_config_lookup_date  NUMBER;
nof_ui_type NUMBER;
nof_calling_application_id  NUMBER;
nof_usage_name  NUMBER;
nof_language    NUMBER;
nof_publication_mode    NUMBER;

BEGIN

  nof_product_key := product_key.COUNT;
  nof_config_lookup_date := config_lookup_date.COUNT;
  nof_ui_type := ui_type.COUNT;
  nof_calling_application_id := calling_application_id.COUNT;
  nof_usage_name := usage_name.COUNT;
  nof_language := language.COUNT;
  nof_publication_mode := publication_mode.COUNT;

  IF ( (nof_product_key <> nof_config_lookup_date) OR
       (nof_product_key <> nof_ui_type) OR
       (nof_product_key <> nof_calling_application_id) OR
       (nof_product_key <> nof_usage_name) OR
       (nof_product_key <> nof_language) OR
       (nof_product_key <> nof_publication_mode) ) THEN
    RAISE WRONG_ARRAYS_LENGTH;
  END IF;

  t_uis_for_products.extend(nof_product_key);

  FOR i IN 1..nof_product_key LOOP
    t_uis_for_products(i) := config_ui_for_product(product_key(i), config_lookup_date(i),
                ui_type(i), calling_application_id(i), usage_name(i), publication_mode(i), language(i));
  END LOOP;
  RETURN t_uis_for_products;
EXCEPTION
  WHEN WRONG_ARRAYS_LENGTH THEN
    -- xERROR:=CZ_UTILS.REPORT('The size of input arrays should be the same',1,'CZ_CF_API.CONFIG_UIS_FOR_PRODUCTS',11222);
    cz_utils.log_report('CZ_CF_API', 'config_uis_for_products', null,
       'The size of input arrays should be the same', fnd_log.LEVEL_EXCEPTION);
    RAISE_APPLICATION_ERROR (-20001,
      'The size of input arrays should be the same');
 WHEN OTHERS THEN
    -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_CF_API.CONFIG_UIS_FOR_PRODUCTS',11222);
    cz_utils.log_report('CZ_CF_API', 'config_uis_for_products', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
END config_uis_for_products;

-----------------------------------------------------------------------------------

FUNCTION publication_for_item    ( inventory_item_id            IN  NUMBER,
                           organization_id          IN  NUMBER,
                         config_lookup_date         IN  DATE,
                         calling_application_id         IN  NUMBER,
                               usage_name               IN  VARCHAR2,
                         publication_mode           IN  VARCHAR2 DEFAULT NULL,
                         language               IN  VARCHAR2 DEFAULT NULL
                    )
RETURN NUMBER
IS

v_inventory_item_id     NUMBER      := inventory_item_id     ;
v_organization_id   NUMBER      := organization_id   ;
v_config_lookup_date    DATE            := config_lookup_date    ;
v_usage_id      NUMBER                   ;
v_language      VARCHAR2(4) := language;
v_publication_mode  VARCHAR2(1)     := publication_mode  ;
v_usage_name        VARCHAR2(255)   := usage_name        ;
v_application_id    NUMBER   := calling_application_id;
v_source_target_flag    VARCHAR2(3) := 'T'           ;
v_publication_id    NUMBER                   ;
v_pb_count      NUMBER                   ;
c_inventory_item_id     NUMBER ;
c_organization_id       NUMBER;

CURSOR pub_cur IS
            SELECT publication_id
            FROM   cz_model_applicabilities_v
            WHERE  inventory_item_id     = v_inventory_item_id
            AND    bom_explosion_org_id  = v_organization_id
            AND    UPPER(publication_mode)   = LTRIM(RTRIM(UPPER(v_publication_mode)))
            AND    fnd_application_id    = v_application_id
            AND    usage_id          = v_usage_id
            AND    Source_Target_Flag        = v_source_target_flag
            AND    deleted_flag      = '0'
            AND    language         = v_language
                AND (start_date <= v_config_lookup_date)
                AND (v_config_lookup_date < disable_date)
            ORDER BY start_date DESC;

  CURSOR no_appl_pub_cur IS
            SELECT publication_id
            FROM   cz_model_applicabilities_v
            WHERE  inventory_item_id     = v_inventory_item_id
            AND    bom_explosion_org_id  = v_organization_id
            AND    UPPER(publication_mode) = LTRIM(RTRIM(UPPER(v_publication_mode)))
            AND    usage_id = v_usage_id
            AND    Source_Target_Flag = v_source_target_flag
            AND    deleted_flag = '0'
            AND    language = v_language
            AND    start_date <= v_config_lookup_date
            AND    v_config_lookup_date < disable_date
            ORDER BY start_date DESC;

BEGIN

    -- Required because Istore passes FND_API.G_MISS_DATE
    IF v_config_lookup_date = FND_API.G_MISS_DATE THEN
        v_config_lookup_date := SYSDATE;
    END IF;

    IF v_language IS NULL THEN
        SELECT userenv('LANG') INTO v_language FROM dual;
    END IF;

  -- check usage_name: if null, get the profile option value from db
  IF v_usage_name IS NULL THEN
    fnd_profile.get('CZ_PUBLICATION_USAGE', v_usage_name);
  END IF;

  v_usage_id := usage_id_from_usage_name(v_usage_name);

  -- Keep these values to lookup common bill, if required
  if (c_application_id is null) then
    c_application_id := calling_application_id;
  end if;
  if (c_usage_name is null) then
    c_usage_name := v_usage_name;
  end if;

  -- check publication mode: if null, get the profile option value from db.
  --                         if still null, use the default 'P'.
  IF v_publication_mode IS NULL THEN
    fnd_profile.get('CZ_PUBLICATION_MODE', v_publication_mode);
    IF v_publication_mode IS NULL THEN
      v_publication_mode := 'P';
    END IF;
  END IF;

  v_pb_count := 0;
  IF v_application_id IS NULL THEN
    OPEN no_appl_pub_cur;
    LOOP
      EXIT WHEN (no_appl_pub_cur%NOTFOUND OR v_pb_count > 0);
      FETCH no_appl_pub_cur INTO v_publication_id;
      v_pb_count := v_pb_count + 1;
    END LOOP;
    CLOSE no_appl_pub_cur;
  ELSE
    OPEN pub_cur;
    LOOP
        EXIT WHEN  ( (pub_cur%NOTFOUND) OR (v_pb_count > 0) ) ;
        FETCH pub_cur INTO v_publication_id;
        v_pb_count := v_pb_count + 1;
    END LOOP;
    CLOSE pub_cur;
  END IF;

    -- if not found check for "any usage" and/or "any application" publication
    --                      or "common bill"
    IF v_publication_id IS NULL THEN
      IF v_usage_id <> ANY_USAGE_ID THEN

        -- passing NULL is NOT the same as passing "any usage"
        RETURN publication_for_item(v_inventory_item_id, v_organization_id,
                                    v_config_lookup_date, v_application_id,
                                    ANY_USAGE_NAME, v_publication_mode, v_language);
      ELSIF v_application_id IS NOT NULL AND v_application_id <> ANY_APPLICATION_ID THEN
        RETURN publication_for_item(v_inventory_item_id, v_organization_id,
                                    v_config_lookup_date, ANY_APPLICATION_ID,
                                    v_usage_name, v_publication_mode, v_language);
      ELSE
        BEGIN
        -- else get publication id of the common bill, if any
        common_bill_for_item(v_inventory_item_id, v_organization_id,
                            c_inventory_item_id, c_organization_id);
        IF (((c_inventory_item_id is not null) and (c_organization_id is not null))
            and ((c_inventory_item_id <> v_inventory_item_id) or (c_organization_id <> v_organization_id))) THEN
            RETURN publication_for_item(c_inventory_item_id, c_organization_id,
                                    v_config_lookup_date, c_application_id,
                                    c_usage_name, v_publication_mode, v_language);
        ELSE
                c_application_id := null;
                c_usage_name := null;
            RETURN NULL;
        END IF;
        END;
      END IF;
    ELSE
        c_application_id := null;
        c_usage_name := null;
          RETURN v_publication_id;
        END IF;
END;

-----------------------------------------------------------------------------
-- Retrieves inventory_item_id and organization_id of root bom referenced
-- by the non bom model specified by the input model_id
-- private
PROCEDURE find_root_bom_inv_org(p_model_id IN NUMBER
                               ,x_inventory_item_id OUT NOCOPY NUMBER
                               ,x_organization_id OUT NOCOPY NUMBER)
IS
   CURSOR reference_cursor IS
      SELECT prj.inventory_item_id, prj.organization_id
      FROM cz_devl_projects prj, cz_model_ref_expls expl
      WHERE expl.model_id = p_model_id
      AND expl.ps_node_type = PS_NODE_TYPE_REFERENCE
      AND expl.deleted_flag = '0'
      AND prj.devl_project_id = expl.component_id
      AND prj.deleted_flag = '0'
      AND prj.inventory_item_id IS NOT NULL
      AND prj.organization_id IS NOT NULL
      ORDER BY expl.node_depth;
BEGIN
   FOR ref_rec IN reference_cursor LOOP
      EXIT WHEN reference_cursor%rowcount > 1 OR reference_cursor%NOTFOUND;
      x_inventory_item_id := ref_rec.inventory_item_id;
      x_organization_id := ref_rec.organization_id;
   END LOOP;

END find_root_bom_inv_org;

-----------------------------------------------------------------------------
FUNCTION publication_for_saved_config (config_hdr_id          IN  NUMBER,
                                       config_rev_nbr         IN  NUMBER,
                                       config_lookup_date     IN  DATE,
                                       calling_application_id IN  NUMBER,
                                       usage_name             IN  VARCHAR2,
                                       publication_mode       IN  VARCHAR2 DEFAULT NULL,
                                       language               IN  VARCHAR2 DEFAULT NULL
                                      )
RETURN NUMBER
IS
  v_config_hdr_id         NUMBER   := config_hdr_id;
  v_config_rev_nbr        NUMBER   := config_rev_nbr;
  v_inventory_item_id     NUMBER;
  v_organization_id       NUMBER;
  v_product_key           cz_devl_projects.product_key%TYPE;
  v_component_id          NUMBER;
  v_model_identifier      cz_config_hdrs.model_identifier%TYPE;
  v_ndebug                NUMBER := 0;

BEGIN
  BEGIN
    SELECT component_id, model_identifier
    INTO v_component_id, v_model_identifier
    FROM CZ_CONFIG_HDRS
    WHERE config_hdr_id = v_config_hdr_id AND config_rev_nbr = v_config_rev_nbr;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;
  v_ndebug := 1;

  IF v_model_identifier IS NOT NULL THEN
    v_inventory_item_id := SUBSTR(v_model_identifier, 1, INSTR(v_model_identifier, ':')-1);
    v_organization_id := SUBSTR(v_model_identifier, INSTR(v_model_identifier, ':')+1,
                      INSTR(v_model_identifier, ':', 1, 2) - (INSTR(v_model_identifier, ':')+1));

  ELSE
    -- Old logic for finding orig_sys_ref is flawed: orig_sys_ref could be null but there
    -- is a publication. If the model is a non-BOM or a mixed model in which the root is non
    -- BOM orig_sys_ref will be NULL. In the customer case of bug 2475218, a BOM reference
    -- was added to a copy of the original non-bom model. The fix for bug 2475218 was:
    --   New logic if the root ps node orig_sys_ref lookup fails:
    -- a. Look for model corresponding to cz_config_hdrs.component_id. If it exists, find
    --    its BOM model.
    -- b. If a. fails, iterate over all projects that have persistent_project_id equal to
    --    the config's persistent_component_id.  Iterate until a root BOM model is found.

    -- The way using orig_sys_ref is still flawed: a not null orig_sys_ref might not be
    -- used to get inv and org for publication lookup. For example, the generic imported
    -- contract model in bug 3189078 has orig_sys_ref of 510:TEMPLATEMODELTOPNODE:202:B:4352
    -- on the root but inv and org cannot be retrieved from it for pub lookup.
    -- The fix for 3189078: using product_key/inv/org info (added to project table in 21)
    -- instead of using cz_ps_nodes.orig_sys_ref. The basic logic is still the same except
    -- if found a product_key on a root project, we will lookup pub by the key, which
    -- depends on the fact that product_key is carried over from source model to published
    -- model during publishing.
    -- Future? could just use one query by persistent_component_id (modify prj_cursor)
    -- do the whole lookup

    v_ndebug := 2;
    BEGIN
      SELECT inventory_item_id, organization_id, product_key
      INTO v_inventory_item_id, v_organization_id, v_product_key
      FROM CZ_DEVL_PROJECTS
      WHERE deleted_flag = '0' AND devl_project_id = v_component_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_ndebug := 3;
        BEGIN
          SELECT inventory_item_id, organization_id
          INTO v_inventory_item_id, v_organization_id
          FROM cz_config_items
          WHERE config_hdr_id = v_config_hdr_id AND config_rev_nbr = v_config_rev_nbr
          AND deleted_flag = '0' AND inventory_item_id IS NOT NULL
          AND to_char(inventory_item_id) = node_identifier;
        EXCEPTION
          WHEN no_data_found THEN
            v_inventory_item_id := NULL;
        END;
    END;
  END IF;

  IF v_product_key IS NOT NULL THEN
    RETURN publication_for_product(v_product_key
                                  ,config_lookup_date
                                  ,calling_application_id
                                  ,usage_name
                                  ,publication_mode
                                  ,language
                                  );

  ELSIF v_inventory_item_id IS NOT NULL THEN
    RETURN publication_for_item(v_inventory_item_id
                               ,v_organization_id
                               ,config_lookup_date
                               ,calling_application_id
                               ,usage_name
                               ,publication_mode
                               ,language
                               );
  ELSE
    RETURN NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    cz_utils.log_report('CZ_CF_API', 'publication_for_saved_config', v_ndebug,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
    RAISE;
END publication_for_saved_config;

-----------------------------------------------------------------------------

FUNCTION publication_for_product (product_key           IN VARCHAR2,
                          config_lookup_date        IN DATE,
                        calling_application_id      IN NUMBER,
                              usage_name            IN VARCHAR2,
                        publication_mode        IN VARCHAR2 DEFAULT NULL,
                        language            IN VARCHAR2 DEFAULT NULL
                     )
RETURN NUMBER
IS

v_product_key       VARCHAR2(40)    := product_key       ;
v_config_lookup_date    DATE            := config_lookup_date    ;
v_usage_id      NUMBER                   ;
v_publication_mode  VARCHAR2(1)     := publication_mode  ;
v_usage_name        VARCHAR2(255)   := usage_name        ;
v_language          VARCHAR2(4)     := language;
v_application_id    NUMBER   := calling_application_id;
v_source_target_flag    VARCHAR2(3) := 'T'           ;
v_publication_id    NUMBER                   ;
v_pb_count      NUMBER;
c_product_key   VARCHAR2(40);

CURSOR pub_cur IS
            SELECT publication_id
            FROM   cz_model_applicabilities_v
            WHERE  product_key       = v_product_key
            AND    UPPER(publication_mode)   = LTRIM(RTRIM(UPPER(v_publication_mode)))
            AND    fnd_application_id    = v_application_id
            AND    usage_id          = v_usage_id
            AND    Source_Target_Flag        = v_source_target_flag
            AND    deleted_flag      = '0'
            AND    language = v_language
                AND (start_date <= v_config_lookup_date)
                AND (v_config_lookup_date < disable_date)
            ORDER BY start_date DESC;
CURSOR no_appl_pub_cur IS
            SELECT publication_id
            FROM   cz_model_applicabilities_v
            WHERE  product_key       = v_product_key
            AND    UPPER(publication_mode)   = LTRIM(RTRIM(UPPER(v_publication_mode)))
            AND    usage_id          = v_usage_id
            AND    Source_Target_Flag        = v_source_target_flag
            AND    deleted_flag      = '0'
            AND    language = v_language
                AND (start_date <= v_config_lookup_date)
                AND (v_config_lookup_date < disable_date)
            ORDER BY start_date DESC;

BEGIN

    -- Required because Istore passes FND_API.G_MISS_DATE
    IF v_config_lookup_date = FND_API.G_MISS_DATE THEN
        v_config_lookup_date := SYSDATE;
    END IF;

    IF v_language IS NULL THEN
        SELECT userenv('LANG') INTO v_language FROM dual;
    END IF;

  -- check usage_name: if null, get the profile option value from db
  IF v_usage_name IS NULL THEN
    fnd_profile.get('CZ_PUBLICATION_USAGE', v_usage_name);
  END IF;

  v_usage_id := usage_id_from_usage_name(v_usage_name);

  -- Keep these values to lookup common bill, if required
  if (c_application_id is null) then
    c_application_id := calling_application_id;
  end if;
  if (c_usage_name is null) then
    c_usage_name := v_usage_name;
  end if;

  -- check publication mode: if null, get the profile option value from db.
  --                         if still null, use the default 'P'.
  IF v_publication_mode IS NULL THEN
    fnd_profile.get('CZ_PUBLICATION_MODE', v_publication_mode);
    IF v_publication_mode IS NULL THEN
      v_publication_mode := 'P';
    END IF;
  END IF;

  -- Bug 5103620- The count was not being
  -- initialized, and therefore restoring from saved configs
  -- returns the wrong publication record.

  v_pb_count := 0;
  IF v_application_id IS NULL THEN
    OPEN no_appl_pub_cur;
    LOOP
      EXIT WHEN (no_appl_pub_cur%NOTFOUND OR v_pb_count > 0);
      FETCH no_appl_pub_cur INTO v_publication_id;
      v_pb_count := v_pb_count + 1;
    END LOOP;
    CLOSE no_appl_pub_cur;
  ELSE
    OPEN pub_cur;
    LOOP
        EXIT WHEN  ( (pub_cur%NOTFOUND) OR (v_pb_count > 0) ) ;
        FETCH pub_cur INTO v_publication_id;
        v_pb_count := v_pb_count + 1;
    END LOOP;
    CLOSE pub_cur;
  END IF;

    -- if not found check for "any usage" and/or "any application"
    -- publications  or common bill
    IF v_publication_id IS NULL THEN
      IF v_usage_id <> ANY_USAGE_ID THEN
        -- passing NULL is NOT the same as passing "any usage"
        RETURN publication_for_product(v_product_key, v_config_lookup_date,
                           v_application_id, ANY_USAGE_NAME,
                           v_publication_mode, v_language);
      ELSIF v_application_id IS NOT NULL AND v_application_id <> ANY_APPLICATION_ID THEN
        RETURN publication_for_product(v_product_key, v_config_lookup_date,
                                       ANY_APPLICATION_ID,
                                       v_usage_name, v_publication_mode, v_language);
      ELSE
        common_bill_for_product(v_product_key, c_product_key);
        IF ((c_product_key is not null) and (c_product_key <> v_product_key)) THEN
            RETURN publication_for_product(c_product_key,v_config_lookup_date, c_application_id,
                                    c_usage_name, v_publication_mode, v_language);
        ELSE
            c_application_id := null;
                c_usage_name := null;
            RETURN NULL;
        END IF;
      END IF;
    ELSE
            c_application_id := null;
                c_usage_name := null;
          RETURN v_publication_id;
        END IF;
END;

-------------------------------------------------------

PROCEDURE DEFAULT_NEW_CFG_DATES(p_creation_date IN OUT NOCOPY DATE,
                                p_lookup_date IN OUT NOCOPY DATE,
                                p_effective_date IN OUT NOCOPY DATE) IS
BEGIN
  ----SELECT NVL(p_creation_date, SYSDATE) INTO p_creation_date FROM dual;
  IF (p_creation_date IS NULL) THEN
	p_creation_date := SYSDATE;
  END iF;

  ----SELECT NVL(p_lookup_date, p_creation_date) INTO p_lookup_date FROM dual;
  IF (p_lookup_date IS NULL) THEN
	p_lookup_date := p_creation_date;
  END IF;

 -----SELECT NVL(p_effective_date, p_creation_date) INTO p_effective_date FROM dual;
 IF (p_effective_date IS NULL) THEN
    p_effective_date := p_creation_date;
 END IF;

END DEFAULT_NEW_CFG_DATES;

-------------------------------------------------------

PROCEDURE DEFAULT_RESTORED_CFG_DATES(p_config_hdr_id IN NUMBER,
                                     p_config_rev_nbr IN NUMBER,
                                     p_creation_date IN OUT NOCOPY DATE,
                     p_lookup_date IN OUT NOCOPY DATE,
                                     p_effective_date IN OUT NOCOPY DATE) IS
  l_config_creation_date DATE;
  l_config_effective_date DATE;
  l_rest_cfg_lookup_setting cz_db_settings.value%TYPE := ' ';

BEGIN
  IF p_config_hdr_id IS NULL OR p_config_rev_nbr IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Config header ID AND config rev nbr ' ||
                            'are required arguments TO CZ_CF_API.' ||
                            'default_restored_cfg_dates');
  END IF;

  BEGIN
    SELECT creation_date, effective_date INTO l_config_creation_date,
      l_config_effective_date FROM CZ_CONFIG_HDRS WHERE config_hdr_id =
      p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       -- just set l_config_creation_date and l_config_effective_date
       -- to NULL, since it is not the role
       -- of this procedure to report missing configurations
       l_config_effective_date := NULL;
       l_config_creation_date := NULL;
  END;

  -- config creation date defaults to creation date of saved config
  SELECT NVL(p_creation_date, NVL(l_config_creation_date, SYSDATE)) INTO
    p_creation_date FROM dual;

  --- get value for setting_id RestoredConfigDefaultModelLookupDate
  --- bug# 2406680 fix for Agilent
  --- Section_name for this should be ORAAPPS_INTEGRATE.  Not adding this condition since it could break
  --- at a customer site.
  BEGIN
      SELECT value
      INTO   l_rest_cfg_lookup_setting
      FROM cz_db_settings WHERE setting_id = 'RestoredConfigDefaultModelLookupDate';
  EXCEPTION
  WHEN OTHERS THEN
	l_rest_cfg_lookup_setting := NULL;
  END;

  ---if l_rest_cfg_lookup_setting is set and p_lookup_date is NULL
  --- then use config creation date else use sysdate
  -- lookup date defaults to sysdate
  IF ( ( UPPER(LTRIM(RTRIM(l_rest_cfg_lookup_setting))) = UPPER('config_creation_date') )
       AND (p_lookup_date IS NULL) ) THEN
	p_lookup_date := p_creation_date ;
  ELSE
  	SELECT NVL(p_lookup_date, SYSDATE) INTO p_lookup_date FROM dual;
  END IF;
  -- effective date defaults to effective date of saved config
  SELECT NVL(p_effective_date, NVL(l_config_effective_date, SYSDATE)) INTO
    p_effective_date FROM dual;
END DEFAULT_RESTORED_CFG_DATES;

-------------------------------------------------
FUNCTION icx_session_ticket RETURN VARCHAR2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_user_id NUMBER;
  l_resp_id NUMBER;
  l_resp_appl_id NUMBER;
  l_session_id NUMBER;
  l_icx_exc EXCEPTION;
BEGIN
  l_user_id := fnd_profile.value('USER_ID');
  l_resp_id := fnd_profile.value('RESP_ID');
  l_resp_appl_id := fnd_profile.value('RESP_APPL_ID');
  l_session_id := FND_SESSION_MANAGEMENT.g_session_id;
  IF (l_session_id = -1) THEN
    IF l_user_id IS NULL OR l_resp_id IS NULL OR l_resp_appl_id IS NULL THEN
      RAISE l_icx_exc;
    END IF;
    l_session_id := fnd_session_management.createsession(l_user_id);
  END IF;

  IF l_session_id = -1 THEN
    RAISE l_icx_exc;
  ELSE
    COMMIT;
  END IF;
  RETURN icx_call.encrypt3(l_session_id);
EXCEPTION
  WHEN l_icx_exc THEN
    COMMIT;
    RETURN NULL;
END icx_session_ticket;
----------------------------
FUNCTION icx_session_ticket (p_session_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
RETURN icx_session_ticket;
END icx_session_ticket;

------------------------------------------------------------------------------------------------

PROCEDURE  common_bill_for_item    ( in_inventory_item_id       IN  NUMBER,
                                in_organization_id      IN  NUMBER,
                            common_inventory_item_id    OUT NOCOPY NUMBER,
                                common_organization_id      OUT NOCOPY NUMBER
                            )
IS

BEGIN

    select ORGANIZATION_ID, ASSEMBLY_ITEM_ID
    into COMMON_ORGANIZATION_ID, COMMON_INVENTORY_ITEM_ID
    from BOM_BILL_OF_MATERIALS
    where BILL_SEQUENCE_ID in (select SOURCE_BILL_SEQUENCE_ID from BOM_BILL_OF_MATERIALS
                        where ORGANIZATION_ID = in_organization_id
                        and ASSEMBLY_ITEM_ID = in_inventory_item_id);


EXCEPTION
  WHEN OTHERS THEN
    -- xERROR := cz_utils.REPORT('No common bill found for ' || in_inventory_item_id || '  ' || SQLERRM, 1, 'CZ_CF_API.common_bill_for_item', NULL);
    cz_utils.log_report('CZ_CF_API', 'common_bill_for_item', null,
                        'No common bill found for ' || in_inventory_item_id || '  ' || SQLERRM,
                        fnd_log.LEVEL_UNEXPECTED);
END common_bill_for_item;

------------------------------------------------------------------------------------------------

PROCEDURE common_bill_for_product(v_product_key IN  VARCHAR2, c_product_key OUT NOCOPY     VARCHAR2)
IS

v_inventory_item_id NUMBER;
v_organization_id  NUMBER;
c_inventory_item_id NUMBER;
c_organization_id NUMBER;

BEGIN

    --get inv and org id from product key
    v_organization_id := to_number(substr(v_product_key,1,instr(v_product_key,':')-1));
    v_inventory_item_id  := to_number(substr(v_product_key,instr(v_product_key,':')+1));

    common_bill_for_item(v_inventory_item_id,v_organization_id,c_inventory_item_id,c_organization_id);

    -- build the product key for the common bill
    c_product_key := c_organization_id || ':' || c_inventory_item_id;


EXCEPTION
  WHEN OTHERS THEN
    -- xERROR := cz_utils.REPORT('No common bill found for ' || v_product_key || '  ' || SQLERRM, 1, 'CZ_CF_API.common_bill_for_product', NULL);
    cz_utils.log_report('CZ_CF_API', 'common_bill_for_product', null,
                        'No common bill found for ' || v_product_key || '  ' || SQLERRM,
                        fnd_log.LEVEL_UNEXPECTED);
END common_bill_for_product;

--------------------------------------------------------------------------------
PROCEDURE pub_for_item_mobile_pvt
                   (p_inventory_item_id      IN  NUMBER
                   ,p_organization_id        IN  NUMBER
                   ,p_application_id IN  NUMBER
                   ,p_usage_id               IN  NUMBER
                   ,p_language               IN  VARCHAR2
                   ,p_pub_start_date         IN  DATE
                   ,p_pub_end_date           IN  DATE
                   ,x_publication_ids   OUT NOCOPY  number_tbl_indexby_type
                   ,x_model_ids         OUT NOCOPY  number_tbl_indexby_type
                   ,x_ui_def_ids        OUT NOCOPY  number_tbl_indexby_type
                   ,x_start_dates       OUT NOCOPY  date_tbl_indexby_type
                   ,x_last_update_dates OUT NOCOPY  date_tbl_indexby_type
                   ,x_model_type        OUT NOCOPY VARCHAR2
                   )
IS
  TYPE model_type_tbl_type IS TABLE OF cz_devl_projects.model_type%TYPE
           INDEX BY BINARY_INTEGER;
  l_model_type_tbl  model_type_tbl_type;
BEGIN
  SELECT pub.publication_id, pub.model_id, pub.ui_def_id, pub.start_date,
         pub.last_update_date, prj.model_type
  BULK COLLECT INTO x_publication_ids, x_model_ids, x_ui_def_ids,
       x_start_dates, x_last_update_dates, l_model_type_tbl
  FROM cz_model_applicabilities_v pub, cz_devl_projects prj
  WHERE pub.model_id = prj.devl_project_id
   AND prj.deleted_flag ='0' AND pub.deleted_flag = '0'
   AND pub.inventory_item_id = p_inventory_item_id
   AND bom_explosion_org_id = p_organization_id
   AND fnd_application_id = p_application_id
   AND usage_id = p_usage_id AND language = p_language
   AND UPPER(publication_mode) IN ( cz_api_pub.G_PRODUCTION_PUB_MODE , 'T')
   AND source_target_flag = TARGET_PUBLICATION
   AND ui_style = UI_STYLE_DHTML
   AND ( (p_pub_start_date >= start_date AND p_pub_start_date < disable_date) OR
         (P_pub_end_date > start_date AND p_pub_end_date <= disable_date) OR
         (start_date >= p_pub_start_date AND start_date < p_pub_end_date) OR
         (disable_date > p_pub_start_date AND disable_date <= p_pub_end_date) );

  x_model_type := l_model_type_tbl(1);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END pub_for_item_mobile_pvt;

--------------------------------------------------------------------------------
PROCEDURE publication_for_item_mobile
                 (p_inventory_item_id      IN  NUMBER
                 ,p_organization_id        IN  NUMBER
                 ,p_calling_application_id IN  NUMBER
                 ,p_usage_name             IN  VARCHAR2
                 ,p_pub_start_date         IN  DATE
                 ,p_pub_end_date           IN  DATE
                 ,x_publication_id_tbl  OUT NOCOPY number_tbl_indexby_type
                 ,x_model_id_tbl OUT NOCOPY  number_tbl_indexby_type
                 ,x_ui_def_id_tbl  OUT NOCOPY  number_tbl_indexby_type
                 ,x_start_date_tbl OUT NOCOPY date_tbl_indexby_type
                 ,x_last_update_date_tbl  OUT NOCOPY date_tbl_indexby_type
                 ,x_model_type  OUT NOCOPY VARCHAR2
                 )
IS
  l_usage_name  VARCHAR2(255) := p_usage_name;
  l_usage_id    NUMBER;
  l_language    VARCHAR2(4) := userenv('LANG');
  l_inventory_item_id     NUMBER ;
  l_organization_id       NUMBER;

BEGIN
  IF l_usage_name IS NULL THEN
    fnd_profile.get('CZ_PUBLICATION_USAGE', l_usage_name);
  END IF;
  l_usage_id := usage_id_from_usage_name(l_usage_name);

  -- Keep these values to lookup common bill, if required
  IF (c_application_id IS NULL) THEN
    c_application_id := p_calling_application_id;
  END IF;
  IF (c_usage_name IS NULL) THEN
    c_usage_name := l_usage_name;
  END IF;

  pub_for_item_mobile_pvt(p_inventory_item_id
                         ,p_organization_id
                         ,p_calling_application_id
                         ,l_usage_id
                         ,l_language
                         ,p_pub_start_date
                         ,p_pub_end_date
                         ,x_publication_id_tbl
                         ,x_model_id_tbl
                         ,x_ui_def_id_tbl
                         ,x_start_date_tbl
                         ,x_last_update_date_tbl
                         ,x_model_type
                         );

  IF (x_publication_id_tbl.COUNT = 0) THEN
    IF l_usage_id <> ANY_USAGE_ID THEN
      -- passing NULL is NOT the same as passing "any usage"
      pub_for_item_mobile_pvt(p_inventory_item_id
                             ,p_organization_id
                             ,p_calling_application_id
                             ,ANY_USAGE_ID
                             ,l_language
                             ,p_pub_start_date
                             ,p_pub_end_date
                             ,x_publication_id_tbl
                             ,x_model_id_tbl
                             ,x_ui_def_id_tbl
                             ,x_start_date_tbl
                             ,x_last_update_date_tbl
                             ,x_model_type
                             );
    ELSE
      -- else get publication id of the common bill, if any
      common_bill_for_item(p_inventory_item_id, p_organization_id,
                           l_inventory_item_id, l_organization_id);
      IF ( l_inventory_item_id IS NOT NULL AND
           l_organization_id IS NOT NULL AND
          (l_inventory_item_id <> p_inventory_item_id OR
           l_organization_id <> p_organization_id) ) THEN
        pub_for_item_mobile_pvt(l_inventory_item_id
                               ,l_organization_id
                               ,c_application_id
                               ,c_usage_name
                               ,l_language
                               ,p_pub_start_date
                               ,p_pub_end_date
                               ,x_publication_id_tbl
                               ,x_model_id_tbl
                               ,x_ui_def_id_tbl
                               ,x_start_date_tbl
                               ,x_last_update_date_tbl
                               ,x_model_type
                               );
      ELSE
        c_application_id := NULL;
        c_usage_name := NULL;
      END IF;
    END IF;
  ELSE
    c_application_id := NULL;
    c_usage_name := NULL;
  END IF;

END publication_for_item_mobile;
--------------------------------------------------------------------------------
FUNCTION product_key_for_saved_config(p_config_hdr_id       IN  NUMBER,
                                      p_config_rev_nbr      IN  NUMBER
		      		      )
RETURN VARCHAR2 IS
  v_config_hdr_id         NUMBER   := p_config_hdr_id;
  v_config_rev_nbr        NUMBER   := p_config_rev_nbr;
  v_inventory_item_id     NUMBER;
  v_organization_id       NUMBER;
  v_product_key           cz_devl_projects.product_key%TYPE := NULL;
  v_persist_comp_id       NUMBER;
  v_model_identifier      cz_config_hdrs.model_identifier%TYPE;

  CURSOR prj_cursor IS
    SELECT product_key
    FROM CZ_DEVL_PROJECTS
    WHERE persistent_project_id = v_persist_comp_id
    AND product_key IS NOT NULL
    AND deleted_flag = '0';

BEGIN
  BEGIN
    SELECT persistent_component_id, model_identifier
    INTO v_persist_comp_id, v_model_identifier
    FROM CZ_CONFIG_HDRS
    WHERE config_hdr_id = v_config_hdr_id AND config_rev_nbr = v_config_rev_nbr;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  IF v_model_identifier IS NOT NULL THEN
    v_inventory_item_id := SUBSTR(v_model_identifier, 1, INSTR(v_model_identifier, ':')-1);
    v_organization_id := SUBSTR(v_model_identifier, INSTR(v_model_identifier, ':')+1,
                      INSTR(v_model_identifier, ':', 1, 2) - (INSTR(v_model_identifier, ':')+1));
    v_product_key := v_organization_id || ':' || v_inventory_item_id;
  ELSE
    FOR v_prj_rec IN prj_cursor LOOP
      EXIT WHEN prj_cursor%rowcount > 1 OR prj_cursor%NOTFOUND;
      v_product_key := v_prj_rec.product_key;
    END LOOP;

  END IF;
  RETURN v_product_key;
END product_key_for_saved_config;
--------------------------------------------------------------------------------
FUNCTION pool_token_for_product_key(p_product_key IN VARCHAR2)
RETURN VARCHAR2 IS
 v_pool_token           cz_model_pool_mappings.pool_identifier%TYPE := NULL;
-- v_pool_token           VARCHAR2(50);
 BEGIN
 IF p_product_key IS NOT NULL THEN
    SELECT pool_identifier INTO v_pool_token FROM cz_model_pool_mappings WHERE model_product_key = p_product_key;
 END IF;
RETURN v_pool_token;
EXCEPTION WHEN NO_DATA_FOUND THEN
 RETURN NULL;
END pool_token_for_product_key;
--------------------------------------------------------------------------------
PROCEDURE register_model_to_pool(p_pool_identifier IN VARCHAR2,
                                 p_model_product_key IN VARCHAR2) AS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO cz_model_pool_mappings(pool_identifier, model_product_key)
  VALUES(p_pool_identifier, p_model_product_key);
  COMMIT;
END register_model_to_pool;
--------------------------------------------------------------------------------
PROCEDURE unregister_model_from_pool(p_pool_identifier IN VARCHAR2,
                                     p_model_product_key IN VARCHAR2) AS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE FROM cz_model_pool_mappings WHERE pool_identifier = p_pool_identifier
  AND model_product_key = p_model_product_key;
  COMMIT;
END unregister_model_from_pool;
--------------------------------------------------------------------------------
PROCEDURE unregister_pool(p_pool_identifier VARCHAR2) AS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE FROM cz_model_pool_mappings WHERE pool_identifier = p_pool_identifier;
  COMMIT;
END unregister_pool;
--------------------------------------------------------------------------------
BEGIN
   id_increment := cz_utils.conv_num(get_db_setting('SCHEMA', 'ORACLESEQUENCEINCR'));
   IF id_increment IS NULL THEN
      id_increment := default_incr;
   END IF;

   BEGIN
     transferTimeout := To_number(get_db_setting('SCHEMA', 'UTLHTTPTRANSFERTIMEOUT'));
     EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.GET_TRANSFER_TIMEOUT(:1); END;' USING IN OUT defaultTimeout;
   EXCEPTION
      WHEN OTHERS THEN
        transferTimeout := NULL;
        defaultTimeout := NULL;
   END;
END CZ_CF_API;

/
