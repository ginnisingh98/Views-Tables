--------------------------------------------------------
--  DDL for Package HXC_TEMPLATE_SUMMARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TEMPLATE_SUMMARY_API" AUTHID CURRENT_USER AS
/* $Header: hxctempsumapi.pkh 120.0 2005/05/29 06:23:01 appldev noship $ */

PROCEDURE DELETE_TEMPLATE
            (
		p_template_id in number
            ) ;
PROCEDURE template_deposit
            (p_blocks	in HXC_BLOCK_TABLE_TYPE,
 	     p_attributes in HXC_ATTRIBUTE_TABLE_TYPE,
	     p_template_id in HXC_TEMPLATE_SUMMARY.TEMPLATE_ID%type
             );
PROCEDURE TEMPLATE_DEPOSIT
(
	p_template_id in hxc_template_summary.template_id%type,
	p_template_ovn in hxc_template_summary.template_ovn%type
);
END HXC_TEMPLATE_SUMMARY_API;

 

/
