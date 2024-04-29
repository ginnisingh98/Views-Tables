--------------------------------------------------------
--  DDL for Package FF_FUNCTIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTIONS_BK2" AUTHID CURRENT_USER as
/* $Header: ffffnapi.pkh 120.1.12010000.2 2008/08/05 10:20:27 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_function_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_function_b
  (p_effective_date               in     date
  ,p_function_id                  in     number
  ,p_object_version_number        in     number
  ,p_name                         in     varchar2
  ,p_class                        in     varchar2
  ,p_alias_name                   in     varchar2
  ,p_data_type                    in     varchar2
  ,p_definition                   in     varchar2
  ,p_description                  in     varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_function_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_function_a
  (p_effective_date               in     date
  ,p_function_id                  in     number
  ,p_object_version_number        in     number
  ,p_name                         in     varchar2
  ,p_class                        in     varchar2
  ,p_alias_name                   in     varchar2
  ,p_data_type                    in     varchar2
  ,p_definition                   in     varchar2
  ,p_description                  in     varchar2
  );
--
end FF_FUNCTIONS_BK2;

/
