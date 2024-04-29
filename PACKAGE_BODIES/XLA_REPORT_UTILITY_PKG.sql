--------------------------------------------------------
--  DDL for Package Body XLA_REPORT_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_REPORT_UTILITY_PKG" AS
-- $Header: xlarputl.pkb 120.11.12010000.11 2010/03/03 13:41:32 rajose ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarputl.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_report_utility_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     Package body. This provides routines that support reports              |
|                                                                            |
| HISTORY                                                                    |
|     04/15/2005  V. Kumar        Created                                    |
|     04/27/2005  V. Kumar        Bug:4309818 increased the size of t_rec.f2 |
|     06/03/2005  V. Kumar        Updated get_transaction_id to include NULL |
|                                 columns for undefined user trx identifier  |
|     12/23/2005  V. Kumar        Added function get_transaction_id          |
|     06/23/2006  V. Kumar        Added function get_conc_segments           |
|     02/16/2009  N. K. Surana    Overloading function get_transaction_id    |
|                                 to handle more than 50 event classes per   |
|                                 application id required for FSAH Customers.|
|     3-Mar-2010  rajose          9323360 to implement caching for CCID desc |
|                                 function by using PLSQL nested table       |
|                                 hashing                                    |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================

TYPE t_rec IS RECORD
    (f1               VARCHAR2(80)
    ,f2               VARCHAR2(80));
TYPE t_array IS TABLE OF t_rec INDEX BY BINARY_INTEGER;

--=============================================================================
--        **************  forward  declaraions  ******************
--=============================================================================
-- none

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_report_utility_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;
C_NEW_LINE            CONSTANT VARCHAR2(8)  := fnd_global.newline;
C_OWNER_ORACLE        CONSTANT VARCHAR2(1)  := 'S';

--bug#9323360
TYPE t_ccid_desc IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE t_coaid IS TABLE OF t_ccid_desc INDEX BY BINARY_INTEGER;

g_t_cache_ccid_desc t_ccid_desc;
g_t_cache_coa_id    t_coaid;
--bug#9323360

-------------------------------------------------------------------------------
-- constant for getting flexfield segment value description
-------------------------------------------------------------------------------
C_SEG_DESC_JOIN      CONSTANT    VARCHAR2(32000) :=
      '  AND $alias$.flex_value_set_id = $flex_value_set_id$ '
   || C_NEW_LINE
   || '  AND $alias$.flex_value        = $segment_column$ '
   || C_NEW_LINE
   || '  AND $alias$.parent_flex_value_low '          -- added for bug:7641746 for Dependant/Table Validated Value Set
   ;


   C_HINT   CONSTANT    VARCHAR2(240) :=
   ' /*+ leading(gcck $fnd_flex_hint$, gl1, glb) use_nl(glb) */ ';

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, NVL(p_module,C_DEFAULT_MODULE));
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, NVL(p_module,C_DEFAULT_MODULE), p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_report_utility_pkg.trace');
END trace;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following are public routines
--
--    1.  get_transaction_id
--    2.  get_acct_qualifier_segs
--    3.  get_ccid_desc
--    4.  clob_to_file
--    5.  get_anc_filter
--    6.  get_conc_segments
--
--
--
--
--
--
--
--
--
--
--=============================================================================


--=============================================================================
--
--
--
--=============================================================================
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_segment_info                                                      |
|                                                                       |
| Returns segment information                                           |
|                                                                       |
+======================================================================*/
PROCEDURE get_segment_info
   (p_coa_id                     IN  NUMBER
  ,p_balancing_segment          IN VARCHAR2
  ,p_account_segment	        IN  VARCHAR2
  ,p_costcenter_segment         IN VARCHAR2
  ,p_management_segment         IN VARCHAR2
  ,p_intercompany_segment       IN VARCHAR2
  ,p_alias_balancing_segment    IN VARCHAR2
  ,p_alias_account_segment      IN  VARCHAR2
  ,p_alias_costcenter_segment   IN VARCHAR2
  ,p_alias_management_segment   IN VARCHAR2
  ,p_alias_intercompany_segment IN VARCHAR2
  ,p_seg_desc_column 		OUT NOCOPY VARCHAR2
  ,p_seg_desc_from  	        OUT NOCOPY VARCHAR2
  ,p_seg_desc_join  		OUT NOCOPY VARCHAR2
  ,p_hint           		OUT NOCOPY VARCHAR2)

IS

   l_log_module                     VARCHAR2(240);

   l_seg_desc_column                VARCHAR2(32000) := ' ';    -- initialized to space bug 8816030
   l_seg_desc_from                  VARCHAR2(32000) := ' ';    -- initialized to space bug 8816030
   l_seg_desc_join                  VARCHAR2(32000) := ' ';    -- initialized to space bug 8816030

   l_fnd_flex_hint                 VARCHAR2(240) := '';
   l_hint                          VARCHAR2(240);

   /* following added for bug:7641746 for Dependant/Table Validated Value Set */

   l_flex_value_set_id		    NUMBER(10) ;
   l_validation_type		    CHAR(1) ;
   l_parent_segment                VARCHAR2(80);
   l_display_flag                  fnd_id_flex_segments.display_flag%TYPE;

   /**********************************************************************/
   /*   Following values for VALIDATION TYPE of a Value Set              */
   /*      i) F : TABLE VALIDATED VALUE SET                              */
   /*     ii) I : INDEPENDENT VALUE SET                                  */
   /*    iii) D : DEPENDENT VALUE SET                                    */
   /**********************************************************************/
    -- Query to get the Validation Type for  Value Set : bug:7641746
   CURSOR c_validation_type(p_flex_value_set_id IN NUMBER) IS
   select  validation_type
   from fnd_flex_value_sets
   where flex_value_set_id = p_flex_value_set_id ;

   -- Query to get the parent SEGMENT for Dependent Value Set : bug:7641746
   CURSOR c_parent_segment_name(p_flex_value_set_id IN NUMBER) IS
   SELECT application_column_name
   FROM fnd_id_flex_segments
   WHERE id_flex_code = 'GL#'
   AND   id_flex_num = p_coa_id
   AND   application_id = 101
   AND   flex_value_set_id =
	                      (	SELECT parent_flex_value_set_id
				FROM fnd_flex_value_sets
				WHERE flex_value_set_id = p_flex_value_set_id
			      );

   /* end of changes for bug:7641746 */

   CURSOR C_SEG_DISP_REQ_CHECK(
                      p_application_id INTEGER,
                      p_id_flex_code VARCHAR2,
                      p_id_flex_num  INTEGER,
                      p_segment_code VARCHAR2
                      )
