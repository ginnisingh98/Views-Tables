--------------------------------------------------------
--  DDL for Package PAY_MAGTAPE_GENERIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MAGTAPE_GENERIC" 
/* $Header: pymaggen.pkh 120.2.12010000.1 2008/07/27 23:08:58 appldev ship $ */
AUTHID CURRENT_USER as
--
--
/*
PRODUCT
    Oracle*Payroll
--
NAME
   pymaggen.pkh
--
DESCRIPTION
This script creates the package body which can be used by the Magnetic
Tape process. This package creates procedures that setup the parameter
and context tables, used in the Magtape process, based on data held
in the PAY_MAGNETIC_BLOCKS and PAY_MAGNETIC_RECORDS tables.
--
MODIFIED (DD-MON-YYYY)
  nbristow    27-FEB-1995 - created.
  allee	      20-SEP-1995 - added function 'date_earned' that
			    is used in global cursors defined
			    in pyusmrep.pkh
  jalloun     30-JUL-1996 - Added error handling.
  nbristow    16-JUN-1997 - Bug 505208. Increased size of parameter strings.
  nbristow    06-SEP-2004 - Changes for multithraeded magtape.
  nbristow    07-SEP-2004 - Fixed GSCC errors.
  tbattoo     03-Dec-2004 - added support for magtape in xml
  tbattoo     26-Jan-2005 - added support for magtape in xml using procedure calls
  tbattoo     25-Jul-2005 - added proc to set parameter value
			    in ff_archive_items
  tbattoo     09-FEB-2006 - added clear_cursors
*/

    use_action_block varchar2(5);
    process_action_rec varchar2(5);
    cur_fetch boolean;
--
    function date_earned
     (
     p_report_date   date,
     p_assignment_id number
     ) return date;

    pragma restrict_references(date_earned, WNDS, WNPS);
    type char_array is table of varchar(257) index by binary_integer;
    ret_vals char_array;
    boolean_flag boolean;
    procedure new_formula;
    function get_parameter_value(prm_name varchar2)
    return varchar2;
    pragma restrict_references (get_parameter_value, WNDS, WNPS);
    function get_cursor_return(curs_name pay_magnetic_blocks.cursor_name%TYPE,
                               pos number) return varchar;
--
    pragma restrict_references (get_cursor_return, WNDS, WNPS);

    procedure clear_cache;
    procedure clear_cursors;

procedure set_paramter_value(asg_act_id number,
                             prm_name varchar,
                             prm_value varchar);


end pay_magtape_generic;

/
