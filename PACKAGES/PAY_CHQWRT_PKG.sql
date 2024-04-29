--------------------------------------------------------
--  DDL for Package PAY_CHQWRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CHQWRT_PKG" AUTHID CURRENT_USER as
/* $Header: pychqwrt.pkh 120.0.12010000.1 2008/07/27 22:20:16 appldev ship $ */
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

   Name        : chqsql

   Description : Build dynamic sql for cheque writer process.

   Test List
   ---------

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   12-OCT-1993  CLEVERLY    1.0             First created.
   05-OCT-1994  RFINE       40.4            Renamed package to pay_chqwrt_pkg
   06-Dec-2004  SuSivasu    115.1           Added cheque_date function.
   10-Dec-2004  SuSivasu    115.2           Removed cheque_date function.
*/

   ---------------------------------- chqsql ----------------------------------
   /*
      NAME
         chqsql - build dynamic sql.
      DESCRIPTION
         selects a SQL statement with the correct ordering of pre-payments
         so that cheque numbers are allocated and printed in the correct
         sequence for the organisation.
      NOTES
         <none>
   */
   procedure chqsql
   (
      procname   in            varchar2,     /* name of the select statement to use */
      sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
      len        out    nocopy number        /* length of the sql string */
   );


   --------------------------------- cheque_date ------------------------------
   /*
      NAME
         cheque_date - derives the cheque date.
      DESCRIPTION
         Returns the cheque date based on the select payment
      NOTES
         <none>
   */
   -- function cheque_date
   -- (
   --    p_business_group_id    in number,
   --    p_payroll_id           in number,
   --    p_consolidation_set_id in number,
   --    p_start_date           in date,
   --    p_end_date             in date,
   --    p_payment_type_id      in number,
   --    p_payment_method_id    in number,
   --    p_cheque_style         in varchar2
   -- ) return date;

end pay_chqwrt_pkg;

/
