--------------------------------------------------------
--  DDL for Package PER_CA_EMP_EQUITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CA_EMP_EQUITY_PKG" AUTHID CURRENT_USER AS
/* $Header: perhrcaempequity.pkh 120.0 2006/05/25 06:37:33 ssmukher noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : per_ca_emp_equity_pkg

    Description : This package is used for generating the employee.txt
                  promot.txt,term.txt and excep.txt tab delimited text
                  file for Employment Equity Report.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    28-Apr-2005 ssmukher   115.0            Created.
    01-Jul-2005 ssmukher   115.1            Modified the gscc error
  ******************************************************************************/

   l_counter number;

   TYPE job_id_tab IS TABLE OF per_jobs.job_id%type
                  INDEX BY BINARY_INTEGER;

   TYPE job_noc_tab IS TABLE OF per_jobs.job_information7%type
                  INDEX BY BINARY_INTEGER;

   TYPE person_type_tab IS TABLE OF per_person_types.person_type_id%type
                  INDEX BY BINARY_INTEGER;

/*  Procedure to generate the employee.txt file */
    procedure employee_dtls (errbuf           out nocopy varchar2,
                             retcode          out nocopy number,
                             p_business_group_id in number,
                             p_year           in varchar2,
                             p_naic_code      in varchar2);
/*  Procedure to generate the promot.txt file  */
    procedure emp_promotions (errbuf           out nocopy varchar2,
                             retcode          out nocopy number,
                             p_business_group_id in number,
                             p_year             in varchar2,
                             p_naic_code        in varchar2,
                             p_start_date       in date,
                             p_end_date         in date );

/*  Procedure to print the list of terminated employee  */
    procedure count_term    (errbuf           out nocopy varchar2,
                             retcode          out nocopy number,
                             p_business_group_id in number,
                             p_year  in varchar2,
                             p_naic_code in varchar2);

/*  Procedure to print the exception report for employee with incomplete details */
    procedure excep_report  (errbuf           out nocopy varchar2,
                             retcode          out nocopy number,
                             p_business_group_id in number,
                             p_year  in varchar2,
                             p_naic_code in varchar2);

/*  Function to check if the Job assigned to the employee exists or not */
    function job_exists (p_job_id in number)
    return varchar2 ;

/*  Function to check if the Person type is a  valid one */
    function person_type_exists (p_person_type in number)
    return varchar2;

end;

 

/
