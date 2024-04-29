--------------------------------------------------------
--  DDL for Package Body ARP_STAX_MINUS99
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_STAX_MINUS99" AS
/*  $Header: ARPLXSTX.txt 115.6 2004/04/30 11:34:24 rpalani noship $      */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE EXCEPTIONS                                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/

AR_STAX_FK_ERROR       EXCEPTION;
PRAGMA EXCEPTION_INIT( AR_STAX_FK_ERROR, -2292 );

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/
TYPE tax_exempt_info_rec_type IS RECORD
(
percent_exempt          NUMBER,
tax_exemption_id        NUMBER,
tax_exempt_reason_code  VARCHAR2(30),
tax_exempt_number       VARCHAR2(80),
bill_to_customer_id     NUMBER,
ship_to_site_use_id     NUMBER,
tax_code                VARCHAR2(50),
status_code             VARCHAR2(30),
start_date              DATE,
end_date                DATE
);

tax_exempt_info_rec tax_exempt_info_rec_type;

TYPE tax_exempt_info_rec_tbl is TABLE of tax_exempt_info_rec_type index by
binary_integer;

tax_exempt_info_tbl tax_exempt_info_rec_tbl;

pg_max_index            BINARY_INTEGER :=0;

--PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

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

CURSOR ar_sales_tax_s_c is
        select ar_sales_tax_s.nextval + arp_standard.sequence_offset
        from dual;

sales_tax_id NUMBER;


BEGIN
 --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
 PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug( '>> INS_SALES_TAX' );
  END IF;

        OPEN ar_sales_tax_s_c;
        FETCH ar_sales_tax_s_c into sales_tax_id;
        CLOSE ar_sales_tax_s_c;

              insert into ar_sales_tax(
              SALES_TAX_ID,
              LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
              CREATED_BY, CREATION_DATE,
              LOCATION_ID,
              rate_context,
              tax_rate,
              LOCATION1_RATE,
 LOCATION2_RATE,
 LOCATION3_RATE,
              from_postal_code,
              to_postal_code,
              start_date,
              end_date,
              enabled_flag)
              VALUES
              (
              sales_tax_id,
              sysdate,
              arp_standard.profile.user_id,
              null,
              arp_standard.profile.user_id,
              sysdate,
              location_id,
              location_structure_id,
              total_tax_rate,
              LOCATION1_RATE,
 LOCATION2_RATE,
 LOCATION3_RATE,
              from_postal_code,
              to_postal_code,
              start_date,
              end_date,
              'Y');
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug( '<< INS_SALES_TAX:' || sales_tax_id );
     END IF;
        return(sales_tax_id);
END ins_sales_tax;


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


cursor  sel_cc( location_segment_id in number ) IS
        select
               struct.location_id location_ccid,
               struct.location_id_segment_1,
               struct.location_id_segment_2,
               struct.location_id_segment_3,
               struct.location_id_segment_4,
               struct.location_id_segment_5,
               struct.location_id_segment_6,
               struct.location_id_segment_7,
               struct.location_id_segment_8,
               struct.location_id_segment_9,
               struct.location_id_segment_10
        from   ar_location_combinations struct
        where  LOCATION_ID_SEGMENT_1 = location_segment_id
 or LOCATION_ID_SEGMENT_2 = location_segment_id
 or LOCATION_ID_SEGMENT_3 = location_segment_id;   -- PL/SQL Flexfield Pre-Processor
                                            -- Refer to token file: token.pls

i                number;
j                number;
k                number;

location_ccid    TAB_ID_TYPE;
ccids            NUMBER := 0;
do_transfer_flag BOOLEAN;
BEGIN

  --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '>> IMPLEMENT_TRANSFER_RATES' );
END IF;

   if not transfer_rates_initialised
   then
 arp_standard.fnd_message( 'AR_TRIG_NOT_INITIALISED', 'TRIGGER', 'LOCATION_RATES' );

   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug( '>> AR TRIGGER LOCATION RATES NOT INITIALIZED' );
   END IF;

   end if;
   transfer_rates_initialised := FALSE;
   transfer_rates_manual := FALSE;

   /*------------------------------------------------------------------------+
    | For each distinct location_segment_id that had a rate insert or update |
    | assocaited with it, find each distinct location_ccid and update        |
    | the table: AR_SALES_TAX for this location_ccid, updating rate          |
    | assignments                                                            |
    +------------------------------------------------------------------------*/

   FOR i in 1 .. loc_rate
   LOOP
      IF location_segment_id( i ) is not null
      THEN

         /*------------------------------------------------------------------+
          | We may have updated or inserted rates for this location multiple |
          | times, in which case find any occurances of this location in the |
          | array and reset this element to null so that we do not repeat    |
          | any work.                                                        |
          +------------------------------------------------------------------*/

         FOR j in i+1 .. loc_rate
         LOOP
            IF location_segment_id( i ) = location_segment_id( j )
            THEN
               location_segment_id( j ) := null;
            END IF;
         END LOOP;

         /*------------------------------------------------------------------+
          | Update the Sales Tax table for this location, deleting any       |
          | invalid rates, adding any new ones.                              |
          +------------------------------------------------------------------*/

         FOR rates in sel_cc(  location_segment_id(i) )
         LOOP

            /*---------------------------------------------------------------+
             | Confirm that this location_ccid has not been updated before   |
             +---------------------------------------------------------------*/

            do_transfer_flag := TRUE;

            FOR k in 1 .. ccids
            LOOP
               if ( rates.location_ccid = location_ccid(k) )
               THEN
                  do_transfer_flag := FALSE; /* Already done */
               END IF;
               EXIT WHEN do_transfer_flag = FALSE;
            END LOOP;

            IF do_transfer_flag
            THEN
               Populate_Sales_Tax( 'Update',
                                   rates.location_ccid,
                                   rates.location_id_segment_1,
                                   rates.location_id_segment_2,
                                   rates.location_id_segment_3,
                                   rates.location_id_segment_4,
                                   rates.location_id_segment_5,
                                   rates.location_id_segment_6,
                                   rates.location_id_segment_7,
                                   rates.location_id_segment_8,
                                   rates.location_id_segment_9,
                                   rates.location_id_segment_10 );
                ccids := ccids + 1;
                location_ccid( ccids ) := rates.location_ccid;
             END IF;
         END LOOP;
      END IF;
      location_segment_id(i) := NULL; /* Once this is used, clear it down */
   END LOOP;

IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '<< IMPLEMENT_TRANSFER_RATES: ' || ccids );
END IF;

END Implement_Transfer_Rates;


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
begin
   triggers_enabled := TRUE;
end;



procedure disable_triggers is
begin
   triggers_enabled := FALSE;
