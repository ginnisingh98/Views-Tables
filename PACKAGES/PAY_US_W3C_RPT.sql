--------------------------------------------------------
--  DDL for Package PAY_US_W3C_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_W3C_RPT" AUTHID CURRENT_USER as
/* $Header: pyusw3cr.pkh 120.0.12000000.1 2007/01/18 03:14:17 appldev noship $*/



PROCEDURE insert_w3c_dtls(errbuf                OUT nocopy     VARCHAR2,
                          retcode               OUT nocopy     NUMBER,
                          p_seq_num             IN      VARCHAR2) ;

end pay_us_w3c_rpt;

 

/
