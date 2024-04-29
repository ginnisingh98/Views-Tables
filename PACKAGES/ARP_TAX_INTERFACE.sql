--------------------------------------------------------
--  DDL for Package ARP_TAX_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TAX_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: ARPLTXIS.pls 115.5 2002/02/12 15:53:49 pkm ship      $ */

/*---------------------------------------------------------------------------+
 |                                                                           |
 | PUBLIC EXCEPTIONS                                                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | PUBLIC DATATYPES                                                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | PUBLIC VARIABLES                                                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/

   override_rates BOOLEAN := FALSE;      -- Override tax existing tax rates

/*---------------------------------------------------------------------------+
 |                                                                           |
 | PUBLIC FUNCTIONS                                                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | PUBLIC PROCEDURES                                                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/

PROCEDURE Upload_Sales_Tax( commit_on_each_senior_segment in varchar2 default 'Y',
			    change_control     in varchar2 default 'N',
                            default_start_date in date default to_date( '01-01-1900', 'dd-mm-yyyy'),
			    senior_segment in varchar2 default null,
			    max_error_count in number default 1000 )  ;

END ARP_TAX_INTERFACE;

 

/
