--------------------------------------------------------
--  DDL for Package PER_NAA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NAA_RKU" AUTHID CURRENT_USER as
/* $Header: penaarhi.pkh 120.0.12000000.1 2007/01/22 00:19:51 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
  ,p_absence_attendance_id_o      in number
  ,p_expected_date_o              in date
  ,p_description_o                in varchar2
  ,p_actual_start_date_o          in date
  ,p_actual_end_date_o            in date
  ,p_holder_o                     in varchar2
  ,p_comments_o                   in varchar2
  ,p_document_file_name_o           in varchar2
  ,p_last_updated_by_o             in number
  ,p_object_version_number_o      in number
  ,p_enabled_o                    in varchar2
  );
--
end per_naa_rku;

 

/
