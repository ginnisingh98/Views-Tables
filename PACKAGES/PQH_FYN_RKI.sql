--------------------------------------------------------
--  DDL for Package PQH_FYN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FYN_RKI" AUTHID CURRENT_USER as
/* $Header: pqfynrhi.pkh 120.0 2005/05/29 01:55:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_fyi_notified_id                in number
 ,p_transaction_category_id        in number
 ,p_transaction_id                 in number
 ,p_notification_event_cd          in varchar2
 ,p_notified_type_cd               in varchar2
 ,p_notified_name                  in varchar2
 ,p_notification_date              in date
 ,p_status                         in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_fyn_rki;

 

/
