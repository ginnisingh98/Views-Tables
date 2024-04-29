--------------------------------------------------------
--  DDL for Package Body ARP_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_FLEX" as
/* $Header: ARPLFLXB.pls 120.4 2005/09/02 02:28:10 sachandr ship $ */

TYPE tab_id_type is table of number index by binary_integer;
TYPE tab_date_type is table of date index by binary_integer;
TYPE tab_varchar2_type is table of varchar2(240) index by binary_integer;
TYPE tab_char_type is table of char index by binary_integer;

flex_name tab_varchar2_type;
flex_num  tab_id_type;
flex_column_name tab_varchar2_type;
flex_qualifier tab_varchar2_type;
flex_prompt    tab_varchar2_type;
flex_pos tab_id_type;
flex_start tab_id_type;
flex_end tab_id_type;
flex_id tab_id_type;
flex_short_name tab_varchar2_type;
flex_separator tab_char_type;
list_segs tab_id_type;


flex_segments number := 0 ;
flex_instance number := 0 ;

no_qualifier EXCEPTION;

/*---------------------------------------------------------------------------+
 | PUBLIC HANDLES                                                            |
 |    These handles are automatically initialised during package startup     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

gl_handle       number; --  General Ledger Accounts Structure for current SOB
location_handle number; --  Sales Tax Location Flexfield for current SOB


function setup_flexfield( application_id  in number,
                          flex_code in varchar2,
                          structure_id    in number ) return number is

 cursor sel_flex_structure(appl_id   in number,
                           flex_code in varchar2,
                           structure_id in number) is
   select struct.concatenated_segment_delimiter separator,
          vs.flex_value_set_name name,
          seg.segment_num num,
          seg.application_column_name column_name,
          qual.segment_attribute_type  qualifier,
	  seg.form_left_prompt prompt,
          rownum pos,
          'LOCATION_ID_SEGMENT_'||to_char(seg.segment_num) column_num
   from   fnd_flex_value_sets vs,
          fnd_id_flex_segments_vl seg,
          fnd_segment_attribute_values qual,
          fnd_id_flex_structures struct
   where  seg.application_id = appl_id
   and    seg.id_flex_code = flex_code
   and    seg.flex_value_set_id = vs.flex_value_set_id
   and    seg.id_flex_num = structure_id
   and    qual.id_flex_code(+) = flex_code
   and    qual.id_flex_num(+) = structure_id
   and    qual.application_id(+) = appl_id
   and    qual.application_column_name(+) = seg.application_column_name
   and    qual.attribute_value(+) = 'Y'
   and    seg.enabled_flag = 'Y'
   and    struct.id_flex_code = seg.id_flex_code
   and    struct.id_flex_num = seg.id_flex_num
   order  by seg.segment_num, qual.segment_attribute_type;

   segment number;
   prior_segment number;

  -- Define Debug Variable and Assign the Profile
  --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

begin

   flex_instance := flex_instance + 1;
   flex_start( flex_instance ) := flex_segments + 1;
   segment := 0;
   prior_segment := 0;

   if PG_DEBUG = 'Y' then
      arp_util_tax.debug('application_id:'||to_char(application_id));
      arp_util_tax.debug('flex_code:'||flex_code);
      arp_util_tax.debug('structure_id:'||to_char(structure_id));
   end if;

   for location in sel_flex_structure( application_id, flex_code, structure_id)
   loop

     /*------------------------------------------------------------------+
      |  The Flex Preprocessor assumes that the Line Number Matches the  |
      |  Column Number in Key Flexfield Definition                       |
      |  Eg.  Line#    Column#     Column Name                           |
      |        1        1         LOCATION_SEGMENT_ID_1                  |
      |        2        2         LOCATION_SEGMENT_ID_2                  |
      |  So we need to check that this assumption is true                |
      +------------------------------------------------------------------*/
     if PG_DEBUG = 'Y' then
        arp_util_tax.debug('location.name : '||location.name);
        arp_util_tax.debug('location.num  : '||location.num);
        arp_util_tax.debug('location.column_name : '||location.column_name);
        arp_util_tax.debug('location.qualifier : '||location.qualifier);
        arp_util_tax.debug('location.prompt : '||location.prompt);
        arp_util_tax.debug('location.pos : '||location.pos);
        arp_util_tax.debug('location.column_num :'||location.column_num);
     end if;

      if location.column_name like 'LOCATION_ID_SEGMENT_%' and
         location.column_name <> location.column_num then
         if PG_DEBUG = 'Y' then
            arp_util_tax.debug('The Line Number: '||to_char(location.num)
                            ||' and Column Segment Number for '||location.column_name
                            ||' must be equal.');
         end if;
         fnd_message.set_name('AR','GENERIC_MESSAGE');
         fnd_message.set_token('GENERIC_TEXT','The Line Number '
                            ||to_char(location.num)
                            ||' and Column Segment Number for '||location.column_name
                            ||' must be equal.');
         app_exception.raise_exception;
      end if;

      if ( location.num <> prior_segment )
      then

         flex_segments := flex_segments + 1;
         flex_num( flex_segments ) := location.num;
         flex_name( flex_segments ) := location.name;
         flex_column_name( flex_segments ) := location.column_name;
         flex_pos( flex_segments ) := location.pos;
         flex_qualifier( flex_segments ) := ' ' || location.qualifier || ' ' ;
	flex_prompt( flex_segments ) := location.prompt;

         flex_separator( flex_instance ) := location.separator;

         prior_segment := location.num;

      else

         /*------------------------------------------------------------------+
          | Multiple Qualifiers per segment are supported, each qualifier    |
          | will be space separated.                                         |
          | Example: GL_ACCOUNT GL_GLOBAL                                    |
          +------------------------------------------------------------------*/

         flex_qualifier( flex_segments ) := flex_qualifier( flex_segments ) ||
              location.qualifier || ' ' ;

     end if;

   end loop;
   flex_end( flex_instance ) :=  flex_segments ;
   flex_short_name( flex_instance ) := flex_code;
   flex_id( flex_instance ) := structure_id;
   return( flex_instance );
