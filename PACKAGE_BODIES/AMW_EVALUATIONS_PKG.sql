--------------------------------------------------------
--  DDL for Package Body AMW_EVALUATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_EVALUATIONS_PKG" as
/*$Header: amwevalb.pls 115.8 2004/01/27 02:05:13 kosriniv noship $*/


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_EVALUATIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwevalb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


procedure insert_row (
 p_EVALUATION_SET_ID               IN NUMBER,
 p_EVALUATION_OBJECT_NAME          IN VARCHAR2,
 p_EVALUATION_CONTEXT              IN VARCHAR2,
 p_EVALUATION_TYPE                 IN VARCHAR2,
 -- 12.31.2003 tsho: for bug 3326347, don't convert varchar2 to date
 -- p_DATE_EVALUATED                  IN VARCHAR2,
 p_DATE_EVALUATED                  IN DATE,
 p_PK1_VALUE                       IN VARCHAR2,
 p_PK2_VALUE                       IN VARCHAR2,
 p_PK3_VALUE                       IN VARCHAR2,
 p_PK4_VALUE                       IN VARCHAR2,
 p_PK5_VALUE                       IN VARCHAR2,
 p_ENTERED_BY_ID                   IN NUMBER,
 p_EXECUTED_BY_ID                  IN NUMBER,
 p_COMMENTS			   IN VARCHAR2,
 p_DES_EFF			   IN VARCHAR2,
 p_OP_EFF			   IN VARCHAR2,
 p_OV_EFF			   IN VARCHAR2,
 p_PGMODE			   IN VARCHAR2,
 p_EVALUATION_ID		   IN NUMBER,
 p_commit		           in varchar2 := FND_API.G_FALSE,
 p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
 p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
 x_return_status		   out nocopy varchar2,
 x_msg_count			   out nocopy number,
 x_msg_data			   out nocopy varchar2,
 p_EVALUATION_SET_STATUS_CODE          IN VARCHAR2
) is

  L_API_NAME CONSTANT VARCHAR2(30) := 'insert_row';
  l_evaluation_id number;

  begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


if p_PGMODE = 'CR' then

/*****************************************************************************/
/********************************CODE FOR CREATE******************************/
/*****************************************************************************/

insert into amw_evaluations_b (
 EVALUATION_ID,
 EVALUATION_SET_ID,
 EVALUATION_OBJECT_NAME,
 EVALUATION_CONTEXT,
 EVALUATION_TYPE,
 DATE_EVALUATED,
 PK1_VALUE,
 PK2_VALUE,
 ENTERED_BY_ID,
 EXECUTED_BY_ID,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY,
 LAST_UPDATE_LOGIN,
 OBJECT_VERSION_NUMBER,
 EVALUATION_SET_STATUS_CODE
)
values
(
AMW_EVALUATION_ID_S.nextval,
p_EVALUATION_SET_ID,
p_EVALUATION_OBJECT_NAME,
p_EVALUATION_CONTEXT,
p_EVALUATION_TYPE,
-- to_date(p_DATE_EVALUATED, 'DD-MON-YYYY HH24:MI:SS'),
-- to_date(p_DATE_EVALUATED),
-- 12.31.2003 tsho: for bug 3326347, don't convert varchar2 to date
--to_date(p_DATE_EVALUATED, 'DD/MM/YYYY'),
p_DATE_EVALUATED,
p_PK1_VALUE,
p_PK2_VALUE,
p_ENTERED_BY_ID,
p_EXECUTED_BY_ID,
sysdate,
G_USER_ID,
sysdate,
G_USER_ID,
G_LOGIN_ID,
1,
p_EVALUATION_SET_STATUS_CODE
)returning EVALUATION_ID into l_evaluation_id;


 insert into AMW_EVALUATIONS_TL (
 EVALUATION_ID,
 COMMENTS,
 LANGUAGE,
 SOURCE_LANG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY,
 LAST_UPDATE_LOGIN,
 OBJECT_VERSION_NUMBER
 )	select
	l_evaluation_id,
	p_comments,
	L.LANGUAGE_CODE,
	userenv('LANG'),
	sysdate,
	G_USER_ID,
	sysdate,
	G_USER_ID,
	G_LOGIN_ID,
	1
	from FND_LANGUAGES L
	where L.INSTALLED_FLAG in ('I', 'B')
	and not exists
		(select NULL
		 from AMW_EVALUATIONS_TL T
		 where T.EVALUATION_ID = l_evaluation_id
		 and T.LANGUAGE = L.LANGUAGE_CODE);


