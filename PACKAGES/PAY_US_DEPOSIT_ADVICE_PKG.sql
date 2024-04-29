--------------------------------------------------------
--  DDL for Package PAY_US_DEPOSIT_ADVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_DEPOSIT_ADVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: payuslivearchive.pkh 120.2.12010000.4 2009/01/21 08:28:03 sudedas ship $ */
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
   08-Jun-04 rmonge         115.0            Created.
                                             This package is a copy of
                                             pyusdar.pkh. Please refer
                                             to the old package header
                                             for history of changes.
   5-Jul-04  schauhan       115.1 3512116    Added function check_if_assignment_paid.
                                             This is added for eliminating cursor
                                             c_actions_zero_pay.
   24-May-07 sudedas        115.2 5635335    Added procedure archive_deinit
                                             to be used by New Deposit Advice (PDF)
   27-Jun-2007 sudedas      115.3            Added Qualifying Procedure and Function
                                             check_if_qualified_for_US. This is for
                                             Archive Deposit Advice producing XML
                                             using Global Payslip Printing Solution.
   15-Jan-2009 sudedas      115.4  7583387   Added function DAxml_range_cursor
                                             and package level global variables for
                                             DA(XML) payroll action level legislative
                                             parameters and a global plsql table.
   21-Jan-2009 sudedas      115.5  7583387   Changed Function DAxml_range_cursor
                                             to Procedure.
                            115.6  7583387   Added NOCOPY hint for OUT variable.
--
*/
 PROCEDURE range_cursor(pactid in number
                       ,sqlstr out NOCOPY varchar2);

 FUNCTION check_if_assignment_paid(p_prepayment_action_id in number,
                                   p_deposit_start_date   in date,
                                   p_deposit_end_date     in date,
                                   p_consolidation_set_id in number)
 RETURN VARCHAR2;


 PROCEDURE archive_action_creation(pactid    in number,
                                   stperson  in number,
                                   endperson in number,
                                   chunk     in number);

 PROCEDURE sort_action(procname   in     varchar2,
                       sqlstr     in out NOCOPY varchar2,
                       len        out    NOCOPY number);

 procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );
-- Procedure will be used for de-initialization of Deposit Advice (PDF) Process
procedure archive_deinit(pactid in number) ;

PROCEDURE qualifying_proc(p_assignment_id    IN         NUMBER
                         ,p_qualifier        OUT NOCOPY VARCHAR2 ) ;
--
--
FUNCTION check_if_qualified_for_US(p_archive_action_id IN NUMBER
                                  ,p_assignment_id IN NUMBER
                                  ,p_deposit_start_date IN DATE
                                  ,p_deposit_end_date IN DATE
                                  ,p_consolidation_set_id IN NUMBER)
RETURN VARCHAR2;
--
--
--

   PROCEDURE DAxml_range_cursor(pactid in number
                               ,psqlstr out NOCOPY varchar2);
--
--
    g_payroll_act_id        NUMBER := -1;
    g_payroll_id            NUMBER := -1;
    g_consolidation_set_id  NUMBER := -1;
    g_start_dt              DATE := TO_DATE('0001/01/01','YYYY/MM/DD');
    g_end_dt                DATE := TO_DATE('4712/12/31','YYYY/MM/DD');
    g_rep_group             pay_report_groups.report_group_name%TYPE := NULL;
    g_rep_category          pay_report_categories.category_name%TYPE := NULL;
    g_assignment_set_id     NUMBER := -1;
    g_assignment_id         NUMBER := -1;
    g_effective_date        DATE := TO_DATE('0001/01/01','YYYY/MM/DD');
    g_business_group_id     NUMBER := -1;
    g_legislation_code      VARCHAR2(10) := 'XX';

    TYPE typ_tmp_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    g_tmp_tbl              typ_tmp_tbl;
--
--
END pay_us_deposit_advice_pkg;

/
