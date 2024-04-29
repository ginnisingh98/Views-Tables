--------------------------------------------------------
--  DDL for Package PQH_FYI_NOTIFY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FYI_NOTIFY_BK3" AUTHID CURRENT_USER as
/* $Header: pqfynapi.pkh 120.0 2005/05/29 01:55:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_fyi_notify_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_fyi_notify_b
  (
   p_fyi_notified_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_fyi_notify_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_fyi_notify_a
  (
   p_fyi_notified_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_fyi_notify_bk3;

 

/
