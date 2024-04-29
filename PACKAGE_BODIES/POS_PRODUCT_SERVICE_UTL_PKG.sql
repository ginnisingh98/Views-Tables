--------------------------------------------------------
--  DDL for Package Body POS_PRODUCT_SERVICE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PRODUCT_SERVICE_UTL_PKG" AS
/* $Header: POSPSUTB.pls 120.5.12010000.34 2014/07/25 16:54:05 atjen ship $*/
--
-- type definition
TYPE cursor_ref_type IS REF CURSOR;

TYPE structure_segment_table IS
   TABLE OF fnd_flex_key_api.segment_type INDEX BY BINARY_INTEGER;

TYPE varchar10_table IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE varchar1000_table IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
TYPE number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE product_segment_record IS RECORD
  (column_name          fnd_id_flex_segments_vl.application_column_name%TYPE,
   value_set_id         fnd_id_flex_segments_vl.flex_value_set_id%TYPE,
   validation_type     	fnd_flex_value_sets.validation_type%TYPE,
   table_name          	fnd_flex_validation_tables.application_table_name%TYPE,
   meaning_column      	fnd_flex_validation_tables.meaning_column_name%TYPE,
   id_column           	fnd_flex_validation_tables.id_column_name%TYPE,
   value_column        	fnd_flex_validation_tables.value_column_name%TYPE,
   where_clause        	fnd_flex_validation_tables.meaning_column_name%TYPE,
   parent_segment_index INTEGER
   );

TYPE product_segment_table IS
   TABLE OF product_segment_record INDEX BY BINARY_INTEGER;

TYPE category_segment_record IS RECORD (
  segment1 mtl_categories_b.segment1%TYPE
, segment2 mtl_categories_b.segment2%TYPE
, segment3 mtl_categories_b.segment3%TYPE
, segment4 mtl_categories_b.segment4%TYPE
, segment5 mtl_categories_b.segment5%TYPE
, segment6 mtl_categories_b.segment6%TYPE
, segment7 mtl_categories_b.segment7%TYPE
, segment8 mtl_categories_b.segment8%TYPE
, segment9 mtl_categories_b.segment9%TYPE
, segment10 mtl_categories_b.segment10%TYPE
, segment11 mtl_categories_b.segment11%TYPE
, segment12 mtl_categories_b.segment12%TYPE
, segment13 mtl_categories_b.segment13%TYPE
, segment14 mtl_categories_b.segment14%TYPE
, segment15 mtl_categories_b.segment15%TYPE
, segment16 mtl_categories_b.segment16%TYPE
, segment17 mtl_categories_b.segment17%TYPE
, segment18 mtl_categories_b.segment18%TYPE
, segment19 mtl_categories_b.segment19%TYPE
, segment20 mtl_categories_b.segment20%TYPE
);


-- private package constants
g_product_segment_profile_name CONSTANT VARCHAR2(30) := 'POS_PRODUCT_SERVICE_SEGMENTS';
g_max_number_of_segments CONSTANT NUMBER := 20;
g_yes CONSTANT VARCHAR2(1) := 'Y';
g_no CONSTANT VARCHAR2(1) := 'N';

-- cached meta data about product service
g_initialized BOOLEAN := FALSE;
g_default_po_category_set_id NUMBER;
g_structure_id NUMBER;
g_product_segment_definition fnd_profile_option_values.profile_option_value%TYPE;
g_product_segment_count NUMBER := 0;
g_product_segments product_segment_table;
g_structure_segment_count NUMBER := 0;
g_structure_segments structure_segment_table;
g_delimiter fnd_id_flex_structures_vl.concatenated_segment_delimiter%TYPE;
g_description_queries varchar1000_table;

PROCEDURE clear_cache IS
BEGIN
   g_default_po_category_set_id := NULL;
   g_structure_id := NULL;
   g_product_segment_definition := NULL;
   g_product_segment_count := 0;
   g_product_segments.DELETE;
   g_structure_segments.DELETE;
   g_structure_segment_count := 0;
   g_initialized := FALSE;
END clear_cache;

FUNCTION get_parent_value_set_id
  (p_value_set_id IN NUMBER) RETURN NUMBER IS
   CURSOR l_cur IS
      SELECT parent_flex_value_set_id
	FROM fnd_flex_value_sets
	WHERE flex_value_set_id = p_value_set_id;
   l_parent_value_set_id NUMBER;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_parent_value_set_id;
   CLOSE l_cur;
   RETURN l_parent_value_set_id;
END get_parent_value_set_id;

PROCEDURE validate_segment_definition
  (x_status        OUT NOCOPY VARCHAR2,
   x_error_message OUT NOCOPY VARCHAR2) IS
      l_temp fnd_profile_option_values.profile_option_value%TYPE;
      l_char VARCHAR2(10);
      l_index NUMBER;
      l_length NUMBER;
      l_dot_positions number_table;
      l_number_of_dots NUMBER;
      l_number_string fnd_profile_option_values.profile_option_value%TYPE;
      l_start_pos NUMBER;
      l_end_pos NUMBER;
      l_number INTEGER;
      l_segments_in_structure number_table;
      l_segments_appeared varchar10_table;
      l_valueset fnd_vset.valueset_r;
      l_format fnd_vset.valueset_dr;
      l_product_segment product_segment_record;
      l_parent_value_set_id NUMBER;
BEGIN
   x_status := g_no;

   FOR l_index IN 1..g_max_number_of_segments LOOP
      l_segments_in_structure(l_index) := NULL;
      l_segments_appeared(l_index) := NULL;
   END LOOP;

   -- flag which segments are in the flexfield structure
   FOR l_index IN 1..g_structure_segment_count LOOP
      l_segments_in_structure(To_number(Substr(g_structure_segments(l_index).column_name,
					       Length('SEGMENT') + 1))) := l_index;
   END LOOP;

   -- product segment definition can not be null
   IF g_product_segment_definition IS NULL THEN
      --x_error_message := 'product segment definition is null';
      x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_NO_DEFINE');
      RETURN;
   END IF;

   -- product segment definition should be not have any characters other than digits
   -- and the . delimiter
   l_length := Length(g_product_segment_definition);
   l_number_of_dots := 0;
   FOR l_index IN 1..l_length LOOP
      l_char := Substr(g_product_segment_definition,l_index,1);
      IF l_char NOT IN ('1','2','3','4','5','6','7','8','9','0','.') THEN
	 --x_error_message := 'product segment definition has a character that is not digits or the . delimeter';
	 x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_ILLEGAL_CHAR');
	 RETURN;
      END IF;
      IF l_char = '.' THEN
	 l_number_of_dots := l_number_of_dots + 1;
	 l_dot_positions(l_number_of_dots) := l_index;
      END IF;
   END LOOP;

   -- product segment definition should be in the format of [1-20](.[1-20])*
   -- a number can not appear twice (e.g. 1.1 is wrong)
   -- and the corresponding segment must be one of the segments in the
   -- flexfield structure for default purchasing category set
   g_product_segment_count := 0;
   FOR l_index IN 1..l_number_of_dots + 1 LOOP
      IF l_index = 1 THEN
	 l_start_pos := 1;
       ELSE
	 l_start_pos := l_dot_positions(l_index - 1) + 1;
      END IF;

      IF l_index <= l_number_of_dots THEN
	 l_end_pos := l_dot_positions(l_index) - 1;
       ELSE
	 l_end_pos := l_length;
      END IF;

      l_number_string := Substr(g_product_segment_definition,
				l_start_pos,
				l_end_pos - l_start_pos + 1);
      l_number := To_number(l_number_string);

      IF l_number > g_max_number_of_segments OR l_number < 0 THEN
         --x_error_message := 'product segment definition has ' || l_number || ', but SEGMENT' || l_number || ' is not used in the flexfield structure for' || 'the default purchasing category set';
         x_error_message:= fnd_message.get_string('POS', 'POS_PS_SETUP_WRONG_SEG_NUM');
         RETURN;
      END IF;

      IF l_segments_in_structure(l_number) IS NULL THEN
	 --x_error_message := 'product segment definition has ' || l_number || ', but SEGMENT' || l_number || ' is not used in the flexfield structure for' || ' the default purchasing category set';
	 x_error_message:= fnd_message.get_string('POS', 'POS_PS_SETUP_WRONG_SEG_NUM');
	 RETURN;
      END IF;

      IF l_segments_appeared(l_number) IS NULL THEN
	 l_segments_appeared(l_number) := 'Y';
       ELSE
	 --x_error_message := 'same segment can not be used twice in product segment definition';
	 x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_DUP_SEGMENT');
	 RETURN;
      END IF;

      l_product_segment.column_name :=
	g_structure_segments(l_segments_in_structure(l_number)).column_name;

      l_product_segment.value_set_id :=
	g_structure_segments(l_segments_in_structure(l_number)).value_set_id;

      fnd_vset.get_valueset
	(g_structure_segments(l_segments_in_structure(l_number)).value_set_id,
	 l_valueset, l_format);


      IF l_valueset.validation_type NOT IN ('I','D','F') THEN
	 --
	 -- NOTES
	 --
	 -- the following validation types are not supported
	 --   none, pair, special, because there is no way to get translated description for values;
	 --   translatable independent, translatable dependent because item categories key flexfield
	 --   does not support id type value sets (column allow_id_valuesets in table
	 --   fnd_id_flex for id_flex_code MCAT is N).
	 --
	 -- x_error_message := 'product segment definition error: validation type ' || l_valueset.validation_type || ' not supported';
	 x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_WRONG_TYPE');
	 RETURN;
      END IF;

      IF l_valueset.table_info.meaning_column_name LIKE '%:%' THEN
	 --x_error_message := 'product segment definition error: bind variables in meaning columns are not supported';
	 x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_BIND_VAR_1');
	 RETURN;
      END IF;

      IF l_valueset.table_info.where_clause LIKE '%:%' THEN
	 --x_error_message := 'product segment definition error: bind variables in where clause are not supported';
	 x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_BIND_VAR_2');
	 RETURN;
      END IF;

      l_product_segment.validation_type := l_valueset.validation_type;
      l_product_segment.table_name := l_valueset.table_info.table_name;
      l_product_segment.id_column := l_valueset.table_info.id_column_name;
      l_product_segment.value_column := l_valueset.table_info.value_column_name;
      l_product_segment.meaning_column := l_valueset.table_info.meaning_column_name;
      l_product_segment.where_clause  := l_valueset.table_info.where_clause;

      IF l_valueset.validation_type IN ('D') THEN
	 -- the first segment cannot have a dependent value set
	 IF g_product_segment_count = 0 THEN
            x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_BAD_DEP_VS');
	    RETURN;
	 END IF;

	 -- find out the index to the parent segment record
	 l_parent_value_set_id := get_parent_value_set_id(l_product_segment.value_set_id);
	 FOR l_lookup_back IN REVERSE 1..g_product_segment_count LOOP
	    IF g_product_segments(l_lookup_back).value_set_id = l_parent_value_set_id THEN
	       l_product_segment.parent_segment_index := l_lookup_back;
	       EXIT;
	    END IF;
	 END LOOP;
       ELSE
	 l_product_segment.parent_segment_index := NULL;
      END IF;

      g_product_segment_count := g_product_segment_count + 1;
      g_product_segments(g_product_segment_count) := l_product_segment;

      g_description_queries(g_product_segment_count) := NULL;
   END LOOP;

   -- check segment def against pos_sup_products_services
   -- to be implemented later
   --

   -- all validation is done
   x_status := g_yes;
   x_error_message := NULL;
   RETURN;
