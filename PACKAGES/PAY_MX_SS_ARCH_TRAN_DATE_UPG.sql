--------------------------------------------------------
--  DDL for Package PAY_MX_SS_ARCH_TRAN_DATE_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_SS_ARCH_TRAN_DATE_UPG" AUTHID CURRENT_USER as
/* $Header: paymxsstrandtupg.pkh 120.0.12000000.1 2007/05/02 10:06:39 sdahiya noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004, Oracle India Pvt. Ltd., Hyderabad         *
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
    Package Name        : PAY_MX_SS_ARCH_TRAN_DATE_UPG
    Package File Name   : paymxsstrandtupg.pkh

    Description : Used for Social Security Archiver upgrade for transaction
                  date.

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sdahiya       24-Jan-2007 115.0           Created.
   ***************************************************************************/


  /****************************************************************************
    Name        : QUAL_PROC
    Description : Qualifying procedure for generic upgrade process.
  *****************************************************************************/
PROCEDURE QUAL_PROC
(
    P_OBJECT_ID NUMBER,
    P_QUAL      OUT NOCOPY VARCHAR2
);


  /****************************************************************************
    Name        : UPG_PROC
    Description : Upgrade procedure for generic upgrade process.
  *****************************************************************************/
PROCEDURE UPG_PROC
(
    P_OBJECT_ID NUMBER
);


END PAY_MX_SS_ARCH_TRAN_DATE_UPG;

 

/
