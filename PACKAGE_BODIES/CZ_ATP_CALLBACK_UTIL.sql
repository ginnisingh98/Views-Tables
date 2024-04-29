--------------------------------------------------------
--  DDL for Package Body CZ_ATP_CALLBACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_ATP_CALLBACK_UTIL" AS
/* $Header: czatpcub.pls 120.1 2008/01/09 16:20:06 qmao ship $ */

  ITEM_KEY_DELIMITER CONSTANT VARCHAR2(1) := ':';
  COMP_CODE_DELIMITER CONSTANT VARCHAR2(1) := '-';

  -- Value used for parent_config_item_id when root is a BOM model (hack for iStore).
  NO_PARENT_VALUE CONSTANT INTEGER := -1;

------------------------------------------------------------------------------
  FUNCTION org_id_from_item_key(p_item_key IN VARCHAR2)
    RETURN NUMBER
  IS
    l_temp   VARCHAR2(100);
    l_result VARCHAR2(100);
  BEGIN
    IF (p_item_key IS NULL) THEN
      RETURN NULL;
    END IF;

    l_temp := substr(p_item_key, instr(p_item_key, ITEM_KEY_DELIMITER, -1, 2)+1);
    l_result := substr(l_temp, 1, instr(l_temp, ITEM_KEY_DELIMITER)-1);
    RETURN cz_utils.conv_num(l_result);
  END org_id_from_item_key;

