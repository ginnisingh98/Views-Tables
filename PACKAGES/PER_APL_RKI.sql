--------------------------------------------------------
--  DDL for Package PER_APL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APL_RKI" AUTHID CURRENT_USER as
/* $Header: peaplrhi.pkh 120.1 2005/10/25 00:30:44 risgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_application_id                 in number
  ,p_business_group_id              in number
  ,p_person_id                      in number
  ,p_date_received                  in date
  ,p_comments                       in varchar2
  ,p_current_employer               in varchar2
  ,p_projected_hire_date            in date
  ,p_successful_flag                in varchar2
  ,p_termination_reason             in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  ,p_appl_attribute_category        in varchar2
  ,p_appl_attribute1                in varchar2
  ,p_appl_attribute2                in varchar2
  ,p_appl_attribute3                in varchar2
  ,p_appl_attribute4                in varchar2
  ,p_appl_attribute5                in varchar2
  ,p_appl_attribute6                in varchar2
  ,p_appl_attribute7                in varchar2
  ,p_appl_attribute8                in varchar2
  ,p_appl_attribute9                in varchar2
  ,p_appl_attribute10               in varchar2
  ,p_appl_attribute11               in varchar2
  ,p_appl_attribute12               in varchar2
  ,p_appl_attribute13               in varchar2
  ,p_appl_attribute14               in varchar2
  ,p_appl_attribute15               in varchar2
  ,p_appl_attribute16               in varchar2
  ,p_appl_attribute17               in varchar2
  ,p_appl_attribute18               in varchar2
  ,p_appl_attribute19               in varchar2
  ,p_appl_attribute20               in varchar2
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
end per_apl_rki;

 

/
