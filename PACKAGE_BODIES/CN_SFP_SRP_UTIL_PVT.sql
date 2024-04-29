--------------------------------------------------------
--  DDL for Package Body CN_SFP_SRP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SFP_SRP_UTIL_PVT" AS
-- $Header: cnvsfsrb.pls 115.4 2004/01/27 02:24:07 fmburu noship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_SFP_SRP_UTIL_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvsfsrb.pls';

FUNCTION contains(value NUMBER, collection DBMS_SQL.NUMBER_TABLE)
RETURN BOOLEAN
IS
BEGIN
    IF collection IS NULL THEN
        RETURN FALSE ;
    END IF ;
    IF collection.count > 0 THEN
        FOR i IN collection.first..collection.last LOOP
            IF value = collection(i) THEN
              RETURN TRUE;
            END IF ;
        END LOOP ;
    END IF ;
    RETURN FALSE ;
END ;

FUNCTION getString(prefix VARCHAR2,collection DBMS_SQL.NUMBER_TABLE, cond BOOLEAN)
RETURN VARCHAR2
IS
  l_ret_val  VARCHAR2(2000) := NULL ;
  l_count    NUMBER         := 0 ;
BEGIN
    IF collection IS NULL THEN
        RETURN NULL ;
    END IF ;
    IF collection.count > 0 THEN
        l_count := l_count + 1 ;
        FOR i IN collection.FIRST..collection.LAST LOOP
        IF i > 1 THEN
            l_ret_val := l_ret_val || ',' ;
        END IF ;
        IF cond THEN
          l_ret_val := l_ret_val || collection(i) ;
        ELSE
          l_ret_val := l_ret_val || ':' || prefix || i ;
        END IF ;
        END LOOP ;
    ELSE
        RETURN NULL ;
    END IF ;
    RETURN l_ret_val ;
END ;

PROCEDURE addBindVariables( csr NUMBER, prefix VARCHAR2, collection DBMS_SQL.NUMBER_TABLE)
IS
BEGIN
    IF collection IS NULL OR collection.count < 1 THEN
      return ;
    END IF ;
    FOR z IN collection.FIRST..collection.LAST LOOP
         DBMS_SQL.bind_variable(csr, prefix || z ,collection(z)) ;
    END LOOP ;
END ;


PROCEDURE Get_Groups_In_Hierarchy
(
     p_include_array        IN         DBMS_SQL.NUMBER_TABLE ,
     p_exclude_array        IN         DBMS_SQL.NUMBER_TABLE ,
     p_date                 IN         DATE := SYSDATE,
     x_hierarchy_groups     OUT NOCOPY DBMS_SQL.NUMBER_TABLE
)
IS
     l_ret_array             DBMS_SQL.NUMBER_TABLE ;
     l_include_string        VARCHAR2(2000) := 'X'  ;
     l_exclude_string        VARCHAR2(2000) := ' '  ;
     l_exclude_string_2      VARCHAR2(2000) := ' '  ;
     l_sql                   VARCHAR2(4000) := ' '  ;
     l_date                  DATE := NULL ;

     select_cursor           NUMBER  := 0 ;
     l_match_rows            NUMBER  := 0 ;

     l_valid_1    VARCHAR2(500)  := ' grl.delete_flag = ''N'' AND :DATE1 BETWEEN Trunc(grl.start_date_active) AND NVL(Trunc(grl.end_date_active), :DATE2 ) ' ;
     l_valid_2    VARCHAR2(500)  := ' grl.delete_flag = ''N'' AND :DATE3 BETWEEN Trunc(grl.start_date_active) AND NVL(Trunc(grl.end_date_active), :DATE4 ) ' ;
     l_valid_3    VARCHAR2(500)  := ' grl.delete_flag = ''N'' AND :DATE5 BETWEEN Trunc(grl.start_date_active) AND NVL(Trunc(grl.end_date_active), :DATE6 ) ' ;
