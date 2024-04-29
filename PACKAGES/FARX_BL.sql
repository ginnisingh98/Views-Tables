--------------------------------------------------------
--  DDL for Package FARX_BL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_BL" AUTHID CURRENT_USER as
/* $Header: farxbls.pls 120.3.12010000.3 2009/10/30 12:39:00 pmadas ship $ */

-- Intended as a private function:

PROCEDURE BALANCES_REPORTS (
  BOOK                  IN      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  report_type           in      varchar2,
  adj_mode              in      varchar2,
  sob_id                in      varchar2 default NULL,   -- MRC: Set of books id
  report_style          in      varchar2 default 'S',
  request_id            in      number,
  user_id               in      number,
  calling_fn            in      varchar2,
  mesg           out nocopy varchar2,
  success        out nocopy boolean);

-- These are the procedures to be called by concurrent request wrappers.

PROCEDURE CIP_BALANCES_RPT (
  book                  in      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  request_id            in      number,
  user_id               in      number,
  retcode        out nocopy number,
  errbuf         out nocopy varchar2);

PROCEDURE ASSET_COST_BALANCES_RPT (
  book                  in      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  sob_id                in      varchar2 default NULL,   -- MRC: Set of books id
  report_style          in      varchar2 default 'S',    -- Drill Down is 'D'
  request_id            in      number,
  user_id               in      number,
  retcode        out nocopy number,
  errbuf         out nocopy varchar2);

PROCEDURE ACCUM_DEPRN_BALANCES_RPT (
  book                  in      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  sob_id                in      varchar2 default NULL,   -- MRC: Set of books id
  report_style          in      varchar2 default 'S',    -- Drill down is 'D'
  request_id            in      number,
  user_id               in      number,
  retcode        out nocopy number,
  errbuf         out nocopy varchar2);

PROCEDURE REVAL_RESERVE_BALANCES_RPT (
  book                  in      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  request_id            in      number,
  user_id               in      number,
  retcode        out nocopy number,
  errbuf         out nocopy varchar2);


END FARX_BL;

/
