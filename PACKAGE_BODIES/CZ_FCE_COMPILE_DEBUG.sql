--------------------------------------------------------
--  DDL for Package Body CZ_FCE_COMPILE_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_FCE_COMPILE_DEBUG" AS
/*	$Header: czfcedbb.pls 120.11 2008/04/09 20:23:43 asiaston ship $		*/
---------------------------------------------------------------------------------------
t_methoddescriptors            cz_fce_compile.type_varchar4000_table;
v_message_id                   PLS_INTEGER;
---------------------------------------------------------------------------------------
FUNCTION get_constant_value( ConstantPool IN BLOB, p_ptr IN PLS_INTEGER ) RETURN VARCHAR2 IS

   i_ptr  PLS_INTEGER := p_ptr + 1;
   i_len  PLS_INTEGER;
-------------------------------------------
   FUNCTION get_byte ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(ConstantPool, 1, p_ptr));

   END get_byte;
-------------------------------------------
   FUNCTION get_word ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(ConstantPool, 2, p_ptr));

   END get_word;
-------------------------------------------
   FUNCTION get_integer ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(ConstantPool, 4, p_ptr));

   END get_integer;
-------------------------------------------
BEGIN

   CASE DBMS_LOB.SUBSTR (ConstantPool, 1, i_ptr)

          WHEN cz_fce_compile.const_string_tag THEN

             i_len := get_word (i_ptr + 1);

             RETURN UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(ConstantPool, i_len, i_ptr + 3));

          WHEN cz_fce_compile.const_integer_tag THEN

             RETURN get_integer (i_ptr + 1);

          WHEN cz_fce_compile.const_float_tag THEN

             RETURN UTL_RAW.CAST_TO_BINARY_FLOAT(DBMS_LOB.SUBSTR(ConstantPool, 4, i_ptr + 1));

          WHEN cz_fce_compile.const_long_tag THEN

             RETURN get_integer (i_ptr + 1) || ':' || get_integer (i_ptr + 5);

          WHEN cz_fce_compile.const_double_tag THEN

             RETURN UTL_RAW.CAST_TO_BINARY_DOUBLE(DBMS_LOB.SUBSTR(ConstantPool, 8, i_ptr + 1));

          WHEN cz_fce_compile.const_method_tag THEN

             RETURN t_methoddescriptors ( get_byte (i_ptr + 1));

          WHEN cz_fce_compile.const_date_tag THEN

             RETURN get_integer (i_ptr + 1) || ':' || get_integer (i_ptr + 5);
   END CASE;
END get_constant_value;
---------------------------------------------------------------------------------------
PROCEDURE dump_code_memory( CodeMemory IN BLOB, ConstantPool IN BLOB, p_run_id IN NUMBER ) IS

   i_ptr          PLS_INTEGER := 1;

-------------------------------------------
   PROCEDURE debug ( p_message IN VARCHAR2) IS
   BEGIN

     cz_fce_compile_utils.report_info (
                 p_message => p_message
               , p_run_id => - p_run_id
               , p_model_id => null
               , p_ps_node_id => null
               , p_rule_id => null
               , p_error_stack => null
               , p_message_id => v_message_id
               );

     v_message_id := v_message_id + 1;

   END debug;
-------------------------------------------
   FUNCTION get_byte ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(CodeMemory, 1, p_ptr));

   END get_byte;
-------------------------------------------
   FUNCTION get_word ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(CodeMemory, 2, p_ptr));

   END get_word;