IS
SELECT display_flag
FROM   fnd_id_flex_segments fid
WHERE  application_id        = p_application_id
AND  id_flex_code            = p_id_flex_code
AND  id_flex_num             = p_id_flex_num
AND  application_column_name = p_segment_code;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_segment_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_segment_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;



   ----------------------------------------------------------------------------
   -- building code to get segment description
   ----------------------------------------------------------------------------
   /* start of new code for the bug:7641746 */

   IF p_balancing_segment <> 'NULL' THEN

	l_flex_value_set_id := xla_flex_pkg.get_segment_valueset
				       (p_application_id              => 101
				       ,p_id_flex_code                => 'GL#'
				       ,p_id_flex_num                 => p_coa_id
				       ,p_segment_code                => p_balancing_segment
				       );

	 FOR i  IN c_validation_type(l_flex_value_set_id)
	 LOOP
		   l_validation_type := i.validation_type ;
	 END LOOP;


	 IF l_validation_type = 'F' THEN -- For Table Validated Set

	      l_seg_desc_column := l_seg_desc_column
				|| ',NULL         BALANCING_SEGMENT_DESC '
				|| C_NEW_LINE;

	 ELSIF l_validation_type IN ('I','D') THEN -- For Independent, Dependent Value Set

	      l_seg_desc_column := l_seg_desc_column
				|| ',fvbs.description          BALANCING_SEGMENT_DESC '
				|| C_NEW_LINE;

	      l_seg_desc_from := l_seg_desc_from
			      ||',fnd_flex_values_vl       fvbs '
			      || C_NEW_LINE;

	    	         --bug#7834671
      OPEN C_SEG_DISP_REQ_CHECK(101,'GL#',p_coa_id,p_balancing_segment);
      FETCH C_SEG_DISP_REQ_CHECK INTO l_display_flag;
      CLOSE C_SEG_DISP_REQ_CHECK;

      IF l_display_flag = 'N'  THEN
         l_seg_desc_join := l_seg_desc_join   || '  AND $alias$.flex_value_set_id(+) = $flex_value_set_id$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.flex_value(+)        = $segment_column$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.parent_flex_value_low(+) ';

      ELSE
         l_seg_desc_join   := l_seg_desc_join||C_SEG_DESC_JOIN;
      END IF;
    --bug#7834671


	      IF l_validation_type = 'I' THEN

			l_seg_desc_join := l_seg_desc_join||' IS NULL '|| C_NEW_LINE; -- For Independent Set, Paret_Flex_Value_Low IS NULL

	      ELSE
			l_seg_desc_join := l_seg_desc_join||' = gcck.$parent_segment_column$ '|| C_NEW_LINE;

			-- Get the PARENT SEGMENT on which DEPENDENT VALUE is based upon
			FOR i IN c_parent_segment_name( l_flex_value_set_id )
			LOOP
				l_parent_segment := i.application_column_name ;
			END LOOP;

			l_seg_desc_join := REPLACE(l_seg_desc_join
						     ,'$parent_segment_column$'
						     ,l_parent_segment);



	      END IF;

	      l_seg_desc_join := REPLACE(l_seg_desc_join,'$alias$','fvbs');

	      l_seg_desc_join :=
		 REPLACE
		    (l_seg_desc_join
		    ,'$flex_value_set_id$'
		    , l_flex_value_set_id
		    );
	      l_seg_desc_join := replace(l_seg_desc_join,'$segment_column$',p_alias_balancing_segment);
	      l_fnd_flex_hint := l_fnd_flex_hint ||',fvbs' ;

	ELSE

		l_seg_desc_column := l_seg_desc_column
				|| ',NULL         BALANCING_SEGMENT_DESC '
				|| C_NEW_LINE;

	END IF ;
	ELSE
	l_seg_desc_column := l_seg_desc_column
				|| ',NULL         BALANCING_SEGMENT_DESC '
				|| C_NEW_LINE;



   END IF;

   IF p_account_segment <> 'NULL' THEN

     l_flex_value_set_id := xla_flex_pkg.get_segment_valueset
				       (p_application_id              => 101
				       ,p_id_flex_code                => 'GL#'
				       ,p_id_flex_num                 => p_coa_id
				       ,p_segment_code                => p_account_segment
				       );

      FOR i  IN c_validation_type(l_flex_value_set_id)
      LOOP
           l_validation_type := i.validation_type ;
      END LOOP;

      IF l_validation_type = 'F' THEN -- For Table Validated Set

	      l_seg_desc_column := l_seg_desc_column
				|| ',NULL         NATURAL_ACCOUNT_DESC '
				|| C_NEW_LINE;

      ELSIF l_validation_type IN ('I','D') THEN -- For Independent, Dependent Value Set


	      l_seg_desc_column := l_seg_desc_column
				||',fvna.description          NATURAL_ACCOUNT_DESC '
				|| C_NEW_LINE;

	      l_seg_desc_from := l_seg_desc_from
			      ||',fnd_flex_values_vl       fvna '
			      || C_NEW_LINE;

	    	         --bug#7834671
      OPEN C_SEG_DISP_REQ_CHECK(101,'GL#',p_coa_id,p_balancing_segment);
      FETCH C_SEG_DISP_REQ_CHECK INTO l_display_flag;
      CLOSE C_SEG_DISP_REQ_CHECK;

      IF l_display_flag = 'N'  THEN
         l_seg_desc_join := l_seg_desc_join   || '  AND $alias$.flex_value_set_id(+) = $flex_value_set_id$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.flex_value(+)        = $segment_column$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.parent_flex_value_low(+) ';

      ELSE
         l_seg_desc_join   := l_seg_desc_join||C_SEG_DESC_JOIN;
      END IF;
    --bug#7834671

		IF l_validation_type = 'I' THEN

			l_seg_desc_join:=l_seg_desc_join||' is null ' || C_NEW_LINE ;  -- For Independent Set, Paret_Flex_Value_Low IS NULL
		ELSE
			l_seg_desc_join:=l_seg_desc_join||' = gcck.$parent_segment_column$ '|| C_NEW_LINE;

			-- Get the PARENT SEGMENT on which DEPENDENT VALUE is based upon
			FOR i IN c_parent_segment_name( l_flex_value_set_id )
			LOOP
				l_parent_segment := i.application_column_name ;

			END LOOP;

			 l_seg_desc_join := REPLACE(l_seg_desc_join
						     ,'$parent_segment_column$'
						     ,l_parent_segment);

		END IF;

	      l_seg_desc_join := REPLACE(l_seg_desc_join,'$alias$','fvna');

	      l_seg_desc_join :=
		 REPLACE
		    (l_seg_desc_join
		    ,'$flex_value_set_id$'
		    , l_flex_value_set_id
		    );
	      l_seg_desc_join := REPLACE(l_seg_desc_join,'$segment_column$',p_alias_account_segment);
	       l_fnd_flex_hint := l_fnd_flex_hint ||',fvna' ;


      ELSE

            l_seg_desc_column := l_seg_desc_column
				|| ',NULL         NATURAL_ACCOUNT_DESC '
				|| C_NEW_LINE;

      END IF;
      ELSE
        l_seg_desc_column := l_seg_desc_column
				|| ',NULL          NATURAL_ACCOUNT_DESC '
				|| C_NEW_LINE;

   END IF;

   IF p_costcenter_segment <> 'NULL' THEN

      l_flex_value_set_id := xla_flex_pkg.get_segment_valueset
				       (p_application_id              => 101
				       ,p_id_flex_code                => 'GL#'
				       ,p_id_flex_num                 => p_coa_id
				       ,p_segment_code                => p_costcenter_segment
				       );

      FOR i  IN c_validation_type(l_flex_value_set_id)
      LOOP
           l_validation_type := i.validation_type ;
      END LOOP;

     IF l_validation_type = 'F' THEN -- For Table Validated Set

	      l_seg_desc_column := l_seg_desc_column
				|| ',NULL         COST_CENTER_DESC '
				|| C_NEW_LINE;

     ELSIF l_validation_type IN ('I','D') THEN -- For Independent, Dependent Value Set

	      l_seg_desc_column := l_seg_desc_column
				||',fvcc.description          COST_CENTER_DESC '
				|| C_NEW_LINE;

	      l_seg_desc_from := l_seg_desc_from
			      ||',fnd_flex_values_vl       fvcc '
			      || C_NEW_LINE;

	         --bug#7834671
      OPEN C_SEG_DISP_REQ_CHECK(101,'GL#',p_coa_id,p_balancing_segment);
      FETCH C_SEG_DISP_REQ_CHECK INTO l_display_flag;
      CLOSE C_SEG_DISP_REQ_CHECK;

      IF l_display_flag = 'N'  THEN
         l_seg_desc_join := l_seg_desc_join   || '  AND $alias$.flex_value_set_id(+) = $flex_value_set_id$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.flex_value(+)        = $segment_column$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.parent_flex_value_low(+) ';

      ELSE
         l_seg_desc_join   := l_seg_desc_join||C_SEG_DESC_JOIN;
      END IF;
    --bug#7834671


	      IF l_validation_type = 'I' THEN

			l_seg_desc_join:=l_seg_desc_join||' is null '|| C_NEW_LINE;  -- For Independent Set, Paret_Flex_Value_Low IS NULL
	      ELSE
			l_seg_desc_join:=l_seg_desc_join||' = gcck.$parent_segment_column$ '|| C_NEW_LINE;

			-- Get the PARENT SEGMENT on which DEPENDENT VALUE is based upon
			FOR i IN c_parent_segment_name( l_flex_value_set_id )
			LOOP
				l_parent_segment := i.application_column_name ;

			END LOOP;

			 l_seg_desc_join := REPLACE(l_seg_desc_join
						     ,'$parent_segment_column$'
						     ,l_parent_segment);

	     END IF;

	      l_seg_desc_join := REPLACE(l_seg_desc_join,'$alias$','fvcc');

	      l_seg_desc_join :=
		 REPLACE
		    (l_seg_desc_join
		    ,'$flex_value_set_id$'
		    , l_flex_value_set_id
		    );
	      l_seg_desc_join := REPLACE(l_seg_desc_join,'$segment_column$',p_alias_costcenter_segment);
	          l_fnd_flex_hint := l_fnd_flex_hint ||',fvcc' ;

      ELSE

	    l_seg_desc_column := l_seg_desc_column
				|| ',NULL         COST_CENTER_DESC '
				|| C_NEW_LINE;

      END IF;
      ELSE
        l_seg_desc_column := l_seg_desc_column
				|| ',NULL         COST_CENTER_DESC'
				|| C_NEW_LINE;

   END IF;

   IF p_management_segment <> 'NULL' THEN

      l_flex_value_set_id := xla_flex_pkg.get_segment_valueset
				       (p_application_id              => 101
				       ,p_id_flex_code                => 'GL#'
				       ,p_id_flex_num                 => p_coa_id
				       ,p_segment_code                => p_management_segment
				       );

      FOR i  IN c_validation_type(l_flex_value_set_id)
      LOOP
           l_validation_type := i.validation_type ;
      END LOOP;

      IF l_validation_type = 'F' THEN -- For Table Validated Set

	      l_seg_desc_column := l_seg_desc_column
				|| ',NULL         MANAGEMENT_SEGMENT_DESC '
				|| C_NEW_LINE;

      ELSIF l_validation_type IN ('I','D') THEN -- For Independent, Dependent Value Set

	      l_seg_desc_column := l_seg_desc_column
				||',fvmg.description          MANAGEMENT_SEGMENT_DESC '
				|| C_NEW_LINE;

	      l_seg_desc_from := l_seg_desc_from
			      ||',fnd_flex_values_vl       fvmg '
			      || C_NEW_LINE;

	         --bug#7834671
      OPEN C_SEG_DISP_REQ_CHECK(101,'GL#',p_coa_id,p_balancing_segment);
      FETCH C_SEG_DISP_REQ_CHECK INTO l_display_flag;
      CLOSE C_SEG_DISP_REQ_CHECK;

      IF l_display_flag = 'N'  THEN
         l_seg_desc_join := l_seg_desc_join   || '  AND $alias$.flex_value_set_id(+) = $flex_value_set_id$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.flex_value(+)        = $segment_column$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.parent_flex_value_low(+) ';

      ELSE
         l_seg_desc_join   := l_seg_desc_join||C_SEG_DESC_JOIN;
      END IF;
    --bug#7834671


	      IF l_validation_type = 'I' THEN

			l_seg_desc_join:=l_seg_desc_join||' is null '|| C_NEW_LINE;  -- For Independent Set, Paret_Flex_Value_Low IS NULL

	      ELSE
			l_seg_desc_join:=l_seg_desc_join||' = gcck.$parent_segment_column$ '|| C_NEW_LINE;

			-- Get the PARENT SEGMENT on which DEPENDENT VALUE is based upon
			FOR i IN c_parent_segment_name( l_flex_value_set_id )
			LOOP
				l_parent_segment := i.application_column_name ;

			END LOOP;

			 l_seg_desc_join := REPLACE(l_seg_desc_join
						     ,'$parent_segment_column$'
						     ,l_parent_segment);

	     END IF;

	      l_seg_desc_join := REPLACE(l_seg_desc_join,'$alias$','fvmg');

	      l_seg_desc_join :=
		 REPLACE
		    (l_seg_desc_join
		    ,'$flex_value_set_id$'
		    ,l_flex_value_set_id
		    );
	      l_seg_desc_join := REPLACE(l_seg_desc_join,'$segment_column$',p_alias_management_segment);
	       l_fnd_flex_hint := l_fnd_flex_hint ||',fvmg' ;

      ELSE
		l_seg_desc_column := l_seg_desc_column
                        || ',NULL         MANAGEMENT_SEGMENT_DESC '
                        || C_NEW_LINE;

      END IF;
     ELSE
     		l_seg_desc_column := l_seg_desc_column
                        || ',NULL         MANAGEMENT_SEGMENT_DESC '
                        || C_NEW_LINE;

   END IF;

   IF p_intercompany_segment <> 'NULL' THEN

      l_flex_value_set_id := xla_flex_pkg.get_segment_valueset
				       (p_application_id              => 101
				       ,p_id_flex_code                => 'GL#'
				       ,p_id_flex_num                 => p_coa_id
				       ,p_segment_code                => p_intercompany_segment
				       );


      FOR i  IN c_validation_type(l_flex_value_set_id)
      LOOP
           l_validation_type := i.validation_type ;
      END LOOP;


      IF l_validation_type = 'F' THEN


	      l_seg_desc_column := l_seg_desc_column
				|| ',NULL         INTERCOMPANY_SEGMENT_DESC '
				|| C_NEW_LINE;

      ELSIF l_validation_type IN ('I','D') THEN -- For Independent, Dependent Value Set


	      l_seg_desc_column := l_seg_desc_column
			      ||',fvic.description          INTERCOMPANY_SEGMENT_DESC ';

	      l_seg_desc_from := l_seg_desc_from
			      ||',fnd_flex_values_vl       fvic ';

	      	         --bug#7834671
      OPEN C_SEG_DISP_REQ_CHECK(101,'GL#',p_coa_id,p_balancing_segment);
      FETCH C_SEG_DISP_REQ_CHECK INTO l_display_flag;
      CLOSE C_SEG_DISP_REQ_CHECK;

      IF l_display_flag = 'N'  THEN

         l_seg_desc_join := l_seg_desc_join   || '  AND $alias$.flex_value_set_id(+) = $flex_value_set_id$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.flex_value(+)        = $segment_column$ '
                                              || C_NEW_LINE
                                              || '  AND $alias$.parent_flex_value_low(+) ';

      ELSE

         l_seg_desc_join   := l_seg_desc_join||C_SEG_DESC_JOIN;
      END IF;
    --bug#7834671


	      IF l_validation_type = 'I' THEN


			l_seg_desc_join:=l_seg_desc_join||' is null '|| C_NEW_LINE;  -- For Independent Set, Paret_Flex_Value_Low IS NULL

	      ELSE
			l_seg_desc_join:=l_seg_desc_join||' = gcck.$parent_segment_column$ '|| C_NEW_LINE;

			-- Get the PARENT SEGMENT on which DEPENDENT VALUE is based upon
			FOR i IN c_parent_segment_name( l_flex_value_set_id )
			LOOP
				l_parent_segment := i.application_column_name ;

			END LOOP;

			 l_seg_desc_join := REPLACE(l_seg_desc_join
						     ,'$parent_segment_column$'
						     ,l_parent_segment);

	     END IF;

	      l_seg_desc_join := REPLACE(l_seg_desc_join,'$alias$','fvic');

	      l_seg_desc_join :=
		 REPLACE
		    (l_seg_desc_join
		    ,'$flex_value_set_id$'
		    ,l_flex_value_set_id
		    );
	      l_seg_desc_join := replace(l_seg_desc_join,'$segment_column$',p_alias_intercompany_segment);
	       l_fnd_flex_hint := l_fnd_flex_hint ||',fvic' ;

      ELSE

		l_seg_desc_column := l_seg_desc_column
                        || ',NULL         INTERCOMPANY_SEGMENT_DESC '
                        || C_NEW_LINE;

      END IF;

      ELSE


	l_seg_desc_column := l_seg_desc_column
                        || ',NULL         INTERCOMPANY_SEGMENT_DESC '
                        || C_NEW_LINE;
   END IF;

   /* end of new code for the bug:7641746 */

   p_seg_desc_column   := l_seg_desc_column;
   p_seg_desc_from     := l_seg_desc_from;
   p_seg_desc_join     := l_seg_desc_join;
   p_hint := l_fnd_flex_hint;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_segment_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tb_report_pvt.get_segment_info');
