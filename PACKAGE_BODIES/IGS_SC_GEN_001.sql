--------------------------------------------------------
--  DDL for Package Body IGS_SC_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SC_GEN_001" AS
/* $Header: IGSSC06B.pls 120.7 2006/05/30 10:02:47 vskumar noship $ */

/******************************************************************
    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.
 Created By         : Uma Maheswari
 Date Created By    : May 16, 2005
 Purpose            : This package is to be used for the processing of the security process for Oracle
                      Student System.
 remarks            : None
 Change History

Who             When           What
mmkumar         24-jun-2005     modified check_ins_security to use bind variables
mmkumar         26-JUL-2005     Modified check_ins_security to remove extra bracket and removed the quotes around hard-coded value
gmaheswa        4-May-2006	Modified size of var l_out_string, l_upper_string in Replace String Method to 32000, as select stmt can be 32000.
-----------------------------------------------------------

******************************************************************/
-- -----------------------------------------------------------------
-- Define the global variables to be used in this package.
-- -----------------------------------------------------------------

  TYPE g_grant_cond_rec IS RECORD (obj_attrib_id     igs_sc_grant_conds.obj_attrib_id%TYPE,
                                   user_attrib_id    igs_sc_grant_conds.user_attrib_id%TYPE,
				   condition         igs_sc_grant_conds.condition%TYPE,
				   text_value        igs_sc_grant_conds.text_value%TYPE,
				   user_attrib_value igs_sc_usr_att_vals.attr_value%TYPE,
				   obj_attrib_value  igs_sc_obj_att_vals.attr_value%TYPE,
				   cond_text         VARCHAR2(4000),
                                   obj_const         VARCHAR2(4000),
				   close_part        VARCHAR2(100),
				    z_typ_flag        VARCHAR2(1) --mmkumar
				   );
  TYPE g_grant_conds_t IS TABLE OF g_grant_cond_rec  INDEX BY BINARY_INTEGER;
  g_debug_level      NUMBER(1) := 0;

 l_prog_label CONSTANT VARCHAR2(500) :='igs.plsql.igs_sc_gen_001';
 l_request_id  NUMBER;
 l_label VARCHAR2(4000);
 l_debug_str VARCHAR2(32000);
 --mmkumar,
 onlyZTypeAttributes BOOLEAN := true;
 l_grant_text       VARCHAR2(4000);
 l_bodmas_grant_text  VARCHAR2(4000);

FUNCTION check_operation (p_operation VARCHAR2
) RETURN VARCHAR2
IS
  l_operation VARCHAR2(25);
BEGIN
  l_operation:= p_operation;
  IF p_operation = '>' THEN
    l_operation := '<';
  ELSIF p_operation ='<' THEN
    l_operation := '>';
  ELSIF p_operation = '>=' THEN
    l_operation := '<=';
  ELSIF p_operation = '<=' THEN
    l_operation := '>=';
  END IF;
  RETURN l_operation;
END check_operation;

FUNCTION replace_string(p_string       IN VARCHAR2,
			  p_from_pattern IN VARCHAR2,
			  p_to_pattern   IN VARCHAR2
			 ) RETURN VARCHAR2
  IS
   l_out_string   VARCHAR2(32000);
   l_upper_string VARCHAR2(32000);
   l_occurence    NUMBER(10) := 0;
   l_len          NUMBER(5);
  BEGIN
    IF UPPER(p_from_pattern) = UPPER(p_to_pattern) THEN
    --check for being the same value, infinite loop
    RETURN p_string;
    END IF;
    -- delete all values for the current user
    l_out_string := p_string;
    l_upper_string := UPPER(l_out_string);
    l_len := LENGTH(p_from_pattern);
    l_occurence := INSTR(l_upper_string,p_from_pattern,1,1);
    LOOP
      IF l_occurence = 0
      THEN
        -- no more found exit
        EXIT;
      END IF;
      l_out_string := SUBSTR(l_out_string,1,l_occurence-1)||p_to_pattern||SUBSTR(l_out_string,l_occurence+l_len,32000);
      l_upper_string := UPPER(l_out_string);
      -- find next
      l_occurence := INSTR(l_upper_string,p_from_pattern,1,1);
    END LOOP;
    RETURN l_out_string;
  END replace_string;

FUNCTION check_grant_text (p_table_name VARCHAR2,
                            p_select_text VARCHAR2
			   )RETURN BOOLEAN
IS
   l_api_name       CONSTANT VARCHAR2(30)   := 'CHECK_GRANT_TEXT';
   l_val NUMBER(20);
   l_select_text VARCHAR(32000);

BEGIN
   l_select_text := replace_string(LTRIM(p_select_text),':PARTY_ID','igs_sc_vars.get_partyid');
   l_select_text := replace_string(LTRIM(l_select_text),':USER_ID','igs_sc_vars.get_userid');
   l_select_text := replace_string(LTRIM(l_select_text),':TBL_ALIAS','tstal');
   EXECUTE IMMEDIATE 'SELECT count(*) FROM ('||' SELECT 1 FROM '||p_table_name||' WHERE '||l_select_text||' )' INTO l_val;
   RETURN TRUE;

EXCEPTION
 WHEN OTHERS THEN
   RETURN FALSE;
END check_grant_text;

