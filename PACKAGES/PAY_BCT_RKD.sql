--------------------------------------------------------
--  DDL for Package PAY_BCT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BCT_RKD" AUTHID CURRENT_USER as
/* $Header: pybctrhi.pkh 120.0.12000000.1 2007/01/17 16:29:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_batch_control_id             in number
  ,p_batch_id_o                   in number
  ,p_control_status_o             in varchar2
  ,p_control_total_o              in varchar2
  ,p_control_type_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_bct_rkd;

 

/