END validate_segment_definition;

PROCEDURE query_po_category_flexfield IS
   l_flexfield fnd_flex_key_api.flexfield_type;
   l_structure fnd_flex_key_api.structure_type;
   l_segment_list fnd_flex_key_api.segment_list;
BEGIN
   -- this call is a must before calling other procedures in fnd_flex_key_api package
   fnd_flex_key_api.set_session_mode('seed_data');

   -- find flexfield
   l_flexfield := fnd_flex_key_api.find_flexfield('INV','MCAT');

   -- find structure
   l_structure := fnd_flex_key_api.find_structure(l_flexfield, g_structure_id);

   -- store the segment_separator in package variable
   g_delimiter := l_structure.segment_separator;

   -- get segment count and name list
   fnd_flex_key_api.get_segments(flexfield    => l_flexfield,
				 structure    => l_structure,
				 enabled_only => TRUE,
				 nsegments    => g_structure_segment_count,
				 segments     => l_segment_list);

   -- get each segment info
   FOR l_index IN 1..g_structure_segment_count LOOP
      g_structure_segments(l_index) :=
	fnd_flex_key_api.find_segment(l_flexfield, l_structure, l_segment_list(l_index));
   END LOOP;
END query_po_category_flexfield;

PROCEDURE query_def_po_category_set_id IS
   CURSOR l_cur IS
      SELECT category_set_id
	FROM mtl_default_category_sets
	WHERE functional_area_id = 2;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO g_default_po_category_set_id;
   CLOSE l_cur;
END query_def_po_category_set_id;

PROCEDURE query_structure_id IS
   CURSOR l_cur IS
      SELECT structure_id
	FROM mtl_category_sets
	WHERE category_set_id = g_default_po_category_set_id;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO g_structure_id;
   CLOSE l_cur;
END query_structure_id;

PROCEDURE do_init
  (x_status         OUT NOCOPY VARCHAR2,
   x_error_message  OUT NOCOPY VARCHAR2) IS
BEGIN
   clear_cache;

   query_def_po_category_set_id;
   query_structure_id;
   query_po_category_flexfield;

   IF g_default_po_category_set_id IS NULL THEN
      x_status := g_no;
      --x_error_message := 'default purchasing category set id is null';
      x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_DEF_PUR_CAT');
      RETURN;
   END IF;

   -- get product and service segments definition

   FOR x IN (SELECT profile_option_value
	       FROM fnd_profile_option_values
	      WHERE profile_option_id IN
	            (SELECT profile_option_id
		       FROM fnd_profile_options
		      WHERE profile_option_name = g_product_segment_profile_name
		        AND level_id = 10001
		        AND level_value = 0
		     )
	     ) LOOP
	g_product_segment_definition := x.profile_option_value;
   END LOOP;

   validate_segment_definition(x_status, x_error_message);
   IF x_status = g_no THEN
      RETURN;
   END IF;

   g_initialized := TRUE;
   x_status := g_yes;
   x_error_message := NULL;
END do_init;

PROCEDURE validate_segment_prof_nocache (
  p_product_segment_definition IN VARCHAR2
, x_status                     OUT NOCOPY VARCHAR2
, x_error_message              OUT NOCOPY VARCHAR2
) IS
BEGIN
   clear_cache;

   query_def_po_category_set_id;
   query_structure_id;
   query_po_category_flexfield;

   IF g_default_po_category_set_id IS NULL THEN
      x_status := g_no;
      --x_error_message := 'default purchasing category set id is null';
      x_error_message := fnd_message.get_string('POS', 'POS_PS_SETUP_DEF_PUR_CAT');
      RETURN;
   END IF;

   g_product_segment_definition := p_product_segment_definition;

   validate_segment_definition(x_status, x_error_message);
   clear_cache;
   RETURN;
END validate_segment_prof_nocache;

PROCEDURE assert_init IS
   l_status VARCHAR2(1);
   l_error_message VARCHAR2(2000);
BEGIN
   IF g_initialized = FALSE THEN
      do_init(l_status, l_error_message);
      IF l_status = g_yes THEN
	 NULL;
       ELSE
	 raise_application_error(-20000,l_error_message);
      END IF;
   END IF;
END assert_init;

PROCEDURE save_segment_profile (
  p_product_segment_definition IN VARCHAR2
, x_status                     OUT NOCOPY VARCHAR2
, x_error_message              OUT NOCOPY VARCHAR2
) IS
BEGIN

   IF NOT fnd_profile.save(g_product_segment_profile_name, p_product_segment_definition, 'SITE') THEN
     x_status := g_no;
     x_error_message := sqlerrm;
     clear_cache;
     RETURN;
   END IF;

   x_status := g_yes;
   x_error_message := NULL;
   clear_cache;
END save_segment_profile;

FUNCTION get_segment_value_desc
  (p_product_segment_index IN NUMBER,
   p_segment_value IN VARCHAR2,
   p_parent_segment_value IN VARCHAR2
   ) RETURN VARCHAR2
  IS
     l_id_or_value fnd_flex_validation_tables.id_column_name%TYPE;
     l_cur cursor_ref_type;
     l_description fnd_flex_values_vl.description%TYPE;
     l_description2 fnd_flex_values_vl.description%TYPE;
     l_index NUMBER;
     l_string varchar2(1000);
BEGIN
   IF g_product_segments(p_product_segment_index).validation_type = 'F' THEN -- table
      -- build and cache the query if the query is not yet built
      IF g_description_queries(p_product_segment_index) IS NULL THEN
	 l_id_or_value := g_product_segments(p_product_segment_index).id_column;
	 IF l_id_or_value IS NULL THEN
	    l_id_or_value := g_product_segments(p_product_segment_index).value_column;
	 END IF;
                             /*Modified as as part of bug 8611906 considering where clause can be null also*/
                            IF (g_product_segments(p_product_segment_index).where_clause IS null) THEN
	        g_description_queries(p_product_segment_index) :=
	        'select ' ||
	         g_product_segments(p_product_segment_index).meaning_column || ' description' ||
	         ' from ' ||
	         g_product_segments(p_product_segment_index).table_name || ' where (' ||
	         l_id_or_value || ' = :1 )';

                          ELSE
                          select instr(g_product_segments(p_product_segment_index).where_clause,'ORDER BY') INTO l_index from dual;
                          IF(l_index=0) then
                          select instr(g_product_segments(p_product_segment_index).where_clause,'order by') INTO l_index from dual;
                          END IF;
                          IF (l_index=0) THEN
                          l_string := g_product_segments(p_product_segment_index).where_clause;
                          ELSE
                         SELECT SubStr(g_product_segments(p_product_segment_index).where_clause,1,l_index-1) INTO l_string FROM dual;
                         END IF;

                          g_description_queries(p_product_segment_index) :=
	       'select ' ||
	        g_product_segments(p_product_segment_index).meaning_column || ' description' ||
	        ' from ' ||
	        g_product_segments(p_product_segment_index).table_name ||
	        ' ' || l_string || ' and (' ||
	        l_id_or_value || ' = :1 )';

                        END IF;
                        /*Modified as as part of bug 8611906 considering where clause can be null also*/

      END IF;
      OPEN l_cur FOR g_description_queries(p_product_segment_index)
	using p_segment_value;
    ELSIF g_product_segments(p_product_segment_index).validation_type IN ('I') THEN
      -- validation type is independent
      g_description_queries(p_product_segment_index) :=
	'select description from fnd_flex_values_vl ' ||
	'where flex_value_set_id = :1 and flex_value = :2 ';
      OPEN l_cur FOR g_description_queries(p_product_segment_index)
	using g_product_segments(p_product_segment_index).value_set_id, p_segment_value;
    ELSIF  g_product_segments(p_product_segment_index).validation_type IN ('D') THEN
      -- validation type is dependent
      g_description_queries(p_product_segment_index) :=
	'select description from fnd_flex_values_vl ' ||
	' where flex_value_set_id = :1 and flex_value = :2 and parent_flex_value_low = :3';
      OPEN l_cur FOR g_description_queries(p_product_segment_index)
	using g_product_segments(p_product_segment_index).value_set_id,
	p_segment_value, p_parent_segment_value;
    ELSE
      -- should not reach here, as the validation type is checked during initialization
      raise_application_error
	(-2000, 'unsupported validation type: ' ||
	 g_product_segments(p_product_segment_index).validation_type
	 );
   END IF;
   --   dbms_output.put_line('query ' || g_description_queries(p_product_segment_index));
   FETCH l_cur INTO l_description;
   -- the query should return only one row for independent and dependent, but
   -- it could return multiple for table validation type which means data
   -- in custom table is not right
   -- we should ignore it for now
   FETCH l_cur INTO l_description2;
   --dbms_output.put_line(l_description2);
   CLOSE l_cur;
   --dbms_output.put_line('returning '||l_description);
   RETURN l_description;
END get_segment_value_desc;

FUNCTION get_product_description
  (p_product_segment_index IN NUMBER,
   p_segment_value IN VARCHAR2,
   p_parent_segment_value IN VARCHAR2
   ) RETURN VARCHAR2
IS
BEGIN
  RETURN get_segment_value_desc( p_product_segment_index, p_segment_value, p_parent_segment_value);
END get_product_description;

--FUNCTION get_segment_value(p_product_segment_index IN NUMBER,
--			   p_rec IN pos_sup_products_services%ROWTYPE ) RETURN VARCHAR2
FUNCTION get_segment_value(p_product_segment_index IN NUMBER,
			   p_rec IN category_segment_record ) RETURN VARCHAR2
  IS
     l_index NUMBER;
BEGIN
   l_index := p_product_segment_index;
   IF g_product_segments(l_index).column_name = 'SEGMENT1' THEN
      RETURN p_rec.segment1;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT2' THEN
      RETURN p_rec.segment2;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT3' THEN
      RETURN p_rec.segment3;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT4' THEN
      RETURN p_rec.segment4;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT5' THEN
      RETURN p_rec.segment5;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT6' THEN
      RETURN p_rec.segment6;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT7' THEN
      RETURN p_rec.segment7;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT8' THEN
      RETURN p_rec.segment8;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT9' THEN
      RETURN p_rec.segment9;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT10' THEN
      RETURN p_rec.segment10;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT11' THEN
      RETURN p_rec.segment11;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT12' THEN
      RETURN p_rec.segment12;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT13' THEN
      RETURN p_rec.segment13;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT14' THEN
      RETURN p_rec.segment14;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT15' THEN
      RETURN p_rec.segment15;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT16' THEN
      RETURN p_rec.segment16;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT17' THEN
      RETURN p_rec.segment17;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT18' THEN
      RETURN p_rec.segment18;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT19' THEN
      RETURN p_rec.segment19;
   ELSIF g_product_segments(l_index).column_name = 'SEGMENT20' THEN
      RETURN p_rec.segment20;
   END IF;
