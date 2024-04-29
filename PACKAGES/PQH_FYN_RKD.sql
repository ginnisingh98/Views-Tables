--------------------------------------------------------
--  DDL for Package PQH_FYN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FYN_RKD" AUTHID CURRENT_USER as
/* $Header: pqfynrhi.pkh 120.0 2005/05/29 01:55:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_fyi_notified_id                in number
 ,p_transaction_category_id_o      in number
 ,p_transaction_id_o               in number
 ,p_notification_event_cd_o        in varchar2
 ,p_notified_type_cd_o             in varchar2
 ,p_notified_name_o                in varchar2
 ,p_notification_date_o            in date
 ,p_status_o                       in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_fyn_rkd;

 

/
