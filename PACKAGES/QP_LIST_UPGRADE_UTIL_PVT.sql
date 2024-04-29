--------------------------------------------------------
--  DDL for Package QP_LIST_UPGRADE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIST_UPGRADE_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: QPXVUPLS.pls 120.0 2005/06/02 00:13:37 appldev noship $ */

Type pricing_attr_rec_type is RECORD
(
  l_pricing_context varchar2(30) := NULL,
  l_pricing_attr varchar2(30) := NULL,
  l_pricing_attr_value_from varchar2(240) := NULL,
  l_pricing_attr_value_to varchar2(240) := NULL);

Type pricing_attr_tbl_type is table of pricing_attr_rec_type
  INDEX BY BINARY_INTEGER;

Type prc_list_map_rec_type is RECORD
(
  old_price_list_id number,
  old_price_list_line_id number,
  new_list_header_id number,
  new_list_line_id number,
  secondary_price_list_id number,
  db_flag varchar2(1) := 'N'
);

Type prc_list_map_tbl_type is table of prc_list_map_rec_type
  INDEX BY BINARY_INTEGER;

procedure upgrade_flex_structures;

procedure  create_parallel_lines
       (  l_workers IN number := 5,
          p_batchsize in number := 5000);

PROCEDURE  CREATE_PARALLEL_SLABS
       (  L_WORKERS IN NUMBER := 5);

procedure create_price_list(p_batchsize in number := 5000,
                            p_worker in number := 1);

procedure create_list_lines(p_batchsize in number := 5000,
                            l_worker in number := 1);


end qp_list_upgrade_util_pvt;

 

/
