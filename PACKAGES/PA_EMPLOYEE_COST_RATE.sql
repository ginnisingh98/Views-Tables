--------------------------------------------------------
--  DDL for Package PA_EMPLOYEE_COST_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EMPLOYEE_COST_RATE" AUTHID CURRENT_USER as
/* $Header: PAXSUECS.pls 120.1 2005/08/09 04:32:14 avajain noship $ */
procedure check_overlapping_date(v_person_id varchar2,
                                v_err_code in out NOCOPY number,
                                v_mesg in out NOCOPY varchar2);

end;

 

/
