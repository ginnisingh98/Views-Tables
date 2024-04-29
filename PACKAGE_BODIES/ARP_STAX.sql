--------------------------------------------------------
--  DDL for Package Body ARP_STAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_STAX" AS
/* $Header: ARPLSTXB.pls 120.8 2005/09/02 02:32:07 sachandr ship $     */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE EXCEPTIONS                                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/

AR_STAX_FK_ERROR       EXCEPTION;
PRAGMA EXCEPTION_INIT( AR_STAX_FK_ERROR, -2292 );

compile_error EXCEPTION;
PRAGMA EXCEPTION_INIT(compile_error, -6550);

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

TYPE find_tax_exempt_info_rec_type IS RECORD
(
  bill_to_customer_id      NUMBER,
  ship_to_customer_id      NUMBER,
  ship_to_site_id          NUMBER,
  tax_code                 VARCHAR2(50),
  inventory_item_id        NUMBER,
  trx_date                 DATE,
  tax_exempt_flag          VARCHAR2(1),
  insert_allowed           VARCHAR2(10),
  reason_code              VARCHAR2(30),
  certificate              VARCHAR2(80),
  percent_exempt           NUMBER,
  inserted_flag            VARCHAR2(1),
  tax_exemption_id         NUMBER,
  exemption_type           VARCHAR2(30),
  hash_string              VARCHAR2(1000)
);

find_tax_exempt_info_rec find_tax_exempt_info_rec_type;

TYPE find_tax_exempt_info_tbl_type is TABLE of find_tax_exempt_info_rec_type index by
binary_integer;

find_tax_exempt_info_tbl find_tax_exempt_info_tbl_type;

pg_max_index            BINARY_INTEGER :=0;
TABLE_SIZE              BINARY_INTEGER := 65636;
cached_org_id                integer;
cached_org_append            varchar2(100);

/* Bugfix887926 */
c_get_exempt                 integer;

 --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
 PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


/* private procedures */

procedure std_other_error( cursor_id in out NOCOPY number,
                           sql_statement in varchar2 ) is
stmt_len integer;
loop_var integer;
begin
  null;
end std_other_error;

procedure std_compile_error( cursor_id in out NOCOPY number,
                             sql_statement in varchar2 ) is
begin
  null;
end std_compile_error;