END get_segment_value;

PROCEDURE set_segment_value(
  p_segment_index IN NUMBER
, p_segment_value IN VARCHAR2
, p_rec IN OUT NOCOPY category_segment_record )

IS
BEGIN
   IF g_product_segments(p_segment_index).column_name = 'SEGMENT1' THEN
       p_rec.segment1:= p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT2' THEN
      p_rec.segment2 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT3' THEN
      p_rec.segment3 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT4' THEN
      p_rec.segment4 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT5' THEN
      p_rec.segment5 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT6' THEN
      p_rec.segment6 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT7' THEN
      p_rec.segment7 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT8' THEN
      p_rec.segment8 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT9' THEN
      p_rec.segment9 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT10' THEN
      p_rec.segment10 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT11' THEN
      p_rec.segment11 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT12' THEN
      p_rec.segment12 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT13' THEN
      p_rec.segment13 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT14' THEN
      p_rec.segment14 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT15' THEN
      p_rec.segment15 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT16' THEN
      p_rec.segment16 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT17' THEN
      p_rec.segment17 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT18' THEN
      p_rec.segment18 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT19' THEN
      p_rec.segment19 := p_segment_value;
   ELSIF g_product_segments(p_segment_index).column_name = 'SEGMENT20' THEN
      p_rec.segment20 := p_segment_value;
   END IF;
END set_segment_value;


PROCEDURE check_subcategory
  (p_classification_id IN  NUMBER,
   x_has_subcategory   OUT NOCOPY VARCHAR2)
  IS
     CURSOR l_cur IS
	SELECT * FROM pos_sup_products_services
	  WHERE classification_id = p_classification_id;
     l_rec l_cur%ROWTYPE;
     l_segment_values category_segment_record;
     l_query VARCHAR2(3000);
     l_segment_value pos_sup_products_services.segment1%TYPE;
     l_last_not_null INTEGER;
     l_cur2 cursor_ref_type;
     l_count NUMBER;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   l_segment_values.segment1 := l_rec.segment1;
   l_segment_values.segment2 := l_rec.segment2;
   l_segment_values.segment3 := l_rec.segment3;
   l_segment_values.segment4 := l_rec.segment4;
   l_segment_values.segment5 := l_rec.segment5;
   l_segment_values.segment6 := l_rec.segment6;
   l_segment_values.segment7 := l_rec.segment7;
   l_segment_values.segment8 := l_rec.segment8;
   l_segment_values.segment9 := l_rec.segment9;
   l_segment_values.segment10 := l_rec.segment10;
   l_segment_values.segment11 := l_rec.segment11;
   l_segment_values.segment12 := l_rec.segment12;
   l_segment_values.segment13 := l_rec.segment13;
   l_segment_values.segment14 := l_rec.segment14;
   l_segment_values.segment15 := l_rec.segment15;
   l_segment_values.segment16 := l_rec.segment16;
   l_segment_values.segment17 := l_rec.segment17;
   l_segment_values.segment18 := l_rec.segment18;
   l_segment_values.segment19 := l_rec.segment19;
   l_segment_values.segment20 := l_rec.segment20;

   -- bug 4157752
   -- l_last_not_null should be initialized
   l_last_not_null := 0;

   FOR l_index IN REVERSE 1..g_product_segment_count LOOP
      l_segment_value := get_segment_value(l_index, l_segment_values);
      IF l_segment_value IS NOT NULL THEN
	 l_last_not_null := l_index;
	 EXIT;
      END IF;
   END LOOP;

   IF l_last_not_null = g_product_segment_count THEN
      -- the classification has values in all product segments
      -- so it would not have any children sub categories
      x_has_subcategory := 'N';
      RETURN;
   END IF;

   l_query := 'select mcb.category_id from mtl_categories_b mcb, ' ||
     ' mtl_category_set_valid_cats mcsvc, pos_sup_products_services psps where ' ||
     ' (mcb.supplier_enabled_flag is null or mcb.supplier_enabled_flag = ''Y'' or mcb.supplier_enabled_flag = ''y'') ' ||
     ' and mcsvc.category_set_id = ' || g_default_po_category_set_id ||
     ' and mcb.category_id = mcsvc.category_id ' ||
     ' and psps.classification_id = :1 and (';
   l_count := 0;
   FOR l_index IN 1..l_last_not_null LOOP
      IF l_index > 1 THEN
	 l_query := l_query || ' and ';
      END IF;
      l_count := l_count + 1;
      l_query := l_query || ' psps.' || g_product_segments(l_index).column_name ||
	' = mcb. ' || g_product_segments(l_index).column_name;
   END LOOP;
   /*Added as part of Bug 8611906 the query build was not proper without this*/
   IF(l_count >= 1) THEN
   l_query := l_query || ' and psps.' || g_product_segments(l_last_not_null + 1).column_name || ' is null ' ||
     ' and mcb.' || g_product_segments(l_last_not_null + 1).column_name || ' is not null) and rownum < 2';
   ELSE
    l_query := l_query || ' psps.' || g_product_segments(l_last_not_null + 1).column_name || ' is null ' ||
     ' and mcb.' || g_product_segments(l_last_not_null + 1).column_name || ' is not null) and rownum < 2';
    END IF;
    /*Added as part of Bug 8611906 the query build was not proper without this*/

   OPEN l_cur2 FOR l_query using p_classification_id;
   FETCH l_cur2 INTO l_count;
   IF l_cur2%notfound THEN
      x_has_subcategory := 'N';
    ELSE
      x_has_subcategory := 'Y';
   END IF;
   CLOSE l_cur2;
END check_subcategory;

--
-- before calling other procedures in this package,
-- call this procedure to initialize
--
-- x_status:                     Y or N for success or failure
-- x_error_message:              an error message if there is an error
--
PROCEDURE initialize
  (x_status                     OUT NOCOPY VARCHAR2,
   x_error_message              OUT NOCOPY VARCHAR2
   ) IS
BEGIN
   IF g_product_segment_definition IS NULL THEN
      do_init(x_status, x_error_message);
      IF x_status = g_no THEN
	 RETURN;
      END IF;
   END IF;

   x_status := g_yes;
   x_error_message := NULL;
END initialize;

PROCEDURE get_product_meta_data
  (x_product_segment_definition OUT NOCOPY VARCHAR2,
   x_product_segment_count      OUT NOCOPY NUMBER,
   x_default_po_category_set_id OUT NOCOPY NUMBER,
   x_delimiter                  OUT NOCOPY VARCHAR2
   ) IS
BEGIN
   assert_init();
   x_product_segment_definition := g_product_segment_definition;
   x_product_segment_count := g_product_segment_count;
   x_default_po_category_set_id := g_default_po_category_set_id;
   x_delimiter := g_delimiter;
END get_product_meta_data;

PROCEDURE get_product_segment_info
  (p_index            	  IN  NUMBER,
   x_column_name      	  OUT NOCOPY VARCHAR2,
   x_value_set_id     	  OUT NOCOPY NUMBER,
   x_validation_type  	  OUT NOCOPY VARCHAR2,
   x_table_name       	  OUT NOCOPY VARCHAR2,
   x_meaning_column   	  OUT NOCOPY VARCHAR2,
   x_id_column        	  OUT NOCOPY VARCHAR2,
   x_value_column     	  OUT NOCOPY VARCHAR2,
   x_where_clause     	  OUT NOCOPY VARCHAR2,
   x_parent_segment_index OUT NOCOPY INTEGER
   ) IS
BEGIN
   assert_init();

   IF p_index IS NULL OR p_index > g_product_segment_count OR p_index < 0 THEN
      raise_application_error
	(-2000, 'invalid parameter value for p_index: ' || p_index);
   END IF;

   x_column_name     := g_product_segments(p_index).column_name;
   x_value_set_id    := g_product_segments(p_index).value_set_id;
   x_validation_type := g_product_segments(p_index).validation_type;
   x_table_name      := g_product_segments(p_index).table_name;
   x_meaning_column  := g_product_segments(p_index).meaning_column;
   x_id_column       := g_product_segments(p_index).id_column;
   x_value_column    := g_product_segments(p_index).value_column;
   x_where_clause    := g_product_segments(p_index).where_clause;
   x_parent_segment_index := g_product_segments(p_index).parent_segment_index;
END get_product_segment_info;

-------------------------------------------------------------
-- given the values of a category (or selection), generate
-- the string 'desc.desc.desc'
-------------------------------------------------------------
PROCEDURE get_concatenated_description (
  p_segments    IN  category_segment_record
, x_description OUT NOCOPY VARCHAR2 )
IS
     l_segment_value mtl_categories_b.segment1%TYPE;
     l_parent_segment_value mtl_categories_b.segment1%TYPE;
     l_result VARCHAR2(3000);
BEGIN
   assert_init();
   --dbms_output.put_line('count ' || g_product_segment_count);
   FOR l_index IN 1..g_product_segment_count LOOP
      l_segment_value := get_segment_value(l_index, p_segments);
      --dbms_output.put_line('value is '|| l_segment_value);
      IF l_segment_value IS NULL THEN
         EXIT;
      END IF;
      IF g_product_segments(l_index).validation_type = 'D' THEN
         l_parent_segment_value :=
           get_segment_value(g_product_segments(l_index).parent_segment_index, p_segments);
       ELSE
         l_parent_segment_value := NULL;
      END IF;
      IF l_index = 1 THEN
         l_result := get_segment_value_desc(l_index, l_segment_value, l_parent_segment_value);
       ELSE
         l_result := l_result || g_delimiter ||
           get_segment_value_desc(l_index, l_segment_value, l_parent_segment_value);
      END IF;
   END LOOP;
   x_description := l_result;
   --dbms_output.put_line(x_description);
END get_concatenated_description;

--
-- get the description of product and service for a row
-- in pos_sup_products_services table.
--
PROCEDURE get_product_description
  (p_classification_id IN  NUMBER, x_description OUT NOCOPY VARCHAR2 ) IS
     CURSOR l_cur IS
	SELECT * FROM pos_sup_products_services
	  WHERE classification_id = p_classification_id;
     l_rec l_cur%ROWTYPE;
     l_segment_values category_segment_record;
     l_segment_value pos_sup_products_services.segment1%TYPE;
BEGIN
   assert_init();
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
   l_segment_values.segment1 := l_rec.segment1;
   l_segment_values.segment2 := l_rec.segment2;
   l_segment_values.segment3 := l_rec.segment3;
   l_segment_values.segment4 := l_rec.segment4;
   l_segment_values.segment5 := l_rec.segment5;
   l_segment_values.segment6 := l_rec.segment6;
   l_segment_values.segment7 := l_rec.segment7;
   l_segment_values.segment8 := l_rec.segment8;
   l_segment_values.segment9 := l_rec.segment9;
   l_segment_values.segment10 := l_rec.segment10;
   l_segment_values.segment11 := l_rec.segment11;
   l_segment_values.segment12 := l_rec.segment12;
   l_segment_values.segment13 := l_rec.segment13;
   l_segment_values.segment14 := l_rec.segment14;
   l_segment_values.segment15 := l_rec.segment15;
   l_segment_values.segment16 := l_rec.segment16;
   l_segment_values.segment17 := l_rec.segment17;
   l_segment_values.segment18 := l_rec.segment18;
   l_segment_values.segment19 := l_rec.segment19;
   l_segment_values.segment20 := l_rec.segment20;
   get_concatenated_description(l_segment_values, x_description);
   --dbms_output.put_line(x_description);