end;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   Site_Use_Sales_Tax                                                    |
 |                                                                         |
 | CALLED BY TRIGGER        RA SITE_USES_BRIU                              |
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

cursor  sel_cc( address_id in number) is
        select
               struct.location_id location_ccid,
               struct.location_id_segment_1,
               struct.location_id_segment_2,
               struct.location_id_segment_3,
               struct.location_id_segment_4,
               struct.location_id_segment_5,
               struct.location_id_segment_6,
               struct.location_id_segment_7,
               struct.location_id_segment_8,
               struct.location_id_segment_9,
               struct.location_id_segment_10
        from   ar_location_combinations struct,
               hz_party_sites party_site,
               hz_loc_assignments loc_assign,
               hz_locations loc,
               hz_cust_acct_sites acct_site
        where  struct.location_id = loc_assign.loc_id
          and  acct_site.party_site_id = party_site.party_site_id
          and  loc.location_id = party_site.location_id
          and  loc.location_id = loc_assign.location_id
          and  NVL(ACCT_SITE.ORG_ID, -99)  =  NVL(LOC_ASSIGN.ORG_ID, -99);

        cc              sel_cc%ROWTYPE;
BEGIN
  -- PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug( '>> SITE_USE_SALES_TAX( ' || address_id || ' )' );
  END IF;

        OPEN sel_cc( address_id );
        FETCH sel_cc into cc;
        CLOSE sel_cc;

        Populate_Sales_Tax(   'Update',
                                cc.location_ccid          ,
                                cc.location_id_segment_1  ,
                                cc.location_id_segment_2  ,
                                cc.location_id_segment_3  ,
                                cc.location_id_segment_4  ,
                                cc.location_id_segment_5  ,
                                cc.location_id_segment_6  ,
                                cc.location_id_segment_7  ,
                                cc.location_id_segment_8  ,
                                cc.location_id_segment_9  ,
                                cc.location_id_segment_10 ) ;

  IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '<< SITE_USE_SALES_TAX' );
 END IF;

END;



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
BEGIN
   --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
   PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
   if transfer_rates_initialised
   then
      arp_standard.fnd_message( 'AR_TRIG_ALREADY_INITIALISED', 'TRIGGER', 'LOCATION_RATES' );

IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('AR_TRIGGER LOCATION RATES ALREADY EXIST');
END IF;

   end if;

   loc_rate := 0;
   ARP_STAX_MINUS99.location_segment_id := ARP_STAX_MINUS99.empty_id_table;
   transfer_rates_initialised := TRUE;

END Initialise_Transfer_Rates;







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
--
cursor sel_bad_rates( p_location_id in number,
                      p_location_id_segment_1 in number,
                      p_location_id_segment_2 in number,
                      p_location_id_segment_3 in number,
                      p_location_id_segment_4 in number,
                      p_location_id_segment_5 in number,
                      p_location_id_segment_6 in number,
                      p_location_id_segment_7 in number,
                      p_location_id_segment_8 in number,
                      p_location_id_segment_9 in number,
                      p_location_id_segment_10 in number ) is

select  rowid, sales_tax_id
from    ar_sales_tax tax
where   tax.location_id = p_location_id
and     tax.enabled_flag = 'Y'
and     not exists (
        select
        'x'
        from   ar_location_rates r1,
 ar_location_rates r2,
 ar_location_rates r3
        where  r1.location_segment_id = p_location_id_segment_1
 and r2.location_segment_id = p_location_id_segment_2
 and r3.location_segment_id = p_location_id_segment_3
        And    R1.FROM_POSTAL_CODE <= TAX.FROM_POSTAL_CODE
 AND R2.FROM_POSTAL_CODE <= TAX.FROM_POSTAL_CODE
 AND R3.FROM_POSTAL_CODE <= TAX.FROM_POSTAL_CODE
	And    R1.TO_POSTAL_CODE <= TAX.TO_POSTAL_CODE
 AND R2.TO_POSTAL_CODE <= TAX.TO_POSTAL_CODE
 AND R3.TO_POSTAL_CODE <= TAX.TO_POSTAL_CODE
        And    R1.START_DATE <= TAX.START_DATE
 AND R2.START_DATE <= TAX.START_DATE
 AND R3.START_DATE <= TAX.START_DATE
   	And    R1.END_DATE <= TAX.END_DATE
 AND R2.END_DATE <= TAX.END_DATE
 AND R3.END_DATE <= TAX.END_DATE
        and    tax.location1_rate = decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1)
 and tax.location2_rate = decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2)
 and tax.location3_rate = decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3)
        and    tax.from_postal_code      = greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code )
        and    tax.to_postal_code        = least( r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code )
        and    tax.start_date            = greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  )
        and    tax.end_date              = least( r1.end_date ,
 r2.end_date ,
 r3.end_date  )
        and    greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code ) <= least( r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code )
        and    greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  ) <= least( r1.end_date ,
 r2.end_date ,
 r3.end_date  ));

--
CURSOR RateUsed( p_sales_tax_id IN NUMBER ) IS
SELECT  'x' from dual
WHERE   exists (
        select 'x'
        from   ra_customer_trx_lines l
        where  l.sales_tax_id = p_sales_tax_id );
--
        dummy	varchar2(30);
--
BEGIN
 --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
 PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug( '>> POPULATE_SALES_TAX ( ' || statement_type || ', '
                                          || location_ccid  || ' )' );
  END IF;

   /*------------------------------------------------------------------------+
    | Validate every sales tax rate assignment for this location, ensuring   |
    | that valid location_rates still exist.                                 |
    | If any rate is no longer valid, attempt to delete the record, and if   |
    | this fails, disable the record so that it will not be available for    |
    | future use.                                                            |
    |                                                                        |
    | This is only applicable is we are updating existing locations, simply  |
    | defining new locations means that there can be no records in the       |
    | sales tax table.                                                       |
    +------------------------------------------------------------------------*/

   IF statement_type = 'Update' or statement_type = 'Delete'
   THEN
      FOR tax_rate_rec in sel_bad_rates(
          location_ccid, p_location_id_segment_1, p_location_id_segment_2, p_location_id_segment_3,
                         p_location_id_segment_4, p_location_id_segment_5, p_location_id_segment_6,
                         p_location_id_segment_7, p_location_id_segment_8, p_location_id_segment_9,
                         p_location_id_segment_10 )
      LOOP
      BEGIN
        OPEN RateUsed( tax_rate_rec.sales_tax_id );
--
        FETCH RateUsed
        INTO  dummy;
--
--      If rate not used cursor does not return a row
--      This means the sales tax is NOT used,
--      So we can delete it.
--
        IF RateUsed%NOTFOUND THEN
--
          DELETE FROM ar_sales_tax
          WHERE rowid = tax_rate_rec.rowid;
