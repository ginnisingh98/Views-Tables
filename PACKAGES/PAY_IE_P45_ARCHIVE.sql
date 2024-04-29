--------------------------------------------------------
--  DDL for Package PAY_IE_P45_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_P45_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyiep45.pkh 120.2.12010000.1 2008/07/27 22:50:36 appldev ship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  IE P45 Archive Package body
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  05 APR 2002 abhaduri  N/A      Created
**  01 JUN 2002 viviswan           XML Report
**                                 procedure added
**  05 DEC 2002 viviswan           no copy changes
**  06 JUL 2005 sgajula   4468864  Added archive_deinit
**  14 FEB 2006 sgajula   5005788  Changed get_arc_bal_value for
**                                 Performance.
------------------------------------------------
*/

PROCEDURE archinit (p_payroll_action_id IN NUMBER);

PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT nocopy VARCHAR2);

PROCEDURE action_creation (pactid in number,
                           stperson in number,
                           endperson in number,
                           chunk in number);

PROCEDURE archive_code (p_assactid in number,
                        p_effective_date in date);

PROCEDURE archive_deinit (p_payroll_action_id IN NUMBER);

FUNCTION get_lookup_meaning(
                     p_lookup_type    in varchar2
                    ,p_lookup_code    in varchar2 ) return varchar2;

FUNCTION get_arc_bal_value(
                     p_assignment_action_id  in number
		    ,p_payroll_action_id     in number     -- 5005788
                    ,p_balance_name          in varchar2 ) return number;

PROCEDURE generate_xml(
           errbuf                   out nocopy varchar2
          ,retcode                  out nocopy varchar2
          ,p_p45_archive_process    in  number
          ,p_assignment_id    in  number);



END;

/
