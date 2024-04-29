--------------------------------------------------------
--  DDL for Package Body IGS_SC_GRANTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SC_GRANTS_PVT" AS
/* $Header: IGSSC01B.pls 120.11 2006/01/27 00:16:18 skpandey noship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Arkadi Tereshenkov

 Date Created By    : Oct-01-2002

 Purpose            : Grant processing package

 remarks            : None

 Change History

Who                   When           What
-----------------------------------------------------------
Arkadi Tereshenkov    Apr-10-2002    New Package created.
mmkumar               05-Jul-2005    Changed the build grant
gmaheswa	      26-Jul-2005    Fnd Logging
******************************************************************/


G_PKG_NAME         CONSTANT VARCHAR2(30) := 'IGS_SC_GRANTS_PVT';
g_debug_level      NUMBER(1) := 0;
g_user_orig_system CONSTANT VARCHAR2(25) := 'FND_USR';
g_alias_number     NUMBER(5) :=0;
g_user_id          NUMBER(14);
g_current_user_id  NUMBER(15);
g_current_party_id NUMBER(15);

--code added by mmkumar
l_grant_text       VARCHAR2(400);
l_bodmas_grant_text  VARCHAR2(400);
p_current_type VARCHAR2(20) := 'START';
p_previous_type VARCHAR2(20) := 'START';
l_string VARCHAR2(400) :='';
l_final_result VARCHAR2(400) := ' ';
l_operator_temp VARCHAR2(10) := '';
onlyZTypeAttributes BOOLEAN := true;
--code added by mmkumar ends

l_prog_label CONSTANT VARCHAR2(500) :='igs.plsql.igs_sc_grants_pvt';
l_label VARCHAR2(4000);
l_debug_str VARCHAR2(32000);

TYPE g_grant_cond_rec IS RECORD (
 obj_attrib_id     igs_sc_grant_conds.obj_attrib_id%TYPE,
 user_attrib_id    igs_sc_grant_conds.user_attrib_id%TYPE,
 condition         igs_sc_grant_conds.condition%TYPE,
 text_value        igs_sc_grant_conds.text_value%TYPE,
 user_attrib_value igs_sc_usr_att_vals.attr_value%TYPE,
 obj_attrib_value  igs_sc_obj_att_vals.attr_value%TYPE,
 cond_text         VARCHAR2(2000),
 z_typ_flag        VARCHAR2(1) --mmkumar
);


TYPE g_grant_conds_t IS TABLE OF g_grant_cond_rec  INDEX BY BINARY_INTEGER;



TYPE g_object_rec IS RECORD
( obj_group_id     igs_sc_objects.obj_group_id%TYPE,
  object_id        igs_sc_objects.object_id%TYPE,
  table_name       fnd_objects.database_object_name%TYPE,
  default_policy_type   igs_sc_obj_groups.default_policy_type%TYPE,
  pk1_column_name  fnd_objects.pk1_column_name%TYPE,
  pk2_column_name  fnd_objects.pk2_column_name%TYPE,
  pk3_column_name  fnd_objects.pk3_column_name%TYPE,
  pk4_column_name  fnd_objects.pk4_column_name%TYPE,
  pk5_column_name  fnd_objects.pk5_column_name%TYPE,
  pk1_column_type  fnd_objects.pk1_column_type%TYPE,
  pk2_column_type  fnd_objects.pk2_column_type%TYPE,
  pk3_column_type  fnd_objects.pk3_column_type%TYPE,
  pk4_column_type  fnd_objects.pk4_column_type%TYPE,
  pk5_column_type  fnd_objects.pk5_column_type%TYPE

);

TYPE g_grant_rec IS RECORD
( grant_id     igs_sc_grants.grant_id%TYPE,
  grant_text   igs_sc_grants.grant_text%TYPE
);



PROCEDURE Put_Log_Msg (
   p_message IN VARCHAR2,
   p_level   IN NUMBER
);

PROCEDURE insert_user_attrib(
  p_user_id          IN NUMBER  ,
  p_party_id         IN NUMBER ,
  p_user_attrib_id   IN NUMBER  ,
  p_user_attrib_name IN VARCHAR2,
  p_user_attrib_type IN VARCHAR2,
  p_static_type      IN VARCHAR2,
  p_select_text      IN VARCHAR2
);


PROCEDURE build_grant(
  p_group_rec    IN OUT NOCOPY g_object_rec,
  p_grants_rec   IN OUT NOCOPY g_grant_rec
) ;

