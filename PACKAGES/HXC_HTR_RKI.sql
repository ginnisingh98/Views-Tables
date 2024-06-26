--------------------------------------------------------
--  DDL for Package HXC_HTR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTR_RKI" AUTHID CURRENT_USER as
/* $Header: hxchtrrhi.pkh 120.0.12010000.1 2008/07/28 11:13:32 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date                 in date
  ,p_time_recipient_id              in number
  ,p_name                           in varchar2
  ,p_application_id                 in number
  ,p_object_version_number          in number
  ,p_appl_retrieval_function        in varchar2
  ,p_appl_update_process            in varchar2
  ,p_appl_validation_process        in varchar2
  ,p_appl_period_function           in varchar2
  ,p_appl_dyn_template_process      in varchar2
  ,p_extension_function1            in varchar2
  ,p_extension_function2            in varchar2
  );
end hxc_htr_rki;

/
