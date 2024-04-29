--------------------------------------------------------
--  DDL for Package PAY_US_PR_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_PR_W2" AUTHID CURRENT_USER as
/* $Header: pyusprw2.pkh 120.0.12010000.1 2008/07/27 23:55:44 appldev ship $*/

/*
 +=====================================================================+
 |              Copyright (c) 1997 Orcale Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |			All rights reserved.                           |
 +=====================================================================+
Name		: pay_us_pr_w2
Description	:  This package is called by the Puerto Rico W2 Totals and
                  Exceptions Report
History		: 23-AUG-2002
   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   27-AUG-2002  fusman      115.0              Created.
   07-AUG-2003  jgoswami    115.1              added p_report_type,Nocopy changes.
   25-AUG-2003  jgoswami    115.2  2778370   added defination for pl/sql table
                                             of records to store label and value
   03-sep-2003 jgoswami     115.3  3097463   added r_type to record to store data type.
--

*/


PROCEDURE insert_pr_w2_totals(errbuf                OUT nocopy    VARCHAR2,
                              retcode               OUT nocopy    NUMBER,
                              p_seq_num             IN      VARCHAR2,
                              p_report_type         IN      VARCHAR2) ;

  /**************************************************************
  ** PL/SQL table of records to store Label name and Value
  ***************************************************************/

  TYPE rec_total  IS RECORD (r_label  varchar2(240),
                             r_value  varchar2(240),
                             r_type  varchar2(240));
  TYPE tab_rec_total IS TABLE OF rec_total INDEX BY BINARY_INTEGER;

end pay_us_pr_w2;

/
