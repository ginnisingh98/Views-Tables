--------------------------------------------------------
--  DDL for Package Body ARP_ADDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ADDS" AS
/* $Header: ARPLLOCB.pls 120.10 2005/09/02 02:30:14 sachandr ship $ */

/*-------------------------------------------------------------------------+
|                                                                         |
| PRIVATE EXCEPTIONS                                                      |
|                                                                         |
+-------------------------------------------------------------------------*/

compile_error EXCEPTION;
PRAGMA EXCEPTION_INIT(compile_error, -6550);

/*-------------------------------------------------------------------------+
|                                                                         |
| PRIVATE VARIABLES                                                       |
|                                                                         |
+-------------------------------------------------------------------------*/

cached_org_id                integer;
cached_org_append            varchar2(100);
--PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
g_current_runtime_level    NUMBER;
g_level_procedure          CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;

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
 |   find_location_segment_id                                              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function Returns a segment value id for any given value of a     |
 |   location flexfield segment.                                           |
 |                                                                         |
 |   If the given value cannot be found in the table, it is inserted       |
 |   and the new location_segment_id is returned from the sequence         |
 |   AR_LOCATION_VALUES_S.nextval                                          |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 |   location_segment_qualifier Value set name used of this segment,eg City|
 |   segment_value       The value to be found/inserted, eg Belmont        |
 |   parent_segment_id   The unique ID of the parent that owns this        |
 |                       segment.                                          |
 | OPTIONAL                                                                |
 |                                                                         |
 |   Descriptive Flexfield    Attribute_category and Descriptive Flexfield |
 |                            information, used if this calls inserts a    |
 |                            new row in ar_location_values                |
 |                                                                         |
 |   Search_Precission        If an existing locaion could not be found    |
 |                            and the supplied location is this number of  |
 |                            characters wide, then reattempt the search   |
 |                            using just this precission. Allows user to   |
 |                            manually correct truncated Cities, if the    |
 |                            data they upload through the interface table |
 |                            only supplies the first N character of a city|
 |                            name.                                        |
 |                                                                         |
 | RETURNS                                                                 |
 |   LOCATION_SEGMENT_ID for the value.                                    |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-Jan-93  Nigel Smith   Created.                                    |
 |    17-Feb-93  Nigel Smith   Now stores all segment values in uppercase  |
 |                             comparisons are case independent            |
 |    23-Aug-93  Nigel Smith   Added support for Descriptive Flexfields    |
 |                             used by Tax Interface program               |
 +-------------------------------------------------------------------------*/


FUNCTION
   find_location_segment_id( location_segment_qualifier    in varchar2,
                     segment_value                 in varchar2,
                     segment_description           in varchar2,
                     parent_segment_id             in number,
                     ATTRIBUTE_CATEGORY            in varchar2 default 'TRIGGER',
                     ATTRIBUTE1                    in varchar2 default null,
                     ATTRIBUTE2                    in varchar2 default null,
                     ATTRIBUTE3                    in varchar2 default null,
                     ATTRIBUTE4                    in varchar2 default null,
                     ATTRIBUTE5                    in varchar2 default null,
                     ATTRIBUTE6                    in varchar2 default null,
                     ATTRIBUTE7                    in varchar2 default null,
                     ATTRIBUTE8                    in varchar2 default null,
                     ATTRIBUTE9                    in varchar2 default null,
                     ATTRIBUTE10                   in varchar2 default null,
                     ATTRIBUTE11                   in varchar2 default null,
                     ATTRIBUTE12                   in varchar2 default null,
                     ATTRIBUTE13                   in varchar2 default null,
                     ATTRIBUTE14                   in varchar2 default null,
                     ATTRIBUTE15                   in varchar2 default null,
		     SEARCH_PRECISSION		   in number   default null )
         return number IS

  l_location_segment_inserted varchar2(5);
  location_segment_id    number;
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN
  -- Stubbed out for R12
 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'AR.PLSQL.ARP_ADDS.find_location_segment_id',
                   'Warning - obsolete code being referenced: ARP_TAX.find_location_segment_id()');
  END IF;
 return null;
END find_location_segment_id;