/*-------------------------------------------------------------------------+
 | PUBLIC  FUNCTION                                                        |
 |   ins_sales_tax                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function generates a new record in the table: AR_SALES_TAX       |
 |   and returns the SALES_TAX_ID of this new record                   |
 |                                                                         |
 | REQUIRES                                                                |
 |   location_id            CCID of this Location                          |
 |   location_structure_id  Multiflex structure ID in use                  |
 |   total_tax_rate         sum of all components of the tax rate          |
 |   location1_rate         Tax rate for segment 1 of the location         |
 |   location2_rate         Tax rate for segment 2 of the location         |
 |   location3_rate         Tax rate for segment 3 of the location         |
 |   location4_rate         Tax rate for segment 4 of the location         |
 |   location5_rate         Tax rate for segment 5 of the location         |
 |   location6_rate         Tax rate for segment 6 of the location         |
 |   location7_rate         Tax rate for segment 7 of the location         |
 |   location8_rate         Tax rate for segment 8 of the location         |
 |   location9_rate         Tax rate for segment 9 of the location         |
 |   location10_rate        Tax rate for segment 10 of the location        |
 |   from_postal_code       The same location may have multiple rates      |
 |   to_postal_code         assigned to it, depending upon postal code     |
 |   start_date             and transaction date.                          |
 |   end_date                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |   SALES_TAX_ID of the new record                                    |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/


FUNCTION      ins_sales_tax(
              location_id in number,
              location_structure_id in number,
              total_tax_rate in number,
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
              from_postal_code in varchar2,
              to_postal_code in varchar2,
              start_date in date,
              end_date in date) return number IS

  sales_tax_id number;
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN
  -- Stubbed out for R12
 null;

end ins_sales_tax;

/*-------------------------------------------------------------------------+
 | PUBLIC  PROCEDURE                                                       |
 |   implement_transfer_rates                                              |
 |                                                                         |
 | CALLED BY TRIGGER        AR_LOCATION_RATES_ASIU                         |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 |   PL/SQL table: LOCATION_SEGMENT_ID to be populated with the            |
 |   location_segment_id of each row that has changed in the table         |
 |   AR_LOCATION_RATES.                                                    |
 |                                                                         |
 |   The PUBLIC variable: loc_rate is a count of the number of rows in     |
 |   the PL/SQL table: location_segment_id that we can expect and is       |
 |   maintained by the trigger: AR_LOCATION_RATES_BRIU                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |   Will take each distinct location_segment_id used during updates or    |
 |   inserts to the table: AR_LOCATION_RATES and propogate these sales     |
 |   tax rate changes into the table: AR_SALES_TAX                         |
 |                                                                         |
 |   This procedures fires the cursor: sel_cc to find each Location Code   |
 |   Combination that uses a particular location_segment_id and then       |
 |   updates each of the rows in ar_sales_tax for that specific location.  |
 |                                                                         |
 |   To optimise performance of the code a note of every code combination  |
 |   is made so that the same set of records in ar_sales_tax is only ever  |
 |   visited once.                                                         |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 |   If the following Code Combinations were active on a system:           |
 |      CA.SAN MATEO.BELMONT      CCID: 1000,   LOCATIONS: 4.6.8           |
 |      CA.SAN MATEO.FOSTER CITY  CCID: 1001,   LOCATIONS: 4.6.10          |
 |      CA.FREEMONT.FREEMONT      CCID: 1002,   LOCATIONS: 4.12.14         |
 |      FL.MIAMI.MIAMI            CCID: 1003,   LOCATIONS: 16.18.20        |
 |                                                                         |
 |   And the user updates AR_LOCATION_RATES for ( CA, and SAN MATEO )      |
 |   There would be two rows set up by the TRIGGER: AR_LOCATION_RATES_BRIU |
 |   in the PL/SQL table: location_segment_id, these rows would be:        |
 |      location_segment_id(0) = 4                                         |
 |      location_segment_id(1) = 6                                         |
 |   This procedure would fire the cursor: sel_cc which for location 4     |
 |   would return: 3 rows, CCIDS: 1000, 10001, and 1002.                   |
 |   Sales Tax Rate records would then be regenerated for all 3 different  |
 |   location code combinations.                                           |
 |   Cursor sel_cc would then be re-fired for location 6 and return the    |
 |   following two rows: 1000, 1001. Since both of these rows have already |
 |   been updated no further work is required and the procedure completes. |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-Jan-93  Nigel Smith        Created.                               |
 |                                                                         |
 +-------------------------------------------------------------------------*/

PROCEDURE Implement_Transfer_Rates is
  l_transfer_rates_initialised varchar2(5);
  l_transfer_rates_manual varchar2(5);
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN
  -- Stubbed out for R12
  null;
end implement_transfer_rates;

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   enable_triggers / disable_triggers                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Control the execution of database triggers associated with the sales |
 |    tax functions, enabling or disabling there actions.                  |
 |                                                                         |
 |    This is used to enhance performance of certain batch operations      |
 |    such as the Sales Tax Interface programs, when the row by row        |
 |    nature of database triggers would degrade performance of the system  |
 |                                                                         |
 | MODIFIES                                                                |
 |                                                                         |
 | ARP_STAX.triggers_enabled                                               |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

procedure enable_triggers is
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN

  -- Stubbed out for R12
  null;
END enable_triggers;

procedure disable_triggers is
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN

  -- Stubbed out for R12
  null;
END disable_triggers;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   Site_Use_Sales_Tax                                                    |
 |                                                                         |
 | CALLED BY TRIGGER        RA_SITE_USES_BRIU                              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | Find the location CCID for the address used by this site use, and all   |
 | of the segment id's in use by this locaiton code combination.           |
 |                                                                         |
 | Re-Populates AR_SALES_TAX with rate information.                        |
 |                                                                         |
 | MODIFIES                                                                |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/


