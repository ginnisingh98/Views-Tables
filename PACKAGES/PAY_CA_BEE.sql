--------------------------------------------------------
--  DDL for Package PAY_CA_BEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_BEE" AUTHID CURRENT_USER AS
/* $Header: pycabee.pkh 115.1 99/07/22 06:34:52 porting shi $ */
/*

 Name          : pay_ca_bee
 Description   : Canadian Legislative Hook for BEE.
 Author        : A.Logue
 Date Created  : 05-Jul-99
 Contents      : line_check_supported, validate_line.

 Change List
 -----------
 Date         Name           Vers     Bug No    Description
 +-----------+--------------+--------+---------+-----------------------+
  23-JUL-1999 A.Logue        115.1              Added commit.
  05-JUL-1999 A.Logue        115.0              First Created.
                                                No Header validation.
                                                Line Validation: checks
                                                that the base element
                                                entry exists for a
                                                Special Input Entry.
 +-----------+--------------+--------+---------+-----------------------+
*/

Function line_check_supported
return number;

procedure validate_line(batch_line_id in  number,
                        valid         out number,
                        leg_message   out varchar2,
                        line_changed  out number);
end pay_ca_bee;

 

/