BEGIN

    l_date  := NVL(p_date, SYSDATE) ;
    x_hierarchy_groups := l_ret_array;

    IF p_include_array IS NOT NULL AND p_include_array.count > 0 THEN
       l_include_string   := getString('INCBIND',  p_include_array,FALSE) ;
       l_exclude_string   := ' ' ;
       l_exclude_string_2 := ' ' ;

       IF p_exclude_array IS NOT NULL AND p_exclude_array.count > 0 THEN
           l_exclude_string   := getString('EXBIND' , p_exclude_array,FALSE)   ;
           l_exclude_string_2 := getString('EX2BIND' ,p_exclude_array,FALSE)   ;
           l_exclude_string   := ' AND GROUP_ID NOT IN ( '         || l_exclude_string   || ' ) ' ;
           l_exclude_string_2 := ' AND RELATED_GROUP_ID NOT IN ( ' || l_exclude_string_2 || ' ) ' ;
       END IF ;

        l_sql :=
          'SELECT DISTINCT group_id      '       ||
          'FROM jtf_rs_grp_relations grl '       ||
          'WHERE '      || l_valid_1  || '     ' || l_exclude_string   ||
          'START WITH related_group_id IN ('     || l_include_string   ||  ') AND ' || l_valid_2 ||
          'CONNECT BY ' || l_valid_3  || '     ' || l_exclude_string_2 ||
          '  AND PRIOR GROUP_ID = RELATED_GROUP_ID ' ;

        --insert into fam_temp(attr1,time)values(l_sql,sysdate) ;
        --commit ;

        select_cursor := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.parse(select_cursor, l_sql, DBMS_SQL.NATIVE);
        DBMS_SQL.define_array  (select_cursor, 1, x_hierarchy_groups, 10, 1);

        DBMS_SQL.bind_variable(select_cursor, ':DATE1', l_date);
        DBMS_SQL.bind_variable(select_cursor, ':DATE2', l_date);
        DBMS_SQL.bind_variable(select_cursor, ':DATE3', l_date);
        DBMS_SQL.bind_variable(select_cursor, ':DATE4', l_date);
        DBMS_SQL.bind_variable(select_cursor, ':DATE5', l_date);
        DBMS_SQL.bind_variable(select_cursor, ':DATE6', l_date);

        addBindVariables(select_cursor,'INCBIND',p_include_array) ;
        addBindVariables(select_cursor,'EXBIND', p_exclude_array) ;
        addBindVariables(select_cursor,'EX2BIND',p_exclude_array) ;
        -- execute
        l_match_rows := DBMS_SQL.EXECUTE(select_cursor);

        LOOP
            l_match_rows := DBMS_SQL.fetch_rows(select_cursor);
            DBMS_SQL.column_value (select_cursor, 1, x_hierarchy_groups);
        EXIT WHEN l_match_rows <> 10 ;
        END LOOP ;

        DBMS_SQL.close_cursor(select_cursor);
     END IF ;

EXCEPTION
   WHEN OTHERS THEN
    IF (DBMS_SQL.is_open(select_cursor)) THEN
        DBMS_SQL.close_cursor(select_cursor);
    END IF;
    RAISE ;
END ;

-- Start of comments
--    API name        : Get_Valid_Plan_Statuses
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_default_all
--                      p_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_values_tab            OUT string_tabletype
--                      x_meanings_tab          OUT string_tabletype
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure gets valid statuses of the salesrep/fm/pa/sm.
--
-- End of comments

PROCEDURE Get_Valid_Plan_Statuses
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_default_all             IN  VARCHAR2 := FND_API.G_FALSE,
   p_type                    IN  VARCHAR2 := 'COMPPLANPROCESS',
   x_values_tab              OUT NOCOPY    string_tabletype,
   x_meanings_tab            OUT NOCOPY    string_tabletype,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Seasonalities';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_error_code NUMBER;
      l_values_tab string_tabletype;
      l_meanings_tab  string_tabletype;
      l_resp_group VARCHAR2(80);
      finalquery VARCHAR2(4000);

      TYPE RC_TYPE IS REF CURSOR;
      RC RC_TYPE;

      compPlanQuery VARCHAR2(4000) := 'SELECT LOOKUP_CODE,MEANING FROM CN_LOOKUPS WHERE
                                       LOOKUP_TYPE = ''PLAN_TYPE_STATUS'' ';
      compPlanExtra VARCHAR2(4000);
      compPlanOrder VARCHAR2(4000) := ' ORDER BY MEANING';
      l_counter     NUMBER := 0;
      l_value       CN_LOOKUPS.LOOKUP_CODE%TYPE;
      l_meaning     CN_LOOKUPS.MEANING%TYPE;
