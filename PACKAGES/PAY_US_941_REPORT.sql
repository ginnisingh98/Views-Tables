--------------------------------------------------------
--  DDL for Package PAY_US_941_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_941_REPORT" AUTHID CURRENT_USER AS
/* $Header: payus941report.pkh 120.1.12010000.2 2010/03/11 06:32:28 vvijayku ship $ */
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

    Name        : pay_us_941_report

    Description : This package is called for the 941 Report to
                  generate the XML file.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    15-APR-2005 pragupta   115.0            Created
    30-OCT-2006 alikhar    115.1   5479800  Added procedure pay_us_941_report_wrapper
	11-MAR-2010 vvijayku   115.2   9357061  Added the Funtion split_number_into_int_decimal

  ******************************************************************************/

  /******************************************************************************
  ** Package Local Variables
  ******************************************************************************/
  TYPE XMLRec IS RECORD(
    xmlstring VARCHAR2(32000));

  TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
    vXMLTable tXMLTable;

  FUNCTION SPLIT_NUMBER_INTO_INT_DECIMAL(P_NUMBER        IN NUMBER,                   -- Bug 9357061: Function start.
                                         P_DEC           IN NUMBER,
                                         P_INTEGER_PART  OUT NOCOPY NUMBER,
                                         P_DECIMAL_PART  OUT NOCOPY VARCHAR2) RETURN NUMBER;

  PROCEDURE gen_941_report(p_business_group_id IN NUMBER,
                           p_tax_unit_id       IN NUMBER,
                           p_year              IN VARCHAR2,
                           p_qtr               IN VARCHAR2,
                           p_template_name     IN VARCHAR2 DEFAULT NULL,
                           p_XML               OUT NOCOPY Clob);

  PROCEDURE pay_us_941_report_wrapper
                  (  errbuf              OUT NOCOPY VARCHAR2,
                     retcode             OUT NOCOPY VARCHAR2,
		     p_business_group_id IN NUMBER,
                     p_tax_unit_id       IN VARCHAR2,
                     p_year              IN NUMBER,
                     p_qtr               IN VARCHAR2,
		     p_valid_template_list IN VARCHAR2,
		     p_appl_short_name   IN VARCHAR2,
                     p_template_name     IN VARCHAR2,
  		     p_effective_date    IN VARCHAR2
                 );

END pay_us_941_report;

/
