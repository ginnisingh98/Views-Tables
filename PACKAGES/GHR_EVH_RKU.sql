--------------------------------------------------------
--  DDL for Package GHR_EVH_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_EVH_RKU" AUTHID CURRENT_USER as
/* $Header: ghevhrhi.pkh 120.0.12010000.3 2009/05/26 11:55:28 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_event_history_id               in number
 ,p_event_id                       in number
 ,p_table_name                     in varchar2
 ,p_record_id                      in number
 ,p_start_date                     in date
 ,p_end_date                       in date
 ,p_comments                       in varchar2
 ,p_object_version_number          in number
 ,p_event_id_o                     in number
 ,p_table_name_o                   in varchar2
 ,p_record_id_o                    in number
 ,p_start_date_o                   in date
 ,p_end_date_o                     in date
 ,p_comments_o                     in varchar2
 ,p_object_version_number_o        in number
  );
--
end ghr_evh_rku;

/
