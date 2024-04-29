--------------------------------------------------------
--  DDL for Package ARP_ADDS_MINUS99
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ADDS_MINUS99" AUTHID DEFINER /*NOSYNC*/ AS
/* $Header: ARPLXLOC.txt 115.5 2004/03/18 16:28:47 rpalani ship $ */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  EXCEPTIONS                                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/


LOCATION_SEGMENT_NULL_VALUE EXCEPTION;



/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  TYPES                                                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/


TYPE LOCATION_TYPE IS RECORD
        (
          country        varchar2(60),
          City           varchar2(60),
          State          varchar2(60),
          County         varchar2(60),
          Province       varchar2(60),
          Postal_code    varchar2(60),
          attribute1     varchar2(150),
          attribute2     varchar2(150),
          attribute3     varchar2(150),
          attribute4     varchar2(150),
          attribute5     varchar2(150),
          attribute6     varchar2(150),
          attribute7     varchar2(150),
          attribute8     varchar2(150),
          attribute9     varchar2(150),
          attribute10    varchar2(150),
          location_ccid  number);

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  VARIABLES                                                       |
 |                                                                         |
 | VARIABLE: location_segment_inserted                                     |
 |    location_segment_inserted is true if the most recent call to         |
 |    find location_segment_id inserted a new record into the table        |
 |    ar_location_values                                                   |
 |                                                                         |
 | VARIABLE: location_combination_inserted                                 |
 |    location_combination_inserted is true if the most recent call to     |
 |    set_location_ccid inserted a new record into the table               |
 |    ar_location_combinations                                             |
 |                                                                         |
 | VARIABLE: triggers_enabled                                              |
 |    If set to true, (default) row and statement table triggers will      |
 |    fire on each of tables associated with Customer Address Entry        |
 |                                                                         |
 | VARIABLE: first_segment_qualifier                                       |
 |    The Segment qualifier of the first segment in your Sales Tax         |
 |    location Flexfield.                                                  |
 |                                                                         |
 | VARIABLE: all_segment_qualifiers                                        |
 |    An ordered list of qualifiers for each segment of your Sales Tax     |
 |    location Flexfield.                                                  |
 |                                                                         |
 | VARIABLE: populate_location_rates                                       |
 |    If enabled, every time a database trigger creates a new row in the   |
 |    table AR_LOCATION_VALUES a default row will automatically by created |
 |    in ar_location_rates.                                                |
 |                                                                         |
 +-------------------------------------------------------------------------*/



   location_segment_inserted    BOOLEAN := FALSE;
   location_combination_inserted BOOLEAN := FALSE;


   populate_location_rates      BOOLEAN := FALSE;

   triggers_enabled             BOOLEAN := TRUE;


   first_segment_qualifier      varchar2(60);
   last_segment_qualifier	varchar2(60);

   all_segment_qualifiers       varchar2(512);

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
			      address_id     in number default null );

FUNCTION ins_location_combinations( location_structure_id  number,
                                    start_date_active      date,
                                    end_date_active        date,
                                    location_id_segment_1  number,
                                    location_id_segment_2  number,
                                    location_id_segment_3  number,
                                    location_id_segment_4  number,
                                    location_id_segment_5  number,
                                    location_id_segment_6  number,
                                    location_id_segment_7  number,
                                    location_id_segment_8  number,
                                    location_id_segment_9  number,
                                    location_id_segment_10 number,
                                    enabled_flag           varchar2 )
                             return number;


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
                              ATTRIBUTE15        in varchar2 default null )
                       return number ;

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
                            ) return number ;


PROCEDURE ins_location_rates(  location_segment_id in number,
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
			      OVERRIDE_RATE10	    in NUMBER  default null);

procedure location_information( location_segment_id          in number,
			        location_segment_qualifier   out NOCOPY varchar2,
			        location_segment_value       out NOCOPY varchar2,
			        location_segment_description out NOCOPY varchar2,
			        parent_segment_id out NOCOPY number ) ;

procedure location_information( location_segment_qualifier   in varchar2,
				location_segment_value       in  varchar2,
                                location_segment_description out NOCOPY varchar2,
			        parent_segment_id out NOCOPY number ) ;



FUNCTION find_location_segment_id( location_segment_qualifier    in varchar2,
                                   segment_value     in varchar2,
                                   segment_description in varchar2,
                                   parent_segment_id in number,
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
				   SEARCH_PRECISSION  in number   default null )
                            return number ;


function location_description( location_segment_qualifier in varchar2,
			       location_segment_value     in varchar2 )
			     return varchar2;

function location_description( location_segment_id in number )
                             return varchar2 ;



function terr_short_name( territory_code in varchar2 ) return varchar2 ;

procedure enable_triggers;

procedure disable_triggers;


procedure return_location_defaults( from_postal_code out NOCOPY varchar2,
				    to_postal_code   out NOCOPY varchar2,
				    min_start_date   out NOCOPY date,
				    max_end_date     out NOCOPY date );

PROCEDURE ins_location_accounts
                            ( location_segment_id        in number,
                              location_segment_qualifier in varchar2);


END ARP_ADDS_MINUS99;

 

/
