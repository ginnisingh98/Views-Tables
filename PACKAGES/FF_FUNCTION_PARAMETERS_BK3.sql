--------------------------------------------------------
--  DDL for Package FF_FUNCTION_PARAMETERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTION_PARAMETERS_BK3" AUTHID CURRENT_USER as
/* $Header: ffffpapi.pkh 120.1.12010000.2 2008/08/05 10:20:39 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_parameter_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_parameter_b
  (p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_parameter_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_parameter_a
  (p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  );
--
--
end FF_FUNCTION_PARAMETERS_BK3;

/