/*-------------------------------------------------------------------------+
| PUBLIC  PROCEDURE                                                       |
|   location_information                                                  |
|                                                                         |
| DESCRIPTION                                                             |
|   This function Returns a location description given either:            |
|      locaiton_segment_id, or                                            |
|      locaiton_segment_qualifier and location_segment_value              |
|                                                                         |
| REQUIRES                                                                |
|   location_segment_qualifier Value set name used on this segment,eg City|
|   segment_value              The value to be found/inserted, eg Belmont |
|   or:                                                                   |
|   location_segment_id        Unique id for this location                |
|                                                                         |
| RETURNS                                                                 |
|   location_segment_id                                                   |
|   location_segment_value                                                |
|   location_segment_description                                          |
|   location_segment_qualifier                                            |
|   parent_segment_id                                                     |
|                                                                         |
| EXCEPTIONS RAISED                                                       |
|                                                                         |
| NOTES                                                                   |
|                                                                         |
| EXAMPLE                                                                 |
|                                                                         |
| MODIFICATION HISTORY                                                    |
|    17-JUN-93  Nigel Smith   Created.                                    |
+-------------------------------------------------------------------------*/


procedure location_information( location_segment_id          in number,
                                location_segment_qualifier   out NOCOPY varchar2,
                                location_segment_value       out NOCOPY varchar2,
                                location_segment_description out NOCOPY varchar2,
                                parent_segment_id out NOCOPY number ) is

  dummy_vch             varchar2(2);
  dummy_num             number;
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin
  -- Stubbed out for R12
  null;
end location_information;


procedure location_information( location_segment_qualifier   in varchar2,
                                location_segment_value       in  varchar2,
                                location_segment_description out NOCOPY varchar2,
                                parent_segment_id out NOCOPY number ) is

  dummy_vch             varchar2(2);
  dummy_num             number;
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin
  -- Stubbed for R12;
  null;
end location_information;


function location_description( location_segment_qualifier in varchar2,
                               location_segment_value     in varchar2 )
         return varchar2 is


  location_segment_description varchar2(60);
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin
  -- Stubbed for R12;
  null;
end location_description;


function location_description( location_segment_id in number )
   return varchar2 is

  location_segment_description varchar2(60);
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin
  -- Stubbed out for R12
  null;
end location_description;


/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   enable_triggers / disable_triggers                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Control the execution of database triggers associated with the       |
 |    customer address functions, disabling or enabling there actions.     |
 |                                                                         |
 |    This is used to enhance performance of certain batch operations      |
 |    such as the Sales Tax Interface programs, when the row by row        |
 |    nature of database triggers would degrade performance of the system  |
 |                                                                         |
 | MODIFIES                                                                |
 |                                                                         |
 | adds.triggers_enabled                                                   |
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

begin

  -- Stubbed out for R12
  null;
end enable_triggers;

procedure disable_triggers is

  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

begin
  -- Stubbed out for R12
  null;
end disable_triggers;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   ins_location_values                                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function generates a new record in the table: AR_LOCATION_VALUES |
 |   and returns the LOCATION_SEGMENT_ID of this new record                |
 |                                                                         |
 | REQUIRES                                                                |
 |   location_segment_qualifier      Value set name used of this segment   |
 |   segment_value       The value to be inserted, eg Belmont              |
 |   parent_segment_id   The unique ID of the parent that owns this        |
 |                       segment.                                          |
 |                                                                         |
 | RETURNS                                                                 |
 |   LOCATION_SEGMENT_ID for the value.                                    |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION ins_location_values( location_segment_qualifier     in varchar2,
                              segment_value      in varchar2,
                              segment_description in varchar2,
                              parent_segment_id  in varchar2,
                              ATTRIBUTE_CATEGORY in varchar2 default 'TRIGGER',
                              ATTRIBUTE1         in varchar2 default null,
                              ATTRIBUTE2         in varchar2 default null,
                              ATTRIBUTE3         in varchar2 default null,
                              ATTRIBUTE4         in varchar2 default null,
                              ATTRIBUTE5         in varchar2 default null,
                              ATTRIBUTE6         in varchar2 default null,
                              ATTRIBUTE7         in varchar2 default null,
                              ATTRIBUTE8         in varchar2 default null,
                              ATTRIBUTE9         in varchar2 default null,
                              ATTRIBUTE10        in varchar2 default null,
                              ATTRIBUTE11        in varchar2 default null,
                              ATTRIBUTE12        in varchar2 default null,
                              ATTRIBUTE13        in varchar2 default null,
                              ATTRIBUTE14        in varchar2 default null,
                              ATTRIBUTE15        in varchar2 default null
      ) return number IS

  location_id           number;
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN

  -- Stubbed out for R12
  null;
end ins_location_values;