END get_segment_info;
--=============================================================================


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE get_transaction_id
       (p_application_id         IN INTEGER
       ,p_entity_code            IN VARCHAR2
       ,p_event_class_code       IN VARCHAR2
       ,p_reporting_view_name    IN VARCHAR2
       ,p_select_str             OUT NOCOPY VARCHAR2
       ,p_from_str               OUT NOCOPY VARCHAR2
       ,p_where_str              OUT NOCOPY VARCHAR2) IS
CURSOR cols_csr IS
   (SELECT xid.transaction_id_col_name_1   trx_col_1
          ,xid.transaction_id_col_name_2   trx_col_2
          ,xid.transaction_id_col_name_3   trx_col_3
          ,xid.transaction_id_col_name_4   trx_col_4
          ,xid.source_id_col_name_1        src_col_1
          ,xid.source_id_col_name_2        src_col_2
          ,xid.source_id_col_name_3        src_col_3
          ,xid.source_id_col_name_4        src_col_4
          ,xem.column_name                 column_name
          ,xem.column_title                PROMPT
          ,utc.data_type                   data_type
      FROM xla_entity_id_mappings   xid
          ,xla_event_mappings_vl    xem
          ,user_tab_columns         utc
     WHERE xid.application_id       = p_application_id
       AND xid.entity_code          = p_entity_code
       AND xem.application_id       = p_application_id
       AND xem.entity_code          = p_entity_code
       AND xem.event_class_code     = p_event_class_code
       AND utc.table_name           = p_reporting_view_name
       AND utc.column_name          = xem.column_name)
     ORDER BY xem.user_sequence;

