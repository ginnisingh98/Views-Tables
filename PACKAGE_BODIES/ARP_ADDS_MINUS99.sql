--------------------------------------------------------
--  DDL for Package Body ARP_ADDS_MINUS99
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ADDS_MINUS99" AS
/* $Header: ARPLXLOC.txt 115.5 2004/03/18 16:28:47 rpalani ship $      */

/*-------------------------------------------------------------------------+
|                                                                         |
| PRIVATE EXCEPTIONS                                                      |
|                                                                         |
+-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------+
|                                                                         |
| PRIVATE DATATYPES                                                       |
|                                                                         |
+-------------------------------------------------------------------------*/

type location_rates_type is RECORD
(
location_ccid         number,
location_id_segment_1 number,
location_id_segment_2 number,
location_id_segment_3 number,
total_tax_rate        number,
location1_rate        number,
location2_rate        number,
location3_rate        number,
location4_rate        number,
location5_rate        number,
location6_rate        number,
location7_rate        number,
location8_rate        number,
location9_rate        number,
location10_rate       number,
from_postal_code      varchar2(60),
to_postal_code        varchar2(60),
start_date            date,
end_date              date );

type tab_id_type is table of binary_integer index by binary_integer;

/*-------------------------------------------------------------------------+
|                                                                         |
| PRIVATE VARIABLES                                                       |
|                                                                         |
+-------------------------------------------------------------------------*/

NULL_SEGMENT_QUALIFIER varchar2(60) := NULL;

previous_territory_code fnd_territories.territory_code%TYPE := NULL;
previous_territory_short_name VARCHAR2(80) := NULL;
--PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*-------------------------------------------------------------------------+
| PRIVATE CURSOR                                                          |
|   ar_location_combations_s_c                                            |
|                                                                         |
| DESCRIPTION                                                             |
|   Return the next value from the sequence AR_LOCATION_COMBINATINOS_S    |
|                                                                         |
| REQUIRES                                                                |
|                                                                         |
| RETURNS                                                                 |
|   Sequence ID + large constant used for debugging                       |
|                                                                         |
| EXCEPTIONS RAISED                                                       |
|                                                                         |
| NOTES                                                                   |
|                                                                         |
| EXAMPLE                                                                 |
|                                                                         |
+-------------------------------------------------------------------------*/



CURSOR ar_location_combinations_s_c is
   select ar_location_combinations_s.nextval + arp_standard.sequence_offset
   from dual;




/*-------------------------------------------------------------------------+
| PRIVATE CURSOR                                                          |
|   ar_location_values_s_c                                                |
|                                                                         |
| DESCRIPTION                                                             |
|   Return the next value from the sequence AR_LOCATION_VALUES_S          |
|                                                                         |
| REQUIRES                                                                |
|                                                                         |
| RETURNS                                                                 |
|   Sequence ID + large constant used for debugging                       |
|                                                                         |
| EXCEPTIONS RAISED                                                       |
|                                                                         |
| NOTES                                                                   |
|                                                                         |
| EXAMPLE                                                                 |
|                                                                         |
+-------------------------------------------------------------------------*/


CURSOR ar_location_values_s_c IS
select ar_location_values_s.nextval + arp_standard.sequence_offset
from dual;



/*-------------------------------------------------------------------------+
| PRIVATE CURSOR                                                          |
|   ar_location_tax_account_c
|                                                                         |
| DESCRIPTION                                                             |
|   Return the tax account id from ar_vat_tax where tax type is LOCATION
|                                                                         |
| REQUIRES                                                                |
|                                                                         |
| RETURNS                                                                 |
|   location tax code's tax account id
|                                                                         |
| EXCEPTIONS RAISED                                                       |
|                                                                         |
| NOTES                                                                   |
|     19-Jun-00  NIPATEL  Modified the cursor to select from multi-org    |
|                         table AR_VAT_TAX_ALL using C_ORG_ID for         |
|                         Location Flexfield Sharing project.             |
| EXAMPLE                                                                 |
|                                                                         |
+-------------------------------------------------------------------------*/


CURSOR ar_location_tax_account_c (c_org_id in number) IS
select
	tax_account_id,
	INTERIM_TAX_CCID,
	ADJ_CCID,
	EDISC_CCID,
	UNEDISC_CCID,
	FINCHRG_CCID,
	ADJ_NON_REC_TAX_CCID,
	EDISC_NON_REC_TAX_CCID,
	UNEDISC_NON_REC_TAX_CCID,
	FINCHRG_NON_REC_TAX_CCID
from ar_vat_tax_all vat
where tax_type='LOCATION'
and   org_id = c_org_id
and   trunc(sysdate) between start_date and nvl(end_date, trunc(sysdate));



/*-------------------------------------------------------------------------+
| PRIVATE CURSOR                                                          |
|   ar_location_accounts_s_c                                              |
|                                                                         |
| DESCRIPTION                                                             |
|    Return the next value from the sequence AR_LOCATION_ACCOUNTS_S       |
|                                                                         |
| REQUIRES                                                                |
|                                                                         |
| RETURNS                                                                 |
|    Sequence ID + large constant used for debugging                      |
|                                                                         |
| EXCEPTIONS RAISED                                                       |
|                                                                         |
| MODIFICATION HISTORY                                                    |
|     19-Jun-00  NIPATEL  Created for Location Flexfield Sharing project. |
|                                                                         |
+-------------------------------------------------------------------------*/

CURSOR ar_location_accounts_s_c IS
select ar_location_accounts_s.nextval + arp_standard.sequence_offset
from dual;



/*------------------------------------------------------------------------+
| PRIVATE CURSOR                                                          |
|   organization_id_c                                                     |
|                                                                         |
| DESCRIPTION                                                             |
|    Used to select distinct ORG_ID from AR_SYSTEM_PARAMETERS_ALL         |
|    to create one record per ORG_ID for a new location_id in             |
|    AR_LOCATION_ACCOUNTS_ALL                                             |
|                                                                         |
| REQUIRES                                                                |
|                                                                         |
| RETURNS                                                                 |
|    Returns distinct ORG_ID from AR_SYSTEM_PARAMETERS_ALL                |
|                                                                         |
| EXCEPTIONS RAISED                                                       |
|                                                                         |
| MODIFICATION HISTORY                                                    |
|     19-Jun-00  NIPATEL  Created for Location Flexfield Sharing project. |
|                                                                         |
|                                                                         |
+-------------------------------------------------------------------------*/

-- Organization Ids -3113 and -3114 are seeded in ar_system_parameters
-- and we do not want to create records in ar_location_accounts_all table
-- for these org_id's. Hence we do not select them in the cursor.

