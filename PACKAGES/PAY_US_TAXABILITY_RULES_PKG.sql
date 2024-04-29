--------------------------------------------------------
--  DDL for Package PAY_US_TAXABILITY_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAXABILITY_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: paysuetw.pkh 115.2 2003/09/22 19:03:16 asasthan ship $ */
--
--
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


    Name        : pay_us_taxability_rules_pkg

    Description : This package holds building blocks used in maintenace
                  of US taxability rule using PAY_TAXABILITY_RULES
                  table.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    NOV-11-1993 RMAMGAIN      1.0                Created with following proc.
                                                 get_or_update
    05-OCT-1994 RFINE         40.2               Added 'PAY_' to package name.
    05-OCT-1994 RFINE         40.3               ... and suffix '_PKG'
    03-APR-1995 gpaytonm      40.4               Modified to handle popuilating
                                                 classification id.

    22-SEP-2003 gpaytonm     115.2               Added get_balance_type
  */
--

PROCEDURE get_or_update(X_MODE                VARCHAR2,
                        X_CONTEXT             VARCHAR2,
                        X_JURISDICTION        VARCHAR2,
                        X_TAX_CAT             VARCHAR2,
			X_classification_id   NUMBER,
                        X_BOX1  IN OUT NOCOPY VARCHAR2,
                        X_BOX2  IN OUT NOCOPY VARCHAR2,
                        X_BOX3  IN OUT NOCOPY VARCHAR2,
                        X_BOX4  IN OUT NOCOPY VARCHAR2,
                        X_BOX5  IN OUT NOCOPY VARCHAR2,
                        X_BOX6  IN OUT NOCOPY VARCHAR2);

FUNCTION get_classification_id (p_classification_name VARCHAR2) RETURN NUMBER;

PROCEDURE get_balance_type(p_tax_type in varchar2,
                           p_tax_category in varchar2,
                           p_taxability_rules_date_id in number,
                           p_legislation_code in varchar2,
                           p_classification_id in number);

END pay_us_taxability_rules_pkg;

 

/