--added by mmkumar
FUNCTION isSingleGrantCond(p_grant_text VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  IF (INSTR(UPPER(p_grant_text),'OR') > 0 OR INSTR(UPPER(p_grant_text),'AND') > 0) THEN
      RETURN false;
  ELSE
      RETURN true;
  END IF;
END isSingleGrantCond;

FUNCTION get_alias
RETURN VARCHAR2
IS
BEGIN

  g_alias_number :=g_alias_number+1;
  RETURN 'sc'||g_alias_number;

END get_alias;

--added by mmkumar
FUNCTION isAnotherOperand(p_cond VARCHAR2, loc NUMBER) RETURN BOOLEAN IS
BEGIN
  IF INSTR(SUBSTR(p_cond,loc), ':') >= 1 THEN
       RETURN true;
  ELSE
       RETURN false;
  END IF;
END isAnotherOperand;

--added by mmkumar
PROCEDURE handler(p_char VARCHAR2,p_cond VARCHAR2, loc NUMBER) is
	p_temp VARCHAR2(10) := '';
BEGIN
  IF p_char IN ('A' , 'N' , 'D' , 'O' , 'R') THEN
       IF p_char IN ('A', 'O') THEN
	    l_operator_temp := '';
       END IF;
       l_operator_temp := l_operator_temp || p_char;
  ELSE
       IF p_char IN (':','(') THEN
	    if TRIM(l_operator_temp) IN ('AND','OR') and p_current_type = 'OPERAND' then
		 IF isAnotherOperand(l_string,loc) THEN
			 l_final_result := l_final_result || ' ' ||  l_operator_temp || ' ';
			 p_previous_type := p_current_type;
			 p_current_type := 'OPERATOR';
		 END IF;
	    end if;
	    l_operator_temp := '';
	    IF p_char = ':' THEN
		 p_previous_type := p_current_type;
		 p_current_type := 'OPERAND';
	    END IF;
	    l_final_result := l_final_result || p_char;
       ELSIF  p_char <> ' ' THEN
	    l_final_result := l_final_result || p_char;
       END IF;
  END IF;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.handler.end';
       l_debug_str := 'Final Result :'|| l_final_result;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

END handler;

--added by mmkumar
FUNCTION getBodmasCondition(p_cond VARCHAR2) RETURN VARCHAR2
IS
   --l_string VARCHAR2(400);
   l_current_index number := 1;
   l_single_char VARCHAR2(1) := 'Q';
   l_current_type VARCHAR2(20) := 'START';
   l_result VARCHAR2(400);
BEGIN
  l_final_result := '';
  --l_string := REPLACE(UPPER(p_cond),':Z','');
  l_string := UPPER((p_cond));
  l_single_char := SUBSTR(l_string,l_current_index,1);
  l_operator_temp := '';
  p_current_type := 'START';
  p_previous_type := 'START';

  LOOP
     IF l_single_char = '' OR l_single_char = 'Q' or l_single_char is null THEN
       EXIT;
     END IF;
     handler(l_single_char,l_string,l_current_index);
     l_current_index := l_current_index + 1;
     l_single_char := SUBSTR(l_string,l_current_index,1);
  END LOOP;
  return replace(l_final_result,'()','');
END getBodmasCondition;


PROCEDURE set_ctx(
  p_name VARCHAR2,
  p_val  VARCHAR2
)
IS
BEGIN
  dbms_session.set_context( 'igsscctx', p_name, p_val );
END set_ctx;

-- This function checks if we need to transform operation for user attribute to the opposite

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


FUNCTION replace_string(
  p_string       IN VARCHAR2,
  p_from_pattern IN VARCHAR2,
  p_to_pattern   IN VARCHAR2
) RETURN VARCHAR2
IS

 l_out_string   VARCHAR2(4000);
 l_upper_string VARCHAR2(4000);
 l_occurence    NUMBER(10) := 0;
 l_len          NUMBER(5);

BEGIN

  IF upper(p_from_pattern) = upper(p_to_pattern) THEN

    --check for being the same value, infinite loop
    RETURN p_string;

  END IF;

  -- delete all values for the current user

  l_out_string := p_string;
  l_upper_string := UPPER(l_out_string);

  l_len := length(p_from_pattern);

  l_occurence := INSTR(l_upper_string,p_from_pattern,1,1);

  LOOP

    IF l_occurence = 0 THEN
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

FUNCTION check_grant_text (
  p_table_name VARCHAR2,
  p_select_text VARCHAR2)
RETURN BOOLEAN IS
 l_api_name       CONSTANT VARCHAR2(30)   := 'CHECK_GRANT_TEXT';
 l_val NUMBER(20);
 l_select_text VARCHAR(32000);
BEGIN
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.check_grant_text.begin';
       l_debug_str := 'Table Name: '||p_table_name||','||'Select Text: '||p_select_text;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

   l_select_text := replace_string(ltrim(p_select_text),':PARTY_ID','igs_sc_vars.get_partyid');

   l_select_text := replace_string(ltrim(l_select_text),':USER_ID','igs_sc_vars.get_userid');

   l_select_text := replace_string(ltrim(l_select_text),':TBL_ALIAS','tstal');

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.check_grant_text.before_execute';
       l_debug_str := 'Final Select: '||'SELECT 1 FROM ('||' SELECT 1 FROM '||p_table_name||' WHERE '||l_select_text||' )';
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

   -- EXECUTE IMMEDIATE 'SELECT count(*) FROM ('||' SELECT 1 FROM '||p_table_name||' WHERE '||l_select_text||' )'
   --simrans change
    EXECUTE IMMEDIATE 'SELECT 1 FROM ('||' SELECT 1 FROM '||p_table_name||' WHERE '||l_select_text||' )' ;
   --INTO l_val;

   RETURN TRUE;

EXCEPTION
 WHEN OTHERS THEN

   -- add error to the stack and return false
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.check_grant_text.execption';
       l_debug_str := 'Exception: '||SQLERRM;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

   FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);

   RETURN FALSE;

END check_grant_text;

PROCEDURE construct_grant(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_grant_id          IN   NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
)
IS


 l_api_name       CONSTANT VARCHAR2(30)   := 'CONSTRUCT_GRANT';
 l_api_version    CONSTANT NUMBER         := 1.0;
 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_group_rec    g_object_rec;
 l_grant_rec    g_grant_rec;
 l_user_id      NUMBER(15);
 l_stat_found   BOOLEAN := false;
 l_alias_name   VARCHAR2(8);
 l_grant_where  VARCHAR2(4000);

--skpandey, Bug#4937960: Changed c_group cursor definition to optimize query
  -- Object data cursor
  CURSOR c_group(cp_grant_id igs_sc_grants.grant_id%TYPE) IS
    SELECT sco.obj_group_id,
           sco.object_id,
           fnd.obj_name,
           grp.default_policy_type,
           pk1_column_name  ,
           pk2_column_name  ,
           pk3_column_name  ,
           pk4_column_name  ,
           pk5_column_name  ,
	   pk1_column_type  ,
           pk2_column_type  ,
           pk3_column_type  ,
           pk4_column_type  ,
           pk5_column_type
      FROM igs_sc_objects sco,
           fnd_objects fnd,
           igs_sc_grants grn,
           igs_sc_obj_groups grp
     WHERE  (application_id  IN (8405,8406))
            AND fnd.object_id = sco.object_id
            AND sco.obj_group_id = grn.obj_group_id
            AND grn.grant_id = cp_grant_id
            AND grp.obj_group_id = grn.obj_group_id
	    AND sco.active_flag = 'Y';


   -- Returns all grants for a given user and object group

   CURSOR c_grants IS
     SELECT grant_id,
            grant_text
       FROM igs_sc_grants gr
      WHERE grant_id = p_grant_id;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     construct_grant;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- API body
  OPEN c_grants;
  FETCH c_grants INTO l_grant_rec;
  CLOSE c_grants;

  FOR c_group_rec IN c_group(p_grant_id) LOOP

    -- Construct grant for each object in the grant group

    Put_Log_Msg ('Generating grant for object: '||c_group_rec.object_id,0);

    build_grant (c_group_rec, l_grant_rec);

  END LOOP;


  -- End of API body.
  -- Standard check of p_commit.

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO construct_grant;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO construct_grant;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO construct_grant;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );


END construct_grant;




PROCEDURE generate_grant(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_object_name       IN   VARCHAR2,
  p_function_type     IN   VARCHAR2,
  x_where_clause      OUT NOCOPY VARCHAR2,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
)
IS


 l_api_name       CONSTANT VARCHAR2(30)   := 'GENERATE_GRANT';
 l_api_version    CONSTANT NUMBER         := 1.0;
 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);


BEGIN

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_where_clause:= generate_grant (
     p_object_name => p_object_name,
     p_function_type => p_function_type);

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.generate_grant';
       l_debug_str := 'Table Name: '||p_object_name||','||' Function type: '||p_function_type||','
			||'Pridicate Where Clause: '||x_where_clause;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

  -- API body


  -- End of API body.
  -- Standard check of p_commit.

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.generate_grant.ex_error';
       l_debug_str := 'Handled Exception: Table Name: '||p_object_name||','||' Function type: '||p_function_type||','
			||'Error Message: '||x_msg_data;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.generate_grant.ex_un';
       l_debug_str := 'Unhandled Exception: Table Name: '||p_object_name||','||' Function type: '||p_function_type||','
			||'Error Message: '||x_msg_data;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

  WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.generate_grant.ex_other';
       l_debug_str := 'Other Exceptions: Table Name: '||p_object_name||','||' Function type: '||p_function_type||','
			||'Error Message: '||x_msg_data;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

