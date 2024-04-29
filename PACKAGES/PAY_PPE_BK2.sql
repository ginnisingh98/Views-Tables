--------------------------------------------------------
--  DDL for Package PAY_PPE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPE_BK2" AUTHID CURRENT_USER as
/* $Header: pyppeapi.pkh 120.1.12010000.1 2008/07/27 23:25:09 appldev ship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< update_process_event_b >------------------|
-- ---------------------------------------------------------------------
--
procedure update_process_event_b
 ( p_process_event_id             in     number
  ,p_object_version_number        in     number
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_change_type                  in     varchar2
  ,p_status                       in     varchar2
  ,p_description                  in     varchar2
  ,p_event_update_id              in     number
  ,p_org_process_event_group_id   in     number
  ,p_business_group_id            in     number
  ,p_surrogate_key                in     varchar2
  ,p_calculation_date             in     date
  ,p_retroactive_status           in     varchar2
  ,p_noted_value                  in     varchar2
  );
--
-- ----------------------------------------------------------------------
-- |---------------------< update_process_event_a >------------------|
-- ---------------------------------------------------------------------
--
procedure update_process_event_a
 ( p_process_event_id             in     number
  ,p_object_version_number        in     number
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_change_type                  in     varchar2
  ,p_status                       in     varchar2
  ,p_description                  in     varchar2
  ,p_event_update_id              in     number
  ,p_org_process_event_group_id   in     number
  ,p_business_group_id            in     number
  ,p_surrogate_key                in     varchar2
  ,p_calculation_date             in     date
  ,p_retroactive_status           in     varchar2
  ,p_noted_value                  in     varchar2
  );
--
end pay_ppe_bk2;

/
