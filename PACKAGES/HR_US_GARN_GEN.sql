--------------------------------------------------------
--  DDL for Package HR_US_GARN_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_GARN_GEN" AUTHID CURRENT_USER as
/* $Header: pywatgen.pkh 120.0.12000000.1 2007/01/18 03:19:43 appldev noship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : Garnishment Generator
    Filename    : pywatgen.pkh
    Change List
    -----------
    Date        Name            Vers    Bug No  Description
    ----        ----            ----    ------  -----------
    13-NOV-95   hparicha        40.0    	Created.
    19-DEC-95   jthuring        40.3            Fixed RCS header
    28-MAR-96  hparicha	    40.4		Adding params to allow user entered
					reporting name and description of
					wage attachment elements.
*/

g_template_leg_code     VARCHAR2(30) := 'US';
g_template_leg_subgroup VARCHAR2(30) := NULL;

FUNCTION create_garnishment (	p_garn_name		IN VARCHAR2,
				p_garn_reporting_name	IN VARCHAR2,
				p_garn_description	IN VARCHAR2,
				p_category		IN VARCHAR2,
				p_bg_id			IN NUMBER,
				p_ele_eff_start_date	IN DATE) RETURN NUMBER;

PROCEDURE delete_dedn (p_business_group_id	in number,
			p_ele_type_id		in number,
			p_ele_name		in varchar2,
			p_ele_priority		in number,
			p_ele_info_10		in varchar2 default null,
			p_ele_info_11		in varchar2 default null,
			p_ele_info_12		in varchar2 default null,
			p_ele_info_13		in varchar2 default null,
			p_ele_info_14		in varchar2 default null,
			p_ele_info_15		in varchar2 default null,
			p_ele_info_16		in varchar2 default null,
			p_ele_info_17		in varchar2 default null,
			p_ele_info_18		in varchar2 default null,
			p_ele_info_19		in varchar2 default null,
			p_ele_info_20		in varchar2 default null,
			p_ele_info_5		in varchar2 default null,
			p_ele_info_8		in varchar2 default null,
			p_del_sess_date		in date,
			p_del_val_start_date	in date,
			p_del_val_end_date	in date);

END hr_us_garn_gen;

 

/
