--------------------------------------------------------
--  DDL for Package GHR_EVH_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_EVH_RKD" AUTHID CURRENT_USER as
/* $Header: ghevhrhi.pkh 120.0.12010000.3 2009/05/26 11:55:28 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_event_history_id               in number
 ,p_event_id_o                     in number
 ,p_table_name_o                   in varchar2
 ,p_record_id_o                    in number
 ,p_start_date_o                   in date
 ,p_end_date_o                     in date
 ,p_comments_o                     in varchar2
 ,p_object_version_number_o        in number
  );
--
end ghr_evh_rkd;

/