BEGIN

   SAVEPOINT   Get_Valid_Plan_Statuses;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- API body
   l_resp_group := FND_PROFILE.VALUE('CN_SFP_RESP_GROUP');

   IF (l_resp_group is null) THEN
     IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                       FND_MESSAGE.SET_NAME('CN', 'CN_QM_NO_RESP_GROUP');
                       FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Comp Plan Process (Many types can be added)

   IF (p_type = 'COMPPLANPROCESS') THEN
      -- Planning Analyst
      IF (l_resp_group = 'CN_SF_SUPER_USER') THEN
        compPlanExtra := ' AND LOOKUP_CODE IN (''SUBMITTED'',''APPROVED'',''ISSUED'',''ACCEPTED'') ';
      END IF;

      -- Contract Approver
      IF (l_resp_group = 'CN_SF_CONTRACT_APPROVER') THEN
        compPlanExtra := ' AND LOOKUP_CODE IN (''SUBMITTED'',''APPROVED'',''ISSUED'',''ACCEPTED'')';
      END IF;

      -- Finance Manager
      IF (l_resp_group = 'CN_SF_FINANCE_MGR') THEN
         compPlanExtra := ' AND LOOKUP_CODE IN (''SUBMITTED'',''APPROVED'',''ISSUED'',''ACCEPTED'')';
      END IF;


      -- Sales Manager
      IF (l_resp_group = 'CN_SF_SALES_MGR') THEN
         compPlanExtra := ' AND LOOKUP_CODE IN (''SUBMITTED'',''APPROVED'',''ISSUED'',''ACCEPTED'') ';
      END IF;

      compPlanQuery := compPlanQuery || compPlanExtra || compPlanOrder;
      finalquery := compPlanQuery;
   END IF;


   -- Rest of the logic should remain the same

   IF (p_default_all = FND_API.G_TRUE) THEN
       x_values_tab(l_counter) := '%';
       x_meanings_tab(l_counter) := FND_MESSAGE.GET_STRING('CN','CN_ALL');
   END IF;

   OPEN RC FOR finalquery;
   LOOP

       FETCH RC INTO l_value,l_meaning;
       EXIT WHEN RC%NOTFOUND;
       l_counter := l_counter + 1;
       x_values_tab(l_counter)  := l_value;
       x_meanings_tab(l_counter) := l_meaning;

   END LOOP;

   -- End of API body.
   << end_Get_Valid_Plan_Statuses >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Valid_Plan_Statuses  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Valid_Plan_Statuses ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE
   );
   WHEN OTHERS THEN
      ROLLBACK TO Get_Valid_Plan_Statuses ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );
END Get_Valid_Plan_Statuses;




-- Start of comments
--    API name        : Get_All_Groups_Access
--    Type            : Private.
--    Function        :
--    Prereqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      x_update_groups         OUT    DBMS_SQL.NUMBER_TABLE,
--                      x_view_groups           OUT    DBMS_SQL.NUMBER_TABLE,
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure gets the user_access for all groups
--                      in cn_user_access
--
-- End of comments

PROCEDURE Get_All_Groups_Access
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_org_code                IN  VARCHAR2 := NULL,
   p_date                    IN  VARCHAR2,
   x_update_groups           OUT NOCOPY    DBMS_SQL.NUMBER_TABLE,
   x_view_groups             OUT NOCOPY    DBMS_SQL.NUMBER_TABLE,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 )
IS
    l_api_name     CONSTANT VARCHAR2(30) := 'Get_All_Groups_Access';
    l_api_version  CONSTANT NUMBER  := 1.0;

    VIEW_ARRAY          DBMS_SQL.NUMBER_TABLE;
    UPDATE_ARRAY        DBMS_SQL.NUMBER_TABLE;
    L_REG_GROUPS        DBMS_SQL.NUMBER_TABLE ;
    hier_update_groups  DBMS_SQL.NUMBER_TABLE ;
    hier_view_groups    DBMS_SQL.NUMBER_TABLE ;

    select_cursor      NUMBER ;
    l_match_rows NUMBER  := 0 ;
    l_sql          VARCHAR2(4000)  := '' ;

    l_date              DATE := SYSDATE ;
    l_org_code          CN_USER_ACCESSES.ORG_CODE%TYPE := NULL ;
    l_user_id           NUMBER ;
    l_include_string    VARCHAR2(2000)   :=  ' ' ;
    l_exclude_string    VARCHAR2(2000)   :=  ' ' ;
    l_exclude_string_2  VARCHAR2(2000) :=  ' ' ;
    l_include_string_2  VARCHAR2(2000) :=  ' ' ;
    l_all_string        VARCHAR2(2000)  :=  ' ' ;
    l_exc_count         INTEGER := 0 ;
    l_inc_count         INTEGER := 0 ;
    l_count             INTEGER := 0 ;
    l_num               NUMBER  := NULL ;
    l_resp_group        VARCHAR2(240)     := NULL ;


    CURSOR Get_Access(c_user_id NUMBER ,c_date DATE ,p_org_code VARCHAR) IS
    SELECT u.comp_group_id group_id , u.access_code  access_code
    FROM  cn_qm_comp_groups g, cn_user_accesses u
    WHERE u.user_id = c_user_id
    AND   g.comp_group_id = u.comp_group_id
    AND   c_date BETWEEN Trunc(g.start_date_active) AND
          Nvl(Trunc(g.end_date_active), c_date )
    AND   ((u.org_code LIKE p_org_code) OR (p_org_code IS NULL)) ;