--
        ELSE
--
--      If rate not used cursor returns a row
--      This means the sales tax is being used,
--      So we do not want to delete it,intead, set enabled to 'N'
--      (This part is added because the AR foreign key constraint
--       is not shipped to customers )
--
          UPDATE ar_sales_tax SET enabled_flag = 'N',
                                  last_update_date = sysdate,
                                  last_updated_by  = arp_standard.profile.user_id
          WHERE rowid = tax_rate_rec.rowid;
        END IF;
        CLOSE RateUsed;
      END ;
      END LOOP;
   END IF;


   /*-----------------------------------------------------------------------+
    | Generate new sales tax records, by combining location rates from each |
    | of the segment values of the location flexfield.                      |
    | Only location rates that do not already exist in the ar_sales_tax     |
    | table are inserted.                                                   |
    +-----------------------------------------------------------------------*/

  IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( 'I: Populate_sales_tax: ' || p_location_id_segment_1 || ' ' ||
                                       p_location_id_segment_2 || ' ' ||
                                       p_location_id_segment_3 || ' ' ||
                                       p_location_id_segment_4 );
  END IF;


   IF statement_type <> 'Delete'
   THEN

      if statement_type = 'Update'
      THEN

      insert into ar_sales_tax(
              SALES_TAX_ID,
              LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
              CREATED_BY, CREATION_DATE,
              LOCATION_ID,
              rate_context,
              tax_rate,
              LOCATION1_RATE,
 LOCATION2_RATE,
 LOCATION3_RATE,
              from_postal_code,
              to_postal_code,
              start_date,
              end_date,
              enabled_flag)
           select
              AR_SALES_TAX_S.NEXTVAL+arp_standard.sequence_offset,
              sysdate,
              arp_standard.profile.user_id,
              null,
              arp_standard.profile.user_id,
              sysdate,
              location_ccid,
              arp_standard.sysparm.location_structure_id,
              decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1)
 + decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2)
 + decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3),
              decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1),
 decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2),
 decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3),
              greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code ),
              least(    r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code ),
              greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  ),
              least(    r1.end_date ,
 r2.end_date ,
 r3.end_date  ),
              'Y' /* Enabled Flag */
        from   ar_location_rates r1,
 ar_location_rates r2,
 ar_location_rates r3
        where  r1.location_segment_id = p_location_id_segment_1
 and r2.location_segment_id = p_location_id_segment_2
 and r3.location_segment_id = p_location_id_segment_3
        and    greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code ) <= least( r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code )
        and    greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  ) <= least( r1.end_date ,
 r2.end_date ,
 r3.end_date  )
        and    not exists (
        select 'x' from ar_sales_tax tax
        where   tax.location_id = location_ccid
        and     tax.location1_rate = decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1)
 and tax.location2_rate = decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2)
 and tax.location3_rate = decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3)
        and     tax.from_postal_code = greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code )
        and     tax.to_postal_code = least( r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code )
        and     tax.start_date = greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  )
        and     tax.end_date = least( r1.end_date ,
 r2.end_date ,
 r3.end_date  )
        and     tax.enabled_flag = 'Y' );

      ELSE  /* Statement type is INSERT, dont us: not exists clause */

      insert into ar_sales_tax(
              SALES_TAX_ID,
              LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
              CREATED_BY, CREATION_DATE,
              LOCATION_ID,
              rate_context,
              tax_rate,
              LOCATION1_RATE,
 LOCATION2_RATE,
 LOCATION3_RATE,
              from_postal_code,
              to_postal_code,
              start_date,
              end_date,
              enabled_flag)
           select
              AR_SALES_TAX_S.NEXTVAL+arp_standard.sequence_offset,
              sysdate,
              arp_standard.profile.user_id,
              null,
              arp_standard.profile.user_id,
              sysdate,
              location_ccid,
              arp_standard.sysparm.location_structure_id,
              decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1)
 + decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2)
 + decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3),
              decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1),
 decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2),
 decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3),
              greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code ),
              least(    r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code ),
              greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  ),
              least(    r1.end_date ,
 r2.end_date ,
 r3.end_date  ),
              'Y' /* Enabled Flag */
        from   ar_location_rates r1,
 ar_location_rates r2,
 ar_location_rates r3
        where  r1.location_segment_id = p_location_id_segment_1
 and r2.location_segment_id = p_location_id_segment_2
 and r3.location_segment_id = p_location_id_segment_3
        and    greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code ) <= least( r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code )
        and    greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  ) <= least( r1.end_date ,
 r2.end_date ,
 r3.end_date  );

      END IF; /* Insert or Update Mode */

   END IF; /* Dont call if in delete mode */

 IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '<< POPULATE_SALES_TAX' );
 END IF;

END Populate_Sales_Tax;


PROCEDURE propogate_sales_tax IS
BEGIN
 --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
 PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

 IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug( '>> PROPOGATE_SALES_TAX' );
 END IF;

      update ar_location_combinations
      set    last_update_date = sysdate ,
             last_updated_by  = arp_standard.profile.user_id,
             program_id       = arp_standard.profile.program_id,
            program_application_id = arp_standard.profile.program_application_id
      where  location_id in ( select loc_assign.loc_id
                                from hz_party_sites party_site,
                                     hz_loc_assignments loc_assign,
                                     hz_locations loc,
                                     hz_cust_acct_sites acct_site,
                                     hz_cust_site_uses site_uses
                              where site_uses.cust_acct_site_id =
                                       acct_site.cust_acct_site_id
                                and acct_site.party_site_id =
                                       party_site.party_site_id
                                and loc.location_id = party_site.location_id
                                and loc.location_id = loc_assign.location_id
                                and nvl(acct_site.org_id,-99) =
                                            nvl(loc_assign.org_id,-99)
                                and  site_uses.site_use_code = 'SHIP_TO' );
   IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug( '<< PROPOGATE_SALES_TAX' );
   END IF;

END;


PROCEDURE Purge_Sales_Tax IS

CURSOR sel_rates_c IS
   SELECT rowid, sales_tax_id from ar_sales_tax;

CURSOR PurgeRateUsed( p_sales_tax_id IN NUMBER ) IS
SELECT  'x' from dual
WHERE   exists (
        select 'x'
        from   ra_customer_trx_lines l
        where  l.sales_tax_id = p_sales_tax_id );
--
        dummy varchar2(30);
--
BEGIN
 -- PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
 PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
   ARP_UTIL_TAX.DEBUG( '>> PURGE_SALES_TAX' );

   FOR tax in sel_rates_c
   LOOP
   BEGIN
        OPEN PurgeRateUsed( tax.sales_tax_id );
