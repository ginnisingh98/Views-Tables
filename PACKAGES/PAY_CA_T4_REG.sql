--------------------------------------------------------
--  DDL for Package PAY_CA_T4_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_T4_REG" AUTHID CURRENT_USER as
/* $Header: pycat4rg.pkh 120.0.12000000.1 2007/01/17 17:29:52 appldev noship $ */

--
-- Function/Procedures (See Package Body for detailed description)
--

procedure range_cursor ( pactid in  number,
                         sqlstr out nocopy varchar2
                       );
procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );
procedure sort_action ( payactid   in     varchar2,
                        sqlstr     in out nocopy varchar2,
                        len        out nocopy    number
                      );
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);

function get_label(p_lookup_type in varchar2,
                   p_lookup_code in varchar2) return varchar2;
--
end pay_ca_t4_reg;

 

/
