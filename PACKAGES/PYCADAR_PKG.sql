--------------------------------------------------------
--  DDL for Package PYCADAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYCADAR_PKG" AUTHID CURRENT_USER as
/* $Header: pycadar.pkh 120.0.12000000.1 2007/01/17 16:53:36 appldev noship $ */
/*

rem +======================================================================+
rem |                Copyright (c) 1993 Oracle Corporation                 |
rem |                   Redwood Shores, California, USA                    |
rem |                        All rights reserved.                          |
rem +======================================================================+
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   03-JUN-1999  mmukherj    110.0  Created.
   23-MAR-2001  vpandya     115.1  Added get_labels function
                                   with three input parameters.
   09-MAY-2002  vpandya     115.2  Added dbdrv and checkfile
   04-JUN-2002  vpandya     115.4  Added procedure archive_action_creation for
                                   the deposit advice process that runs off of
                                   the payroll archive process.
   21-SEP-2002  pganguly    115.5  Added whenever oserror exit failure rollback
   27-Jan-2003  vpandya     115.6  Added nocopy with out parameter as per gscc.
   27-JUL-2004  ssattini    115.7  Added new function check_if_assignment_paid
                                   to use in the archive_action_creation
                                   procedure to improve performance. Bug#3438254
--
*/
procedure range_cursor ( pactid in  number,
                         sqlstr out nocopy varchar2
                       );

FUNCTION check_if_assignment_paid(p_prepayment_action_id in number,
                                   p_deposit_start_date   in date,
                                   p_deposit_end_date     in date,
                                   p_consolidation_set_id in number)
RETURN VARCHAR2;

procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );

procedure archive_action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );

procedure sort_action ( procname   in     varchar2,
                        sqlstr     in out nocopy varchar2,
                        len        out nocopy    number
                      );

function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);

function get_labels(p_lookup_type in varchar2,
                    p_lookup_code in varchar2) return varchar2;

function get_labels(p_lookup_type in varchar2,
                    p_lookup_code in varchar2,
                    p_person_language in varchar2 ) return varchar2;

--pragma restrict_references(get_labels, WNDS, WNPS);
--
end pycadar_pkg;

 

/
