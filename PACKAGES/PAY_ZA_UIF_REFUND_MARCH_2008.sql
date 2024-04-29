--------------------------------------------------------
--  DDL for Package PAY_ZA_UIF_REFUND_MARCH_2008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_UIF_REFUND_MARCH_2008" AUTHID CURRENT_USER as
/* $Header: pyzauifr.pkh 120.2.12010000.1 2008/09/30 11:17:27 parusia noship $ */
procedure create_uif_backdated_entries (errbuf out nocopy varchar2,
                                       retcode out nocopy number,
                                       p_payroll_id number,
                                       p_reflection_date_char varchar2,
                                       p_asg_set_id number) ;

type assact_rec is record ( month_yr varchar2(15),
                            assignment_id number,
                            assignment_number varchar2(30),
                            action_seq number
                           );
type tab_assact is table of assact_rec INDEX BY BINARY_INTEGER;

excp_uif_manipulated exception ;

end PAY_ZA_UIF_REFUND_MARCH_2008;

/
