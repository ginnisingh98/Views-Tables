--------------------------------------------------------
--  DDL for Package HR_AU_PER_PAY_METHOD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_PER_PAY_METHOD_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peaulhpp.pkh 120.0.12000000.1 2007/08/17 10:48:30 vamittal noship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1999 Oracle Corporation Australia Ltd.,         *
 *                     Brisbane, Australia.                       *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  the material is also     *
 *  protected by copyright law.  no part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation          *
 *  Australia Ltd,.                                               *
 *                                                                *
 ******************************************************************/

/*

	Filename: hraulhpp.pkb (BODY)
        Author: Varun Mittal
 	Description: Creates the user hook seed data for the AU legislation
                     validation in HR_PERSONAL_PAYMENT_METHOD_API.


 	Change List
 	-----------

 	Version Date      Author     ER/CR No. Description of Change
 	-------+---------+-----------+---------+--------------------------
 	115.0   06-Aug-07  vamittal   6315194   Initial Version
	115.1   09-Aug-07  vamittal   6315194   Header is changed

 ================================================================= */


 PROCEDURE VALIDATE_BANK_ACCT (p_segment2	IN VARCHAR2);

END HR_AU_PER_PAY_METHOD_LEG_HOOK;

 

/
