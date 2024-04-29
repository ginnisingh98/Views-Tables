--------------------------------------------------------
--  DDL for Package CZ_PRC_CALLBACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PRC_CALLBACK_UTIL" AUTHID CURRENT_USER AS
/* $Header: czprcbus.pls 115.15 2004/03/02 15:42:22 askhacha ship $ */

  -- Global constants representing cz_pricing_structures.item_key_type values
  G_ITEM_KEY_BOM_NODE CONSTANT NUMBER := 1;
  G_ITEM_KEY_PS_NODE CONSTANT NUMBER := 2;

  -- Global constants representing available pricing types
  G_PRC_TYPE_LIST CONSTANT VARCHAR2(10) := 'LIST';
  G_PRC_TYPE_SELLING CONSTANT VARCHAR2(10) := 'SELLING';
  G_PRC_TYPE_BOTH CONSTANT VARCHAR2(10) := 'BOTH';

  PROCEDURE insert_pricing_table (p_pricing_tbl IN system.cz_price_tbl_type);

  PROCEDURE insert_pricing_rec (p_config_session_key IN VARCHAR2,
                                p_seq_nbr IN NUMBER,
                                p_ps_node_id IN NUMBER,
                                p_item_key IN VARCHAR2,
                                p_quantity IN NUMBER,
                                p_uom_code IN VARCHAR2,
                                p_config_item_id IN NUMBER,
                                p_parent_config_item_id IN NUMBER);

  PROCEDURE delete_pricing_recs (p_config_session_key IN VARCHAR2);

  PROCEDURE run_pricing_callback(p_pkg_name IN VARCHAR2,
                                 p_proc_name IN VARCHAR2,
                                 p_config_session_key IN VARCHAR2,
                                 p_price_type IN VARCHAR2,
                                 p_total_price OUT NOCOPY NUMBER);

  PROCEDURE run_mls_pricing_callback(p_pkg_name IN VARCHAR2,
				     p_proc_name IN VARCHAR2,
				     p_config_session_key IN VARCHAR2,
				     p_price_type IN VARCHAR2,
				     p_total_price OUT NOCOPY NUMBER,
				     p_currency_code OUT NOCOPY VARCHAR2);

  FUNCTION root_bom_config_item_id(p_config_session_key IN VARCHAR2)
  RETURN NUMBER;

END cz_prc_callback_util;

 

/