END generate_grant;

PROCEDURE build_grant(
  p_group_rec    IN OUT NOCOPY g_object_rec,
  p_grants_rec   IN OUT NOCOPY g_grant_rec
)
IS
  l_statment     VARCHAR2(4000);   -- Grant statment
  l_stat_found   BOOLEAN := false;
  l_grant_cond   g_grant_conds_t;
  l_user_attrib  igs_sc_usr_attribs%ROWTYPE;
  l_obj_attrib   igs_sc_obj_att_mths%ROWTYPE;
  l_cur_pos      NUMBER(10);
  l_found_pos    NUMBER(10);
  l_cur_num      NUMBER(1);
  l_alias_name   VARCHAR2(8);
  l_part_grant   VARCHAR2(4000);
  l_part_grant2  VARCHAR2(4000);
  l_attr_select  VARCHAR2(4000);
  l_usr_select   VARCHAR2(4000);
  l_obj_select   VARCHAR2(4000);
  l_obj_const    VARCHAR2(4000);
  l_usr_const    VARCHAR2(4000);
  l_obj_alias    VARCHAR2(25);
  l_usr_alias    VARCHAR2(25);
  l_column_name  VARCHAR2(255);


  l_post_grant   VARCHAR2(255);


   -- Select of all conditions for a grant

  CURSOR c_grant_where (s_grant_id NUMBER, s_obj_id NUMBER) IS
    SELECT grant_where
      FROM igs_sc_obj_grants
     WHERE object_id = s_obj_id
           AND grant_id = s_grant_id;
       --FOR UPDATE OF grant_where;

  CURSOR c_grant_cond (s_grant_id NUMBER )IS
    SELECT grant_id,
           grant_cond_num,
           obj_attrib_id,
           user_attrib_id,
           condition,
           text_value
      FROM igs_sc_grant_conds
     WHERE grant_id = s_grant_id;

  CURSOR c_user_attrib (s_attrib_id NUMBER) IS
    SELECT *
      FROM igs_sc_usr_attribs
     WHERE user_attrib_id = s_attrib_id;

  CURSOR c_obj_attrib (s_attrib_id NUMBER, s_object_id NUMBER) IS
    SELECT *
      FROM igs_sc_obj_att_mths
     WHERE obj_attrib_id = s_attrib_id
           AND object_id = s_object_id;

  l_table_column VARCHAR2(30);

