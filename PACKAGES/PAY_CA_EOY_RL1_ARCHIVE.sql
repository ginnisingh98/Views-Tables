--------------------------------------------------------
--  DDL for Package PAY_CA_EOY_RL1_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EOY_RL1_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pycarlar.pkh 120.0.12010000.2 2009/04/20 14:42:49 sapalani ship $ */
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

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   14-JAN-2000  mmukherj    110.0           Created.
   10-NOV-2001  vpandya     115.1           Added set veify off at top as per
                                            GSCC
   12-NOV-2001  vpandya     115.2           Added dbdrv line at top
   27-DEC-2001  vpandya     115.4           Added check_file in dbdrv
   02-DEC-2002  vpandya     115.5           Added nocopy with out parameter
                                            as per GSCC.
   10-Apr-2009  sapalani    115.6 6768167   Added function gen_rl1_pdf_seq.
*/
--
TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;
TYPE number_data_type_table IS TABLE OF NUMBER
                                  INDEX BY BINARY_INTEGER;
g_min_chunk    number:= -1;
g_archive_flag varchar2(1) := 'N';
g_rl1_last_slip_number number := 0;

procedure eoy_range_cursor(pactid in  number,
                       sqlstr out nocopy varchar2);

procedure eoy_action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number);
procedure eoy_archive_data(p_assactid in number, p_effective_date in date);
procedure eoy_archinit(p_payroll_action_id in number);
FUNCTION gen_rl1_pdf_seq(p_aaid in number,
                         p_reporting_year in varchar2,
                         p_jurisdiction in varchar2,
                         called_from in varchar2)
        return varchar2;
--
end pay_ca_eoy_rl1_archive;

/
