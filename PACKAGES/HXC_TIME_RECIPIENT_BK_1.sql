--------------------------------------------------------
--  DDL for Package HXC_TIME_RECIPIENT_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_RECIPIENT_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchtrapi.pkh 120.1 2005/10/02 02:06:55 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_time_recipient_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_recipient_b
  (p_time_recipient_id              in     NUMBER
  ,p_application_id                 in     NUMBER
  ,p_object_version_number          in     NUMBER
  ,p_name                           in     VARCHAR2
  ,p_appl_retrieval_function        in     VARCHAR2
  ,p_appl_update_process            in     VARCHAR2
  ,p_appl_validation_process        in     VARCHAR2
  ,p_appl_period_function           in     VARCHAR2
  ,p_appl_dyn_template_process      in     VARCHAR2
  ,p_extension_function1            in     VARCHAR2
  ,p_extension_function2            in     VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_time_recipient_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_recipient_a
  (p_time_recipient_id              in     NUMBER
  ,p_application_id                 in     NUMBER
  ,p_object_version_number          in     NUMBER
  ,p_name                           in     VARCHAR2
  ,p_appl_retrieval_function        in     VARCHAR2
  ,p_appl_update_process            in     VARCHAR2
  ,p_appl_validation_process        in     VARCHAR2
  ,p_appl_period_function           in     VARCHAR2
  ,p_appl_dyn_template_process      in     VARCHAR2
  ,p_extension_function1            in     VARCHAR2
  ,p_extension_function2            in     VARCHAR2
  );
--
end hxc_time_recipient_bk_1;

 

/
