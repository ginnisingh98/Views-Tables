--------------------------------------------------------
--  DDL for Package PAY_CA_T4AEOY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_T4AEOY_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pycayt4a.pkh 120.0.12000000.1 2007/01/17 17:44:46 appldev noship $ */

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
This package is used to keep the logics for
1)selecting people  : eoy_range_cursor
2)assignment action creation : eoy_action_creation
3)archiving data for Canadian End of Year archiver process :eoy_archive_data
  for T4 reports and magtape.
4)Initialization_code : eoy_archinit (which does not do anything but kept for
                                      backward compatibility with the PYUGEN
                                      archiver process.)

The above procedures are called by PYUGEN pay_report_mappings_f, i.e the
row in this table for T4 archiver is like:

 REPORT_TYPE            : CAEOY
 REPORT_QUALIFIER       : CAEOY
 REPORT_FORMAT          : CAEOY
 EFFECTIVE_START_DATE   : 01-JAN-01
 EFFECTIVE_END_DATE     : 31-DEC-12
 RANGE_CODE             : pay_ca_t4aeoy_archive.eoy_range_cursor
 ASSIGNMENT_ACTION_CODE : pay_ca_t4aeoy_archive.eoy_action_creation
 INITIALIZATION_CODE    : pay_ca_t4aeoy_archive.eoy_archinit
 ARCHIVE_CODE           : pay_ca_t4aeoy_archive.eoy_archive_data
 MAGNETIC_CODE          : NULL
 REPORT_CATEGORY        : CAEOY
 REPORT_NAME            : NULL
 SORT_CODE              : NULL
 INITIALISATION_CODE    : NULL
 UPDATABLE_FLAG         : NULL



   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   03-JAN-2000  mmukherj    110.0           Created.
   19-NOV-2001  ssattini    115.1           Added dbdrv line.
   02-DEC-2002  SSattini    115.6           Added 'nocopy' for out and in out
                                            parameters, GSCC compliance.
*/

TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;
TYPE number_data_type_table IS TABLE OF NUMBER
                                  INDEX BY BINARY_INTEGER;
g_min_chunk    number:= -1;
g_archive_flag varchar2(1) := 'N';

procedure eoy_range_cursor(pactid in  number,
                       sqlstr out nocopy varchar2);

procedure eoy_action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number);
procedure eoy_archive_data(p_assactid in number, p_effective_date in date);
procedure eoy_archinit(p_payroll_action_id in number);
--
end pay_ca_t4aeoy_archive;

 

/
