--------------------------------------------------------
--  DDL for Package GMF_AR_GET_WAREHOUSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_WAREHOUSES" AUTHID CURRENT_USER as
/* $Header: gmfwarhs.pls 115.0 99/07/16 04:26:49 porting shi $ */
    procedure AR_GET_WAREHOUSES (warehouse_id       in out number,
                                 warehouse_code     in out varchar2,
                                 name               out    varchar2,
                                 date_from          out    date,
                                 date_to            out    date,
                                 sob_id             out    number,
                                 coa_id             out    number,
                                 inv_enabled_flg    out    varchar2,
                                 int_ext_flag       out    varchar2,
                                 int_addr_line      out    varchar2,
                                 type               out    varchar2,
                                 master_orgid       out    number,
                                 attr_category      out    varchar2,
                                 att1               out    varchar2,
                                 att2               out    varchar2,
                                 att3               out    varchar2,
                                 att4               out    varchar2,
                                 att5               out    varchar2,
                                 att6               out    varchar2,
                                 att7               out    varchar2,
                                 att8               out    varchar2,
                                 att9               out    varchar2,
                                 att10              out    varchar2,
                                 att11              out    varchar2,
                                 att12              out    varchar2,
                                 att13              out    varchar2,
                                 att14              out    varchar2,
                                 att15              out    varchar2,
                                 created_by         out    number,
                                 creation_date      out    date,
                                 last_update_date   out    date,
                                 last_updated_by    out    number,
                                 row_to_fetch       in out number,
                                 error_status       out    number);
END GMF_AR_GET_WAREHOUSES;

 

/
