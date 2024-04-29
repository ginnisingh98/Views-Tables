--------------------------------------------------------
--  DDL for Package PAY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pyarchiv.pkh 120.0.12010000.1 2008/07/27 22:03:32 appldev ship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   20-MAR-1998          First Created.
   25-JUN-1998		dzshanno	40.1	add multi context functionality
   17-JUL-1998		dzshanno		added set_jur_level
   08-MAR-1999          nbristow        110.2   Added remove_report_actions.
   17-SEP-1999          nbristow        110.3   Added archive_aa.
   15-FEB-2000          alogue          115.3   Utf8 support : use of
                                                varchar_240_tbl.
   19-MAY-2000          nbristow        115.4   Added the deinitialise
                                                section.
   13-JUL-2000          ssarma          115.5   Added g_leg_code global.
                                                Added function get_jursd_level.
   30-JAN-2002          mreid           115.6   Added dbdrv standards
   16-JUL-2002          nbristow        115.7   Added standard_deinit.
   09-JUL-2004          nbristow        115.8   Added process_chunk.
*/
TYPE number_tbl     IS TABLE OF NUMBER      INDEX BY binary_integer;
TYPE varchar_60_tbl IS TABLE OF VARCHAR(60) INDEX BY binary_integer;
TYPE varchar_240_tbl IS TABLE OF VARCHAR(240) INDEX BY binary_integer;

TYPE context_values IS RECORD
(
 name		varchar_60_tbl,
 value		varchar_60_tbl,
  sz		integer
);

g_context_values		context_values;
g_leg_code                      varchar2(10) := null;
--
-- Variables
--
balance_aa number;
archive_aa number;
--
-- Procedures
procedure arch_initialise(p_payroll_action_id   in      number);
function  get_jursd_level(p_route_id  number,p_user_entity_id number) return number;
procedure deinitialise(p_payroll_action_id   in      number);
procedure process_chunk(p_payroll_action_id in number,
                        p_chunk_number in number);
procedure process_employee(p_assact_id in number);
procedure set_dbi_level (p_dbi_name in varchar2,p_jur_level in varchar2);
procedure remove_report_actions(p_pact_id in number,
                                p_chunk_no in number default null);
procedure standard_deinit (pactid in number);
end pay_archive;

/
