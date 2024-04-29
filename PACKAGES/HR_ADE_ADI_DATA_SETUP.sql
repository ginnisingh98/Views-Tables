--------------------------------------------------------
--  DDL for Package HR_ADE_ADI_DATA_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ADE_ADI_DATA_SETUP" AUTHID CURRENT_USER AS
/* $Header: peadeset.pkh 115.3 2003/05/21 13:03:02 smcmilla noship $ */
--
-- ---------------------------------------------------------------------------
-- |------------------------< create_metadata_data >-------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Creates the metadata required for Web ADI.
--   p_metadata_type indicates the type of metadata to create - DOWNLOAD,
--   UPDATE or CREATE. Download types do not have to supply api details.
--
-- ---------------------------------------------------------------------------
PROCEDURE  create_metadata(
    p_metadata_type        IN    varchar2
   ,p_application_id       IN    number
   ,p_integrator_user_name IN    varchar2
   ,p_view_name            IN    varchar2 default null
   ,p_form_name            IN    varchar2 default null
   ,p_api_package_name     IN    varchar2 default null
   ,p_api_procedure_name   IN    varchar2 default null
   ,p_interface_user_name  IN    varchar2 default null
   ,p_interface_param_name IN    varchar2 default null
   ,p_api_type             IN    varchar2 default null
   ,p_api_return_type      IN    varchar2 default null
   );
--
-- ---------------------------------------------------------------------------
-- |------------------------< create_standalone_query >----------------------|
-- ---------------------------------------------------------------------------
PROCEDURE create_standalone_query
  (p_application_id    in number
  ,p_intg_user_name    in varchar2
  ,p_sql               in varchar2
  ,p_param1_name       in varchar2 default NULL
  ,p_param1_type       in varchar2 default NULL
  ,p_param1_prompt     in varchar2 default NULL
  ,p_param2_name       in varchar2 default NULL
  ,p_param2_type       in varchar2 default NULL
  ,p_param2_prompt     in varchar2 default NULL
  ,p_param3_name       in varchar2 default NULL
  ,p_param3_type       in varchar2 default NULL
  ,p_param3_prompt     in varchar2 default NULL
  ,p_param4_name       in varchar2 default NULL
  ,p_param4_type       in varchar2 default NULL
  ,p_param4_prompt     in varchar2 default NULL
  ,p_param5_name       in varchar2 default NULL
  ,p_param5_type       in varchar2 default NULL
  ,p_param5_prompt     in varchar2 default NULL
  );
--
-- ---------------------------------------------------------------------------
-- |----------------------< maintain_standalone_query >----------------------|
-- ---------------------------------------------------------------------------
PROCEDURE maintain_standalone_query
  (p_application_id    in number
  ,p_intg_user_name    in varchar2
  ,p_sql               in varchar2 default null
  ,p_param1_name       in varchar2 default null
  ,p_param1_type       in varchar2 default null
  ,p_param1_prompt     in varchar2 default null
  ,p_param2_name       in varchar2 default null
  ,p_param2_type       in varchar2 default null
  ,p_param2_prompt     in varchar2 default null
  ,p_param3_name       in varchar2 default null
  ,p_param3_type       in varchar2 default null
  ,p_param3_prompt     in varchar2 default null
  ,p_param4_name       in varchar2 default null
  ,p_param4_type       in varchar2 default null
  ,p_param4_prompt     in varchar2 default null
  ,p_param5_name       in varchar2 default null
  ,p_param5_type       in varchar2 default null
  ,p_param5_prompt     in varchar2 default null
  );
--
END hr_ade_adi_data_setup;

 

/
