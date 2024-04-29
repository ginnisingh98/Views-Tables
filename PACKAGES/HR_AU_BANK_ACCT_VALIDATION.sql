--------------------------------------------------------
--  DDL for Package HR_AU_BANK_ACCT_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_BANK_ACCT_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: peauavbk.pkh 120.0.12000000.1 2007/08/17 10:48:21 vamittal noship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1999 Oracle Corporation Australia Ltd.,         *
 *                     Brisbane, Australia.                       *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation          *
 *  Australia Ltd,.                                               *
 *                                                                *
 ****************************************************************** */
/*
 Name        : HR_AU_BANK_ACCT_VALIDATION  (HEADER)

 Description : This package declares a function  to validate
               AU Bank Account Number.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 115.0   03-Aug-07 vamittal             Created
 115.1   09-Aug-07 vamittal   6315194   Header is changed
 ================================================================= */

FUNCTION VALIDATE_ACC_NUM(acc_num VARCHAR2) RETURN VARCHAR2;

END HR_AU_BANK_ACCT_VALIDATION ;

 

/
