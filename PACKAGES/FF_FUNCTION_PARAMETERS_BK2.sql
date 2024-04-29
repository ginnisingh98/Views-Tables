--------------------------------------------------------
--  DDL for Package FF_FUNCTION_PARAMETERS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTION_PARAMETERS_BK2" AUTHID CURRENT_USER as
/* $Header: ffffpapi.pkh 120.1.12010000.2 2008/08/05 10:20:39 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_parameter_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_parameter_b
  (p_effective_date                in     date
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  ,p_class                         in     varchar2
  ,p_data_type                     in     varchar2
  ,p_name                          in     varchar2
  ,p_optional                      in     varchar2
  ,p_continuing_parameter          in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_parameter_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_parameter_a
  (p_effective_date                in     date
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  ,p_class                         in     varchar2
  ,p_data_type                     in     varchar2
  ,p_name                          in     varchar2
  ,p_optional                      in     varchar2
  ,p_continuing_parameter          in     varchar2
  );

--
end FF_FUNCTION_PARAMETERS_BK2;

/
