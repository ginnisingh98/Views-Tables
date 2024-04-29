--------------------------------------------------------
--  DDL for Package PAY_PWA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PWA_RKD" AUTHID CURRENT_USER as
/* $Header: pypwarhi.pkh 120.0 2005/05/29 08:06:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_account_id                     in number
 ,p_business_group_id_o            in number
 ,p_carrier_id_o                   in number
 ,p_location_id_o                  in number
 ,p_name_o                         in varchar2
 ,p_account_number_o               in varchar2
 ,p_comments_o                     in long
 ,p_object_version_number_o        in number
  );
--
end pay_pwa_rkd;

 

/
