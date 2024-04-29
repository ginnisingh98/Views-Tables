--------------------------------------------------------
--  DDL for Package Body CZ_NETWORK_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_NETWORK_API_PUB" AS
/*  $Header: czntapib.pls 120.9 2006/10/19 17:03:35 qmao ship $    */
------------------------------------------------------------------------------------------
-- model_type/model_instantiation_type
NETWORK CONSTANT VARCHAR2(1) := 'N';

-- mtl_system_items.config_model_type
NETWORK_CONTAINER_MODEL  CONSTANT VARCHAR2(1) := 'N';

-- component_instance_type
ROOT  CONSTANT VARCHAR2(1) := 'R';
INSTANCE_ROOT CONSTANT VARCHAR2(1) := 'I';
INCLUDED CONSTANT VARCHAR2(1) := 'T';


NO_PARENT_VALUE         CONSTANT PLS_INTEGER := -1;
INSTANTIABLE            CONSTANT PLS_INTEGER := 4;
PS_NODE_TYPE_REFERENCE  CONSTANT PLS_INTEGER := 263;
NO_FLAG                 CONSTANT VARCHAR2(1) := '0';
YES_FLAG                CONSTANT VARCHAR2(1) := '1';

type VARCHAR2_TBL_TYPE is table of VARCHAR2(1200);

----declaration used for grouping instances and keyed by inv item id
TYPE container_model_rec_type IS RECORD
(
 inventory_item_id    NUMBER,
 organization_id      NUMBER,
 config_item_id         NUMBER
);
TYPE container_model_tbl_type IS TABLE OF container_model_rec_type INDEX BY BINARY_INTEGER;

TYPE container_config_rec_type IS RECORD
(
 inventory_item_id    NUMBER,
 config_hdr_id    NUMBER,
 config_rev_nbr    NUMBER
);
TYPE container_config_tbl_type IS TABLE OF container_config_rec_type INDEX BY BINARY_INTEGER;

G_INCOMPATIBLE_API   EXCEPTION;

-----declaration for debug message table
v_msg_tbl CZ_DEBUG_PUB.msg_text_list ;

-------function that extracts the config err msg from xml
FUNCTION get_terminate_msg(p_str IN LONG) RETURN VARCHAR2
IS
  l_start_tag       VARCHAR2(20) := '<message_text>';
  l_end_tag         VARCHAR2(20) := '</message_text>';
  l_start_msg       VARCHAR2(2000);
  l_start_instr  NUMBER;
  l_end_instr    NUMBER;
  l_str_len    NUMBER;

BEGIN
  l_start_instr := INSTR(p_str,l_start_tag);
  l_str_len     := LENGTH(p_str);
  l_start_msg   := SUBSTR(p_str,l_start_instr);
  l_start_msg   := SUBSTR(l_start_msg,15,l_str_len);
  l_end_instr   := INSTR(l_start_msg,l_end_tag);
  l_start_msg   := SUBSTR(l_start_msg,1,l_end_instr-1);
  l_start_msg   := SUBSTR(l_start_msg,1,2000);
  RETURN l_start_msg;
EXCEPTION
  WHEN OTHERS THEN
    l_start_msg := SUBSTR(p_str,1,2000);
    RETURN l_start_msg;
END get_terminate_msg;

----procedure that populates debug messages
PROCEDURE populate_debug_message(p_msg     IN VARCHAR2,
                                 p_caller  IN VARCHAR2,
                                 p_sqlcode IN NUMBER)
IS
  l_caller cz_db_logs.caller%TYPE;

BEGIN
  IF (p_caller IS NULL) THEN
    l_caller := 'CZ_NETWORK_API';
  ELSE
    l_caller := p_caller;
  END IF;
  CZ_DEBUG_PUB.populate_debug_message(p_msg,p_caller,NVL(p_sqlcode,0),v_msg_tbl);
END populate_debug_message;
------------------------------------------------------------------------
-----procedure that writes messages to the FND stack
PROCEDURE set_fnd_message(inMessageName IN VARCHAR2,
                          inToken1 IN VARCHAR2 DEFAULT NULL, inValue1 IN VARCHAR2 DEFAULT NULL,
                          inToken2 IN VARCHAR2 DEFAULT NULL, inValue2 IN VARCHAR2 DEFAULT NULL,
                          inToken3 IN VARCHAR2 DEFAULT NULL, inValue3 IN VARCHAR2 DEFAULT NULL,
                          inToken4 IN VARCHAR2 DEFAULT NULL, inValue4 IN VARCHAR2 DEFAULT NULL,
                          inToken5 IN VARCHAR2 DEFAULT NULL, inValue5 IN VARCHAR2 DEFAULT NULL,
                          inToken6 IN VARCHAR2 DEFAULT NULL, inValue6 IN VARCHAR2 DEFAULT NULL
                         )
IS

BEGIN
  FND_MESSAGE.SET_NAME('CZ', inMessageName);
  IF (inToken1 IS NOT NULL) THEN
    FND_MESSAGE.SET_TOKEN(inToken1, inValue1);
  END IF;

  IF (inToken2 IS NOT NULL) THEN
    FND_MESSAGE.SET_TOKEN(inToken2, inValue2);
  END IF;

  IF (inToken3 IS NOT NULL) THEN
    FND_MESSAGE.SET_TOKEN(inToken3, inValue3);
  END IF;

  IF (inToken4 IS NOT NULL) THEN
    FND_MESSAGE.SET_TOKEN(inToken4, inValue4);
  END IF;

  IF (inToken5 IS NOT NULL) THEN
    FND_MESSAGE.SET_TOKEN(inToken5, inValue5);
  END IF;

  IF (inToken6 IS NOT NULL) THEN
    FND_MESSAGE.SET_TOKEN(inToken6, inValue6);
  END IF;

  FND_MSG_PUB.ADD;
END set_fnd_message;

-------------------------------------------------------------------------
-------calling applications default publication parameters to G_MISS_DATE, G_MISS_CHAR etc
-------In  such cases default the parameter to NULL.
----default pb applicability parameters to NULL if no values are passed in
PROCEDURE default_pb_parameters(p_appl_param_rec IN OUT NOCOPY CZ_API_PUB.appl_param_rec_type,
                                x_return_status  IN OUT NOCOPY VARCHAR2)
IS
  APPLID_NOT_FOUND EXCEPTION;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_appl_param_rec.config_creation_date = FND_API.G_MISS_DATE) THEN
    p_appl_param_rec.config_creation_date := NULL;
  END IF;

  IF (p_appl_param_rec.config_model_lookup_date = FND_API.G_MISS_DATE) THEN
    p_appl_param_rec.config_model_lookup_date := NULL;
  END IF;

  IF (p_appl_param_rec.config_effective_date = FND_API.G_MISS_DATE) THEN
    p_appl_param_rec.config_effective_date := NULL;
  END IF;

  IF (p_appl_param_rec.usage_name = FND_API.G_MISS_CHAR) THEN
    p_appl_param_rec.usage_name := NULL;
  END IF;

  IF (p_appl_param_rec.publication_mode = FND_API.G_MISS_CHAR) THEN
    p_appl_param_rec.publication_mode := NULL;
  END IF;

  IF (p_appl_param_rec.language = FND_API.G_MISS_CHAR) THEN
    p_appl_param_rec.language := NULL;
  END IF;

  IF ( (p_appl_param_rec.calling_application_id = FND_API.G_MISS_NUM) OR (p_appl_param_rec.calling_application_id IS NULL) ) THEN
    RAISE APPLID_NOT_FOUND;
  END IF;
EXCEPTION
  WHEN APPLID_NOT_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    set_fnd_message('CZ_NET_APPL_ID_ISNULL',null,null,null,null);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END default_pb_parameters;
-----------------------------------------------------------------------
----procedure that sets the the return status to error
----and populates the error message stack
PROCEDURE set_error_message(p_err_code  IN OUT NOCOPY VARCHAR2,
                            p_msg_count IN OUT NOCOPY NUMBER,
                            p_msg_data  IN OUT NOCOPY VARCHAR2,
                            p_err_msg   IN VARCHAR2)
IS

BEGIN
  p_err_code := FND_API.G_RET_STS_ERROR;
  fnd_msg_pub.count_and_get(p_count => p_msg_count,p_data  => p_msg_data);
  populate_debug_message(p_err_msg,NULL,NULL);
  CZ_DEBUG_PUB.insert_into_logs(v_msg_tbl);
END set_error_message;

---------------------------------------------------------------------------
----procedure that deletes the saved configurations
PROCEDURE delete_configuration(p_config_model_tbl IN cz_api_pub.config_model_tbl_type)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_err_buf   VARCHAR2(2000);
  l_msg_data  VARCHAR2(2000);
  l_msg_count NUMBER;
  l_err_code  VARCHAR2(30);
  l_usage_exists   NUMBER;
  l_error_message  VARCHAR2(2000);
  l_Return_value   NUMBER;

BEGIN
  IF (p_config_model_tbl.COUNT > 0) THEN
    FOR I IN p_config_model_tbl.FIRST..p_config_model_tbl.LAST
    LOOP
      -- this needs to change to call cz_cf_api.delete_configuration
      cz_cf_api.delete_configuration(p_config_model_tbl(i).config_hdr_id,
                                     p_config_model_tbl(i).config_rev_nbr,
                                     l_usage_exists,
                                     l_error_message,
                                     l_Return_value);
      IF (l_Return_value <> 1) THEN
        l_err_buf := CZ_UTILS.GET_TEXT('CZ_NET_API_DEL_CFG_ERR','ConfigHdrId',
            p_config_model_tbl(i).config_hdr_id,'ConfigRevNbr',p_config_model_tbl(i).config_rev_nbr);
      END IF;
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err_buf := CZ_UTILS.GET_TEXT('CZ_NET_API_DEL_CONFIG_ERR');
    set_error_message(l_err_code,l_msg_count,l_msg_data,l_err_buf);
    set_error_message(l_err_code,l_msg_count,l_msg_data,'delete config err');
END delete_configuration;
---------------------------------------------------------------------------
----procedure that retrieves the model instantiation type and
----component instance type for a config hdr and rev nbr
PROCEDURE get_header_types(p_config_hdr_id  IN NUMBER,
                           p_config_rev_nbr IN NUMBER,
                           x_model_instantiation_type OUT NOCOPY VARCHAR2,
                           x_component_instance_type  OUT NOCOPY VARCHAR2)
IS

BEGIN
  SELECT model_instantiation_type,
         component_instance_type
    INTO x_model_instantiation_type,
         x_component_instance_type
  FROM   cz_config_hdrs
  WHERE  cz_config_hdrs.config_hdr_id  = p_config_hdr_id
  AND    cz_config_hdrs.config_rev_nbr = p_config_rev_nbr;
EXCEPTION
  WHEN OTHERS THEN
     x_model_instantiation_type := '0';
     x_component_instance_type  := '0';
END get_header_types;

--------------------------------------------------------------------------
----procedure that retrieves the root inventory item id and organization id for a
----given config_hdr_id and rev nbr
procedure get_root_bom_config_item(p_config_hdr_id     IN  NUMBER,
                                   p_config_rev_nbr    IN  NUMBER,
                                   x_inventory_item_id OUT NOCOPY  NUMBER,
                                   x_organization_id   OUT NOCOPY  NUMBER,
                                   x_config_item_id    OUT NOCOPY   NUMBER)
IS

BEGIN
  SELECT config_item_id, inventory_item_id, organization_id
    INTO x_config_item_id, x_inventory_item_id, x_organization_id
  FROM  cz_config_items
  WHERE config_hdr_id  = p_config_hdr_id
  AND   config_rev_nbr = p_config_rev_nbr
  AND   deleted_flag   = '0'
  AND   inventory_item_id IS NOT NULL
  START WITH (parent_config_item_id IS NULL OR parent_config_item_id = -1)
    AND config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
  CONNECT BY PRIOR inventory_item_id IS NULL
    AND parent_config_item_id = PRIOR config_item_id
    AND config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr;