BEGIN

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.begin';
       l_debug_str := 'Grant ID: '||p_grants_rec.grant_id||','||' Grant text: '||p_grants_rec.grant_text;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

   onlyZTypeAttributes := TRUE;

   Put_Log_Msg ('Grant found: '||p_grants_rec.grant_id,0);
   Put_Log_Msg ('Grant text: '||p_grants_rec.grant_text,0);

   -- For each condition in grant
   --code added by mmkumar
   FOR c_grant_cond_rec IN c_grant_cond(p_grants_rec.grant_id) LOOP
          IF c_grant_cond_rec.obj_attrib_id  IS NOT NULL THEN
               OPEN c_obj_attrib ( c_grant_cond_rec.obj_attrib_id ,p_group_rec.object_id );
               FETCH c_obj_attrib INTO l_obj_attrib;

	       IF c_obj_attrib%NOTFOUND THEN
	            -- Method for the table not found
	            close c_obj_attrib;
                    FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_MTHD_NOT_FOUND');
                    FND_MESSAGE.SET_TOKEN('ATTRIB_ID',  l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id);
                    FND_MESSAGE.SET_TOKEN('TABLE_NAME',p_group_rec.table_name );
                    FND_MSG_PUB.Add;

                    RAISE FND_API.G_EXC_ERROR;

               ELSIF l_obj_attrib.NULL_ALLOW_FLAG IN ('Y','N') THEN
	            onlyZTypeAttributes  := false;
	            close c_obj_attrib;
	            EXIT;
	       END IF;

	       if c_obj_attrib%isopen then
                    close c_obj_attrib;
               end if;
          END IF;
   END LOOP;
   --code added by mmkumar ends

   FOR c_grant_cond_rec IN c_grant_cond(p_grants_rec.grant_id) LOOP

    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.grant_cond_loop';
       l_debug_str := 'Condition Number: '||c_grant_cond_rec.grant_cond_num||','||'Object Attribute ID: '||c_grant_cond_rec.obj_attrib_id
		      ||','||'User Attrib ID: '||c_grant_cond_rec.user_attrib_id||','||'Condition Text Value: '||c_grant_cond_rec.text_value;
       fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

     Put_Log_Msg ('|  Condition found: '||c_grant_cond_rec.grant_cond_num,0);

     l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id  := c_grant_cond_rec.obj_attrib_id;
     l_grant_cond(c_grant_cond_rec.grant_cond_num).user_attrib_id := c_grant_cond_rec.user_attrib_id;
     l_grant_cond(c_grant_cond_rec.grant_cond_num).condition      := c_grant_cond_rec.condition;
     l_grant_cond(c_grant_cond_rec.grant_cond_num).text_value     := c_grant_cond_rec.text_value;
     l_obj_select := '';
     l_usr_select := '';
     l_obj_const  := '';
     l_usr_const  := '';
     l_obj_alias := 'sc'||p_grants_rec.grant_id||'o'||c_grant_cond_rec.grant_cond_num||'a';
     l_usr_alias := 'sc'||p_grants_rec.grant_id||'u'||c_grant_cond_rec.grant_cond_num||'a';

     -- Construct condition grant

     IF l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id  IS NOT NULL THEN
       -- Process object attribute

       -- Fetch definition

       OPEN c_obj_attrib ( l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id ,p_group_rec.object_id );
       FETCH c_obj_attrib INTO l_obj_attrib;

       IF c_obj_attrib%NOTFOUND THEN

          -- Method for the table not found
          CLOSE c_obj_attrib;
          FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_MTHD_NOT_FOUND');
          FND_MESSAGE.SET_TOKEN('ATTRIB_ID',  l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id);
          FND_MESSAGE.SET_TOKEN('TABLE_NAME',p_group_rec.table_name );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

       END IF;


       CLOSE c_obj_attrib;

       Put_Log_Msg ('|    Attribute fetched: '||l_obj_attrib.obj_attrib_id||' '||l_obj_attrib.obj_attrib_type ,0);
       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.grant_attrib';
         l_debug_str := 'Attribute fetched: '||l_obj_attrib.obj_attrib_id||','||l_obj_attrib.obj_attrib_type ;
         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
       END IF;

	  --code added by mmkumar
	  l_grant_cond(c_grant_cond_rec.grant_cond_num).z_typ_flag := l_obj_attrib.NULL_ALLOW_FLAG;
	  --

       --  T Table column name, S select statement, F - function call

       IF  l_obj_attrib.obj_attrib_type = 'T' THEN

         -- If attribute column name -then just add column name to the grant text
         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_obj_attrib.select_text||' ';

	 l_table_column := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text;

       ELSIF  l_obj_attrib.obj_attrib_type = 'F' THEN

         l_obj_const := l_obj_attrib.select_text;

       ELSIF l_obj_attrib.obj_attrib_type IN ('M','S') AND l_obj_attrib.static_type IN ('S','D') THEN

         -- Replace table alias value with our alias, generated based on attribute id

         l_obj_select := replace_string(ltrim(l_obj_attrib.select_text),':TBL_ALIAS',l_obj_alias);


       ELSIF l_obj_attrib.obj_attrib_type IN ('S','F') AND l_obj_attrib.static_type IN ('C') THEN

         -- Attribute static and Select or function type - use select from attributes table
         -- final will look like  (pk_column1,pk_column2,..) IN
         --   (select pk1_value,pk2_value,.. from igs_sc_obj_att_vals where object_id= ..
         --    AND obj_attrib_id = ... AND value =..)
         -- Construct first part with PK
         l_alias_name := get_alias;

         l_part_grant :=  '('||p_group_rec.pk1_column_name;
         l_part_grant2 := ') IN ( SELECT '||l_alias_name||'.pk1_value';

         -- Check if more then one PK column is present

         IF p_group_rec.pk2_column_name IS NOT NULL THEN
           l_part_grant := l_part_grant|| ','||p_group_rec.pk2_column_name;
           l_part_grant2 := l_part_grant2||','||l_alias_name||'.pk2_value';

           IF p_group_rec.pk3_column_name IS NOT NULL THEN
             l_part_grant := l_part_grant|| ','||p_group_rec.pk2_column_name;
             l_part_grant2 := l_part_grant2||','||l_alias_name||'.pk2_value';

             IF p_group_rec.pk4_column_name IS NOT NULL THEN
               l_part_grant := l_part_grant|| ','||p_group_rec.pk2_column_name;
               l_part_grant2 := l_part_grant2||','||l_alias_name||'.pk2_value';

               IF p_group_rec.pk5_column_name IS NOT NULL THEN
                 l_part_grant := l_part_grant|| ','||p_group_rec.pk2_column_name;
                 l_part_grant2 := l_part_grant2||','||l_alias_name||'.pk2_value';

               END IF;

             END IF;

           END IF;

         END IF;


         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_part_grant||l_part_grant2||' FROM igs_sc_obj_att_vals '||l_alias_name
             ||' WHERE '||l_alias_name||'.object_id='||p_group_rec.object_id
             ||' AND '||l_alias_name||'.obj_attrib_id='||l_grant_cond(c_grant_cond_rec.grant_cond_num).obj_attrib_id ||' AND '
             ||l_alias_name||'.attr_value '||l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' ';

         l_post_grant := ')';

       ELSE -- F

          -- Not supported combination
          FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_NOT_SPRT_COMB');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

       END IF;

       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.condition_text';
         l_debug_str := 'Attribute condition: '||l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text ;
         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
       END IF;

       Put_Log_Msg ('|    Attribute condition: '|| l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text,0);

     ELSE  --Add Text instead of parameter

       l_obj_const :=l_grant_cond(c_grant_cond_rec.grant_cond_num).text_value;

     END IF;

     IF c_grant_cond_rec.user_attrib_id IS NOT NULL THEN

       -- read attribute definition
       OPEN c_user_attrib ( l_grant_cond(c_grant_cond_rec.grant_cond_num).user_attrib_id );
       FETCH c_user_attrib INTO l_user_attrib;
       CLOSE c_user_attrib;

       Put_Log_Msg ('|    User Attribute found: '|| l_grant_cond(c_grant_cond_rec.grant_cond_num).user_attrib_id ,0);

       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.user_attrib';
         l_debug_str := ' User Attribute found: '||l_grant_cond(c_grant_cond_rec.grant_cond_num).user_attrib_id ;
         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
       END IF;


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

       Put_Log_Msg ('|    Attribute condition: '|| l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text ,0);

     ELSE  --Add Text instead of parameter

           l_usr_const := l_grant_cond(c_grant_cond_rec.grant_cond_num).text_value;

     END IF; -- User parameter id null

     -- l_usr_const, l_obj_const - function or text value of any kind
     -- l_obj_select, l_usr_select - select statments.

     -- Add post grant condition

     IF l_obj_select IS NULL THEN
--        --code added my mmkumar
          IF l_obj_attrib.NULL_ALLOW_FLAG = 'Z' THEN
	       --IF isSingleGrantCond(p_grants_rec.grant_text) THEN
	       IF onlyZTypeAttributes THEN
                    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' 1=1 ';
	       ELSE
                    NULL;
	       END IF;

	       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	         l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.Obj_select_1';
		 l_debug_str := ' Object select NULL, and Z type attrib. Condition text '||l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text ;
	         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	       END IF;


          ELSE
	  --code added by mmkumar ends
	  -- its not Z
               IF  l_obj_const IS NOT NULL AND l_usr_select IS NOT NULL THEN
                    -- User attribute is select of any kind and object attribute is not select
		    -- User Select = Obj CONST
                    l_found_pos := INSTR(UPPER(ltrim(l_usr_select)),'FROM',1,1);
                    l_column_name := substr(ltrim(l_usr_select),8,l_found_pos-9); -- 8 position 'select ' found -9 ' FROM'

                    --grant text ' EXISTS (object_select AND Column Condition ( user attrr select))

                    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text
                         ||' EXISTS ('||l_usr_select||' AND '||l_column_name||' '||check_operation(l_grant_cond(c_grant_cond_rec.grant_cond_num).condition)||' '||l_obj_const||' )';

               ELSIF l_obj_const IS NULL  AND l_usr_select IS NOT NULL THEN
                    -- Colunmn name = User Select
                    IF l_obj_attrib.NULL_ALLOW_FLAG = 'Y' THEN -- Nullable column
	                 l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := '('||l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' '||
                         l_grant_cond(c_grant_cond_rec.grant_cond_num).condition ||' (' ||l_usr_select||') OR '||l_table_column ||' IS NULL) '||l_post_grant;
	            ELSE
               	         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' '||
                         l_grant_cond(c_grant_cond_rec.grant_cond_num).condition ||' (' ||l_usr_select||')'||l_post_grant;
                    END IF;
               ELSIF  l_obj_const IS NULL  AND l_usr_select IS NULL THEN
                    -- Column name = User CONST
                    IF l_obj_attrib.NULL_ALLOW_FLAG = 'Y' THEN -- Nullable column
                         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := '('||l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' '||
                         l_obj_const||' '||l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' '||l_usr_const||' OR '||l_table_column ||' IS NULL)'||l_post_grant;
                    ELSE
                         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' '||
                         l_obj_const||' '||l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' '||l_usr_const||l_post_grant;
	            END IF;
               ELSE
                    -- Object Const = User CONST
                    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' '||
                    l_obj_const||' '||l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' '||l_usr_const||l_post_grant;

               END IF;

	       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	         l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.Obj_select_2';
		 l_debug_str := ' Object select is NULL. Non Z. Grant condition text '||l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text ;
	         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	       END IF;
          END IF; --mmkumar
     ELSE --Object select is not null

          -- we need to change select so we'll have 2 select statments


          --find the name of the select coulmn for attribute
          l_found_pos := INSTR(UPPER(ltrim(l_obj_select)),'FROM',1,1);
          l_column_name := substr(ltrim(l_obj_select),8,l_found_pos-9); -- 8 position 'select ' found -9 ' FROM'
          --grant text ' EXISTS (object_select AND Column Condition ( user attrr select))

          --code added my mmkumar
          IF l_obj_attrib.NULL_ALLOW_FLAG = 'Z' THEN
	       --IF isSingleGrantCond(p_grants_rec.grant_text) THEN
	       IF onlyZTypeAttributes THEN
	            l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text :=  l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' 1=1 ';
               ELSE
	            NULL;
	       END IF;

	       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	         l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.Obj_select_3';
		 l_debug_str := ' Object select NOT NULL, and Z type attrib. Condition text '||l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text ;
	         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	       END IF;

	  ELSE
  	  -- its not Z
