--------------------------------------------------------
--  DDL for Package PAY_CA_TAXABILITY_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_TAXABILITY_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: paycaetw.pkh 120.1 2006/02/21 12:13:28 ssouresr noship $ */
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


    Name        : pay_ca_taxability_rules_pkg

    Description : This package holds building blocks used in maintenace
                  of Canadian taxability rules using PAY_TAXABILITY_RULES
                  table.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    NOV-11-1993 RMAMGAIN      1.0                Created with following proc.
                                                 get_or_update
    05-NOV-05   SSOURESR      115.1              Added tax type PPIP
  */
--

PROCEDURE get_or_update(X_MODE                VARCHAR2,
                        X_CONTEXT             VARCHAR2,
                        X_JURISDICTION        VARCHAR2,
                        X_TAX_CAT             VARCHAR2,
			X_classification_id   NUMBER,
			X_legislation_code    VARCHAR2,
			X_taxability_rules_date_id out nocopy NUMBER,
			X_valid_date_from	in out nocopy DATE,
			X_valid_date_to		in out nocopy DATE,
                        X_session_date          DATE,
                        X_BOX1         IN OUT nocopy VARCHAR2,
                        X_BOX2         IN OUT nocopy VARCHAR2,
                        X_BOX3         IN OUT nocopy VARCHAR2,
                        X_BOX4         IN OUT nocopy VARCHAR2,
                        X_BOX5         IN OUT nocopy VARCHAR2,
                        X_BOX6         IN OUT nocopy VARCHAR2,
			X_BOX7         IN OUT nocopy VARCHAR2,
			X_BOX8         IN OUT nocopy VARCHAR2,
			X_BOX9         IN OUT nocopy VARCHAR2,
			X_BOX10        IN OUT nocopy VARCHAR2);
--
FUNCTION get_classification_id (p_classification_name VARCHAR2) RETURN NUMBER;
--
END pay_ca_taxability_rules_pkg;

 

/
