--------------------------------------------------------
--  DDL for Package PAY_ZA_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pyzaparc.pkh 120.0.12010000.1 2008/07/28 00:03:57 appldev ship $ */

procedure archinit(p_payroll_action_id in number);

procedure range_cursor
(
   pactid in  number,
   sqlstr out nocopy varchar2
);

procedure action_creation
(
   pactid    in number,
   stperson  in number,
   endperson in number,
   chunk     in number
);

procedure archive_code
(
   p_assactid       in number,
   p_effective_date in date
);

end;

/