PROCEDURE Site_Use_Sales_Tax( address_id in number ) IS
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN
  -- Stubbed out for R12
  null;
end site_use_sales_tax;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   Initialise_Transfer_Rates                                             |
 |                                                                         |
 | CALLED BY TRIGGER        AR_LOCATION_RATES_BSIU                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | Initialise the public variable: location_rates_transfer_id with the     |
 | value from the sequence: AR_LOCATION_RATES_TRASNFER_S                   |
 |                                                                         |
 | For each set of inserted or updateed rows in the table AR_LOCATION_RATES|
 | a distinct value is placed in the column: AR_TRANSFER_CONTROL_ID        |
 | When all records have been inserted or updated, the after statement     |
 | trigger: AR_LOCATION_RATES_ASIU fires, and refetchs each of these new   |
 | records across into the table: AR_SALES_TAX                             |
 |                                                                         |
 | This works around the kernel limitation of MUTATING tables.             |
 |                                                                         |
 | MODIFIES                                                                |
 |   Public variable: LOCATION_RATES_TRANSFER_ID                           |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/


PROCEDURE Initialise_Transfer_Rates is
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin

  -- Stubbed out for R12
  null;
end initialise_transfer_rates;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   Populate_Sales_Tax                                                    |
 |                                                                         |
 | CALLED BY TRIGGER        RA_LOCATION_COMBINATIONS_BRIU                  |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | Generate records in the table: AR_SALES_TAX for the new location_CCID   |
 | These records will be derived from multiple records in the table        |
 | AR_LOCATION_RATES.                                                      |
 |                                                                         |
 | For each enabled segment in the "Tax Location Flexfield", find          |
 | every sales tax rate, zip and date range. Note if two rates             |
 | have different, mutually exclusive date or zip code ranges              |
 | then reject this record.                                                |
 |                                                                         |
 | Example:-                                                               |
 |                                                                         |
 | Segment         From    To      Start           End             Tax     |
 | Value           Zip     Zip     Date            Date            Rate    |
 | ------------    -----   ------  ---------       ----------      -----   |
 | CA              A       C       01-JAN-90       31-DEC-90       5       |
 | CA              D       Z       01-JAN-90       31-DEC-90       10      |
 | CA              A       Z       01-JAN-91       31-JAN-91       12      |
 |                                                                         |
 | San Mateo       A       Z       01-JAN-91       31-JAN-91       2       |
 | San Mateo       A       Z       07-JUL-90       07-JUL-90       0       |
 |                                                                         |
 | Foster City     A       Z       01-JAN-91       31-JAN-91       1       |
 | Belmont         A       Z       01-JAN-90       31-JAN-91       3       |
 |                                                                         |
 | If the following flexfield combinations were created, the               |
 | sales tax rate assignments generated would be:-                         |
 |                                                                         |
 | Flexfield Combination    Rate   Start      End        From   To         |
 |                                 Date       Date       Zip    Zip        |
 | ------------------------ -----  ---------  ---------  -----  ------     |
 | CA.San Mateo.Foster City 12+2+1 01-jan-91  31-jan-91  A      Z          |
 | CA.San Mateo.Belmont     12+2+3 01-jan-91  31-jan-91  A      Z          |
 | CA.San Matro.Belmont     5+0+3  07-jul-90  07-jul-90  A      C          |
 | CA.San Matro.Belmont     10+0+3 07-jul-90  07-jul-90  D      Z          |
 |                                                                         |
 | Note.                                                                   |
 |                                                                         |
 | Because CA has two different tax rates in 1990, the first               |
 | for zip codes ( A-C ), the second for zip codes ( D-Z )                 |
 | it must have two separate entries in the sales tax rates table          |
 | whenever assignments are created for 1990.                              |
 |                                                                         |
 | Rate assignments for 1990 are not available for Foster City             |
 | because the city component has no tax rate for this date range          |
 | even though the State and County both have tax rates available.         |
 |                                                                         |
 | Even though CA and Belmont have tax rates available across many         |
 | days in 1990, the County of San Mateo only has a valid rate             |
 | for the 7th July, 1990 so the combined rate assignment is only          |
 | valid for 07-Jul-1990.                                                  |
 |                                                                         |
 | The Same set of restrictions also applies to Zip code ranges.           |
 |                                                                         |
 | Location_ID column to the Code Combinations ID applicable to this       |
 | address.                                                                |
 |                                                                         |
 | In order to do this, it may be necessary to insert new items into       |
 | the tables: AR_LOCATION_VALUES and AR_LOCATION_COMBINATIONS             |
 |                                                                         |
 | REQUIRES                                                                |
 |    Location_CCID         Location ID for ths entry in Sales Tax         |
 |    location_id_segments  1 .. 10, Location_segment_id for each segment  |
 |                          in the location flexfield structure.           |
 |                                                                         |
 | STATEMENT_TYPE                                                          |
 |                                                                         |
 |    INSERT                New Location CCID Created, there will be *NO*  |
 |                          pre-existing sales tax data for this location  |
 |    DELETE                A Locatoin Code Combination has been deleted   |
 |                          purge ununsed sales tax rates.                 |
 |    UPDATE                Existing Data May Exist, some of whic may now  |
 |                          be invalid. Purge Invalid data, creating new   |
 |                          valid data in its place.                       |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

