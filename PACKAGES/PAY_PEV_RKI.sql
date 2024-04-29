--------------------------------------------------------
--  DDL for Package PAY_PEV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PEV_RKI" AUTHID CURRENT_USER as
/* $Header: pypperhi.pkh 120.1.12010000.1 2008/07/27 23:25:21 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_process_event_id             in number
  ,p_assignment_id                in number
  ,p_effective_date               in date
  ,p_change_type                  in varchar2
  ,p_status                       in varchar2
  ,p_description                  in varchar2
  ,p_event_update_id              in number
  ,p_business_group_id            in number
  ,p_org_process_event_group_id   in number
  ,p_surrogate_key                in varchar2
  ,p_object_version_number        in number
  ,p_calculation_date             in date
  ,p_retroactive_status           in varchar2
  ,p_noted_value                  in varchar2
  );
end pay_pev_rki;

/