if p_EVALUATION_OBJECT_NAME = 'PROCEDURE_CONTROL' then
	insert into amw_evaluations_details (
	 EVALUATION_ID,
	 EVALUATION_COMPONENT,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 EVALUATION_CONCLUSION )
	 values
	 (
	 l_evaluation_id,
	 'DESIGN_EFFECTIVENESS',
	 sysdate,
	 G_USER_ID,
	 sysdate,
	 G_USER_ID,
	 G_LOGIN_ID,
	 p_DES_EFF
	 );
	insert into amw_evaluations_details (
	 EVALUATION_ID,
	 EVALUATION_COMPONENT,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 EVALUATION_CONCLUSION )
	 values
	 (
	 l_evaluation_id,
	 'OPERATING_EFFECTIVENESS',
	 sysdate,
	 G_USER_ID,
	 sysdate,
	 G_USER_ID,
	 G_LOGIN_ID,
	 p_OP_EFF
	 );
end if;
if p_EVALUATION_OBJECT_NAME = 'PROCEDURE' then
	insert into amw_evaluations_details (
	 EVALUATION_ID,
	 EVALUATION_COMPONENT,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 EVALUATION_CONCLUSION )
	 values
	 (
	 l_evaluation_id,
	 'OVERALL_EFFECTIVENESS',
	 sysdate,
	 G_USER_ID,
	 sysdate,
	 G_USER_ID,
	 G_LOGIN_ID,
	 p_OV_EFF
	 );
end if;
if p_EVALUATION_OBJECT_NAME = 'ASSESSMENT_COMPONENT' OR p_EVALUATION_OBJECT_NAME = 'ASSESSMENT' then
	insert into amw_evaluations_details (
	 EVALUATION_ID,
	 EVALUATION_COMPONENT,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 EVALUATION_CONCLUSION )
	 values
	 (
	 l_evaluation_id,
	 'CONCLUSION',
	 sysdate,
	 G_USER_ID,
	 sysdate,
	 G_USER_ID,
	 G_LOGIN_ID,
	 p_OV_EFF
	 );
end if;

else -- p_PGMODE = 'CR'

/*****************************************************************************/
/********************************CODE FOR UPDATE******************************/
/*****************************************************************************/

update amw_evaluations_b set
-- DATE_EVALUATED = to_date(p_DATE_EVALUATED, 'DD-MON-YYYY HH24:MI:SS'),
-- DATE_EVALUATED = to_date(p_DATE_EVALUATED),
-- 12.31.2003 tsho: for bug 3326347, don't convert varchar2 to date
-- DATE_EVALUATED = to_date(p_DATE_EVALUATED,'DD/MM/YYYY'),
 DATE_EVALUATED = p_DATE_EVALUATED,
 ENTERED_BY_ID = p_ENTERED_BY_ID,
 EXECUTED_BY_ID = p_EXECUTED_BY_ID,
 LAST_UPDATE_DATE = sysdate,
 LAST_UPDATED_BY = G_USER_ID,
 CREATION_DATE = sysdate,
 CREATED_BY = G_USER_ID,
 LAST_UPDATE_LOGIN = G_LOGIN_ID,
 OBJECT_VERSION_NUMBER = (OBJECT_VERSION_NUMBER + 1),
 EVALUATION_SET_STATUS_CODE = p_EVALUATION_SET_STATUS_CODE
 where EVALUATION_ID = p_EVALUATION_ID;


