--------------------------------------------------------
--  DDL for Package Body OE_INLINE_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INLINE_FLEX" as
/* $Header: OEXFILFB.pls 120.3 2006/02/21 12:06:41 aycui ship $ */

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
flex_start number;
flex_end number;
flex_id number;
flex_short_name varchar(240);
flex_separator char;
list_segs tab_id_type;


flex_segments number := 0 ;

no_qualifier EXCEPTION;


procedure setup_flexfield( flex_code in varchar2,
                          structure_id    in number ) is

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
   and    struct.application_id=seg.application_id
   order  by seg.segment_num, qual.segment_attribute_type;

   segment number;
   prior_segment number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSIDE SETUP_FLEXFIELD' ) ;
   END IF;
   flex_start := flex_segments + 1;
   segment := 0;
   prior_segment := 0;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FLEX_CODE:'||FLEX_CODE ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'STRUCTURE_ID:'||TO_CHAR ( STRUCTURE_ID ) ) ;
   END IF;

   for location in sel_flex_structure( 222, flex_code, structure_id)
   loop

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCATION.NAME='||LOCATION.NAME ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCATION.NUM='||TO_CHAR ( LOCATION.NUM ) ) ;
      END IF;
     /*------------------------------------------------------------------+
      |  The Flex Preprocessor assumes that the Line Number Matches the  |
      |  Column Number in Key Flexfield Definition                       |
      |  Eg.  Line#    Column#     Column Name                           |
      |        1        1         LOCATION_SEGMENT_ID_1                  |
      |        2        2         LOCATION_SEGMENT_ID_2                  |
      |  So we need to check that this assumption is true                |
      +------------------------------------------------------------------*/
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOCATION.NAME : '||LOCATION.NAME ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOCATION.NUM : '||LOCATION.NUM ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOCATION.COLUMN_NAME : '||LOCATION.COLUMN_NAME ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOCATION.QUALIFIER : '||LOCATION.QUALIFIER ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOCATION.PROMPT : '||LOCATION.PROMPT ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOCATION.POS : '||LOCATION.POS ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOCATION.COLUMN_NUM :'||LOCATION.COLUMN_NUM ) ;
     END IF;

     if location.column_name like 'LOCATION_ID_SEGMENT_%' and
         location.column_name <> location.column_num then
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'THE LINE NUMBER: '||TO_CHAR ( LOCATION.NUM ) ||' AND COLUMN SEGMENT NUMBER FOR '||LOCATION.COLUMN_NAME ||' MUST BE EQUAL.' ) ;
                      END IF;
         fnd_message.set_name('AR','GENERIC_MESSAGE');
         fnd_message.set_token('GENERIC_TEXT','The Line Number '
                            ||to_char(location.num)
                       ||' and Column Segment Number for '||location.column_name
                       ||' must be equal.');
         app_exception.raise_exception;
     end if;

     -- if the segment number is not the prior segment number then that means
	-- total segment is not more.we then store the sequenc of location,
	-- value_set name,application_column_name,its position in the sequence
	-- and the qualifier

     if ( location.num <> prior_segment ) then

         flex_segments := flex_segments + 1;
         flex_num( flex_segments ) := location.num;
         flex_name( flex_segments ) := location.name;
         flex_column_name( flex_segments ) := location.column_name;
         flex_pos( flex_segments ) := location.pos;
         flex_qualifier( flex_segments ) := ' ' || location.qualifier || ' ' ;
	    flex_prompt( flex_segments ) := location.prompt;
         flex_separator := location.separator;
         prior_segment := location.num;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'LOCATION_QUALIFIER='||LOCATION.QUALIFIER ) ;
	    END IF;
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

   flex_end :=  flex_segments ;
   flex_short_name := flex_code;
   flex_id := structure_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'START POS='||TO_CHAR ( FLEX_START ) ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'END POS='||TO_CHAR ( FLEX_END ) ) ;
   END IF;


end setup_flexfield;