EXCEPTION
  WHEN OTHERS THEN
    x_inventory_item_id := -1;
    x_organization_id   := -1;
END get_root_bom_config_item;

--------------------------------------------------------------------------
PROCEDURE get_container_header(p_config_hdr_id     NUMBER,
                               p_config_rev_nbr    NUMBER,
                               x_container_hdr_id  OUT NOCOPY NUMBER,
                               x_container_rev_nbr OUT NOCOPY NUMBER)
IS

BEGIN
  ----get container header
  SELECT config_hdr_id, config_rev_nbr
    INTO x_container_hdr_id, x_container_rev_nbr
  FROM   cz_config_items
  WHERE  cz_config_items.instance_hdr_id  = p_config_hdr_id
  AND    cz_config_items.instance_rev_nbr = p_config_rev_nbr
  AND    cz_config_items.deleted_flag = '0'
  AND    ROWNUM < 2;
EXCEPTION
  WHEN OTHERS THEN
    x_container_hdr_id  := -1;
    x_container_rev_nbr := -1;
END get_container_header;

--------------------------------------------------------------------------
PROCEDURE check_if_item_exists(p_inv_item_id IN NUMBER,
                               p_org_id      IN NUMBER,
                               container_model_tbl IN container_model_tbl_type,
                               x_out_index   OUT NOCOPY NUMBER,
                               x_flag     OUT NOCOPY BOOLEAN)
IS

BEGIN
  x_flag := FALSE;
  x_out_index := 0;
  IF (container_model_tbl.COUNT > 0) THEN
    FOR I IN container_model_tbl.FIRST..container_model_tbl.LAST
    LOOP
      IF ( (container_model_tbl(i).inventory_item_id = p_inv_item_id) AND
           (container_model_tbl(i).organization_id = p_org_id) ) THEN
        x_flag := TRUE;
        x_out_index := i;
      END IF;
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_flag := FALSE;
END check_if_item_exists;

-------------------------------------------------------------------------
PROCEDURE validate_org_id(container_model_tbl IN container_model_tbl_type,
                          x_flag OUT NOCOPY BOOLEAN)
IS
  prev_org_id  NUMBER;

BEGIN
  x_flag := TRUE;
  IF (container_model_tbl.COUNT > 0) THEN
    FOR I IN container_model_tbl.FIRST..container_model_tbl.LAST
    LOOP
      prev_org_id := container_model_tbl(i).organization_id;
      IF (i <> container_model_tbl.COUNT) THEN
        IF (prev_org_id <> container_model_tbl(i+1).organization_id) THEN
          x_flag := FALSE;
          EXIT;
        END IF;
      END IF;
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_flag := FALSE;
END validate_org_id;

-------------------------------------------------------------------------
------procedure that sets the deltas to 0 for the new configuration
------after a call is made to copy configuration
PROCEDURE reset_config_delta (p_config_hdr_id  IN NUMBER,
                              p_config_rev_nbr IN NUMBER)
IS

BEGIN
  UPDATE cz_config_items
  SET    config_delta = 0
  WHERE  config_hdr_id = p_config_hdr_id
  AND    config_rev_nbr = p_config_rev_nbr;
END reset_config_delta ;

--------------------------------------------------------------------------
PROCEDURE write_dummy_config(p_inventory_id    IN NUMBER,
                             p_inst_hdr_id_tbl IN container_config_tbl_type,
                             x_dummy_hdr_id    OUT NOCOPY NUMBER)
IS

--These values do not really matter. We only provide them because corresponding columns
--are not null.

ANY_USAGE_ID          CONSTANT NUMBER      := -1;
NETWORK               CONSTANT VARCHAR2(1) := 'N';
ROOT                  CONSTANT VARCHAR2(1) := 'R';
INPUTTTYPECODE        CONSTANT NUMBER      := 7;

TYPE t_local_number_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_inst_header_id_tbl  t_local_number_tbl;
l_input_id_tbl        t_local_number_tbl;

BEGIN

   SELECT cz_config_hdrs_s.NEXTVAL INTO x_dummy_hdr_id FROM DUAL;

   FOR i IN 1..p_inst_hdr_id_tbl.COUNT LOOP

     IF(p_inst_hdr_id_tbl(i).inventory_item_id = p_inventory_id)THEN

       l_inst_header_id_tbl(l_inst_header_id_tbl.COUNT + 1) := p_inst_hdr_id_tbl(i).config_hdr_id;
       l_input_id_tbl(l_inst_header_id_tbl.COUNT) := l_inst_header_id_tbl.COUNT;
     END IF;
   END LOOP;

   INSERT INTO cz_config_hdrs ( config_hdr_id
                              , config_rev_nbr
                              , name
                              , desc_text
                              , effective_usage_id
                              , deleted_flag
                              , config_delta_spec
                              , component_instance_type
                              , model_instantiation_type
                              , has_failures
                              )
                      VALUES  ( x_dummy_hdr_id
                              , 1
                              , 'generate/add_to_config_tree'
                              , 'generate/add_to_config_tree'
                              , ANY_USAGE_ID
                              , '0'
			      , 0
			      , ROOT
			      , NETWORK
                              , 0
                              );

   FORALL i IN 1..l_inst_header_id_tbl.COUNT
     INSERT INTO cz_config_contents_v ( config_hdr_id
                                      , config_rev_nbr
                                      , config_input_id
                                      , input_seq
                                      , input_type_code
                                      , input_num_val
                                      , item_num_val
                                      , config_item_id
                                      , item_type_code
                                      , instance_hdr_id
                                      , instance_rev_nbr
                                      , component_instance_type
                                      , config_delta
                                      )
                               VALUES ( x_dummy_hdr_id
                                      , 1
                                      , l_input_id_tbl(i)
                                      , l_input_id_tbl(i)
                                      , INPUTTTYPECODE
                                      , l_inst_header_id_tbl(i)
                                      , l_inst_header_id_tbl(i)
                                      , -1 * l_input_id_tbl(i)
                                      , -1
                                      , x_dummy_hdr_id
                                      , 1
                                      , 'R'
                                      , 0
                                      );
END write_dummy_config;

--------------------------------------------------------------------------
PROCEDURE delete_dummy_config(p_dummy_hdr_id IN NUMBER)
IS

v_cfg_delete     cz_db_settings.value%TYPE;

BEGIN

    -----delete based on setting in cz_db_settings
    BEGIN
        SELECT value INTO v_cfg_delete
          FROM cz_db_settings
         WHERE setting_id = 'BatchValConfigInputDelete';
    EXCEPTION
      WHEN OTHERS THEN
          v_cfg_delete := 'NO';
    END;

    IF(v_cfg_delete <> 'YES')THEN

      DELETE FROM cz_config_contents_v WHERE config_hdr_id = p_dummy_hdr_id
         AND config_rev_nbr = 1;

      DELETE FROM cz_config_hdrs WHERE config_hdr_id = p_dummy_hdr_id
         AND config_rev_nbr = 1;
    END IF;
END delete_dummy_config;

--------------------------------------------------------------------------
------procedure that creates the init msg
PROCEDURE create_hdr_xml( p_inventory_id      IN NUMBER,
                          p_organization_id   IN NUMBER,
                          p_config_hdr_id     IN NUMBER,
                          p_config_rev_nbr    IN NUMBER,
                          p_dummy_header_id   IN NUMBER,
                          p_appl_params       IN CZ_API_PUB.appl_param_rec_type,
                          p_tree_copy_mode    IN VARCHAR2,
                          p_valid_context     IN VARCHAR2,
                          x_xml_hdr           OUT NOCOPY VARCHAR2 )
IS

TYPE param_name_type IS TABLE OF VARCHAR2(30)INDEX BY BINARY_INTEGER;
TYPE param_value_type IS TABLE OF VARCHAR2(200)INDEX BY BINARY_INTEGER;
param_name  param_name_type;
param_value param_value_type;

l_rec_index BINARY_INTEGER;

l_database_id                     VARCHAR2(100);
l_save_config_behavior            VARCHAR2(30):= CZ_API_PUB.G_NEW_REVISION_COPY_MODE;
l_ui_type                         VARCHAR2(30):= null;
l_msg_behavior                    VARCHAR2(30):= 'brief';
l_context_org_id                  VARCHAR2(80);
l_inventory_item_id               VARCHAR2(80);
l_config_header_id                VARCHAR2(80);
l_config_rev_nbr                  VARCHAR2(80);
l_model_quantity                  VARCHAR2(80);
l_count                           NUMBER;

-- message related
l_xml_hdr                         VARCHAR2(32767):= '<initialize>';
l_dummy                           VARCHAR2(500) := NULL;
l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

BEGIN
  ---- now set the values from model_rec and org_id
  l_context_org_id     := to_char(p_organization_id);
  l_inventory_item_id     := to_char(p_inventory_id);
  l_config_header_id      := to_char(p_config_hdr_id);
  l_config_rev_nbr        := to_char(p_config_rev_nbr);

  -- profiles and env. variables.
  l_database_id           := fnd_web_config.database_id;

  -- set param_names
  param_name(1)  := 'database_id';
  param_name(2)  := 'context_org_id';
  param_name(3)  := 'config_creation_date';
  param_name(4)  := 'calling_application_id';
  param_name(5)  := 'responsibility_id';
  param_name(6)  := 'model_id';
  param_name(7)  := 'config_header_id';
  param_name(8)  := 'config_rev_nbr';
  param_name(9)  := 'config_effective_date';
  param_name(10) := 'save_config_behavior';
  param_name(11) := 'ui_type';
  param_name(12) := 'language';
  param_name(13) := 'terminate_msg_behavior';
  param_name(14) := 'model_quantity';
  param_name(15) := 'icx_session_ticket';
  param_name(16) := 'publication_mode';
  param_name(17) := 'usage_name';
  param_name(18) := 'sbm_flag';
  param_name(19) := 'validation_context';
  param_name(20) := 'suppress_baseline_errors';

  l_count := 20;

  -- set param values
  param_value(1)  := l_database_id;
  param_value(2)  := l_context_org_id;
  param_value(3)  := to_char(sysdate,'MM-DD-YYYY-HH24-MI-SS');
  param_value(4)  := p_appl_params.calling_application_id;
  param_value(5)  := fnd_profile.value('RESP_ID');
  param_value(6)  := l_inventory_item_id;
  param_value(7)  := l_config_header_id;
  param_value(8)  := l_config_rev_nbr;

  -- config_effective_date should have LONG DATE FORMAT --
  param_value(9)  := to_char(p_appl_params.config_effective_date,'MM-DD-YYYY-HH24-MI-SS');

  IF (p_tree_copy_mode = CZ_API_PUB.G_NEW_HEADER_COPY_MODE) THEN
    l_save_config_behavior := 'new_config';
  ELSIF (p_tree_copy_mode = CZ_API_PUB.G_NEW_REVISION_COPY_MODE) THEN
    l_save_config_behavior := 'new_revision';
  END IF;

  param_value(10) := l_save_config_behavior;
  param_value(11) := l_ui_type;
  param_value(12) := p_appl_params.language;
  param_value(13) := l_msg_behavior;
  param_value(14) := l_model_quantity;
  param_value(15) := cz_cf_api.icx_session_ticket;
  param_value(16) := p_appl_params.publication_mode;
  param_value(17) := p_appl_params.usage_name;
  param_value(18) := 'TRUE';

  IF (p_valid_context = 'I') THEN
    param_value(19) := 'INSTALLED';
  ELSIF (p_valid_context = 'P') THEN
    param_value(19) := 'PENDING_OR_INSTALLED';
  ELSE
    param_value(19) := 'I';
  END IF;
  param_value(20) := 'TRUE';

  l_rec_index := 1;
  LOOP
    ----- ex : <param name="config_header_id">1890</param>
    IF (param_value(l_rec_index) IS NOT NULL) THEN
      l_dummy :=  '<param name='||'"'||param_name(l_rec_index)||'"'||'>'|| param_value(l_rec_index)||'</param>';
      l_xml_hdr := l_xml_hdr || l_dummy;
    END IF;
    l_dummy := NULL;
    l_rec_index := l_rec_index + 1;
    EXIT WHEN l_rec_index > l_count;
  END LOOP;

  -- add termination tags
  l_xml_hdr := l_xml_hdr || '</initialize>';

  --add the config instance section
  l_xml_hdr := l_xml_hdr ||
     '<config_instance>' ||
        '<config_header_id>' || TO_CHAR(p_dummy_header_id) || '</config_header_id>' ||
        '<config_rev_nbr>1</config_rev_nbr>' ||
     '</config_instance>';

  l_xml_hdr := REPLACE(l_xml_hdr, ' ' , '+');
  x_xml_hdr := l_xml_hdr;

  ----added for debugging
  populate_debug_message(l_xml_hdr,'CREATE_HDR_XML',NULL);

