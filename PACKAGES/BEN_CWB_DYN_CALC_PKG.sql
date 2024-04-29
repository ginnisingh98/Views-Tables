--------------------------------------------------------
--  DDL for Package BEN_CWB_DYN_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_DYN_CALC_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbdc.pkh 120.1.12010000.1 2008/07/29 12:06:37 appldev ship $ */
-- --------------------------------------------------------------------------
-- |--------------------< run_dynamic_calculations >------------------------|
-- --------------------------------------------------------------------------
procedure run_dynamic_calculations(p_group_per_in_ler_id in number
                                  ,p_group_pl_id in number
                                  ,p_lf_evt_ocrd_dt in date
                                  ,p_raise_error in boolean default false);

end BEN_CWB_DYN_CALC_PKG ;


/