END get_product_description;

--
-- get the description of product and service represented
-- in the "category" format: 'value.value.valule..'
--
PROCEDURE get_product_description
  (p_category IN  VARCHAR2, x_description OUT NOCOPY VARCHAR2 ) IS

     l_segment_values category_segment_record;
     l_segment_value pos_sup_products_services.segment1%TYPE;

l_length NUMBER;
l_num_of_delim NUMBER;
l_index NUMBER;
l_delim_positions number_table;
l_start_pos NUMBER;
l_end_pos NUMBER;

BEGIN
   assert_init();

   l_length := length(p_category);
   l_num_of_delim := 0;

   -- count the delimiters
   FOR l_index IN 1..l_length LOOP
     IF substr(p_category,l_index,1) = '.' THEN
       l_num_of_delim := l_num_of_delim + 1;
       l_delim_positions(l_num_of_delim) := l_index;
     END IF;
   END LOOP;

   -- extract segment values
   FOR l_index IN 1..l_num_of_delim + 1 LOOP
     IF l_index = 1 THEN
       l_start_pos := 1;
     ELSE
       l_start_pos := l_delim_positions(l_index-1) + 1;
     END IF;
     IF l_index <= l_num_of_delim THEN
       l_end_pos := l_delim_positions(l_index) - 1;
     ELSE
       l_end_pos := l_length;
     END IF;
     l_segment_value := substr(p_category,
                               l_start_pos,
			       l_end_pos - l_start_pos + 1);
     set_segment_value(l_index, l_segment_value, l_segment_values);
   END LOOP;

   get_concatenated_description(l_segment_values, x_description);
   --dbms_output.put_line(x_description);
END get_product_description;

-- get the description of product and service for a row
-- in pos_sup_products_services table, and whether there
-- is a subcategories for the product and service
PROCEDURE get_desc_check_subcategory
  (p_classification_id IN  NUMBER,
   x_description       OUT NOCOPY VARCHAR2,
   x_has_subcategory   OUT NOCOPY VARCHAR2 -- return Y or N
   ) IS
BEGIN
   get_product_description(p_classification_id, x_description);
   check_subcategory(p_classification_id,x_has_subcategory);
END get_desc_check_subcategory;

FUNCTION debug_to_string RETURN VARCHAR2
  IS
   l_var VARCHAR2(3000);
BEGIN
   assert_init();

   l_var := 'default po category set id = ' || g_default_po_category_set_id ||
     ', product segment definition = ' || g_product_segment_definition ||
     ', product segment count = ' || g_product_segment_count;

   FOR l_index IN 1..g_product_segment_count LOOP
      l_var := l_var || '; product segment ' || l_index ||
	' - column name = ' || g_product_segments(l_index).column_name ||
	', value set id = ' || g_product_segments(l_index).value_set_id ||
	', validation_type = ' || g_product_segments(l_index).validation_type;

      IF g_product_segments(l_index).validation_type = 'F' THEN -- table
	 l_var := l_var || ', table_name = ' || g_product_segments(l_index).table_name ||
	   ', meaning_column = ' || g_product_segments(l_index).meaning_column ||
	   ', id_column = ' || g_product_segments(l_index).id_column ||
	   ', value_column = ' || g_product_segments(l_index).value_column ||
	   ', where_clause = ' || g_product_segments(l_index).where_clause;
      END IF;

      l_var := l_var || '.';
   END LOOP;
   RETURN l_var;
END debug_to_string;

FUNCTION get_vendor_by_category_query RETURN VARCHAR2
  IS
     l_query VARCHAR2(4000);
BEGIN
   assert_init();
   l_query := 'select psps.vendor_id, mcb.category_id from mtl_categories_b mcb, ' ||
     ' mtl_category_set_valid_cats mcsvc, pos_sup_products_services psps where ' ||
     ' (mcb.supplier_enabled_flag is null or mcb.supplier_enabled_flag = ''Y'' or mcb.supplier_enabled_flag = ''y'') ' ||
     ' and mcsvc.category_set_id = ' || g_default_po_category_set_id ||
     ' and mcb.category_id = mcsvc.category_id and (';
   FOR l_index IN 1..g_product_segment_count LOOP
      IF l_index > 1 THEN
	 l_query := l_query || ' or ';
      END IF;

      FOR l_index2 IN 1..l_index LOOP
	 IF l_index2 > 1 THEN
	    l_query := l_query || ' and ';
	 END IF;
	 l_query := l_query || ' psps.' || g_product_segments(l_index).column_name ||
	   ' = mcb.' || g_product_segments(l_index).column_name;
      END LOOP;

      FOR l_index2 IN l_index+1..g_product_segment_count LOOP
	 l_query := l_query || ' and psps.' || g_product_segments(l_index).column_name || ' is null';
      END LOOP;
   END LOOP;
   l_query := l_query || ')';
   RETURN l_query;
END get_vendor_by_category_query;
/* Added following for P and S ER 7482793  */

   -- Insert the validation set values into global temp table for each of the
   -- segments enabled for products and services

   PROCEDURE insert_into_glb_temp
   (
       p_validation_type     IN  VARCHAR2,
       p_curr_seg_val_id     IN  NUMBER,
       p_parent_seg_val_id   IN  NUMBER,
       p_table_name          IN VARCHAR2,
       p_where_clause        IN VARCHAR2,
       p_meaning             IN VARCHAR2,
       p_id_column           IN VARCHAR2,
       p_value_column        IN VARCHAR2,
       p_column_name         IN VARCHAR2,
       p_parent_column_name  IN VARCHAR2,
       l_hierarchy           IN NUMBER,
       x_return_status       OUT nocopy VARCHAR2,
       x_msg_count           OUT nocopy NUMBER,
       x_msg_data            OUT nocopy VARCHAR2
   ) IS
   l_sql varchar2(4000) := null;
   l_tbl_sql varchar2(4000) := null;
   l_valorid_col  varchar2(300) := null;
   l_tblcur       cursor_ref_type;
   l_description varchar2(2000);
   l_value       varchar2(2000);
   l_value_id varchar2(2000);
   l_parent_value varchar2(2000);
   l_parent_value_id varchar2(2000);
   l_parent_value2 varchar2(2000);
   l_parent_value_id2 varchar2(2000);
   l_cur cursor_ref_type;
   l_count NUMBER;
   l_parent_column_name VARCHAR2(20);


   BEGIN

/*Bug 9043064 (FP 9011350) Added the following debug statements.*/

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_validation_type : '||p_validation_type);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_curr_seg_val_id : '||p_curr_seg_val_id);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_parent_seg_val_id : '||p_parent_seg_val_id);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_table_name : '||p_table_name);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_where_clause : '||p_where_clause);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_meaning : '||p_meaning);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_id_column : '||p_id_column);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_value_column : '||p_value_column);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_column_name : '||p_column_name);
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'p_parent_column_name : '||p_parent_column_name);
END IF;
       /*Modified as as part of bug 8611906 considering where clause can be null also and syncind data in global temp table with other VO used fro browse specific*/
      if (p_validation_type = 'I') then
       if (l_hierarchy = 1) then
/*Bug 9043064 (FP 9011350) Added a condition to pick the categories only that are viewable by supplier.*/
         l_tbl_sql := 'SELECT ffvl.flex_value,
                      ffvl.description,
                      ffvl.flex_value_id,
                      null parent_value,
                      null parent_value_id
                      FROM fnd_flex_values_vl ffvl,
                      mtl_categories_b mcb,
                      mtl_category_set_valid_cats mcsvc
                     WHERE ffvl.flex_value_set_id = '|| p_curr_seg_val_id ||
                     ' AND  mcb.category_id = mcsvc.category_id
                     and (mcb.supplier_enabled_flag is null or mcb.supplier_enabled_flag =  ''Y'' or mcb.supplier_enabled_flag = ''y'')
                     AND  mcsvc.category_set_id =' ||  g_default_po_category_set_id ||
                     ' AND  ffvl.flex_value = mcb.' || p_column_name || ' and not exists (select SEGMENT_VALUE_ID
                                     from pos_products_services_gt
                                     where SEGMENT_VALUE_ID = ffvl.flex_value_id )';

      elsif (l_hierarchy > 1) then
        l_tbl_sql := 'SELECT ffvl.flex_value,
                      ffvl.description,
                      ffvl.flex_value_id,
                      gt.segment_value parent_value,
                         gt.segment_value_id parent_value_id
                      FROM fnd_flex_values_vl ffvl,
                      mtl_categories_b mcb,
                      mtl_category_set_valid_cats mcsvc,
                      pos_products_services_gt gt
                     WHERE ffvl.flex_value_set_id = '|| p_curr_seg_val_id ||
                     ' AND  mcb.category_id = mcsvc.category_id
                     and (mcb.supplier_enabled_flag is null or mcb.supplier_enabled_flag =  ''Y'' or mcb.supplier_enabled_flag = ''y'')
                     AND  mcsvc.category_set_id =' ||  g_default_po_category_set_id ||
                     ' AND  ffvl.flex_value = mcb.' || p_column_name || '
                     and gt.hierarchy_level = ' || l_hierarchy || ' -1 '||'
                     and  gt.segment_value = mcb.' ||  p_parent_column_name || '
                      and not exists (select SEGMENT_VALUE_ID
                                     from pos_products_services_gt
                                     where SEGMENT_VALUE_ID = ffvl.flex_value_id )';
end if;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'l_tbl_sql (I) : '||l_tbl_sql);
END IF;

      OPEN l_tblcur for l_tbl_sql;
      loop
     FETCH l_tblcur INTO l_value , l_description , l_value_id ,l_parent_value,l_parent_value_id;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos_product_service_utl_pkg.insert_into_glb_temp.gt table data', 'pos_products_services_gt : '||l_value||l_description||l_parent_value||l_parent_value_id||l_hierarchy||l_value_id);
END IF;

      EXIT WHEN l_tblcur%NOTFOUND;
      select Count(*) INTO l_count  FROM pos_products_services_gt WHERE SEGMENT_VALUE_ID = l_value_id  ;
      IF(l_count = 0) THEN

      insert into pos_products_services_gt(SEGMENT_VALUE ,
                          SEGMENT_VALUE_DESCRIPTION   ,
                          SUPPLIER_SELECTION          ,
                          PARENT_SEGMENT_VALUE        ,
                          PARENT_SEGMENT_VALUE_ID     ,
                          HIERARCHY_LEVEL             ,
                          SEGMENT_VALUE_ID            ,
                          LAST_UPDATE_DATE            ,
                          LAST_UPDATED_BY             ,
                          LAST_UPDATE_LOGIN           ,
                          CREATION_DATE               ,
                          CREATED_BY                 )
               values(l_value,
               l_description,
               null,
               l_parent_value,
               l_parent_value_id,
               l_hierarchy,
               l_value_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               sysdate,
               fnd_global.user_id);

           END IF;

           end loop;
           CLOSE l_tblcur;

      elsif (p_validation_type = 'D') then