PROCEDURE Populate_Sales_Tax(   statement_type                   in varchar2,
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
                                p_location_id_segment_10 in number ) is
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN

  -- Stubbed out for R12
  null;
end populate_sales_tax;


PROCEDURE propogate_sales_tax IS
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin

  -- Stubbed out for R12
  null;
end propogate_sales_tax;


PROCEDURE Purge_Sales_Tax IS
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin

  -- Stubbed out for R12
  null;
end purge_sales_tax;

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   renumber_tax_lines( customer_trx_id in number )                       |
 |                                                                         |
 | CALLED BY USER EXIT: #AR SALESTAX MODE=UPDATE                           |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Will renumber each Tax line belonging to an invoice so that duplicate |
 |   line numbers no longer exist.                                         |
 |   For Example:- if Original Invoice had the following lines, this       |
 |   procedure would update each of the line numbers to be:-               |
 |                                                                         |
 |             OLD INVOICE                    NEW_INVOICE                  |
 |   1 ITEM LINE                       1 ITEM LINE                         |
 |     1 TAX LINE                        1 TAX LINE                        |
 |     2 TAX LINE                        2 TAX LINE                        |
 |     1 TAX LINE                        3 TAX LINE                        |
 |                                                                         |
 |  Duplicate Line numbers can occur when a header level change is made    |
 |  for an invoice and all but Adhoc Tax lines are deleted and then        |
 |  recalculated.                                                          |
 |                                                                         |
 | REQUIRES: CUSTOMER_TRX_ID                                               |
 |                                                                         |
 | MODIFIES: RA_CUSTOMER_TRX_LINES.LINE_NUMBER                             |
 |                                                                         |
 +-------------------------------------------------------------------------*/

PROCEDURE renumber_tax_lines( customer_trx_id in number,
                              trx_type in varchar2 default 'TAX' ) is
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin

  -- Stubbed out for R12
 null;
end renumber_tax_lines;

FUNCTION FIND_HASH ( TAB_INDEX in out NOCOPY binary_integer, VALUE IN varchar2, nameTable in find_tax_exempt_info_tbl_type) return boolean is
        HASH_VALUE binary_integer;

    begin

  -- Stubbed out for R12
     null;

