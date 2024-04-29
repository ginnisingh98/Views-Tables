--------------------------------------------------------
--  DDL for Package Body CSK_SETUP_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSK_SETUP_UTILITY_PKG" 
  /* $Header: csktsub.pls 120.0 2005/06/01 11:46:35 appldev noship $ */
AS

-- Create Category Group
PROCEDURE Create_CG (P_ID NUMBER, P_NAME VARCHAR2)
IS
BEGIN
  insert into CS_KB_CATEGORY_GROUPS_B (
    CATEGORY_GROUP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_ID,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351 );

  insert into CS_KB_CATEGORY_GROUPS_TL (
    CATEGORY_GROUP_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_ID,
    P_NAME,
    P_NAME,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_KB_CATEGORY_GROUPS_TL T
    where T.CATEGORY_GROUP_ID = P_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END Create_CG;

--Create Solution Type
PROCEDURE Create_Soln_Type (P_ID NUMBER, P_NAME VARCHAR2)
IS
BEGIN
  insert into CS_KB_SET_TYPES_B (
    SET_TYPE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_ID,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351 );

  insert into CS_KB_SET_TYPES_TL (
    SET_TYPE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_ID,
    P_NAME,
    P_NAME,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_KB_SET_TYPES_TL T
    where T.SET_TYPE_ID = P_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END Create_Soln_Type;

--Create statement type
PROCEDURE Create_Stmt_Type (P_ID NUMBER, P_NAME VARCHAR2)
IS
BEGIN
  insert into CS_KB_ELEMENT_TYPES_B (
   ELEMENT_TYPE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_ID,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351 );

  insert into CS_KB_ELEMENT_TYPES_TL (
    ELEMENT_TYPE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_ID,
    P_NAME,
    P_NAME,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_KB_ELEMENT_TYPES_TL T
    where T.ELEMENT_TYPE_ID = P_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END Create_Stmt_Type;

--Create visibility
PROCEDURE Create_Visibility (P_ID NUMBER, P_NAME VARCHAR2, P_POSN NUMBER)
IS
BEGIN
  insert into CS_KB_VISIBILITIES_B (
    VISIBILITY_ID,
    POSITION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_ID,
    P_POSN,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351 );

  insert into CS_KB_VISIBILITIES_TL (
    VISIBILITY_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_ID,
    P_NAME,
    P_NAME,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_KB_VISIBILITIES_TL T
    where T.VISIBILITY_ID = P_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END Create_Visibility;

-- Validate common data setup for: category group, solution type, statement
-- type, visibility, authoring flow.
PROCEDURE Validate_Seeded_Setups(
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2)
IS
l_max NUMBER;
BEGIN
-------------------------------------------------------------
-- Create Seeded Category Groups
-------------------------------------------------------------
 DELETE FROM CS_KB_CATEGORY_GROUPS_B  WHERE CATEGORY_GROUP_ID = CAT_GROUP_API_TEST_DEFAULT;
 DELETE FROM CS_KB_CATEGORY_GROUPS_TL WHERE CATEGORY_GROUP_ID = CAT_GROUP_API_TEST_DEFAULT;
 Create_CG (P_ID => CAT_GROUP_API_TEST_DEFAULT, P_NAME => 'Api_Test_Default_CG');

 DELETE FROM CS_KB_CATEGORY_GROUPS_B  WHERE CATEGORY_GROUP_ID = CAT_GROUP_API_TEST_CG1;
 DELETE FROM CS_KB_CATEGORY_GROUPS_TL WHERE CATEGORY_GROUP_ID = CAT_GROUP_API_TEST_CG1;
 Create_CG (P_ID => CAT_GROUP_API_TEST_CG1, P_NAME => 'Api_Test_CG1');

 DELETE FROM CS_KB_CATEGORY_GROUPS_B  WHERE CATEGORY_GROUP_ID = CAT_GROUP_API_TEST_CG2;
 DELETE FROM CS_KB_CATEGORY_GROUPS_TL WHERE CATEGORY_GROUP_ID = CAT_GROUP_API_TEST_CG2;
 Create_CG (P_ID => CAT_GROUP_API_TEST_CG2, P_NAME => 'Api_Test_CG2');

-------------------------------------------------------------
-- Create Seeded Solution Types
-------------------------------------------------------------
 DELETE FROM CS_KB_SET_TYPES_B  WHERE SET_TYPE_ID = SOLN_TYPE_FAQ_API_TEST;
 DELETE FROM CS_KB_SET_TYPES_TL WHERE SET_TYPE_ID = SOLN_TYPE_FAQ_API_TEST;
 Create_Soln_Type (P_ID => SOLN_TYPE_FAQ_API_TEST, P_NAME => 'FAQ_API_TEST');

-------------------------------------------------------------
-- Create Seeded Statement Types
-------------------------------------------------------------
 DELETE FROM CS_KB_ELEMENT_TYPES_B  WHERE ELEMENT_TYPE_ID = STMT_TYPE_FAQ_API_TEST;
 DELETE FROM CS_KB_ELEMENT_TYPES_TL WHERE ELEMENT_TYPE_ID = STMT_TYPE_FAQ_API_TEST;
 Create_Stmt_Type (P_ID => STMT_TYPE_FAQ_API_TEST, P_NAME => 'FAQ_API_TEST');

-------------------------------------------------------------
-- Create Seeded Solution to Statement Type Associations
-------------------------------------------------------------
 DELETE FROM CS_KB_SET_ELE_TYPES WHERE SET_TYPE_ID = SOLN_TYPE_FAQ_API_TEST AND ELEMENT_TYPE_ID = STMT_TYPE_FAQ_API_TEST;
 INSERT INTO CS_KB_SET_ELE_TYPES ( SET_TYPE_ID,ELEMENT_TYPE_ID,ELEMENT_TYPE_ORDER
                                  ,OPTIONAL_FLAG,CREATION_DATE,CREATED_BY
                                  ,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
 VALUES (SOLN_TYPE_FAQ_API_TEST, STMT_TYPE_FAQ_API_TEST, 1, 'Y', sysdate,
 -1351, sysdate, -1351, -1351);

-------------------------------------------------------------
-- Create Seeded Visibilities
-------------------------------------------------------------
 SELECT MAX(Position) INTO l_max
 FROM CS_KB_VISIBILITIES_B
 WHERE Visibility_id > 1;

 DELETE FROM CS_KB_VISIBILITIES_B  WHERE Visibility_ID = VISIBILITY_RESTRICTED_API_TEST;
 DELETE FROM CS_KB_VISIBILITIES_TL WHERE Visibility_ID = VISIBILITY_RESTRICTED_API_TEST;
 Create_Visibility(P_ID => VISIBILITY_RESTRICTED_API_TEST, P_NAME => 'Restricted_API_TEST', P_POSN => l_max+1);
 UPDATE CS_KB_CAT_GROUP_DENORM SET VISIBILITY_POSITION = l_max+1
 WHERE VISIBILITY_ID = VISIBILITY_RESTRICTED_API_TEST;

 DELETE FROM CS_KB_VISIBILITIES_B  WHERE Visibility_ID = VISIBILITY_INTERNAL_API_TEST;
 DELETE FROM CS_KB_VISIBILITIES_TL WHERE Visibility_ID = VISIBILITY_INTERNAL_API_TEST;
 Create_Visibility(P_ID => VISIBILITY_INTERNAL_API_TEST, P_NAME => 'Internal_API_TEST', P_POSN => l_max+2);
 UPDATE CS_KB_CAT_GROUP_DENORM SET VISIBILITY_POSITION = l_max+2
 WHERE VISIBILITY_ID = VISIBILITY_INTERNAL_API_TEST;

 DELETE FROM CS_KB_VISIBILITIES_B  WHERE Visibility_ID = VISIBILITY_LIMITED_API_TEST;
 DELETE FROM CS_KB_VISIBILITIES_TL WHERE Visibility_ID = VISIBILITY_LIMITED_API_TEST;
 Create_Visibility(P_ID => VISIBILITY_LIMITED_API_TEST, P_NAME => 'Limited_API_TEST', P_POSN => l_max+3);
 UPDATE CS_KB_CAT_GROUP_DENORM SET VISIBILITY_POSITION = l_max+3
 WHERE VISIBILITY_ID = VISIBILITY_LIMITED_API_TEST;

 DELETE FROM CS_KB_VISIBILITIES_B  WHERE Visibility_ID = VISIBILITY_EXTERNAL_API_TEST;
 DELETE FROM CS_KB_VISIBILITIES_TL WHERE Visibility_ID = VISIBILITY_EXTERNAL_API_TEST;
 Create_Visibility(P_ID => VISIBILITY_EXTERNAL_API_TEST, P_NAME => 'External_API_TEST', P_POSN => l_max+4);
 UPDATE CS_KB_CAT_GROUP_DENORM SET VISIBILITY_POSITION = l_max+4
 WHERE VISIBILITY_ID = VISIBILITY_EXTERNAL_API_TEST;

-------------------------------------------------------------
-- Create Seeded Flow
-------------------------------------------------------------
 DELETE FROM CS_KB_WF_FLOWS_B  WHERE FLOW_ID = FLOW_API_TEST_FLOW;
 DELETE FROM CS_KB_WF_FLOWS_TL WHERE FLOW_ID = FLOW_API_TEST_FLOW;
 DELETE FROM CS_KB_WF_FLOW_DETAILS WHERE FLOW_ID = FLOW_API_TEST_FLOW;

   insert into CS_KB_WF_FLOWS_B (
    FLOW_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    FLOW_API_TEST_FLOW,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351 );



  insert into CS_KB_WF_FLOWS_TL (
    FLOW_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    FLOW_API_TEST_FLOW,
    'Api Test Flow',
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_KB_WF_FLOWS_TL T
    where T.FLOW_ID = -1
    and T.LANGUAGE = L.LANGUAGE_CODE);

 INSERT INTO CS_KB_WF_FLOW_DETAILS (FLOW_DETAILS_ID, FLOW_ID, STEP, ORDER_NUM,
                     ACTION, GROUP_ID, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
 VALUES (-1,FLOW_API_TEST_FLOW,'TECHNICAL_REVIEW',10, 'NOT',100000121, -1351,sysdate,-1351,sysdate,-1351);

 INSERT INTO CS_KB_WF_FLOW_DETAILS (FLOW_DETAILS_ID, FLOW_ID, STEP, ORDER_NUM,
                     ACTION, GROUP_ID, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
 VALUES (-2,FLOW_API_TEST_FLOW,'PUBLISHED',20, 'PUB',100000121, -1351,sysdate,-1351,sysdate,-1351);
-------------------------------------------------------------
-------------------------------------------------------------

 if fnd_api.to_boolean( p_commit ) then
        commit;
 end if;
END Validate_Seeded_Setups;

--Create category
PROCEDURE Create_Category (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_PARENT_CATEGORY_ID IN NUMBER,
    P_CATEGORY_ID        IN NUMBER,
    P_CATEGORY_NAME      IN VARCHAR2,
    P_VISIBILITY_ID      IN NUMBER)
IS

CURSOR Get_Posn IS
 SELECT Position
 FROM CS_KB_VISIBILITIES_B
 WHERE VISIBILITY_ID = P_VISIBILITY_ID;
l_posn NUMBER;

BEGIN

 DELETE FROM cs_kb_soln_categories_b WHERE CATEGORY_ID = P_CATEGORY_ID;
 DELETE FROM cs_kb_soln_categories_tl WHERE CATEGORY_ID = P_CATEGORY_ID;

 insert into CS_KB_SOLN_CATEGORIES_B
 (
      CATEGORY_ID,
      PARENT_CATEGORY_ID,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      VISIBILITY_ID
    )
    values
    ( P_CATEGORY_ID,
      P_PARENT_CATEGORY_ID,
      sysdate,
      -1351,
      sysdate,
      -1351,
      -1351,
      P_VISIBILITY_ID
 );

 insert into CS_KB_SOLN_CATEGORIES_TL
 (
      CATEGORY_ID,
      NAME,
      DESCRIPTION,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    )
    select
      P_CATEGORY_ID,
      P_CATEGORY_NAME,
      P_CATEGORY_NAME,
      sysdate,
      -1351,
      sysdate,
      -1351,
      -1351,
      L.LANGUAGE_CODE,
      userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
      (select NULL
       from CS_KB_SOLN_CATEGORIES_TL T
       where T.CATEGORY_ID = P_CATEGORY_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);

 OPEN  Get_Posn;
 FETCH Get_Posn INTO l_posn;
 CLOSE Get_Posn;

 UPDATE CS_KB_CAT_GROUP_DENORM
 SET VISIBILITY_ID = P_VISIBILITY_ID,
     VISIBILITY_POSITION = l_posn
 WHERE CHILD_CATEGORY_ID = P_CATEGORY_ID;

 if fnd_api.to_boolean( p_commit ) then
     commit;
 end if;
END Create_Category;

--Delete category
procedure Delete_Category(
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    p_category_id in number)
is
    n_child_solutions number;
    n_subcatgories    number;
    l_delete_status   number;
begin

  select /*+ index(sl) */ count( * ) into n_child_solutions
  from cs_kb_set_categories sl, cs_kb_sets_b b
  where sl.category_id = p_category_id
    and b.set_id = sl.set_id
    and (b.status = 'PUB' or (b.status <> 'OBS' and b.latest_version_flag = 'Y'));

  select count( * ) into n_subcatgories
  from cs_kb_soln_categories_b
  where parent_category_id = p_category_id;

  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  -- check if the category is deletable
  -- i.e. it does not contain sub-categories nor PUBlished child solutions
  if( n_child_solutions <> 0 OR n_subcatgories <> 0 ) then
     FND_MSG_PUB.initialize;
     FND_MESSAGE.set_name('CS', 'CS_KB_C_CAT_DELETE_FAILED');
     FND_MSG_PUB.ADD;
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                               p_count   => X_MSG_COUNT,
                               p_data    => X_MSG_DATA);

  ELSE
    -- Delete all set category links (which should not be PUBlished versions)
    delete /*+ index(sl) */  from cs_kb_set_categories sl
    where sl.category_id = p_category_id;

    -- Delete this leaf category
    delete from cs_kb_soln_categories_tl
    where category_id = p_category_id;

    delete from cs_kb_soln_categories_b
    where category_id = p_category_id;

    -- cs_kb_security_pvt.REMOVE_CATEGORY_FROM_CAT_GROUP
    -- Removes Category from Members table if the Category Exists
    DELETE FROM CS_KB_CAT_GROUP_MEMBERS
    WHERE Category_Id = P_CATEGORY_ID;
    -- Removes Category from Denorm table if the Category Exists
    DELETE FROM CS_KB_CAT_GROUP_DENORM
    WHERE Child_Category_Id = P_CATEGORY_ID;

    if fnd_api.to_boolean( p_commit ) then
      commit;
    end if;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  end if;
end Delete_Category;

--Create solution
-- !!! Incomplete: missing the way to submit it to a certain flow.
PROCEDURE Create_Solution (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_SOLN_REC    IN Soln_rec_type,
    P_STMT_TBL    IN Stmt_tbl_type,
    p_CAT_TBL     IN Cat_tbl_type,
    P_PUBLISH     IN Boolean)
IS
a    pls_integer;

i1 pls_integer;

l_status VARCHAR2(30);
l_locked_by NUMBER;
l_fdi NUMBER;
b NUMBER;
i2    pls_integer;

BEGIN
dbms_output.put_line('Before Delete');
 DELETE FROM CS_KB_SETS_B  WHERE SET_ID = P_SOLN_REC.Set_id;
 DELETE FROM CS_KB_SETS_TL WHERE SET_ID = P_SOLN_REC.Set_id;
 DELETE FROM CS_KB_SET_CATEGORIES WHERE SET_ID = P_SOLN_REC.Set_id;
 DELETE FROM CS_KB_SET_ELES WHERE SET_ID = P_SOLN_REC.Set_id;

 a := P_STMT_TBL.FIRST;

 WHILE a IS NOT NULL LOOP

   DELETE FROM CS_KB_ELEMENTS_B  WHERE ELEMENT_ID = P_STMT_TBL(a).element_id;

   DELETE FROM CS_KB_ELEMENTS_TL WHERE ELEMENT_ID = P_STMT_TBL(a).element_id;

   a := P_STMT_TBL.NEXT(a);

 END LOOP;
dbms_output.put_line('After Delete');
 IF P_PUBLISH = true THEN
  l_status := 'PUB';
  l_locked_by := null;
  l_fdi := null;
 ELSE
  l_status := 'NOT';
  l_locked_by := -1;
  l_fdi := -1;
 END IF;


   INSERT INTO CS_KB_SETS_B (
    set_id,
    set_number,
    set_type_id,
    status,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    locked_by,
    priority_code,
    original_author,
    original_author_date,
    visibility_id,
    latest_version_flag,
    USAGE_SCORE,
    Flow_Details_id )
  VALUES (
    P_SOLN_REC.set_id,
    P_SOLN_REC.set_number,
    P_SOLN_REC.set_type_id,
    l_status,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    l_locked_by,
    4,
    -1351,
    sysdate,
    P_SOLN_REC.visibility_id,
    'Y',
     0,
     l_fdi );

  INSERT INTO CS_KB_SETS_TL (
    set_id,
    name,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    language,
    source_lang
  ) SELECT
    P_SOLN_REC.set_id,
    P_SOLN_REC.name,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    l.language_code,
    USERENV('LANG')
  FROM fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
     FROM CS_KB_SETS_TL t
     WHERE t.set_id = P_SOLN_REC.set_id
     AND t.language = l.language_code);


dbms_output.put_line('After Insert Solution');
  IF P_PUBLISH = true THEN
    l_status := 'PUBLISHED';
  ELSE
    l_status := 'DRAFT';
  END IF;

  b := 1;
  i1 := P_STMT_TBL.FIRST;

  while i1 is not null loop

  INSERT INTO CS_KB_ELEMENTS_B (
    element_id,
    element_number,
    element_type_id,
    status,
    access_level,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    content_type
  ) VALUES (
    P_STMT_TBL(i1).element_id,
    P_STMT_TBL(i1).element_number,
    P_STMT_TBL(i1).element_type_id,
    l_status,
    P_STMT_TBL(i1).access_level,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    P_STMT_TBL(i1).content_type );

  INSERT INTO CS_KB_ELEMENTS_TL (
    element_id,
    name,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    language,
    source_lang
  ) SELECT
    P_STMT_TBL(i1).element_id,
    P_STMT_TBL(i1).name,
    sysdate,
    -1351,
    sysdate,
    -1351,
    -1351,
    l.language_code,
    USERENV('LANG')
  FROM FND_LANGUAGES l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM CS_KB_ELEMENTS_TL t
    WHERE t.element_id = P_STMT_TBL(i1).element_id
    AND t.language = l.language_code);

  INSERT INTO CS_KB_SET_ELES (SET_ID,
                             ELEMENT_ID,
                             ELEMENT_ORDER,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_LOGIN)
                      VALUES( P_SOLN_REC.set_id,
                              P_STMT_TBL(i1).element_id,
                              b,
                              sysdate,
                              -1351,
                              sysdate,
                              -1351,
                              -1351);
    b := b+1;
    i1 := P_STMT_TBL.NEXT(i1);
  end loop;

  i2 := p_CAT_TBL.FIRST;
  while i2 is not null loop
  dbms_output.put_line('Add Cat'||p_CAT_TBL(i2) );
     INSERT INTO CS_KB_SET_CATEGORIES (SET_ID,
                                       CATEGORY_ID,
                                       CREATION_DATE,
                                       CREATED_BY,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_LOGIN )
     VALUES ( P_SOLN_REC.set_id,
              p_CAT_TBL(i2),
              sysdate,
              -1351,
              sysdate,
              -1351,
              -1351);
   i2 := P_CAT_TBL.NEXT(i2);
  end loop;
  if fnd_api.to_boolean( p_commit ) then
        commit;
  end if;
END Create_Solution;


--Delete solution
PROCEDURE Delete_Solution (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_SET_ID             IN NUMBER)
IS
    CURSOR Get_Elements IS
        SELECT ELEMENT_ID
        FROM CS_KB_SET_ELES
        WHERE SET_ID = P_SET_ID;
    l_element_id NUMBER;
BEGIN
    --Remove Solution
    DELETE FROM CS_KB_SETS_B  WHERE SET_ID = P_SET_ID;
    DELETE FROM CS_KB_SETS_TL WHERE SET_ID = P_SET_ID;
    --Remove Solution Category
    DELETE FROM CS_KB_SET_CATEGORIES WHERE SET_ID = P_SET_ID;
    --Remove Solution Statements
    OPEN  Get_Elements;
    LOOP
        FETCH Get_Elements INTO l_element_id;
        EXIT WHEN Get_Elements%NOTFOUND;
        DELETE FROM CS_KB_ELEMENTS_B  WHERE ELEMENT_ID = l_element_id;
        DELETE FROM CS_KB_ELEMENTS_TL WHERE ELEMENT_ID = l_element_id;
        DELETE FROM CS_KB_SET_ELES WHERE SET_ID = P_SET_ID and ELEMENT_ID = l_element_id;
    END LOOP;
    CLOSE Get_Elements;
    if fnd_api.to_boolean( p_commit ) then
      commit;
    end if;
END Delete_Solution;

--Delete solution
PROCEDURE Obsolete_Solution (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_SET_ID             IN NUMBER)
IS
BEGIN
    --Remove Solution
    UPDATE CS_KB_SETS_B  SET STATUS = 'OBS' WHERE SET_ID = P_SET_ID;
END Obsolete_Solution;

--Get next solution ID from sequence
FUNCTION Get_Next_Set_ID
RETURN NUMBER
IS
    l_next_val number;
BEGIN
    SELECT CS_KB_SETS_S.NEXTVAL INTO l_next_val FROM DUAL;
    return l_next_val;
END;

--Get next solution Number from sequence
FUNCTION Get_Next_Set_Number
RETURN NUMBER
IS
    l_next_val number;
BEGIN
    SELECT CS_KB_SET_NUMBER_S.NEXTVAL INTO l_next_val FROM DUAL;
    return l_next_val;
END;

--Get next statement ID from sequence
FUNCTION Get_Next_Element_ID
RETURN NUMBER
IS
    l_next_val number;
BEGIN
    SELECT CS_KB_ELEMENTS_S.NEXTVAL INTO l_next_val FROM DUAL;
    return l_next_val;
END;

--Get next statement number from sequence
FUNCTION Get_Next_Element_Number
RETURN NUMBER
IS
    l_next_val number;
BEGIN
    SELECT CS_KB_ELEMENT_NUMBER_S.NEXTVAL INTO l_next_val FROM DUAL;
    return l_next_val;
END;

--Get next category ID
FUNCTION Get_Next_Category_ID
RETURN NUMBER
IS
    l_next_val number;
BEGIN
    SELECT CS_KB_SOLN_CATEGORIES_S.NEXTVAL INTO l_next_val FROM DUAL;
    return l_next_val;
END;

FUNCTION Calculate_Set_Index_Content (P_SET_ID IN NUMBER)
RETURN VARCHAR2
IS
l_lob CLOB;
l_len INTEGER;
l_offset INTEGER;
l_text_content varchar2(4000) := '';
begin
    dbms_lob.createtemporary(l_lob, TRUE, dbms_lob.session);
    cs_kb_ctx_pkg.Synthesize_Solution_Content(P_SET_ID,userenv('LANG'),l_lob);
    l_len := dbms_lob.GETLENGTH(l_lob);
    l_offset := 1;

    while l_len > 100 loop
        l_text_content := l_text_content || dbms_lob.substr(l_lob,100,l_offset);
        l_offset := l_offset + 100;
        l_len := l_len - 100;
    end loop;
        l_text_content := l_text_content || dbms_lob.substr(l_lob,l_len,l_offset);
        dbms_output.put_line(substr(l_text_content,0,200));
    return l_text_content;
end;


END CSK_SETUP_UTILITY_PKG;

/
