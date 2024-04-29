--------------------------------------------------------
--  DDL for Package IBY_RISKYINSTR_PKG_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_RISKYINSTR_PKG_WRAP" AUTHID CURRENT_USER as
/*$Header: ibyrkwrs.pls 115.4 2002/11/20 00:00:15 jleybovi ship $*/

  procedure add_riskyinstr(i_count  integer,
    i_riskyinstr_payeeid JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_instrtype JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_routing_num JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_account_num JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_creditcard_num JTF_VARCHAR2_TABLE_100,
    o_results_success out nocopy JTF_NUMBER_TABLE,
    o_results_errmsg out nocopy JTF_VARCHAR2_TABLE_100);

  procedure delete_riskyinstr(i_count  integer,
    i_riskyinstr_payeeid JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_instrtype JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_routing_num JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_account_num JTF_VARCHAR2_TABLE_100,
    i_riskyinstr_creditcard_num JTF_VARCHAR2_TABLE_100,
    o_results_success out nocopy JTF_NUMBER_TABLE,
    o_results_errmsg out nocopy JTF_VARCHAR2_TABLE_100);
end iby_riskyinstr_pkg_wrap;

 

/
