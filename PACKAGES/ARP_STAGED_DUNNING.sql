--------------------------------------------------------
--  DDL for Package ARP_STAGED_DUNNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_STAGED_DUNNING" AUTHID CURRENT_USER AS
/* $Header: ARCUSDLS.pls 115.5 2002/11/15 02:29:02 anukumar ship $ */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  CONSTANTS                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

MAX_STAGED_DUNNING	constant NUMBER := 20;

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  TYPES                                                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

--  to store site information
/* 2107939
Added the include_payments field. */

  TYPE  site_type IS RECORD
        (
	site_use_id	    VARCHAR2(40)
	,customer_id	    VARCHAR2(40)
	,dunning_level      VARCHAR2(1)
	,payment_grace_days VARCHAR2(10)
	,grace_days   	    VARCHAR2(1)
	,include_payments   VARCHAR2(1)
	,dun_disputed_items VARCHAR2(1)
	,letter_set_id	    VARCHAR2(16)
         );

-- to store parameter information
  TYPE parameter_type IS RECORD
	(
	dunning_level_from     NUMBER(2)
	,dunning_level_to      NUMBER(2)
	,dun_date	       VARCHAR2(20)
	,transaction_type_from VARCHAR2(21)
	,transaction_type_to   VARCHAR2(21));

-- type to store letter id information
  TYPE 	letter_id_tab IS TABLE OF
	ar_dunning_letter_set_lines.dunning_letter_id%TYPE
	INDEX BY BINARY_INTEGER;

/*-------------------------------------------------------------------------+
 |									   |
 |                                                                         |
 | PUBLIC  VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

  site		site_type;
  parameter	parameter_type;
  letter_tab	letter_id_tab;

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  FUNCTIONS                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/



/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    staged_dunning( site         IN site_type		             	      |
 |		     ,parameter    IN parameter_type		              |
 |    		     ,letter_tab   IN OUT NOCOPY letter_id_tab          	      |
 |		     ,letter_count IN OUT NOCOPY NUMBER                              |
 |                   ,single_letter_flag IN VARCHAR2) RETURN BOOLEAN          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Given an input list of parameters for a customer/site, get dunning let- |
 |    ters for on which the open payment  schedules of this customer/site will|
 |    be printed. Return FALSE if NO letter could be found                    |
 |                                                                            |
 |                                                                            |
 | MODIFIES                                                                   |
 |    letter_tab  store dunning letter information                            |
 |    letter_count number of dunning letters found			      |
 |                                                                            |
 | RETURNS                                                                    |
 |    TRUE   - no ORACLE error                                                |
 |    FALSE  - ORACLE error occured    or more than MAX_STAGED_DUNNING found  |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |    7/31/95  Christine Vogel  Created                                       |
 |    8/7/96   Paul Rooney      Modified to accept single_letter_flag         |
 |    8/25/96  Simon Jou        Modified for staged dunning/credit memo       |
 *----------------------------------------------------------------------------*/

FUNCTION staged_dunning( site         IN site_type
		        ,parameter    IN parameter_type
			,letter_tab   IN OUT NOCOPY letter_id_tab
			,letter_count IN OUT NOCOPY NUMBER
                        ,single_letter_flag VARCHAR2) RETURN BOOLEAN ;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    get_cpa( site		  IN site_type                                |
 |	      ,curr_code	  IN VARCHAR2				      |
 |	      ,min_dun_amount	  IN OUT NOCOPY NUMBER				      |
 |	      ,min_dun_inv_amount IN OUT NOCOPY NUMBER ) RETURN BOOLEAN	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    for a given customer/site and currency get the minimum dunning amount   |
 |    and minimum dunning invoice amount				      |
 |									      |
 | MODIFIES								      |
 |    min_dun_amount     store the amount found				      |
 |    min_dun_inv_amount store amount found				      |
 |									      |
 | RETURNS                                                                    |
 |    TRUE  if no error occured                                               |
 |    FALSE else							      |
 |                                                                            |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |  7/31/95  Christine Vogel  Created                                         |
 |                                                                            |
 *----------------------------------------------------------------------------*/


FUNCTION get_cpa( site			IN site_type
		,curr_code		IN VARCHAR2
		,min_dun_amount		OUT NOCOPY NUMBER
		,min_dun_inv_amount	OUT NOCOPY NUMBER) RETURN BOOLEAN;


/*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                           |
 |    get_new_dunning_level( ps_id		     IN NUMBER                |
 |	                    ,staged_dunning_level    IN OUT NOCOPY NUMBER            |
 |			    ,current_dun_date        IN DATE		      |
 |	                    ,last_dunning_level_override_date  IN DATE        |
 |                          ,days_late IN NUMBER                              |
 |                          ,letter_set_id IN NUMBER ) RETURN BOOLEAN         |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    for a payment schedule get the new dunning level. The user has the      |
 |    possibility to update the dunning level. Thatfore , dunning level can   |
 |    not be increased by 1 with every printing of a dunning letter	      |
 |									      |
 |									      |
 | RETURNS                                                                    |
 |    TRUE if open payment should be dunned, else return FALSE                |
 |									      |
 | MODIFIES								      |
 |    staged_dunning_level						      |
 |                                                                            |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |  7/31/95  Christine Vogel  Created                                         |
 |  8/25/96  Simon Jou        Modified for staged dunning/credit memo         |
 |                                                                            |
 *----------------------------------------------------------------------------*/


FUNCTION get_new_dunning_level(ps_id	   IN NUMBER
		  ,staged_dunning_level    IN OUT NOCOPY NUMBER
		  ,current_dun_date	   IN DATE
		  ,dunning_level_override_date  IN DATE
                  ,days_late IN NUMBER
                  ,o_letter_set_id IN NUMBER ) RETURN BOOLEAN;


END ARP_STAGED_DUNNING;

 

/
