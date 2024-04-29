--------------------------------------------------------
--  DDL for Package Body FND_IREP_CP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_IREP_CP_PKG" AS
/* $Header: AFIRCPPB.pls 120.1 2005/07/02 04:08:38 appldev noship $ */
--
-- Procedure
--   GET_CP_PARAM_ANNOTATIONS
--
-- Purpose
--   Get the parameter details of the given CP
--
-- Returns: the parameter annotations as a clob enclosed within
-- /** and */
--
--
FUNCTION GET_CP_PARAM_ANNOTATIONS(
                          p_cp_id IN NUMBER,
                          p_app_id IN NUMBER)
			  RETURN VARCHAR2
			  IS

    cursor IREP_CURSOR is
	  select
	  FDFCU.END_USER_COLUMN_NAME,
	  FDFCU.REQUIRED_FLAG,
          DECODE(FDFCU.DISPLAY_FLAG, 'N', 'N', 'Y'),
	  TL.DESCRIPTION,
	  TL.FORM_LEFT_PROMPT,
	  FVS.FLEX_VALUE_SET_NAME
	  from
	  FND_CONCURRENT_PROGRAMS FCP,
	  FND_DESCR_FLEX_COLUMN_USAGES FDFCU,
	  FND_DESCR_FLEX_COL_USAGE_TL TL,
	  FND_FLEX_VALUE_SETS FVS
	  where
	  FCP.APPLICATION_ID=p_app_id AND
	  FCP.CONCURRENT_PROGRAM_ID=p_cp_id AND
	  FDFCU.ENABLED_FLAG='Y' AND
	  FDFCU.DESCRIPTIVE_FLEXFIELD_NAME=
		'$SRS$.'||FCP.CONCURRENT_PROGRAM_NAME AND
	  TL.DESCRIPTIVE_FLEXFIELD_NAME=FDFCU.DESCRIPTIVE_FLEXFIELD_NAME AND
	  TL.APPLICATION_COLUMN_NAME=FDFCU.APPLICATION_COLUMN_NAME AND
	  TL.LANGUAGE='US' AND
	  FDFCU.FLEX_VALUE_SET_ID=FVS.FLEX_VALUE_SET_ID AND
          FDFCU.APPLICATION_ID = FCP.APPLICATION_ID AND
          TL.APPLICATION_ID = FDFCU.APPLICATION_ID AND
          TL.DESCRIPTIVE_FLEX_CONTEXT_CODE=FDFCU.DESCRIPTIVE_FLEX_CONTEXT_CODE
	  order by
	  FDFCU.COLUMN_SEQ_NUM;

    param_name varchar2(60);
    param_req  varchar2(60);
    param_disp Varchar2(1);
    param_desc FND_DESCR_FLEX_COL_USAGE_TL.DESCRIPTION%TYPE;
    param_prompt FND_DESCR_FLEX_COL_USAGE_TL.FORM_LEFT_PROMPT%TYPE;
    param_type FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE;

    -- variable to hold one parameter annotation
    v_annotation varchar2(4000);
    n number;
    -- whole annotation
    v_annotation_block varchar2(32000);

  begin
	open irep_cursor;

	-- Write the string /** to show the beginning of the annotation
	v_annotation_block := '/**' || wf_core.newline;

	LOOP
	   -- Get the parameter values into the cursor
	   fetch irep_cursor
	    into param_name, param_req, param_disp,
		 param_desc, param_prompt, param_type;
	   exit when irep_Cursor%NOTFOUND;

	   -- Replace % character with %%
	   param_name:=REPLACE(param_name, '%', '%%');

   	   -- Replace space character with %_
	   param_name:=REPLACE(param_name, ' ', '%_');

 	   -- Create the annotation for a single parameter.  If no
           -- description is found, the prompt value is taken as description
	   v_annotation := '  * @param ' || param_name || ' ' ||
	 	NVL(param_desc, param_prompt) || wf_core.newline ||
		'  * @rep:paraminfo {@rep:type ' || param_type || '}' ||
			     ' {@rep:displayed ' || param_disp || '}';

           if (param_req = 'Y') then
                         v_annotation := v_annotation || ' {@rep:required}';
           end if;

           v_annotation := v_annotation || wf_core.newline;
	   v_annotation_block := v_annotation_block || v_annotation;

	END loop;

        -- Write the string */ to show the end of the annotation
	v_annotation_block := v_annotation_block || '  */';

        close irep_cursor;
	return v_annotation_block;
  end;

END FND_IREP_CP_PKG;

/
