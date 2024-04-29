--------------------------------------------------------
--  DDL for Package BEN_BCD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BCD_RKD" AUTHID CURRENT_USER as
/* $Header: bebcdrhi.pkh 120.0.12010000.1 2008/07/29 10:53:24 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cwb_matrix_dtl_id            in number
  ,p_cwb_matrix_id_o              in number
  ,p_row_crit_val_o               in varchar2
  ,p_col_crit_val_o               in varchar2
  ,p_pct_emp_cndr_o               in number
  ,p_pct_val_o                    in number
  ,p_emp_amt_o                    in number
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ben_bcd_rkd;

/
