--------------------------------------------------------
--  DDL for Package CZ_ATP_CALLBACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_ATP_CALLBACK_UTIL" AUTHID CURRENT_USER AS
/* $Header: czatpcus.pls 115.10 2003/09/22 21:48:58 qmao ship $ */

  -- Global constants representing cz_atp_requests.item_key_type values
  G_ITEM_KEY_BOM_NODE CONSTANT NUMBER := 1;
  G_ITEM_KEY_PS_NODE CONSTANT NUMBER := 2;

  TYPE char30_arr IS TABLE OF VARCHAR2(30);

  PROCEDURE delete_atp_recs (p_config_session_key IN VARCHAR2);

  PROCEDURE insert_atp_rec (p_config_session_key IN VARCHAR2,
                            p_seq_nbr IN NUMBER,
                            p_ps_node_id IN NUMBER,
                            p_item_key IN VARCHAR2,
                            p_quantity IN NUMBER,
                            p_uom_code IN VARCHAR2,
                            p_config_item_id IN NUMBER,
                            p_parent_config_item_id IN NUMBER,
                            p_ato_config_item_id IN NUMBER,
                            p_component_sequence_id IN NUMBER);

  PROCEDURE run_atp_callback(p_pkg_name IN VARCHAR2,
                             p_proc_name IN VARCHAR2,
                             p_config_session_key IN VARCHAR2,
                             p_warehouse_id IN NUMBER,
			     p_ship_to_org_id IN NUMBER,
			     p_customer_id IN NUMBER,
			     p_customer_site_id IN NUMBER,
			     p_requested_date IN DATE,
                             p_ship_to_group_date OUT NOCOPY DATE);

  FUNCTION inv_item_id_from_item_key(p_item_key IN VARCHAR2)
  RETURN NUMBER;

  FUNCTION component_code_from_item_key(p_item_key IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION component_code_tokens(p_component_code IN VARCHAR2)
  RETURN char30_arr;

  FUNCTION item_key_tokens(p_item_key IN VARCHAR2)
  RETURN char30_arr;

  FUNCTION validation_org_for_cfg_model(p_config_session_key IN VARCHAR2)
  RETURN NUMBER;

  FUNCTION root_bom_config_item_id(p_config_session_key IN VARCHAR2)
  RETURN NUMBER;

END cz_atp_callback_util;

 

/
