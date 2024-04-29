--------------------------------------------------------
--  DDL for Package PAY_PWR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PWR_RKD" AUTHID CURRENT_USER as
/* $Header: pypwrrhi.pkh 120.0 2005/05/29 08:09:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_rate_id                        in number
 ,p_business_group_id_o            in number
 ,p_account_id_o                   in number
 ,p_code_o                         in varchar2
 ,p_rate_o                         in number
 ,p_description_o                  in varchar2
 ,p_comments_o                     in long
 ,p_object_version_number_o        in number
  );
--
end pay_pwr_rkd;

 

/