CURSOR organization_id_c is
select nvl(org_id, -99), location_structure_id
from   ar_system_parameters_all
where  nvl(org_id, -99) not in (-3113, -3114)
and    set_of_books_id <> -1;


/*-------------------------------------------------------------------------+
| PRIVATE CURSOR                                                          |
|   ar_location_rates_s_c                                                 |
|                                                                         |
| DESCRIPTION                                                             |
|   Return the next value from the sequence AR_LOCATION_RATES_S           |
|                                                                         |
| REQUIRES                                                                |
|                                                                         |
| RETURNS                                                                 |
|   Sequence ID + large constant used for debugging                       |
|                                                                         |
| EXCEPTIONS RAISED                                                       |
|                                                                         |
| NOTES                                                                   |
|                                                                         |
| EXAMPLE                                                                 |
|                                                                         |
+-------------------------------------------------------------------------*/


CURSOR ar_location_rates_s_c IS
       select ar_location_rates_s.nextval + arp_standard.sequence_offset
       from dual;


/*-------------------------------------------------------------------------+
| PUBLIC FUNCTION                                                         |
|   find_missing_parent_in_loc                                            |
|                                                                         |
| DESCRIPTION                                                             |
|   This function Returns a parent value in AR_LOCATION_VALUES for any    |
|   given segment of a location flexfield.  This is required because it   |
|   is quite normal not to specifiy the county for any address within the |
|   United states of America.                                             |
|                                                                         |
|   First of all, try to find the records without using postal code       |
|   and if this fails because the same child occurs in two different      |
|   different states, then find the record using postal code to restrict  |
|   the states that can be selected.                                      |
|                                                                         |
| REQUIRES                                                                |
|   location_segment_qualifier Identifies which segment this is           |
|   value               Name of Child segment, eg the city of Belmont     |
|                                                                         |
| RETURNS                                                                 |
|   Segment value for parent, EG County of "San Mateo"                    |
|                                                                         |
| EXCEPTIONS RAISED                                                       |
|   Oracle Error        If any given child( city ) has two or more        |
|                       parents with different names, and postal codes    |
|                       cannot be be used to resolve the naming conflict. |
|   NO_DATA_FOUND       If no parent can be found.                        |
|                                                                         |
| NOTES                                                                   |
|                                                                         |
| EXAMPLE                                                                 |
|                                                                         |
|                                                                         |
| MODIFICATION HISTORY                                                    |
|    22-Jan-93  Nigel Smith        Created.                               |
|    04-Mar-93  Nigel Smith        BUGFIX, find_missing_parent_in_loc,    |
|                                  now cheks parent zip range not child   |
+-------------------------------------------------------------------------*/


FUNCTION find_missing_parent_in_loc( p_location_segment_qualifier in varchar2,
                                     p_value          in varchar2,
                                     p_postal_code    in varchar2 )
         return varchar2 IS

 parent_value varchar2(60);

BEGIN


   SELECT DISTINCT v1.location_segment_value  into parent_value
   from   ar_location_values v2,
          ar_location_values v1
   WHERE  v1.location_segment_id  = v2.parent_segment_id
   and    v2.location_segment_value = rtrim(ltrim(upper(p_value)))
   and    v2.location_segment_qualifier = p_location_segment_qualifier
   and    v1.location_structure_id = arp_standard.sysparm.location_structure_id
   and    v2.location_structure_id = arp_standard.sysparm.location_structure_id;

   RETURN( parent_value );

EXCEPTION

   WHEN TOO_MANY_ROWS
   THEN
   BEGIN

      /*--------------------------------------------------------------------+
      | There are multiple parents ( counties ) with the same name, we are |
      | forced to use postal code to distinguish one from another. This    |
      | could have been done intitially, but would have a performance      |
      | impact for the majority of cases                                   |
      +--------------------------------------------------------------------*/

      if ( p_postal_code is not null )
      then

      SELECT DISTINCT v1.location_segment_value  into parent_value
      from   ar_location_values v2,
      ar_location_values v1,
      ar_location_rates  r1
      WHERE  v1.location_segment_id  = v2.parent_segment_id
      and    v2.location_segment_value = ltrim(rtrim(upper(p_value)))
      and    v2.location_segment_qualifier = p_location_segment_qualifier
      and    v2.location_segment_id = r1.location_segment_id
      and    v1.location_structure_id = arp_standard.sysparm.location_structure_id
      and    v2.location_structure_id = arp_standard.sysparm.location_structure_id
      and    p_postal_code between r1.from_postal_code and r1.to_postal_code
      and    sysdate between r1.start_date and r1.end_date;

      else RAISE NO_DATA_FOUND;
      end if;

      RETURN( parent_value );

   EXCEPTION
   WHEN TOO_MANY_ROWS
      /*--------------------------------------------------------------------+
      | Postal Codes cannot help us resolve the name conflict, report the  |
      | error back to the user                                             |
      *--------------------------------------------------------------------*/
      THEN arp_standard.fnd_message( 'AR_PP_ADDS_TOO_MANY_PARENTS', 'CHILD', rtrim(p_value, ' ') );

 IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug('TOO MANY PARENTS FOR THE GIVEN POSTAL CODE');
 END IF;

   END;

END find_missing_parent_in_loc;


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

/*------------------------------------------------------------------------+
 | PRIVATE CURSOR                                                         |
 |   location_value_given_parent_c                                        |
 |                                                                        |
 | DESCRIPTION                                                            |
 |   Check AR_LOCATION_VALUES for existing location_segment_id given      |
 |   parent_segment_id and location_segment_value.                        |
 |                                                                        |
 | WARNING                                                                |
 |   DO NOT MODIFY THIS CURSOR ADDING ANY SELECT COLUMNS.                 |
 |   The select does not perform any table accesses, utilising index      |
 |   only access from AR_LOCATION_VALUES_U2.                              |
 |                                                                        |
 | EXPLAIN PLAN                                                           |
 |   OPERATION              OPTIONS         OBJECT_NAME                   |
 |   ---------------------- --------------- ----------------------------- |
 |   INDEX                  RANGE SCAN      AR_LOCATION_VALUES_U2         |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |    22-Jan-93  Nigel Smith   Created.                                   |
 +------------------------------------------------------------------------*/


CURSOR location_value_given_parent_c( p_location_segment_qualifier    in varchar2,
                                      p_segment_value     in varchar2,
                                      p_parent_segment_id in number) is
   select location_segment_id
   from   ar_location_values
   where  location_segment_qualifier = p_location_segment_qualifier
   and    location_structure_id = arp_standard.sysparm.location_structure_id
   and    parent_segment_id = p_parent_segment_id
   and    location_segment_value = rtrim(upper(p_segment_value), ' ');


