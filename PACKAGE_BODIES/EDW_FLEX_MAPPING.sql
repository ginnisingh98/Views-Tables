--------------------------------------------------------
--  DDL for Package Body EDW_FLEX_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_FLEX_MAPPING" as
/* $Header: EDWSRFLB.pls 115.5 2002/12/05 22:19:00 arsantha ship $ */

/*===========================================================================*/

FUNCTION GET_VALUE(   P_fact_name	 	 IN  VARCHAR2,
			  P_dim_name		 IN  VARCHAR2,
			  P_ccid		 IN  NUMBER,
			  P_set_of_books_id      IN  VARCHAR2,
			  P_structure_id              IN  NUMBER)
				RETURN VARCHAR2 IS

l_application_column_name	VARCHAR2(30);
l_value_set_id                  NUMBER(10);
l_instance_code			VARCHAR2(10);
l_segment_value                 VARCHAR2(25);
l_sob				NUMBER;
l_edw_sob			NUMBER;
l_parent_equi_sob		NUMBER;
l_parent_sob			NUMBER;
l_instance			VARCHAR2(30);
BEGIN

	l_sob := p_set_of_books_id;

	begin

	select loc.edw_set_of_books_id into l_edw_sob
	from edw_local_set_of_books loc,
	edw_local_instance inst
	where P_set_of_books_id = loc.set_of_books_id
	AND loc.instance = inst.instance_code;

	Exception when no_data_found then
		return 'NA_EDW';
	end;

	begin

	select EQUI_SET_OF_BOOKS_ID into l_parent_equi_sob
	from edw_local_equi_set_of_books
	where l_edw_sob = EDW_SET_OF_BOOKS_ID;

	select set_of_books_id, instance into l_parent_sob, l_instance
	from edw_local_set_of_books loc
	where edw_set_of_books_id = l_parent_equi_sob;

	Exception
          when no_data_found then
		null;
	  when others then
		raise;
	END;
  --------------------------
  IF  (P_fact_name IS NULL) OR
      (P_dim_name IS NULL) OR
	(P_ccid IS NULL) OR
	(P_set_of_books_id IS NULL) OR
	(P_structure_id IS NULL)
	then
      RETURN 'NA_EDW';
  END IF;


	SELECT
		map.application_column_name,
		map.value_set_id,
		map.instance_code
	INTO
		l_application_column_name,
		l_value_set_id,
		l_instance_code
	FROM
		edw_local_instance inst,
		edw_local_flex_seg_mappings_v map,
		edw_local_fact_flex_fk_maps_v fact
	WHERE
		fact.fact_short_name 		= p_fact_name
	--	AND fact.fk_physical_name 	= p_fk_name
		AND map.dimension_short_name 	= fact.dimension_short_name
		AND fact.dimension_short_name   = p_dim_name
		AND map.instance_code		= inst.instance_code
		AND map.structure_num		= p_structure_id
		AND upper(fact.enabled_flag)	= 'Y';

	IF l_parent_equi_sob IS NOT NULL  THEN
		l_instance_code := l_instance;
		l_sob		:= l_parent_sob;
	END IF;

	-- We will now put a huge IF statement in order not to use dynamic sql


		IF (l_application_column_name = 'SEGMENT1') THEN
			SELECT 	segment1
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT2') THEN
			SELECT 	segment2
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT3') THEN
			SELECT 	segment3
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT4') THEN
			SELECT 	segment4
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT5') THEN
			SELECT 	segment5
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT6') THEN
			SELECT 	segment6
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT7') THEN
			SELECT 	segment7
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT8') THEN
			SELECT 	segment8
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT9') THEN
			SELECT 	segment9
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT10') THEN
			SELECT 	segment10
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT11') THEN
			SELECT 	segment11
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT12') THEN
			SELECT 	segment12
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT13') THEN
			SELECT 	segment13
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT14') THEN
			SELECT 	segment14
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT15') THEN
			SELECT 	segment15
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT16') THEN
			SELECT 	segment16
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT17') THEN
			SELECT 	segment17
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT18') THEN
			SELECT 	segment18
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT19') THEN
			SELECT 	segment19
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		ELSIF (l_application_column_name = 'SEGMENT20') THEN
			SELECT 	segment20
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT21') THEN
			SELECT 	segment21
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT22') THEN
			SELECT 	segment22
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT23') THEN
			SELECT 	segment23
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT24') THEN
			SELECT 	segment24
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT25') THEN
			SELECT 	segment25
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT26') THEN
			SELECT 	segment26
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT27') THEN
			SELECT 	segment27
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT28') THEN
			SELECT 	segment28
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT29') THEN
			SELECT 	segment29
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;
		ELSIF (l_application_column_name = 'SEGMENT30') THEN
			SELECT 	segment30
			INTO   	l_segment_value
			FROM 	gl_code_combinations
			WHERE	code_combination_id	= p_ccid
			AND	chart_of_accounts_id	= p_structure_id;

		END IF;


   RETURN l_segment_value||'-'||l_sob||'-'||l_instance_code;


EXCEPTION
 WHEN NO_DATA_FOUND THEN
       RETURN 'NA_EDW';
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
	return 'Error!';
       -- Provide debug information
--       RETURN "ERROR!! "||debug_info
   END IF;
   -- APP_EXCEPTION.RAISE_EXCEPTION;

END get_value;


END EDW_FLEX_MAPPING;

/