--
               IF l_usr_select IS NOT NULL THEN
                    --Add user select
                    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' EXISTS ('||l_obj_select||' AND '||l_column_name||' '||
                    l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' ('||l_usr_select||' )';
               ELSE  --Add user constant
                    IF l_grant_cond(c_grant_cond_rec.grant_cond_num).condition IS NULL THEN
                         --operator in the grant text - don't add anything but Object select
                         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_obj_select;
                    ELSE
                         l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text := l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' EXISTS ('||l_obj_select||' AND '||l_column_name||' '||
                         l_grant_cond(c_grant_cond_rec.grant_cond_num).condition||' '||l_usr_const;
                    END IF;
               END IF;

               IF l_obj_attrib.NULL_ALLOW_FLAG = 'Y' THEN
                    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text :=  l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||' OR NOT EXISTS (' ||l_obj_select||'))';
               ELSE
                    l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text :=  l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text||')';
               END IF;

	       IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	         l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.Obj_select_4';
		 l_debug_str := ' Object select NOT NULL, and Non Z type attrib. Condition text '||l_grant_cond(c_grant_cond_rec.grant_cond_num).cond_text ;
	         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	       END IF;
          END IF; --mmkumar
     END IF;

   END LOOP;


   Put_Log_Msg ('|  Analyzing grant structure, current grant: '|| l_statment ,0);


   --code added by mmkumar
   l_cur_pos :=1;
   l_found_pos := 0;

   l_grant_text := p_grants_rec.grant_text;
   LOOP
     l_found_pos := INSTR(l_grant_text,':',l_cur_pos,1);

     IF l_found_pos =0 THEN -- End loop no occurences found anymore
          EXIT;
     END IF;

     Put_Log_Msg ('|  Found new condition, at position: '|| l_found_pos ,0);

     -- Find number of predicate - total numbers is limited to 9 so far.

     l_cur_num := SUBSTR(l_grant_text,l_found_pos+1,1);  --Just one character
     IF l_grant_cond(l_cur_num).z_typ_flag = 'Z' AND NOT onlyZTypeAttributes THEN
          l_grant_text :=  REPLACE(l_grant_text, ':' || l_cur_num,'');
     END IF;
     l_cur_pos := l_found_pos + 2;
   END LOOP;

     l_bodmas_grant_text := getBodmasCondition(l_grant_text);

     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	         l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant.bodmas_return_1';
		 l_debug_str := '  Grant text after Bodmas call '||l_bodmas_grant_text ;
	         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

     --  Analize grant structure and construct grant, example  "(:1 AND (:2 OR :3))"
     l_cur_pos :=1;
     l_found_pos := 0;
     -- First pass - check if there is anything before the first grant condition
     l_found_pos := INSTR(l_bodmas_grant_text,':',l_cur_pos,1);

     IF l_found_pos >1 THEN
          IF l_statment IS NOT NULL THEN -- not first grant, we need to  add OR
               l_statment := l_statment||' OR ';
          END IF;

          -- concatenate with previous statment and add first part of condition text
          --  l_statment := l_statment||substr(p_grants_rec.grant_text,1,l_found_pos-1);
          Put_Log_Msg ('  First part added, current grant: '|| l_statment ,0);

     END IF;

    --     IF onlyZTypeAttributes THEN
    --        l_statment := l_statment||'1=1';
    -- ELSE

          LOOP
               -- Find next occurence of :
               l_found_pos := INSTR(l_bodmas_grant_text,':',l_cur_pos,1);
               IF l_found_pos =0 THEN -- End loop no occurences found anymore
                    EXIT;
               END IF;

	       IF l_grant_cond(l_cur_num).z_typ_flag = 'Z' AND onlyZTypeAttributes THEN
     	            l_statment := l_statment || '1 = 1';
	            EXIT;
	       END IF;

               Put_Log_Msg ('|  Found new condition, at position: '|| l_found_pos ,0);
               -- Find number of predicate - total numbers is limited to 9 so far.
               l_cur_num := SUBSTR(l_bodmas_grant_text,l_found_pos+1,1);  --Just one character
               l_statment := l_statment||SUBSTR(l_bodmas_grant_text,l_cur_pos, (l_found_pos - l_cur_pos));
               Put_Log_Msg ('|  New statment: '|| l_statment ,0);

               -- Add condition from found grant number to statement
               l_statment := l_statment || l_grant_cond(l_cur_num).cond_text;
               Put_Log_Msg ('|  Statment with condition added: '|| l_statment ,0);

	       l_cur_pos := l_found_pos + 2;

          END LOOP;
          -- Add last part of condition
	  IF NOT (l_grant_cond(l_cur_num).z_typ_flag = 'Z' AND onlyZTypeAttributes) THEN
               l_statment := l_statment||substr(l_bodmas_grant_text,l_cur_pos);
          END IF;

          Put_Log_Msg ('|  Last part of condition added: '|| l_statment ,0);
     --END IF; --mmkumar

   --code added by mmkumar ends

   --gmaheswa fnd logging
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_grants_pvt.build_grant_end';
       l_debug_str := 'Final where Clause: Table Name: '||p_group_rec.table_name||','||'Pridicate Where: '||l_statment;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;



   --check grant text
   IF NOT check_grant_text ( p_group_rec.table_name, l_statment) THEN

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRNT_TXT_ERR');
          FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_group_rec.table_name );
          FND_MESSAGE.SET_TOKEN('GRNT_TEXT', l_statment);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

   END IF;


   -- Insert or update grant for an object

   IF l_statment IS NULL THEN

      DELETE FROM igs_sc_obj_grants
       WHERE object_id = p_group_rec.object_id AND grant_id = p_grants_rec.grant_id;

   END IF;

   OPEN c_grant_where( p_grants_rec.grant_id,p_group_rec.object_id) ;
   FETCH c_grant_where INTO l_part_grant;

   IF c_grant_where%NOTFOUND THEN

     -- Insert new row
     INSERT INTO igs_sc_obj_grants (
           grant_id,
           object_id,
           grant_where,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login)
         VALUES (
           p_grants_rec.grant_id,
           p_group_rec.object_id,
           l_statment,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1) ) ;
   ELSE
     null; --simran
     --update existing
     -- UPDATE igs_sc_obj_grants SET grant_where = l_statment WHERE CURRENT OF c_grant_where;

   END IF;

   CLOSE c_grant_where;