------------------------------------------------------------------------------
  PROCEDURE delete_atp_recs (p_config_session_key IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE FROM cz_atp_requests WHERE configurator_session_key = p_config_session_key;
    COMMIT;
  END delete_atp_recs;

  PROCEDURE insert_atp_rec (p_config_session_key IN VARCHAR2,
                            p_seq_nbr IN NUMBER,
                            p_ps_node_id IN NUMBER,
                            p_item_key IN VARCHAR2,
                            p_quantity IN NUMBER,
                            p_uom_code IN VARCHAR2,
                            p_config_item_id IN NUMBER,
                            p_parent_config_item_id IN NUMBER,
                            p_ato_config_item_id IN NUMBER,
                            p_component_sequence_id IN NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_item_key_type NUMBER;
    l_item_id       NUMBER;
    l_org_id        NUMBER;
    l_component_sequence_id NUMBER := p_component_sequence_id;

  BEGIN
    IF p_item_key IS NULL THEN
      l_item_key_type := G_ITEM_KEY_PS_NODE;
    ELSE
      l_item_key_type := G_ITEM_KEY_BOM_NODE;
    END IF;

    IF (l_component_sequence_id IS NULL AND
        p_item_key IS NOT NULL) THEN
      l_item_id := inv_item_id_from_item_key(p_item_key);
      l_org_id := org_id_from_item_key(p_item_key);

      BEGIN
        SELECT bill_sequence_id INTO l_component_sequence_id
        FROM bom_bill_of_materials
        WHERE assembly_item_id = l_item_id
        AND organization_id = l_org_id AND alternate_bom_designator IS NULL;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20001, 'Error in retrieving component_sequence_id for ' ||
             'config item ' || p_config_item_id || ': no bill_sequence_id found for ' ||
             'inventory item ' || l_item_id || ' with organization_id ' || l_org_id);
      END;
    END IF;

    INSERT INTO CZ_ATP_REQUESTS (atp_request_id,
                                 configurator_session_key,
                                 seq_no,
                                 ps_node_id,
                                 item_key, item_key_type,
                                 quantity, uom_code,
                                 config_item_id, parent_config_item_id,
                                 ato_config_item_id,
                                 component_sequence_id)
        VALUES (cz_atp_requests_s.nextval, p_config_session_key, p_seq_nbr,
                p_ps_node_id, p_item_key, l_item_key_type, p_quantity, p_uom_code,
                p_config_item_id,
                decode(p_parent_config_item_id, NO_PARENT_VALUE, NULL,
                       p_parent_config_item_id),
                p_ato_config_item_id,
                l_component_sequence_id);

    COMMIT;
  END insert_atp_rec;


  PROCEDURE run_atp_callback(p_pkg_name IN VARCHAR2,
                             p_proc_name IN VARCHAR2,
                             p_config_session_key IN VARCHAR2,
                             p_warehouse_id IN NUMBER,
			     p_ship_to_org_id IN NUMBER,
			     p_customer_id IN NUMBER,
			     p_customer_site_id IN NUMBER,
			     p_requested_date IN DATE,
                             p_ship_to_group_date OUT NOCOPY DATE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    block_1 VARCHAR2(100);
    block_2 VARCHAR2(100);
    block_3 VARCHAR2(100);
    block_4 VARCHAR2(100);
    block_5 VARCHAR2(100);
    final_block VARCHAR2(500);
  BEGIN

    block_1 := 'begin ' || p_pkg_name || '.' || p_proc_name;
    block_2 := '(:configurator_session_key, :warehouse_id, :ship_to_org, ';
    block_3 := ':customer_id, :customer_site_id, :requested_date, ';
    block_4 := ':ship_to_group_date); ';
    block_5 := 'end;';
    final_block := block_1 || block_2 || block_3 || block_4 || block_5;

    EXECUTE IMMEDIATE final_block USING IN p_config_session_key,
      IN p_warehouse_id, IN p_ship_to_org_id, IN p_customer_id,
      IN p_customer_site_id, IN p_requested_date, OUT p_ship_to_group_date;

    COMMIT;

  END run_atp_callback;

  -- Returns inventory item id from item_key, which should have the
  -- form [component code]:[explosion type]:[org ID]:[top item id].
  -- Component code is a concatenation of inv item IDs with "-" in
  -- between each pair.  We're interested in the last ID in the
  -- component code.
  -- Returns null if item_id can't be found
  FUNCTION inv_item_id_from_item_key(p_item_key IN VARCHAR2)
    RETURN NUMBER IS

    l_item_id_str cz_atp_requests.item_key%TYPE;

  BEGIN

    IF p_item_key IS NULL THEN
      return NULL;
    END IF;

    SELECT
      substr(component_code_from_item_key(p_item_key),
             instr(decode(substr(p_item_key,1,3),'PRJ',null,'PRD',
                          substr(p_item_key,
                                 instr(p_item_key,ITEM_KEY_DELIMITER,-1,1)+1),
                          substr(p_item_key,1,instr(p_item_key,ITEM_KEY_DELIMITER)-1)),
                   COMP_CODE_DELIMITER,-1,1)+1) INTO l_item_id_str FROM dual;

    return cz_utils.conv_num(l_item_id_str);

  END inv_item_id_from_item_key;


  FUNCTION component_code_from_item_key(p_item_key IN VARCHAR2)
    RETURN VARCHAR2 IS

    l_comp_code_str bom_explosions.component_code%TYPE;

  BEGIN
    IF p_item_key IS NULL THEN
      return NULL;
    END IF;

    SELECT
      decode(substr(p_item_key,1,3),
                          'PRJ',null,
                          'PRD',
                          substr(p_item_key,
                                 instr(p_item_key,ITEM_KEY_DELIMITER,-1,1)+1),
                    substr(p_item_key,1,instr(p_item_key,ITEM_KEY_DELIMITER)-1))
    INTO l_comp_code_str FROM dual;

    return l_comp_code_str;
  END component_code_from_item_key;

  FUNCTION break_str_by_delim(p_input_str IN VARCHAR2,
                              p_delimiter IN VARCHAR2)
    RETURN char30_arr IS

    l_input_str VARCHAR2(2000) := p_input_str;
    l_return_arr char30_arr;
    l_token VARCHAR2(20);
    l_delim_pos NUMBER;
    l_index NUMBER := 1;

  BEGIN

    LOOP
      select instr(l_input_str,p_delimiter)
        into l_delim_pos from dual;

      IF l_delim_pos = 0 THEN
        l_token := l_input_str;
      ELSIF l_delim_pos IS NULL THEN
        return NULL;
      ELSE
        l_token := substr(l_input_str,1,l_delim_pos-1);
      END IF;

      IF l_index = 1 THEN
        l_return_arr := char30_arr(l_token);
      ELSE
        l_return_arr.extend(1);
        l_return_arr(l_index) := l_token;
      END IF;

      EXIT WHEN l_delim_pos = 0;
      l_input_str := substr(l_input_str, l_delim_pos+1,
                            length(l_input_str));
      l_index := l_index + 1;
    END LOOP;

    return l_return_arr;
  END break_str_by_delim;


  FUNCTION component_code_tokens(p_component_code IN VARCHAR2)
    RETURN char30_arr IS
  BEGIN
    return break_str_by_delim(p_component_code, COMP_CODE_DELIMITER);
  END component_code_tokens;


  FUNCTION item_key_tokens(p_item_key IN VARCHAR2)
    RETURN char30_arr IS
  BEGIN
    return break_str_by_delim(p_item_key, ITEM_KEY_DELIMITER);
  END item_key_tokens;


  FUNCTION validation_org_for_cfg_model(p_config_session_key IN VARCHAR2)
    RETURN NUMBER IS

    l_temp VARCHAR2(100);
    l_result VARCHAR2(100);
    l_item_key cz_atp_requests.item_key%TYPE;

  BEGIN
    begin
      select item_key into l_item_key from cz_atp_requests where
        configurator_session_key = p_config_session_key and seq_no = 1;
    exception
      when others then
        return NULL;
    end;

    return org_id_from_item_key(l_item_key);

  END validation_org_for_cfg_model;

--This function returns the config_item_id of the root BOM model in a configuration
--identified by the p_config_session_id parameter.

FUNCTION root_bom_config_item_id(p_config_session_key IN VARCHAR2) RETURN NUMBER IS

  TYPE typeItemKeyTable IS TABLE OF cz_atp_requests.item_key%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeItemIdTable  IS TABLE OF cz_atp_requests.config_item_id%TYPE INDEX BY BINARY_INTEGER;

  tabItemKey      typeItemKeyTable;
  tabConfigItemId typeItemIdTable;
  vComponentCode  cz_atp_requests.item_key%TYPE;

BEGIN

  --Read only the configuration lines corresponding to BOM items.

  SELECT item_key, config_item_id BULK COLLECT INTO tabItemKey, tabConfigItemId
    FROM cz_atp_requests
   WHERE configurator_session_key = p_config_session_key
     AND item_key_type = G_ITEM_KEY_BOM_NODE;

  FOR i IN 1..tabItemKey.COUNT LOOP

    vComponentCode := component_code_from_item_key(tabItemKey(i));

    IF(INSTR(vComponentCode, COMP_CODE_DELIMITER) = 0)THEN

      --For every line, we extract the component code and see if it contains the delimiter
      --symbol. If there is no delimiter, we assume the component code is just a single id
      --and so this is the root model. As soon as one such line found we exit.

      RETURN tabConfigItemId(i);
    END IF;
  END LOOP;

  --No root model found, return NULL.

  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN

    --Any error occured, return NULL.

    RETURN NULL;
END root_bom_config_item_id;

END cz_atp_callback_util;

/
