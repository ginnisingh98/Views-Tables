--------------------------------------------------------
--  DDL for Package HXC_SEEDDATA_BY_LEVEL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SEEDDATA_BY_LEVEL_BK1" AUTHID CURRENT_USER as
/* $Header: hxchsdapi.pkh 120.0 2005/05/29 05:40:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_seed_data_by_level_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_seed_data_by_level_b
  (p_object_id                     in   number
  ,p_object_type                   in   varchar2
  ,p_hxc_required                  in   varchar2
  ,p_owner_application_id          in   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_seed_data_by_level_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_seed_data_by_level_a
  (p_object_id                     in  number
  ,p_object_type                   in  varchar2
  ,p_hxc_required                  in  varchar2
  ,p_owner_application_id          in  number
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< update_seed_data_by_level_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_seed_data_by_level_b
  (p_object_id                     in  number
  ,p_object_type                   in  varchar2
  ,p_hxc_required                  in  varchar2
  ,p_owner_application_id          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_seed_data_by_level_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_seed_data_by_level_a
  (p_object_id                     in number
  ,p_object_type                   in varchar2
  ,p_hxc_required                  in varchar2
  ,p_owner_application_id          in number
  );


-- ----------------------------------------------------------------------------
-- |-------------------------< delete_seed_data_by_level_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_seed_data_by_level_b
  (p_object_id                     in number
  ,p_object_type                   in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_seed_data_by_level_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_seed_data_by_level_a
  (p_object_id                     in number
  ,p_object_type                   in varchar2
  );

--
end hxc_seeddata_by_level_bk1;

 

/
