--------------------------------------------------------
--  DDL for Package PAY_US_SQWL_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_SQWL_ERROR" AUTHID CURRENT_USER as
/* $Header: pyusngpk.pkh 120.0.12000000.1 2007/01/18 02:42:47 appldev noship $*/



PROCEDURE insert_error(errbuf                OUT nocopy     VARCHAR2,
                       retcode               OUT nocopy     NUMBER,
                       p_payroll_action_id   IN      NUMBER,
                       p_qtrname            IN      VARCHAR2) ;

end pay_us_sqwl_error;

 

/
