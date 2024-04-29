--------------------------------------------------------
--  DDL for Package PAY_ACTION_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ACTION_CONTEXTS_PKG" AUTHID CURRENT_USER as
/* $Header: pyactx.pkh 115.4 2002/12/05 18:03:50 rthirlby noship $ */

procedure archinit(p_pay_act_id in number);

procedure range_cursor(p_pay_act_id in            number
                      ,p_sqlstr        out nocopy varchar2);

procedure action_creation(p_pay_act_id in number,
                          p_stperson   in number,
                          p_endperson  in number,
                          p_chunk      in number);

procedure archive_data(p_asg_act_id in number, p_effective_date in date);

procedure deinitialise(p_pay_act_id in number);

end pay_action_contexts_pkg;

 

/