function token_expand( word        in varchar2,
                       i           in number ) return varchar2 is
str varchar2(1000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

   /*----------------------------------------------------------------------+
    | Expand segment tokens if requested                                   |
    *----------------------------------------------------------------------*/

   str := replace( word, '%COUNTER%', i );
   str := replace( str,  '%COLUMN%', flex_column_name(i) );
   str := replace( str,  '%POSITION%', flex_pos(i));
   str := replace( str,  '%QUALIFIER%', ltrim(rtrim(flex_qualifier(i))));
   str := replace( str,  '%NUMBER%', flex_num(i));
   str := replace( str,  '%SEPARATOR%', flex_separator);
   str := replace( str,  '%PROMPT%', flex_prompt(i));

   /*----------------------------------------------------------------------+
    | Expand Next segment tokens if requested                              |
    | Next is defined to be the next physical segment in the structure     |
    *----------------------------------------------------------------------*/

   if i < flex_end then
      str := replace( str,  '%NEXT_COUNTER%', i+1 - flex_start );
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

   if i > flex_start then
      str := replace( str,  '%PREVIOUS_COUNTER%', i-1 - flex_start);
      str := replace( str,  '%PREVIOUS_COLUMN%', flex_column_name(i-1) );
      str := replace( str,  '%PREVIOUS_POSITION%', flex_pos(i-1));
      str := replace( str,  '%PREVIOUS_QUALIFIER%',ltrim(rtrim(flex_qualifier(i-1))));
      str := replace( str,  '%PREVIOUS_NUMBER%', flex_num(i-1));
      str := replace( str,  '%PREVIOUS_PROMPT%', ltrim(rtrim(flex_prompt(i-1))));
   end if;


   /* Previous number of element i is 0 */
   if i = flex_start
   then
      str := replace( str,  '%PREVIOUS_NUMBER%', 0);
   end if;

   return( str );

exception
  when no_data_found then
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'WHEN NO DATA FOUND TOKEN_EXPAN' ) ;
	 END IF;

  when others then
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'WHEN OTHERS IN TOKEN_EXPAND' ) ;
	 END IF;

end token_expand;


function delimit( word in varchar2 ) return varchar2 is
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
   return( ' ' || word || ' ' );
end delimit;


procedure add_to_list( list in out NOCOPY /* file.sql.39 change */ varchar2, value in varchar2 ) is
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '>> ADD_TO_LIST ( ' || LIST || ' , ' || VALUE || ' ) ' ) ;
   END IF;

   /* skip, the instr only searches for a character string(value) in list */
   if  instr( list, value ) <> 0
   then
      list := replace( list,  value , null );
   else
      /* No Changes - so add to the end of the list  */
      list := list || value;
   end if;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '<< ADD_TO_LIST ( ' || LIST || ' , ' || VALUE || ' ) ' ) ;
   END IF;
end add_to_list;



function qualifier_list( qualifiers in varchar2 ) return varchar2 is
  i          number;
  k          number;
  step       number;
  segment    number;
  quals      varchar2( 240 );
  qual       varchar2( 30 );
  list       varchar2( 1000 );
  qual_found boolean;
  startpos   number;
  endpos     number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSIDE QUALIFIER_LIST' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QUALIFIERS='||QUALIFIERS ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '>> QUALIFIER_LIST ( ' || ' , ' || QUALIFIERS || ' ) ' ) ;
  END IF;

  quals := qualifiers;
  list := null;


  if quals = 'ALLREV' then
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'IF ALLREV' ) ;
		END IF;
          startpos := flex_end - flex_start;
          endpos := 0;
          step:=-1;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'STARTPOS='||TO_CHAR ( STARTPOS ) ) ;
	     END IF;
  end if;

  i := startpos;
  for k in 0 .. flex_end - flex_start
     loop
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INSIDE LOOP' ) ;
	   END IF;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'FLEX_START='||TO_CHAR ( FLEX_START ) ) ;
	   END IF;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'I='||TO_CHAR ( I ) ) ;
	   END IF;
        segment := flex_start + i;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'SEGMENT='||TO_CHAR ( SEGMENT ) ) ;
	   END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'I=' || I || ' ' || LIST || ' --- ' || SEGMENT ) ;
        END IF;

        if list is not null then
           list := list ||  delimit( segment );
        else
           list := delimit( segment ) ;
        end if;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'LIST='||LIST ) ;
	   END IF;

        i := i + step;
     end loop;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '<< QUALIFIER_LIST: ' || LIST ) ;
  END IF;
  return( list );