END build_grant ;


/* This function concatenates all grants for a given user using link between groups and users.*/

FUNCTION generate_grant(
  p_object_name       IN   VARCHAR2,
  p_function_type     IN   VARCHAR2
) RETURN VARCHAR2
IS
  l_statment     VARCHAR2(32000);   -- Grant statment
  l_group_rec    g_object_rec;
  l_user_id      NUMBER(15);
  l_stat_found   BOOLEAN := false;
  l_alias_name   VARCHAR2(8);

--skpandey, Bug#4937960: Changed c_group cursor definition to optimize query
 -- Object data cursor
  CURSOR c_group(cp_obj_name fnd_objects.obj_name%TYPE) IS
    SELECT sco.obj_group_id,
           sco.object_id,
           fnd.obj_name,
           grp.default_policy_type,
           pk1_column_name  ,
           pk2_column_name  ,
           pk3_column_name  ,
           pk4_column_name  ,
           pk5_column_name  ,
           pk1_column_type  ,
           pk2_column_type  ,
           pk3_column_type  ,
           pk4_column_type  ,
           pk5_column_type
      FROM igs_sc_objects sco,
           fnd_objects fnd,
           igs_sc_obj_groups grp
     WHERE  application_id  IN (8405,8406)
            AND fnd.obj_name = cp_obj_name
            AND grp.obj_group_id = sco.obj_group_id
            AND fnd.object_id = sco.object_id;

   -- Returns all grants for a given user and object group

   CURSOR c_grants (s_group_id NUMBER,s_object_id NUMBER, s_user_id NUMBER) IS
     SELECT gr.grant_id,
            objgr.grant_where
       FROM igs_sc_grants gr,
            igs_sc_obj_grants objgr,
            wf_local_user_roles rls
      WHERE rls.user_orig_system =g_user_orig_system
            AND rls.user_orig_system_id = s_user_id
            AND rls.role_orig_system = 'IGS'
            AND rls.role_orig_system_id = gr.user_group_id
            AND objgr.object_id = s_object_id
            AND objgr.grant_id = gr.grant_id
            AND SYSDATE BETWEEN NVL(rls.start_date,sysdate-1) AND NVL(rls.expiration_date,sysdate+1)
            AND gr.obj_group_id = s_group_id
            AND gr.locked_flag ='Y'
            AND decode(p_function_type,'S',gr.grant_select_flag,'I',gr.grant_insert_flag,'D',gr.grant_delete_flag,'U',gr.grant_update_flag,'N')='Y';

   CURSOR c_def_grant (s_group_id NUMBER,s_object_id NUMBER) IS
     SELECT objgr.grant_where
       FROM igs_sc_grants gr,
            igs_sc_obj_grants objgr
      WHERE objgr.object_id = s_object_id
            AND objgr.grant_id = gr.grant_id
            AND gr.obj_group_id = s_group_id
            AND gr.locked_flag ='Y'
            AND upper(gr.grant_name)='DEFAULT';


BEGIN

 --gmaheswa fnd logging
 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sc_grants_pvt.generate_grant.local';
     l_debug_str := 'Table Name: '||p_object_name||','||'Function Type: '||p_function_type;
     fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
 END IF;

 g_alias_number :=0;
 l_user_id := igs_sc_vars.get_userid;
 g_user_id := l_user_id;
 -- Check if object exists in the tables and assigned to a group


 OPEN c_group(p_object_name);
 FETCH c_group INTO l_group_rec;

 IF c_group%NOTFOUND THEN

   -- Object is not found - return exception
   CLOSE c_group;

   FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_NO_OBJECT_FOUND');
   FND_MSG_PUB.Add;

   -- Return nothing ofr a table
   RAISE FND_API.G_EXC_ERROR;

 END IF;

 -- Find all grant Ids for all groups user belongs to


 CLOSE c_group;

 -- Check for each group grants

 IF l_user_id = -1 THEN
   -- Apply default grant, if found

   IF p_function_type = 'S' THEN
     -- Select only operation. If others - don't do anything
     OPEN  c_def_grant (l_group_rec.obj_group_id,l_group_rec.object_id) ;
     FETCH c_def_grant INTO l_statment;
     CLOSE c_def_grant;

     IF l_statment IS NOT NULL THEN
       l_stat_found := true;
     END IF;

   END IF;

 ELSE

   FOR c_grants_rec IN c_grants(l_group_rec.obj_group_id,l_group_rec.object_id,l_user_id) LOOP

     l_stat_found := true;

     Put_Log_Msg ('Grant found: '||c_grants_rec.grant_id,0);
     Put_Log_Msg ('Grant text: '||c_grants_rec.grant_where,0);

     -- Add last part of condition
     IF l_statment IS  NULL THEN

       l_statment :=c_grants_rec.grant_where;

     ELSE

       l_statment := l_statment||' OR '||c_grants_rec.grant_where;

     END IF;

     Put_Log_Msg ('|  Condition added: '|| l_statment ,0);

   END LOOP;

 END IF;

 IF NOT(l_stat_found) THEN

   -- Nothing is granted for a group. Apply default policy

    -- Default policy G - grant all, R - restrict all
   IF l_group_rec.default_policy_type ='G' THEN
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sc_grants_pvt.generate_grant.default1';
        l_debug_str := 'Table Name: '||p_object_name||','||'Function Type: '||p_function_type||','||' User ID: '
			||l_user_id||','||'Default Policy: G';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;
     RETURN '';

   ELSE
     IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
        l_label := 'igs.plsql.igs_sc_grants_pvt.generate_grant.default2';
        l_debug_str := 'Table Name: '||p_object_name||','||'Function Type: '||p_function_type||','||' User ID: '
			||l_user_id||','||'Default Policy: R';
        fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
     END IF;

     RETURN '1=2';

   END IF;


 END IF;

  --gmaheswa fnd logging
 IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sc_grants_pvt.generate_grant.final_return';
     l_debug_str := 'Table Name: '||p_object_name||','||'Function Type: '||p_function_type||','||' User ID: '
			||l_user_id||','||'Final Select: '||l_statment;
     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
 END IF;


 RETURN l_statment;