CURSOR location_value_max_width_c(    p_location_segment_qualifier    in varchar2,
                                      p_segment_value     in varchar2,
                                      p_parent_segment_id in number,
				      p_search_precission in number) is
   select location_segment_id
   from   ar_location_values
   where  location_segment_qualifier = p_location_segment_qualifier
   and    location_structure_id = arp_standard.sysparm.location_structure_id
   and    parent_segment_id = p_parent_segment_id
   and    substr(location_segment_value,1,p_search_precission)
	= substr(rtrim(upper(p_segment_value), ' '),1,p_search_precission);
   /*** MB skip for above substr, because the idea is to compare  ***/
   /*** two strings, so it is ok and the compare length is same ***/


CURSOR location_value_no_parent_c( p_location_segment_qualifier in varchar2,
                                   p_segment_value  in varchar2 ) IS
   select location_segment_id
   from   ar_location_values
   where  location_segment_qualifier = p_location_segment_qualifier
   and    location_structure_id = arp_standard.sysparm.location_structure_id
   and    location_segment_value = rtrim(upper(p_segment_value), ' ' );

location_segment_id    number;
override	       number;

BEGIN
 IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '>> FIND_LOCATION_SEGMENT_ID( ' ||
                       location_segment_qualifier || ', ' ||
                       segment_value ||  ', ' ||
                       segment_description || ', ' ||
                       parent_segment_id || ' ) ' );
  END IF;

   location_segment_inserted := FALSE;

   IF segment_value is not null
   THEN
   BEGIN
      IF parent_segment_id is null
      THEN
         /*----------------------------------------------------------------------+
          | This is the first segment of the location flexfield and as such has  |
          | no parent. Open a cursor pasing in just the value set name and       |
          | segment value.                                                       |
          *----------------------------------------------------------------------*/
         OPEN location_value_no_parent_c( location_segment_qualifier, ltrim(rtrim(segment_value)) );
         FETCH location_value_no_parent_c into location_segment_id;
         IF    location_value_no_parent_c%NOTFOUND
         THEN
            CLOSE location_value_no_parent_c;
            GOTO location_not_found;
         END IF;
         CLOSE location_value_no_parent_c;
      ELSE
        /*---------------------------------------------------------------------+
         | This is a dependent segment, and as such find a location value with |
         | the named parent.                                                   |
         +---------------------------------------------------------------------*/

         OPEN location_value_given_parent_c( location_segment_qualifier,
                                             ltrim(rtrim(segment_value)),
                                             parent_segment_id );

         FETCH location_value_given_parent_c into location_segment_id;
         IF    location_value_given_parent_c%NOTFOUND
         THEN
            CLOSE location_value_given_parent_c;
            goto location_not_found;
         END IF;
         CLOSE location_value_given_parent_c;
      END IF;
     IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug( '<< FIND_LOCATION_SEGMENT_ID: EXISTING ROW '
	                  || to_char(location_segment_id) );
     END IF;

      return( location_segment_id );

   END;
   ELSE

   /*----------------------------------------------------------------------------+
   | Oracle Receivables has found a null value for a segment when this location |
   | has nevever been used before. It is impossible to deduce what should be    |
   | the correct value to use.                                                  |
   +----------------------------------------------------------------------------*/

   /*----------------------------------------------------------------------------+
   | Normal operation requires that an exception be raised if this package      |
   | cannot guess the correct value of any missing segment                      |
   *----------------------------------------------------------------------------*/

      NULL_SEGMENT_QUALIFIER := LOCATION_SEGMENT_QUALIFIER;
      RAISE LOCATION_SEGMENT_NULL_VALUE;

   END IF;

<<location_not_found>>

   -- EXCEPTIONS are not used even though initial design called for them.
   -- Attempting to illeminate end-of-file error on communication channel
   -- returned from RDBMS.

   /*-------------------------------------------------------------------------+
    | Use only the first n characters of the existing location_value database |
    | and re-attempt to find the location using this search precission.       |
    +-------------------------------------------------------------------------*/

   -- Check if the width of this location is equal to the search precission
   -- if any was specificed, if so re-attempt this search using just the
   -- first nn character in ar_location_values.location_segment_value
   -- BUGFIX: INC: 27093

   /*** MB skip, we want to see if the character length of segment_value ***/
   /*** >= search_precission ***/
   IF  length( segment_value ) >= search_precission
       and parent_segment_id is not null
   THEN
   BEGIN

      OPEN location_value_max_width_c( location_segment_qualifier,
                                       ltrim(rtrim(segment_value)),
                                       parent_segment_id,
                                       search_precission );

      FETCH location_value_max_width_c into location_segment_id;
      IF    location_value_max_width_c%NOTFOUND
      THEN
         CLOSE location_value_max_width_c;
         goto insert_new_location;
      END IF;
      CLOSE location_value_max_width_c;
     IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug( '<< FIND_LOCATION_SEGMENT_ID: EXISTING ROW(PRECISSION) '
                           || to_char(location_segment_id) );
      END IF;
      return( location_segment_id );

   END;
   END IF;

<<insert_new_location>>

   /*-----------------------------------------------------------------------+
    | This value has never been used before, insert it into the value sets  |
    | table and return the unique id assoicated with this value             |
    +-----------------------------------------------------------------------*/

    location_segment_inserted := TRUE;
    location_segment_id := ins_location_values( location_segment_qualifier,
       ltrim(rtrim(segment_value)),
       segment_description,
       parent_segment_id,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15 );


    if ARP_ADDS_MINUS99.populate_location_rates
    then

	/*--------------------------------------------------------------------+
         | If this flag is set, then new location_value records automatically |
         | get a rate record assigned to them.                                |
         +--------------------------------------------------------------------*/

	/*--------------------------------------------------+
         | CITY SEGMENTS MUST HAVE AN OVERRIDE STRUCTURE ID |
         | COLUMN ASSIGNED TO THEM.                         |
         +--------------------------------------------------*/

       if location_segment_qualifier = 'CITY'
       then
          override := arp_standard.sysparm.location_structure_id;
       else
          override := null;
       end if;

       ins_location_rates( location_segment_id,
			    arp_standard.sysparm.from_postal_code,
			    arp_standard.sysparm.to_postal_code,
		            arp_standard.min_start_date,
			    arp_standard.max_end_date,
			    0,
			    'TRIGGER',
		            attribute1,
		            attribute2,
		            attribute3,
		            attribute4,
		            attribute5,
		            attribute6,
		            attribute7,
		            attribute8,
		            attribute9,
		            attribute10,
		            attribute11,
		            attribute12,
		            attribute13,
		            attribute14,
		            attribute15,
			    OVERRIDE_STRUCTURE_ID => override
			   );
    end if;

 IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '<< FIND_LOCATION_SEGMENT_ID: NEW ROW ' || to_char(location_segment_id) );
 END IF;

    return( location_segment_id );

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


