--------------------------------------------------------
--  DDL for Package PER_NAA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NAA_RKI" AUTHID CURRENT_USER as
/* $Header: penaarhi.pkh 120.0.12000000.1 2007/01/22 00:19:51 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_absence_action_id            in number
  ,p_absence_attendance_id        in number
  ,p_expected_date                in date
  ,p_description                  in varchar2
  ,p_actual_start_date            in date
  ,p_actual_end_date              in date
  ,p_holder                       in varchar2
  ,p_comments                     in varchar2
  ,p_document_file_name           in varchar2
  ,p_last_updated_by               in number
  ,p_object_version_number        in number
  ,p_enabled                      in varchar2
  );
end per_naa_rki;

 

/