END generate_grant ;


PROCEDURE populate_user_attrib(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_attrib_id         IN   NUMBER   := NULL,
  p_user_id           IN   NUMBER   := NULL,
  p_all_attribs       IN   VARCHAR2 :='N',
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
) IS

 l_api_name       CONSTANT VARCHAR2(30)   := 'POPULATE_USER_ATTRIB';
 l_api_version    CONSTANT NUMBER         := 1.0;
 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_user_id        NUMBER;
 l_party_id       NUMBER;

 -- This cursor is used when attrib is not specified -select all static attribs

 CURSOR c_all_attribs IS
    SELECT user_attrib_id   ,
           user_attrib_name ,
           user_attrib_type ,
           static_type      ,
           select_text
      FROM igs_sc_usr_attribs
     WHERE user_attrib_id = p_attrib_id
           OR ( p_attrib_id IS NULL AND
                (static_type = 'S'
                  OR (static_type = 'C' AND p_all_attribs = 'Y') )
              )
              ORDER BY user_attrib_id;

 CURSOR c_attrib IS
    SELECT user_attrib_id   ,
           user_attrib_name ,
           user_attrib_type ,
           static_type      ,
           select_text
      FROM igs_sc_usr_attribs
     WHERE user_attrib_id = p_attrib_id;

-- skpandey, Bug#4937960: Changed c_user definition to optimize query
 CURSOR c_users IS
	SELECT user_orig_system_id user_id
	FROM wf_local_user_roles rls
	WHERE rls.user_orig_system = 'FND_USR'
	AND rls.role_orig_system = 'IGS'
	AND (rls.EXPIRATION_DATE IS NULL OR rls.EXPIRATION_DATE > SYSDATE)
	AND rls.parent_orig_system = 'IGS'
	AND rls.parent_orig_system_id = rls.role_orig_system_id
	AND rls.partition_id = 0;


CURSOR c_party_value (s_user_id NUMBER) IS
    SELECT attr_value
      FROM igs_sc_usr_att_vals
     WHERE user_attrib_id = 1
           AND user_id = s_user_id;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     populate_user_attrib;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- API body


    FOR c_attrib_rec IN c_all_attribs LOOP

      IF p_user_id IS NULL THEN

        OPEN c_users;
        FETCH c_users INTO l_user_id;

      ELSE

        l_user_id := p_user_id;

      END IF;

      LOOP

        -- Get party id

        OPEN c_party_value (l_user_id);
        FETCH c_party_value INTO l_party_id;
        CLOSE c_party_value;

       -- populate attrib value for a given user
       insert_user_attrib(
         p_user_id          => l_user_id  ,
         p_party_id         => l_party_id ,
         p_user_attrib_id   => c_attrib_rec.user_attrib_id  ,
         p_user_attrib_name => c_attrib_rec.user_attrib_name  ,
         p_user_attrib_type => c_attrib_rec.user_attrib_type  ,
         p_static_type      => c_attrib_rec.static_type  ,
         p_select_text      => c_attrib_rec.select_text  );

         IF p_user_id IS NOT NULL THEN
            -- if only one user - end loop
            EXIT;

         ELSE

           FETCH c_users INTO l_user_id;

           IF c_users%NOTFOUND THEN

             -- if no more users to fetch exit
             EXIT;

           END IF;

         END IF;

      END LOOP;

      -- check if cursor is open then close

      IF c_users%ISOPEN THEN

        CLOSE c_users;

      END IF;
    END LOOP;


  -- End of API body.
  -- Standard check of p_commit.

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO populate_user_attrib;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO populate_user_attrib;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO populate_user_attrib;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

END populate_user_attrib;

FUNCTION get_current_user
RETURN NUMBER
IS
BEGIN

  return g_current_user_id;

END;

FUNCTION get_current_party
RETURN NUMBER
IS
BEGIN

  return g_current_party_id;

END;

PROCEDURE insert_user_attrib(
  p_user_id          IN NUMBER  ,
  p_party_id         IN NUMBER ,
  p_user_attrib_id   IN NUMBER  ,
  p_user_attrib_name IN VARCHAR2,
  p_user_attrib_type IN VARCHAR2,
  p_static_type      IN VARCHAR2,
  p_select_text      IN VARCHAR2
) IS

 l_select        VARCHAR2(32000);
 l_select_text   VARCHAR2(2000);
 l_party_id_arg  NUMBER(10) := 0;
 l_user_id_arg   NUMBER(10) := 0;

BEGIN

  -- delete all values for the current user

  DELETE FROM igs_sc_usr_att_vals
     WHERE user_id = p_user_id
           AND user_attrib_id = p_user_attrib_id;

  l_select := 'INSERT INTO igs_sc_usr_att_vals (USER_ID,USER_ATTRIB_ID,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,ATTR_VALUE )';

  -- find is :USER_ID or :PARTY_ID is used in the text
  -- replace all PARTY_ID with call to a IGS_SC_GRANTS_PVT.get_current_party function

  l_select_text := replace_string(ltrim(p_select_text),':PARTY_ID','IGS_SC_GRANTS_PVT.get_current_party');

  l_select_text := replace_string(ltrim(l_select_text),':USER_ID','IGS_SC_GRANTS_PVT.get_current_user');

  -- Replace table alias value with our alias, generated based on attribute id

  l_select_text := replace_string(ltrim(l_select_text),':TBL_ALIAS','sc'||p_user_attrib_id||'u');

  g_current_user_id := p_user_id;

  g_current_party_id := p_party_id;


  IF p_user_attrib_type = 'F' THEN

    l_select := l_select||' SELECT :V1, :V2, sysdate , -1 , -1, sysdate ,'||l_select_text||' FROM dual ';

  ELSE  --Select of M-valued
    -- Remove all spaces from text and remove SELECT word from a text

    l_select := l_select||' SELECT :V1, :V2, sysdate , -1 , -1, sysdate ,'||substr(l_select_text,7,32000);

  END IF;

  Put_Log_Msg ('Executed text is: '||IGS_SC_GRANTS_PVT.get_current_user||' : '||IGS_SC_GRANTS_PVT.get_current_party||':'|| l_select ,0);

  -- Execute as it is
  EXECUTE IMMEDIATE l_select USING p_user_id,p_user_attrib_id;

END insert_user_attrib;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Used to generate messages that are to be output
                        into the concurrent request log.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Generate_Message
IS

   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN

   FND_MSg_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0) THEN

      l_msg_data := '';

      FOR l_cur IN 1..l_msg_count LOOP

         l_msg_data := FND_MSg_PUB.GET(l_cur, FND_API.g_FALSE);
         Put_Log_Msg(l_msg_data,1);
      END LOOP;

   ELSE

         l_msg_data  := 'Error Returned but Error stack has no data';
         Put_Log_Msg(l_msg_data,1);

   END IF;