end FIND_HASH;

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
 |    INVENTORY_ITEM_ID         Item exemptions are if found, used        |
 |    TRX_DATE                  Tax Date for this transaction             |
 |    TAX_CODE                  Tax Code for this transaction             |
 |    TAX_EXEMPT_FLAG           "S"tandard; "E"xempt or "R"equire         |
 |    REASON_CODE               Mandatory for all Exempt transactions     |
 |    CERTIFICATE               Optional, used in Exempt transactions     |
 |    PERCENT_EXEMPT            Exemption, Percentage of Tax that is      |
 |                              Exempt; or NULL if no Exemption is        |
 |                              applicable.                               |
 |    INSERT_ALLOWED            If False and "E" is called but not        |
 |                              valid exemption is on file; this routine  |
 |                              will return an error.                     |
 | RETURNS                                                                |
 |    TAX_EXEMPTION_ID          Foreign Key to "RA_TAX_EXEMPTIONS"        |
 |                              If NULL, this transaction is NOT exempt   |
 |    CERTIFICATE               Certificate Number                        |
 |    REASON                    Reason Code for exemption                 |
 |    INSERTED_FLAG             TRUE if this call forced an insert        |
 |    EXEMPTION_TYPE            CUSTOMER or ITEM                          |
 |                                                                        |
 | DATABASE REQUIREMENTS                                                  |
 |    View: TAX_EXEMPTIONS_QP_V This view must be installed before        |
 |                              this database package can be installed    |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |                                                                        |
 |  17-May-94  Nigel Smith      Created.                                  |
 |  3 Aug, 94  Nigel Smith      BUGFIX: 228807, Exemptions are now        |
 |                              managed by Bill To Customer and Ship      |
 |                              To Site.                                  |
 |    13 Oct 94  Nigel Smith    Bugfix: 227953, Exemptions with No        |
 |                              certificate number were not shown by Order|
 |                              Entry.                                    |
 |    19 Oct 94  Nigel Smith    Bugfix: 244306, Error Validating Address  |
 |                              during order entry; or invoice creation on|
 |                              export orders/invoices that are marked as |
 |                              exempt.                                   |
 |                                                                        |
 +------------------------------------------------------------------------*/


PROCEDURE find_tax_exemption_id(
	bill_to_customer_id	in number,
        ship_to_customer_id     in number,
        ship_to_site_id         in number,
        tax_code                in varchar2,
        inventory_item_id       in number,
        trx_date                in date,
        tax_exempt_flag         in varchar2,
        insert_allowed          in varchar2 default 'TRUE',
        reason_code             in out NOCOPY varchar2,
        certificate             in out NOCOPY varchar2,
        percent_exempt          out NOCOPY number,
        inserted_flag           out NOCOPY varchar2,
        tax_exemption_id        out NOCOPY number,
        exemption_type          out NOCOPY varchar2
                               ) is
  dummy_number          number;
  dummy_varchar2        varchar2(2);
  rows_processed	integer;
  statement		varchar2(1000);
  found_in_cache        boolean := FALSE;
  hash_string           varchar2(1000);
  TABLEIDX              binary_integer;

begin
  -- Stubbed out for R12
  null;
end find_tax_exemption_id;

/*------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                       |
 |   combine_tax_rates                                                    |
 |                                                                        |
 | CALLED BY package upgrade_sales_tax                                    |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   The tax rates will be combined and stored as the sales tax during    |
 |   the upgrade.  The rates are taken from the AR_LOCATION_RATES table   |
 |   and combined as the combination is defined in AR_LOCATION_           |
 |   COMBINATIONS                                                         |
 |                                                                        |
 |                                                                        |
 |                                                                        |
 |   REQUIRES:   no arguments                                             |
 |                                                                        |
 |   MODIFIES:   inserts combined rates into AR_SALES_TAX                 |
 |                                                                        |
 +------------------------------------------------------------------------*/

PROCEDURE combine_tax_rates IS
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin

  -- Stubbed out for R12
  null;
end combine_tax_rates;


PROCEDURE populate_segment_array( loc_segment_id in number ) is
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin

  -- Stubbed out for R12
  null;
end populate_segment_array;

/*------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                       |
 |   close_open_cusor                                                     |
 |                                                                        |
 | CALLED BY package arp_process_tax.calculate_tax_f_sql                  |
 |                                                                        |
 | DESCRIPTION                                                            |
 |    Close all open cursor opened in this file before the end of tax     |
 |    calculation.                                                        |
 |                                                                        |
 +------------------------------------------------------------------------*/
PROCEDURE close_open_cursor IS
BEGIN
  -- Stubbed out for R12
  null;
END close_open_cursor;

/* global package initialization */

BEGIN
  -- Stubbed out for R12
  null;

END ARP_STAX;

/