begin

   select location_segment_value,
          location_segment_description,
          location_segment_qualifier,
          parent_segment_id
   into   location_segment_value,
          location_segment_description,
          location_segment_qualifier,
          parent_segment_id
   from   ar_location_values
   where  location_segment_id = location_information.location_segment_id;

end;


procedure location_information( location_segment_qualifier   in varchar2,
                                location_segment_value       in  varchar2,
                                location_segment_description out NOCOPY varchar2,
                                parent_segment_id out NOCOPY number ) is


   begin

   select location_segment_description,
          parent_segment_id
   into   location_segment_description,
          parent_segment_id
   from   ar_location_values v1
   where  v1.location_segment_qualifier = location_information.location_segment_qualifier
   and    v1.location_segment_value = ltrim(rtrim(upper(location_information.location_segment_value)))
   and    v1.location_structure_id = arp_standard.sysparm.location_structure_id;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
   BEGIN
      select max(location_segment_description), max(parent_segment_id)
      into   location_segment_description, parent_segment_id
      from   ar_location_values v1
      where  v1.location_segment_qualifier = location_information.location_segment_qualifier
      and    v1.location_structure_id = arp_standard.sysparm.location_structure_id
      and    v1.location_segment_value = ltrim(rtrim(location_information.location_segment_value));
   END;

end;


function location_description( location_segment_qualifier in varchar2,
                               location_segment_value     in varchar2 )
         return varchar2 is


 location_segment_description varchar2(60);
 parent_segment_id number;
 location_segment_id number;

begin

location_information( location_segment_qualifier, location_segment_value,
	                 location_segment_description,
	                 location_segment_id );

   return( location_segment_description );

end;



function location_description( location_segment_id in number )
   return varchar2 is

   location_segment_description varchar2(60);
   parent_segment_id number;
   location_segment_value varchar2(60);
   location_segment_qualifier varchar2(30);

begin

   location_information( location_segment_id,
			 location_segment_qualifier,
			 location_segment_value,
	                 location_segment_description,
	                 parent_segment_id );

   return( location_segment_description );

end;



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
begin
   triggers_enabled := TRUE;
end;

procedure disable_triggers is
begin
   triggers_enabled := FALSE;
end;




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

    location_id number;
    l_organization_id number;
    location_value_account_id number;
    location_segment_value ar_location_values.location_segment_value%TYPE;
    location_segment_user_value ar_location_values.location_segment_user_value%TYPE;
    location_segment_description ar_location_values.location_segment_description%TYPE;

BEGIN
   IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '>> INS_LOCATION_VALUES( ' ||
	       location_segment_qualifier || ', ' ||
               segment_value ||  ', ' ||
               segment_description || ', ' ||
               parent_segment_id || ' ) ' );
   END IF;
   location_segment_value := ltrim(rtrim(upper( segment_value )));
   location_segment_user_value := ltrim(rtrim( segment_value ));
   location_segment_description := initcap( segment_description );

   OPEN  ar_location_values_s_c;
   FETCH ar_location_values_s_c into location_id;
   CLOSE ar_location_values_s_c;

   insert into ar_location_values( location_structure_id,
                                   location_segment_qualifier,
                                   location_segment_id,
                                   location_segment_value,
                                   location_segment_user_value,
                                   location_segment_description,
                                   parent_segment_id,
                                   request_id,
                                   program_application_id,
                                   program_id,
                                   program_update_date,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   attribute_category,
                                   attribute1,
                                   attribute2,
                                   attribute3,
                                   attribute4,
                                   attribute5,
                                   attribute6,
                                   attribute7,
                                   attribute8,
                                   attribute9,
                                   attribute10,
                                   attribute11,
                                   attribute12,
                                   attribute13,
                                   attribute14,
                                   attribute15 )
   VALUES ( arp_standard.sysparm.location_structure_id,
            location_segment_qualifier,
            location_id,
            location_segment_value,
            location_segment_user_value,
            location_segment_description,
            parent_segment_id,
            arp_standard.PROFILE.request_id,
            arp_standard.PROFILE.program_application_id,
            arp_standard.PROFILE.program_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.PROFILE.last_update_login,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15 );

--  Insert accounting information into ar_location_accounts_all
--  One record will be inserted for each Org_id.

    ins_location_accounts
                       ( location_id,
                         location_segment_qualifier);
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug( '<< INS_LOCATION_VALUES: ' || to_char(location_id) );
    END IF;
   return( location_id );

END ins_location_values;


/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   ins_location_accounts                                                 |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This procedure generates new records in the table:                    |
 |   AR_LOCATION_ACCOUNTS. One record is created for each ORG_ID           |
 |   so as to Accounting information in this table is Organization         |
 |   independent and so that location structure can be shared across       |
 |   Organizations.                                                        |
 |                                                                         |
 | REQUIRES                                                                |
 |   location_segment_qualifier      Value set name used of this segment   |
 |   location_segment_id             Foreign Key to AR_LOCATION_VALUES     |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     19-Jun-00  NIPATEL  Created for Location Flexfield Sharing project. |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

PROCEDURE ins_location_accounts
                            ( location_segment_id        in number,
                              location_segment_qualifier in varchar2)
IS

  l_location_value_account_id number;
  location_tax_account       number;
	l_INTERIM_TAX_CCID		NUMBER;
	l_ADJ_CCID			NUMBER;
	l_EDISC_CCID			NUMBER;
	l_UNEDISC_CCID			NUMBER;
	l_FINCHRG_CCID			NUMBER;
	l_ADJ_NON_REC_TAX_CCID		NUMBER;
	l_EDISC_NON_REC_TAX_CCID	NUMBER;
	l_UNEDISC_NON_REC_TAX_CCID	NUMBER;
	l_FINCHRG_NON_REC_TAX_CCID	NUMBER;

  type num_tab is table of number index by binary_integer;
  type date_tab is table of date index by binary_integer;
  org_id_tab num_tab;
  loc_structure_id_tab num_tab;

 location_account_id_tab      num_tab;
 location_segment_id_tab      num_tab;
 tax_account_ccid_tab         num_tab;
 interim_tax_ccid_tab         num_tab;
 adj_ccid_tab                 num_tab;
 edisc_ccid_tab               num_tab;
 unedisc_ccid_tab             num_tab;
 finchrg_ccid_tab             num_tab;
 adj_non_rec_tax_ccid_tab     num_tab;
 edisc_non_rec_tax_ccid_tab   num_tab;
 unedisc_non_rec_tax_ccid_tab num_tab;
 finchrg_non_rec_tax_ccid_tab num_tab;
 created_by_tab               num_tab;
 creation_date_tab            date_tab;
 last_updated_by_tab          num_tab;
 last_update_date_tab         date_tab;
 request_id_tab               num_tab;
 program_application_id_tab   num_tab;
 program_id_tab               num_tab;
 program_update_date_tab      date_tab;
 last_update_login_tab        num_tab;
 organization_id_tab          num_tab;

