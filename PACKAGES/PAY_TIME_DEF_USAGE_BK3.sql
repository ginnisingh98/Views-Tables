--------------------------------------------------------
--  DDL for Package PAY_TIME_DEF_USAGE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TIME_DEF_USAGE_BK3" AUTHID CURRENT_USER as
/* $Header: pytduapi.pkh 120.2 2006/07/13 13:34:18 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_definition_b >-------- ------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_def_Usage_b
  (p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_Usage_type                    in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_definition_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_def_Usage_a
  (p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_Usage_type                    in     varchar2
  ,p_object_version_number         in     number
  );
--
end PAY_TIME_DEF_Usage_BK3;

 

/
