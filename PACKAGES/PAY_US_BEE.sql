--------------------------------------------------------
--  DDL for Package PAY_US_BEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_BEE" AUTHID CURRENT_USER AS
/* $Header: pyusbee.pkh 115.3 2002/12/05 14:23:03 jbarker ship $ */

Function line_check_supported
return number;

procedure validate_line(p_batch_line_id in  number,
                        valid           out NOCOPY number,
                        leg_message     out NOCOPY varchar2,
                        line_changed    out NOCOPY number);
end pay_us_bee;

 

/
