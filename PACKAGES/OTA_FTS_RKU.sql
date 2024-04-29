--------------------------------------------------------
--  DDL for Package OTA_FTS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FTS_RKU" AUTHID CURRENT_USER as
/* $Header: otftsrhi.pkh 120.0 2005/06/24 07:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_forum_thread_id              in number
  ,p_forum_id                     in number
  ,p_business_group_id            in number
  ,p_subject                      in varchar2
  ,p_last_post_date               in date
  ,p_reply_count                  in number
  ,p_private_thread_flag          in varchar2
  ,p_object_version_number        in number
  ,p_forum_id_o                   in number
  ,p_business_group_id_o          in number
  ,p_subject_o                    in varchar2
  ,p_last_post_date_o             in date
  ,p_reply_count_o                in number
  ,p_private_thread_flag_o        in varchar2
  ,p_object_version_number_o      in number
  );
--
end ota_fts_rku;

 

/
