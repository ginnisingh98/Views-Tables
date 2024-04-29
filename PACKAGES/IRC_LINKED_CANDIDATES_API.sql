--------------------------------------------------------
--  DDL for Package IRC_LINKED_CANDIDATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LINKED_CANDIDATES_API" AUTHID CURRENT_USER as
/* $Header: irilcapi.pkh 120.0.12010000.1 2010/03/17 14:06:44 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_linked_candidate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- {End Of Comments}
--
procedure create_linked_candidate
  (p_validate                       in           boolean  default false
  ,p_duplicate_set_id               in           number
  ,p_party_id                       in           number
  ,p_status                         in           varchar2
  ,p_target_party_id                in           number   default null
  ,p_link_id                        out nocopy   number
  ,p_object_version_number          out nocopy   number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_linked_candidate >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--
-- {End Of Comments}
--
procedure update_linked_candidate
  (p_validate                       in           boolean  default false
  ,p_link_id                        in           number
  ,p_duplicate_set_id               in           number   default hr_api.g_number
  ,p_party_id                       in           number   default hr_api.g_number
  ,p_status                         in           varchar2 default hr_api.g_varchar2
  ,p_target_party_id                in           number   default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_linked_candidate >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--
-- {End Of Comments}
--
procedure delete_linked_candidate
  (p_validate                       in  boolean  default false
  ,p_link_id                        in  number
  ,p_object_version_number          in  number
  );
--
end IRC_LINKED_CANDIDATES_API;

/