BEGIN
  IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '>> INS_LOCATION_ACCOUNTS( ' ||
	              location_segment_qualifier ||', '||
                to_char(Location_segment_id)||' ) ');
  END IF;
 -- Records will be inserted into AR_LOCATION_ACCOUNTS_ALL only if
 -- the segment has qualifier 'Tax Account' enabled.

 if location_segment_qualifier = 'STATE'
 then

   org_id_tab.delete;
   loc_structure_id_tab.delete;

   location_account_id_tab.delete;
   location_segment_id_tab.delete;
   tax_account_ccid_tab.delete;
   interim_tax_ccid_tab.delete;
   adj_ccid_tab.delete;
   edisc_ccid_tab.delete;
   unedisc_ccid_tab.delete;
   finchrg_ccid_tab.delete;
   adj_non_rec_tax_ccid_tab.delete;
   edisc_non_rec_tax_ccid_tab.delete;
   unedisc_non_rec_tax_ccid_tab.delete;
   finchrg_non_rec_tax_ccid_tab.delete;
   created_by_tab.delete;
   creation_date_tab.delete;
   last_updated_by_tab.delete;
   last_update_date_tab.delete;
   request_id_tab.delete;
   program_application_id_tab.delete;
   program_id_tab.delete;
   program_update_date_tab.delete;
   last_update_login_tab.delete;
   organization_id_tab.delete;


   open organization_id_c ;
   fetch organization_id_c bulk collect into
             org_id_tab, loc_structure_id_tab;
   close organization_id_c ;

   -- Insert records into ar_location_accounts_all
   for I in 1..org_id_tab.last loop

        	      location_tax_account := NULL;
 	              l_INTERIM_TAX_CCID := NULL;
	              l_ADJ_CCID := NULL;
	              l_EDISC_CCID := NULL;
	              l_UNEDISC_CCID := NULL;
	              l_FINCHRG_CCID := NULL;
	              l_ADJ_NON_REC_TAX_CCID := NULL;
	              l_EDISC_NON_REC_TAX_CCID := NULL;
	              l_UNEDISC_NON_REC_TAX_CCID := NULL;
	              l_FINCHRG_NON_REC_TAX_CCID := NULL;

          OPEN  ar_location_tax_account_c(org_id_tab(I));
	        FETCH ar_location_tax_account_c into
   	            location_tax_account,
	              l_INTERIM_TAX_CCID,
	              l_ADJ_CCID,
	              l_EDISC_CCID,
	              l_UNEDISC_CCID,
	              l_FINCHRG_CCID,
	              l_ADJ_NON_REC_TAX_CCID,
	              l_EDISC_NON_REC_TAX_CCID,
	              l_UNEDISC_NON_REC_TAX_CCID,
	              l_FINCHRG_NON_REC_TAX_CCID;

           if ar_location_tax_account_c%NOTFOUND
           then
	             location_tax_account:=arp_standard.sysparm.location_tax_account;
	         end if;
           CLOSE ar_location_tax_account_c;


           OPEN ar_location_accounts_s_c;
           FETCH ar_location_accounts_s_c into
                   l_location_value_account_id;
           CLOSE ar_location_accounts_s_c;

           location_account_id_tab(i)      := l_location_value_account_id;
           location_segment_id_tab(i)      := location_segment_id;
           tax_account_ccid_tab(i)         := location_tax_account;
           interim_tax_ccid_tab(i)         := l_INTERIM_TAX_CCID;
           adj_ccid_tab(i)                 := l_ADJ_CCID;
           edisc_ccid_tab(i)               := l_EDISC_CCID;
           unedisc_ccid_tab(i)             := l_UNEDISC_CCID;
           finchrg_ccid_tab(i)             := l_FINCHRG_CCID;
           adj_non_rec_tax_ccid_tab(i)     := l_ADJ_NON_REC_TAX_CCID;
           edisc_non_rec_tax_ccid_tab(i)   := l_EDISC_NON_REC_TAX_CCID;
           unedisc_non_rec_tax_ccid_tab(i) := l_UNEDISC_NON_REC_TAX_CCID;
           finchrg_non_rec_tax_ccid_tab(i) := l_FINCHRG_NON_REC_TAX_CCID;
           created_by_tab(i)               := arp_standard.profile.user_id;
           creation_date_tab(i)            := sysdate;
           last_updated_by_tab(i)          := arp_standard.profile.user_id;
           last_update_date_tab(i)         := sysdate;
           request_id_tab(i)               := arp_standard.PROFILE.request_id;
           program_application_id_tab(i)   :=
                                    arp_standard.PROFILE.program_application_id;
           program_id_tab(i)               := arp_standard.PROFILE.program_id;
           program_update_date_tab(i)      := sysdate;
           last_update_login_tab(i)        := arp_standard.PROFILE.last_update_login;
           organization_id_tab(i)          := org_id_tab(I);

      end loop;

      forall I in 1.. organization_id_tab.last
           insert into ar_location_accounts_all
                                 ( location_value_account_id,
                                   location_segment_id,
                                   tax_account_ccid,
                                   interim_tax_ccid,
                                   adj_ccid,
                                   edisc_ccid,
                                   unedisc_ccid,
                                   finchrg_ccid,
                                   adj_non_rec_tax_ccid,
                                   edisc_non_rec_tax_ccid,
                                   unedisc_non_rec_tax_ccid,
                                   finchrg_non_rec_tax_ccid,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   request_id,
                                   program_application_id,
                                   program_id,
                                   program_update_date,
                                   last_update_login,
                                   org_id)
   		VALUES
               ( location_account_id_tab(i),
            	 location_segment_id_tab(i),
                 tax_account_ccid_tab(i),
                 interim_tax_ccid_tab(i),
                 adj_ccid_tab(i),
                 edisc_ccid_tab(i),
                 unedisc_ccid_tab(i),
                 finchrg_ccid_tab(i),
                 adj_non_rec_tax_ccid_tab(i),
                 edisc_non_rec_tax_ccid_tab(i),
                 unedisc_non_rec_tax_ccid_tab(i),
                 finchrg_non_rec_tax_ccid_tab(i),
                 created_by_tab(i),
                 creation_date_tab(i),
                 last_updated_by_tab(i),
                 last_update_date_tab(i),
                 request_id_tab(i),
                 program_application_id_tab(i),
                 program_id_tab(i),
                 program_update_date_tab(i),
                 last_update_login_tab(i),
                 organization_id_tab(i) );

  end if;  -- location_segment_qualifier = 'AR_TAX_ACCOUNT_SEGMENT'
   IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug( '<< INS_LOCATION_ACCOUNTS: ' ||
                         to_char(l_location_value_account_id) );
   END IF;