EXCEPTION
  WHEN OTHERS THEN
    ----is error to be logged ? if so what ?
    RAISE;
END create_hdr_xml;

--------------------------------------------------------------------------
PROCEDURE  parse_output_xml(p_xml                IN  LONG,
                            x_config_header_id   OUT NOCOPY NUMBER,
                            x_config_rev_nbr     OUT NOCOPY NUMBER,
                            x_return_status      OUT NOCOPY VARCHAR2)
IS

CURSOR messages(p_config_hdr_id NUMBER, p_config_rev_nbr NUMBER) IS
                  SELECT constraint_type , message
                  FROM   cz_config_messages
                  WHERE  config_hdr_id = p_config_hdr_id
                  AND    config_rev_nbr = p_config_rev_nbr;
l_exit_start_tag        VARCHAR2(20) := '<EXIT>';
l_exit_end_tag          VARCHAR2(20) := '</EXIT>';
l_exit_start_pos        NUMBER;
l_exit_end_pos          NUMBER;
l_config_header_id_start_tag  VARCHAR2(20) := '<CONFIG_HEADER_ID>';
l_config_header_id_end_tag    VARCHAR2(20) := '</CONFIG_HEADER_ID>';
l_config_header_id_start_pos  NUMBER;
l_config_header_id_end_pos    NUMBER;
l_config_rev_nbr_start_tag    VARCHAR2(20) := '<CONFIG_REV_NBR>';
l_config_rev_nbr_end_tag      VARCHAR2(20) := '</CONFIG_REV_NBR>';
l_config_rev_nbr_start_pos    NUMBER;
l_config_rev_nbr_end_pos      NUMBER;
l_message_text_start_tag      VARCHAR2(20) := '<MESSAGE_TEXT>';
l_message_text_end_tag        VARCHAR2(20) := '</MESSAGE_TEXT>';
l_message_text_start_pos      NUMBER;
l_message_text_end_pos        NUMBER;
l_message_type_start_tag      VARCHAR2(20) := '<MESSAGE_TYPE>';
l_message_type_end_tag        VARCHAR2(20) := '</MESSAGE_TYPE>';
l_message_type_start_pos      NUMBER;
l_message_type_end_pos        NUMBER;
l_exit                        VARCHAR(20);
l_config_header_id            NUMBER;
l_config_rev_nbr              NUMBER;
l_message_text                VARCHAR2(2000);
l_message_type                VARCHAR2(200);
l_list_price                  NUMBER;
l_selection_line_id           NUMBER;
l_valid_config                VARCHAR2(10);
l_complete_config             VARCHAR2(10);
l_header_id                   NUMBER;
l_line_id                     NUMBER ;
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_return_status_del           VARCHAR2(1);
l_msg                         VARCHAR2(2000);
l_msg_data                    VARCHAR2(2000);
l_msg_count                   NUMBER;
l_constraint                  VARCHAR2(16);
l_flag                        VARCHAR2(1) := 'N';