l_col_array                t_array;
l_null_col_array           t_array;
l_col_string               VARCHAR2(4000)   := NULL;
l_view_name                VARCHAR2(800);
l_join_string              VARCHAR2(4000)   := NULL;
l_sql_string               VARCHAR2(4000) := NULL;
l_index                    INTEGER;
l_outerjoin                VARCHAR2(30);
l_log_module               VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_transaction_id';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GET_TRANSACTION_ID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_entity_code = '||p_entity_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_reporting_view_name = '||p_reporting_view_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
    ----------------------------------------------------------------------------
   -- creating a dummy array that contains "NULL" strings
   ----------------------------------------------------------------------------
   FOR i IN 1..10 LOOP
      l_null_col_array(i).f1 := 'NULL';
      l_null_col_array(i).f2 := 'NULL';

   END LOOP;
   ----------------------------------------------------------------------------
   -- initiating the array that contains name of the columns to be selected
   -- from the TID View.
   ----------------------------------------------------------------------------
   l_col_array := l_null_col_array;

   ----------------------------------------------------------------------------
   -- creating SELECT,FROM and WHERE clause strings when the reporting view is
   -- defined for an Event Class.
   ----------------------------------------------------------------------------
   IF p_reporting_view_name IS NOT NULL THEN
      -------------------------------------------------------------------------
      -- creating string to be added to FROM clause
      -------------------------------------------------------------------------
      l_view_name   := ',' || p_reporting_view_name || '    TIV';
      l_index := 0;
      FOR c1 IN cols_csr LOOP
         l_index := l_index + 1;

         ----------------------------------------------------------------------
         -- creating string to be added to WHERE clause
         ----------------------------------------------------------------------
         IF l_index = 1 THEN
            -------------------------------------------------------------------
            -- Bug 3389175
            -- Following logic is build to make sure all events are reported
            -- if debug is enabled evenif there is no data for the event in the
            -- transaction id view.
            -- if log enabled  then
            --        outer join to TID view
            -- endif
            -------------------------------------------------------------------
            IF g_log_level <> C_LEVEL_LOG_DISABLED THEN
               l_outerjoin := '(+)';
            ELSE
               l_outerjoin := NULL;
            END IF;

            IF c1.trx_col_1 IS NOT NULL THEN
               l_join_string := l_join_string ||
                                ' AND TIV.'|| c1.trx_col_1 ||l_outerjoin ||
                                ' = ENT.'|| c1.src_col_1;
            END IF;
            IF c1.trx_col_2 IS NOT NULL THEN
               l_join_string := l_join_string ||
                                ' AND TIV.'|| c1.trx_col_2 ||l_outerjoin ||
                                ' = ENT.'|| c1.src_col_2;
            END IF;
            IF c1.trx_col_3 IS NOT NULL THEN
               l_join_string := l_join_string ||
                                ' AND TIV.'|| c1.trx_col_3 ||l_outerjoin ||
                                ' = ENT.'|| c1.src_col_3;
            END IF;
            IF c1.trx_col_4 IS NOT NULL THEN
               l_join_string := l_join_string ||
                                ' AND TIV.'|| c1.trx_col_4 ||l_outerjoin ||
                                ' = ENT.'|| c1.src_col_4;
            END IF;
         END IF;

         ----------------------------------------------------------------------
         -- getting the PROMPTs to be displayed
         ----------------------------------------------------------------------
         --l_col_array(l_index).f1 := ''''||c1.PROMPT||'''';
         l_col_array(l_index).f1 := ''''||REPLACE (c1.PROMPT, '''', '''''')||''''; --bug7567172

         ----------------------------------------------------------------------
         -- getting the columns to be displayed
         ----------------------------------------------------------------------
         IF c1.data_type = 'VARCHAR2' THEN
           l_col_array(l_index).f2 := 'TIV.'|| c1.column_name;

         ELSIF c1.data_type = 'DATE'  THEN
           l_col_array(l_index).f2 := 'to_char(TIV.'|| c1.column_name
                                   ||',''YYYY-MM-DD"T"hh:mi:ss'')';
         ELSE
           l_col_array(l_index).f2 := 'to_char(TIV.'|| c1.column_name||')';
         END IF;
      END LOOP;
   END IF;

   ----------------------------------------------------------------------------
   -- building the string to be added to the SELECT clause
   ----------------------------------------------------------------------------
   FOR i IN 1..l_col_array.count LOOP
      l_col_string := l_col_string || ',' ||
                      l_col_array(i).f1||'   USER_TRX_IDENTIFIER_NAME_'    ||TO_CHAR(i)||','||
                      l_col_array(i).f2||'   USER_TRX_IDENTIFIER_VALUE_' ||TO_CHAR(i);
   END LOOP;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_col_string = '||l_col_string
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;
   -----------------------------------------------------------------------------
   -- Following tests whether the view and columns are defined in the data base
   -----------------------------------------------------------------------------
   IF p_reporting_view_name IS NOT NULL THEN
      BEGIN
         ----------------------------------------------------------------------
         -- build and execute a dummy query if the view name is defined for
         -- the class
         -- NOTE: following never fails because the cursor joins to
         -- user_tab_columns table that will make sure that view and column
         -- names fetched exists. This can beremoved unless we decide to go
         -- for outerjoin on this table.
         ----------------------------------------------------------------------
         l_sql_string :=
                   ' SELECT '                     ||
                   ' NULL            dummy '      ||
                     l_col_string                 ||
                   ' FROM '                       ||
                   ' DUAL  dual '                 ||
                     l_view_name                  ||
                   ' WHERE ROWNUM = 1 ' ;


         EXECUTE IMMEDIATE l_sql_string;

      EXCEPTION
      WHEN OTHERS THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'Technical Warning: There seems to a problem in retreiving '||
                              'transaction identifiers from '||p_reporting_view_name
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
         END IF;

         ----------------------------------------------------------------------
         -- if the above query raises an exception following clears the FROM
         -- and WHERE strings and creates the error to be displayed to the user
         ----------------------------------------------------------------------
         l_col_array       := l_null_col_array;
         l_col_string      := NULL;
         l_col_array(1).f1 := '''Error''';
         l_col_array(1).f2 := '''Problem with Transaction Identifier View''';
         l_view_name       := NULL;
         l_join_string     := NULL;

         FOR i IN 1..l_col_array.count LOOP
            l_col_string := l_col_string || ',' ||
                            l_col_array(i).f1||'   USER_TRX_IDENTIFIER_NAME_'    ||TO_CHAR(i)||','||
                            l_col_array(i).f2||'   USER_TRX_IDENTIFIER_VALUE_' ||TO_CHAR(i);
         END LOOP;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'l_col_string = '||l_col_string
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;
      END;
   END IF;

   p_select_str := l_col_string;
   p_from_str   := l_view_name;
   p_where_str  := l_join_string;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_select_str = '||p_select_str
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_from_str = '||p_from_str
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_where_str = '||p_where_str
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'End of procedure GET_TRANSACTION_ID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_report_utility_pkg.get_transaction_id ');
END get_transaction_id;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE get_acct_qualifier_segs
       (p_coa_id                 IN         NUMBER
       ,p_balance_segment        OUT NOCOPY VARCHAR2
       ,p_account_segment        OUT NOCOPY VARCHAR2
       ,p_cost_center_segment    OUT NOCOPY VARCHAR2
       ,p_management_segment     OUT NOCOPY VARCHAR2
       ,p_intercompany_segment   OUT NOCOPY VARCHAR2) IS