--
        FETCH PurgeRateUsed
        INTO  dummy;
--
--      If rate not used cursor returns a row
--      This means the sales tax is NOT used,
--      So we can delete it.
--
        IF PurgeRateUsed%NOTFOUND THEN
--
          DELETE FROM ar_sales_tax
          WHERE rowid = tax.rowid;
--
        ELSE
--
--      If rate not used cursor returns no row
--      This means the sales tax is being used,
--      So we do not want to delete it,intead, set enabled to 'N'
--      (This part is added because the AR foreign key constraint
--       is not shipped to customers )
--
          UPDATE ar_sales_tax SET enabled_flag = 'N',
                                  last_update_date = sysdate,
                                  last_updated_by  = arp_standard.profile.user_id
          WHERE rowid = tax.rowid;
        END IF;
        CLOSE PurgeRateUsed;
   END ;
   END LOOP;

   ARP_UTIL_TAX.DEBUG( '<< PURGE_SALES_TAX' );

END Purge_Sales_Tax;

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
  cursor c_tax_lines( cust_trx_id in number, cust_trx_type in varchar2 ) is
            select customer_trx_line_id,
                   line_number,
                   link_to_cust_trx_line_id
            from   ra_customer_trx_lines
            where  customer_trx_id = cust_trx_id
            and    line_type = cust_trx_type
            and    link_to_cust_trx_line_id is not null
            order  by link_to_cust_trx_line_id, customer_trx_line_id
            for    update of line_number;


  previous_parent_line_id number := 0;
  new_line_number number := 0;

BEGIN
   -- PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
   PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

   for trx_line in c_tax_lines( customer_trx_id, trx_type )
   Loop
      if trx_line.link_to_cust_trx_line_id <> previous_parent_line_id
      then
         previous_parent_line_id :=
             trx_line.link_to_cust_trx_line_id;
         new_line_number := 0;
      end if;
      new_line_number := new_line_number + 1;
      update ra_customer_trx_lines set line_number = new_line_number
      where current of c_tax_lines;
   end loop;

END;


/*------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                       |
 |   period_date_range                                                    |
 |                                                                        |
 | CALLED BY find_tax_exemption_id                                        |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   This function returns the start date in the period associated        |
 |   any given trx_date.                                                  |
 |                                                                        |
 | REQUIRES                                                               |
 |    TRX_DATE                 Transaction Date                           |
 |                                                                        |
 | RETURNS                                                                |
 |    START_DATE               First date in period identified by trxdate |
 |    END_DATE                 Last date in period identified by trxdate  |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | 24 May, 1994  Nigel Smith   Created.                                   |
 |                                                                        |
 +------------------------------------------------------------------------*/

procedure period_date_range( trx_date in date,
                             start_date out NOCOPY date,
                               end_date out NOCOPY date ) is

   cursor sel_date( trx_date in date ) is
     select p.start_date, p.end_date
     from gl_period_statuses p, gl_sets_of_books g
    where p.application_id = arp_standard.application_id
      and p.set_of_books_id = arp_standard.sysparm.set_of_books_id
      and trunc(trx_date) between p.start_date and p.end_date
      and g.set_of_books_id = p.set_of_books_id
      and g.accounted_period_type = p.period_type;

begin
  --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug('period_date_range ( '||to_char(trx_date)||')');
  END IF;

   open sel_date( trx_date );
   fetch sel_date into start_date, end_date;

   if sel_date%notfound
   then
      close sel_date;
      arp_standard.fnd_message( 'AR_TW_NO_PERIOD_DEFINED','DATE',to_char(trx_date));
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('AR ACCOUNTING PERIOD IS NOT DEFINED');
    END IF;

   end if;
   if sel_date%isopen then
       close sel_date;
   end if;

end;



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
 |    View: TAX_EXEMPTIONS_V    This view must be installed before        |
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
 |    30-Jul-97  M Sabapathy    Bugfix 520228: Changed cursor             |
 |                              sel_item_exemption to look for exemptions |
 |                              with status PRIMARY only.                 |
 |    28-Mar-00  Helen Si       Bugfix 1039662: View Performance.    	  |
 |				Changed view TAX_EXEMPTIONS_QP_V to       |
 |				TAX_EXEMPTIONS_V.			  |
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

--
-- CURSOR: chk_customer_exemption
--
-- Check to see if this customer has an exemption at any level
--
-- The Explain Plan from this cursor, is very light weight and will for the
-- majority of calls to the tax engine, result in no data found forcing the
-- larger cursor not to be executed. This is based on the assumption
-- that the majority of Customers are not Tax Exempt; if they are an
-- Installation site should consider using Receivable Transactions
-- with a "Calculation Tax: No"; and then "Requiring Tax" in the
-- exception case.
--
-- EXPLAIN PLAN
--
-- OPERATION                              OPTIONS         OBJECT_NAME
-- -------------------------------------- --------------- ------------------
--  FILTER
--    TABLE ACCESS                         FULL            DUAL
--    INDEX                                RANGE SCAN      RA_TAX_EXEMPTIONS_N1
--
-- The Where Exists clause ensures that the database stops the search on
-- the index RAX_TAX_EXMEPTIONS_N1 for the first row found.
--

cursor chk_customer_exemption(customer in number) is
  select 'x' from dual where exists
   ( select 'x' from ra_tax_exemptions where
     customer_id = customer );

--
-- CURSOR: sel_customer_exemption
--
-- Find Customer Exemption, for this transaction line
--
cursor sel_customer_exemption(customer in number, site in number,
                              trxdate in date, taxcode in varchar2,
                              tax_exempt_flag in varchar2,
                              certificate_number in varchar2,
                              reason_code in varchar2 ) is
       select
	   x.percent_exempt,
	   x.tax_exemption_id,
           x.reason_code,
           rtrim(ltrim(nvl(x.customer_exemption_number,' '))) tax_exempt_number,
           x.status,
           x.start_date,
           x.end_date,
           decode( x.site_use_id, null,
            decode(x.location_id_segment_10, null,
             decode(x.location_id_segment_9, null,
              decode(x.location_id_segment_8, null,
               decode(x.location_id_segment_7, null,
                decode(x.location_id_segment_6, null,
                 decode(x.location_id_segment_5, null,
                  decode(x.location_id_segment_4, null,
                   decode(x.location_id_segment_3, null,
                    decode(x.location_id_segment_2, null,
                     decode(x.location_id_segment_1, null,
                    11, 10), 9), 8), 7), 6), 5), 4), 3), 2), 1), 0 )
                    +decode( x.status, 'PRIMARY', 0,
                                       'MANUAL', 1000,
                                       'UNAPPROVED', 2000,
                                       'EXPIRED', 3000, 4000 )
           DISPLAY_ORDER
      	from
	   hz_cust_site_uses        s,
           hz_cust_acct_sites       a,
           hz_party_sites           p,
           hz_loc_assignments       la,
           ra_tax_exemptions        x,
           ar_location_combinations c
