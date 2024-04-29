--------------------------------------------------------
--  DDL for Package PQH_FYI_NOTIFY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FYI_NOTIFY_BK1" AUTHID CURRENT_USER as
/* $Header: pqfynapi.pkh 120.0 2005/05/29 01:55:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_fyi_notify_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_fyi_notify_b
  (
   p_transaction_category_id        in  number
  ,p_transaction_id                 in  number
  ,p_notification_event_cd          in  varchar2
  ,p_notified_type_cd               in  varchar2
  ,p_notified_name                  in  varchar2
  ,p_notification_date              in  date
  ,p_status                         in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_fyi_notify_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_fyi_notify_a
  (
   p_fyi_notified_id                in  number
  ,p_transaction_category_id        in  number
  ,p_transaction_id                 in  number
  ,p_notification_event_cd          in  varchar2
  ,p_notified_type_cd               in  varchar2
  ,p_notified_name                  in  varchar2
  ,p_notification_date              in  date
  ,p_status                         in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_fyi_notify_bk1;

 

/