/*Bug 9043064 (FP 9011350) Added a condition to pick the categories only that are viewable by supplier.*/

       l_sql := 'select distinct ffvl.flex_value,
                    ffvl.flex_value_id
                    from fnd_flex_values_vl ffvl,
                    mtl_categories_b mcb,
                    mtl_category_set_valid_cats mcsvc
                    where ffvl.flex_value_set_id = ' || p_parent_seg_val_id || ' AND
                    mcb.category_id  = mcsvc.category_id
		    and (mcb.supplier_enabled_flag is null or mcb.supplier_enabled_flag =  ''Y'' or mcb.supplier_enabled_flag = ''y'')
                    AND mcsvc.category_set_id = '||  g_default_po_category_set_id ||
                    ' AND  ffvl.flex_value = mcb.' || p_parent_column_name ;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'l_sql : '||l_sql);
END IF;


      OPEN l_cur FOR l_sql;
         LOOP
         FETCH l_cur INTO l_parent_value  , l_parent_value_id ;
         EXIT WHEN l_cur%NOTFOUND;

           /*Bug 9043064 (FP 9011350) Added a condition to pick the categories only that are viewable by supplier.*/
          l_tbl_sql := 'SELECT ffvl2.flex_value,
		                       ffvl2.description,
                               ffvl2.flex_value_id
                        FROM   fnd_flex_values_vl ffvl2,
                               mtl_categories_b mcb1,
                               mtl_category_set_valid_cats mcsvc1
                        WHERE  ffvl2.flex_value_set_id = ' || p_curr_seg_val_id || ' and
                               mcb1.category_id  = mcsvc1.category_id AND
                               (mcb1.supplier_enabled_flag is null or mcb1.supplier_enabled_flag =  ''Y'' or mcb1.supplier_enabled_flag = ''y'') and
                               mcsvc1.category_set_id = '||  g_default_po_category_set_id || ' AND
                               ffvl2.flex_value = mcb1.'|| p_column_name || ' and
                               ffvl2.parent_flex_value_low =  mcb1.'|| p_parent_column_name || ' and
                               ffvl2.parent_flex_value_low = '||'''' || l_parent_value || '''' ||' and
                               not exists  (select SEGMENT_VALUE_ID
                                            from pos_products_services_gt
                                            where  SEGMENT_VALUE_ID = ffvl2.flex_value_id)' ;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'l_tbl_sql (D) : '||l_tbl_sql);
END IF;

      OPEN l_tblcur for l_tbl_sql;
      loop
      FETCH l_tblcur INTO l_value , l_description , l_value_id ;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos_product_service_utl_pkg.insert_into_glb_temp.gt table data', 'pos_products_services_gt : '||l_value||l_description||l_parent_value||l_parent_value_id||l_hierarchy||l_value_id);