END Generate_Message;



/******************************************************************
   Created By         : Arkadi Tereshenkov

   Date Created By    : Oct 14, 2002

   Purpose            : Place the messages that have been generated into
                        the appropriate log file for viewing.

   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
PROCEDURE Put_Log_Msg (
   p_message IN VARCHAR2,
   p_level         IN NUMBER
) IS

   l_api_name             CONSTANT VARCHAR2(30)   := 'Put_Log_Msg';
   l_len NUMBER(10) := 1;
BEGIN

    -- This procedure outputs messages into the log file  Level 0 - System messages. 1 - user messages
    IF p_level >= g_debug_level THEN

       -- fnd_file.put_line (FND_FILE.LOG,p_message);
        LOOP
          IF length(p_message) <l_len THEN
            EXIT;
          END IF;
          l_len:=l_len+255;
        END LOOP;
    END IF;

END Put_Log_Msg;


PROCEDURE unlock_all_grants(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_conc_program_flag IN   VARCHAR2 := FND_API.G_FALSE,
  p_disable_security  IN   VARCHAR2 := FND_API.G_FALSE,
  p_obj_group_id      IN   NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
)IS

 l_api_name       CONSTANT VARCHAR2(30)   := 'UNLOCK_ALL_GRANTS';
 l_api_version    CONSTANT NUMBER         := 1.0;
 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);


 CURSOR c_grants IS
    SELECT grant_id
    FROM igs_sc_grants
     WHERE ( obj_group_id = p_obj_group_id  OR p_obj_group_id IS NULL)
           AND locked_flag ='Y';



BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     unlock_all_grants;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- API body


    FOR c_grants_rec IN c_grants LOOP

       IGS_SC_DATA_SEC_APIS_PKG.Unlock_Grant (
           p_api_version    => 1.0,
           p_grant_id       => c_grants_rec.grant_id,
           x_return_status  => l_return_status,
           x_return_message => l_msg_data );

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
       END IF;

    END LOOP;

  IF FND_API.to_Boolean (p_disable_security) THEN

    -- Change default access level for all groups
    UPDATE igs_sc_obj_groups
      SET default_policy_type = 'G';

  END IF;

  -- End of API body.
  -- Standard check of p_commit.

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO unlock_all_grants;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO unlock_all_grants;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO unlock_all_grants;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

END unlock_all_grants;

PROCEDURE lock_all_grants(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_conc_program_flag IN   VARCHAR2 := FND_API.G_FALSE,
  p_obj_group_id      IN   NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
) IS

 l_api_name       CONSTANT VARCHAR2(30)   := 'LOCK_ALL_GRANTS';
 l_api_version    CONSTANT NUMBER         := 1.0;
 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);


 CURSOR c_grants IS
    SELECT grant_id
    FROM igs_sc_grants
     WHERE ( obj_group_id = p_obj_group_id  OR p_obj_group_id IS NULL)
           AND locked_flag = 'N';



BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     lock_all_grants;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- API body


    FOR c_grants_rec IN c_grants LOOP

       IGS_SC_DATA_SEC_APIS_PKG.Lock_Grant (
           p_api_version    => 1.0,
           p_grant_id       => c_grants_rec.grant_id,
           x_return_status  => l_return_status,
           x_return_message => l_msg_data );

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
       END IF;

    END LOOP;


  -- End of API body.
  -- Standard check of p_commit.

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO lock_all_grants;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO lock_all_grants;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO lock_all_grants;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
END lock_all_grants;


FUNCTION admin_mode
RETURN VARCHAR2 IS
BEGIN
  RETURN 'N';
END admin_mode;


PROCEDURE put_d_message (
   p_message IN VARCHAR2,
   p_level   IN NUMBER,
   l_file_ptr UTL_FILE.FILE_TYPE
) IS

BEGIN

    IF p_level <= g_debug_level THEN

      UTL_FILE.PUT_LINE ( l_file_ptr, p_message);
      UTL_FILE.FFLUSH ( l_file_ptr );

    END IF;

END put_d_message;

FUNCTION format_string (
   col1 IN VARCHAR2 :='',
   len1 IN NUMBER   :=0,
   col2 IN VARCHAR2 :='',
   len2 IN NUMBER   :=0,
   col3 IN VARCHAR2 :='',
   len3 IN NUMBER   :=0,
   col4 IN VARCHAR2 :='',
   len4 IN NUMBER   :=0,
   col5 IN VARCHAR2 :='',
   len5 IN NUMBER   :=0,
   col6 IN VARCHAR2 :='',
   len6 IN NUMBER   :=0,
   col7 IN VARCHAR2 :='',
   len7 IN NUMBER   :=0,
   col8 IN VARCHAR2 :='',
   len8 IN NUMBER   :=0,
   col9 IN VARCHAR2 :='',
   len9 IN NUMBER   :=0,
   col10 IN VARCHAR2 :='',
   len10 IN NUMBER   :=0
) RETURN VARCHAR2 IS
 l_space VARCHAR2(80):='                                                                                ';
BEGIN

  RETURN substr(col1||l_space,1,len1)||substr(col2||l_space,1,len2)||substr(col3||l_space,1,len3)||substr(col4||l_space,1,len4)||
         substr(col5||l_space,1,len5)||substr(col6||l_space,1,len6)||substr(col7||l_space,1,len7)||substr(col8||l_space,1,len8)
         ||substr(col9||l_space,1,len9)||substr(col10||l_space,1,len10);

END format_string;

PROCEDURE run_diagnostic(
  p_dirpath           IN   VARCHAR2,
  p_file_name         IN   VARCHAR2,
  p_log_level         IN   VARCHAR2,
  p_user_id           IN   NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
) IS
/*******************************************************************************
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  skpandey        12-JAN-2006     Bug#4937960
                                  Stubbed the procedure as it is never used
*******************************************************************************/
BEGIN

Null;

END run_diagnostic;



FUNCTION check_attrib_text (
  p_table_name VARCHAR2,
  p_select_text VARCHAR2,
  p_obj_attrib_type VARCHAR2 )

RETURN BOOLEAN IS
 l_select_text VARCHAR2(32000);
BEGIN
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sc_grants_pvt.check_attrib_text';
     l_debug_str := 'Table Name: '||p_table_name||','||'Select Text: '||p_select_text||','||'Object Attribute Type: '||p_obj_attrib_type;
     fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

  IF p_obj_attrib_type = 'F' THEN

   l_select_text :=  ' EXISTS ( SELECT '||p_select_text||' FROM DUAL ) ';

  ELSIF p_obj_attrib_type = 'T' THEN

   l_select_text :=  p_select_text||' IS NOT NULL ';

  ELSE
   -- Select statment. Add EXIST
   l_select_text := ' EXISTS ( '||p_select_text||' )';

  END IF;

  RETURN check_grant_text ( p_table_name, l_select_text );

END check_attrib_text;

END IGS_SC_GRANTS_PVT;


/