l_balance_segment          VARCHAR2(80);
l_account_segment          VARCHAR2(80);
l_cost_center_segment      VARCHAR2(80);
l_management_segment       VARCHAR2(80);
l_intercompany_segment     VARCHAR2(80);
l_log_module               VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_acct_qualifier_segs';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GET_ACCT_QUALIFIER_SEGS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_coa_id = '||p_coa_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   BEGIN
      SELECT application_column_name
        INTO l_balance_segment
        FROM fnd_segment_attribute_values
       WHERE application_id         = 101
         AND id_flex_code           = 'GL#'
         AND id_flex_num            = p_coa_id
         AND attribute_value        = 'Y'
         AND segment_attribute_type = 'GL_BALANCING';
   EXCEPTION
   WHEN no_data_found THEN
      l_balance_segment := 'NULL';
   END;

   BEGIN
      SELECT application_column_name
        INTO l_account_segment
        FROM fnd_segment_attribute_values
       WHERE application_id         = 101
         AND id_flex_code           = 'GL#'
         AND id_flex_num            = p_coa_id
         AND attribute_value        = 'Y'
         AND segment_attribute_type = 'GL_ACCOUNT';
   EXCEPTION
   WHEN no_data_found THEN
      l_account_segment := 'NULL';
   END;

   BEGIN
      SELECT application_column_name
        INTO l_cost_center_segment
        FROM fnd_segment_attribute_values
       WHERE application_id         = 101
         AND id_flex_code           = 'GL#'
         AND id_flex_num            = p_coa_id
         AND attribute_value        = 'Y'
         AND segment_attribute_type = 'FA_COST_CTR';
   EXCEPTION
   WHEN no_data_found THEN
      l_cost_center_segment := 'NULL';
   END;

   BEGIN
      SELECT application_column_name
        INTO l_management_segment
        FROM fnd_segment_attribute_values
       WHERE application_id         = 101
         AND id_flex_code           = 'GL#'
         AND id_flex_num            = p_coa_id
         AND attribute_value        = 'Y'
         AND segment_attribute_type = 'GL_MANAGEMENT';
   EXCEPTION
   WHEN no_data_found THEN
      l_management_segment := 'NULL';
   END;

   BEGIN
      SELECT application_column_name
        INTO l_intercompany_segment
        FROM fnd_segment_attribute_values
       WHERE application_id         = 101
         AND id_flex_code           = 'GL#'
         AND id_flex_num            = p_coa_id
         AND attribute_value        = 'Y'
         AND segment_attribute_type = 'GL_INTERCOMPANY';
   EXCEPTION
   WHEN no_data_found THEN
      l_intercompany_segment := 'NULL';
   END;

   p_intercompany_segment := l_intercompany_segment;
   p_management_segment   := l_management_segment;
   p_cost_center_segment  := l_cost_center_segment;
   p_account_segment      := l_account_segment;
   p_balance_segment      := l_balance_segment;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_intercompany_segment = '||p_intercompany_segment
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_management_segment = '||p_management_segment
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_cost_center_segment = '||p_cost_center_segment
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_account_segment = '||p_account_segment
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_balance_segment = '||p_balance_segment
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'End of procedure GET_ACCT_QUALIFIER_SEGS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_report_utility_pkg.get_acct_qualifier_segs');
END get_acct_qualifier_segs;


--=============================================================================
--
-- Function to get concenated description of accounting flex field
--
--=============================================================================
FUNCTION get_ccid_desc
       (p_coa_id               IN NUMBER
       ,p_ccid                 IN NUMBER)
RETURN VARCHAR2  IS
l_ccid_desc                VARCHAR2(2000);
l_log_module               VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_ccid_desc';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GET_CCID_DESC'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_coa_id = '||p_coa_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ccid = '||p_ccid
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

  --returning ccid desc bug#9323360 via caching
   IF  g_t_cache_coa_id.EXISTS(p_coa_id) THEN
     IF g_t_cache_coa_id(p_coa_id).EXISTS(p_ccid) THEN
      RETURN g_t_cache_coa_id(p_coa_id)(p_ccid);
     END IF;
   END IF;
  --returning ccid desc bug#9323360


   IF fnd_flex_keyval.validate_ccid
         ('SQLGL','GL#',p_coa_id,p_ccid) = TRUE
   THEN
      l_ccid_desc := fnd_flex_keyval.concatenated_descriptions();

      -- bug#9323360
      -- used nested tables indexed by binary_integer. g_t_cache_coa_id is the parent table
      -- having child as description
      -- populate using hash key p_coa_id and p_ccid

      g_t_cache_coa_id(p_coa_id)(p_ccid)  :=  l_ccid_desc;

      --bug#9323360

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'l_ccid_desc = '||l_ccid_desc
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'END of procedure GET_CCID_DESC'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
      END IF;

      RETURN l_ccid_desc;
   ELSE
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'l_ccid_desc = '
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'END of procedure GET_CCID_DESC'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
      END IF;

      RETURN NULL;
   END IF;
EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_report_utility_pkg.get_ccid_desc');
END get_ccid_desc;


--=============================================================================
--
-- Body for the procedure clob_to_file
--
--=============================================================================
PROCEDURE clob_to_file
        (p_xml_clob           IN CLOB) IS

l_clob_size                NUMBER;
l_offset                   NUMBER;
l_chunk_size               INTEGER;
l_chunk                    VARCHAR2(32767);
l_log_module               VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.clob_to_file';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure CLOB_TO_FILE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_clob_size := dbms_lob.getlength(p_xml_clob);

   IF (l_clob_size = 0) THEN
      RETURN;
   END IF;
   l_offset     := 1;
   l_chunk_size := 3000;

   WHILE (l_clob_size > 0) LOOP
      l_chunk := dbms_lob.substr (p_xml_clob, l_chunk_size, l_offset);
      fnd_file.put
         (which     => fnd_file.output
         ,buff      => l_chunk);

      l_clob_size := l_clob_size - l_chunk_size;
      l_offset := l_offset + l_chunk_size;
   END LOOP;

   fnd_file.new_line(fnd_file.output,1);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure CLOB_TO_FILE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_report_utility_pkg.clob_to_file');
END clob_to_file;


--=============================================================================
--
-- Function to get condtions based on analytical detail values
--
--=============================================================================
FUNCTION get_anc_filter
       (p_anc_level                  IN VARCHAR2
       ,p_table_alias                IN VARCHAR2
       ,p_anc_detail_code            IN VARCHAR2
       ,p_anc_detail_value           IN VARCHAR2)
