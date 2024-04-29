--------------------------------------------------------
--  DDL for Package BEN_EXT_SMART_TOTAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_SMART_TOTAL" AUTHID CURRENT_USER as
/* $Header: benxsttl.pkh 120.0 2005/05/28 09:47:50 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|           Copyright (c) 1997 Oracle Corporation              |
|              Redwood Shores, California, USA             |
|                   All rights reserved.                   |
+==============================================================================+
--
Name
        Benefit Extract Smart Totals
Purpose
        This package is for totals in the header/trailer
History
        Date      Version      Who                   What?
        11/16/98  115.0        YRathman/PDas         Created.
        12/09/98  115.1        PDas                  Modified Calc_Smart_Total
                                                     Procedure
        12/28/98  115.2        PDas                  Added get_value procedure
        02/08/99  115.3        PDas                  Moved function get_value to benxutil.pkh
        02/10/99  115.4        PDas                  Modified Calc_Smart_Total
                                                     Procedure
                                                     - added p_frmt_mask_cd paramater
        10/1/99   115.5        Thayden               Added multiple conditions.
        12/23/02  115.6        Lakrish               NOCOPY changes
        03/22/05  115.6        tjesumic              new parameter group_val_01,02 added for
                                                     sub grouping calcaultion for subheader
*/
--
--
g_package  varchar2(33) := ' ben_ext_smart_total';  -- Global package name
--
Procedure calc_smart_total(p_ext_rslt_id                   in number,
                           p_ttl_fnctn_cd                  in varchar2,
                           p_ttl_sum_ext_data_elmt_id      in number,
                           p_ttl_cond_ext_data_elmt_id     in number,
                           p_ext_data_elmt_id              in number,
                           p_frmt_mask_cd                  in varchar2,
                           p_ext_file_id                   in number,
                           p_business_group_id             in number,
                           p_group_val_01                  in varchar2 default null ,
                           p_group_val_02                  in varchar2 default null,
                           p_smart_total                   out nocopy varchar2
                           );
--
end ben_ext_smart_total;

 

/
