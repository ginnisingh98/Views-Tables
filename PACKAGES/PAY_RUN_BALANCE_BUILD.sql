--------------------------------------------------------
--  DDL for Package PAY_RUN_BALANCE_BUILD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_BALANCE_BUILD" AUTHID CURRENT_USER as
/* $Header: pycorubl.pkh 115.1 2002/12/09 17:16:59 kkawol noship $ */
--
/*
function find_context(p_context_name in varchar2,
                      p_context_id   in number) return varchar2;
*/

  PROCEDURE action_range_cursor( p_payroll_action_id in number
                              ,p_sqlstr           out nocopy varchar2);

  PROCEDURE action_action_creation( p_payroll_action_id   in number
                                 ,p_start_person_id in number
                                 ,p_end_person_id   in number
                                 ,p_chunk               in number);

  PROCEDURE ACTION_ARCHIVE_DATA(p_assactid in number,
                                p_effective_date in date);


  PROCEDURE ACTION_ARCHINIT(p_payroll_action_id in number);

procedure deinitialise (pactid in number);

  end pay_run_balance_build;

 

/
