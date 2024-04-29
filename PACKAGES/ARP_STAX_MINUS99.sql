--------------------------------------------------------
--  DDL for Package ARP_STAX_MINUS99
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_STAX_MINUS99" AUTHID DEFINER /*NOSYNC*/ AS
/* $Header: ARPLXSTX.txt 115.6 2004/04/30 11:34:24 rpalani noship $   */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  EXCEPTIONS                                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  DATATYPES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/


TYPE TAB_ID_TYPE    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC VARIABLES                                                        |
 |                                                                         |
 |    PUBLIC VARIABLES ARE ONLY SUPPORTED SERVER SIDE, WITHIN PL/SQL 2.    |
 |    CLIENT APPLICATIONS, FOR EXAMPLE: SRW20 and FORMS40 CAN ONLY ACCESS  |
 |    THEIR VALUES THROUGH COVER FUNCTIONS.                                |
 |                                                                         |
 | VARIABLE: triggers_enabled                                              |
 |    If set to true, (default) row and statement table triggers will      |
 |    fire on each of tables associated with Receivables Sales Tax         |
 |                                                                         |
 | VARIABLE: location_rate_transfer_id                                     |
 |    This is a counter which gives the next index to use on the PL/SQL    |
 |    table: location_segment_id.  This is incremented by the trigger      |
 |    AR_LOCATION_RATES_BRIU, and reset to zero by the triggers:           |
 |    AR_LOCATION_RATES_BSIU, and AR_LOCATION_RATES_BRIU                   |
 |                                                                         |
 | VARIABLE: location_segment_id                                           |
 |    Used by the trigger on AR_LOCATION_RATES_BRIU and provides a table   |
 |    of used location_segment_ids, which can then be populated on mass by |
 |    the trigger: AR_LOCATION_RATES_ASIU - this works around the database |
 |    restriction: Mutating tables.                                        |
 |                                                                         |
 | VARIABLE: empty_id_table                                                |
 |    This public variable is used to release the memory of a populated    |
 |    PL/SQL array once all of the rows have been processed.  By assigning |
 |    this empty array to a used array, all of the elements in the used    |
 |    array get deleted from memory.                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/


triggers_enabled                BOOLEAN := TRUE;

transfer_rates_initialised	BOOLEAN := FALSE;
transfer_rates_manual		BOOLEAN := FALSE;

location_rates_transfer_id      NUMBER;

location_segment_id             TAB_ID_TYPE;

empty_id_table                  TAB_ID_TYPE;

loc_rate                        NUMBER;


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC PROCEDURES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/


PROCEDURE Purge_Sales_Tax ;

PROCEDURE Site_Use_Sales_Tax( address_id in number ) ;

PROCEDURE Initialise_Transfer_Rates;

PROCEDURE Implement_Transfer_Rates;

PROCEDURE Populate_Sales_Tax(   statement_type         in varchar2,
                                location_ccid          in number,
                                p_location_id_segment_1  in number,
                                p_location_id_segment_2  in number,
                                p_location_id_segment_3  in number,
                                p_location_id_segment_4  in number,
                                p_location_id_segment_5  in number,
                                p_location_id_segment_6  in number,
                                p_location_id_segment_7  in number,
                                p_location_id_segment_8  in number,
                                p_location_id_segment_9  in number,
                                p_location_id_segment_10 in number ) ;

PROCEDURE Propogate_sales_tax;


PROCEDURE enable_triggers;

PROCEDURE disable_triggers;

PROCEDURE renumber_tax_lines( customer_trx_id in number,
                              trx_type in varchar2 default 'TAX' );

PROCEDURE combine_tax_rates;