end;


function token_expand( flex_handle in number,
                       word        in varchar2,
                       i           in number ) return varchar2 is
str varchar2(1000);

begin

   /*----------------------------------------------------------------------+
    | Expand segment tokens if requested                                   |
    *----------------------------------------------------------------------*/

   str := replace( word, '%COUNTER%', i );
   str := replace( str,  '%COLUMN%', flex_column_name(i) );
   str := replace( str,  '%POSITION%', flex_pos(i));
   str := replace( str,  '%QUALIFIER%', ltrim(rtrim(flex_qualifier(i))));
   str := replace( str,  '%NUMBER%', flex_num(i));
   str := replace( str,  '%SEPARATOR%', flex_separator(flex_handle));
   str := replace( str,  '%PROMPT%', flex_prompt(i));

   /*----------------------------------------------------------------------+
    | Expand Next segment tokens if requested                              |
    | Next is defined to be the next physical segment in the structure     |
    *----------------------------------------------------------------------*/

   if i < flex_end( flex_handle )
   then
      str := replace( str,  '%NEXT_COUNTER%', i+1 - flex_start(flex_handle) );
      str := replace( str,  '%NEXT_COLUMN%', flex_column_name(i+1) );
      str := replace( str,  '%NEXT_POSITION%', flex_pos(i+1));
      str := replace( str,  '%NEXT_QUALIFIER%', ltrim(rtrim(flex_qualifier(i+1))));
      str := replace( str,  '%NEXT_NUMBER%', flex_num(i+1));
      str := replace( str,  '%NEXT_PROMPT%', flex_prompt(i+1));
   else
      str := replace( str,  '%NEXT_COUNTER%', 0 );
      str := replace( str,  '%NEXT_COLUMN%', '''''' );
      str := replace( str,  '%NEXT_POSITION%', 0 );
      str := replace( str,  '%NEXT_QUALIFIER%', '''''' );
      str := replace( str,  '%NEXT_NUMBER%', 0 );
      str := replace( str,  '%NEXT_PROMPT%', '''''' );
   end if;

   /*----------------------------------------------------------------------+
    | Expand previous segment tokens if requested                          |
    *----------------------------------------------------------------------*/

   if i > flex_start( flex_handle )
   then
      str := replace( str,  '%PREVIOUS_COUNTER%', i-1 - flex_start( flex_handle ) );
      str := replace( str,  '%PREVIOUS_COLUMN%', flex_column_name(i-1) );
      str := replace( str,  '%PREVIOUS_POSITION%', flex_pos(i-1));
      str := replace( str,  '%PREVIOUS_QUALIFIER%', ltrim(rtrim(flex_qualifier(i-1))));
      str := replace( str,  '%PREVIOUS_NUMBER%', flex_num(i-1));
      str := replace( str,  '%PREVIOUS_PROMPT%', ltrim(rtrim(flex_prompt(i-1))));
   end if;


   /* Previous number of element i is 0 */
   if i = flex_start( flex_handle )
   then
      str := replace( str,  '%PREVIOUS_NUMBER%', 0);
   end if;

   return( str );