end qualifier_list;


procedure expand( qualifiers  in varchar2,
                 separator   in varchar2,
                 word        in varchar2,
structure out nocopy varchar2) IS


str       varchar2(20000);
segments  varchar2(1000);
segment   number;
l_segments varchar2(1000);
l_segment varchar2(1000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE EXPAND' ) ;
    END IF;
    initialize;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER INITIALIZE ' ) ;
    END IF;

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  '>> EXPAND ( ' || ' , ' || QUALIFIERS || ' , ' || SEPARATOR || ' , ' || WORD || ' ) ' ) ;
              END IF;

    segment := flex_start;

   /*-------------------------------------------------------------------------+
    | Generate a list of segments, index values based on the qualifier        |
    | description string passed into the function.                            |
    | e,g 1.2.3.4 is the value inside segments returned by qualifier_list     |
    +-------------------------------------------------------------------------*/

   segments := qualifier_list(qualifiers );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SEGMENTS='||SEGMENTS ) ;
   END IF;
   str := null;

   /*-------------------------------------------------------------------------+
    | Loop over each selected segment, expanding any tokens as requested      |
    +-------------------------------------------------------------------------*/

/* The following is added as a workaround for the Initialization issue in
 arp_standard */
  begin

  if arp_standard.get_next_word( l_segments, l_segment ) then
       oe_debug_pub.add(  '<< LOOP** DUMMY TRUE: ' ) ;
    else
       oe_debug_pub.add(  '<< LOOP** DUMMY FALSE: ' ) ;
    end if;
  exception
   when others then
       oe_debug_pub.add(  '<< LOOP** DUMMY OTHERS : '||sqlerrm ) ;
  end;


   while arp_standard.get_next_word( segments, segment )
   -- segment is the next word in the list
   loop
      if str is not null
      then
         str := str || token_expand( separator, segment );
      end if;
      str := str || token_expand( word, segment );
   end loop;


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '<< EXPAND: ' || STR ) ;
   END IF;
   structure := str;

EXCEPTION
  When others then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WHEN OTHERS EXPAND' ) ;
    END IF;

end expand;


function active_segments return number is
segments number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

   segments := flex_end - flex_start + 1;
   return( segments );

END active_segments;


PROCEDURE initialize IS

cursor c_sel is
    select location_structure_id
	 from ar_system_parameters;

l_location_structure_id ar_system_parameters.location_structure_id%TYPE;

l_AR_Sys_Param_Rec    AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin -- Initialisation Section

   flex_segments := 0;  -- Count of number of active segment records.

   IF oe_code_control.code_release_level < '110510' THEN
      OPEN c_sel;
      FETCH c_sel
      INTO l_location_structure_id;
      CLOSE c_sel;
   ELSE
      l_AR_Sys_Param_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params;
      l_location_structure_id := l_AR_Sys_Param_Rec.location_structure_id;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'STRUCUTRE_ID='||TO_CHAR ( L_LOCATION_STRUCTURE_ID ) ) ;
   END IF;
   setup_flexfield(
			  'RLOC',
                  l_location_structure_id
			   );


   if active_segments = 0
   then
      arp_standard.fnd_message( 'AR_FLEX_MANDATORY_STRUCTURE', 'FNAME', 'Sales Tax Location');
   end if;

end initialize;

end oe_inline_flex;


/