update AMW_EVALUATIONS_TL set
 COMMENTS = p_comments,
 LAST_UPDATE_DATE = sysdate,
 LAST_UPDATED_BY = G_USER_ID,
 CREATION_DATE = sysdate,
 CREATED_BY = G_USER_ID,
 LAST_UPDATE_LOGIN = G_LOGIN_ID,
 OBJECT_VERSION_NUMBER = (OBJECT_VERSION_NUMBER + 1)
 where evaluation_id = p_EVALUATION_ID;


if p_EVALUATION_OBJECT_NAME = 'PROCEDURE_CONTROL' then

	update amw_evaluations_details set
	 EVALUATION_CONCLUSION = p_DES_EFF,
	 LAST_UPDATE_DATE = sysdate,
	 LAST_UPDATED_BY = G_USER_ID,
	 CREATION_DATE = sysdate,
	 CREATED_BY = G_USER_ID,
	 LAST_UPDATE_LOGIN = G_LOGIN_ID
	 where evaluation_id = p_evaluation_id
	 and EVALUATION_COMPONENT = 'DESIGN_EFFECTIVENESS';


	update amw_evaluations_details set
	 EVALUATION_CONCLUSION = p_OP_EFF,
	 LAST_UPDATE_DATE = sysdate,
	 LAST_UPDATED_BY = G_USER_ID,
	 CREATION_DATE = sysdate,
	 CREATED_BY = G_USER_ID,
	 LAST_UPDATE_LOGIN = G_LOGIN_ID
	 where evaluation_id = p_evaluation_id
	 and EVALUATION_COMPONENT = 'OPERATING_EFFECTIVENESS';
end if;

if p_EVALUATION_OBJECT_NAME = 'PROCEDURE' then

	update amw_evaluations_details set
	 EVALUATION_CONCLUSION = p_OV_EFF,
	 LAST_UPDATE_DATE = sysdate,
	 LAST_UPDATED_BY = G_USER_ID,
	 CREATION_DATE = sysdate,
	 CREATED_BY = G_USER_ID,
	 LAST_UPDATE_LOGIN = G_LOGIN_ID
	 where evaluation_id = p_evaluation_id
	 and EVALUATION_COMPONENT = 'OVERALL_EFFECTIVENESS';

end if;


if p_EVALUATION_OBJECT_NAME = 'ASSESSMENT_COMPONENT' OR p_EVALUATION_OBJECT_NAME = 'ASSESSMENT' then

	update amw_evaluations_details set
	 EVALUATION_CONCLUSION = p_OV_EFF,
	 LAST_UPDATE_DATE = sysdate,
	 LAST_UPDATED_BY = G_USER_ID,
	 CREATION_DATE = sysdate,
	 CREATED_BY = G_USER_ID,
	 LAST_UPDATE_LOGIN = G_LOGIN_ID
	 where evaluation_id = p_evaluation_id
	 and EVALUATION_COMPONENT = 'CONCLUSION';

end if;

end if; -- p_PGMODE = 'UP'


exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end insert_row;


function get_op_effectiveness(p_evaluation_id IN NUMBER) return varchar2 IS
l_ev_conl varchar2(1);
begin
	select evaluation_conclusion
	into l_ev_conl
	from amw_evaluations_details
	where evaluation_id = p_evaluation_id
	and evaluation_component = 'OPERATING_EFFECTIVENESS';

	RETURN AMW_Utility_PVT.get_lookup_meaning('AMW_PASS_FAIL', l_ev_conl);
end get_op_effectiveness;


function get_des_effectiveness(p_evaluation_id IN NUMBER) return varchar2 IS
l_ev_conl varchar2(1);
begin
	select evaluation_conclusion
	into l_ev_conl
	from amw_evaluations_details
	where evaluation_id = p_evaluation_id
	and evaluation_component = 'DESIGN_EFFECTIVENESS';

	RETURN AMW_Utility_PVT.get_lookup_meaning('AMW_PASS_FAIL', l_ev_conl);
