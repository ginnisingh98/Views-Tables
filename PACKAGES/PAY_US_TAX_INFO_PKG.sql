--------------------------------------------------------
--  DDL for Package PAY_US_TAX_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusgjit.pkh 115.2 99/07/17 06:44:19 porting ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1997 Oracle Corporation US Ltd.,                *
 *                                                                *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation US Ltd.  *
 *  								  *
 *                                                                *
 ******************************************************************
 Name        : pay_us_tax_info_pkg (HEADER)
 File        : pyusgjit.pkh
 Description : This package declares procedures which are used
               for any jurisdiction specific tax information
               stored on the database.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 40.0    07-DEC-97 lwthomps             Date Created
 40.1/
 110.1   08-DEC-98 rthirlby   735626	Added get_tax_exist. Used
                                        in state balance views.
 =================================================================
*/

FUNCTION get_sit_exist (p_state_abbrev    varchar2,
                        p_date            DATE)
                        return boolean;

FUNCTION get_lit_exist ( p_tax_type	       	varchar2,
			 p_jurisdiction_code   	varchar2,
			 p_date		        date)
			 return boolean;

FUNCTION get_tax_exist ( p_tax_type	       	varchar2,
			 p_jurisdiction_code   	varchar2,
                         p_ee_or_er		varchar2,
			 p_date		        date)
			 return varchar2;

PRAGMA RESTRICT_REFERENCES(get_tax_exist, WNDS, WNPS);


end pay_us_tax_info_pkg;

 

/
