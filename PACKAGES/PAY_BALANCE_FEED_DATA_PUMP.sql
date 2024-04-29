--------------------------------------------------------
--  DDL for Package PAY_BALANCE_FEED_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_FEED_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: pypbfdpm.pkh 115.0 2003/03/27 13:03:40 scchakra noship $ */
--
Function get_balance_feed_id
(
   p_balance_feed_user_key in varchar2
) return number;
--
Function get_balance_type_id
  (p_balance_name          in varchar2
  ,p_business_group_id     in number
  ,p_language_code         in varchar2
  )
  return number;
--
Function get_balance_feed_ovn
  (p_balance_feed_user_key in varchar2
  ,p_effective_date        in date
  )
  return number;
--
END pay_balance_feed_data_pump;

 

/