end;

function delimit( word in varchar2 ) return varchar2 is
begin
   return( ' ' || word || ' ' );
end;

procedure add_to_list( list in out nocopy varchar2, value in varchar2 ) is

  -- Define Debug Variable and Assign the Profile
  --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

begin
   if PG_DEBUG = 'Y' then
      arp_util_tax.debug( '>> add_to_list( ' || list || ', ' || value || ' )' );
   end if;

   /*** MB skip, the instr only searches for a character string(value) ***/
   /*** in list ***/
   if  instrb( list, value ) <> 0
   then
      list := replace( list,  value , null );
   else
      /* No Changes - so add to the end of the list  */
      list := list || value;
   end if;

   if PG_DEBUG = 'Y' then
      arp_util_tax.debug( '<< add_to_list( ' || list || ', ' || value || ' )' );
   end if;
end add_to_list;



function qualifier_list( flex_handle in number, qualifiers in varchar2 ) return varchar2 is
  i          number;
  k          number;
  step       number;
  segment    number;
  quals      varchar2( 240 );
  qual       varchar2( 30 );
  list       varchar2( 1000 );
  qual_found boolean;
  list_start number;
  startpos   number;
  endpos     number;

  -- Define Debug Variable and Assign the Profile
  --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

begin

   if PG_DEBUG = 'Y' then
      arp_util_tax.debug( '>> qualifier_list( ' || flex_handle || ', ' || qualifiers || ')' );
   end if;

  quals := qualifiers;
  list := null;
  list_start := flex_start( flex_handle );


  while arp_standard.get_next_word( quals, qual )
  loop

     qual_found := qual in ( 'ALL',  'FIRST',  'LAST', 'ALLREV' );


     if qual = 'ALLREV'
     then
          /***************************************/
          /* If ALL in Reverse order is required */
          /***************************************/
          startpos := flex_end( flex_handle ) - list_start;
          endpos := 0;
          step:=-1;
     else
          /*********************************************************/
          /* Normally, walk forward through the flexfield segments */
          /*********************************************************/
          startpos := 0;
          endpos := flex_end( flex_handle ) - list_start;
          step:=1;
     end if;

     i := startpos;
     for k in 0 .. flex_end(flex_handle) - list_start
     loop

        segment := list_start + i;

        if PG_DEBUG = 'Y' then
           arp_util_tax.debug( 'i=' || i || ' ' || list || ' --- ' || segment );
        end if;

        if ( qual in ( 'ALL', 'ALLREV' ))
        then
           if list is not null
           then
              list := list ||  delimit( segment );
           else
              list := delimit( segment ) ;
           end if;
        elsif ( qual = 'FIRST' and i = 0 )
           or ( qual = 'LAST' and ( i = flex_end( flex_handle ) - list_start ))
           or ( qual = ltrim( to_char( i+1, '99999' ) ))
        then
           add_to_list( list, delimit(segment) ) ;
           qual_found := true ;
        /*** MB skip, the instr only searches for a character string ***/
        /*** in flex_qualifier( segment ) ***/
        elsif instrb( flex_qualifier( segment ),  delimit( qual ) ) <> 0
        then
           add_to_list( list, delimit(segment) );
           qual_found := true;
        end if;

       i:=i+step;
     end loop;

     if not qual_found
     then

        if PG_DEBUG = 'Y' then
           arp_util_tax.debug(
           arp_standard.fnd_message( 'AR_FLEX_NO_QUALIFIER', 'QUALIFIER', qual,
                                  'STRING',    qualifiers,
                                  'FLEXCODE',  flex_short_name( flex_handle ),
                                  'STRUCTURE', flex_id( flex_handle ) ));
        end if;

       raise no_qualifier;

     end if;

  end loop;

   if PG_DEBUG = 'Y' then
      arp_util_tax.debug( '<< qualifier_list: ' || list );
   end if;
  return( list );