END IF;

      EXIT WHEN l_tblcur%NOTFOUND;
       select Count(*) INTO l_count  FROM pos_products_services_gt WHERE SEGMENT_VALUE_ID = l_value_id  ;
        IF(l_count = 0) THEN


      insert into pos_products_services_gt(SEGMENT_VALUE ,
                          SEGMENT_VALUE_DESCRIPTION   ,
                          SUPPLIER_SELECTION          ,
                          PARENT_SEGMENT_VALUE        ,
                          PARENT_SEGMENT_VALUE_ID     ,
                          HIERARCHY_LEVEL             ,
                          SEGMENT_VALUE_ID            ,
                          LAST_UPDATE_DATE            ,
                          LAST_UPDATED_BY             ,
                          LAST_UPDATE_LOGIN           ,
                          CREATION_DATE               ,
                          CREATED_BY                 )
               values(l_value,
               l_description,
               null,
               l_parent_value,
               l_parent_value_id,
               l_hierarchy,
               l_value_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               sysdate,
               fnd_global.user_id);

               END IF;
               end loop;
            CLOSE l_tblcur;

         end loop;
         CLOSE l_cur;

      elsif (p_validation_type = 'F') then
       if (p_id_column is not null) then
         l_valorid_col := p_id_column;
      else
         l_valorid_col := p_value_column;
      end if;

      IF(p_where_clause IS not null ) then
	-- Bug 9126584 (FP 9056630). Added spaces to construct the query string properly.
        l_tbl_sql := 'select distinct mcb.'||p_column_name || ' value,
                      x.description description
                      from mtl_categories_b mcb,  mtl_category_set_valid_cats mcsvc,(SELECT '||p_meaning||' description, '||
              l_valorid_col||' value '||
              ' FROM '||p_table_name||' '||
               p_where_clause||
              ') x where mcb.' || p_column_name ||' is not null
              and (mcb.supplier_enabled_flag is null or mcb.supplier_enabled_flag =  ''Y''
              or mcb.supplier_enabled_flag = ''y'')
              and mcb.category_id = mcsvc.category_id  and mcsvc.category_set_id ='||g_default_po_category_set_id || ' and
             To_Char(x.value) = mcb.'||p_column_name|| '    AND NOT EXISTS (select SEGMENT_VALUE_ID from pos_products_services_gt where SEGMENT_VALUE_ID = x.value ) ';

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'l_tbl_sql (T1) : '||l_tbl_sql);
END IF;

        ELSE
           l_tbl_sql := 'select distinct mcb.' ||p_column_name ||' value,
                      x.description description
                      from mtl_categories_b mcb,  mtl_category_set_valid_cats mcsvc,'||'(SELECT '||p_meaning||' description, '||
              l_valorid_col||' value '||
              ' FROM '||p_table_name|| ') x where mcb.' || p_column_name ||' is not null
              and (mcb.supplier_enabled_flag is null or mcb.supplier_enabled_flag =  ''Y''
              or mcb.supplier_enabled_flag = ''y'')
              and mcb.category_id = mcsvc.category_id  and mcsvc.category_set_id ='||g_default_po_category_set_id || ' and
             To_Char(x.value) = mcb.'||p_column_name||

              ' and  NOT EXISTS (select SEGMENT_VALUE_ID from pos_products_services_gt where SEGMENT_VALUE_ID = x.value ) ';

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.insert_into_glb_temp.begin', 'l_tbl_sql (T2) : '||l_tbl_sql);
END IF;

        END IF;

      OPEN l_tblcur for l_tbl_sql;
      loop
      FETCH l_tblcur INTO l_value ,  l_description;
      EXIT WHEN l_tblcur%NOTFOUND;
          insert into pos_products_services_gt(SEGMENT_VALUE ,
                             SEGMENT_VALUE_DESCRIPTION   ,
                             SUPPLIER_SELECTION          ,
                             PARENT_SEGMENT_VALUE        ,
                             PARENT_SEGMENT_VALUE_ID     ,
                             HIERARCHY_LEVEL             ,
                             SEGMENT_VALUE_ID            ,
                             LAST_UPDATE_DATE            ,
                             LAST_UPDATED_BY             ,
                             LAST_UPDATE_LOGIN           ,
                             CREATION_DATE               ,
                             CREATED_BY                 )
           values(l_value,
                  l_description,
                  null,
                  null,
                  null,
                  null,
                  l_value,
                  sysdate,
                  fnd_global.user_id,
                  fnd_global.login_id,
                  sysdate,
                  fnd_global.user_id);

       end loop;
       CLOSE l_tblcur;
      end if;
       /*Modified as as part of bug 8611906 considering where clause can be null also and syncind data in global temp table with other VO used fro browse specific*/
     /*commit;*/
     /*Commented commit as part of bug:16437430*/
   EXCEPTION
       WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_msg_data := 'Insert into Global temp failed  ';
         rollback;
         raise_application_error(-20013, x_msg_data, true);

   END insert_into_glb_temp;

   /* Function to get concatenated segment value description */

   FUNCTION get_segment_value_description(x_segment_value_id VARCHAR2)
   RETURN VARCHAR2
   IS
     l_contact_description VARCHAR2(4000) := null;
     l_segment_value_description VARCHAR2(240) := null;
     CURSOR c1 IS
     SELECT SEGMENT_VALUE_DESCRIPTION
     FROM pos_products_services_gt
     START WITH segment_value_id = x_segment_value_id
     CONNECT BY PRIOR parent_segment_value_id =segment_value_id
     ORDER BY HIERARCHY_LEVEL asc;

   BEGIN
     OPEN c1;
     LOOP
       FETCH c1 INTO l_segment_value_description;
       EXIT WHEN C1%NOTFOUND;
       IF (l_segment_value_description IS NOT NULL AND l_contact_description IS NOT NULL) THEN
          l_contact_description := l_contact_description||g_delimiter;
          l_contact_description := l_contact_description||l_segment_value_description;
       ELSIF (l_segment_value_description IS NOT NULL AND l_contact_description IS NULL) THEN
          l_contact_description := l_segment_value_description;
       END IF;
     END LOOP;
     CLOSE c1;

     RETURN (l_contact_description);
   END get_segment_value_description;

   /* Function to get concatenated segment value code */

   FUNCTION get_segment_value_code(x_segment_value_id VARCHAR2)
   RETURN VARCHAR2
   IS
     l_contact_code VARCHAR2(4000) := null;
     l_segment_value_code VARCHAR2(240) := null;
     CURSOR c1 IS
     SELECT SEGMENT_VALUE
     FROM pos_products_services_gt
     START WITH segment_value_id = x_segment_value_id
     CONNECT BY PRIOR parent_segment_value_id =segment_value_id
     ORDER BY HIERARCHY_LEVEL asc;

   BEGIN
     OPEN c1;
     LOOP
       FETCH c1 INTO l_segment_value_code;
       EXIT WHEN C1%NOTFOUND;
       IF  (l_segment_value_code IS NOT NULL AND  l_contact_code IS NOT NULL) THEN
            l_contact_code := l_contact_code || g_delimiter;
            l_contact_code := l_contact_code || l_segment_value_code;
       ELSIF (l_segment_value_code IS NOT NULL AND  l_contact_code IS NULL) THEN
            l_contact_code := l_segment_value_code;
       END IF;
     END LOOP;
     CLOSE c1;

     RETURN (l_contact_code);
   END get_segment_value_code;

   /* Function to get classification id for a segment value code for the current vendor */

   FUNCTION get_classid(x_segment_code in VARCHAR2,x_vendor_id in NUMBER)
   RETURN NUMBER
   IS
     TYPE cursor_ref_type IS REF CURSOR;
     l_start_pos       number         := 0;
     l_index           number         := 0;
     l_concat_value    varchar2(4000) := null;
     l_next_seg        varchar2(4000) := null;
     l_class_id        number         := 0;
     l_segcode_val     varchar2(2000) := null;
     l_sql             varchar2(4000) := null;
     l_parent_sql      varchar2(4000) := null;
     l_pscur           cursor_ref_type;
     l_seg_def         fnd_profile_option_values.profile_option_value%TYPE;
     l_product_segment_profile_name CONSTANT VARCHAR2(30) := 'POS_PRODUCT_SERVICE_SEGMENTS';

   begin

     l_seg_def     := fnd_profile.value(l_product_segment_profile_name);
     l_segcode_val := x_segment_code;

     while (length(l_seg_def)) > l_start_pos
     loop
        /*
 	        Bug 8358082 : delimiter of segment numbers in the profile is always '.'.
 	        it doesnot depend on the flex delimiter. in the below statement replace
 	        g_delimiter with '.'
 	     */
       l_index      := instr(l_seg_def,'.',l_start_pos+1);
       if (l_index = 0) then
         exit;
       end if;
       l_concat_value :=  l_concat_value||'segment'||substr(l_seg_def,l_start_pos+1,(l_index-l_start_pos-1))||'||'||''''||g_delimiter||''''||'||';
       l_start_pos      := l_index;
     end loop;
     l_concat_value := l_concat_value||'segment'||substr(l_seg_def,l_start_pos+1);



     l_sql := 'SELECT classification_id
              FROM pos_sup_products_services
              WHERE '||l_concat_value||'='||''''||l_segcode_val||''''||
              'AND status <> '||''''||'X'||''''||
              'AND vendor_id = '||x_vendor_id||
              'union all
               select PS_REQUEST_ID classification_id
               from POS_PRODUCT_SERVICE_REQUESTS psr , POS_SUPPLIER_MAPPINGS pmapp
               WHERE '||l_concat_value||'='||''''||l_segcode_val||''''||
               'and pmapp.mapping_id = psr.MAPPING_ID
               AND (psr.REQUEST_STATUS =''PENDING'' or psr.REQUEST_STATUS =''REJECTED'')
               AND pmapp.vendor_id = '||x_vendor_id  ;


      OPEN l_pscur for l_sql;
      FETCH l_pscur INTO l_class_id;
      CLOSE l_pscur;


   /* check if the immediate parent has been already selected. If so return the classification Id of the parent for the children .
   This will disable the children on the screen so user cannot select them again
   */

   if (l_class_id = 0) then
     if (instr(l_concat_value,g_delimiter,-1) <> 0 ) then
       l_next_seg := substr(l_concat_value,instr(l_concat_value,g_delimiter,-1)+4);
       l_concat_value := substr(l_concat_value,1,(instr(l_concat_value,g_delimiter,-1)-4));
     end if;
      if (instr(l_segcode_val,g_delimiter,-1) <> 0) then
       l_segcode_val := substr(l_segcode_val,1,(instr(l_segcode_val,g_delimiter,-1)-1));
      end if;


      l_parent_sql := 'SELECT classification_id
              FROM pos_sup_products_services
       WHERE '||l_concat_value||'='||''''||l_segcode_val||''''||
              'AND '||l_next_seg||' is null '||
              'AND status <> '||''''||'X'||''''||
              'AND vendor_id = '||x_vendor_id||
               'union all
               select PS_REQUEST_ID classification_id
               from POS_PRODUCT_SERVICE_REQUESTS psr , POS_SUPPLIER_MAPPINGS pmapp
               WHERE '||l_concat_value||'='||''''||l_segcode_val||''''||
               'AND '||l_next_seg||' is null '||
               'and pmapp.mapping_id = psr.MAPPING_ID
                AND (psr.REQUEST_STATUS ='||''''||'PENDING'||''''|| 'or psr.REQUEST_STATUS ='||''''|| 'REJECTED'||''''||')
               AND pmapp.vendor_id = '||x_vendor_id ;


       OPEN l_pscur for l_parent_sql;
       FETCH l_pscur INTO l_class_id;
       CLOSE l_pscur;

   end if;

     return l_class_id;

   end;
   /*Function to get request id for prospective supplier user*/
   FUNCTION get_requestid(x_segment_code in VARCHAR2,x_mapp_id IN NUMBER )
   RETURN NUMBER
   IS
     TYPE cursor_ref_type IS REF CURSOR;
     l_start_pos       number         := 0;
     l_index           number         := 0;
     l_concat_value    varchar2(4000) := null;
     l_next_seg        varchar2(4000) := null;
     l_class_id        number         := 0;
     l_segcode_val     varchar2(2000) := null;
     l_sql             varchar2(4000) := null;
     l_parent_sql      varchar2(4000) := null;
     l_pscur           cursor_ref_type;
     l_seg_def         fnd_profile_option_values.profile_option_value%TYPE;
     l_product_segment_profile_name CONSTANT VARCHAR2(30) := 'POS_PRODUCT_SERVICE_SEGMENTS';


    begin

     l_seg_def     := fnd_profile.value(l_product_segment_profile_name);

     l_segcode_val := x_segment_code;

     while (length(l_seg_def)) > l_start_pos
     loop
        /*
 	        Bug 8358082 : delimiter of segment numbers in the profile is always '.'.
 	        it doesnot depend on the flex delimiter. in the below statement replace
 	        g_delimiter with '.'
 	     */
       l_index      := instr(l_seg_def,'.',l_start_pos+1);
       if (l_index = 0) then
         exit;
       end if;
       l_concat_value :=  l_concat_value||'segment'||substr(l_seg_def,l_start_pos+1,(l_index-l_start_pos-1))||'||'||''''||g_delimiter||''''||'||';
       l_start_pos      := l_index;
     end loop;
     l_concat_value := l_concat_value||'segment'||substr(l_seg_def,l_start_pos+1);



     l_sql := 'select PS_REQUEST_ID
               from POS_PRODUCT_SERVICE_REQUESTS
               WHERE '||l_concat_value||'='||''''||l_segcode_val||''''||
               'and MAPPING_ID='||x_mapp_id||
               'AND REQUEST_STATUS =''PENDING'' ';



      OPEN l_pscur for l_sql;
      FETCH l_pscur INTO l_class_id;
      CLOSE l_pscur;


   /* check if the immediate parent has been already selected. If so return the classification Id of the parent for the children .
   This will disable the children on the screen so user cannot select them again
   */

   if (l_class_id = 0) then
     if (instr(l_concat_value,g_delimiter,-1) <> 0 ) then
       l_next_seg := substr(l_concat_value,instr(l_concat_value,g_delimiter,-1)+4);
       l_concat_value := substr(l_concat_value,1,(instr(l_concat_value,g_delimiter,-1)-4));
     end if;
      if (instr(l_segcode_val,g_delimiter,-1) <> 0) then
       l_segcode_val := substr(l_segcode_val,1,(instr(l_segcode_val,g_delimiter,-1)-1));
      end if;


      l_parent_sql := '
               select PS_REQUEST_ID
               from POS_PRODUCT_SERVICE_REQUESTS
               WHERE '||l_concat_value||'='||''''||l_segcode_val||''''||
               'AND '||l_next_seg||' is null '||
               'and MAPPING_ID='||x_mapp_id||
                'AND REQUEST_STATUS =''PENDING''';




       OPEN l_pscur for l_parent_sql;
       FETCH l_pscur INTO l_class_id;
       CLOSE l_pscur;

   end if;

     return l_class_id;

   end;


   /* Function to get Concatenate Code value for a given classification id */

   FUNCTION get_concat_code(x_classification_id in varchar2)
   RETURN VARCHAR2 IS
     l_index           number         := 0;
     l_concat_code     varchar2(4000) := null;
     l_segcode_val     varchar2(2000) := null;

     Cursor ps_code_cur is
     (select segment1 , segment2, segment3 , segment4,segment5 , segment6,segment7 , segment8,segment9 , segment10,
     segment11 , segment12,segment13 , segment14,segment15 , segment16,segment17 , segment18,segment19 , segment20
     from pos_sup_products_services
     where classification_id = x_classification_id)
     UNION ALL
     (select segment1 , segment2, segment3 , segment4,segment5 , segment6,segment7 , segment8,segment9 , segment10,
     segment11 , segment12,segment13 , segment14,segment15 , segment16,segment17 , segment18,segment19 , segment20
     from POS_PRODUCT_SERVICE_REQUESTS
     where PS_REQUEST_ID = x_classification_id);

    l_rec category_segment_record;

   BEGIN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'Entering get_concat_code x_classification_id: ' || x_classification_id);
      END IF;
      assert_init();

      OPEN ps_code_cur;
      FETCH ps_code_cur INTO l_rec;
      IF ps_code_cur%notfound THEN
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'No data found.');
         END IF;
         CLOSE ps_code_cur;
         RAISE no_data_found;
      END IF;
      CLOSE ps_code_cur;

      FOR l_index IN  1..g_product_segment_count LOOP
        l_segcode_val := get_segment_value(l_index, l_rec);
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'At level: ' || l_index || ' value: ' || l_segcode_val);
        END IF;
        if l_segcode_val is null then
         EXIT;
        else
          if l_index = 1 then
            l_concat_code := l_segcode_val;
          else
            l_concat_code := l_concat_code||g_delimiter||l_segcode_val;
          end if;
       end if;
      END LOOP;
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'Leaving get_concat_code return ' || l_concat_code);
      END IF;
      return l_concat_code;

   end;

  /* Function to get Concatenate Code value for a given classification id and record type(approved or pending)*/

   FUNCTION get_concat_code(x_classification_id in VARCHAR2,record_type IN VARCHAR2)
   RETURN VARCHAR2 IS
     l_index           number         := 0;
     l_concat_code     varchar2(4000) := null;
     l_segcode_val     varchar2(2000) := null;


     Cursor ps_code_cur1 is
     (select segment1 , segment2, segment3 , segment4,segment5 , segment6,segment7 , segment8,segment9 , segment10,
     segment11 , segment12,segment13 , segment14,segment15 , segment16,segment17 , segment18,segment19 , segment20
     from pos_sup_products_services
     where classification_id = x_classification_id);


     Cursor ps_code_cur2 is
     (select segment1 , segment2, segment3 , segment4,segment5 , segment6,segment7 , segment8,segment9 , segment10,
     segment11 , segment12,segment13 , segment14,segment15 , segment16,segment17 , segment18,segment19 , segment20
     from POS_PRODUCT_SERVICE_REQUESTS
     where PS_REQUEST_ID = x_classification_id);


    l_rec category_segment_record;

   BEGIN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'Entering get_concat_code x_classification_id: ' || x_classification_id);
      END IF;
      assert_init();

       IF(record_type = 'MAIN') THEN
         OPEN ps_code_cur1;
      FETCH ps_code_cur1 INTO l_rec;
      IF ps_code_cur1%notfound THEN
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'No data found.');
         END IF;
         CLOSE ps_code_cur1;
         RAISE no_data_found;
      END IF;
      CLOSE ps_code_cur1;

     ELSE
      OPEN ps_code_cur2;
      FETCH ps_code_cur2 INTO l_rec;
      IF ps_code_cur2%notfound THEN
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'No data found.');
         END IF;
         CLOSE ps_code_cur2;
         RAISE no_data_found;
      END IF;
      CLOSE ps_code_cur2;
      END IF;

      FOR l_index IN  1..g_product_segment_count LOOP
        l_segcode_val := get_segment_value(l_index, l_rec);
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'At level: ' || l_index || ' value: ' || l_segcode_val);
        END IF;
        if l_segcode_val is null then
         EXIT;
        else
          if l_index = 1 then
            l_concat_code := l_segcode_val;
          else
            l_concat_code := l_concat_code||g_delimiter||l_segcode_val;
          end if;
       end if;
      END LOOP;
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.pos_product_service_utl_pkg.get_concat_code', 'Leaving get_concat_code return ' || l_concat_code);
      END IF;
      return l_concat_code;

   end;