Exception
    when others then
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug(' Exception in ARP_ADDS.ins_location_Accounts '||
                               SQLCODE||' ; '||SQLERRM );
     END IF;

          if organization_id_c%isopen then
                close organization_id_c;
          end if;

          if ar_location_tax_account_c%isopen then
                close ar_location_tax_account_c;
          end if;

          if ar_location_accounts_s_c%isopen then
                close ar_location_accounts_s_c;
          end if;

End ins_location_accounts;


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

BEGIN

   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug( '>> INS_LOCATION_RATES( ' ||
	       location_segment_id || ', ' ||
               from_postal_code ||  ', ' ||
               to_postal_code || ', ' ||
               start_date || ', ' ||
               end_date || ', ' ||
               tax_rate || ' ) ' );
   END IF;

   if location_segment_id is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'LOCATION_SEGMENT_ID' );
   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('Location segment id is null');
   END IF;
   end if;
   if from_postal_code is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'FROM_POSTAL_CODE' );

   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('From postal code  is null');
   END IF;

   end if;
   if to_postal_code is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'TO_POSTAL_CODE' );

   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('To postal code  is null');
   END IF;

   end if;
   if start_date is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'START_DATE' );

   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('start date  is null');
   END IF;

   end if;
   if end_date is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'END_DATE' );

   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('End date  is null');
   END IF;

   end if;

   OPEN  ar_location_rates_s_c;
   FETCH ar_location_rates_s_c into location_rate_id;
   CLOSE ar_location_rates_s_c;

   insert into ar_location_rates( location_rate_id,
                                  location_segment_id,
                                  from_postal_code,
                                  to_postal_code,
                                  start_date,
                                  end_date,
                                  tax_rate,
                                  request_id,
                                  program_application_id,
                                  program_id,
                                  program_update_date,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login,
                                  attribute_category,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15,
				  override_structure_id,
				  override_rate1,
				  override_rate2,
				  override_rate3,
				  override_rate4,
				  override_rate5,
				  override_rate6,
				  override_rate7,
				  override_rate8,
				  override_rate9,
				  override_rate10  )
   VALUES ( location_rate_id,
            location_segment_id,
            from_postal_code,
            to_postal_code,
            start_date,
            end_date,
            tax_rate,
            arp_standard.PROFILE.request_id,
            arp_standard.PROFILE.program_application_id,
            arp_standard.PROFILE.program_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.PROFILE.last_update_login,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            override_structure_id,
            override_rate1,
            override_rate2,
            override_rate3,
            override_rate4,
            override_rate5,
            override_rate6,
            override_rate7,
            override_rate8,
            override_rate9,
            override_rate10  );

   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug( '<< INS_LOCATION_RATES: ' || to_char(location_rate_id) );
   END IF;

   return( location_rate_id );

END ins_location_rates;

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

BEGIN
   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug( '>> INS_LOCATION_RATES( ' ||
	       location_segment_id || ', ' ||
               from_postal_code ||  ', ' ||
               to_postal_code || ', ' ||
               start_date || ', ' ||
               end_date || ', ' ||
               tax_rate || ' ) ' );
   END IF;

   if location_segment_id is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'LOCATION_SEGMENT_ID' );

    IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('Location segment id is null');
    END IF;

   end if;
   if from_postal_code is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'FROM_POSTAL_CODE' );
   IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug('From postal code is null');
   END IF;

   end if;
   if to_postal_code is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'TO_POSTAL_CODE' );

   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('To postal code is null');
   END IF;

   end if;
   if start_date is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'START_DATE' );
   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('start date is null');
   END IF;

   end if;
   if end_date is null
   then
      arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'ARP_ADDS_MINUS99INS_LOCATION_RATES', 'PARAMETER', 'END_DATE' );

  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug('End date is null');
  END IF;
   end if;

   insert into ar_location_rates( location_rate_id,
                                  location_segment_id,
                                  from_postal_code,
                                  to_postal_code,
                                  start_date,
                                  end_date,
                                  tax_rate,
                                  request_id,
                                  program_application_id,
                                  program_id,
                                  program_update_date,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login,
                                  attribute_category,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15,
				  override_structure_id,
				  override_rate1,
				  override_rate2,
				  override_rate3,
				  override_rate4,
				  override_rate5,
				  override_rate6,
				  override_rate7,
				  override_rate8,
				  override_rate9,
				  override_rate10  )
   VALUES ( ar_location_rates_s.nextval + arp_standard.sequence_offset,
            location_segment_id,
            from_postal_code,
            to_postal_code,
            start_date,
            end_date,
            tax_rate,
            arp_standard.PROFILE.request_id,
            arp_standard.PROFILE.program_application_id,
            arp_standard.PROFILE.program_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.PROFILE.last_update_login,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            override_structure_id,
            override_rate1,
            override_rate2,
            override_rate3,
            override_rate4,
            override_rate5,
            override_rate6,
            override_rate7,
            override_rate8,
            override_rate9,
            override_rate10  );
   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug( '<< INS_LOCATION_RATES' );
   END IF;
END ins_location_rates; /* Procedure */






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
      location_id number;

BEGIN
  IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug( '>> INS_LOCATION_COMBINATIONS' );
  END IF;

   OPEN ar_location_combinations_s_c;
   FETCH ar_location_combinations_s_c into location_id;
   CLOSE ar_location_combinations_s_c;

   insert into ar_location_combinations( LOCATION_ID,
                                         LOCATION_STRUCTURE_ID,
                                         ENABLED_FLAG,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         SUMMARY_FLAG,
                                         PROGRAM_APPLICATION_ID,
                                         PROGRAM_ID,
                                         PROGRAM_UPDATE_DATE,
                                         REQUEST_ID,
                                         START_DATE_ACTIVE,
                                         END_DATE_ACTIVE,
                                         LOCATION_ID_SEGMENT_1,
                                         LOCATION_ID_SEGMENT_2,
                                         LOCATION_ID_SEGMENT_3,
                                         LOCATION_ID_SEGMENT_4,
                                         LOCATION_ID_SEGMENT_5,
                                         LOCATION_ID_SEGMENT_6,
                                         LOCATION_ID_SEGMENT_7,
                                         LOCATION_ID_SEGMENT_8,
                                         LOCATION_ID_SEGMENT_9,
                                         LOCATION_ID_SEGMENT_10,
                                         CREATED_BY,
                                         CREATION_DATE)
   VALUES
   (
    LOCATION_ID,
    LOCATION_STRUCTURE_ID,
    ENABLED_FLAG,
    arp_standard.PROFILE.USER_ID,
    sysdate,
    'N',
    arp_standard.PROFILE.PROGRAM_APPLICATION_ID,
    arp_standard.PROFILE.PROGRAM_ID,
    sysdate,
    arp_standard.PROFILE.REQUEST_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    LOCATION_ID_SEGMENT_1,
    LOCATION_ID_SEGMENT_2,
    LOCATION_ID_SEGMENT_3,
    LOCATION_ID_SEGMENT_4,
    LOCATION_ID_SEGMENT_5,
    LOCATION_ID_SEGMENT_6,
    LOCATION_ID_SEGMENT_7,
    LOCATION_ID_SEGMENT_8,
    LOCATION_ID_SEGMENT_9,
    LOCATION_ID_SEGMENT_10,
    arp_standard.PROFILE.USER_ID,
    sysdate );

    location_combination_inserted := TRUE;
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug( '<< INS_LOCATION_COMBINATIONS: ' || to_char(location_id) );
    END IF;
    return( location_id );

