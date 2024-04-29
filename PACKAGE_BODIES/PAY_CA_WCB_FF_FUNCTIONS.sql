--------------------------------------------------------
--  DDL for Package Body PAY_CA_WCB_FF_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_WCB_FF_FUNCTIONS" AS
/* $Header: pycawcfc.pkb 120.0.12010000.3 2009/06/08 10:50:34 sapalani ship $ */
----------------------------------------------------------------------
-- FUNCTION GET_RATE_ID_FOR_WCB_CODE
----------------------------------------------------------------------
FUNCTION get_rate_id_for_wcb_code (p_bg_id          number
                                  ,p_account_number varchar2
                                  ,p_code           varchar2
                                  ,p_jurisdiction   varchar2)
RETURN NUMBER IS
--
l_rate_id	number;
--
CURSOR get_rate_id_for_wcb_code(p_bg_id          number
                               ,p_account_number varchar2
                               ,p_code           varchar2
                               ,p_jurisdiction   varchar2) IS
--
  select wr.rate_id
  from   pay_wci_accounts_v wav
  ,      pay_wci_rates      wr
  where  wav.account_id     = wr.account_id
  and    wav.province       = p_jurisdiction
  and    wav.account_number = p_account_number
  and    wr.code            = p_code
  and    wr.business_group_id = p_bg_id; --Added for 6833569
  --
BEGIN
--
open  get_rate_id_for_wcb_code(p_bg_id, p_account_number, p_code, p_jurisdiction);
fetch get_rate_id_for_wcb_code into l_rate_id;
--
if get_rate_id_for_wcb_code%NOTFOUND then
  l_rate_id := 8.8;
end if;
--
close get_rate_id_for_wcb_code;
--
RETURN l_rate_id;
--
END get_rate_id_for_wcb_code;
--
-------------------------------------------------------------------------
-- FUNCTION GET_RATE_ID_FOR_JOB
-------------------------------------------------------------------------
FUNCTION get_rate_id_for_job (p_account_number varchar2
                             ,p_job            varchar2
                             ,p_jurisdiction   varchar2)
RETURN number IS
--
l_rate_id 	number;
--
CURSOR get_rate_id_for_job(p_account_number varchar2
                          ,p_job            varchar2
                          ,p_jurisdiction   varchar2) IS
--
  select wr.rate_id
  from   pay_wci_accounts_v  wav
  ,      pay_wci_rates       wr
  ,      pay_wci_occupations wo
  ,      per_jobs            pj
  where  wav.account_id     = wr.account_id
  and    wr.rate_id         = wo.rate_id
  and    wo.job_id          = pj.job_id
  and    pj.name            = p_job
  and    wav.province       = p_jurisdiction
  and    wav.account_number = p_account_number;
  --
BEGIN
--
open  get_rate_id_for_job(p_account_number, p_job, p_jurisdiction);
fetch get_rate_id_for_job into l_rate_id;
--
if get_rate_id_for_job%NOTFOUND then
  l_rate_id := 9.9;
end if;
--
close get_rate_id_for_job;
--
RETURN l_rate_id;
--
END get_rate_id_for_job;
-------------------------------------------------------------------------
-- FUNCTION GET_WCB_RATE
-------------------------------------------------------------------------
FUNCTION get_wcb_rate (p_rate_id number) RETURN number IS
--
l_rate 		number;
--
CURSOR get_wcb_rate(p_rate_id number) IS
--
  select nvl(rate,0)
  from   pay_wci_rates
  where  rate_id = p_rate_id;
--
BEGIN
--
open  get_wcb_rate(p_rate_id);
fetch get_wcb_rate into l_rate;
close get_wcb_rate;
--
RETURN l_rate;
--
END get_wcb_rate;
--
END pay_ca_wcb_ff_functions;

/