/*End of P&S ER*/
PROCEDURE check_req_subcategory
  (p_segment_values    IN  category_segment_record,
   p_ps_request_id     IN  NUMBER,
   x_has_subcategory   OUT NOCOPY VARCHAR2)
  IS
     l_query VARCHAR2(3000);
     l_segment_value pos_sup_products_services.segment1%TYPE;
     l_last_not_null INTEGER;
     l_cur2 cursor_ref_type;
     l_count NUMBER;
BEGIN
   l_last_not_null := 0;

   FOR l_index IN REVERSE 1..g_product_segment_count LOOP
      l_segment_value := get_segment_value(l_index, p_segment_values);
      IF l_segment_value IS NOT NULL THEN
	 l_last_not_null := l_index;
	 EXIT;
      END IF;
   END LOOP;

   IF l_last_not_null = g_product_segment_count THEN
      -- the classification has values in all product segments
      -- so it would not have any children sub categories
      x_has_subcategory := 'N';
      RETURN;
   END IF;

   l_query := 'select mcb.category_id from mtl_categories_b mcb, ' ||
     ' mtl_category_set_valid_cats mcsvc, pos_product_service_requests ppsr where ' ||
     ' (mcb.supplier_enabled_flag is null or mcb.supplier_enabled_flag = ''Y'' or mcb.supplier_enabled_flag = ''y'') ' ||
     ' and mcsvc.category_set_id = ' || g_default_po_category_set_id ||
     ' and mcb.category_id = mcsvc.category_id ' ||
     ' and ppsr.ps_request_id = :1 and (';
   l_count := 0;
   FOR l_index IN 1..l_last_not_null LOOP
      IF l_index > 1 THEN
	 l_query := l_query || ' and ';
      END IF;
      l_count := l_count + 1;

      l_query := l_query || ' ppsr.' || g_product_segments(l_index).column_name ||
	' = mcb. ' || g_product_segments(l_index).column_name;
   END LOOP;
   /*Added as part of Bug 8611906 the query build was not proper without this*/
   IF (l_count >= 1) THEN

   l_query := l_query || ' and ppsr.' || g_product_segments(l_last_not_null + 1).column_name || ' is null ' ||
     ' and mcb.' || g_product_segments(l_last_not_null + 1).column_name || ' is not null) and rownum < 2';
   ELSE
   l_query := l_query || '  ppsr.' || g_product_segments(l_last_not_null + 1).column_name || ' is null ' ||
     ' and mcb.' || g_product_segments(l_last_not_null + 1).column_name || ' is not null) and rownum < 2';
   END IF;
   /*Added as part of Bug 8611906 the query build was not proper without this*/


   OPEN l_cur2 FOR l_query using p_ps_request_id;
   FETCH l_cur2 INTO l_count;
   IF l_cur2%notfound THEN
      x_has_subcategory := 'N';
    ELSE
      x_has_subcategory := 'Y';
   END IF;
   CLOSE l_cur2;
END check_req_subcategory;

