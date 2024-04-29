--------------------------------------------------------
--  DDL for Package PAY_US_MULTI_MMRF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MULTI_MMRF" AUTHID CURRENT_USER AS
/* $Header: payusmultimmrf.pkh 120.0.12000000.1 2007/02/24 10:12:13 sackumar noship $ */



/*
File        : payusmultimmrf.pkh
Description : This package declares functions and procedures which are
                    used to return values for the W2 US Payroll reports.

Change List
---------------

Version Date      Author      Bug No.   Description of Change
-------+---------+-----------+---------+----------------------------------
115.24 06-feb-2006  djoshi               created

=============================================================================

*/

    TYPE er_sum_rec IS RECORD
       ( bal_name   varchar2(60)
       , value          varchar2(20)
       );
  TYPE er_sum_table IS TABLE OF
       er_sum_rec
  INDEX BY BINARY_INTEGER;




FUNCTION  get_w2_er_arch_bal(
                         w2_balance_name in varchar2,
                         w2_tax_unit_id  in varchar2,
                         w2_jurisdiction_code in varchar2,
                         w2_jurisdiction_level in varchar2,
                         w2_year varchar2,
                         a1 OUT NOCOPY varchar2,
                         a2 OUT NOCOPY varchar2,
                         a3 OUT NOCOPY varchar2,
                         a4 OUT NOCOPY varchar2,
                         a5 OUT NOCOPY varchar2,
                         a6 OUT NOCOPY varchar2,
                         a7 OUT NOCOPY varchar2,
                         a8 OUT NOCOPY varchar2,
                         a9 OUT NOCOPY varchar2,
                         a10 OUT NOCOPY varchar2,
                         a11 OUT NOCOPY varchar2,
                         a12 OUT NOCOPY varchar2,
                         a13 OUT NOCOPY varchar2,
                         a14 OUT NOCOPY varchar2,
                         a15 OUT NOCOPY varchar2,
                         a16 OUT NOCOPY varchar2,
                         a17 OUT NOCOPY varchar2,
                         a18 OUT NOCOPY varchar2,
                         a19 OUT NOCOPY varchar2,
                         a20 OUT NOCOPY varchar2,
                         a21 OUT NOCOPY varchar2,
                         a22 OUT NOCOPY varchar2,
                         a23 OUT NOCOPY varchar2,
                         a24 OUT NOCOPY varchar2,
                         a25 OUT NOCOPY varchar2,
                         a26 OUT NOCOPY varchar2,
                         a27 OUT NOCOPY varchar2,
                         a28 OUT NOCOPY varchar2,
                         a29 OUT NOCOPY varchar2,
                         a30 OUT NOCOPY varchar2,
                         a31 OUT NOCOPY varchar2,
                         a32 OUT NOCOPY varchar2,
                         a33 OUT NOCOPY varchar2,
                         a34 OUT NOCOPY varchar2,
                         a35 OUT NOCOPY varchar2,
                         a36 OUT NOCOPY varchar2,
                         a37 OUT NOCOPY varchar2,
                         a38 OUT NOCOPY varchar2,
                         a39 OUT NOCOPY varchar2,
                         a40 OUT NOCOPY varchar2,
                         a41 OUT NOCOPY varchar2,
                         a42 OUT NOCOPY varchar2,
                         a43 OUT NOCOPY varchar2,
                         a44 OUT NOCOPY varchar2,
                         a45 OUT NOCOPY varchar2,
                         a46 OUT NOCOPY varchar2,
                         a47 OUT NOCOPY varchar2
                         )

                          RETURN varchar2;
--         PRAGMA RESTRICT_REFERENCES(get_w2_er_arch_bal, WNDS);



end pay_us_multi_mmrf;

 

/
