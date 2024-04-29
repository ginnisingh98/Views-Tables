--------------------------------------------------------
--  DDL for Package CE_BANKACCT_BA_REPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BANKACCT_BA_REPORT_UTIL" AUTHID CURRENT_USER AS
/* $Header: cexmlb1s.pls 120.4 2006/01/10 01:12:48 shawang noship $ */
function get_rate
  (
   p_from_curr       varchar2,
   p_to_curr         varchar2,
   p_exchange_rate_date   varchar2,
   p_exchange_rate_type   varchar2
  )
  return number;

function get_reporting_balance
  (
   p_balance         number,
   p_from_curr       varchar2,
   p_to_curr         varchar2,
   p_exchange_rate_date   varchar2,
   p_exchange_rate_type   varchar2
  )
  return varchar2;

function get_balance
  (
   p_balance         number,
   p_from_curr       varchar2
  )
  return varchar2;


function get_variance
  (
   p_bank_acct_id  number,
   p_balance_date  date,
   p_actual_balance_type  varchar2
  )
  return number;

PROCEDURE printClobOut(
                      aResult       IN OUT NOCOPY  CLOB
                      );


END CE_BANKACCT_BA_REPORT_UTIL;

 

/