-------------------------------------------
BEGIN

   debug('------------------------');
   debug('Code Memory: ' || NVL ( DBMS_LOB.GETLENGTH (CodeMemory), 0) || ' bytes');
   debug('------------------------');

   WHILE (i_ptr <= DBMS_LOB.GETLENGTH (CodeMemory)) LOOP

      CASE DBMS_LOB.SUBSTR (CodeMemory, 1, i_ptr)

             WHEN cz_fce_compile.h_inst('nop') THEN

                debug('nop');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('iconst_m1') THEN

                debug('iconst_m1 -- push -1');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('iconst_0') THEN

                debug('iconst_0 -- push 0');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('iconst_1') THEN

                debug('iconst_1 -- push 1');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('iconst_2') THEN

                debug('iconst_2 -- push 2');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('iconst_3') THEN

                debug('iconst_3 -- push 3');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('iconst_4') THEN

                debug('iconst_4 -- push 4');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('iconst_5') THEN

                debug('iconst_5 -- push 5');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('bipush') THEN

                debug('bipush ' || get_byte(i_ptr + 1) || ' -- push byte value');
                i_ptr := i_ptr + 2;

             WHEN cz_fce_compile.h_inst('sipush') THEN

                debug('sipush ' || get_word(i_ptr + 1) || ' -- push word value');
                i_ptr := i_ptr + 3;

             WHEN cz_fce_compile.h_inst('ldc') THEN

                debug('ldc ' || get_byte(i_ptr + 1) || ' -- push value ''' || get_constant_value(ConstantPool, get_byte(i_ptr + 1)) || '''');
                i_ptr := i_ptr + 2;

             WHEN cz_fce_compile.h_inst('ldc_w') THEN

                debug('ldc_w ' || get_word(i_ptr + 1) || ' -- push value ''' || get_constant_value(ConstantPool, get_word(i_ptr + 1)) || '''');
                i_ptr := i_ptr + 3;

             WHEN cz_fce_compile.h_inst('aload') THEN

                debug('aload ' || get_byte(i_ptr + 1) || ' -- push from local variable #' || get_byte(i_ptr + 1));
                i_ptr := i_ptr + 2;

             WHEN cz_fce_compile.h_inst('aload_0') THEN

                debug('aload_0 -- push from local variable #0');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('aload_1') THEN

                debug('aload_1 -- push from local variable #1');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('aload_2') THEN

                debug('aload_2 -- push from local variable #2');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('aload_3') THEN

                debug('aload_3 -- push from local variable #3');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('aaload') THEN

                debug('aaload');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('astore') THEN

                debug('astore ' || get_byte(i_ptr + 1) || ' -- pop into local variable #' || get_byte(i_ptr + 1));
                i_ptr := i_ptr + 2;

             WHEN cz_fce_compile.h_inst('astore_0') THEN

                debug('astore_0 -- pop into local variable #0');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('astore_1') THEN

                debug('astore_1 -- pop into local variable #1');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('astore_2') THEN

                debug('astore_2 -- pop into local variable #2');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('astore_3') THEN

                debug('astore_3 -- pop into local variable #3');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('copyto') THEN

                debug('copyto ' || get_byte(i_ptr + 1) || ' -- copy into local variable #' || get_byte(i_ptr + 1));
                i_ptr := i_ptr + 2;

             WHEN cz_fce_compile.h_inst('copyto_0') THEN

                debug('copyto_0 -- copy into local variable #0');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('copyto_1') THEN

                debug('copyto_1 -- copy into local variable #1');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('copyto_2') THEN

                debug('copyto_2 -- copy into local variable #2');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('copyto_3') THEN

                debug('copyto_3 -- copy into local variable #3');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('aastore') THEN

                debug('aastore');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('pop') THEN

                debug('pop');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('mpop') THEN

                debug('mpop');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('dup') THEN

                debug('dup -- duplicate value at top of stack');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('swap') THEN

                debug('swap');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('ret') THEN

                debug('ret');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('areturn') THEN

                debug('areturn');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('invokevirtual') THEN

                debug('invokevirtual ' || get_word(i_ptr + 1) || ' -- call ' || get_constant_value(ConstantPool, get_word(i_ptr + 1)));
                i_ptr := i_ptr + 3;

             WHEN cz_fce_compile.h_inst('invokestatic') THEN

                debug('invokestatic ' || get_word(i_ptr + 1) || ' -- call ' || get_constant_value(ConstantPool, get_word(i_ptr + 1)));
                i_ptr := i_ptr + 3;

             WHEN cz_fce_compile.h_inst('newarray') THEN

                debug('newarray ' || get_byte(i_ptr + 1));
                i_ptr := i_ptr + 2;

             WHEN cz_fce_compile.h_inst('multinewarray') THEN

                debug('multinewarray ' || get_byte(i_ptr + 1) || get_byte(i_ptr + 2));
                i_ptr := i_ptr + 3;

             WHEN cz_fce_compile.h_inst('haload_0') THEN

                debug('haload_0 -- pop key, push value[key]');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('hastore_0') THEN

                debug('hastore_0 -- pop key, pop value, hash value by key');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('haload_1') THEN

                debug('haload_1 -- pop key, push value[key]');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('hastore_1') THEN

                debug('hastore_1 -- pop key, pop value, hash value by key');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('haload_2') THEN

                debug('haload_2 -- pop id2, pop id1, push from [DIO]');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('bulkaastore') THEN

                debug('bulkaastore');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('comment') THEN

                debug('// ' || get_constant_value ( ConstantPool, get_word ( i_ptr + 1 )));
                i_ptr := i_ptr + 3;

             WHEN cz_fce_compile.h_inst('pushtrue') THEN

                debug('pushtrue');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('pushfalse') THEN

                debug('pushfalse');
                i_ptr := i_ptr + 1;

             WHEN cz_fce_compile.h_inst('pushmath') THEN

                debug('pushmath ' || get_byte(i_ptr + 1));
                i_ptr := i_ptr + 2;

             WHEN cz_fce_compile.h_inst('aload_w') THEN

                debug('aload_w ' || get_word(i_ptr + 1) || ' -- push (wide) from variable #' || get_word(i_ptr + 1));
                i_ptr := i_ptr + 3;

             WHEN cz_fce_compile.h_inst('astore_w') THEN

                debug('astore_w ' || get_word(i_ptr + 1) || ' -- pop (wide) into variable #' || get_word(i_ptr + 1));
                i_ptr := i_ptr + 3;

             WHEN cz_fce_compile.h_inst('copyto_w') THEN

                debug('copyto_w ' || get_word(i_ptr + 1) || ' -- copy (wide) into variable #' || get_word(i_ptr + 1));
                i_ptr := i_ptr + 3;

      END CASE;
   END LOOP;
END dump_code_memory;
---------------------------------------------------------------------------------------
PROCEDURE dump_constant_pool( ConstantPool IN BLOB, p_run_id IN NUMBER ) IS

   i_ptr          PLS_INTEGER := 1;
   i_len          PLS_INTEGER;

-------------------------------------------
   PROCEDURE debug ( p_message IN VARCHAR2) IS
   BEGIN

     cz_fce_compile_utils.report_info (
                 p_message => p_message
               , p_run_id => - p_run_id
               , p_model_id => null
               , p_ps_node_id => null
               , p_rule_id => null
               , p_error_stack => null
               , p_message_id => v_message_id
               );

     v_message_id := v_message_id + 1;

   END debug;
-------------------------------------------
   FUNCTION get_byte ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(ConstantPool, 1, p_ptr));

   END get_byte;
-------------------------------------------
   FUNCTION get_word ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(ConstantPool, 2, p_ptr));

   END get_word;
-------------------------------------------
   FUNCTION get_integer ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(ConstantPool, 4, p_ptr));

   END get_integer;
-------------------------------------------
BEGIN

   debug('--------------------------');
   debug('Constant Pool: ' || NVL ( DBMS_LOB.GETLENGTH (ConstantPool), 0) || ' bytes');
   debug('--------------------------');

   WHILE (i_ptr <= DBMS_LOB.GETLENGTH (ConstantPool)) LOOP

      CASE DBMS_LOB.SUBSTR (ConstantPool, 1, i_ptr)

             WHEN cz_fce_compile.const_string_tag THEN

                i_len := get_word (i_ptr + 1);
                debug('string  ' || TO_CHAR(i_ptr - 1 , 'FM09999999') || ': ' ||
                     UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(ConstantPool, i_len, i_ptr + 3)));
                i_ptr := i_ptr + i_len + 3;

             WHEN cz_fce_compile.const_integer_tag THEN

                debug('integer ' || TO_CHAR(i_ptr - 1, 'FM09999999') || ': ' || get_integer (i_ptr + 1));
                i_ptr := i_ptr + 5;

             WHEN cz_fce_compile.const_float_tag THEN

                debug('float   ' || TO_CHAR(i_ptr - 1, 'FM09999999') || ': ' ||
                     UTL_RAW.CAST_TO_BINARY_FLOAT(DBMS_LOB.SUBSTR(ConstantPool, 4, i_ptr + 1)));
                i_ptr := i_ptr + 5;

             WHEN cz_fce_compile.const_long_tag THEN

                debug('long    ' || TO_CHAR(i_ptr - 1, 'FM09999999') || ': ' ||
                     get_integer (i_ptr + 1) || ':' || get_integer (i_ptr + 5));
                i_ptr := i_ptr + 9;

             WHEN cz_fce_compile.const_double_tag THEN

                debug('double  ' || TO_CHAR(i_ptr - 1, 'FM09999999') || ': ' ||
                     UTL_RAW.CAST_TO_BINARY_DOUBLE(DBMS_LOB.SUBSTR(ConstantPool, 8, i_ptr + 1)));
                i_ptr := i_ptr + 9;

             WHEN cz_fce_compile.const_method_tag THEN

                debug('method  ' || TO_CHAR(i_ptr - 1, 'FM09999999') || ': ' || t_methoddescriptors ( get_byte (i_ptr + 1)));
                i_ptr := i_ptr + 2;

             WHEN cz_fce_compile.const_date_tag THEN

                debug('date    ' || TO_CHAR(i_ptr - 1, 'FM09999999') || ': ' ||
                     get_integer (i_ptr + 1) || ':' || get_integer (i_ptr + 5));
                i_ptr := i_ptr + 9;

      END CASE;
   END LOOP;
END dump_constant_pool;
---------------------------------------------------------------------------------------
PROCEDURE dump_logic ( p_fce_file IN BLOB, p_run_id IN NUMBER ) IS

   l_constant_pool   BLOB;
   l_code_memory     BLOB;

   l_size            PLS_INTEGER;
   l_tail            PLS_INTEGER;

   FUNCTION get_integer ( p_ptr IN PLS_INTEGER ) RETURN BINARY_INTEGER IS
   BEGIN

     RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR( p_fce_file, 4, p_ptr));

   END get_integer;

BEGIN

  l_size := get_integer ( DBMS_LOB.GETLENGTH ( p_fce_file ) - 7 );
  l_tail := DBMS_LOB.GETLENGTH ( p_fce_file ) - 8 - l_size;

  IF ( l_size > 0 ) THEN l_constant_pool := DBMS_LOB.SUBSTR ( p_fce_file, l_size, 1 ); END IF;
  IF ( l_tail > 0 ) THEN l_code_memory := DBMS_LOB.SUBSTR ( p_fce_file, l_tail, l_size + 1); END IF;

  dump_constant_pool( l_constant_pool, p_run_id );
  dump_code_memory( l_code_memory, l_constant_pool, p_run_id);

END dump_logic;
---------------------------------------------------------------------------------------
PROCEDURE dump_logic ( p_model_id IN NUMBER, p_run_id IN NUMBER ) IS

   PROCEDURE debug ( p_message IN VARCHAR2) IS
   BEGIN

     cz_fce_compile_utils.report_info (
                 p_message => p_message
               , p_run_id => - p_run_id
               , p_model_id => null
               , p_ps_node_id => null
               , p_rule_id => null
               , p_error_stack => null
               , p_message_id => v_message_id
               );

     v_message_id := v_message_id + 1;

   END debug;

BEGIN

  v_message_id := 1;

  FOR file IN (SELECT component_id, fce_file_type, segment_nbr, fce_file FROM cz_fce_files
                WHERE deleted_flag = '0'
                  AND component_id IN
                    (SELECT component_id FROM cz_model_ref_expls WHERE deleted_flag = '0'
                        AND model_id = p_model_id)
                ORDER BY component_id, fce_file_type, segment_nbr ) LOOP

       debug ( '>');
       debug ('Component: ' || file.component_id || ', Phase: ' || file.fce_file_type || ', Segment: ' || file.segment_nbr );
       dump_logic ( file.fce_file, p_run_id );

  END LOOP;
END dump_logic;
---------------------------------------------------------------------------------------
--Populate the method descriptor table from the seed data table.

PROCEDURE populate_display_data IS

  l_key  VARCHAR2(4000);

BEGIN

  l_key := cz_fce_compile.h_methoddescriptors.FIRST;

  WHILE ( l_key IS NOT NULL ) LOOP

    t_methoddescriptors ( cz_fce_compile.h_methoddescriptors ( l_key )) := l_key;
    l_key := cz_fce_compile.h_methoddescriptors.NEXT ( l_key );

  END LOOP;
END populate_display_data;
---------------------------------------------------------------------------------------
BEGIN

  populate_display_data;

END;

/
