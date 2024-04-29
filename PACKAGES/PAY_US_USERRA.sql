--------------------------------------------------------
--  DDL for Package PAY_US_USERRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_USERRA" AUTHID CURRENT_USER as
/* $Header: pyususer.pkh 120.1.12000000.1 2007/01/18 03:09:20 appldev noship $*/



PROCEDURE insert_userra_balances(errbuf out nocopy varchar2,
                                 retcode out nocopy number,
                                 p_year in varchar2,
                                 p_category in varchar2,
                                 p_balance  in varchar2,
                                 p_business_group_id in number) ;

end pay_us_userra;

 

/