/*------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                       |
 |   find_tax_exemption_id                                                |
 |                                                                        |
 | CALLED BY sales tax engine                                             |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   Each transaction line may be forced exempt from taxes by the user.   |
 |   When exempted; "find_tax_exemption_id" is called, passing in the     |
 |   Exemption Certificate Number and Reason Code. If no "Unapproved",    |
 |   "Manual" or "Primary" Exemption exists for this Customer, Location,  |
 |   Tax Code and Reason this routine will optionally create an Automatic |
 |   exemption with a status of "Unapproved" and a location that matches  |
 |   the flexfield qualifier: "EXEMPT_LEVEL".                             |
 |                                                                        |
 | REQUIRES                                                               |
 |    BILL TO_CUSTOMER_ID	Bill To Customer ID (mandatory)           |
 |    SHIP_TO_CUSTOMER_ID	Ship To Customer ID                       |
 |    SHIP_TO_SITE_ID           Identifies the ship to site from which we |
 |                              can deduce the State, County and City     |
 |                              Or other segments applicable to the sales |
 |                              tax location flexfield.                   |
 |    INVENTORY_ITEM_ID	        Item exemptions are if found, used        |
 |    TRX_DATE			Tax Date for this transaction             |
 |    TAX_CODE                  Tax Code for this transaction             |
 |    TAX_EXEMPT_FLAG 		"S"tandard; "E"xempt or "R"equire         |
 |    REASON_CODE		Mandatory for all Exempt transactions     |
 |    CERTIFICATE		Optional, used in Exempt transactions     |
 |    PERCENT_EXEMPT		Exemption, Percentage of Tax that is      |
 |                              Exempt; or NULL if no Exemption is        |
 |                              applicable.                               |
 |    INSERT_ALLOWED		If False and "E" is called but not        |
 |                              valid exemption is on file; this routine  |
 |                              will return an error.                     |
 | RETURNS                                                                |
 |    TAX_EXEMPTION_ID		Foreign Key to "RA_TAX_EXEMPTIONS"        |
 |				If NULL, this transaction is NOT exempt   |
 |    CERTIFICATE		Certificate Number                        |
 |    REASON			Reason Code for exemption                 |
 |    INSERTED_FLAG		TRUE if this call forced an insert        |
 |    EXEMPTION_TYPE		CUSTOMER or ITEM			  |
 |                                                                        |
 | DATABASE REQUIREMENTS                                                  |
 |    View: TAX_EXEMPTIONS_QP_V This view must be installed before        |
 |                              this database package can be installed    |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | 17 May, 1994  Nigel Smith	Created.                                  |
 |  3 Aug, 1994  Nigel Smith    BUGFIX: 228807, Exemptions are now        |
 |                              managed by Bill To Customer and Ship      |
 |                              To Site.                                  |
 |                                                                        |
 +------------------------------------------------------------------------*/


PROCEDURE find_tax_exemption_id(
	bill_to_customer_id	in number,
	ship_to_customer_id	in number,
	ship_to_site_id		in number,
	tax_code		in varchar2,
	inventory_item_id	in number,
	trx_date		in date,
        tax_exempt_flag         in varchar2,
	insert_allowed		in varchar2 default 'TRUE',
	reason_code		in out NOCOPY varchar2,
	certificate		in out NOCOPY varchar2,
	percent_exempt		out NOCOPY number,
	inserted_flag		out NOCOPY varchar2,
	tax_exemption_id	out NOCOPY number,
	exemption_type		out NOCOPY varchar2

				);

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC FUNCTIONS                                                        |
 |                                                                         |
 +-------------------------------------------------------------------------*/


FUNCTION ins_sales_tax( location_id           in number,
                        location_structure_id in number,
                        total_tax_rate        in number,
                        location1_rate        in number,
                        location2_rate        in number,
                        location3_rate        in number,
                        location4_rate        in number,
                        location5_rate        in number,
                        location6_rate        in number,
                        location7_rate        in number,
                        location8_rate        in number,
                        location9_rate        in number,
                        location10_rate       in number,
                        from_postal_code      in varchar2,
                        to_postal_code        in varchar2,
                        start_date            in date,
                        end_date              in date )
                 return number;

PROCEDURE populate_segment_array( loc_segment_id in number );

END ARP_STAX_MINUS99;

 

/
