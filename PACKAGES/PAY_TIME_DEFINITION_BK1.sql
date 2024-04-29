--------------------------------------------------------
--  DDL for Package PAY_TIME_DEFINITION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TIME_DEFINITION_BK1" AUTHID CURRENT_USER as
/* $Header: pytdfapi.pkh 120.2 2006/07/13 13:28:18 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_time_definition_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_definition_b
  (p_effective_date                in     date
  ,p_short_name                    in     varchar2
  ,p_definition_name               in     varchar2
  ,p_period_type                   in     varchar2
  ,p_period_unit                   in     varchar2
  ,p_day_adjustment                in     varchar2
  ,p_dynamic_code                  in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_definition_type               in     varchar2
  ,p_number_of_years               in     number
  ,p_start_date                    in     date
  ,p_period_time_definition_id     in     number
  ,p_creator_id                    in     number
  ,p_creator_type                  in     varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_time_definition_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_definition_a
  (p_effective_date                in     date
  ,p_short_name                    in     varchar2
  ,p_definition_name               in     varchar2
  ,p_period_type                   in     varchar2
  ,p_period_unit                   in     varchar2
  ,p_day_adjustment                in     varchar2
  ,p_dynamic_code                  in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_definition_type               in     varchar2
  ,p_number_of_years               in     number
  ,p_start_date                    in     date
  ,p_period_time_definition_id     in     number
  ,p_creator_id                    in     number
  ,p_creator_type                  in     varchar2
  ,p_time_definition_id            in     number
  ,p_object_version_number         in     number
  );
--
end PAY_TIME_DEFINITION_BK1;

 

/
