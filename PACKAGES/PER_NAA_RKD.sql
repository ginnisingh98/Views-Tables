--------------------------------------------------------
--  DDL for Package PER_NAA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NAA_RKD" AUTHID CURRENT_USER as
/* $Header: penaarhi.pkh 120.0.12000000.1 2007/01/22 00:19:51 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_absence_action_id            in number
  ,p_absence_attendance_id_o      in number
  ,p_expected_date_o              in date
  ,p_description_o                in varchar2
  ,p_actual_start_date_o          in date
  ,p_actual_end_date_o            in date
  ,p_holder_o                     in varchar2
  ,p_comments_o                   in varchar2
  ,p_document_file_name_o         in varchar2
  ,p_last_updated_by_o             in number
  ,p_object_version_number_o      in number
  ,p_enabled_o                    in varchar2
  );
--
end per_naa_rkd;

 

/
