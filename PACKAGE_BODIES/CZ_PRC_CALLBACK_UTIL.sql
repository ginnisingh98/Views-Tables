--------------------------------------------------------
--  DDL for Package Body CZ_PRC_CALLBACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PRC_CALLBACK_UTIL" AS
/* $Header: czprcbub.pls 115.16 2004/03/02 15:42:31 askhacha ship $ */

  COMP_CODE_DELIMITER CONSTANT VARCHAR2(1) := '-';

  -- Value used for parent_config_item_id when root is a BOM model (hack for iStore).
  NO_PARENT_VALUE CONSTANT INTEGER := -1;

  PROCEDURE insert_pricing_table (p_pricing_tbl IN system.cz_price_tbl_type)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    FOR i IN 1..p_pricing_tbl.COUNT LOOP
      INSERT INTO CZ_PRICING_STRUCTURES (configurator_session_key,
                                         seq_nbr,
                                         ps_node_id,
                                         item_key,
                                         item_key_type,
             	                         quantity,
                                         uom_code,
                                         config_item_id,
                                         parent_config_item_id)
      VALUES (p_pricing_tbl(i).config_session_key,
              p_pricing_tbl(i).seq_nbr,
              p_pricing_tbl(i).ps_node_id,
	      nvl(p_pricing_tbl(i).item_key, to_char(p_pricing_tbl(i).ps_node_id)),
              decode(p_pricing_tbl(i).item_key, NULL, G_ITEM_KEY_PS_NODE,
                     G_ITEM_KEY_BOM_NODE),
	      p_pricing_tbl(i).quantity,
              p_pricing_tbl(i).uom_code,
              p_pricing_tbl(i).config_item_id,
              decode(p_pricing_tbl(i).parent_config_item_id, NO_PARENT_VALUE, NULL,
                     p_pricing_tbl(i).parent_config_item_id));
    END LOOP;
    COMMIT;
  END insert_pricing_table;

  PROCEDURE insert_pricing_rec (p_config_session_key IN VARCHAR2,
                                p_seq_nbr IN NUMBER,
                                p_ps_node_id IN NUMBER,
                                p_item_key IN VARCHAR2,
                                p_quantity IN NUMBER,
                                p_uom_code IN VARCHAR2,
                                p_config_item_id IN NUMBER,
                                p_parent_config_item_id IN NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_item_key_type NUMBER;
    l_item_key cz_pricing_structures.item_key%TYPE;

  BEGIN

    IF p_item_key IS NULL THEN
      l_item_key_type := G_ITEM_KEY_PS_NODE;
      l_item_key := TO_CHAR(p_ps_node_id);
    ELSE
      l_item_key_type := G_ITEM_KEY_BOM_NODE;
      l_item_key := p_item_key;
    END IF;

    INSERT INTO cz_pricing_structures (configurator_session_key,
                                       seq_nbr,
    				       ps_node_id, item_key,
    				       item_key_type, quantity,
    				       uom_code, config_item_id,
                                       parent_config_item_id)
      VALUES (p_config_session_key,
              p_seq_nbr,
              p_ps_node_id, l_item_key,
              l_item_key_type, p_quantity, p_uom_code, p_config_item_id,
              decode(p_parent_config_item_id, NO_PARENT_VALUE, NULL,
                     p_parent_config_item_id));
    COMMIT;
  END insert_pricing_rec;

  PROCEDURE delete_pricing_recs (p_config_session_key IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE FROM CZ_PRICING_STRUCTURES
    WHERE configurator_session_key = p_config_session_key;
    COMMIT;
  END delete_pricing_recs;


  PROCEDURE run_pricing_callback(p_pkg_name IN VARCHAR2,
                                 p_proc_name IN VARCHAR2,
                                 p_config_session_key IN VARCHAR2,
                                 p_price_type IN VARCHAR2,
                                 p_total_price OUT NOCOPY NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    block_1 VARCHAR2(100);
    block_2 VARCHAR2(100);
    block_3 VARCHAR2(100);
    final_block VARCHAR2(300);
  BEGIN

    block_1 := 'begin ' || p_pkg_name || '.' || p_proc_name;
    block_2 := '(:configurator_session_key, :price_type, :config_total_price); ';
    block_3 := 'end;';
    final_block := block_1 || block_2 || block_3;

    EXECUTE IMMEDIATE final_block USING IN p_config_session_key, IN p_price_type,
      OUT p_total_price;

    COMMIT;

  END run_pricing_callback;

  PROCEDURE run_mls_pricing_callback(p_pkg_name IN VARCHAR2,
				     p_proc_name IN VARCHAR2,
				     p_config_session_key IN VARCHAR2,
				     p_price_type IN VARCHAR2,
				     p_total_price OUT NOCOPY NUMBER,
				     p_currency_code OUT NOCOPY VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    block_1 VARCHAR2(100);
    block_2 VARCHAR2(100);
    block_3 VARCHAR2(100);
    block_4 VARCHAR2(100);
    final_block VARCHAR2(400);
  BEGIN

    block_1 := 'begin ' || p_pkg_name || '.' || p_proc_name;
    block_2 := '(:configurator_session_key, :price_type, :config_total_price, ';
    block_3 := ':currency_code); ';
    block_4 := 'end;';
    final_block := block_1 || block_2 || block_3 || block_4;

    EXECUTE IMMEDIATE final_block USING IN p_config_session_key, IN p_price_type,
      OUT p_total_price, OUT p_currency_code;

    COMMIT;

  END run_mls_pricing_callback;

--This function returns the config_item_id of the root BOM model in a configuration
--identified by the p_config_session_id parameter.

FUNCTION root_bom_config_item_id(p_config_session_key IN VARCHAR2) RETURN NUMBER IS

  TYPE typeItemKeyTable IS TABLE OF cz_pricing_structures.item_key%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeItemIdTable  IS TABLE OF cz_pricing_structures.config_item_id%TYPE INDEX BY BINARY_INTEGER;

  tabItemKey      typeItemKeyTable;
  tabConfigItemId typeItemIdTable;
  vComponentCode  cz_pricing_structures.item_key%TYPE;

BEGIN

  --Read only the configuration lines corresponding to BOM items.

  SELECT item_key, config_item_id BULK COLLECT INTO tabItemKey, tabConfigItemId
    FROM cz_pricing_structures
   WHERE configurator_session_key = p_config_session_key
     AND item_key_type = G_ITEM_KEY_BOM_NODE;

  FOR i IN 1..tabItemKey.COUNT LOOP

    vComponentCode := cz_atp_callback_util.component_code_from_item_key(tabItemKey(i));

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

END cz_prc_callback_util;

/
