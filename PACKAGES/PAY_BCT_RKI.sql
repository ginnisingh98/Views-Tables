--------------------------------------------------------
--  DDL for Package PAY_BCT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BCT_RKI" AUTHID CURRENT_USER as
/* $Header: pybctrhi.pkh 120.0.12000000.1 2007/01/17 16:29:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_session_date                 in date
  ,p_batch_control_id             in number
  ,p_batch_id                     in number
  ,p_control_status               in varchar2
  ,p_control_total                in varchar2
  ,p_control_type                 in varchar2
  ,p_object_version_number        in number
  );
end pay_bct_rki;

 

/