end get_des_effectiveness;

function get_op_effectiveness_code(p_evaluation_id IN NUMBER) return varchar2 IS
l_ev_conl varchar2(1);
begin
	select evaluation_conclusion
	into l_ev_conl
	from amw_evaluations_details
	where evaluation_id = p_evaluation_id
	and evaluation_component = 'OPERATING_EFFECTIVENESS';

	RETURN l_ev_conl;
end get_op_effectiveness_code;


function get_des_effectiveness_code(p_evaluation_id IN NUMBER) return varchar2 IS
l_ev_conl varchar2(1);
begin
	select evaluation_conclusion
	into l_ev_conl
	from amw_evaluations_details
	where evaluation_id = p_evaluation_id
	and evaluation_component = 'DESIGN_EFFECTIVENESS';

	RETURN l_ev_conl;
end get_des_effectiveness_code;

function get_line_conclusion(p_evaluation_id IN NUMBER) return varchar2 IS
l_ev_conl varchar2(1);
begin
	select evaluation_conclusion
	into l_ev_conl
	from amw_evaluations_details
	where evaluation_id = p_evaluation_id
	and evaluation_component = 'LINE_CONCLUSION';

	RETURN AMW_Utility_PVT.get_lookup_meaning('AMW_EVALUATION_CONCLUSION', l_ev_conl);
end get_line_conclusion;

function get_line_conclusion_code(p_evaluation_id IN NUMBER) return varchar2 IS
l_ev_conl varchar2(1);
begin
	select evaluation_conclusion
	into l_ev_conl
	from amw_evaluations_details
	where evaluation_id = p_evaluation_id
	and evaluation_component = 'LINE_COMPONENT';

	RETURN l_ev_conl;
end get_line_conclusion_code;


function isEvalOwnerOrExecutor(p_evaluation_id IN NUMBER, p_user_id IN NUMBER) return varchar2 IS
n     number;
BEGIN
   select count(*)
   into n
   from  amw_evaluations_vl
   where evaluation_id = p_evaluation_id
   and   (executed_by_id = p_user_id or entered_by_id = p_user_id);

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
end isEvalOwnerOrExecutor;


function isEvalExecutorOfAssessment(p_assessment_id IN NUMBER, p_user_id IN NUMBER, p_eval_context IN VARCHAR2) return varchar2 IS
n     number;
BEGIN
   select count(*)
   into n
   from  amw_evaluations_vl
   where executed_by_id = p_user_id
    and evaluation_object_name = 'ASSESSMENT'
    and evaluation_type = '1'
    and evaluation_context = p_eval_context
    and pk1_value = p_assessment_id;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
end isEvalExecutorOfAssessment;

procedure ADD_LANGUAGE
is
begin
  delete from AMW_EVALUATIONS_TL T
  where not exists
    (select NULL
    from AMW_EVALUATIONS_B B
    where B.EVALUATION_ID = T.EVALUATION_ID
    );

  update AMW_EVALUATIONS_TL T set (
      COMMENTS
    ) = (select
      B.COMMENTS
    from AMW_EVALUATIONS_TL B
    where B.EVALUATION_ID = T.EVALUATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EVALUATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EVALUATION_ID,
      SUBT.LANGUAGE
    from AMW_EVALUATIONS_TL SUBB, AMW_EVALUATIONS_TL SUBT
    where SUBB.EVALUATION_ID = SUBT.EVALUATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.COMMENTS <> SUBT.COMMENTS
      or (SUBB.COMMENTS is null and SUBT.COMMENTS is not null)
      or (SUBB.COMMENTS is not null and SUBT.COMMENTS is null)
  ));

  insert into AMW_EVALUATIONS_TL (
    EVALUATION_ID,
    COMMENTS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.EVALUATION_ID,
    B.COMMENTS,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_EVALUATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_EVALUATIONS_TL T
    where T.EVALUATION_ID = B.EVALUATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end AMW_EVALUATIONS_PKG;

/