PROCEDURE get_req_desc_has_sub
  (p_ps_request_id     IN  NUMBER,
   x_description       OUT NOCOPY VARCHAR2,
   x_has_subcategory   OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
	SELECT * FROM pos_product_service_requests
	  WHERE ps_request_id = p_ps_request_id;
     l_rec l_cur%ROWTYPE;
     l_segment_values category_segment_record;
     l_segment_value pos_product_service_requests.segment1%TYPE;
BEGIN
   assert_init();
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
   l_segment_values.segment1 := l_rec.segment1;
   l_segment_values.segment2 := l_rec.segment2;
   l_segment_values.segment3 := l_rec.segment3;
   l_segment_values.segment4 := l_rec.segment4;
   l_segment_values.segment5 := l_rec.segment5;
   l_segment_values.segment6 := l_rec.segment6;
   l_segment_values.segment7 := l_rec.segment7;
   l_segment_values.segment8 := l_rec.segment8;
   l_segment_values.segment9 := l_rec.segment9;
   l_segment_values.segment10 := l_rec.segment10;
   l_segment_values.segment11 := l_rec.segment11;
   l_segment_values.segment12 := l_rec.segment12;
   l_segment_values.segment13 := l_rec.segment13;
   l_segment_values.segment14 := l_rec.segment14;
   l_segment_values.segment15 := l_rec.segment15;
   l_segment_values.segment16 := l_rec.segment16;
   l_segment_values.segment17 := l_rec.segment17;
   l_segment_values.segment18 := l_rec.segment18;
   l_segment_values.segment19 := l_rec.segment19;
   l_segment_values.segment20 := l_rec.segment20;

   get_concatenated_description(l_segment_values, x_description);

   check_req_subcategory(l_segment_values, p_ps_request_id, x_has_subcategory);

END get_req_desc_has_sub;

PROCEDURE add_new_ps_req
  (p_vendor_id     IN  NUMBER,
   p_segment1	   IN  VARCHAR2,
   p_segment2	   IN  VARCHAR2,
   p_segment3	   IN  VARCHAR2,
   p_segment4	   IN  VARCHAR2,
   p_segment5	   IN  VARCHAR2,
   p_segment6	   IN  VARCHAR2,
   p_segment7	   IN  VARCHAR2,
   p_segment8	   IN  VARCHAR2,
   p_segment9	   IN  VARCHAR2,
   p_segment10	   IN  VARCHAR2,
   p_segment11	   IN  VARCHAR2,
   p_segment12	   IN  VARCHAR2,
   p_segment13	   IN  VARCHAR2,
   p_segment14	   IN  VARCHAR2,
   p_segment15	   IN  VARCHAR2,
   p_segment16	   IN  VARCHAR2,
   p_segment17	   IN  VARCHAR2,
   p_segment18	   IN  VARCHAR2,
   p_segment19	   IN  VARCHAR2,
   p_segment20	   IN  VARCHAR2,
   p_segment_definition	   IN  VARCHAR2,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
  l_mapping_id		NUMBER;
  l_party_id            NUMBER;
  l_count               NUMBER;

BEGIN

/*
 * If the count of pos_suppliers mapping record of the party id is zero, then
 * insert a record into the pos_supplier_mappings table for corresponding vendor id and party id
 * else, use the existing mapping_id value of the party id to create a Pending Product and
 * Service Request.
 * Please refer the bug 7374266 for more information.
*/

SELECT party_id
INTO   l_party_id
FROM   AP_SUPPLIERS
WHERE  vendor_id = p_vendor_id;

SELECT COUNT(mapping_id)
INTO l_count
FROM pos_supplier_mappings
WHERE party_id = l_party_id;

  IF ( l_count = 0 ) then
   INSERT INTO pos_supplier_mappings
   (
      mapping_id, party_id , vendor_id ,
      created_by, creation_date,
      last_updated_by, last_update_date, last_update_login
    )
    VALUES
    (
       pos_supplier_mapping_s.nextval, l_party_id, p_vendor_id,
       fnd_global.user_id, sysdate,
       fnd_global.user_id, sysdate, fnd_global.login_id
    );
  END IF;

select mapping_id
into l_mapping_id
from Pos_supplier_mappings
where vendor_id = p_vendor_id ;

INSERT INTO POS_PRODUCT_SERVICE_REQUESTS
     (
        PS_REQUEST_ID
      , MAPPING_ID
      , segment1
      , segment2
      , segment3
      , segment4
      , segment5
      , segment6
      , segment7
      , segment8
      , segment9
      , segment10
      , segment11
      , segment12
      , segment13
      , segment14
      , segment15
      , segment16
      , segment17
      , segment18
      , segment19
      , segment20
      , request_status
      , request_type
      , segment_definition
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
     )
     VALUES
     (
        POS_PRODUCT_SERVICE_REQ_S.NEXTVAL
      , l_mapping_id
      , p_segment1
      , p_segment2
      , p_segment3
      , p_segment4
      , p_segment5
      , p_segment6
      , p_segment7
      , p_segment8
      , p_segment9
      , p_segment10
      , p_segment11
      , p_segment12
      , p_segment13
      , p_segment14
      , p_segment15
      , p_segment16
      , p_segment17
      , p_segment18
      , p_segment19
      , p_segment20
      , 'PENDING'
      , 'ADD'
      , p_segment_definition
      , fnd_global.user_id
      , Sysdate
      , fnd_global.user_id
      , Sysdate
      , fnd_global.login_id
     );
x_return_status := fnd_api.g_ret_sts_success;

end add_new_ps_req;

PROCEDURE update_main_ps_req
(     p_req_id_tbl        IN  po_tbl_number,
      p_status            IN  VARCHAR2,
      x_return_status     OUT nocopy VARCHAR2,
      x_msg_count         OUT nocopy NUMBER,
      x_msg_data          OUT nocopy VARCHAR2
)
IS
BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP

   UPDATE POS_SUP_PRODUCTS_SERVICES
      SET status = p_status,
      last_updated_by = fnd_global.user_id,
      last_update_date = Sysdate,
      last_update_login = fnd_global.login_id
   WHERE classification_id = p_req_id_tbl(i);

   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

END update_main_ps_req;

PROCEDURE remove_mult_ps_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count       OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS
BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP
   UPDATE POS_PRODUCT_SERVICE_REQUESTS
            SET request_status = 'DELETED',
            last_updated_by = fnd_global.user_id,
            last_update_date = Sysdate,
            last_update_login = fnd_global.login_id
   WHERE PS_REQUEST_ID = p_req_id_tbl(i);
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
END remove_mult_ps_reqs;

PROCEDURE approve_mult_temp_ps_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count       OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS
BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP
   UPDATE POS_PRODUCT_SERVICE_REQUESTS
            SET request_status = 'PENDING',
            request_type = 'ADD',
            last_updated_by = fnd_global.user_id,
            last_update_date = Sysdate,
            last_update_login = fnd_global.login_id
   WHERE PS_REQUEST_ID = p_req_id_tbl(i);
   END LOOP;

   pos_profile_change_request_pkg.approve_mult_ps_reqs( p_req_id_tbl, x_return_status, x_msg_count, x_msg_data) ;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
END approve_mult_temp_ps_reqs;

/* Begin Supplier Hub: Supplier Profile Workbench */

/*
The table function 'product_service_ocv' is used for querying all possible
Products and Services classifications, to be used in the Supplier Profile UDA
codes.

Example usage:
SELECT code, meaning
FROM table(pos_product_service_utl_pkg.product_service_ocv)
*/

PROCEDURE insert_into_ocv_table
  (p_ocv_table           IN OUT NOCOPY product_service_ocv_table,
   p_parent_vals         IN OUT NOCOPY category_segment_record,             -- bug 16205262
   p_concat_parent_vals  IN VARCHAR2,
   p_concat_parent_desc  IN VARCHAR2,
   p_level               IN NUMBER
  )
  IS

  l_product_segment      product_segment_record;
  l_curr_segment_vals    product_service_ocv_table := product_service_ocv_table();
  l_tbl_sql              VARCHAR2(4000);
  l_valorid_col          VARCHAR2(240);
  l_tblcur               cursor_ref_type;
  l_curr_val             product_service_ocv_rec;
  l_parent_val           mtl_categories_b.segment1%TYPE;
  l_parent_column_name   fnd_id_flex_segments_vl.application_column_name%TYPE;

BEGIN

  l_product_segment := g_product_segments(p_level);

  -- Bug 19216656
  -- Modified the queries to:
  -- 1. only select PS categories that are viewable by supplier
  -- 2. and hence fixing an ORA-06502 error as well

  IF (l_product_segment.validation_type = 'I') THEN

    l_tbl_sql := 'SELECT DISTINCT ffv.flex_value, ffv.description ' ||
                 'FROM fnd_flex_values_vl ffv, ' ||
                 '     mtl_categories_b mcb, ' ||
                 '     mtl_category_set_valid_cats mcsvc ' ||
                 'WHERE flex_value_set_id = ' || l_product_segment.value_set_id ||
                 '  AND (mcb.supplier_enabled_flag IS NULL OR mcb.supplier_enabled_flag IN (''Y'', ''y'')) ' ||
                 '  AND mcb.category_id = mcsvc.category_id ' ||
                 '  AND mcsvc.category_set_id = ' || g_default_po_category_set_id ||
                 '  AND ffv.flex_value = mcb.' || l_product_segment.column_name;

    OPEN l_tblcur FOR l_tbl_sql;
    FETCH l_tblcur BULK COLLECT INTO l_curr_segment_vals;
    CLOSE l_tblcur;

  ELSIF (l_product_segment.validation_type = 'D') THEN

    l_parent_val := get_segment_value(l_product_segment.parent_segment_index, p_parent_vals);
    l_parent_column_name := g_product_segments(l_product_segment.parent_segment_index).column_name;

    l_tbl_sql := 'SELECT DISTINCT ffv.flex_value, ffv.description ' ||
                 'FROM fnd_flex_values_vl ffv, ' ||
                 '     mtl_categories_b mcb, ' ||
                 '     mtl_category_set_valid_cats mcsvc ' ||
                 'WHERE flex_value_set_id = ' || l_product_segment.value_set_id ||
                 '  AND (mcb.supplier_enabled_flag IS NULL OR mcb.supplier_enabled_flag IN (''Y'', ''y'')) ' ||
                 '  AND mcb.category_id = mcsvc.category_id ' ||
                 '  AND mcsvc.category_set_id = ' || g_default_po_category_set_id ||
                 '  AND ffv.flex_value = mcb.' || l_product_segment.column_name ||
                 '  AND ffv.parent_flex_value_low = ''' || l_parent_val || '''' ||
                 '  AND ffv.parent_flex_value_low = mcb.' || l_parent_column_name;

    OPEN l_tblcur FOR l_tbl_sql;
    FETCH l_tblcur BULK COLLECT INTO l_curr_segment_vals;
    CLOSE l_tblcur;

  ELSIF (l_product_segment.validation_type = 'F') THEN

    IF (l_product_segment.id_column IS NOT NULL) THEN
      l_valorid_col := l_product_segment.id_column;
    ELSE
      l_valorid_col := l_product_segment.value_column;
    END IF;

    l_tbl_sql := 'SELECT DISTINCT x.value, x.description ' ||
                 'FROM mtl_categories_b mcb, ' ||
                 '     mtl_category_set_valid_cats mcsvc ' ||
                 '     (SELECT ' || l_valorid_col || ' value, ' ||
                                    l_product_segment.meaning_column || ' description ' ||
                 '      FROM ' || l_product_segment.table_name ||
                 '           ' || l_product_segment.where_clause || ') x ' ||
                 'WHERE (mcb.supplier_enabled_flag IS NULL OR mcb.supplier_enabled_flag IN (''Y'', ''y'')) ' ||
                 '  AND mcb.category_id = mcsvc.category_id ' ||
                 '  AND mcsvc.category_set_id = ' || g_default_po_category_set_id ||
                 '  AND x.value = mcb.' || l_product_segment.column_name;

    OPEN l_tblcur FOR l_tbl_sql;
    FETCH l_tblcur BULK COLLECT INTO l_curr_segment_vals;
    CLOSE l_tblcur;

  END IF;

  -- Bug 10151022: Add a check on whether the segment contains any value
  -- Only proceed if the segment contains any value
  IF (l_curr_segment_vals.COUNT > 0) THEN

    FOR i IN l_curr_segment_vals.FIRST..l_curr_segment_vals.LAST LOOP
      l_curr_val := l_curr_segment_vals(i);

      IF (p_level > 1) THEN
        l_curr_val.code := p_concat_parent_vals || g_delimiter || l_curr_val.code;
        l_curr_val.meaning := p_concat_parent_desc || g_delimiter || l_curr_val.meaning;
      END IF;

      p_ocv_table.EXTEND;
      p_ocv_table(p_ocv_table.COUNT) := l_curr_val;

      IF (p_level < g_product_segment_count) THEN
        set_segment_value(p_level, l_curr_segment_vals(i).code, p_parent_vals);            --bug 16205262
        insert_into_ocv_table(p_ocv_table,
                              p_parent_vals,          --bug 16205262
                              l_curr_val.code,
                              l_curr_val.meaning,
                              p_level + 1);
      END IF;

    END LOOP;

  END IF;

END insert_into_ocv_table;

FUNCTION product_service_ocv
RETURN product_service_ocv_table PIPELINED
  IS
  l_status                 VARCHAR2(1);
  l_error_message          VARCHAR2(2000);
  l_product_service_ocv    product_service_ocv_table := product_service_ocv_table();
  l_concat_parent_vals     VARCHAR2(1000);
  l_concat_parent_desc     VARCHAR2(4000);
  l_parent_segment_values  category_segment_record;
BEGIN

  IF g_initialized = FALSE THEN
    do_init(l_status, l_error_message);
    IF l_status = g_no THEN
      RETURN;
    END IF;
  END IF;

  insert_into_ocv_table(l_product_service_ocv,
                        l_parent_segment_values,        --bug 16205262
                        l_concat_parent_vals,
                        l_concat_parent_desc,
                        1);

  FOR i IN 1..l_product_service_ocv.COUNT LOOP
    PIPE ROW(l_product_service_ocv(i));
  END LOOP;

  RETURN;

END product_service_ocv;

-- Added for bug 17007701
-- Returns the product service description for given "x_code" in the form of "DESCRIPTION1.DESCRIPTION2...DESCRIPTION<N>"
FUNCTION product_service_description(x_code in VARCHAR2)
RETURN VARCHAR2
	IS
	l_concat_code			VARCHAR2(1000) := 'PS:';
	l_concat_desc			VARCHAR2(4000) := '';
	l_product_segment		product_segment_record;
	l_curr_segment_vals		product_service_ocv_table;
	l_parent_vals			category_segment_record;
	l_tbl_sql				VARCHAR2(4000);
	l_valorid_col			VARCHAR2(240);
	l_tblcur				cursor_ref_type;
	l_curr_val				product_service_ocv_rec;

	CURSOR l_flex_i_cursor(p_value_set_id NUMBER) IS
		SELECT flex_value, description
		FROM fnd_flex_values_vl
		WHERE flex_value_set_id = p_value_set_id;

    CURSOR l_flex_d_cursor(p_value_set_id NUMBER, p_parent_val VARCHAR2) IS
		SELECT flex_value, description
		FROM fnd_flex_values_vl
		WHERE flex_value_set_id = p_value_set_id
		AND parent_flex_value_low = p_parent_val;
BEGIN

	assert_init();
	FOR lvl IN 1..g_product_segment_count LOOP

		l_product_segment := g_product_segments(lvl);
    l_curr_segment_vals := product_service_ocv_table();
		IF (l_product_segment.validation_type = 'I') THEN
			OPEN l_flex_i_cursor(l_product_segment.value_set_id);
			FETCH l_flex_i_cursor BULK COLLECT INTO l_curr_segment_vals;
			CLOSE l_flex_i_cursor;

		ELSIF (l_product_segment.validation_type = 'D') THEN
			OPEN l_flex_d_cursor(l_product_segment.value_set_id, get_segment_value(l_product_segment.parent_segment_index, l_parent_vals));
			FETCH l_flex_d_cursor BULK COLLECT INTO l_curr_segment_vals;
			CLOSE l_flex_d_cursor;

		ELSIF (l_product_segment.validation_type = 'F') THEN
			IF (l_product_segment.id_column IS NOT NULL) THEN
				l_valorid_col := l_product_segment.id_column;
			ELSE
				l_valorid_col := l_product_segment.value_column;
			END IF;

			l_tbl_sql := 'SELECT '||l_valorid_col||' value, '||
									l_product_segment.meaning_column||' description '||
						' FROM ' ||l_product_segment.table_name||
						' '      ||l_product_segment.where_clause;

			OPEN l_tblcur FOR l_tbl_sql;
			FETCH l_tblcur BULK COLLECT INTO l_curr_segment_vals;
			CLOSE l_tblcur;
		END IF;

		IF (l_curr_segment_vals.COUNT > 0) THEN
			FOR i IN l_curr_segment_vals.FIRST..l_curr_segment_vals.LAST LOOP
				l_curr_val := l_curr_segment_vals(i);
				IF(x_code LIKE l_concat_code || l_curr_val.code) THEN
					l_concat_code := l_concat_code || l_curr_val.code;
					l_concat_desc := l_concat_desc || l_curr_val.meaning;
					RETURN l_concat_desc;
				ELSIF(x_code LIKE l_concat_code || l_curr_val.code || g_delimiter || '%') THEN
					l_concat_code := l_concat_code || l_curr_val.code || g_delimiter ;
					l_concat_desc := l_concat_desc || l_curr_val.meaning || g_delimiter;
					set_segment_value(lvl, l_curr_val.code, l_parent_vals);
					EXIT;
				END IF;
			END LOOP;
		END IF;
	END LOOP;

	RETURN null;

END product_service_description;

-- Added for bug 9275861
-- Returns the columns of the flexfield for PS Category in the form of "SEGMENT1.SEGMENT2...SEGMENT<N>".
FUNCTION get_flexfield_columns
RETURN VARCHAR2
  IS
  l_concat_cols    VARCHAR2(4000) := NULL;
BEGIN

  assert_init();

  FOR i IN 1..g_structure_segment_count LOOP
    IF (g_structure_segments(i).displayed_flag = 'Y') THEN
      IF (l_concat_cols IS NULL) THEN
        l_concat_cols := g_structure_segments(i).column_name;
      ELSE
        l_concat_cols := l_concat_cols || '.' || g_structure_segments(i).column_name;
      END IF;
    END IF;
  END LOOP;

  RETURN l_concat_cols;

END get_flexfield_columns;

/* End Supplier Hub: Supplier Profile Workbench */

END pos_product_service_utl_pkg;

/