FUNCTION check_ins_security(
                            p_bo_name      IN VARCHAR2,
			    p_object_name  IN VARCHAR2,
                            p_attrib_tab   IN attrib_rec,
                            p_msg_data OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
 ------------------------------------------------------------------
  --Updated by  : gmaheswa, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose: code replication of generate/build grant in SC02.
  -- need to form the sql of predicate clause, evaluate that by replacing the values for attribs passed.
  -- p_attrib_tab has all user attibs passed, ...

  --Change History:
------------------------------------------------------------------
  l_statment     VARCHAR2(32000);   -- Grant statment
  l_stat_found   BOOLEAN := FALSE;
  l_grant_cond   g_grant_conds_t;
  l_user_attrib  igs_sc_usr_attribs%ROWTYPE;
  l_obj_attrib   igs_sc_obj_attribs%ROWTYPE;
  l_cur_pos      NUMBER(10);
  l_found_pos    NUMBER(10);
  l_cur_num      NUMBER(1);
  l_alias_name   VARCHAR2(8);
  l_attr_select  VARCHAR2(32000);
  l_usr_select   VARCHAR2(32000);
  l_obj_select   VARCHAR2(32000);
  l_obj_const    VARCHAR2(32000);
  l_usr_const    VARCHAR2(32000);
  l_obj_alias    VARCHAR2(25);
  l_usr_alias    VARCHAR2(25);
  l_column_name  VARCHAR2(255);
  l_finally      VARCHAR2(32000);
  l_post_grant   VARCHAR2(255);
  l_select       VARCHAR2(32000);
  l_where        VARCHAR2(32000);
  l_Ext_Cursor	 NUMBER;
  l_SelectStatement VARCHAR2(32000);
  l_output	NUMBER;
  lnRows	NUMBER(5);

  CURSOR c_get_grant( cp_object VARCHAR2, cp_user_id NUMBER) IS
  SELECT gr.grant_id ,
         obj.object_id,
	 obj.obj_group_id ,
	 gr.grant_text
  FROM   igs_sc_grants  gr,
         igs_sc_objects obj,
         fnd_objects    fnd,
         wf_local_user_roles rls
  WHERE  gr.grant_insert_flag='Y'
  AND gr.locked_flag ='Y'
  AND obj.obj_group_id =  gr.obj_group_id
  AND obj.object_id = fnd.object_id
  AND fnd.application_id IN (8405,8406)
  AND UPPER( fnd.obj_name) = cp_object
  AND rls.user_orig_system_id = cp_user_id
  AND rls.role_orig_system = 'IGS'
  AND rls.role_orig_system_id = gr.user_group_id
  AND SYSDATE BETWEEN NVL(rls.start_date,SYSDATE-1) AND NVL(rls.expiration_date,SYSDATE+1)
  ORDER BY gr.grant_id ;

  CURSOR c_grant_where (s_grant_id NUMBER, s_obj_id NUMBER) IS
  SELECT grant_where
  FROM igs_sc_obj_grants
  WHERE object_id = s_obj_id
  AND grant_id = s_grant_id
  FOR UPDATE OF grant_where;

  -- Select of all conditions for a grant
  CURSOR c_grant_cond (s_grant_id NUMBER )IS
  SELECT grant_id,
         grant_cond_num,
	 obj_attrib_id,
	 user_attrib_id,
	 condition,
	 text_value
  FROM   igs_sc_grant_conds
  WHERE  grant_id = s_grant_id;

  -- Get user attributes.
  CURSOR c_user_attrib (s_attrib_id NUMBER) IS
  SELECT *
  FROM igs_sc_usr_attribs
  WHERE user_attrib_id = s_attrib_id;

  CURSOR c_obj_attrib ( s_obj_attrib_id NUMBER, s_obj_group_id NUMBER) IS
  SELECT *
  FROM igs_sc_obj_attribs
  WHERE obj_group_id = s_obj_group_id
  AND   obj_attrib_id= s_obj_attrib_id;

  CURSOR def_grnt(p_obj_name VARCHAR2)
  IS
  SELECT b.DEFAULT_POLICY_TYPE
  FROM igs_sc_objects a,
       igs_sc_obj_groups b,
       fnd_objects c
  WHERE c.obj_name = p_obj_name
  AND c.object_id = a.object_id
  AND b.obj_group_id = a.obj_group_id;

  CURSOR c_null_allow_flag (cp_object_id number,cp_obj_attrib_id number) IS
  SELECT null_allow_flag
  FROM igs_sc_obj_att_mths
  WHERE object_id = cp_object_id
  AND obj_attrib_id = cp_obj_attrib_id;

  cnt NUMBER;
  l_val NUMBER;
  l_grants_exist BOOLEAN := FALSE;
  l_def_gr VARCHAR2(1);
  l_user_id  NUMBER;
  L_NULL_FLAG VARCHAR2(1) := 'N';
  l_null_allow varchar2(1);


  lv_obj_constant varchar2(4000);

BEGIN

  fnd_dsql.init;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
     l_debug_str :=  P_ATTRIB_TAB.ADVISOR||','||
		     P_ATTRIB_TAB.ADVISOR_PERSON_ID||','||
		     P_ATTRIB_TAB.APPLICATION_PROGRAM_CODE||','||
		     P_ATTRIB_TAB.APPLICATION_TYPE||','||
		     P_ATTRIB_TAB.INSTRUCTOR_ID||','||
		     P_ATTRIB_TAB.INSTRUCTOR_PERSON_ID||','||
		     P_ATTRIB_TAB.LOCATION||','||
		     P_ATTRIB_TAB.NOMINATED_COURSE_CODE||','||
		     P_ATTRIB_TAB.ORGANIZATIONAL_UNIT_CODE||','||
		     P_ATTRIB_TAB.OWNING_ORG_UNIT_CODE||','||
		     P_ATTRIB_TAB.PERSON_ID||','||
		     P_ATTRIB_TAB.PERSON_TYPE||','||
		     P_ATTRIB_TAB.PROGRAM_ATTEMPT_ADVISOR||','||
		     P_ATTRIB_TAB.PROGRAM_ATTEMPT_LOCATION||','||
		     P_ATTRIB_TAB.PROGRAM_ATT_OWNING_ORG_UNIT_CD||','||
		     P_ATTRIB_TAB.PROGRAM_ATT_RESP_ORG_UNIT_CD||','||
		     P_ATTRIB_TAB.PROGRAM_ATTEMPT_TYPE||','||
		     P_ATTRIB_TAB.PROGRAM_OWNING_ORG_UNIT_CODE||','||
		     P_ATTRIB_TAB.PROGRAM_RESP_ORG_UNIT_CODE||','||
		     P_ATTRIB_TAB.PROGRAM_TYPE||','||
		     P_ATTRIB_TAB.RESPONSIBLE_ORG_UNIT_CODE||','||
		     P_ATTRIB_TAB.TEACHING_ORG_UNIT_CODE||','||
		     P_ATTRIB_TAB.UNIT_LOCATION||','||
		     P_ATTRIB_TAB.UNIT_MODE||','||
		     P_ATTRIB_TAB.UNIT_ATT_ORG_UNIT_CODE||','||
		     P_ATTRIB_TAB.UNIT_ATTEMPT_LOCATION||','||
		     P_ATTRIB_TAB.UNIT_ATTEMPT_INSTRUCTOR||','||
		     P_ATTRIB_TAB.UNIT_ATTEMPT_MODE||','||
		     P_ATTRIB_TAB.OTHER_UNIT_ORG_UNIT_CODE||','||
		     P_ATTRIB_TAB.OTHER_UNIT_LOCATION||','||
		     P_ATTRIB_TAB.OTHER_UNIT_INSTRUCTOR||','||
		     P_ATTRIB_TAB.OTHER_UNIT_MODE;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

  l_user_id := FND_GLOBAL.USER_ID;
  --l_statment := 'SELECT 1 FROM DUAL WHERE ';
  fnd_dsql.add_text('SELECT 1 FROM DUAL WHERE ');

  -- For the object, pick up all the grants.
  FOR grants_rec IN c_get_grant(p_object_name,l_user_id)
  LOOP
    l_grants_exist := TRUE;
    l_finally := '';
    onlyZTypeAttributes := TRUE;
	   --
	   --
	   -- For each condition in grant
	   --code added by mmkumar
		   FOR cc_grant_cond_rec IN c_grant_cond(grants_rec.grant_id) LOOP
			  IF cc_grant_cond_rec.obj_attrib_id  IS NOT NULL THEN
			       OPEN c_null_allow_flag( grants_rec.object_id, cc_grant_cond_rec.obj_attrib_id);
			       FETCH c_null_allow_flag INTO l_null_allow;

			       IF c_null_allow_flag%NOTFOUND THEN
				    -- Method for the table not found
				    close c_null_allow_flag;
			       ELSIF l_null_allow IN ('Y','N') THEN
				    onlyZTypeAttributes  := false;
				    close c_null_allow_flag;
				    EXIT;
			       END IF;

			       IF C_NULL_ALLOW_FLAG%ISOPEN THEN
				    CLOSE c_null_allow_flag;
			       END IF;
			  END IF;
		   END LOOP;
	   --code added by mmkumar ends
	    --
	    --

		--**  Statement level logging.
		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			 l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
			 if onlyZTypeAttributes then
     			     l_debug_str :=  'onlyZTypeAttributes : true ';
                         else
     			     l_debug_str :=  'onlyZTypeAttributes : false ';
                         end if;
			 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;
		--**

	    FOR c_grant_cond_rec IN c_grant_cond(grants_rec.grant_id) LOOP
		      l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id  := c_grant_cond_rec.obj_attrib_id;
		      l_grant_cond(c_grant_cond_rec.grant_cond_num).user_attrib_id := c_grant_cond_rec.user_attrib_id;
		      l_grant_cond(c_grant_cond_rec.grant_cond_num).condition      := c_grant_cond_rec.condition;
		      l_grant_cond(c_grant_cond_rec.grant_cond_num).text_value     := c_grant_cond_rec.text_value;
		      l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_const      := null;
		      l_usr_select := '';
		      l_obj_const  := '';
		      l_usr_const  := '';
		      l_usr_alias := 'sc'||grants_rec.grant_id||'u'||c_grant_cond_rec.grant_cond_num||'a';
		      L_OBJ_SELECT := '';

		      -- Construct select stmt from the fetched grant condition
		      IF l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id  IS NOT NULL THEN
			-- Get the object attribute name for the object attribute ID.
			OPEN c_obj_attrib (l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id ,grants_rec.obj_group_id );
			FETCH c_obj_attrib INTO l_obj_attrib;
			CLOSE c_obj_attrib;

			--code added by mmkumar
			       OPEN c_null_allow_flag( grants_rec.object_id, c_grant_cond_rec.obj_attrib_id);
			       FETCH c_null_allow_flag INTO l_null_allow;
				  l_grant_cond(c_grant_cond_rec.grant_cond_num).z_typ_flag := l_null_allow;
                               CLOSE c_null_allow_flag;
			-- code added by mmkumar ends

			--Read the PL/SQL table and match the attribute name.
			IF UPPER(l_obj_attrib.obj_attrib_name) = 'ADVISOR' THEN
			   IF(INSTR(P_ATTRIB_TAB.ADVISOR,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.ADVISOR;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.ADVISOR;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'ADVISOR PERSON ID' THEN
			   IF(INSTR(P_ATTRIB_TAB.ADVISOR_PERSON_ID,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.ADVISOR_PERSON_ID;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.ADVISOR_PERSON_ID;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'APPLICATION PROGRAM CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.APPLICATION_PROGRAM_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.APPLICATION_PROGRAM_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.APPLICATION_PROGRAM_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'APPLICATION TYPE' THEN
			   IF(INSTR(P_ATTRIB_TAB.APPLICATION_TYPE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.APPLICATION_TYPE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.APPLICATION_TYPE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'INSTRUCTOR ID' THEN
			   IF(INSTR(P_ATTRIB_TAB.INSTRUCTOR_ID,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.INSTRUCTOR_ID;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.INSTRUCTOR_ID;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'INSTRUCTOR PERSON ID' THEN
			   IF(INSTR(P_ATTRIB_TAB.INSTRUCTOR_PERSON_ID,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.INSTRUCTOR_PERSON_ID;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.INSTRUCTOR_PERSON_ID;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'LOCATION' THEN
			   IF(INSTR(P_ATTRIB_TAB.LOCATION,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.LOCATION;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.LOCATION;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'NOMINATED COURSE CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.NOMINATED_COURSE_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.NOMINATED_COURSE_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.NOMINATED_COURSE_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.ORGANIZATIONAL_UNIT_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.ORGANIZATIONAL_UNIT_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.ORGANIZATIONAL_UNIT_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'OWNING ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.OWNING_ORG_UNIT_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.OWNING_ORG_UNIT_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.OWNING_ORG_UNIT_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PERSON ID' THEN
			   IF(INSTR(P_ATTRIB_TAB.PERSON_ID,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PERSON_ID;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PERSON_ID;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PERSON TYPE' THEN
			   IF(INSTR(P_ATTRIB_TAB.PERSON_TYPE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PERSON_TYPE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PERSON_TYPE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PROGRAM ATTEMPT ADVISOR' THEN
			   IF(INSTR(P_ATTRIB_TAB.PROGRAM_ATTEMPT_ADVISOR,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PROGRAM_ATTEMPT_ADVISOR;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PROGRAM_ATTEMPT_ADVISOR;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PROGRAM ATTEMPT LOCATION' THEN
			   IF(INSTR(P_ATTRIB_TAB.PROGRAM_ATTEMPT_LOCATION,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PROGRAM_ATTEMPT_LOCATION;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PROGRAM_ATTEMPT_LOCATION;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PROGRAM ATTEMPT OWNING ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.PROGRAM_ATT_OWNING_ORG_UNIT_CD,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PROGRAM_ATT_OWNING_ORG_UNIT_CD;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PROGRAM_ATT_OWNING_ORG_UNIT_CD;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PROGRAM ATTEMPT RESPONSIBLE ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.PROGRAM_ATT_RESP_ORG_UNIT_CD,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PROGRAM_ATT_RESP_ORG_UNIT_CD;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PROGRAM_ATT_RESP_ORG_UNIT_CD;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PROGRAM ATTEMPT TYPE' THEN
			   IF(INSTR(P_ATTRIB_TAB.PROGRAM_ATTEMPT_TYPE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PROGRAM_ATTEMPT_TYPE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PROGRAM_ATTEMPT_TYPE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PROGRAM OWNING ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.PROGRAM_OWNING_ORG_UNIT_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PROGRAM_OWNING_ORG_UNIT_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PROGRAM_OWNING_ORG_UNIT_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PROGRAM RESPONSIBLE ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.PROGRAM_RESP_ORG_UNIT_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PROGRAM_RESP_ORG_UNIT_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PROGRAM_RESP_ORG_UNIT_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'PROGRAM TYPE' THEN
			   IF(INSTR(P_ATTRIB_TAB.PROGRAM_TYPE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.PROGRAM_TYPE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.PROGRAM_TYPE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'RESPONSIBLE ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.RESPONSIBLE_ORG_UNIT_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.RESPONSIBLE_ORG_UNIT_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.RESPONSIBLE_ORG_UNIT_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'TEACHING ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.TEACHING_ORG_UNIT_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.TEACHING_ORG_UNIT_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.TEACHING_ORG_UNIT_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'UNIT LOCATION' THEN
			   IF(INSTR(P_ATTRIB_TAB.UNIT_LOCATION,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.UNIT_LOCATION;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.UNIT_LOCATION;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'UNIT MODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.UNIT_MODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.UNIT_MODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.UNIT_MODE;
			   END IF;
			ELSIF UPPER(L_OBJ_ATTRIB.OBJ_ATTRIB_NAME) = 'UNIT ATTEMPT ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.UNIT_ATT_ORG_UNIT_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.UNIT_ATT_ORG_UNIT_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.UNIT_ATT_ORG_UNIT_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'UNIT ATTEMPT LOCATION' THEN
			   IF(INSTR(P_ATTRIB_TAB.UNIT_ATTEMPT_LOCATION,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.UNIT_ATTEMPT_LOCATION;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.UNIT_ATTEMPT_LOCATION;
			   END IF;
			ELSIF UPPER(L_OBJ_ATTRIB.OBJ_ATTRIB_NAME) = 'UNIT ATTEMPT INSTRUCTOR' THEN
			   IF(INSTR(P_ATTRIB_TAB.UNIT_ATTEMPT_INSTRUCTOR,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.UNIT_ATTEMPT_INSTRUCTOR;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.UNIT_ATTEMPT_INSTRUCTOR;
			   END IF;
			ELSIF UPPER(L_OBJ_ATTRIB.OBJ_ATTRIB_NAME) = 'UNIT ATTEMPT MODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.UNIT_ATTEMPT_MODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.UNIT_ATTEMPT_MODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.UNIT_ATTEMPT_MODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'OTHER UNIT ORGANIZATIONAL UNIT CODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.OTHER_UNIT_ORG_UNIT_CODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.OTHER_UNIT_ORG_UNIT_CODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.OTHER_UNIT_ORG_UNIT_CODE;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'OTHER UNIT LOCATION' THEN
			   IF(INSTR(P_ATTRIB_TAB.OTHER_UNIT_LOCATION,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.OTHER_UNIT_LOCATION;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.OTHER_UNIT_LOCATION;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'OTHER UNIT INSTRUCTOR' THEN
			   IF(INSTR(P_ATTRIB_TAB.OTHER_UNIT_INSTRUCTOR,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.OTHER_UNIT_INSTRUCTOR;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.OTHER_UNIT_INSTRUCTOR;
			   END IF;
			ELSIF UPPER(l_obj_attrib.obj_attrib_name) = 'OTHER UNIT MODE' THEN
			   IF(INSTR(P_ATTRIB_TAB.OTHER_UNIT_MODE,'SELECT') > 0) THEN
			      L_OBJ_SELECT := P_ATTRIB_TAB.OTHER_UNIT_MODE;
			   ELSE
			      L_OBJ_CONST :=   P_ATTRIB_TAB.OTHER_UNIT_MODE;
			   END IF;
			END IF;

			IF l_obj_const IS NOT NULL THEN l_obj_const := ''''||l_obj_const||''''; END IF;

		      ELSE
			-- Object attr is null, use the text_Value as the default one.
			l_obj_const := l_grant_cond(c_grant_cond_rec.grant_cond_num).text_value;
		      END IF;

		      IF c_grant_cond_rec.user_attrib_id IS NOT NULL THEN
			  -- read attribute definition
			  OPEN c_user_attrib ( l_grant_cond(c_grant_cond_rec.grant_cond_num).user_attrib_id );
			  FETCH c_user_attrib INTO l_user_attrib;
			  CLOSE c_user_attrib;

			  -- If dynamic attribute - get value for dynamic C - constant, S - static, D - dynamic
			  -- Check for being multi-value attribute. T Table column name,  S select statement,  F Function call,  M - multy values - select only
			  IF l_user_attrib.static_type = 'D' AND l_user_attrib.user_attrib_type <> 'F' THEN
			      -- Dynamic attribute - we need to append the actual select for this attribute
			      l_attr_select := replace_string(ltrim(l_user_attrib.select_text),':PARTY_ID','igs_sc_vars.get_partyid');
			      l_attr_select := replace_string(ltrim(l_attr_select),':USER_ID','igs_sc_vars.get_userid');
			      -- Replace table alias value with our alias, generated based on attribute id
			      l_usr_select := replace_string(ltrim(l_attr_select),':TBL_ALIAS',l_usr_alias);

			  ELSIF l_user_attrib.static_type = 'D' AND l_user_attrib.user_attrib_type = 'F' THEN
			     l_attr_select := replace_string(ltrim(l_user_attrib.select_text),':PARTY_ID','igs_sc_vars.get_partyid');
			     l_usr_const := replace_string(ltrim(l_attr_select),':USER_ID','igs_sc_vars.get_userid');

			  ELSIF l_user_attrib.user_attrib_type = 'M' THEN
			     -- If yes then construct for multi-value attribute
			     -- Add select from values table
			     l_usr_select :='SELECT '||l_usr_alias||'.attr_value FROM igs_sc_usr_att_vals '||l_usr_alias||' WHERE '||l_usr_alias||'.user_id=igs_sc_vars.get_userid AND '
					    ||l_usr_alias||'.user_attrib_id='||c_grant_cond_rec.user_attrib_id;
			  ELSE
			     --Simply get value for an attribute using API and append
			     l_usr_const := 'igs_sc_vars.get_att('||c_grant_cond_rec.user_attrib_id||')';
			  END IF; -- Multy value attribute end

		      ELSE  --Add Text instead of parameter
			  l_usr_const := l_grant_cond(c_grant_cond_rec.grant_cond_num).text_value;

		      END IF; -- User parameter id null

		      -- l_usr_const, l_obj_const - function or text value of any kind
		      -- l_obj_select, l_usr_select - select statments.

			    --**  Statement level logging.
			    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
			      l_debug_str :=  'l_obj_select is : '|| l_obj_select || ' and l_obj_const is ' || l_obj_const;
			      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			    END IF;
			    --**


			    --**  Statement level logging.
			    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
			      l_debug_str :=  'l_usr_select is : '|| l_usr_select || ' and l_usr_const is ' || l_usr_const;
			      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			    END IF;
			    --**

		      OPEN c_null_allow_flag(grants_rec.OBJECT_ID,l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id);
		      FETCH c_null_allow_flag INTO L_NULL_FLAG;
		      CLOSE c_null_allow_flag;


		    -- Add post grant condition
		    IF l_obj_select IS NULL THEN
		         --code added my mmkumar
			 IF L_NULL_FLAG = 'Z' THEN
			       --IF isSingleGrantCond(p_grants_rec.grant_text) THEN
			       IF onlyZTypeAttributes THEN
				    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' 1=1 ';
			       ELSE
				    NULL;
			       END IF;
			 ELSE

			    --**  Statement level logging.
			    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
			      l_debug_str :=  'l_obj_select is not null : '|| l_obj_select;
			      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			    END IF;
			    --**

			     --code added by mmkumar ends
			     IF  l_obj_const IS NOT NULL AND l_usr_select IS NOT NULL THEN
			         -- User attribute is select of any kind and object attribute is not select
			         -- User Select = Obj CONST
			         l_found_pos := INSTR(UPPER(ltrim(l_usr_select)),'FROM',1,1);
			         l_column_name := substr(ltrim(l_usr_select),8,l_found_pos-9); -- 8 position 'select ' found -9 ' FROM'
   			         --grant text ' EXISTS (object_select AND Column Condition ( user attrr select))
 			         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text
				      ||' EXISTS ('||l_usr_select||' AND '||l_column_name||' '||check_operation(l_grant_cond(c_grant_cond_rec.grant_cond_num).condition)||' ';   -- ||l_obj_const||' ))';
                                 l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_const := l_obj_const;
			         l_grant_cond(c_grant_cond_rec.grant_cond_num).close_part := ' )'; --mmkumar, removed extra bracket
			     ELSIF l_obj_const IS NULL  AND l_usr_select IS NOT NULL THEN
			         IF L_NULL_FLAG = 'Y' THEN
				     l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' 1=1 ';                    --mmmkumar, replaced return true
			         END IF;
			         -- Colunmn name = User Select
			         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' '||
			         l_grant_cond(c_grant_cond_rec.grant_cond_num).condition ||' (' ||l_usr_select||') '||l_post_grant;
			     ELSE
			         -- Column name or Object Const = User CONST
			         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' '||
			         l_obj_const||' '||l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' '||l_usr_const||l_post_grant;
			     END IF;
		        END IF; -- added by mmkumar
		    ELSE --Object select is not null
			  --find the name of the select coulmn for attribute
			  l_found_pos := INSTR(UPPER(ltrim(l_obj_select)),'FROM',1,1);
			  l_column_name := substr(ltrim(l_obj_select),8,l_found_pos-9); -- 8 position 'select ' found -9 ' FROM'
			  --grant text ' EXISTS (object_select AND Column Condition ( user attrr select))


		           --code added my mmkumar
                    IF L_NULL_FLAG  = 'Z' THEN
 	                 IF onlyZTypeAttributes THEN
	                    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text :=  l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' 1=1 ';
                         ELSE
	                    NULL;
	                 END IF;
	            ELSE
                 	  -- its not Z
			  IF l_usr_select IS NOT NULL THEN
			      --Add user select
			      l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' EXISTS ('||l_obj_select||' AND '||l_column_name||' '||
			      l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' ('||l_usr_select||' )';
				 IF L_NULL_FLAG <> 'Y' THEN
				      l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' ) ';
				 END IF;
			  ELSE  --Add user constant
			      IF l_grant_cond(c_grant_cond_rec.grant_cond_num).condition IS NULL THEN
				    --operator in the grant text - don't add anything but Object select
				    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_obj_select;
			      ELSE
				    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' EXISTS ('||l_obj_select||' AND '||l_column_name||' '||
				    l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' '||l_usr_const;
     			    IF L_NULL_FLAG <> 'Y' THEN
				       l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' ) ';
 				    END IF;
			      END IF;
			  END IF;

			  IF L_NULL_FLAG = 'Y' THEN
			      l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text :=  l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' OR NOT EXISTS (' ||l_obj_select||'))';
		         END IF;
                    END IF; --mmkumar
		 END IF;
	END LOOP;

	--
	--
	   --code added by mmkumar
	  l_cur_pos :=1;
	  l_found_pos := 0;

	  l_grant_text := grants_rec.grant_text;
	  LOOP
	       l_found_pos := INSTR(l_grant_text,':',l_cur_pos,1);

  	       IF l_found_pos =0 THEN -- End loop no occurences found anymore
		    EXIT;
	       END IF;

	       -- Find number of predicate - total numbers is limited to 9 so far.

	       l_cur_num := SUBSTR(l_grant_text,l_found_pos+1,1);  --Just one character
	       IF l_grant_cond(l_cur_num).z_typ_flag = 'Z' AND NOT onlyZTypeAttributes THEN
		    l_grant_text :=  REPLACE(l_grant_text, ':' || l_cur_num,'');
	       END IF;
	       l_cur_pos := l_found_pos + 2;
	  END LOOP;

	     l_bodmas_grant_text := IGS_SC_GRANTS_PVT.getBodmasCondition(l_grant_text);

	    --**  Statement level logging.
	    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
	      l_debug_str :=  'Got string from bodmas : '|| l_bodmas_grant_text; --l_statment;
	      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	    END IF;
	    --**


	   --code added by mmkumar
	--
	--




	    --  Analize grant structure and construct grant, example  "(:1 AND (:2 OR :3))"
	    l_cur_pos :=1;
	    l_found_pos := 0;
	    -- First pass - check if there is anything before the first grant condition
	    l_found_pos := INSTR(l_bodmas_grant_text,':',l_cur_pos,1);

	    IF l_found_pos >1 THEN
	       --IF l_statment IS NOT NULL THEN -- not first grant, we need to  add OR
		  --l_statment := l_statment||' OR ';
		  fnd_dsql.add_text(' OR ');
	       --END IF;
	    END IF;

	    LOOP

	      -- Find next occurence of :

	      l_found_pos := INSTR(l_bodmas_grant_text,':',l_cur_pos,1);

	      IF l_found_pos =0 THEN -- End loop no occurences found anymore
		 EXIT;
	      END IF;

               --added by mmkumar
	       IF l_grant_cond(l_cur_num).z_typ_flag = 'Z' AND onlyZTypeAttributes THEN
	            fnd_dsql.add_text('1 = 1');
     	            --l_statment := l_statment || '1 = 1';
	            EXIT;
	       END IF;
	       --added by mmkumar

	      -- Find number of predicate - total numbers is limited to 9 so far.

	      l_cur_num := SUBSTR(l_bodmas_grant_text,l_found_pos+1,1);  --Just one character
	      --l_statment := l_statment||SUBSTR(grants_rec.grant_text,l_cur_pos, (l_found_pos - l_cur_pos));
              fnd_dsql.add_text(SUBSTR(l_bodmas_grant_text,l_cur_pos, (l_found_pos - l_cur_pos)));
	      -- Add condition from found grant number to statement
	      --l_statment := l_statment || l_grant_cond(l_cur_num).cond_text;
	      fnd_dsql.add_text(l_grant_cond(l_cur_num).cond_text);

	      if l_grant_cond(l_cur_num).obj_const is not null then

		lv_obj_constant := l_grant_cond(l_cur_num).obj_const;
                l_grant_cond(l_cur_num).obj_const := replace(l_grant_cond(l_cur_num).obj_const,'''','');


	        fnd_dsql.add_bind(l_grant_cond(l_cur_num).obj_const);
                fnd_dsql.add_text(l_grant_cond(l_cur_num).close_part);
	      end if;

	      l_cur_pos := l_found_pos + 2;

	    END LOOP;






	    -- Add last part of condition
	  IF NOT (l_grant_cond(l_cur_num).z_typ_flag = 'Z' AND onlyZTypeAttributes) THEN
	    --l_statment := l_statment||substr(grants_rec.grant_text,l_cur_pos);
            fnd_dsql.add_text(substr(l_bodmas_grant_text,l_cur_pos));
	  END IF;
	    --**  Statement level logging.
	    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
	      l_debug_str :=  'Final Select: '|| fnd_dsql.get_text(); --l_statment;
	      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	    END IF;
	    --**
	    ---now evaluate the grant, as this is pre-evaulation
	    BEGIN
		l_val :=0;
		l_SelectStatement := fnd_dsql.get_text(FALSE);

		    --**  Statement level logging.
		    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
		      l_debug_str :=  'statement to be executed : '|| l_SelectStatement;
		      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		    END IF;
		    --**

	        l_ext_cursor := DBMS_SQL.OPEN_CURSOR;
                fnd_dsql.set_cursor(l_ext_cursor);
		DBMS_SQL.PARSE (l_ext_cursor, l_SelectStatement, DBMS_SQL.V7);
		fnd_dsql.do_binds;
		dbms_sql.define_column(l_ext_cursor, 1, l_output);
		lnRows :=  DBMS_SQL.EXECUTE (l_ext_cursor);
		IF dbms_sql.fetch_rows(l_ext_cursor) > 0 THEN
			dbms_sql.column_value(l_ext_cursor, 1, l_output);
			  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			    l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security.finalreturn';
			    l_debug_str := 'Final Select: TRUE ';
			    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			  END IF;
			RETURN TRUE;
                END IF;

		/*
		EXECUTE IMMEDIATE l_statment INTO l_val;

		IF (l_val = 1) THEN
		  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		    l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security.finalreturn';
		    l_debug_str := 'Final Select: TRUE ';
		    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		  END IF;

		  RETURN TRUE;
		END IF;
		*/
	      EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		    l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security.finalreturn';
		    l_debug_str := 'Final Select: FALSE ';
		    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		  END IF;

		  RETURN FALSE;
		WHEN OTHERS THEN
		  --**  Statement level logging.
		  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security.Exception';
		      l_debug_str :=  'Exception: '||SQLERRM;
		      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		  END IF;
		  --**
		  p_msg_data := SQLERRM;
		  RETURN FALSE;
	      END;
    END LOOP;

    -- if no grant statement exists, evaluate the default policy..if grant then return TRUE
    IF NOT L_GRANTS_EXIST THEN
      OPEN DEF_GRNT(P_OBJECT_NAME);
      FETCH DEF_GRNT INTO l_def_gr;
      IF l_def_gr = 'G' THEN
         IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
            l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security.DefaultPolicy';
            l_debug_str := 'DefaultPolicy: TRUE ';
            fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
         RETURN TRUE;
      ELSE
         IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
            l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security.DefaultPolicy';
            l_debug_str := 'DefaultPolicy: FALSE ';
            fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
         RETURN FALSE;
      END IF;
   END IF;

	    --**  Statement level logging.
	    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
	      l_debug_str :=  'Returing False after setting it null : ';
	      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	    END IF;
	    --**

   p_msg_data  := NULL;
   RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
	    --**  Statement level logging.
	    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	      l_label := 'igs.plsql.igs_sc_gen_001.check_ins_security';
	      l_debug_str :=  'inside exception section : ' || SQLERRM;
	      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	    END IF;
	    --**

     p_msg_data := SQLERRM;
     RETURN FALSE;
END check_ins_security;

PROCEDURE set_ctx(
  p_name VARCHAR2
) IS
 ------------------------------------------------------------------
  --Updated by  : gmaheswa, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose: FGAC-- set context --this makes everything securre---so dba policy predicate would
  -- get appened to all sqls.
  --
  --Change History:
------------------------------------------------------------------
BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sc_gen_001.set_ctx';
     l_debug_str := 'Context set User ID: '||FND_GLOBAL.USER_ID||','||'Responsibility ID'||FND_GLOBAL.RESP_ID;
     fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

  IF(SYS_CONTEXT('OSS_APP_CTX','SECURITY') IS NULL) THEN
     dbms_session.set_context( 'OSS_APP_CTX', 'SECURITY', UPPER(P_NAME));
  END IF;
END set_ctx;

PROCEDURE unset_ctx(
  p_name VARCHAR2
) IS
 ------------------------------------------------------------------
  --Updated by  : gmaheswa, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose: FGAC-- unset context --this makes it unrestricted...dba_policy predicate would not get appeneded.
  --
  --Change History:
------------------------------------------------------------------
BEGIN
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sc_gen_001.unset_ctx';
     l_debug_str := 'Context UNset User ID: '||FND_GLOBAL.USER_ID||','||'Responsibility ID'||FND_GLOBAL.RESP_ID;
     fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

  IF(SYS_CONTEXT('OSS_APP_CTX','SECURITY') IS NOT NULL) THEN
     dbms_session.set_context( 'OSS_APP_CTX', 'SECURITY', '' );
  END IF;
END unset_ctx;

FUNCTION CHECK_SEL_UPD_DEL_SECURITY (
 P_Tab_Name IN VARCHAR2,
 P_Rowid    IN ROWID,
 P_Action   IN VARCHAR2, --(U/D - Update/Delete)
 P_Msg_data OUT NOCOPY VARCHAR2) -- return the error message in case of any exceptions.
RETURN BOOLEAN IS -- TRUE if update/delete privileges are there else return FALSE
 ------------------------------------------------------------------
  --Updated by  : gmaheswa, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose:main wrapper for pre-check security, (only for select,upd, del)
  -- different for insert, as evaluation for insert is different.
  --
  --Change History:
------------------------------------------------------------------

l_obj_exists_cur VARCHAR2(4000);
L_WHERE_CLAUSE VARCHAR2(32000);
L_SELECT_STMT VARCHAR2(32000);
l_obj_found VARCHAR2(1);
l_grant VARCHAR2(1);
l_operation VARCHAR2(10);

TYPE GetGrantCurTyp IS REF CURSOR;
Grant_cv GetGrantCurTyp;

BEGIN
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_gen_001.check_sel_upd_del_security';
       l_debug_str := 'Table Name: '||P_Tab_Name||','||'RowID: '||P_Rowid||','||'Action: '||P_Action;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

    IF P_Tab_Name <> 'IGS_PS_UNIT_OFR_OPT_SV' THEN
	--validate whether the table is registered for the particular operation or not.
	l_obj_exists_cur := 'SELECT 1 FROM IGS_SC_OBJECTS SC, FND_OBJECTS FND WHERE SC.OBJECT_ID = FND.OBJECT_ID AND FND.OBJ_NAME =  UPPER(:P_Tab_Name) AND ';
        IF P_ACTION = 'S' THEN
          L_OBJ_EXISTS_CUR := L_OBJ_EXISTS_CUR||' SC.SELECT_FLAG = ''Y''';
          l_operation := 'SELECT';
        ELSIF P_ACTION = 'U' THEN
          L_OBJ_EXISTS_CUR := L_OBJ_EXISTS_CUR||' SC.UPDATE_FLAG = ''Y''';
          l_operation := 'UPDATE';
        ELSIF P_ACTION = 'D' THEN
          L_OBJ_EXISTS_CUR := L_OBJ_EXISTS_CUR||' SC.DELETE_FLAG = ''Y''';
          l_operation := 'DELETE';
        END IF;

	    --**  Statement level logging.
	    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	      l_label := 'igs.plsql.igs_sc_gen_001.check_sel_upd_del_security';
	      l_debug_str :=  'executing statement : '|| l_obj_exists_cur;
	      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	    END IF;
	    --**

        EXECUTE IMMEDIATE l_obj_exists_cur INTO l_obj_found USING P_Tab_Name;
        IF l_obj_found IS NOT NULL THEN
          --get the main security predicate clause
          L_WHERE_CLAUSE := IGS_SC_GRANTS_PVT.GENERATE_GRANT(P_Tab_name, P_Action );
        ELSE
          FND_MESSAGE.SET_NAME('IGS','IGS_SC_TAB_NOT_REG');
          FND_MESSAGE.SET_TOKEN('OPERATION',l_operation);
          p_msg_data := fnd_message.get;
          RETURN FALSE;
        END IF;
    ELSE
        L_WHERE_CLAUSE := IGS_SC_GRANTS_PVT.GENERATE_GRANT(P_Tab_name, P_Action );
    END IF;

	    --**  Statement level logging.
	    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	      l_label := 'igs.plsql.igs_sc_gen_001.check_sel_upd_del_security';
	      l_debug_str :=  'L_WHERE_CLAUSE is  : '|| L_WHERE_CLAUSE;
	      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	    END IF;
	    --**

    --evaluate the predicated against the passed table.
    IF L_WHERE_CLAUSE IS NOT NULL THEN
       L_SELECT_STMT := 'SELECT 1 FROM '||P_Tab_Name||' WHERE ROWID = :1 AND ('||L_WHERE_CLAUSE||')';

       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_sc_gen_001.check_sel_upd_del_security.finalselect';
          l_debug_str := 'Final Select: '||L_SELECT_STMT;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
       END IF;

       OPEN Grant_cv FOR L_SELECT_STMT USING P_ROWID;
       FETCH Grant_cv INTO l_grant;
       IF Grant_cv%FOUND THEN
          close grant_cv;
          IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
            l_label := 'igs.plsql.igs_sc_gen_001.check_sel_upd_del_security.finalreturn';
            l_debug_str := 'Final Select: TRUE ';
            fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
          END IF;
          RETURN TRUE;
       ELSE
          close grant_cv;
          IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
            l_label := 'igs.plsql.igs_sc_gen_001.check_sel_upd_del_security.finalreturn';
            l_debug_str := 'Final Select: FALSE ';
            fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
          END IF;
          RETURN FALSE;
       END IF;
    ELSE
       RETURN TRUE;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    IF grant_cv%ISOPEN THEN
       close grant_cv ;
    END IF;

    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_gen_001.check_sel_upd_del_security.Exception';
       l_debug_str := 'Exception: '||SQLERRM;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;
    P_MSG_DATA := SQLERRM;
    RETURN FALSE;
END CHECK_SEL_UPD_DEL_SECURITY;

FUNCTION CHECK_PERSON_SECURITY (
 P_Table_Name IN VARCHAR2,
 P_Person_id    IN NUMBER,
 P_Action   IN VARCHAR2, --(S/U - Select/Update)
 P_Msg_data OUT NOCOPY VARCHAR2) -- return the error message in case of any exceptions.
 ------------------------------------------------------------------
  --Updated by  : gmaheswa, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose:main wrapper for person security used by UIs
  --
  --Change History:
------------------------------------------------------------------
RETURN BOOLEAN IS

L_ROWID ROWID;
GET_ROW_ID_CUR varchar2(4000);
TYPE GetRowidCurTyp IS REF CURSOR;
rowid_cv GetRowidCurTyp;
l_msg_data varchar2(4000);
L_WHERE_CLAUSE VARCHAR2(32000);
L_SELECT_STMT  VARCHAR2(32000);

TYPE GetGrantCurTyp IS REF CURSOR;
Grant_cv GetGrantCurTyp;
l_grant VARCHAR2(1);

BEGIN
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_gen_001.check_person_security';
       l_debug_str := 'Table Name: '||P_Table_Name||','||'Person ID: '||P_Person_id||','||'Action: '||P_Action;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

   get_row_id_cur := 'SELECT ROWID FROM '||P_Table_Name||' WHERE PARTY_ID = :P_Person_id';

   OPEN  rowid_cv FOR get_row_id_cur using P_Person_id;
    FETCH rowid_cv INTO L_ROWID;
    IF rowid_cv%NOTFOUND THEN
	    --**  Statement level logging.
       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	     l_label := 'igs.plsql.igs_sc_gen_001.check_person_security';
	     l_debug_str :=  'NON-OSS Person';
	     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	  END IF;
	    --**
       CLOSE    rowid_cv;
       L_WHERE_CLAUSE := IGS_SC_GRANTS_PVT.GENERATE_GRANT(P_Table_Name, P_Action );

	    --**  Statement level logging.
       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	     l_label := 'igs.plsql.igs_sc_gen_001.check_person_security';
	     l_debug_str :=  'L_WHERE_CLAUSE is  : '|| L_WHERE_CLAUSE;
	     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	  END IF;
	    --**
       IF L_WHERE_CLAUSE IS NOT NULL THEN
	     -- As person Security is always evaluated on isg_pe_hz_parties and igs_pe_hz_parties_sv, replace them with igs_pe_person_base_v
          L_WHERE_CLAUSE := replace_string(L_WHERE_CLAUSE,'IGS_PE_HZ_PARTIES.PARTY_ID','IGS_PE_PERSON_BASE_V.PERSON_ID');
	     L_WHERE_CLAUSE := replace_string(L_WHERE_CLAUSE,'IGS_PE_HZ_PARTIES_SV.PARTY_ID','IGS_PE_PERSON_BASE_V.PERSON_ID');
          L_WHERE_CLAUSE := replace_string(L_WHERE_CLAUSE,' PARTY_ID',' PERSON_ID');

          IF L_WHERE_CLAUSE IS NOT NULL THEN
            L_SELECT_STMT := 'SELECT 1 FROM IGS_PE_PERSON_BASE_V WHERE PERSON_ID = :1 AND ('||L_WHERE_CLAUSE||')';

	       --**  Statement level logging.
	       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		     l_label := 'igs.plsql.igs_sc_gen_001.check_person_security';
		     l_debug_str :=  'L_SELECT_STMT is  : '|| L_SELECT_STMT;
		     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		  END IF;
		  --**

            OPEN Grant_cv FOR L_SELECT_STMT USING P_Person_id;
	       FETCH Grant_cv INTO l_grant;
	       IF Grant_cv%FOUND THEN
	          CLOSE grant_cv;
		     --**  Statement level logging.
		     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			     l_label := 'igs.plsql.igs_sc_gen_001.check_person_security';
				l_debug_str :=  'Privilege Exists: Return True';
			     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	  		END IF;
	 	     --**
	          RETURN TRUE;
   	       ELSE
	          CLOSE grant_cv;
		     --**  Statement level logging.
		     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
			     l_label := 'igs.plsql.igs_sc_gen_001.check_person_security';
				l_debug_str :=  'Privilege Does not Exists: Return False';
			     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	  		END IF;
	 	     --**
	          RETURN FALSE;
 	       END IF;
          ELSE
		  --**  Statement level logging.
		  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		     l_label := 'igs.plsql.igs_sc_gen_001.check_person_security';
			l_debug_str :=  'Privilege Exists: Default Policy: Return True';
		     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	  	  END IF;
  	       --**
            RETURN TRUE;
          END IF;
       ELSE
		RETURN TRUE;
       END IF;
    ELSE
       CLOSE    rowid_cv;
       RETURN(CHECK_SEL_UPD_DEL_SECURITY(
		P_Tab_Name =>	P_Table_Name,
		P_Rowid    =>   L_ROWID,
		P_Action   =>	P_Action,
		P_Msg_data =>	p_Msg_data));
    END IF;
EXCEPTION
WHEN OTHERS THEN
    IF rowid_cv%ISOPEN THEN
       CLOSE rowid_cv ;
    END IF;
    IF l_msg_data IS NOT NULL THEN  --exception came from check_sel call
       P_MSG_DATA := l_Msg_data;
    ELSE
       P_MSG_DATA := sqlerrm;  -- couldnt handle the exception.
    END IF;
    RETURN FALSE;

END CHECK_PERSON_SECURITY;

FUNCTION check_user_policy
( P_BUSINESS_OBJECT   IN          varchar2, -- BO name
  P_ACTION            IN          varchar2 , -- S,I,D,U
  P_USER_ID           IN          number DEFAULT NULL) -- fnd user id)
RETURN VARCHAR2 IS
------------------------------------------------------------------
  --Updated by  : ssawhney, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose:required by EN..check whether loged in user has any access on the BO-table
  --
  --Change History:
  --WHO		WHEN		WHAT
  --skpandey    10-JAN-2006     Bug#4937960
  --                            Changed c_user cursor definition to optimize query
------------------------------------------------------------------

l_user_id fnd_user.user_id%type;
l_return varchar2(4000); --incase sql errmr then 4000
l_default IGS_SC_OBJ_GROUPS.default_policy_type%type ;
l_obj_grp_id  IGS_SC_OBJ_GROUPS.obj_group_id%type;
l_role_id NUMBER;

CURSOR c_user (cp_igs varchar, cp_fnd varchar, cp_fnd_user fnd_user.user_id%type) IS
	SELECT role_orig_system_id
	FROM  wf_local_user_roles role, fnd_user use
	WHERE role_orig_system = cp_igs
	AND user_orig_system = cp_fnd
	AND user_orig_system_id  = cp_fnd_user
	AND role.user_name = use.user_name
	AND use.user_id = cp_fnd_user;


CURSOR c_bo (cp_bo_name varchar) IS
SELECT default_policy_type, obj_group_id
FROM IGS_SC_OBJ_GROUPS
WHERE obj_group_name = cp_bo_name;

CURSOR c_policy (cp_role_id NUMBER, cp_bo_id NUMBER) IS
SELECT grant_id,locked_flag ,grant_select_flag,grant_update_flag,grant_insert_flag,grant_delete_flag
FROM IGS_SC_GRANTS
WHERE user_group_id = cp_role_id
AND obj_group_id =cp_bo_id
AND locked_flag= 'Y';

policy_rec c_policy%rowtype;

BEGIN

-- get logged in USER
IF p_user_id IS NULL THEN
   l_user_id := FND_GLOBAL.USER_ID;
ELSE
   l_user_id := p_user_id;
END IF;

OPEN c_bo(p_business_object);
FETCH c_bo INTO l_default, l_obj_grp_id;
CLOSE c_bo;

--get the default policies.
IF l_default ='R' THEN
   l_return := 'DEFAULT_RESTRICT';
ELSE
   l_return := 'DEFAULT_GRANT';
END IF;

--get the policy for the user-role combination
OPEN c_user ('IGS','FND_USR', l_user_id);
FETCH c_user INTO l_role_id;
CLOSE c_user;


OPEN c_policy(l_role_id, l_obj_grp_id);
FETCH c_policy INTO policy_rec;
IF c_policy%NOTFOUND THEN
   CLOSE c_policy;
   RETURN l_return;  --retrun from here..no need to go further this will return default BO.
ELSE
   CLOSE c_policy;
END IF;

IF p_action='S' AND ( policy_rec.grant_select_flag='Y')  THEN
   l_return:= 'POLICY_EXIST';
ELSIF  p_action='I' AND policy_rec.grant_insert_flag='Y' THEN
   l_return:= 'POLICY_EXIST';
ELSIF  p_action='U' AND policy_rec.grant_update_flag='Y' THEN
   l_return:= 'POLICY_EXIST';
ELSIF  p_action='D' AND policy_rec.grant_delete_flag='Y' THEN
   l_return:= 'POLICY_EXIST';
END IF;

RETURN l_return;

EXCEPTION
WHEN OTHERS THEN
     l_return := SQLERRM;
     RETURN l_return;

END check_user_policy;

END IGS_SC_GEN_001;

/