END ins_location_combinations;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   find_location_ccid                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This functions attempts to find the LOCATION_CCID from the table      |
 |   AR_LOCATION_COMBINATIONS given each of the possible values for        |
 |   segments in the LOCATION flexfield structure.                         |
 |   If no such record exists, this record will, if each of the values     |
 |   exist, create a new record and return the LOCATION_CCID of the new    |
 |   record.                                                               |
 |                                                                         |
 | REQUIRES                                                                |
 |   location               Record type, which contains                    |
 |                          State, County, City, Postal Code               |
 |                          Each of the fields from the users descriptive  |
 |                          flexfield.                                     |
 |                                                                         |
 | RETURNS                                                                 |
 |   LOCATION_CODE_COMBINATION_ID for this structure                       |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/



FUNCTION find_location_ccid(  param in LOCATION_TYPE ) return number IS

/*                            Cursor: ra_addresses_c                                         */
/*                                                                                           */
/* Find each of the address segment id's that are used in this location flexfield            */


CURSOR  ra_addresses_c( param in LOCATION_TYPE ) is

select  v1.location_segment_id,
 v2.location_segment_id,
 v3.location_segment_id
from    ar_location_values v1,
 ar_location_values v2,
 ar_location_values v3
where   v1.location_segment_value = upper(param.STATE)
 and v2.location_segment_value = upper(param.COUNTY)
 and v3.location_segment_value = upper(param.CITY)
and     v2.parent_segment_id = v1.location_segment_id
 and v3.parent_segment_id = v2.location_segment_id
and     v1.location_structure_id = arp_standard.sysparm.location_structure_id and
v2.location_structure_id = arp_standard.sysparm.location_structure_id and
v3.location_structure_id = arp_standard.sysparm.location_structure_id
and     v1.location_segment_qualifier = 'STATE'
 and v2.location_segment_qualifier = 'COUNTY'
 and v3.location_segment_qualifier = 'CITY' ;

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
select  rowid
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
 r3.end_date  ));

CURSOR  loc_ccid_c(p_location_id_segment_1 in number,
                   p_location_id_segment_2 in number,
                   p_location_id_segment_3 in number,
                   p_location_id_segment_4 in number,
                   p_location_id_segment_5 in number,
                   p_location_id_segment_6 in number,
                   p_location_id_segment_7 in number,
                   p_location_id_segment_8 in number,
                   p_location_id_segment_9 in number,
                   p_location_id_segment_10 in number ) IS
 select location_id
        from   ar_location_combinations cc
        where  location_structure_id = arp_standard.sysparm.location_structure_id
        and    cc.LOCATION_ID_SEGMENT_1 = p_LOCATION_ID_SEGMENT_1
 and cc.LOCATION_ID_SEGMENT_2 = p_LOCATION_ID_SEGMENT_2
 and cc.LOCATION_ID_SEGMENT_3 = p_LOCATION_ID_SEGMENT_3;


        location_id       number;
        loc_id_1          number := null;
        loc_id_2          number := null;
        loc_id_3          number := null;
        loc_id_4          number := null;
        loc_id_5          number := null;
        loc_id_6          number := null;
        loc_id_7          number := null;
        loc_id_8          number := null;
        loc_id_9          number := null;
        loc_id_10         number := null;



BEGIN
     IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug( '>> FIND_LOCATION_CCID' );
     END IF;

     OPEN ra_addresses_c( param );
     FETCH ra_addresses_c into loc_id_1 ,
 loc_id_2 ,
 loc_id_3 ;
     IF ra_addresses_c%FOUND
     THEN /* we have ids for each value, do we have ccid's? */
        OPEN loc_ccid_c( loc_id_1, loc_id_2, loc_id_3, loc_id_4, loc_id_5, loc_id_6, loc_id_7, loc_id_8, loc_id_9, loc_id_10 );
        FETCH loc_ccid_c into location_id;
        if loc_ccid_c%NOTFOUND
        THEN

               location_id := ins_location_combinations(
                                             arp_standard.sysparm.location_structure_id,
                                             null,
                                             null,
                                             loc_id_1,
                                             loc_id_2,
                                             loc_id_3,
                                             loc_id_4,
                                             loc_id_5,
                                             loc_id_6,
                                             loc_id_7,
                                             loc_id_8,
                                             loc_id_9,
                                             loc_id_10,
                                             'Y' );
        END IF;
        CLOSE loc_ccid_c;
   ELSE
        CLOSE ra_addresses_c;
         IF PG_DEBUG = 'Y' THEN
          arp_util_tax.debug( '<< FIND_LOCATION_CCID: NO_DATA_FOUND' );
         END IF;
	RETURN(NULL);
   END IF;
   CLOSE ra_addresses_c;

    IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug( '<< FIND_LOCATION_CCID: '  || to_char(location_id) );
    END IF;
   RETURN( location_id );
END find_location_ccid;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   TERR_SHORT_NAME                                                       |
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
 |   Package varicables: PREVIOUS_TERRITORY_CODE and PREVIOUS_TERRITORY_   |
 |   SHORT_NAME  cache the most recent database access.                    |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 +-------------------------------------------------------------------------*/


function terr_short_name( territory_code in varchar2 ) return varchar2 is

short_name VARCHAR2(80);

