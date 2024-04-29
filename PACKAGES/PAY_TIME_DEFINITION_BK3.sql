--------------------------------------------------------
--  DDL for Package PAY_TIME_DEFINITION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TIME_DEFINITION_BK3" AUTHID CURRENT_USER as
/* $Header: pytdfapi.pkh 120.2 2006/07/13 13:28:18 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_definition_b >-------- ------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_definition_b
  (p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_definition_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_definition_a
  (p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_object_version_number         in     number
  );
--
end PAY_TIME_DEFINITION_BK3;

 

/
