--------------------------------------------------------
--  DDL for Package PAY_CORE_XDO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CORE_XDO_UTILS" AUTHID CURRENT_USER as
/* $Header: paycorexdoutil.pkh 120.0.12000000.1 2007/03/21 13:52:18 sausingh noship $ */

Type t_req_ids is Table of fnd_concurrent_requests.request_id%type index by binary_integer;
request_list t_req_ids;

Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER);

Procedure standard_deinit(pactid IN NUMBER);

end pay_core_xdo_utils;

 

/