begin
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug( '>> TERRITORY_SHORT_NAME( ' || territory_code || ' ) ' );
    END IF;

   if territory_code = previous_territory_code
   then return( previous_territory_short_name );
   else

      select territory_short_name into short_name from fnd_territories_vl
      where territory_code = terr_short_name.territory_code;

      previous_territory_code := territory_code;
      previous_territory_short_name := short_name;
      IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug( '<< TERRITORY_SHORT_NAME: ' || short_name );
      END IF;
      return( short_name );

   end if;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN arp_standard.fnd_message(gl_public_sector.get_message_name(
                                   p_message_name => 'AR_BAD_TERRITORY',
                                   p_app_short_name => 'AR'),
                                  'TERRITORY', territory_code);
   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug( 'Territory not available' );
   END IF;

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

        location        LOCATION_TYPE;
        location_id     TAB_ID_TYPE;
        description     varchar2(60);
        loc_struct      varchar2(512);



BEGIN
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug( '>> SET_LOCATION_CCID( ' || Country || ', ' ||
                                             City || ', ' ||
                                             State || ', ' ||
                                             County || ', ' ||
                                             Province || ', ' ||
                                             Postal_code || ', ' ||
                                             attribute1 || ', ' ||
                                             attribute2 || ', ' ||
                                             attribute3 || ', ' ||
                                             attribute4 || ', ' ||
                                             attribute5 || ', ' ||
                                             attribute6 || ', ' ||
                                             attribute7 || ', ' ||
                                             attribute8 || ', ' ||
                                             attribute9 || ', ' ||
                                             attribute10 || ', ' ||
			                     to_char(address_id) || ') ' );
    END IF;
    location_combination_inserted := FALSE;
    location_segment_inserted := FALSE;

    IF country = nvl(arp_standard.sysparm.default_country, country )
    THEN
    BEGIN
       BEGIN

          if ltrim(rtrim(STATE)) is null then STATE := find_missing_parent_in_loc( 'COUNTY', COUNTY, postal_code ); END IF;
if ltrim(rtrim(COUNTY)) is null then COUNTY := find_missing_parent_in_loc( 'CITY', CITY, postal_code ); END IF;

          location.country := ltrim(rtrim(country));
          location.state := ltrim(rtrim(state));
          location.county := ltrim(rtrim(county));
          location.province := ltrim(rtrim(province));
          location.city := ltrim(rtrim(city));
          location.postal_code := ltrim(rtrim(postal_code));
          location.attribute1 := ltrim(rtrim(attribute1));
          location.attribute2 := ltrim(rtrim(attribute2));
          location.attribute3 := ltrim(rtrim(attribute3));
          location.attribute4 := ltrim(rtrim(attribute4));
          location.attribute5 := ltrim(rtrim(attribute5));
          location.attribute6 := ltrim(rtrim(attribute6));
          location.attribute7 := ltrim(rtrim(attribute7));
          location.attribute8 := ltrim(rtrim(attribute8));
          location.attribute9 := ltrim(rtrim(attribute9));
          location.attribute10 := ltrim(rtrim(attribute10));

          location_ccid := find_location_ccid( location );

       EXCEPTION
          WHEN NO_DATA_FOUND THEN location_ccid := NULL;
       END;

       if location_ccid is null
       THEN  /* One or more of the address componets is missing from the values table    */
       BEGIN

          IF arp_standard.sysparm.address_validation  = 'ERR'
          THEN

             loc_struct := 'STATE COUNTY CITY';

             /* Report The Error back to the user */
             -- arp_standard.fnd_message( 'AR_PP_ADDS_NO_ADDRESS', 'LOCATION', STATE || ' ' ||COUNTY || ' ' ||CITY );
             -- Bug 3179554
             arp_standard.fnd_message( 'AR_PP_ADDS_NO_ADDRESS', 'LOCATION', loc_struct  || ' ' ||  STATE || ' ' ||COUNTY || ' ' ||CITY );


          ELSE


             /* Find Missing Values, insert them and then generate Code Combination ID */

            for i in 0 .. 10
            loop
               location_id(i) := null;
            end loop;


    location_id(1) := find_location_segment_id( 'STATE', STATE, initcap( STATE ), location_id( 0 ), attribute1 => to_char(address_id) );
location_id(2) := find_location_segment_id( 'COUNTY', COUNTY, initcap( COUNTY ), location_id( 1 ), attribute1 => to_char(address_id) );
location_id(3) := find_location_segment_id( 'CITY', CITY, initcap( CITY ), location_id( 2 ), attribute1 => to_char(address_id) );

            location_ccid := ins_location_combinations(
                                                 arp_standard.sysparm.location_structure_id,
                                                 NULL,
                                                 NULL,
                                                 location_id(1),
                                                 location_id(2),
                                                 location_id(3),
                                                 location_id(4),
                                                 location_id(5),
                                                 location_id(6),
                                                 location_id(7),
                                                 location_id(8),
                                                 location_id(9),
                                                 location_id(10),
                                                 'Y');

          END IF;
       END;
       END IF;
    END;
    ELSE location_ccid := null;
    END IF;
   IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug( '<< SET_LOCATION_CCID: ' || to_char(location_ccid) );
   END IF;
EXCEPTION

     /*---------------------------------------------------------------------------+
      | Oracle Receivables cannot accept a null value for a segment when this     |
      | location has never been used before. It is not possible to create a new   |
      | location combination when one of the segments is null.                    |
      +---------------------------------------------------------------------------*/

      WHEN LOCATION_SEGMENT_NULL_VALUE
      THEN arp_standard.fnd_message( 'AR_PP_ADDS_LOC_NULL_VALUE', 'SEGMENT', NULL_SEGMENT_QUALIFIER );

END Set_Location_CCID ;


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
begin

    from_postal_code := arp_standard.sysparm.from_postal_code;
    to_postal_code := arp_standard.sysparm.to_postal_code;
    min_start_date := arp_standard.min_start_date;
    max_end_date   := arp_standard.max_end_date;

end;

BEGIN

    /*---------------------------------------------------------------------------+
     | Initialise Sales Tax Location Flexfield qualifiers so that the database   |
     | trigger, AR_LOCATION_VALUES_BRIU has access to this information for       |
     | validation purposes.                                                      |
     *---------------------------------------------------------------------------*/

   ARP_ADDS_MINUS99.first_segment_qualifier := 'STATE';
   ARP_ADDS_MINUS99.all_segment_qualifiers := 'STATE COUNTY CITY';
   ARP_ADDS_MINUS99.last_segment_qualifier := 'CITY';
   --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
   PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

   if arp_standard.sysparm.from_postal_code is null
   or arp_standard.sysparm.to_postal_code is null
   or arp_standard.sysparm.from_postal_code > arp_standard.sysparm.to_postal_code
   then
      arp_standard.fnd_message( 'AR_SYSPARM_POSTAL_CODES', 'FROM', arp_standard.sysparm.from_postal_code,
                                                           'TO', arp_standard.sysparm.to_postal_code );
   end if;

END ARP_ADDS_MINUS99;

/
