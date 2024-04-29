--------------------------------------------------------
--  DDL for Package FV_CCR_BPN_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_CCR_BPN_LOAD_PKG" AUTHID CURRENT_USER as
/* $Header: FVBPNLDS.pls 120.1.12010000.3 2009/11/12 15:59:17 sthota noship $*/

type new_data is table of varchar2(2000);
ccr_data new_data;
procedure insert_ccr_codes(clob_buff in clob,
                           field_count_low in number,
                           field_count_high in number,
                           delimiter in varchar2,
                           proc_count in number,
                           from_index in number,
                           duns_num in varchar2,
                           retpos out NOCOPY number);
procedure insert_ccr_data(clob_buff in clob,
                          field_count_low in number,
                          field_count_high in number,
                          delimiter in varchar2,
                          proc_count in number,
                          from_index in number,
                          ccr_data in out NOCOPY new_data,
                          retpos out NOCOPY number
                          );
procedure main;

procedure delete_ccr_codes(p_duns in varchar2);
procedure delete_ccr_flags(p_duns in varchar2);

end fv_ccr_bpn_load_pkg;


/