RETURN VARCHAR2 IS
l_column_name              VARCHAR2(80);
l_string                   VARCHAR2(2000);
l_log_module               VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_anc_filter';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GET_ANC_FILTER'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_anc_level = '||p_anc_level
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_table_alias = '||p_table_alias
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_anc_detail_code = '||p_anc_detail_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_anc_detail_value = '||p_anc_detail_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   SELECT
       CASE data_type_code
          WHEN 'C' THEN 'ADV.ANALYTICAL_DETAIL_CHAR_'||TO_CHAR(grouping_order)
          WHEN 'D' THEN 'ADV.ANALYTICAL_DETAIL_DATE_'||TO_CHAR(grouping_order)
          WHEN 'N' THEN 'ADV.ANALYTICAL_DETAIL_NUMBER_'||TO_CHAR(grouping_order)
          ELSE NULL
       END CASE
    INTO l_column_name
    FROM xla_analytical_dtls_b
   WHERE analytical_Detail_code = p_anc_detail_code;

   IF p_anc_level = 'H' THEN
      l_string := ' and exist ( '||
                  ' select 1 from xla_ae_header_details ahd, xla_analytical_dtl_vals adv '||
                  ' where ahd.ae_header_id = '||p_table_alias||'.ae_header_id '||
                  ' and adv.analytical_detail_value_id = ahd.analytical_detail_value_id '||
                  ' and adv.'||l_column_name||' = '''||p_anc_detail_value||''''||
                  ' )';
   ELSIF p_anc_level = 'L' THEN
      l_string := ' and exist ( '||
                  ' select 1 from xla_ae_line_details ald, xla_analytical_dtl_vals adv '||
                  ' where ald.ae_header_id = '||p_table_alias||'.ae_header_id '||
                  ' and ald.ae_line_num = '||p_table_alias||'.ae_line_num '||
                  ' and adv.analytical_detail_value_id = ald.analytical_detail_value_id '||
                  ' and adv.'||l_column_name||' = '''||p_anc_detail_value||''''||
                  ' )';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of function GET_ANC_FILTER'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_string;

EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_report_utility_pkg.get_anc_filter');
END get_anc_filter;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION is_primary_ledger (p_ledger_id IN NUMBER)
RETURN NUMBER IS

l_ledger_id  gl_ledgers.ledger_id%type;

BEGIN

   select ledger_id
     into l_ledger_id
     from gl_ledgers
    where ledger_category_code = 'PRIMARY'
      and ledger_id = p_ledger_id
      and rownum = 1;

   RETURN l_ledger_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN NULL;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_report_utility_pkg.unravel_ledger (fn)');
END is_primary_ledger;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_ledger_id (p_ledger_id    IN NUMBER)
RETURN NUMBER IS

  l_object_type_code gl_ledgers.object_type_code%TYPE;
  l_ledger_id        gl_ledgers.ledger_id%TYPE;
  l_ledger_id_out    gl_ledgers.ledger_id%TYPE;

BEGIN

  l_object_type_code := xla_report_utility_pkg.
                       get_ledger_object_type(p_ledger_id);

  IF l_object_type_code = 'L' THEN

    select distinct primary_ledger_id
      into l_ledger_id_out
      from xla_ledger_relationships_v
     where ledger_id = p_ledger_id;



  ELSIF l_object_type_code = 'S' THEN

    select ledger_id
      into l_ledger_id
      from gl_ledger_set_assignments glsa
     where glsa.ledger_id <> p_ledger_id
       and glsa.ledger_set_id = p_ledger_id
       and rownum = 1;

    select distinct primary_ledger_id
      into l_ledger_id_out
      from xla_ledger_relationships_v
     where ledger_id = l_ledger_id;

  END IF;

  RETURN l_ledger_id_out;

EXCEPTION
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_report_utility_pkg.unravel_ledger (fn)');
END get_ledger_id;

--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_ledger_object_type (p_ledger_id    IN NUMBER)
RETURN VARCHAR2 IS

  l_object_type_code gl_ledgers.object_type_code%TYPE;

BEGIN

  SELECT object_type_code
    INTO l_object_type_code
    FROM gl_ledgers
   WHERE ledger_id = p_ledger_id;

  RETURN l_object_type_code;

EXCEPTION
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_report_utility_pkg.unravel_ledger (fn)');
END get_ledger_object_type;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_transaction_id
            (p_resp_application_id IN NUMBER
            ,p_ledger_id          IN NUMBER ) RETURN VARCHAR2 IS
CURSOR cur_event_class  IS
  (SELECT   DISTINCT
            xet.application_id        APPLICATION_ID
           ,xet.entity_code           ENTITY_CODE
           ,xet.event_class_code      EVENT_CLASS_CODE
           ,xeca.reporting_view_name  REPORTING_VIEW_NAME
    FROM    xla_event_types_b         xet
           ,xla_event_class_attrs     xeca
   WHERE   xeca.entity_code       =  xet.entity_code
     AND   xeca.event_class_code  =  xet.event_class_code
     AND   xeca.application_id    =  p_resp_application_id
     AND   xet.application_id     =  xeca.application_id
     AND   EXISTS
     ( SELECT /*+ hash_sj */ null
     FROM xla_ae_headers aeh
     WHERE
     AEH.LEDGER_ID       = p_ledger_id AND
     XET.APPLICATION_ID  = AEH.APPLICATION_ID AND
     XET.EVENT_TYPE_CODE = AEH.EVENT_TYPE_CODE AND
     XECA.APPLICATION_ID = AEH.APPLICATION_ID )) ;  --added for bug 7688085,7707717

l_col_array           t_array;
l_null_col_array      t_array;
l_trx_id_str          VARCHAR2(32000);
l_col_string          VARCHAR2(4000)   := NULL;
l_view_name           VARCHAR2(800);
l_join_string         VARCHAR2(4000)   := NULL;
l_sql_string          VARCHAR2(4000) := NULL;
l_index               INTEGER;
l_outerjoin           VARCHAR2(30);
l_log_module          VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_transaction_id';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GET_TRANSACTION_ID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_resp_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   l_trx_id_str := ',CASE WHEN 1<1 THEN NULL';

   --
   -- creating a dummy array that contains "NULL" strings
   --
   FOR i IN 1..10 LOOP
      l_null_col_array(i).f1 := 'NULL';
      l_null_col_array(i).f2 := 'NULL';
   END LOOP;

   FOR cur_trx IN cur_event_class LOOP
      l_col_string    := NULL;
      l_view_name     := NULL;
      l_join_string   := NULL;

      IF cur_trx.entity_code NOT IN('MANUAL','THIRD_PARTY_MERGE')  THEN
         --
         -- initiating the array that contains name of the columns to be selected
         -- from the TID View.
         --
         l_col_array := l_null_col_array;
         l_index := 0;

         --
         -- creating SELECT,FROM and WHERE clause strings when the reporting view is
         -- defined for an Event Class.
         --

         IF cur_trx.reporting_view_name IS NOT NULL THEN
            --
            -- creating string to be added to FROM clause
            --
            l_view_name   := cur_trx.reporting_view_name || '    TIV';
            FOR cols_csr IN
               (SELECT  xid.transaction_id_col_name_1   trx_col_1
                       ,xid.transaction_id_col_name_2   trx_col_2
                       ,xid.transaction_id_col_name_3   trx_col_3
                       ,xid.transaction_id_col_name_4   trx_col_4
                       ,xid.source_id_col_name_1        src_col_1
                       ,xid.source_id_col_name_2        src_col_2
                       ,xid.source_id_col_name_3        src_col_3
                       ,xid.source_id_col_name_4        src_col_4
                       ,xem.column_name                 column_name
                       ,xem.column_title                PROMPT
                       ,utc.data_type                   data_type
                  FROM  xla_entity_id_mappings   xid
                       ,xla_event_mappings_vl    xem
                       ,user_tab_columns         utc
                 WHERE xid.application_id       = cur_trx.application_id
                   AND xid.entity_code          = cur_trx.entity_code
                   AND xem.application_id       = cur_trx.application_id
                   AND xem.entity_code          = cur_trx.entity_code
                   AND xem.event_class_code     = cur_trx.event_class_code
                   AND utc.table_name           = cur_trx.reporting_view_name
                   AND utc.column_name          = xem.column_name
              ORDER BY xem.user_sequence)
            LOOP

               l_index := l_index + 1;
               --
               -- creating string to be added to WHERE clause
               --
               IF l_index = 1 THEN
                  -----------------------------------------------------------------
                  -- Bug 3389175
                  -- Following logic is build to make sure all events are reported
                  -- if debug is enabled evenif there is no data for the event in the
                  -- transaction id view.
                  -- if log enabled  then
                  --        outer join to TID view
                  -- endif
                  -----------------------------------------------------------------
                  IF g_log_level <> C_LEVEL_LOG_DISABLED THEN
                     l_outerjoin := '(+)';
                  ELSE
                     l_outerjoin := NULL;
                  END IF;

                  IF cols_csr.trx_col_1 IS NOT NULL THEN
                     l_join_string := l_join_string ||
                                     '  TIV.'|| cols_csr.trx_col_1 ||l_outerjoin ||
                                     ' = ENT.'|| cols_csr.src_col_1;
                  END IF;
                  IF cols_csr.trx_col_2 IS NOT NULL THEN
                     l_join_string := l_join_string ||
                                    ' AND TIV.'|| cols_csr.trx_col_2 ||l_outerjoin ||
                                    ' = ENT.'|| cols_csr.src_col_2;
                  END IF;
                  IF cols_csr.trx_col_3 IS NOT NULL THEN
                     l_join_string := l_join_string ||
                                    ' AND TIV.'|| cols_csr.trx_col_3 ||l_outerjoin ||
                                    ' = ENT.'|| cols_csr.src_col_3;
                  END IF;
                  IF cols_csr.trx_col_4 IS NOT NULL THEN
                     l_join_string := l_join_string ||
                                   ' AND TIV.'|| cols_csr.trx_col_4 ||l_outerjoin ||
                                   ' = ENT.'|| cols_csr.src_col_4;
                  END IF;
               END IF;
               --
               -- getting the PROMPTs to be displayed
               -- Bug 5360816. Added REPLACE to handle apostophe in user prompts.
               --
               l_col_array(l_index).f1 := ''''||REPLACE(cols_csr.PROMPT,'''','''''')||'''';

               ---
               -- getting the columns to be displayed
               ---
               IF cols_csr.data_type = 'VARCHAR2' THEN
                  l_col_array(l_index).f2 := 'TIV.'|| cols_csr.column_name;

               ELSIF cols_csr.data_type = 'DATE' THEN
                  l_col_array(l_index).f2 := 'to_char(TIV.'|| cols_csr.column_name
                                             ||',''YYYY-MM-DD"T"hh:mi:ss'')';
               ELSE
                  l_col_array(l_index).f2 := 'to_char(TIV.'|| cols_csr.column_name||')';
               END IF;
            END LOOP;
         END IF;
         --------------------------------------------------------------------------
         -- building the string to be added to the SELECT clause
         --------------------------------------------------------------------------
         IF l_index > 0 THEN
            l_col_string := l_col_string ||
                            l_col_array(1).f1||'||''|''||'||
                            l_col_array(1).f2;

            FOR i IN 2..l_col_array.count LOOP
               l_col_string := l_col_string ||'||''|''||'||
                               l_col_array(i).f1||'||''|''||'||
                               l_col_array(i).f2;
            END LOOP;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'l_col_string = '||l_col_string
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
            END IF;

            l_trx_id_str := l_trx_id_str||
                            ' WHEN xet.event_class_code = '''||
                            cur_trx.event_class_code||
                            ''' THEN  ( SELECT '||l_col_string||
                            ' FROM  '||l_view_name ||' WHERE '|| l_join_string ||')';
         END IF;
      END IF;
   END LOOP;

   l_trx_id_str := l_trx_id_str ||' END  ';
   RETURN l_trx_id_str;

EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_report_utility_pkg.get_transaction_id ');

END get_transaction_id;



-------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Added for bug 7580995

PROCEDURE get_transaction_id(p_resp_application_id  IN NUMBER
                           ,p_ledger_id           IN NUMBER
                           ,p_trx_identifiers_1   OUT NOCOPY VARCHAR2
                           ,p_trx_identifiers_2   OUT NOCOPY VARCHAR2
                           ,p_trx_identifiers_3   OUT NOCOPY VARCHAR2
                           ,p_trx_identifiers_4   OUT NOCOPY VARCHAR2
                           ,p_trx_identifiers_5   OUT NOCOPY VARCHAR2) IS
CURSOR cur_event_class  IS
  (SELECT   DISTINCT
            xet.application_id        APPLICATION_ID
           ,xet.entity_code           ENTITY_CODE
           ,xet.event_class_code      EVENT_CLASS_CODE
           ,xeca.reporting_view_name  REPORTING_VIEW_NAME
    FROM    xla_event_types_b         xet
           ,xla_event_class_attrs     xeca
   WHERE   xeca.entity_code       =  xet.entity_code
     AND   xeca.event_class_code  =  xet.event_class_code
     AND   xeca.application_id    =  p_resp_application_id
     AND   xet.application_id     =  xeca.application_id
     AND   EXISTS
     ( SELECT /*+ hash_sj */ null
     FROM xla_ae_headers aeh
     WHERE
     AEH.LEDGER_ID       = p_ledger_id AND
     XET.APPLICATION_ID  = AEH.APPLICATION_ID AND
     XET.EVENT_TYPE_CODE = AEH.EVENT_TYPE_CODE AND
     XECA.APPLICATION_ID = AEH.APPLICATION_ID )) ;  --added for bug 7688085,7707717

l_col_array           t_array;
l_null_col_array      t_array;
l_trx_id_str          VARCHAR2(32000);
l_col_string          VARCHAR2(4000)   := NULL;
l_view_name           VARCHAR2(800);
l_join_string         VARCHAR2(4000)   := NULL;
l_sql_string          VARCHAR2(4000) := NULL;
l_index               INTEGER;
l_outerjoin           VARCHAR2(30);
l_log_module          VARCHAR2(240);
l_trx_id_str_temp     VARCHAR2(32000):=NULL;
l_id_num              number:=1;

BEGIN

p_trx_identifiers_1 := ' ';
p_trx_identifiers_2 := ' ';
p_trx_identifiers_3 := ' ';
p_trx_identifiers_4 := ' ';
p_trx_identifiers_5 := ' ';

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_transaction_id';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GET_TRANSACTION_ID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_resp_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   l_trx_id_str := ',CASE WHEN 1<1 THEN NULL';

   --
   -- creating a dummy array that contains "NULL" strings
   --
   FOR i IN 1..10 LOOP
      l_null_col_array(i).f1 := 'NULL';
      l_null_col_array(i).f2 := 'NULL';
   END LOOP;

   FOR cur_trx IN cur_event_class LOOP
      l_col_string    := NULL;
      l_view_name     := NULL;
      l_join_string   := NULL;

      IF cur_trx.entity_code NOT IN('MANUAL','THIRD_PARTY_MERGE')  THEN
         --
         -- initiating the array that contains name of the columns to be selected
         -- from the TID View.
         --
         l_col_array := l_null_col_array;
         l_index := 0;

         --
         -- creating SELECT,FROM and WHERE clause strings when the reporting view is
         -- defined for an Event Class.
         --

         IF cur_trx.reporting_view_name IS NOT NULL THEN
            --
            -- creating string to be added to FROM clause
            --
            l_view_name   := cur_trx.reporting_view_name || '    TIV';
            FOR cols_csr IN
               (SELECT  xid.transaction_id_col_name_1   trx_col_1
                       ,xid.transaction_id_col_name_2   trx_col_2
                       ,xid.transaction_id_col_name_3   trx_col_3
                       ,xid.transaction_id_col_name_4   trx_col_4
                       ,xid.source_id_col_name_1        src_col_1
                       ,xid.source_id_col_name_2        src_col_2
                       ,xid.source_id_col_name_3        src_col_3
                       ,xid.source_id_col_name_4        src_col_4
                       ,xem.column_name                 column_name
                       ,xem.column_title                PROMPT
                       ,utc.data_type                   data_type
                  FROM  xla_entity_id_mappings   xid
                       ,xla_event_mappings_vl    xem
                       ,user_tab_columns         utc
                 WHERE xid.application_id       = cur_trx.application_id
                   AND xid.entity_code          = cur_trx.entity_code
                   AND xem.application_id       = cur_trx.application_id
                   AND xem.entity_code          = cur_trx.entity_code
                   AND xem.event_class_code     = cur_trx.event_class_code
                   AND utc.table_name           = cur_trx.reporting_view_name
                   AND utc.column_name          = xem.column_name
              ORDER BY xem.user_sequence)
            LOOP

               l_index := l_index + 1;
               --
               -- creating string to be added to WHERE clause
               --
               IF l_index = 1 THEN
                  -----------------------------------------------------------------
                  -- Bug 3389175
                  -- Following logic is build to make sure all events are reported
                  -- if debug is enabled evenif there is no data for the event in the
                  -- transaction id view.
                  -- if log enabled  then
                  --        outer join to TID view
                  -- endif
                  -----------------------------------------------------------------
                  IF g_log_level <> C_LEVEL_LOG_DISABLED THEN
                     l_outerjoin := '(+)';
                  ELSE
                     l_outerjoin := NULL;
                  END IF;

                  IF cols_csr.trx_col_1 IS NOT NULL THEN
                     l_join_string := l_join_string ||
                                     '  TIV.'|| cols_csr.trx_col_1 ||l_outerjoin ||
                                     ' = ENT.'|| cols_csr.src_col_1;
                  END IF;
                  IF cols_csr.trx_col_2 IS NOT NULL THEN
                     l_join_string := l_join_string ||
                                    ' AND TIV.'|| cols_csr.trx_col_2 ||l_outerjoin ||
                                    ' = ENT.'|| cols_csr.src_col_2;
                  END IF;
                  IF cols_csr.trx_col_3 IS NOT NULL THEN
                     l_join_string := l_join_string ||
                                    ' AND TIV.'|| cols_csr.trx_col_3 ||l_outerjoin ||
                                    ' = ENT.'|| cols_csr.src_col_3;
                  END IF;
                  IF cols_csr.trx_col_4 IS NOT NULL THEN
                     l_join_string := l_join_string ||
                                   ' AND TIV.'|| cols_csr.trx_col_4 ||l_outerjoin ||
                                   ' = ENT.'|| cols_csr.src_col_4;
                  END IF;
               END IF;
               --
               -- getting the PROMPTs to be displayed
               -- Bug 5360816. Added REPLACE to handle apostophe in user prompts.
               --
               l_col_array(l_index).f1 := ''''||REPLACE(cols_csr.PROMPT,'''','''''')||'''';

               ---
               -- getting the columns to be displayed
               ---
               IF cols_csr.data_type = 'VARCHAR2' THEN
                  l_col_array(l_index).f2 := 'TIV.'|| cols_csr.column_name;

               ELSIF cols_csr.data_type = 'DATE' THEN
                  l_col_array(l_index).f2 := 'to_char(TIV.'|| cols_csr.column_name
                                             ||',''YYYY-MM-DD"T"hh:mi:ss'')';
               ELSE
                  l_col_array(l_index).f2 := 'to_char(TIV.'|| cols_csr.column_name||')';
               END IF;
            END LOOP;
         END IF;
         --------------------------------------------------------------------------
         -- building the string to be added to the SELECT clause
         --------------------------------------------------------------------------
         IF l_index > 0 THEN
            l_col_string := l_col_string ||
                            l_col_array(1).f1||'||''|''||'||
                            l_col_array(1).f2;

            FOR i IN 2..l_col_array.count LOOP
               l_col_string := l_col_string ||'||''|''||'||
                               l_col_array(i).f1||'||''|''||'||
                               l_col_array(i).f2;
            END LOOP;


         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'length of l_col_string = '||length(l_col_string)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
         END IF;

        l_trx_id_str_temp := l_trx_id_str||
                            ' WHEN xet.event_class_code = '''||
                            cur_trx.event_class_code||
                            ''' THEN  ( SELECT '||l_col_string||
                            ' FROM  '||l_view_name ||' WHERE '|| l_join_string ||')';
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'length of l_trx_id_str_temp = '||length(l_trx_id_str_temp)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
       END IF;

      IF  length(l_trx_id_str_temp)<=25000 then
        l_trx_id_str := l_trx_id_str_temp;

      ELSE
        IF l_id_num = 1 then
          p_trx_identifiers_1 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
        END IF;
        IF l_id_num = 2 then
          p_trx_identifiers_2 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
        END IF;
        IF l_id_num = 3 then
          p_trx_identifiers_3 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
        END IF;
        IF l_id_num = 4 then
          p_trx_identifiers_4 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
        END IF;
       IF l_id_num = 5 then
          p_trx_identifiers_5 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
       END IF;
       l_trx_id_str_temp := ' WHEN xet.event_class_code = '''||
                             cur_trx.event_class_code||
                            ''' THEN  ( SELECT '||l_col_string||
                            ' FROM  '||l_view_name ||' WHERE '|| l_join_string ||')';

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'inside length of l_trx_id_str_temp = '||length(l_trx_id_str_temp)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
       END IF;

       l_id_num := l_id_num + 1;

     END IF;




           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'length of l_trx_id_str = '||length(l_trx_id_str)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
           END IF;



        END IF;

    END IF;

   END LOOP;

    l_trx_id_str := l_trx_id_str ||' END  '||' USERIDS';

    if l_id_num = 1 then
         p_trx_identifiers_1 := l_trx_id_str;
    elsif l_id_num = 2 then
         p_trx_identifiers_2 := l_trx_id_str;
    elsif l_id_num = 3 then
         p_trx_identifiers_3 := l_trx_id_str;
    elsif l_id_num = 4 then
         p_trx_identifiers_4 := l_trx_id_str;
    elsif l_id_num = 5 then
         p_trx_identifiers_5 := l_trx_id_str;
    end if;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('get_transaction_id .End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_report_utility_pkg.get_transaction_id ');

END get_transaction_id;

------------------------------------------------------------------------------
------------------------------------------------------------------------------

--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_conc_segments
       (p_coa_id                  NUMBER
       ,p_table_alias             VARCHAR2)
RETURN VARCHAR2 IS

TYPE t_array_char IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

l_conc_seg_delimiter            VARCHAR2(80);
l_concat_segment                VARCHAR2(4000);
l_array                         t_array_char;
l_log_module                    VARCHAR2(240);

CURSOR  c(p_coa_id NUMBER,p_table_alias VARCHAR2)  IS
   SELECT  p_table_alias||'.'||application_column_name seg
     FROM  fnd_id_flex_segments
    WHERE  application_id =101
      AND  id_flex_code ='GL#'
      AND  id_flex_num = p_coa_id
 ORDER BY  segment_num ;

 BEGIN

    IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.get_conc_segments';
    END IF;
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
          (p_msg      => 'BEGIN of function GET_CONC_SEGMENTS'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
       trace
          (p_msg      => 'p_coa_id = '||p_coa_id
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
       trace
          (p_msg      => 'p_table_alias = '||p_table_alias
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
    END IF;

   --
   -- Get concatenated segment delimiter for COA
   --

   SELECT  '||'''||concatenated_segment_delimiter||'''||'
     INTO  l_conc_seg_delimiter
     FROM  fnd_id_flex_structures
    WHERE application_id =101
      AND id_flex_code ='GL#'
      AND id_flex_num = p_coa_id;

   OPEN c(p_coa_id ,p_table_alias);

   FETCH c BULK COLLECT INTO l_array;

   CLOSE c;

   FOR  i in 1 .. l_array.count LOOP
      l_concat_segment := l_concat_segment||l_array(i);

      IF i<l_array.count THEN
      l_concat_segment := l_concat_segment||l_conc_seg_delimiter;
      END IF;

   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of function GET_CONC_SEGMENTS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_concat_segment;

EXCEPTION
WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location       => 'xla_report_utility_pkg.get_conc_segments ');

END get_conc_segments;


--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END XLA_REPORT_UTILITY_PKG;

/