/*-------------------------------------------------------------------------+
 | PUBLIC  FUNCTION                                                        |
 |   ins_location_rates                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function generates a new record in the table: AR_LOCATION_RATES  |
 |   and returns the LOCATION_RATE_ID of this new record                   |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   LOCATION_RATE_ID for the value.                                       |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION ins_location_rates(  location_segment_id in number,
                              from_postal_code in varchar2,
                              to_postal_code in varchar2,
                              start_date in date,
                              end_date in date,
                              tax_rate in number,
                              ATTRIBUTE_CATEGORY in varchar2 default 'TRIGGER',
                              ATTRIBUTE1         in varchar2 default null,
                              ATTRIBUTE2         in varchar2 default null,
                              ATTRIBUTE3         in varchar2 default null,
                              ATTRIBUTE4         in varchar2 default null,
                              ATTRIBUTE5         in varchar2 default null,
                              ATTRIBUTE6         in varchar2 default null,
                              ATTRIBUTE7         in varchar2 default null,
                              ATTRIBUTE8         in varchar2 default null,
                              ATTRIBUTE9         in varchar2 default null,
                              ATTRIBUTE10        in varchar2 default null,
                              ATTRIBUTE11        in varchar2 default null,
                              ATTRIBUTE12        in varchar2 default null,
                              ATTRIBUTE13        in varchar2 default null,
                              ATTRIBUTE14        in varchar2 default null,
                              ATTRIBUTE15        in varchar2 default null,
			      OVERRIDE_STRUCTURE_ID in NUMBER default null,
			      OVERRIDE_RATE1	    in NUMBER default null,
			      OVERRIDE_RATE2	    in NUMBER default null,
			      OVERRIDE_RATE3	    in NUMBER default null,
			      OVERRIDE_RATE4	    in NUMBER default null,
			      OVERRIDE_RATE5	    in NUMBER default null,
			      OVERRIDE_RATE6	    in NUMBER default null,
			      OVERRIDE_RATE7	    in NUMBER default null,
			      OVERRIDE_RATE8	    in NUMBER default null,
			      OVERRIDE_RATE9	    in NUMBER default null,
			      OVERRIDE_RATE10	    in NUMBER default null
			    ) return number is

  location_rate_id number;
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN
  -- Stubbed out for R12
  null;
end ins_location_rates;


PROCEDURE ins_location_rates( location_segment_id in number,
                              from_postal_code in varchar2,
                              to_postal_code in varchar2,
                              start_date in date,
                              end_date in date,
                              tax_rate in number,
                              ATTRIBUTE_CATEGORY in varchar2 default 'TRIGGER',
                              ATTRIBUTE1         in varchar2 default null,
                              ATTRIBUTE2         in varchar2 default null,
                              ATTRIBUTE3         in varchar2 default null,
                              ATTRIBUTE4         in varchar2 default null,
                              ATTRIBUTE5         in varchar2 default null,
                              ATTRIBUTE6         in varchar2 default null,
                              ATTRIBUTE7         in varchar2 default null,
                              ATTRIBUTE8         in varchar2 default null,
                              ATTRIBUTE9         in varchar2 default null,
                              ATTRIBUTE10        in varchar2 default null,
                              ATTRIBUTE11        in varchar2 default null,
                              ATTRIBUTE12        in varchar2 default null,
                              ATTRIBUTE13        in varchar2 default null,
                              ATTRIBUTE14        in varchar2 default null,
                              ATTRIBUTE15        in varchar2 default null,
			      OVERRIDE_STRUCTURE_ID in NUMBER default null,
			      OVERRIDE_RATE1	    in NUMBER default null,
			      OVERRIDE_RATE2	    in NUMBER default null,
			      OVERRIDE_RATE3	    in NUMBER default null,
			      OVERRIDE_RATE4	    in NUMBER default null,
			      OVERRIDE_RATE5	    in NUMBER default null,
			      OVERRIDE_RATE6	    in NUMBER default null,
			      OVERRIDE_RATE7	    in NUMBER default null,
			      OVERRIDE_RATE8	    in NUMBER default null,
			      OVERRIDE_RATE9	    in NUMBER default null,
			      OVERRIDE_RATE10	    in NUMBER default null) is

  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN

  -- Stubbed out for R12
  null;
end ins_location_rates;

/*-------------------------------------------------------------------------+
 | PUBLIC  FUNCTION                                                        |
 |   ins_location_combinations                                             |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function generates a new record in the table:                    |
 |   AR_LOCATON_COMBINATIONS and returns the location code combinations id |
 |   for this new record.                                                  |
 |                                                                         |
 | REQUIRES                                                                |
 |   location_structure_id  Multiflex structure ID in use                  |
 |   start_date_active      Date at which Code combination becomes active  |
 |   end_date_active        Date at which Code combinatino becomes inactive|
 |   location_id_segment_1  Location_segment_id for segment 1 or null      |
 |   location_id_segment_2  Location_segment_id for segment 2 or null      |
 |   location_id_segment_3  Location_segment_id for segment 3 or null      |
 |   location_id_segment_4  Location_segment_id for segment 4 or null      |
 |   location_id_segment_5  Location_segment_id for segment 5 or null      |
 |   location_id_segment_6  Location_segment_id for segment 6 or null      |
 |   location_id_segment_7  Location_segment_id for segment 7 or null      |
 |   location_id_segment_8  Location_segment_id for segment 8 or null      |
 |   location_id_segment_9  Location_segment_id for segment 9 or null      |
 |   location_id_segment_10 Location_segment_id for segment 10 or null     |
 |                                                                         |
 | RETURNS                                                                 |
 |   LOCATION_CODE_COMBINATION_ID of the new record.                       |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/


FUNCTION ins_location_combinations(     LOCATION_STRUCTURE_ID  NUMBER,
                                        START_DATE_ACTIVE      DATE,
                                        END_DATE_ACTIVE        DATE,
                                        LOCATION_ID_SEGMENT_1  NUMBER,
                                        LOCATION_ID_SEGMENT_2  NUMBER,
                                        LOCATION_ID_SEGMENT_3  NUMBER,
                                        LOCATION_ID_SEGMENT_4  NUMBER,
                                        LOCATION_ID_SEGMENT_5  NUMBER,
                                        LOCATION_ID_SEGMENT_6  NUMBER,
                                        LOCATION_ID_SEGMENT_7  NUMBER,
                                        LOCATION_ID_SEGMENT_8  NUMBER,
                                        LOCATION_ID_SEGMENT_9  NUMBER,
                                        LOCATION_ID_SEGMENT_10 NUMBER,
                                        ENABLED_FLAG           varchar2 )
                                 return number IS
  location_id           number;
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN

  -- Stubbed out for R12
  null;
end ins_location_combinations;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   TERRITORY_SHORT_NAME                                                  |
 |                                                                         |
 | CALLED BY TRIGGER        AR_LOCATION_VALUES_BRIU                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | Given a territory code, this function returns the description for that  |
 | territory.                                                              |
 |                                                                         |
 | REQUIRES                                                                |
 |   territory_code         FK to FND_TERRITORIES.TERRITORY_CODE           |
 |                                                                         |
 | RETURNS                                                                 |
 |   Description            FND_TERRITORIES.DESCRIPTION                    |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |   NO_DATA_FOUND          If the FK is in error                          |
 |                                                                         |
 | NOTES                                                                   |
 |   Package variables: PREVIOUS_TERRITORY_CODE and PREVIOUS_TERRITORY_    |
 |   SHORT_NAME  cache the most recent database access.                    |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/


function terr_short_name( territory_code in varchar2 ) return varchar2 is

  l_territory_short_name  varchar2(80);
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN

  -- Stubbed out for R12
  null;
end terr_short_name;

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   Set_Location_CCID                                                     |
 |                                                                         |
 | CALLED BY TRIGGER        RA_ADDRESSES_BRIU                              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | Given Each of the key components of this address, find and set the      |
 | Location_ID column to the Code Combinations ID applicable to this       |
 | address.                                                                |
 |                                                                         |
 | In order to do this, it may be necessary to insert new items into       |
 | the tables: AR_LOCATION_VALUES and AR_LOCATION_COMBINATIONS             |
 |                                                                         |
 | REQUIRES                                                                |
 |   City                   City column of RA_ADDRESSES                    |
 |   State                  State column of RA_ADDRESSES                   |
 |   County                 County column of RA_ADDRESSES                  |
 |   Province               Province column of RA_ADDRESSES                |
 |   Country                Country column of RA_ADDRESSES                 |
 |   Postal Code            Postal Code column of RA_ADDRESSES             |
 |   DF1 .. 10              User Descriptive Flexfields 1 through 10       |
 |                                                                         |
 | RETURNS                                                                 |
 |  Location_ID             Set the Location Code Combination id           |
 |                          applicable to this address given each of the   |
 |                          segment values described above.                |
 | MODIFIES                                                                |
 |   Each of the address components may have the value NULL, even though   |
 |   it is used as part of the location flexfield. If so, this code will   |
 |   determine the missing value using the other segments and postal code  |
 |   and update this column to hold the correct value.                     |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

PROCEDURE Set_Location_CCID(  Country        in out NOCOPY varchar2,
                              City           in out NOCOPY varchar2,
                              State          in out NOCOPY varchar2,
                              County         in out NOCOPY varchar2,
			      Province       in out NOCOPY varchar2,
                              Postal_code    in out NOCOPY varchar2,
                              attribute1     in out NOCOPY varchar2,
                              attribute2     in out NOCOPY varchar2,
                              attribute3     in out NOCOPY varchar2,
                              attribute4     in out NOCOPY varchar2,
                              attribute5     in out NOCOPY varchar2,
                              attribute6     in out NOCOPY varchar2,
                              attribute7     in out NOCOPY varchar2,
                              attribute8     in out NOCOPY varchar2,
                              attribute9     in out NOCOPY varchar2,
                              attribute10    in out NOCOPY varchar2,
                              location_ccid  in out NOCOPY number,
			      address_id     in number default null ) IS

  l_location_segment_inserted varchar2(5);
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN
  -- Stubbed out for R12
  null;
end Set_Location_CCID;

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   Set_Location_CCID with org_id parameter                               |
 |                                                                         |
 | CALLED BY TRIGGER        RA_ADDRESSES_BRIU                              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | Given Each of the key components of this address, find and set the      |
 | Location_ID column to the Code Combinations ID applicable to this       |
 | address.                                                                |
 |                                                                         |
 | In order to do this, it may be necessary to insert new items into       |
 | the tables: AR_LOCATION_VALUES and AR_LOCATION_COMBINATIONS             |
 |                                                                         |
 | REQUIRES                                                                |
 |   City                   City column of RA_ADDRESSES                    |
 |   State                  State column of RA_ADDRESSES                   |
 |   County                 County column of RA_ADDRESSES                  |
 |   Province               Province column of RA_ADDRESSES                |
 |   Country                Country column of RA_ADDRESSES                 |
 |   Postal Code            Postal Code column of RA_ADDRESSES             |
 |   DF1 .. 10              User Descriptive Flexfields 1 through 10       |
 |   org_id                                                                |
 | RETURNS                                                                 |
 |  Location_ID             Set the Location Code Combination id           |
 |                          applicable to this address given each of the   |
 |                          segment values described above.                |
 | MODIFIES                                                                |
 |   Each of the address components may have the value NULL, even though   |
 |   it is used as part of the location flexfield. If so, this code will   |
 |   determine the missing value using the other segments and postal code  |
 |   and update this column to hold the correct value.                     |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES Added for bug 3105634                                             |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

PROCEDURE Set_Location_CCID(  Country        in out NOCOPY varchar2,
                              City           in out NOCOPY varchar2,
                              State          in out NOCOPY varchar2,
                              County         in out NOCOPY varchar2,
			      Province       in out NOCOPY varchar2,
                              Postal_code    in out NOCOPY varchar2,
                              attribute1     in out NOCOPY varchar2,
                              attribute2     in out NOCOPY varchar2,
                              attribute3     in out NOCOPY varchar2,
                              attribute4     in out NOCOPY varchar2,
                              attribute5     in out NOCOPY varchar2,
                              attribute6     in out NOCOPY varchar2,
                              attribute7     in out NOCOPY varchar2,
                              attribute8     in out NOCOPY varchar2,
                              attribute9     in out NOCOPY varchar2,
                              attribute10    in out NOCOPY varchar2,
                              location_ccid  in out NOCOPY number,
			      address_id     in number default null,
                              org_id         in number ) IS

  l_location_segment_inserted varchar2(5);
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN

  -- Stubbed out for R12
  null;
end Set_Location_CCID;
/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   return_location_defaults                                              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | Return the default values for the columns:-                             |
 |     start_date, end_date, from_postal_code and to_postal_code           |
 | in the table AR_LOCATION_RATES.                                         |
 |                                                                         |
 | MODIFIES                                                                |
 |    from_postal_code                                                     |
 |    to_postal_code                                                       |
 |    min_start_date                                                       |
 |    max_end_date                                                         |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

procedure return_location_defaults( from_postal_code out NOCOPY varchar2,
				    to_postal_code   out NOCOPY varchar2,
				    min_start_date   out NOCOPY date,
				    max_end_date     out NOCOPY date ) is

  dummy_varchar2        varchar2(2);
  dummy_date            date;
  c			integer;
  rows_processed	integer;
  statement		varchar2(1000);

BEGIN
  -- Stubbed out for R12
  null;
end return_location_defaults;

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   Initialize_Global_Variables                                           |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |   Initialize Global Variables, This routine has to be called            |
 |   before to use those variables.                                        |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

PROCEDURE Initialize_Global_Variables  IS
    c                   integer;
    rows_processed      integer;
    statement           varchar2(1000);
BEGIN

  -- Stubbed out for R12
  null;
END Initialize_Global_Variables;


/* global package initialization */

BEGIN

  -- Stubbed out for R12
  null;
END ARP_ADDS ;

/
