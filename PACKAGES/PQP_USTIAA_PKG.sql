--------------------------------------------------------
--  DDL for Package PQP_USTIAA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_USTIAA_PKG" AUTHID CURRENT_USER as
/* $Header: pqustiaa.pkh 120.1.12000000.1 2007/01/16 04:38:44 appldev noship $ */
/*

--
*/

level_cnt number;

PROCEDURE range_cursor ( pactid in  number  ,
                         sqlstr out nocopy varchar2
                       );
PROCEDURE action_creation ( pactid in number   ,
                            stperson in number ,
                            endperson in number,
                            chunk in number
                          );
PROCEDURE sort_action ( payactid   in     varchar2 ,
                        sqlstr     in out nocopy varchar2 ,
                        len        out nocopy    number
                      );
FUNCTION get_parameter(name in varchar2       ,
                       parameter_list varchar2) return varchar2;
PRAGMA RESTRICT_REFERENCES(get_parameter, WNDS, WNPS);
--

PROCEDURE action_creation_ops ( pactid in number   ,
                            stperson in number ,
                            endperson in number,
                            chunk in number
                          );

PROCEDURE generate_record;

PROCEDURE generate_header_xml;

PROCEDURE generate_footer_xml;

CURSOR TIAA_DETAIL IS
SELECT  'TRANSFER_ACT_ID=P'
      , ptoa.object_action_id
FROM    pay_temp_object_actions       ptoa
WHERE ptoa.payroll_action_id          =
       pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');

CURSOR TIAA_HF IS
SELECT  'PAYROLL_ACTION_ID=P'
      ,pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
FROM  dual;

CURSOR TIAA_ASG_ACTIONS IS
SELECT  'TRANSFER_ACT_ID=P'
      ,pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
FROM  dual;

END pqp_ustiaa_pkg;

 

/