WHERE  la.loc_id = c.location_id(+)
and    a.party_site_id = p.party_site_id
and    p.location_id = la.location_id
and    nvl(a.org_id, -99) = nvl(la.org_id, -99)
and    s.cust_acct_site_id  = a.cust_acct_site_id
and    nvl(x.location_id_segment_1, nvl(c.location_id_segment_1,-1)) = nvl(c.location_id_segment_1,-1)
and    nvl(x.location_id_segment_2, nvl(c.location_id_segment_2,-1)) = nvl(c.location_id_segment_2,-1)
and    nvl(x.location_id_segment_3, nvl(c.location_id_segment_3,-1)) = nvl(c.location_id_segment_3,-1)
and    nvl(x.location_id_segment_4, nvl(c.location_id_segment_4,-1)) = nvl(c.location_id_segment_4,-1)
and    nvl(x.location_id_segment_5, nvl(c.location_id_segment_5,-1)) = nvl(c.location_id_segment_5,-1)
and    nvl(x.location_id_segment_6, nvl(c.location_id_segment_6,-1)) = nvl(c.location_id_segment_6,-1)
and    nvl(x.location_id_segment_7, nvl(c.location_id_segment_7,-1)) = nvl(c.location_id_segment_7,-1)
and    nvl(x.location_id_segment_8, nvl(c.location_id_segment_8,-1)) = nvl(c.location_id_segment_8,-1)
and    nvl(x.location_id_segment_9, nvl(c.location_id_segment_9,-1)) = nvl(c.location_id_segment_9,-1)
and    nvl(x.location_id_segment_10, nvl(c.location_id_segment_10,-1)) = nvl(c.location_id_segment_10,-1)
and     x.exemption_type = 'CUSTOMER'
and	nvl( x.site_use_id, s.site_use_id  ) = s.site_use_id
and     x.customer_id = customer
and     s.site_use_id = site
and     x.tax_code = taxcode
/*
 * Standard Tax rules can only search for Exemptions that are marked as
 * PRIMARY. All other exemptions are ignored.
 *
 */
            AND (( tax_exempt_flag = 'S' and x.status = 'PRIMARY' )
/*
 * Transactions that are forced exempt, should only ever use an existing certificate
 * number if:-
 * The Certificate is not rejected or expired.
 * The user supplied reason codes, and exemption numbers match those on the certificate
 * (note the supplied exemption number can be null)
 *
 * If these conditions are NOT met, a new Unapproved certificate will be created
 * to support this.
 *
 */
             OR ( tax_exempt_flag = 'E'
                  AND x.STATUS IN ( 'PRIMARY', 'MANUAL', 'UNAPPROVED' )
                  AND x.REASON_CODE = reason_code
                  AND ( (rtrim(ltrim(x.customer_exemption_number)) = certificate_number)
                      or (x.customer_exemption_number IS NULL AND
                          certificate_number IS NULL))   ))
          AND trxdate between x.start_date and nvl(x.end_date, trx_date)
        ORDER BY DISPLAY_ORDER;

cursor sel_item_exemption( item in number, taxcode in varchar2, trxdate in date ) is
          SELECT percent_exempt, tax_exemption_id,
                 reason_code                     tax_exempt_reason_code,
                 rtrim(ltrim(customer_exemption_number)) tax_exempt_number
          FROM            ra_tax_exemptions
          WHERE           inventory_item_id = item
          AND             tax_code = taxcode
          AND trxdate between start_date and nvl(end_date, trx_date)
          AND exemption_type = 'ITEM'
          AND status = 'PRIMARY';	/* Bugfix 520228 */

CURSOR sel_tax_exemptions_s is
          SELECT ra_tax_exemptions_s.nextval from dual;

CURSOR sel_location_ids( site_id in number ) is
          select c.location_id_segment_1,
                 c.location_id_segment_2,
                 c.location_id_segment_3,
                 c.location_id_segment_4,
                 c.location_id_segment_5,
                 c.location_id_segment_6,
                 c.location_id_segment_7,
                 c.location_id_segment_8,
                 c.location_id_segment_9,
                 c.location_id_segment_10
                 from ar_location_combinations c,
                      hz_cust_acct_sites acct_site,
                      hz_loc_assignments loc_assign,
                      hz_locations loc,
                      hz_party_sites party_site,
                      hz_cust_site_uses site_uses
                 where site_uses.site_use_id = site_id
                   and site_uses.cust_acct_site_id = acct_site.cust_acct_site_id
                   and acct_site.party_site_id = party_site.party_site_id
                   and loc.location_id = party_site.location_id
                   and loc.location_id = loc_assign.location_id
                   and loc_assign.loc_id = c.location_id(+); /* BUGFIX: 244306 */

   l_percent_exempt          number := 0;
   l_exemption_id            number := NULL ;
   l_tax_exempt_number       varchar2(80) := NULL;
   l_tax_exempt_reason_code  varchar2(30) := NULL;
   l_inserted                boolean := FALSE;
   l_exemption_type          varchar2(30) := NULL;
   l_period_start_date       date;
   l_period_end_date         date;
   l_find_customer_exemption boolean;

   l_bill_to_customer_id     NUMBER := NULL;
   l_status_code             VARCHAR2(30) := NULL;
   l_start_date              DATE;
   l_end_date                DATE;

   l_location_id_segment     TAB_ID_TYPE;
   dummy                     dual.dummy%type;
   l_display_order           NUMBER;

