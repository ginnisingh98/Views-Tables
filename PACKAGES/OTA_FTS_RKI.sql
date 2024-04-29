--------------------------------------------------------
--  DDL for Package OTA_FTS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FTS_RKI" AUTHID CURRENT_USER as
/* $Header: otftsrhi.pkh 120.0 2005/06/24 07:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_forum_thread_id              in number
  ,p_forum_id                     in number
  ,p_business_group_id            in number
  ,p_subject                      in varchar2
  ,p_last_post_date               in date
  ,p_reply_count                  in number
  ,p_private_thread_flag          in varchar2
  ,p_object_version_number        in number
  );
end ota_fts_rki;

 

/