BEGIN
  l_exit_start_pos := INSTR(UPPER(p_xml), l_exit_start_tag,1, 1) + length(l_exit_start_tag);
  l_exit_end_pos   := INSTR(UPPER(p_xml), l_exit_end_tag,1, 1) - 1;
  l_exit           := SUBSTR(p_xml,l_exit_start_pos,l_exit_end_pos - l_exit_start_pos + 1);

  -- get the latest config_header_id, and rev_nbr to get
  -- messages if any.
  l_config_header_id_start_pos := INSTR(UPPER(p_xml), l_config_header_id_start_tag, 1, 1)+ length(l_config_header_id_start_tag);
  l_config_header_id_end_pos   := INSTR(UPPER(p_xml), l_config_header_id_end_tag, 1, 1) - 1;
  l_config_header_id  := to_number(SUBSTR(p_xml,l_config_header_id_start_pos,l_config_header_id_end_pos - l_config_header_id_start_pos + 1));

  l_config_rev_nbr_start_pos   := INSTR(UPPER(p_xml), l_config_rev_nbr_start_tag, 1, 1)+ length(l_config_rev_nbr_start_tag);
  l_config_rev_nbr_end_pos     := INSTR(UPPER(p_xml), l_config_rev_nbr_end_tag, 1, 1) - 1;
  l_config_rev_nbr    := to_number(SUBSTR(p_xml,l_config_rev_nbr_start_pos,l_config_rev_nbr_end_pos - l_config_rev_nbr_start_pos + 1));

  -----no need to check if valid_config or complete_config
  ----fix for bug# 2937753
  IF ( (l_exit is NULL) OR (UPPER(l_exit) = 'ERROR') ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- if everything ok, set return values
    x_return_status    := l_return_status;
    x_config_header_id := l_config_header_id;
    x_config_rev_nbr   := l_config_rev_nbr;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Parse_output_xml;

--------------------------------------------------------------------------
----procedure that logs trace for network API
PROCEDURE trace_gen_config_trees (p_api_version        IN  NUMBER,
                                  p_config_tbl         IN  CZ_API_PUB.config_tbl_type,
                                  p_tree_copy_mode     IN  VARCHAR2,
                                  p_appl_param_rec     IN  CZ_API_PUB.appl_param_rec_type,
                                  p_validation_context IN  VARCHAR2,
                                  p_config_model_tbl   IN OUT NOCOPY CZ_API_PUB.config_model_tbl_type,
                                  p_return_status      IN OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
TYPE trace_tbl IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
l_trace_tbl   trace_tbl ;
l_trace_count NUMBER := 0;
l_trace_value cz_db_settings.value%type;

BEGIN
  BEGIN
    SELECT value
    INTO   l_trace_value
    FROM   cz_db_settings
    WHERE  cz_db_settings.setting_id = 'NetworkApiTrace';
  EXCEPTION
    WHEN OTHERS THEN
      l_trace_value := 'NO';
  END;

  IF (l_trace_value = 'YES') THEN
    l_trace_count := 1;
    l_trace_tbl(l_trace_count) := 'Api version            : '||to_char(p_api_version);
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Tree copy mode         : '||p_tree_copy_mode;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Publication applicability parameters';
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'config_effective_date  : '||to_char(p_appl_param_rec.config_effective_date,'mm-dd-yyyy hh24:mi:ss');
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'calling_application_id : '||to_char(p_appl_param_rec.calling_application_id);
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'usage_name             : '||p_appl_param_rec.usage_name;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'publication_mode       : '||p_appl_param_rec.publication_mode;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'language               : '||p_appl_param_rec.language;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Validation context     : '||p_validation_context;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Input configs from calling application';

    IF (p_config_tbl.COUNT > 0) THEN
      FOR I IN p_config_tbl.FIRST..p_config_tbl.LAST
      LOOP
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Input config hdr id : '||to_char(p_config_tbl(i).config_hdr_id);
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Input config rev nbr: '||to_char(p_config_tbl(i).config_rev_nbr);
      END LOOP;
    END IF;

    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Output configs sent to calling application';

    IF (p_config_model_tbl.COUNT > 0) THEN
      FOR I IN p_config_model_tbl.FIRST..p_config_model_tbl.LAST
      LOOP
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Ouput  config hdr id  : '||to_char(p_config_model_tbl(i).config_hdr_id);
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Output config rev nbr : '||to_char(p_config_model_tbl(i).config_rev_nbr);
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Ouput  inv item id    : '||to_char(p_config_model_tbl(i).inventory_item_id);
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Output org id         : '||to_char(p_config_model_tbl(i).organization_id);
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Output config item id : '||to_char(p_config_model_tbl(i).config_item_id);
        l_trace_count := l_trace_count + 1;
      END LOOP;
    END IF;

    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'STATUS : '||p_return_status;

    IF (l_trace_tbl.COUNT > 0) THEN
      FOR I IN l_trace_tbl.FIRST..l_trace_tbl.LAST
      LOOP
        insert into cz_db_logs (message,caller,logtime) values (l_trace_tbl(i),'CZNETAPI',sysdate);
      END LOOP;
      l_trace_tbl.DELETE;
    END IF;
  END IF;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END trace_gen_config_trees;

-------------------------------------------------------------------------
----procedure that logs trace for network API
PROCEDURE trace_add_to_config_trees (p_api_version     IN  NUMBER,
          p_inventory_item_id  IN  NUMBER,
          p_organization_id    IN  NUMBER,
          p_config_hdr_id      IN  NUMBER,
          p_config_rev_nbr     IN  NUMBER,
          p_instance_tbl       IN  CZ_API_PUB.config_tbl_type,
          p_tree_copy_mode     IN  VARCHAR2,
          p_appl_param_rec     IN  CZ_API_PUB.appl_param_rec_type,
          p_validation_context IN  VARCHAR2,
          x_config_model_rec   IN CZ_API_PUB.config_model_rec_type,
          x_return_status      IN VARCHAR2,
          x_msg_count          IN NUMBER,
          x_msg_data           IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
TYPE trace_tbl IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
l_trace_tbl   trace_tbl ;
l_trace_count NUMBER := 0;
l_trace_value cz_db_settings.value%type;

BEGIN
  BEGIN
    SELECT value
    INTO   l_trace_value
    FROM   cz_db_settings
    WHERE  cz_db_settings.setting_id = 'NetworkApiTrace';
  EXCEPTION
    WHEN OTHERS THEN
      l_trace_value := 'NO';
  END;

  IF (l_trace_value = 'YES') THEN
    l_trace_count := 1;
    l_trace_tbl(l_trace_count) := 'Api version            : '||to_char(p_api_version);
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Tree copy mode         : '||p_tree_copy_mode;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Publication applicability parameters';
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'config_effective_date  : '||to_char(p_appl_param_rec.config_effective_date,'mm-dd-yyyy hh24:mi:ss');
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'calling_application_id : '||to_char(p_appl_param_rec.calling_application_id);
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'usage_name             : '||p_appl_param_rec.usage_name;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'publication_mode       : '||p_appl_param_rec.publication_mode;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'language               : '||p_appl_param_rec.language;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Validation context     : '||p_validation_context;
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Input configs from calling application';

    IF (p_instance_tbl.COUNT > 0) THEN
      FOR I IN p_instance_tbl.FIRST..p_instance_tbl.LAST
      LOOP
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Input config hdr id : '||to_char(p_instance_tbl(i).config_hdr_id);
        l_trace_count := l_trace_count + 1;
        l_trace_tbl(l_trace_count) := 'Input config rev nbr: '||to_char(p_instance_tbl(i).config_rev_nbr);
      END LOOP;
    END IF;

    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Output configs sent to calling application';

    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Ouput  config hdr id  : '||to_char(nvl(x_config_model_rec.config_hdr_id,0));
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Output config rev nbr : '||to_char(nvl(x_config_model_rec.config_rev_nbr,0));
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Ouput  inv item id    : '||to_char(nvl(x_config_model_rec.inventory_item_id,0));
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Output org id         : '||to_char(nvl(x_config_model_rec.organization_id,0));
    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'Output config item id : '||to_char(nvl(x_config_model_rec.config_item_id,0));
    l_trace_count := l_trace_count + 1;

    l_trace_count := l_trace_count + 1;
    l_trace_tbl(l_trace_count) := 'STATUS : '||x_return_status;

    IF (l_trace_tbl.COUNT > 0) THEN
      FOR I IN l_trace_tbl.FIRST..l_trace_tbl.LAST
      LOOP
        insert into cz_db_logs (message,caller,logtime) values (l_trace_tbl(i),'CZNETAPI',sysdate);
      END LOOP;
      l_trace_tbl.DELETE;
    END IF;
  END IF;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END trace_add_to_config_trees;


---------------------------------------------------------------------------
---Start of comments
---API name                 : generate_config_trees
---Type          : Public
---Pre-reqs                 : None
---Function                 : generates config trees for a given set of config hdr ids and rev nbrs
---Parameters               :
---IN      : p_api_version        IN  NUMBER              Required
---          p_config_tbl         IN  config_tbl_type     Required
---          p_tree_copy_mode     IN  VARCHAR2            Required
---          p_appl_param_rec     IN  appl_param_rec_type Required
---          p_validation_context IN  VARCHAR2            Required
---          p_validation_type    IN  VARCHAR2            valid values are :
---                  CZ_API_PUB.INTERACTIVE, CZ_API_PUB.VALIDATE_RETURN
---OUT     : x_return_status      OUT NOCOPY VARCHAR2
---          x_msg_count          OUT NOCOPY NUMBER
---          x_msg_data           OUT NOCOPY VARCHAR2
---Version: Current version :1.0
---End of comments

PROCEDURE generate_config_trees(p_api_version        IN  NUMBER,
                                p_config_tbl         IN  CZ_API_PUB.config_tbl_type,
                                p_tree_copy_mode     IN  VARCHAR2,
                                p_appl_param_rec     IN  CZ_API_PUB.appl_param_rec_type,
                                p_validation_context IN  VARCHAR2,
                                p_validation_type    IN  VARCHAR2,
                                x_config_model_tbl   OUT NOCOPY CZ_API_PUB.config_model_tbl_type,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2
                               )
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_api_name              CONSTANT VARCHAR2(30) := 'generate_config_trees';
l_api_version           CONSTANT NUMBER := 1.0;
l_config_hdr_id         cz_config_hdrs.config_hdr_id%TYPE;
l_config_rev_nbr        cz_config_hdrs.config_rev_nbr%TYPE;
l_main_config_hdr_id    cz_config_hdrs.config_hdr_id%TYPE;
l_main_config_rev_nbr   cz_config_hdrs.config_rev_nbr%TYPE;
l_inventory_item_id     cz_config_items.inventory_item_id%TYPE;
l_organization_id       cz_config_items.organization_id%TYPE;
l_config_item_id        cz_config_items.config_item_id%TYPE;
l_model_instantiation_type VARCHAR2(1);
l_component_instance_type  VARCHAR2(1);
container_model_tbl     container_model_tbl_type;
container_config_tbl    container_config_tbl_type;
exists_flag             BOOLEAN;
ORG_ID_FLAG             BOOLEAN;
inst_hdr_count          NUMBER := 0;
l_xml_hdr               VARCHAR2(32767);
l_batch_validate_msg    VARCHAR2(100);
v_config_hdr_id         NUMBER := 0;
v_config_rev_nbr        NUMBER := 0;
v_output_cfg_hdr_id     NUMBER := 0;
v_output_cfg_rev_nbr    NUMBER := 0;
v_valid_config          VARCHAR2(30);
v_complete_config       VARCHAR2(30);
l_copy_config_msg       VARCHAR2(2000);
config_input_list       cz_cf_api.cfg_input_list;
config_messages         cz_cf_api.cfg_output_pieces;
v_ouput_config_count    NUMBER := 0;
v_xml_str               LONG;
l_idx                   NUMBER;
inv_count               NUMBER := 0;
new_config_flag         VARCHAR2(1);
l_msg_count             NUMBER;
l_cp_msg_count          NUMBER;
l_msg_data              VARCHAR2(10000);
l_errbuf                VARCHAR2(2000);
l_copy_config_status    VARCHAR2(1);
validation_status       NUMBER;
v_parse_status          VARCHAR2(1);
l_validation_context    VARCHAR2(1);
l_url                   VARCHAR2(255);
l_orig_item_tbl         cz_api_pub.number_tbl_type;
l_new_item_tbl          cz_api_pub.number_tbl_type;
l_config_err_msg        VARCHAR2(2000);
l_dummy_config_hdr_id   NUMBER;

NO_INPUT_RECORDS        EXCEPTION;
INPUT_TREE_MODE_NULL    EXCEPTION;
ORG_ID_EXCEP            EXCEPTION;
BATCH_VALID_FAILURE     EXCEPTION;
INVALID_CONTAINER_HDR   EXCEPTION;
INVALID_INV_ORG_ID      EXCEPTION;
INVALID_OUT_INV_ORG_ID  EXCEPTION;
INVALID_HEADER_TYPE     EXCEPTION;
INVALID_TREE_MODE_ERR   EXCEPTION;
INVALID_VALIDATION_TYPE EXCEPTION;
COPY_CONFIG_FAILURE_EXCEP EXCEPTION;
INVALID_HEADER_EXCEP    EXCEPTION;
BATCH_VALID_ERR         EXCEPTION;
PARSE_XML_ERROR         EXCEPTION;
INVALID_CONTEXT         EXCEPTION;
NO_VALIDATION_CONTEXT   EXCEPTION;

BEGIN

  IF p_validation_type NOT IN(CZ_API_PUB.INTERACTIVE, CZ_API_PUB.VALIDATE_RETURN) THEN
    RAISE INVALID_VALIDATION_TYPE;
  END IF;

  l_orig_item_tbl := cz_api_pub.NUMBER_TBL_TYPE();
  l_new_item_tbl  := cz_api_pub.NUMBER_TBL_TYPE();

  ----initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;

  ---check api version
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  ----verify that input array contains records
  IF (p_config_tbl.COUNT = 0) THEN
    RAISE NO_INPUT_RECORDS;
  END IF;

  ---verify that the input parameters are not null
  IF ( (p_tree_copy_mode IS NULL) OR (p_tree_copy_mode = FND_API.G_MISS_CHAR)) THEN
    RAISE INPUT_TREE_MODE_NULL;
  ELSIF (p_tree_copy_mode = CZ_API_PUB.G_NEW_HEADER_COPY_MODE) THEN
    new_config_flag := '0';
  ELSIF (p_tree_copy_mode = CZ_API_PUB.G_NEW_REVISION_COPY_MODE) THEN
    new_config_flag := '1';
  ELSE
    RAISE INVALID_TREE_MODE_ERR;
  END IF;

  ----verify validation context
  IF (p_validation_context IS NULL) THEN
    l_validation_context := NULL;
  ELSIF (p_validation_context = CZ_API_PUB.G_INSTALLED) THEN
    l_validation_context :=  CZ_API_PUB.G_INSTALLED;
  ELSIF (p_validation_context = CZ_API_PUB.G_PENDING_OR_INSTALLED) THEN
    l_validation_context := CZ_API_PUB.G_PENDING_OR_INSTALLED;
  ELSE
    RAISE INVALID_CONTEXT;
  END IF;

  container_model_tbl.DELETE;
  FOR configInstance IN p_config_tbl.FIRST..p_config_tbl.LAST
  LOOP
    IF (p_config_tbl(configInstance).config_hdr_id > 0) THEN
      l_config_hdr_id  := p_config_tbl(configInstance).config_hdr_id;
      l_config_rev_nbr := p_config_tbl(configInstance).config_rev_nbr;
      ----get header types
      get_header_types(l_config_hdr_id,l_config_rev_nbr,l_model_instantiation_type,l_component_instance_type);

      IF (l_model_instantiation_type = NETWORK) THEN
        IF (l_component_instance_type = INSTANCE_ROOT) THEN
          ----get container header
          get_container_header(l_config_hdr_id,l_config_rev_nbr,l_main_config_hdr_id,l_main_config_rev_nbr);

          ----if no container header is found raise exception
          IF ( (l_main_config_hdr_id = -1) OR (l_main_config_rev_nbr = -1) ) THEN
            RAISE INVALID_CONTAINER_HDR;
          END IF;

          ------get top inv item and org id
          get_root_bom_config_item(l_main_config_hdr_id,l_main_config_rev_nbr,l_inventory_item_id,l_organization_id,l_config_item_id);

          -----if no inv item id or org id is retrieved raise exception
          IF ( (l_inventory_item_id = -1) OR (l_organization_id = -1) ) THEN
            RAISE INVALID_INV_ORG_ID;
          END IF;

          ----check if the combination of inv item id and org id exists
          check_if_item_exists(l_inventory_item_id,l_organization_id,container_model_tbl,l_idx,exists_flag);


          ---if inv item and org id exists in the array then append instances else create a new rec
          inst_hdr_count := container_config_tbl.COUNT + 1;
          container_config_tbl(inst_hdr_count).inventory_item_id  := l_inventory_item_id;
          container_config_tbl(inst_hdr_count).config_hdr_id      := l_config_hdr_id;
          container_config_tbl(inst_hdr_count).config_rev_nbr     := l_config_rev_nbr;
          IF (NOT exists_flag) THEN
            inv_count      := container_model_tbl.COUNT + 1;
            inst_hdr_count := container_config_tbl.COUNT + 1;
            container_model_tbl(inv_count).inventory_item_id := l_inventory_item_id;
            container_model_tbl(inv_count).organization_id   := l_organization_id;
            container_model_tbl(inv_count).config_item_id    := l_config_item_id;
          END IF;

        ELSIF (l_component_instance_type = ROOT) THEN
          get_root_bom_config_item(l_config_hdr_id,l_config_rev_nbr,l_inventory_item_id,l_organization_id,l_config_item_id);
          v_config_hdr_id  := 0;
          v_config_rev_nbr := 0;

          CZ_CONFIG_API_PUB.copy_configuration(1.0,
                                               l_config_hdr_id,
                                               l_config_rev_nbr,
                                               p_tree_copy_mode,
                                               v_config_hdr_id,
                                               v_config_rev_nbr,
                                               l_orig_item_tbl,
                                               l_new_item_tbl,
                                               l_copy_config_status,
                                               l_cp_msg_count,
                                               l_copy_config_msg,
                                               NULL,
                                               NULL);

          IF (l_copy_config_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE COPY_CONFIG_FAILURE_EXCEP;
          ELSE
            reset_config_delta (v_config_hdr_id,v_config_hdr_id);
            v_ouput_config_count := x_config_model_tbl.COUNT + 1;
            x_config_model_tbl(v_ouput_config_count).config_hdr_id     := v_config_hdr_id;
            x_config_model_tbl(v_ouput_config_count).config_rev_nbr    := v_config_rev_nbr;
            x_config_model_tbl(v_ouput_config_count).inventory_item_id := l_inventory_item_id;
            x_config_model_tbl(v_ouput_config_count).organization_id   := l_organization_id;
            x_config_model_tbl(v_ouput_config_count).config_item_id    := l_config_item_id;
          END IF;
        ELSE
          RAISE INVALID_HEADER_TYPE;
        END IF; /* end if of l_component_instance_type = INSTANCE_ROOT */
      ELSE
        RAISE INVALID_HEADER_EXCEP;
      END IF; /* end if of l_model_instantiation_type = NETWORK */
    END IF;
  END LOOP;

  ---validate organization id in container_model_tbl
  ---if org ids are not the same then raise exception
  validate_org_id(container_model_tbl, org_id_flag);
  IF (NOT org_id_flag) THEN
    RAISE ORG_ID_EXCEP;
  END IF;

  -----batch validation for grouped network instances.
  IF (container_model_tbl.COUNT > 0) THEN
    FOR I IN container_model_tbl.FIRST..container_model_tbl.LAST
    LOOP


     BEGIN
       write_dummy_config ( container_model_tbl(i).inventory_item_id
                          , container_config_tbl
                          , l_dummy_config_hdr_id );
       COMMIT;

      create_hdr_xml( container_model_tbl(i).inventory_item_id,
                      container_model_tbl(i).organization_id,
                      null,
                      null,
                      l_dummy_config_hdr_id,
                      p_appl_param_rec,
                      p_tree_copy_mode,
                      l_validation_context,
                      l_xml_hdr);

      l_url := FND_PROFILE.VALUE('CZ_UIMGR_URL');
      config_messages.DELETE;
      cz_cf_api.validate(config_input_list,l_xml_hdr,config_messages,validation_status,l_url,p_validation_type);

     EXCEPTION
       WHEN OTHERS THEN
         delete_dummy_config ( l_dummy_config_hdr_id );
         COMMIT;
         RAISE;
     END;

     delete_dummy_config ( l_dummy_config_hdr_id );
     COMMIT;

      cz_debug_pub.get_batch_validate_message(validation_status,l_batch_validate_msg);

      IF (validation_status <> CZ_CF_API.CONFIG_PROCESSED) THEN
        RAISE BATCH_VALID_ERR;
      ELSE
        ----get config hdr id and config rev nbr from xml string
        IF (config_messages.COUNT > 0) THEN
          v_output_cfg_hdr_id := 0;
          v_xml_str := NULL;

          FOR xmlStr IN config_messages.FIRST..config_messages.LAST
          LOOP
            v_xml_str := v_xml_str||config_messages(xmlStr);
            populate_debug_message(config_messages(xmlStr),NULL,NULL);
          END LOOP;
        END IF;

        parse_output_xml (v_xml_str,
                          v_output_cfg_hdr_id,
                          v_output_cfg_rev_nbr,
                          v_parse_status);

        ----if error in parsing xml raise an exception
        IF (v_parse_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE PARSE_XML_ERROR;
        END IF;

        ---add the config hdr and rev to OUT NOCOPY put tbl
        IF (v_output_cfg_hdr_id > 0) THEN
          v_ouput_config_count := x_config_model_tbl.COUNT + 1;
          x_config_model_tbl(v_ouput_config_count).config_hdr_id  := v_output_cfg_hdr_id;
          x_config_model_tbl(v_ouput_config_count).config_rev_nbr := v_output_cfg_rev_nbr;

          ------get top inv item and org id
          get_root_bom_config_item(v_output_cfg_hdr_id,v_output_cfg_rev_nbr,l_inventory_item_id,l_organization_id,l_config_item_id);

          -----if no inv item id or org id is retrieved raise exception
          IF p_validation_type<>CZ_API_PUB.VALIDATE_RETURN AND
              ( l_inventory_item_id = -1 OR l_organization_id = -1 ) THEN
            RAISE INVALID_OUT_INV_ORG_ID;
          END IF;

          x_config_model_tbl(v_ouput_config_count).inventory_item_id := l_inventory_item_id;
          x_config_model_tbl(v_ouput_config_count).organization_id   := l_organization_id;
          x_config_model_tbl(v_ouput_config_count).config_item_id    := l_config_item_id;
        END IF;
      END IF;
    END LOOP;
  END IF;

  -----log messages for debugging
  populate_debug_message('Generation of config tree successful','CZ_NETWORK_API: '||to_char(sysdate, 'mm-dd-yyyy hh24:mi:ss'), 0);
  CZ_DEBUG_PUB.insert_into_logs(v_msg_tbl);
  trace_gen_config_trees (p_api_version,p_config_tbl,
                          p_tree_copy_mode,p_appl_param_rec,
                          p_validation_context,
                          x_config_model_tbl,
                          x_return_status);
  COMMIT;
EXCEPTION
  WHEN G_INCOMPATIBLE_API THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_VERSION_ERR', 'CODEVERSION', l_api_version, 'VERSION', p_api_version);
    set_fnd_message('CZ_NET_API_VERSION_ERR','CODEVERSION',l_api_version, 'VERSION', p_api_version);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN INVALID_VALIDATION_TYPE THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_BV_INVALID_TYPE','TYPE',p_validation_type);
    set_fnd_message('CZ_BV_INVALID_TYPE','TYPE',p_validation_type);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN NO_INPUT_RECORDS THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_NO_INPUT_HDRS','TABLE','p_config_tbl','PROC',l_api_name );
    set_fnd_message('CZ_NET_API_NO_INPUT_HDRS','TABLE','p_config_tbl','PROC',l_api_name);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN INPUT_TREE_MODE_NULL THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_INVALID_TREE_MODE','MODE',p_tree_copy_mode,'PROC',l_api_name);
    set_fnd_message('CZ_NET_API_INVALID_TREE_MODE','MODE',p_tree_copy_mode,'PROC',l_api_name);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN NO_VALIDATION_CONTEXT THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_INVALID_VAL_CTX', 'CTX', p_validation_context);
    set_fnd_message('CZ_NET_API_INVALID_VAL_CTX','CTX', p_validation_context, null, null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN INVALID_CONTEXT THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_INVALID_VAL_CTX', 'CTX', p_validation_context);
    set_fnd_message('CZ_NET_API_INVALID_VAL_CTX','CTX', p_validation_context, null, null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN INVALID_CONTAINER_HDR THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_NO_SESSION_HDR','HDRID',l_config_hdr_id,'REV',l_config_rev_nbr);
    set_fnd_message('CZ_NET_API_NO_SESSION_HDR','HDRID',l_config_hdr_id,'REV',l_config_rev_nbr);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN INVALID_HEADER_TYPE THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_INVALID_INST_HDR',
              'modelInstType', l_model_instantiation_type,
              'compInstType' , l_component_instance_type,
              'Hdr',l_config_hdr_id,
              'Rev',l_config_rev_nbr);
    set_fnd_message('CZ_NET_API_INVALID_INST_HDR',
        'modelInstType', l_model_instantiation_type,
        'compInstType' , l_component_instance_type,
        'Hdr',l_config_hdr_id,
        'Rev',l_config_rev_nbr);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN INVALID_INV_ORG_ID THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_NO_INV_FOR_CFG_HDR','HDR',l_main_config_hdr_id,'REV',l_main_config_rev_nbr);
    set_fnd_message('CZ_NET_API_NO_INV_FOR_CFG_HDR','HDR',l_main_config_hdr_id,'REV',l_main_config_rev_nbr);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN INVALID_OUT_INV_ORG_ID THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_NO_INV_FOR_CFG_HDR','HDR',v_output_cfg_hdr_id,'REV',v_output_cfg_rev_nbr);
    set_fnd_message('CZ_NET_API_NO_INV_FOR_CFG_HDR','HDR',v_output_cfg_hdr_id,'REV',v_output_cfg_rev_nbr);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    IF x_config_model_tbl.COUNT>0 AND p_validation_type<>CZ_API_PUB.VALIDATE_RETURN THEN
      delete_configuration(x_config_model_tbl);
      x_config_model_tbl.DELETE;
    END IF;
    COMMIT;
  WHEN INVALID_TREE_MODE_ERR THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_INVALID_TREE_MODE','MODE',p_tree_copy_mode,'PROC',l_api_name);
    set_fnd_message('CZ_NET_API_INVALID_TREE_MODE','MODE',p_tree_copy_mode,'PROC',l_api_name);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN ORG_ID_EXCEP THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_DIFF_ORGS');
    set_fnd_message('CZ_NET_API_DIFF_ORGS',null,null, null, null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN COPY_CONFIG_FAILURE_EXCEP THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_COPY_CONFIG_ERR', 'HDR',l_main_config_hdr_id,'REV',l_main_config_rev_nbr,'ERR',l_copy_config_msg);
    set_fnd_message('CZ_NET_API_COPY_CONFIG_ERR','HDR',l_main_config_hdr_id,'REV',l_main_config_rev_nbr,'ERR',l_copy_config_msg,null,null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN INVALID_HEADER_EXCEP THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_NO_SESSION_HDR', 'HDR',l_config_hdr_id,'REV',l_config_rev_nbr);
    set_fnd_message('CZ_NET_API_NO_SESSION_HDR', 'HDR',l_config_hdr_id,'REV',l_config_rev_nbr);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN BATCH_VALID_ERR THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_BV_ERR', 'STATUS', l_batch_validate_msg);
    set_fnd_message('CZ_NET_API_BV_ERR', 'STATUS', l_batch_validate_msg,null,null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN PARSE_XML_ERROR THEN
    l_config_err_msg := get_terminate_msg(v_xml_str);
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_PARSE_BV_XML_ERR','Err',l_config_err_msg,1,2000);
    set_fnd_message('CZ_NET_API_PARSE_BV_XML_ERR', 'ERR', substr(v_xml_str,1,2000),null,null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name);
    END IF;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
    delete_configuration(x_config_model_tbl);
    x_config_model_tbl.DELETE;
    COMMIT;
END generate_config_trees;

---------------------------------------------------------------------------
---Start of comments
---API name                 : generate_config_trees
---Type          : Public
---Pre-reqs                 : None
---Function                 : generates config trees for a given set of config hdr ids and rev nbrs
---Parameters               :
---IN      : p_api_version        IN  NUMBER              Required
---          p_config_tbl         IN  config_tbl_type     Required
---          p_tree_copy_mode     IN  VARCHAR2            Required
---          p_appl_param_rec     IN  appl_param_rec_type Required
---          p_validation_context IN  VARCHAR2            Required
---OUT     : x_return_status      OUT NOCOPY VARCHAR2
---          x_msg_count          OUT NOCOPY NUMBER
---          x_msg_data           OUT NOCOPY VARCHAR2
---Version: Current version :1.0
---End of comments

PROCEDURE generate_config_trees(p_api_version        IN  NUMBER,
                                p_config_tbl         IN  CZ_API_PUB.config_tbl_type,
                                p_tree_copy_mode     IN  VARCHAR2,
                                p_appl_param_rec     IN  CZ_API_PUB.appl_param_rec_type,
                                p_validation_context IN  VARCHAR2,
                                x_config_model_tbl   OUT NOCOPY CZ_API_PUB.config_model_tbl_type,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2
                               )
IS
BEGIN

  generate_config_trees(p_api_version        => p_api_version,
                        p_config_tbl         => p_config_tbl,
                        p_tree_copy_mode     => p_tree_copy_mode,
                        p_appl_param_rec     => p_appl_param_rec,
                        p_validation_context => p_validation_context,
                        p_validation_type    => CZ_API_PUB.INTERACTIVE,
                        x_config_model_tbl   => x_config_model_tbl,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data
        );

END generate_config_trees;

------------------------------------------------------------------------------------------------
-----procedure adds instances to the saved configuration of a container model
PROCEDURE add_to_config_tree (p_api_version     IN  NUMBER,
          p_inventory_item_id  IN  NUMBER,
          p_organization_id    IN  NUMBER,
          p_config_hdr_id      IN  NUMBER,
          p_config_rev_nbr     IN  NUMBER,
          p_instance_tbl       IN  CZ_API_PUB.config_tbl_type,
          p_tree_copy_mode     IN  VARCHAR2,
          p_appl_param_rec     IN  CZ_API_PUB.appl_param_rec_type,
          p_validation_context IN  VARCHAR2,
          x_config_model_rec   OUT NOCOPY CZ_API_PUB.config_model_rec_type,
          x_return_status      OUT NOCOPY VARCHAR2,
          x_msg_count          OUT NOCOPY NUMBER,
          x_msg_data           OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_api_name           CONSTANT VARCHAR2(30) := 'add_to_config_tree';
l_api_version        CONSTANT NUMBER := 1.0;

l_config_hdr_id      cz_config_hdrs.config_hdr_id%TYPE;
l_config_rev_nbr     cz_config_hdrs.config_rev_nbr%TYPE;

l_inventory_item_id     cz_config_items.inventory_item_id%TYPE;
l_organization_id       cz_config_items.organization_id%TYPE;
l_config_item_id        cz_config_items.config_item_id%TYPE;

l_main_config_hdr_id    cz_config_hdrs.config_hdr_id%TYPE;
l_main_config_rev_nbr   cz_config_hdrs.config_rev_nbr%TYPE;

l_config_model_tbl      CZ_API_PUB.config_model_tbl_type;
l_con_config_tbl        container_config_tbl_type;

l_model_instantiation_type VARCHAR2(1);
l_component_instance_type  VARCHAR2(1);

config_input_list       cz_cf_api.cfg_input_list;
config_messages         cz_cf_api.cfg_output_pieces;
validation_status       NUMBER;
l_batch_validate_msg    VARCHAR2(100);
v_output_cfg_hdr_id     NUMBER := 0;
v_output_cfg_rev_nbr    NUMBER := 0;
v_valid_config          VARCHAR2(30);
v_complete_config       VARCHAR2(30);

l_xml_hdr               VARCHAR2(32767);

v_config_hdr_id         NUMBER;
v_config_rev_nbr        NUMBER;
l_copy_config_msg       VARCHAR2(2000);

v_ouput_config_count    NUMBER := 0;
v_xml_str               LONG;
l_idx                   NUMBER;
new_config_flag         VARCHAR2(1);
instance_hdr_count      NUMBER;

l_msg_count             NUMBER;
l_msg_data              VARCHAR2(10000);
l_errbuf                VARCHAR2(2000);
l_copy_config_status    NUMBER;
v_parse_status          VARCHAR2(1);
l_validation_context    VARCHAR2(1);
l_url                   VARCHAR2(255);
l_config_err_msg        VARCHAR2(2000);
l_dummy_config_hdr_id   NUMBER;

INPUT_TREE_MODE_NULL    EXCEPTION;
BATCH_VALID_FAILURE     EXCEPTION;
INVALID_CONTAINER_HDR   EXCEPTION;
INVALID_INV_ORG_ID      EXCEPTION;
GEN_CONFIG_TREE_ERR     EXCEPTION;
INVALID_HEADER_TYPE     EXCEPTION;
MODEL_ORG_EXCEP         EXCEPTION;
BATCH_VALID_ERR         EXCEPTION;
PARSE_XML_ERROR         EXCEPTION;
NO_INPUT_RECORDS        EXCEPTION;
INVALID_CONTEXT         EXCEPTION;
INVALID_TREE_MODE_ERR   EXCEPTION;
NO_VALIDATION_CONTEXT   EXCEPTION;

BEGIN
  ----initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;

  ---check api version
  IF NOT FND_API.Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  ---check if instance records are passed
  IF (p_instance_tbl.COUNT = 0) THEN
    RAISE NO_INPUT_RECORDS;
  END IF;

  ---verify that the input parameters are not null
  IF ( (p_tree_copy_mode IS NULL) OR (p_tree_copy_mode = FND_API.G_MISS_CHAR)) THEN
    RAISE INPUT_TREE_MODE_NULL;
  ELSIF (p_tree_copy_mode = CZ_API_PUB.G_NEW_HEADER_COPY_MODE) THEN
    new_config_flag := '0';
  ELSIF (p_tree_copy_mode = CZ_API_PUB.G_NEW_REVISION_COPY_MODE) THEN
    new_config_flag := '1';
  ELSE
    RAISE INVALID_TREE_MODE_ERR;
  END IF;

  ----verify validation context
  IF (p_validation_context IS NULL) THEN
    l_validation_context := NULL;
  ELSIF (p_validation_context = CZ_API_PUB.G_INSTALLED) THEN
    l_validation_context :=  CZ_API_PUB.G_INSTALLED;
  ELSIF (p_validation_context = CZ_API_PUB.G_PENDING_OR_INSTALLED) THEN
    l_validation_context := CZ_API_PUB.G_PENDING_OR_INSTALLED;
  ELSE
    RAISE INVALID_CONTEXT;
  END IF;

  ---validate instance headers
  ---this is not required as adding of a non-network instance is allowed
  IF (p_instance_tbl.COUNT > 0) THEN
    FOR configInstance IN p_instance_tbl.FIRST..p_instance_tbl.LAST
    LOOP
      l_config_hdr_id  := p_instance_tbl(configInstance).config_hdr_id;
      l_config_rev_nbr := p_instance_tbl(configInstance).config_rev_nbr;

      ----get header types
      get_header_types(l_config_hdr_id,l_config_rev_nbr,l_model_instantiation_type,l_component_instance_type);

      IF ( (l_model_instantiation_type <> NETWORK) OR (l_component_instance_type <> INSTANCE_ROOT) ) THEN
        RAISE INVALID_HEADER_TYPE;
      END IF;
    END LOOP;
  END IF;

  IF ( (p_config_hdr_id IS NOT NULL) AND (p_config_rev_nbr IS NOT NULL) ) THEN
    get_header_types(p_config_hdr_id,p_config_rev_nbr,l_model_instantiation_type,l_component_instance_type);
    IF ( (l_model_instantiation_type <> NETWORK) OR (l_component_instance_type <> ROOT) ) THEN
      RAISE INVALID_HEADER_TYPE;
    END IF;

    IF ( (p_inventory_item_id IS NOT NULL) AND (p_organization_id IS NOT NULL) ) THEN
      ------get top inv item and org id
      get_root_bom_config_item(p_config_hdr_id,p_config_rev_nbr,l_inventory_item_id,l_organization_id,l_config_item_id);

      -----if no inv item id or org id is retrieved raise exception
      IF ( (l_inventory_item_id = -1) OR (l_organization_id = -1) ) THEN
        RAISE INVALID_INV_ORG_ID;
      END IF;

      -----if OUT NOCOPY put inv id and org id are not equal to input model id and org id raise exception
      IF ( (l_inventory_item_id <> p_inventory_item_id) OR (l_organization_id <> p_organization_id) ) THEN
        RAISE MODEL_ORG_EXCEP;
      END IF;
    END IF; /* end if of (p_inventory_item_id IS NOT NULL) */

    ----initialize config array for creating xml hdr
    l_con_config_tbl.DELETE;
    IF (p_instance_tbl.COUNT > 0) THEN
      FOR inst IN p_instance_tbl.FIRST..p_instance_tbl.LAST
      LOOP
        instance_hdr_count := l_con_config_tbl.COUNT + 1;
        l_con_config_tbl(instance_hdr_count).inventory_item_id := p_inventory_item_id;
        l_con_config_tbl(instance_hdr_count).config_hdr_id     := p_instance_tbl(inst).config_hdr_id;
        l_con_config_tbl(instance_hdr_count).config_rev_nbr    := p_instance_tbl(inst).config_rev_nbr;
      END LOOP;
    END IF;

    BEGIN
      write_dummy_config ( p_inventory_item_id
                         , l_con_config_tbl
                         , l_dummy_config_hdr_id );
      COMMIT;

    -----create init message
    create_hdr_xml( p_inventory_item_id,
                    p_organization_id,
                    p_config_hdr_id,
                    p_config_rev_nbr,
                    l_dummy_config_hdr_id,
                    p_appl_param_rec,
                    p_tree_copy_mode,
                    l_validation_context,
                    l_xml_hdr);

    config_input_list.DELETE;
    l_url := FND_PROFILE.VALUE('CZ_UIMGR_URL');
    config_messages.DELETE;
    cz_cf_api.validate(config_input_list,l_xml_hdr,config_messages,validation_status,l_url,CZ_API_PUB.INTERACTIVE);

    EXCEPTION
      WHEN OTHERS THEN
        delete_dummy_config ( l_dummy_config_hdr_id );
        COMMIT;
        RAISE;
    END;

    delete_dummy_config ( l_dummy_config_hdr_id );
    COMMIT;

    cz_debug_pub.get_batch_validate_message(validation_status,l_batch_validate_msg);

    IF (validation_status <> CZ_CF_API.CONFIG_PROCESSED) THEN
      RAISE BATCH_VALID_ERR;
    ELSE
      ----get config hdr id and config rev nbr from xml string
      IF (config_messages.COUNT > 0) THEN
        v_output_cfg_hdr_id := 0;
        v_xml_str := NULL;

        FOR xmlStr IN config_messages.FIRST..config_messages.LAST
        LOOP
          v_xml_str := v_xml_str||config_messages(xmlStr);
        END LOOP;
      END IF;

      parse_output_xml (v_xml_str,
                        v_output_cfg_hdr_id,
                        v_output_cfg_rev_nbr,
                        v_parse_status);

      ----if error in parsing xml raise an exception
      IF (v_parse_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE PARSE_XML_ERROR;
      END IF;

      ---add the config hdr and rev to OUT NOCOPY put tbl
      IF (v_output_cfg_hdr_id > 0) THEN
        x_config_model_rec.config_hdr_id     := v_output_cfg_hdr_id;
        x_config_model_rec.config_rev_nbr    := v_output_cfg_rev_nbr;
        x_config_model_rec.inventory_item_id := p_inventory_item_id;
        x_config_model_rec.organization_id   := p_organization_id;
        x_config_model_rec.config_item_id    := l_config_item_id;
      END IF;
    END IF;  /* end if of validation_status <> CZ_CF_API.CONFIG_PROCESSED */

  ELSE  /* if p_config_hdr_id is NULL */
    ----generate config tree
    generate_config_trees(l_api_version,
                          p_instance_tbl,
                          p_tree_copy_mode,
                          p_appl_param_rec,
                          l_validation_context,
                          l_config_model_tbl,
                          x_return_status,
                          x_msg_count,
                          x_msg_data
                         );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE GEN_CONFIG_TREE_ERR;
    END IF;

    IF (l_config_model_tbl.COUNT > 1) THEN
      RAISE GEN_CONFIG_TREE_ERR;
    END IF;

    IF ( (p_inventory_item_id IS NOT NULL) AND (p_organization_id IS NOT NULL) ) THEN
      IF ( (p_inventory_item_id <> l_config_model_tbl(1).inventory_item_id)
        OR (p_organization_id <> l_config_model_tbl(1).organization_id) ) THEN
        RAISE MODEL_ORG_EXCEP;
      END IF;
    END IF;

    x_config_model_rec.config_hdr_id     := l_config_model_tbl(1).config_hdr_id;
    x_config_model_rec.config_rev_nbr    := l_config_model_tbl(1).config_rev_nbr;
    x_config_model_rec.inventory_item_id := l_config_model_tbl(1).inventory_item_id;
    x_config_model_rec.organization_id   := l_config_model_tbl(1).organization_id;
    x_config_model_rec.config_item_id    := l_config_model_tbl(1).config_item_id;

  END IF; /* end if of (p_config_hdr_id IS NOT NULL) */
  trace_add_to_config_trees (p_api_version,p_inventory_item_id,p_organization_id,p_config_hdr_id,p_config_rev_nbr
        ,p_instance_tbl,p_tree_copy_mode,p_appl_param_rec,p_validation_context,x_config_model_rec
        ,x_return_status,x_msg_count,x_msg_data);
  COMMIT;
EXCEPTION
  WHEN G_INCOMPATIBLE_API THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_VERSION_ERR', 'CODEVERSION', l_api_version, 'VERSION', p_api_version);
    set_fnd_message('CZ_NET_API_VERSION_ERR','CODEVERSION',l_api_version, 'VERSION', p_api_version);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN NO_INPUT_RECORDS THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_NO_INPUT_HDRS','TABLE','p_instance_tbl','PROC',l_api_name );
    set_fnd_message('CZ_NET_API_NO_INPUT_HDRS','TABLE','p_instance_tbl','PROC',l_api_name);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN INVALID_HEADER_TYPE THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_INVALID_INST_HDR','modelInstType', l_model_instantiation_type,
              'compInstType',l_component_instance_type,'Hdr',l_config_hdr_id,
              'Rev',l_config_rev_nbr);
    set_fnd_message('CZ_NET_API_INVALID_INST_HDR','modelInstType', l_model_instantiation_type,
        'compInstType',l_component_instance_type,'Hdr',l_config_hdr_id,
        'Rev',l_config_rev_nbr);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN INVALID_CONTEXT THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_INVALID_VAL_CTX', 'CTX', p_validation_context);
    set_fnd_message('CZ_NET_API_INVALID_VAL_CTX','CTX',p_validation_context, null, null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN NO_VALIDATION_CONTEXT THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_INVALID_VAL_CTX','CTX', p_validation_context);
    set_fnd_message('CZ_NET_API_INVALID_VAL_CTX','CTX', p_validation_context, null, null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN INVALID_INV_ORG_ID THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_NO_INV_FOR_CFG_HDR', 'HDR',l_config_hdr_id,'REV',l_config_rev_nbr);
    set_fnd_message('CZ_NET_API_NO_INV_FOR_CFG_HDR','HDR',l_config_hdr_id,'REV',l_config_rev_nbr);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN MODEL_ORG_EXCEP THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_MODELID_ORGID_ERR',
              'ITEM1',l_inventory_item_id,
              'ORGID1',l_organization_id,
              'HDRID',p_config_hdr_id,
              'REVNBR',p_config_rev_nbr,
              'ITEM2',p_inventory_item_id,
              'ORGID2',p_organization_id);
    set_fnd_message('CZ_NET_API_MODELID_ORGID_ERR',
              'ITEM1', l_inventory_item_id,
              'ORGID1',l_organization_id,
              'HDRID', p_config_hdr_id,
              'REVNBR',p_config_rev_nbr,
              'ITEM2', p_inventory_item_id,
              'ORGID2',p_organization_id);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN BATCH_VALID_ERR THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_BV_ERR', 'STATUS', l_batch_validate_msg);
    set_fnd_message('CZ_NET_API_BV_ERR', 'STATUS', l_batch_validate_msg, null, null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN PARSE_XML_ERROR THEN
    l_config_err_msg := get_terminate_msg(v_xml_str);
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_PARSE_BV_XML_ERR','ERR',l_config_err_msg);
    set_fnd_message('CZ_NET_API_NO_CFG_HDR', 'ERR', substr(v_xml_str,1,2000),null,null);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN GEN_CONFIG_TREE_ERR THEN
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_NET_API_TREE_GEN_ERR','HDR',l_config_hdr_id,'REV',l_config_rev_nbr);
    set_fnd_message('CZ_NET_API_TREE_GEN_ERR', 'HDR',l_config_hdr_id,'REV',l_config_rev_nbr);
    set_error_message(x_return_status,x_msg_count,x_msg_data,l_errbuf);
    COMMIT;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(NULL,x_msg_count,x_msg_data);
    COMMIT;
END add_to_config_tree;

-----------------------------------------------------------------------------
-- API name:  is_container_pvt
-- API type:  private
-- Function:  Checks if a given model is a network container model
-- Pre-Reqs:  input model is in cz schema

FUNCTION is_container_pvt(p_model_id IN NUMBER)
  RETURN BOOLEAN

IS
  l_model_type  cz_devl_projects.model_type%TYPE;

BEGIN

  SELECT model_type INTO l_model_type
  FROM cz_devl_projects
  WHERE devl_project_id = p_model_id
  AND deleted_flag = NO_FLAG;

  RETURN (upper(l_model_type) = NETWORK);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END is_container_pvt;

-----------------------------------------------------------------------------
-- API name:  get_contained_models_pvt
-- API type:  private
-- Function:  Retrieves all trackable and instantiable child models for a
--            given network container model.

procedure get_contained_models_pvt(p_model_id IN NUMBER
                                  ,p_inventory_item_id_tbl IN OUT NOCOPY CZ_API_PUB.number_tbl_type
                                  )
IS
  l_model_id           NUMBER := p_model_id;
  l_reference_id       NUMBER;
  l_inventory_item_id  NUMBER := NULL;
  l_index              NUMBER := 0;
  l_count              NUMBER;

  CURSOR child_model_csr IS
    SELECT reference_id
    FROM cz_ps_nodes
    WHERE devl_project_id = l_model_id
      AND ps_node_type = PS_NODE_TYPE_REFERENCE
      AND deleted_flag = NO_FLAG;

BEGIN
  FOR child_model_rec IN child_model_csr
  LOOP
    l_reference_id := child_model_rec.reference_id;
    BEGIN
      SELECT to_number(substr(orig_sys_ref, instr(orig_sys_ref, ':', -1, 1)+1))
        INTO l_inventory_item_id
      FROM   cz_ps_nodes
      WHERE  ps_node_id = l_reference_id
        AND  ib_trackable = YES_FLAG
        AND  deleted_flag = NO_FLAG;

      -- check if the model is already in array
      -- Note: if arrray size is big, use hashing insead of iteration
      l_index := 1;
      l_count := p_inventory_item_id_tbl.COUNT;

      WHILE (l_index <= l_count AND l_inventory_item_id <> p_inventory_item_id_tbl(l_index))
      LOOP
        l_index := l_index + 1;
      END LOOP;

      -- new entry
      IF (l_index > l_count) THEN
        p_inventory_item_id_tbl.extend(1);
        p_inventory_item_id_tbl(l_index) := l_inventory_item_id;
      END IF;
      l_inventory_item_id := NULL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN  -- not trackable, lookup further down the branch
        get_contained_models_pvt(l_reference_id, p_inventory_item_id_tbl);
    END;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_contained_models_pvt;

-----------------------------------------------------------------------------
-- API name:  get_contained_models
-- API type:  public
-- Function:  Retrieves all possible enclosed trackable child models for the network
--            container model specified by the input inventory_item_id and
--            organization_id

procedure get_contained_models(p_api_version        IN   NUMBER
                              ,p_inventory_item_id  IN   NUMBER
                              ,p_organization_id    IN   NUMBER
                              ,p_appl_param_rec     IN   CZ_API_PUB.appl_param_rec_type
                              ,x_model_tbl          OUT NOCOPY  CZ_API_PUB.number_tbl_type
                              ,x_return_status      OUT NOCOPY  VARCHAR2
                              ,x_msg_count          OUT NOCOPY  NUMBER
                              ,x_msg_data           OUT NOCOPY  VARCHAR2
                              )
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'get_contained_models';

  l_config_creation_date      DATE := p_appl_param_rec.config_creation_date;
  l_config_model_lookup_date  DATE := p_appl_param_rec.config_model_lookup_date;
  l_config_effective_date     DATE := p_appl_param_rec.config_effective_date;

  l_model_id               NUMBER;
  l_inventory_item_id_tbl  CZ_API_PUB.number_tbl_type := cz_api_pub.NUMBER_TBL_TYPE();
  l_msg_data               VARCHAR2(2000);
  l_appl_param_rec         CZ_API_PUB.appl_param_rec_type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;
  x_model_tbl := cz_api_pub.NUMBER_TBL_TYPE();
  -- standard call to check for call compatibility
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ----default pb applicability parameters to NULL if no values are passed in
  l_appl_param_rec.config_creation_date     := p_appl_param_rec.config_creation_date;
  l_appl_param_rec.config_model_lookup_date := p_appl_param_rec.config_model_lookup_date;
  l_appl_param_rec.config_effective_date    := p_appl_param_rec.config_effective_date;
  l_appl_param_rec.calling_application_id   := p_appl_param_rec.calling_application_id;
  l_appl_param_rec.usage_name               := p_appl_param_rec.usage_name;
  l_appl_param_rec.publication_mode         := p_appl_param_rec.publication_mode;
  l_appl_param_rec.language                 := p_appl_param_rec.language;

  default_pb_parameters(l_appl_param_rec,x_return_status);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- defaulting date values if not passed in
  cz_cf_api.default_new_cfg_dates(l_appl_param_rec.config_creation_date
                                 ,l_appl_param_rec.config_model_lookup_date
                                 ,l_appl_param_rec.config_effective_date
                                 );

  -- publication look up
  l_model_id := cz_cf_api.config_model_for_item
                              (p_inventory_item_id
                              ,p_organization_id
                              ,l_appl_param_rec.config_model_lookup_date
                              ,l_appl_param_rec.calling_application_id
                              ,l_appl_param_rec.usage_name
                              ,l_appl_param_rec.publication_mode
                              ,l_appl_param_rec.language
                              );

  -- in case of publication look up failure
  IF (l_model_id IS NULL) THEN
    fnd_message.set_name('CZ', 'CZ_NO_PUB_MODEL');
    fnd_message.set_token('inventory_item_id', p_inventory_item_id);
    fnd_message.set_token('organization', p_organization_id);
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- must be a network container model
  IF (NOT is_container_pvt(l_model_id)) THEN
    fnd_message.set_name('CZ', 'CZ_NOT_CONTAINER_MODEL');
    fnd_message.set_token('model', l_model_id);
    fnd_msg_pub.add;

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  get_contained_models_pvt(l_model_id, l_inventory_item_id_tbl);
  x_model_tbl := l_inventory_item_id_tbl;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END get_contained_models;

-----------------------------------------------------------------------------
-- API name:  is_container
-- API type:  public
-- Function:  Checks if a model specified by the top inventory_item_id and
--            organization_id is a network container model.

procedure is_container(p_api_version        IN   NUMBER
                      ,p_inventory_item_id  IN   NUMBER
                      ,p_organization_id    IN   NUMBER
                      ,p_appl_param_rec     IN   CZ_API_PUB.appl_param_rec_type
                      ,x_return_value       OUT NOCOPY  VARCHAR2
                      ,x_return_status      OUT NOCOPY  VARCHAR2
                      ,x_msg_count          OUT NOCOPY  NUMBER
                      ,x_msg_data           OUT NOCOPY  VARCHAR2
                      )
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'is_container';
BEGIN
  fnd_msg_pub.initialize;

  -- standard call to check for call compatibility
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SELECT DECODE(config_model_type, NETWORK_CONTAINER_MODEL, FND_API.G_TRUE, FND_API.G_FALSE)
    INTO x_return_value
  FROM mtl_system_items_b
  WHERE inventory_item_id = p_inventory_item_id AND organization_id = p_organization_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_value := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := 'The input inventory item ' || p_inventory_item_id || ' with organization ' ||
                  p_organization_id || ' does not exist';

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_value := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END is_container;

---------------------------------------------------------------------------
-- API name:  is_configurable
-- API type:  public
-- Function:  Checks whether a config item is independently configurable

procedure is_configurable(p_api_version     IN   NUMBER
                         ,p_config_hdr_id   IN   NUMBER
                         ,p_config_rev_nbr  IN   NUMBER
                         ,p_config_item_id  IN   NUMBER
                         ,x_return_value    OUT NOCOPY  VARCHAR2
                         ,x_return_status   OUT NOCOPY  VARCHAR2
                         ,x_msg_count       OUT NOCOPY  NUMBER
                         ,x_msg_data        OUT NOCOPY  VARCHAR2
                         )
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'is_configurable';

  l_component_instance_type cz_config_items.component_instance_type%TYPE;

BEGIN
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BEGIN
    SELECT component_instance_type INTO l_component_instance_type
    FROM cz_config_items
    WHERE config_hdr_id = p_config_hdr_id
      AND config_rev_nbr = p_config_rev_nbr
      AND config_item_id = p_config_item_id
      AND deleted_flag = NO_FLAG;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('CZ','CZ_NO_CFG_ITEM');
      fnd_message.set_token('hdr_id','p_config_hdr_id');
      fnd_message.set_token('revision','p_config_hdr_id');
      fnd_message.set_token('item', p_config_item_id);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
  END;

  IF (l_component_instance_type = INSTANCE_ROOT) THEN
    x_return_value := FND_API.G_TRUE;
  ELSE
    x_return_value := FND_API.G_FALSE;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END is_configurable;

------------------------------------------------------------------------
-- API name:  is_rma_allowed
-- API type:  public
-- Function:  Checks if a configurable item instance can be split

procedure is_rma_allowed(p_api_version     IN   NUMBER
                        ,p_config_hdr_id   IN   NUMBER
                        ,p_config_rev_nbr  IN   NUMBER
                        ,p_config_item_id  IN   NUMBER
                        ,x_return_value    OUT NOCOPY  VARCHAR2
                        ,x_return_status   OUT NOCOPY  VARCHAR2
                        ,x_msg_count       OUT NOCOPY  NUMBER
                        ,x_msg_data        OUT NOCOPY  VARCHAR2
                        )
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'is_rma_allowed';

  l_model_instantiation_type cz_config_hdrs.model_instantiation_type%TYPE;
  l_component_instance_type  cz_config_hdrs.component_instance_type%TYPE;

BEGIN
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  get_header_types(p_config_hdr_id
                  ,p_config_rev_nbr
                  ,l_model_instantiation_type
                  ,l_component_instance_type
                  );
  IF (l_model_instantiation_type = NO_FLAG) THEN
    fnd_message.set_name('CZ','CZ_NO_CFG');
    fnd_message.set_token('hdr_id','p_config_hdr_id');
    fnd_message.set_token('revision','p_config_hdr_id');
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_model_instantiation_type <> NETWORK) THEN
    x_return_value := FND_API.G_TRUE;
  ELSE
    x_return_value := FND_API.G_FALSE;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END is_rma_allowed;

---------------------------------------------------------------------
------procedure that gets the root instance , component_instance_type = 'I'
------for the config_item_id that is passed in
PROCEDURE get_root_instance(p_config_hdr_id   IN NUMBER,
                            p_config_rev_nbr  IN NUMBER,
                            p_config_item_id  IN NUMBER,
                            x_root_inst_changed OUT NOCOPY BOOLEAN)
IS

CURSOR config_sub_tree_cur IS
      SELECT component_instance_type,config_delta,ext_activated_flag
        FROM cz_config_items
       WHERE config_hdr_id = p_config_hdr_id
         AND config_rev_nbr  = p_config_rev_nbr
         AND deleted_flag    = NO_FLAG
      START WITH config_item_id = p_config_item_id
        AND config_hdr_id   = p_config_hdr_id
        AND config_rev_nbr  = p_config_rev_nbr
        AND deleted_flag    = NO_FLAG
      CONNECT BY PRIOR parent_config_item_id = config_item_id
        AND config_hdr_id  = p_config_hdr_id
        AND config_rev_nbr = p_config_rev_nbr
        AND deleted_flag   = NO_FLAG;

l_component_instance_type cz_config_items.component_instance_type%TYPE;
l_config_delta            cz_config_items.config_delta%TYPE;
l_ext_activated_flag      cz_config_items.ext_activated_flag%TYPE;

BEGIN
  x_root_inst_changed := FALSE;
  OPEN config_sub_tree_cur;
  LOOP
    FETCH config_sub_tree_cur
     INTO l_component_instance_type, l_config_delta, l_ext_activated_flag;
    EXIT WHEN config_sub_tree_cur%NOTFOUND;
    IF (l_component_instance_type = 'I') THEN
      EXIT;
    END IF;
  END LOOP;
  CLOSE config_sub_tree_cur;

  IF (l_component_instance_type = 'I') THEN
    IF ((l_config_delta <> 0) AND (l_ext_activated_flag <> '1')) THEN
      x_root_inst_changed := TRUE;
    END IF;
  ELSE
    x_root_inst_changed := FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (config_sub_tree_cur%ISOPEN) THEN
      CLOSE config_sub_tree_cur;
    END IF;
END get_root_instance;
-------------------------------------------
-----procedure that retrieves the children of the config item id
-----that has been passed in (for a config hdr and config rev)
PROCEDURE get_child_items(p_config_hdr_id   IN NUMBER,
                          p_config_rev_nbr  IN NUMBER,
                          p_config_item_id  IN NUMBER,
                          x_child_config_tbl OUT NOCOPY CZ_API_PUB.number_tbl_type)

IS

BEGIN
  SELECT config_item_id BULK COLLECT INTO x_child_config_tbl
  FROM cz_config_items
  WHERE config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
    AND deleted_flag = NO_FLAG
  START WITH config_item_id = p_config_item_id
    AND config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
    AND deleted_flag = NO_FLAG
  CONNECT BY PRIOR config_item_id = parent_config_item_id
    AND config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
    AND deleted_flag = NO_FLAG;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ---the query returns no rows so ignore
    NULL;
  WHEN OTHERS THEN
    RAISE;
END get_child_items;
-----------------------------------------------------------------------------
-- API name:  ext_deactivate_item
-- API type:  public
-- Function:  Externally deactivates an instance from CZ_CONFIG_DETAILS_V
-- Note    :  Marks the specified config item and all of its child config items as
--            externally deactivated. If any of those items has no other changes,
--            they will be filtered OUT NOCOPY from the view CZ_CONFIG_DETAILS_V.

procedure ext_deactivate_item(p_api_version     IN   NUMBER
                             ,p_config_hdr_id   IN   NUMBER
                             ,p_config_rev_nbr  IN   NUMBER
                             ,p_config_item_id  IN   NUMBER
                             ,x_return_status   OUT NOCOPY  VARCHAR2
                             ,x_msg_count       OUT NOCOPY  NUMBER
                             ,x_msg_data        OUT NOCOPY  VARCHAR2
                             )
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name VARCHAR2(30) := 'ext_deactivate_item';
  l_ext_activated_flag  VARCHAR2(1);
  l_root_inst_changed   BOOLEAN;
  v_child_config_tbl    CZ_API_PUB.number_tbl_type;
  l_run_id      NUMBER;
  l_config_item_id   NUMBER;
  REMOVE_IB_ERR    EXCEPTION;

BEGIN
  fnd_msg_pub.initialize;
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     ))  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -----get root instance for the config_item_id
  get_root_instance(p_config_hdr_id,
        p_config_rev_nbr,
        p_config_item_id,
        l_root_inst_changed);

  IF (l_root_inst_changed) THEN
    -----get all the children of the config item id that is passed in
    get_child_items (p_config_hdr_id,p_config_rev_nbr,p_config_item_id,v_child_config_tbl);

    IF (v_child_config_tbl.COUNT > 0) THEN
      FOR childItem IN v_child_config_tbl.FIRST..v_child_config_tbl.LAST
      LOOP
        l_config_item_id := v_child_config_tbl(childItem);
        cz_ib_transactions.remove_ib_config(p_session_config_hdr_id =>   p_config_hdr_id,
                  p_session_config_rev_nbr => p_config_rev_nbr,
                  p_instance_item_id =>  l_config_item_id,
                  x_run_id =>  l_run_id
                  );
        IF (l_run_id > 0) THEN
          RAISE REMOVE_IB_ERR;
        END IF;
      END LOOP;
    END IF;
  END IF;

  l_ext_activated_flag := '1';
  UPDATE cz_config_items
  SET    ext_activated_flag = NO_FLAG
  WHERE  ext_activated_flag = l_ext_activated_flag
    AND  config_hdr_id = p_config_hdr_id
    AND  config_rev_nbr = p_config_rev_nbr
    AND  config_item_id IN
      (SELECT config_item_id
       FROM cz_config_items
       WHERE config_hdr_id = p_config_hdr_id
         AND config_rev_nbr = p_config_rev_nbr
         AND deleted_flag = NO_FLAG
       START WITH config_item_id = p_config_item_id
         AND config_hdr_id = p_config_hdr_id
         AND config_rev_nbr = p_config_rev_nbr
         AND deleted_flag = NO_FLAG
       CONNECT BY PRIOR config_item_id = parent_config_item_id
         AND config_hdr_id = p_config_hdr_id
         AND config_rev_nbr = p_config_rev_nbr
         AND deleted_flag = NO_FLAG);

  IF (SQL%ROWCOUNT > 0) THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
    set_fnd_message('CZ_IB_API_NO_DEACTIVATE','ConfigHdrId',p_config_hdr_id, 'ConfigRevNbr', p_config_rev_nbr);
  END IF;
  fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);

EXCEPTION
  WHEN REMOVE_IB_ERR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    set_fnd_message('CZ_IB_DEACT_REMOVE_IB_ERR',
          'ConfigHdrId',  p_config_hdr_id,
          'ConfigRevNbr', p_config_rev_nbr,
          'ConfigItemId', l_config_item_id,
          'RunId', l_run_id);
    fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END ext_deactivate_item;

------------------------------------------------------------------------------------------
/*  The CZ stub patch for use as a prereq by other teams will contain CZ_NETWORK_API_PUB.validate
    but not CZ_CF_API.validate.  Existing customers have CZ_CF_API.validate,
    but without the new p_validation_type parameter. If the CZ stub patch is applied
    with your product's MACD changes but without CZ's MACD changes,
    your code will not compile if it calls CZ_CF_API.validate with p_validation_type. */

PROCEDURE VALIDATE(config_input_list IN  CZ_CF_API.CFG_INPUT_LIST,        -- input selections
             init_message      IN  VARCHAR2,                              -- additional XML
             config_messages   IN OUT NOCOPY CZ_CF_API.CFG_OUTPUT_PIECES, -- table of output XML messages
             validation_status IN OUT NOCOPY NUMBER,                      -- status return
             URL               IN  VARCHAR2 DEFAULT FND_PROFILE.Value('CZ_UIMGR_URL'),
             p_validation_type IN  VARCHAR2 DEFAULT CZ_API_PUB.VALIDATE_ORDER
        )

IS

BEGIN
  cz_cf_api.validate( config_input_list,
                      init_message,
                      config_messages,
                      validation_status,
                      URL,
                      p_validation_type);
END VALIDATE;


-- The "is_item_added" function returns 1 if the config item has an "add" delta, 0 if not.
-- Note that p_config_hdr_id and p_config_rev_nbr are for the session header, not the instance header.

FUNCTION is_item_added (p_config_hdr_id IN NUMBER,
                        p_config_rev_nbr IN NUMBER,
                        p_config_item_id IN NUMBER) RETURN pls_integer IS
  l_delta pls_integer;
  l_hex_format varchar2(20) := 'FM0000X';
  -- add bit is bit 1, which has a value of 2 when turned on
  l_add_bit pls_integer := 2;
BEGIN
  SELECT config_delta INTO l_delta
  FROM cz_config_items
  WHERE config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
    AND config_item_id = p_config_item_id;

  IF to_number(utl_raw.bit_and(to_char(l_delta,l_hex_format), to_char(l_add_bit,l_hex_format))) > 0 THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END is_item_added;

----------------------------------------------------------------------
END CZ_NETWORK_API_PUB;

/