BEGIN
   SAVEPOINT   Get_All_Groups_Access;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   l_resp_group := fnd_profile.value('CN_SFP_RESP_GROUP');
   IF l_resp_group IS  null THEN
      IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
          FND_MESSAGE.SET_NAME('CN', 'CN_QM_NO_RESP_GROUP');
        FND_MSG_PUB.Add;
        END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_resp_group <> 'CN_SF_FINANCE_MGR' THEN
      RETURN ;
   END IF ;

   l_date     := p_date ;
   l_org_code := p_org_code ;
   l_user_id  := fnd_global.user_id ;

   --dbms_output.put_line( 'Entering') ;

   FOR retCsr IN Get_Access(l_user_id,l_date,l_org_code) LOOP
      IF retCsr.access_code = 'UPDATE' THEN
        l_inc_count := l_inc_count + 1 ;
        UPDATE_ARRAY(l_inc_count) := retCsr.group_id ;
        X_UPDATE_GROUPS(l_inc_count) := retCsr.group_id ;
      ELSIF retCsr.access_code = 'VIEW' THEN
        l_exc_count := l_exc_count + 1 ;
        VIEW_ARRAY(l_exc_count) := retCsr.group_id ;
        X_VIEW_GROUPS(l_exc_count) := retCsr.group_id ;
      END IF ;
      l_count := l_count + 1 ;
      L_REG_GROUPS(l_count) := retCsr.group_id ;
   END LOOP ;

   IF L_REG_GROUPS IS NULL OR L_REG_GROUPS.count < 1 THEN
        RETURN ;
   END IF ;


    -- GET VIEW/UPDATE GROUPS
     Get_Groups_In_Hierarchy(VIEW_ARRAY,UPDATE_ARRAY,l_date,hier_view_groups) ;
     Get_Groups_In_Hierarchy(UPDATE_ARRAY,VIEW_ARRAY,l_date,hier_update_groups) ;


    -- ADD GROUPS UNDER THE ROOT
    IF hier_view_groups.count > 0 THEN
        FOR i IN hier_view_groups.first..hier_view_groups.last LOOP
          IF hier_view_groups.exists(i) THEN
             X_VIEW_GROUPS(l_inc_count+i) := hier_view_groups(i) ;
          END IF ;
        END LOOP ;
    END IF ;

    IF hier_update_groups.count > 0 THEN
        FOR i IN hier_update_groups.first..hier_update_groups.last LOOP
            X_UPDATE_GROUPS(l_inc_count+i) := hier_update_groups(i) ;
        END LOOP ;
    END IF ;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_All_Groups_Access  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_All_Groups_Access ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Get_All_Groups_Access ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name) ;
      END IF ;
      cn_message_pkg.debug(G_PKG_NAME || ' ' || l_api_name ||' '||TO_CHAR(SQLCODE)||': '||SQLERRM) ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
END Get_All_Groups_Access;


-- Start of comments
--    API name        : Get_Group_Access
--    Type            : Private.
--    Function        :
--    Prereqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_default_all
--                      p_group_id
--                      p_update_groups         IN      DBMS_SQL.NUMBER_TABLE,
--                      p_view_groups           IN      DBMS_SQL.NUMBER_TABLE,
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_privilege             OUT     VARCHAR2,
--    Version :         Current version       1.0
--
--
--    Notes           : This procedure gets valid statuses of the salesrep/fm/pa/sm.
--
-- End of comments

PROCEDURE Get_Group_Access
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_group_id                IN  NUMBER,
   p_update_groups           IN  DBMS_SQL.NUMBER_TABLE,
   p_view_groups             IN  DBMS_SQL.NUMBER_TABLE,
   x_privilege               OUT NOCOPY    VARCHAR2,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 )
IS
    l_api_name     CONSTANT VARCHAR2(30) := 'Get_Group_Access';
    l_api_version  CONSTANT NUMBER  := 1.0;

BEGIN
   SAVEPOINT   Get_Group_Access;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF contains(p_group_id,p_update_groups) THEN
      --dbms_output.put_line('IRead Only');
       x_privilege := 'WRITE' ;
       RETURN ;
  END IF ;

  IF contains(p_group_id,p_view_groups) THEN
      --dbms_output.put_line('IRead Only');
       x_privilege := 'READ' ;
       RETURN ;
  END IF ;

  x_privilege := 'NO_READ' ;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Group_Access  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Group_Access ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Get_Group_Access ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name) ;
      END IF ;
      FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count ,
                                p_data    =>  x_msg_data  ,
                                p_encoded => FND_API.G_FALSE);
END Get_Group_Access;

END CN_SFP_SRP_UTIL_PVT;

/