BEGIN
   --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
   PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

   ARP_UTIL_TAX.DEBUG( '>> FIND_TAX_EXEMPTION_ID: ' || bill_to_customer_id || ', ' ||
                       ship_to_site_id || ', ' || tax_code || ', ' ||
                       inventory_item_id || ', ' || to_char(trx_date, 'DD-MON-YYYY') || ', ' ||
                       tax_exempt_flag || ', ' || reason_code || ', ' || certificate );


   l_inserted := FALSE;
   l_exemption_type := NULL;
   l_tax_exempt_number := ltrim(rtrim(certificate));
   l_tax_exempt_reason_code := reason_code;
   l_find_customer_exemption := FALSE;

   --
   --  Assign null values to each candidate location segment id
   --  so that the region descriptive flexfield will be
   --  populated correctly in the ra_tax_exemptions table
   --
   for i in 1 .. 10
   loop
      l_location_id_segment(i) := NULL;
   end loop;

   if l_tax_exempt_reason_code is null and tax_exempt_flag = 'E'
   then
       arp_standard.fnd_message( 'AR_NO_REASON_FOR_EXEMPTION' );
    IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('NO REASON FOR EXEMPTION ');
    END IF;

   end if;

   if arp_standard.sysparm.tax_use_customer_exempt_flag = 'Y' and
      tax_exempt_flag <> 'R' then

      /* Standard Tax Rules May have a customer Exemption */
      if tax_exempt_flag = 'S' then

         OPEN chk_customer_exemption( bill_to_customer_id );
         FETCH chk_customer_exemption into dummy;

         if  chk_customer_exemption%FOUND then

            l_find_customer_exemption := TRUE;

           IF PG_DEBUG = 'Y' THEN
             arp_util_tax.debug( 'I: A Customer Exemption Exists (chk1)' );
           END IF;

         else

            l_find_customer_exemption := FALSE;

            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug( 'I: No Customer Exemption found (chk1)' );
            END IF;

         end if;

         CLOSE chk_customer_exemption;

      else

         /* Exempt Transactions have to use the larger cursor: sel_customer_exemption */
         l_find_customer_exemption := TRUE;

      end if; -- tax_exempt_flag = 'S'

      if l_find_customer_exemption then

        FOR j IN 1 .. pg_max_index
        LOOP

          if  tax_exempt_info_tbl(j).bill_to_customer_id = bill_to_customer_id
          and tax_exempt_info_tbl(j).ship_to_site_use_id = ship_to_site_id
          and tax_exempt_info_tbl(j).tax_code = tax_code
          and (   tax_exempt_flag = 'S' and (   tax_exempt_info_tbl(j).status_code = 'PRIMARY'
                                             or tax_exempt_info_tbl(j).status_code is null)
               or (    tax_exempt_flag = 'E'
                   and (   tax_exempt_info_tbl(j).status_code in ( 'PRIMARY', 'MANUAL', 'UNAPPROVED' )
                        or tax_exempt_info_tbl(j).status_code is null)
                   and (   tax_exempt_info_tbl(j).tax_exempt_reason_code = l_tax_exempt_reason_code
                        or (    tax_exempt_info_tbl(j).tax_exempt_reason_code is null
                            and l_tax_exempt_reason_code is null))
                   and (   (rtrim(ltrim(tax_exempt_info_tbl(j).tax_exempt_number)) = l_tax_exempt_number)
                        or (    rtrim(ltrim(tax_exempt_info_tbl(j).tax_exempt_number)) is NULL
                            and l_tax_exempt_number is null
                           )
                        )
                  )
               )
          and trx_date >= tax_exempt_info_tbl(j).start_date
          and trx_date <= nvl(tax_exempt_info_tbl(j).end_date, trx_date) then

            l_bill_to_customer_id := bill_to_customer_id;
            l_percent_exempt := tax_exempt_info_tbl(j).percent_exempt;
            l_exemption_id := tax_exempt_info_tbl(j).tax_exemption_id;
            l_tax_exempt_reason_code := tax_exempt_info_tbl(j).tax_exempt_reason_code;
            l_tax_exempt_number := tax_exempt_info_tbl(j).tax_exempt_number;
            l_status_code := tax_exempt_info_tbl(j).status_code;

            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('INSIDE OF LOOP:Found exemption in cache('||to_char(j)||')');
            END IF;

            EXIT;

          end if;

        END LOOP; -- FOR j IN 1 .. pg_max_index

        if l_bill_to_customer_id is null then

        IF PG_DEBUG = 'Y' THEN
          arp_util_tax.debug('No matching record in cache.');
        END IF;

          OPEN sel_customer_exemption( bill_to_customer_id, ship_to_site_id,
                                       trx_date, tax_code, tax_exempt_flag,
                                       l_tax_exempt_number, l_tax_exempt_reason_code );

          FETCH sel_customer_exemption into l_percent_exempt,
                                            l_exemption_id,
                                            l_tax_exempt_reason_code,
                                            l_tax_exempt_number,
                                            l_status_code,
                                            l_start_date,
                                            l_end_date,
                                            l_display_order;

          if sel_customer_exemption%NOTFOUND then

            l_percent_exempt := 100;

            /* Reset these values, they may now be null */
	    l_tax_exempt_reason_code := reason_code;
	    l_tax_exempt_number := rtrim(ltrim(certificate));

            if tax_exempt_flag = 'E' and
               insert_allowed = 'TRUE' and
               l_tax_exempt_reason_code is not null then

              /*********************************************************************/
              /* Using: EXEMPT_LEVEL qualifier, find each location_segment_id      */
              /* that must be populated in ra_tax_exemptions.location_id_segment_n */
              /*********************************************************************/

           IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug( 'I: Location Qualifiers');
              arp_util_tax.debug( 'EXEMPT_LEVEL STATE TAX_ACCOUNT, COUNTY, CITY' );
           END IF;

	      /*** MB skip, hardcode search for EXEMPT_LEVEL ***/
              if instr( 'EXEMPT_LEVEL STATE TAX_ACCOUNT, COUNTY, CITY', 'EXEMPT_LEVEL' ) <> 0 then

              IF PG_DEBUG = 'Y' THEN
                  arp_util_tax.debug( 'I: FIND_TAX_EXEMPTION_ID: USING EXEMT_LEVEL SEGMENT QUALIFIER FOR NEW EXEMPTION');
              END IF;

                OPEN sel_location_ids( ship_to_site_id );

                FETCH sel_location_ids into
                      l_location_id_segment(1),
                      l_location_id_segment(2),
                      l_location_id_segment(3),
                      l_location_id_segment(4),
                      l_location_id_segment(5),
                      l_location_id_segment(6),
                      l_location_id_segment(7),
                      l_location_id_segment(8),
                      l_location_id_segment(9),
                      l_location_id_segment(10);

                if sel_location_ids%NOTFOUND then
                   CLOSE sel_location_ids;
                   arp_standard.fnd_message( 'AR_STAX_NO_LOCATION_ID', 'SITE_USE_ID', ship_to_site_id );
                   IF PG_DEBUG = 'Y' THEN
                      arp_util_tax.debug('AR STAX NO LOCATION ID');
                   END IF;
                end if;
                CLOSE sel_location_ids;

                /***************************************************************************/
                /* Mark as null all trailing location segment id's that follow the segment */
                /* at which automatic exemptions are created for.                          */
                /***************************************************************************/

                BEGIN
                  FOR i in arp_flex.expand( arp_flex.location, 'EXEMPT_LEVEL', null, '%NUMBER%')+1 .. 10
                  LOOP
                    l_location_id_segment(i) := NULL;
                  END LOOP;
                EXCEPTION
                  /*********************************************************************************/
                  /* arp_flex.expand can raise error message if the sales tax location flexfield   */
                  /* has been reconfigured without then rerunning the pl/sql flexfield precompiler */
                  /*********************************************************************************/
                  WHEN OTHERS THEN
                    arp_standard.fnd_message( 'AR_STAX_NOT_INSTALLED' );
            IF PG_DEBUG = 'Y' THEN
               arp_util_tax.debug('STAX NOT INSTALLED');
             END IF;

                END;

              end if;  -- instr( 'EXEMPT_LEVEL STATE TAX_ACCOUNT, COUNTY, CITY', 'EXEMPT_LEVEL' ) <> 0


              /***************************************/
              /* Insert automatic customer exemption */
              /***************************************/

              period_date_range( trx_date,
                                 l_period_start_date,
                                 l_period_end_date );

              OPEN sel_tax_exemptions_s;
              FETCH sel_tax_exemptions_s into l_exemption_id;
              CLOSE sel_tax_exemptions_s;


              insert into ra_tax_exemptions(
                  TAX_EXEMPTION_ID,
                  CREATED_BY,
                  CREATION_DATE,
                  EXEMPTION_TYPE,
                  IN_USE_FLAG,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  PERCENT_EXEMPT,
                  START_DATE,
                  TAX_CODE,
                  CUSTOMER_ID,
                  END_DATE,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE,
                  REQUEST_ID,
                  CUSTOMER_EXEMPTION_NUMBER,
                  REASON_CODE,
                  STATUS,
                  LOCATION_CONTEXT,
                  LOCATION_ID_SEGMENT_1,
                  LOCATION_ID_SEGMENT_2,
                  LOCATION_ID_SEGMENT_3,
                  LOCATION_ID_SEGMENT_4,
                  LOCATION_ID_SEGMENT_5,
                  LOCATION_ID_SEGMENT_6,
                  LOCATION_ID_SEGMENT_7,
                  LOCATION_ID_SEGMENT_8,
                  LOCATION_ID_SEGMENT_9,
                  LOCATION_ID_SEGMENT_10
              )
              values
              (
                  l_exemption_id,
                  arp_standard.profile.user_id,
                  sysdate,
                  'CUSTOMER',
                  'Y',
                  arp_standard.profile.user_id,
                  sysdate,
                  100.00,
                  l_period_start_date,
                  tax_code,
                  bill_to_customer_id,
                  null,
                  arp_standard.application_id,
                  arp_standard.profile.program_id,
                  sysdate,
                  arp_standard.profile.request_id,
                  l_tax_exempt_number,
                  l_tax_exempt_reason_code,
                  'UNAPPROVED',
   	       arp_standard.sysparm.location_structure_id,
                  l_location_id_segment(1),
                  l_location_id_segment(2),
                  l_location_id_segment(3),
                  l_location_id_segment(4),
                  l_location_id_segment(5),
                  l_location_id_segment(6),
                  l_location_id_segment(7),
                  l_location_id_segment(8),
                  l_location_id_segment(9),
                  l_location_id_segment(10)
             );

             l_exemption_type := 'CUSTOMER';
             l_inserted := TRUE;

             IF PG_DEBUG = 'Y' THEN
               arp_util_tax.debug('Inserting into cache after inserting into ra_tax_exemptions');
             END IF;

             pg_max_index := pg_max_index + 1;
             tax_exempt_info_tbl(pg_max_index).percent_exempt := 100.00;
             tax_exempt_info_tbl(pg_max_index).tax_exemption_id := l_exemption_id;
             tax_exempt_info_tbl(pg_max_index).tax_exempt_reason_code := l_tax_exempt_reason_code;
             tax_exempt_info_tbl(pg_max_index).tax_exempt_number := l_tax_exempt_number;
             tax_exempt_info_tbl(pg_max_index).bill_to_customer_id := bill_to_customer_id;
             tax_exempt_info_tbl(pg_max_index).ship_to_site_use_id := ship_to_site_id;
             tax_exempt_info_tbl(pg_max_index).tax_code := tax_code;
             tax_exempt_info_tbl(pg_max_index).status_code := 'UNAPPROVED';
             tax_exempt_info_tbl(pg_max_index).start_date := l_period_start_date;
             tax_exempt_info_tbl(pg_max_index).end_date := NULL;

           else

             IF PG_DEBUG = 'Y' THEN
               arp_util_tax.debug('Inserting into cache. Exemption is not found.');
             END IF;
             pg_max_index := pg_max_index + 1;
             tax_exempt_info_tbl(pg_max_index).percent_exempt := l_percent_exempt;
             tax_exempt_info_tbl(pg_max_index).tax_exemption_id := l_exemption_id;
             tax_exempt_info_tbl(pg_max_index).tax_exempt_reason_code := l_tax_exempt_reason_code;
             tax_exempt_info_tbl(pg_max_index).tax_exempt_number := l_tax_exempt_number;
             tax_exempt_info_tbl(pg_max_index).bill_to_customer_id := bill_to_customer_id;
             tax_exempt_info_tbl(pg_max_index).ship_to_site_use_id := ship_to_site_id;
             tax_exempt_info_tbl(pg_max_index).tax_code := tax_code;
             tax_exempt_info_tbl(pg_max_index).status_code := l_status_code;
             tax_exempt_info_tbl(pg_max_index).start_date := nvl(l_start_date, trx_date);
             tax_exempt_info_tbl(pg_max_index).end_date := l_end_date;

           end if; -- tax_exempt_flag = 'E' and .....

         else

           /* Exemption ID was found in the cursor: sel_customer_exemption */
           l_exemption_type := 'CUSTOMER';
	   l_inserted := FALSE;

           IF PG_DEBUG = 'Y' THEN
             arp_util_tax.debug('Inserting into cache. Exemption is found by query. ');
           END IF;
           pg_max_index := pg_max_index + 1;
           tax_exempt_info_tbl(pg_max_index).percent_exempt := l_percent_exempt;
           tax_exempt_info_tbl(pg_max_index).tax_exemption_id := l_exemption_id;
           tax_exempt_info_tbl(pg_max_index).tax_exempt_reason_code := l_tax_exempt_reason_code;
           tax_exempt_info_tbl(pg_max_index).tax_exempt_number := l_tax_exempt_number;
           tax_exempt_info_tbl(pg_max_index).bill_to_customer_id := bill_to_customer_id;
           tax_exempt_info_tbl(pg_max_index).ship_to_site_use_id := ship_to_site_id;
           tax_exempt_info_tbl(pg_max_index).tax_code := tax_code;
           tax_exempt_info_tbl(pg_max_index).status_code := l_status_code;
           tax_exempt_info_tbl(pg_max_index).start_date := l_start_date;
           tax_exempt_info_tbl(pg_max_index).end_date := l_end_date;

         end if; -- sel_customer_exemption%NOTFOUND

         CLOSE sel_customer_exemption;

       elsif l_status_code is not null then

         /* Exemption is found in cache */
         IF PG_DEBUG = 'Y' THEN
           arp_util_tax.debug('Found Exemption in cache.');
         END IF;

         l_exemption_type := 'CUSTOMER';
         l_inserted := FALSE;

       end if; -- l_bill_to_customer_id is null

     end if;  -- l_find_customer_exemption


   else
      IF PG_DEBUG = 'Y' THEN
         arp_util_tax.debug( 'I: FIND_TAX_EXEMPTION_ID: ARP_STANDARD.SYSPARM.TAX_USE_CUSTOMER_EXEMPT_FLAG = ' ||
                                arp_standard.sysparm.tax_use_customer_exempt_flag );
      END IF;
   end if; -- arp_standard.sysparm.tax_use_customer_exempt_flag


   if  arp_standard.sysparm.tax_use_product_exempt_flag = 'Y'
   and l_exemption_type is null THEN

      OPEN sel_item_exemption( inventory_item_id,
                               tax_code, trx_date );
      FETCH sel_item_exemption into
                l_percent_exempt, l_exemption_id,
                l_tax_exempt_reason_code, l_tax_exempt_number;


      IF sel_item_exemption%NOTFOUND
      THEN
         l_exemption_type := NULL;
         l_tax_exempt_reason_code := NULL;
         l_tax_exempt_number := NULL;
         l_exemption_id := NULL;
         l_percent_exempt := 0;
      ELSE
         l_exemption_type := 'ITEM';
      END IF;
      CLOSE sel_item_exemption;
  else

      /* Product Exemptions are not to be checked */


      IF l_exemption_type IS NULL
      THEN

         --
         -- Product Exmeptions must be turned off in the system parameters form
         --
       IF PG_DEBUG = 'Y' THEN
          arp_util_tax.debug( 'I: FIND_TAX_EXEMPTION_ID: ARP_STANDARD.TAX_USE_PRODUCT_EXEMPT_FLAG = ' ||
                                arp_standard.sysparm.TAX_USE_PRODUCT_EXEMPT_FLAG );
       END IF;
      END IF;

   end if; --arp_standard.sysparm.tax_use_product_exempt_flag = 'Y'

   percent_exempt   := l_percent_exempt;
   tax_exemption_id := l_exemption_id;
   reason_code      := l_tax_exempt_reason_code;
   certificate      := l_tax_exempt_number;
   exemption_type   := l_exemption_type;

   if l_inserted
   then
     inserted_flag := 'Y';
   else
     inserted_flag := 'N';
   end if;


   if l_exemption_type is not null
   then
      if l_inserted
      then
        IF PG_DEBUG = 'Y' THEN
          arp_util_tax.debug( '<< FIND_TAX_EXEMPTION_ID( INSERTED, ' || l_exemption_type || ' ' || l_exemption_id
                             || ', ' || l_percent_exempt ||' )' );
        END IF;
      else
         inserted_flag := 'N';
         IF PG_DEBUG = 'Y' THEN
           arp_util_tax.debug( '<< FIND_TAX_EXEMPTION_ID( FOUND, ' || l_exemption_type || ', '
                                 || l_exemption_id || ', ' || l_percent_exempt ||' )' );
           arp_util_tax.debug( ' Updating In_Use_Flag in ra_tax_exemptions' ) ;
         END IF;
         -- Bug 3159438: To Update In_Use_Flag in Exemptions
         Update ra_tax_exemptions_all
            set in_use_flag = 'Y'
          where tax_exemption_id = l_exemption_id;
      end if;

   else

     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug( '<< FIND_TAX_EXEMPTION_ID( NO EXEMPTION )' );
     END IF;

   end if;