end;


function expand( flex_handle in number,
                 qualifiers  in varchar2,
                 separator   in varchar2,
                 word        in varchar2 ) return varchar2 is

str       varchar2(20000);
segments  varchar2(1000);
segment   number;

  -- Define Debug Variable and Assign the Profile
  --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

begin

   if PG_DEBUG = 'Y' then
    arp_util_tax.debug( '>> expand( ' || flex_handle || ', ' ||
              qualifiers || ', ' || separator || ', ' ||
              word || ' )' );
   end if;
   /*-------------------------------------------------------------------------+
    | Confirm that the flex handle passed is valid                            |
    +-------------------------------------------------------------------------*/

   BEGIN
      segment := flex_start(flex_handle );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN arp_standard.fnd_message( 'AR_FLEX_BAD_HANDLE', 'HANDLE', to_char(flex_handle));
   END;

   /*-------------------------------------------------------------------------+
    | Generate a list of segments, index values based on the qualifier        |
    | description string passed into the function.                            |
    +-------------------------------------------------------------------------*/

  BEGIN
   segments := qualifier_list( flex_handle, qualifiers );
  EXCEPTION
    WHEN no_qualifier
    THEN NULL;
  END;

   str := null;

   /*-------------------------------------------------------------------------+
    | Loop over each selected segment, expanding any tokens as requested      |
    +-------------------------------------------------------------------------*/


   while arp_standard.get_next_word( segments, segment )
   loop
      if str is not null
      then
         str := str || token_expand( flex_handle, separator, segment );
      end if;
      str := str || token_expand( flex_handle, word, segment );
   end loop;

   if PG_DEBUG = 'Y' then
      arp_util_tax.debug( '<< expand: ' || str );
   end if;
   return( str );

end expand;

function expand( flex_handle in number,
                 separator   in varchar2,
                 word        in varchar2 ) return varchar2 is
begin
   return( expand( flex_handle, 'ALL', separator, word ));
end expand;


function location return number is
begin
  return( location_handle );
end;

function gl return number is
begin
   return( gl_handle );
end;


function active_segments( flex_handle in number ) return number is
segments number;
  -- Define Debug Variable and Assign the Profile
  --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
begin

   if PG_DEBUG = 'Y' then
      arp_util_tax.debug( '>> active_segments( ' || flex_handle || ')' );
   end if;

   /*-------------------------------------------------------------------------+
    | Confirm that the flex handle passed is valid                            |
    +-------------------------------------------------------------------------*/

   BEGIN
      segments := flex_end(flex_handle) - flex_start(flex_handle )+1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN arp_standard.fnd_message( 'AR_FLEX_BAD_HANDLE', 'HANDLE', to_char(flex_handle) );
   END;

   if PG_DEBUG = 'Y' then
      arp_util_tax.debug( '<< active_segments: ' || to_char(segments) );
   end if;
   return( segments );

END;


begin -- Initialisation Section

   flex_instance := 0;  -- Count of number of open flexfield structures.
   flex_segments := 0;  -- Count of number of active segment records.

   /*------------------------------------------------------------------------+
    | Setup standard Flexfield handles.                                      |
    |                                                                        |
    | These handles are expected to be used frequently and so are publically |
    | declared for everyone to use.                                          |
    |                                                                        |
    +------------------------------------------------------------------------*/

   IF arp_standard.sysparm.location_structure_id <> -99 THEN
     location_handle := setup_flexfield( arp_standard.application_id, 'RLOC',
                                  arp_standard.sysparm.location_structure_id );
   END IF;

   gl_handle := setup_flexfield( arp_standard.gl_application_id, 'GL#',
                          arp_standard.gl_chart_of_accounts_id );

  ----- Commented out for eBTax uptake
   /*
   if active_segments( location_handle ) = 0
   then
      arp_standard.fnd_message( 'AR_FLEX_MANDATORY_STRUCTURE', 'FNAME', 'Sales Tax Location');
   end if;
   */

end;

/