END;


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
BEGIN
        insert into ar_sales_tax(
                SALES_TAX_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                CREATED_BY,
                CREATION_DATE,
                LOCATION_ID,
                rate_context,
                tax_rate,
                LOCATION1_RATE,
 LOCATION2_RATE,
 LOCATION3_RATE,
                from_postal_code,
                to_postal_code,
                start_date,
                end_date,
                enabled_flag)
        select
                AR_SALES_TAX_S.NEXTVAL+arp_standard.sequence_offset,
                sysdate,
                arp_standard.profile.user_id,
                null,
                arp_standard.profile.user_id,
                sysdate,
                ccid.location_id,
                arp_standard.sysparm.location_structure_id,
                decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1)
 + decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2)
 + decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3),
                decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1),
 decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2),
 decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3),
                greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code ),
                least( r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code ),
                greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  ),
                least( r1.end_date ,
 r2.end_date ,
 r3.end_date  ),
                'Y'
        from    ar_location_rates r1,
 ar_location_rates r2,
 ar_location_rates r3,
                AR_LOCATION_COMBINATIONS ccid
        where   ccid.LOCATION_ID_SEGMENT_1  = r1.location_segment_id and
ccid.LOCATION_ID_SEGMENT_2  = r2.location_segment_id and
ccid.LOCATION_ID_SEGMENT_3  = r3.location_segment_id
        and     greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code ) <= least( r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code )
        and     greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  ) <= least( r1.end_date ,
 r2.end_date ,
 r3.end_date  )
        and     not exists (
                        select  'x'
                        from    ar_sales_tax tax
                        where   tax.location_id = ccid.location_id
                        and     tax.location1_rate = decode( r3.override_rate1, null, nvl(r1.tax_rate,0), r3.override_rate1)
 and tax.location2_rate = decode( r3.override_rate2, null, nvl(r2.tax_rate,0), r3.override_rate2)
 and tax.location3_rate = decode( r3.override_rate3, null, nvl(r3.tax_rate,0), r3.override_rate3)
                        and     tax.from_postal_code =
                                        greatest( r1.from_postal_code,
 r2.from_postal_code,
 r3.from_postal_code )
                        and     tax.to_postal_code =
                                        least( r1.to_postal_code,
 r2.to_postal_code,
 r3.to_postal_code )
                        and     tax.start_date =
                                        greatest( r1.start_date ,
 r2.start_date ,
 r3.start_date  )
                        and     tax.end_date =
                                        least( r1.end_date ,
 r2.end_date ,
 r3.end_date  )
                        and     tax.enabled_flag = 'Y' );
END;

PROCEDURE populate_segment_array( loc_segment_id in number ) is
begin
    ARP_STAX_MINUS99.loc_rate := ARP_STAX_MINUS99.loc_rate + 1;
    ARP_STAX_MINUS99.location_segment_id(ARP_STAX_MINUS99.loc_rate) :=
        loc_segment_id;
   -- PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
   PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

end populate_segment_array;

END ARP_STAX_MINUS99;

/
