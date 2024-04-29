--------------------------------------------------------
--  DDL for Package Body IEX_FILTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_FILTER_PUB" AS
/* $Header: iexpfilb.pls 120.6.12010000.7 2010/06/02 11:21:05 barathsr ship $ */

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'IEX_FILTER_PUB';
G_FILE_NAME  CONSTANT VARCHAR2(12) := 'iexpfilb.pls';
G_Batch_Size NUMBER := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '1000'));
PG_DEBUG NUMBER;

/*
|| Overview: this function will return a dynamic SQL statement to
|| execute as the universe of  objects to score for a particular
|| scoring engine
||
|| Parameter: p_object_id   Scoring_Engine or Strategy Engine attached to the universe
||            p_object_type = EITHER SCORE OR STRATEGY
||
|| Return value: table of ids for the universe
||
|| Source Tables: IEX_OBJECT_FILTERS
||
|| Target Tables: none
||
|| Creation date:  01/09/02 3:38:PM
||
|| Major Modifications: when            who                       what
||                      01/09/02        raverma             created
*/
-- Start for bug 9387044
function buildsql(p_object_id IN NUMBER
                  ,p_object_type IN VARCHAR2
                  ,p_query_obj_id in varchar2    --Added for Bug 9670348 27-May-2009 barathsr
		  ,p_limit_rows in number default null)  --Added for Bug 9670348 27-May-2009 barathsr
		      return varchar2
is
  l_select_column varchar2(30);
  l_entity_name varchar2(30);
  vstr1   varchar2(100);
  vstr2   varchar2(100);
  vstr3   varchar2(100);
  vstr4   varchar2(100);
  vPLSQL  varchar2(1000);
begin

    vstr1   := 'SELECT ';
    vstr2   := '  FROM ';
    vstr3   := ' WHERE ';
    vstr4   := ' IS NOT NULL ';

    execute immediate
        'Select select_column, entity_name        ' ||
        ' From IEX_OBJECT_FILTERS                 ' ||
        ' Where object_id = :p_object_id AND      ' ||
        ' Object_Filter_Type = :p_object_Type     '
    into l_select_column , l_entity_name
    using p_object_id, p_object_Type;

     vPLSQL:=  vstr1 || l_select_column ||
               vstr2 || l_entity_name ||
               vstr3 || l_select_column || vstr4;

	       --Begin Bug 9670348 27-May-2010 barathsr
	        if p_query_obj_id is not null then
	        vPLSQL:=  vPLSQL||' AND ' || l_select_column || ' IN ('||p_query_obj_id||')';
	      end if;

	      if p_limit_rows is not null then
	         vPLSQL:=  vPLSQL|| ' AND ROWNUM <= '|| p_limit_rows;
              end if;
           --End  Bug 9670348 27-May-2010 barathsr
              vPLSQL:= vPLSQL|| ' ORDER BY ' || l_select_column;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring engine object filter SQL: ' || vPLSQL);

   return vPLSQL;

   exception
   when others then
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Failed to construct Scoring engine object filter');
      return vPLSQL;

end buildsql;

-- end for bug 9387044

function buildUniverse(p_object_id IN NUMBER
                      ,p_query_obj_id in varchar2    --Added for Bug 8933776 16-Dec-2009 barathsr
		      ,p_limit_rows in number default null  --Added for Bug 8933776 16-Dec-2009 barathsr
                      ,p_object_type IN VARCHAR2
                      ,p_last_object_scored in out nocopy number
                      ,x_end_of_universe out nocopy boolean) return IEX_FILTER_PUB.UNIVERSE_IDS

IS
    l_select_column varchar2(30); -- select column for universeQuery
    l_entity_name varchar2(30);   -- entity for universeQuery

    Type refCur is Ref Cursor;
    --object_cur refCur;
    vPLSQL                varchar2(2000);
    Universe_cur          refCur;
    l_universe_ids        IEX_FILTER_PUB.UNIVERSE_IDS;
    i                     number := 0;
    l_last_object_scored  number;
    l_api_name            varchar2(20);

    -- clchang updated for sql bind var 05/07/2003
    vstr1   varchar2(100);
    vstr2   varchar2(100);
    vstr3   varchar2(100);
    vstr4   varchar2(100);


begin

    l_api_name := 'buildUniverse';
    x_end_of_universe := true;

    IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ': Start time      ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ': p_object_id =   ' || p_object_id);
    IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ': p_object_type = ' || p_object_type);
    IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ': p_last_object_scored = ' || p_last_object_scored);

--chang updated for sql bind var 05/07/2003
    vstr1   := 'SELECT ';
    vstr2   := '  FROM ';
    vstr3   := ' WHERE ';
    vstr4   := ' is not null ';

    if p_last_object_scored is null then
        l_last_object_scored := 0;
    else
        l_last_object_scored := p_last_object_scored;
    end if;

    -- figure out the universe to select from
    execute immediate
        'Select select_column, entity_name        ' ||
        ' From IEX_OBJECT_FILTERS                 ' ||
        ' Where object_id = :p_object_id AND      ' ||
        ' Object_Filter_Type = :p_object_Type     '
    into l_select_column , l_entity_name
    using p_object_id, p_object_Type;



    -- build SQL for universe
    -- clchang updated for sql bind var 05/07/2003

     vPLSQL:= vstr1 || l_select_column ||
              vstr2 || l_entity_name ||
              vstr3 || l_select_column || vstr4 ||
              '   AND ' || l_select_column || ' > :1 ' ;  --l_last_object_scored || --Added bind variable for bug#7166924 by schekuri on 25-Aug-2008
            --Begin Bug 8933776 16-Dec-2009 barathsr
	      if p_query_obj_id is not null then
	        vPLSQL:=  vPLSQL||' AND ' || l_select_column || ' IN ('||p_query_obj_id||')';
	      end if;

	      if p_limit_rows is not null then
	         vPLSQL:=  vPLSQL|| ' AND ROWNUM <= '|| p_limit_rows;
              end if;
           --End  Bug 8933776 16-Dec-2009 barathsr
              vPLSQL:= vPLSQL|| ' ORDER BY ' || l_select_column;



    IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ': vPLSQL is ' ||  vPLSQL );
     FND_FILE.PUT_LINE(FND_FILE.LOG,'sql-->'||vPLSQL);

    -- "fill" the universe
    open universe_cur for
            vPLSQL using l_last_object_scored;   --Added bind variable for bug#7166924 by schekuri on 25-Aug-2008
     --Begin bug#7166924 by schekuri on 25-Aug-2008
     fetch universe_cur  BULK COLLECT INTO l_universe_ids limit G_Batch_Size;

     if l_universe_ids.count=G_BATCH_SIZE then
        x_end_of_universe := false;
	p_last_object_scored := l_universe_ids(l_universe_ids.last);
	return l_universe_ids;
     end if;
    /*LOOP
        if i > G_Batch_Size then
             x_end_of_universe := false;
             IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ':Batch size met');
             IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ':last object : ' || p_last_object_scored);
             return l_universe_ids;
        end if;
        i := i + 1;
    fetch universe_cur into l_universe_ids(i);
          p_last_object_scored := l_universe_ids(i);
    exit when universe_cur%NOTFOUND;
    end loop;*/
    --End bug#7166924 by schekuri on 25-Aug-2008

    x_end_of_universe := true;
    IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ': Reached the End');

    close universe_cur;
    return l_universe_ids;
    -- FND_FILE.PUT_LINE(FND_FILE.LOG,'unv_size-->'||l_universe_ids.count);
    IEX_DEBUG_PUB.logMessage(G_PKG_NAME || ': ' || l_api_name || ': End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

exception

    When No_Data_Found then
        IEX_DEBUG_PUB.logMessage('IEX_FILTER_PUB: buildUniverse: ' || sqlerrm ||' ' || sqlcode);
        return l_universe_ids;
    When others Then
        IEX_DEBUG_PUB.logMessage('IEX_FILTER_PUB: buildUniverse: ' || sqlerrm ||' ' || sqlcode);
        return l_universe_ids;
end buildUniverse;

Procedure Validate_FILTER(P_Init_Msg_List              IN   VARCHAR2 := FND_API.G_FALSE,
                          P_FILTER_rec                 IN   IEX_FILTER_PUB.FILTER_REC_TYPE,
                          X_Dup_Status                 OUT NOCOPY  VARCHAR2,
                          X_Return_Status              OUT NOCOPY  VARCHAR2,
                          X_Msg_Count                  OUT NOCOPY  NUMBER,
                          X_Msg_Data                   OUT NOCOPY  VARCHAR2)

IS
    l_filter_rec          IEX_FILTER_PUB.FILTER_REC_TYPE;
    l_table_name varchar2(50);
    l_col_name   varchar2(25);
    l_return_Status varchar2(1);
    L_API_NAME  varchar2(25);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
    L_API_NAME   := 'Validate_Filter';
    l_filter_rec           := p_filter_rec;
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter');

     -- api body
     -- validate object_filter_id
     /*
     IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID        => p_filter_rec.object_filter_id,
                                   P_COL_NAME      => 'OBJECT_FILTER_ID',
                                   P_TABLE_NAME    => 'IEX_OBJECT_FILTERS',
                                   X_Return_Status => x_return_status,
                                   X_Msg_Count     => x_msg_count,
                                   X_Msg_Data      => x_msg_data,
                                   p_init_msg_list => fnd_api.g_false);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     */

      iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:Validate_Any_VARCHAR');
     -- validate object_filter_name
     IEX_UTILITIES.VALIDATE_ANY_VARCHAR(P_COL_VALUE     => p_filter_rec.object_filter_name,
                                        P_COL_NAME      => 'OBJECT_FILTER_NAME',
                                        P_TABLE_NAME    => 'IEX_OBJECT_FILTERS',
                                        X_Return_Status => l_return_status,
                                        X_Msg_Count     => x_msg_count,
                                        X_Msg_Data      => x_msg_data,
                                        p_init_msg_list => fnd_api.g_false);
     --dbms_output.put_line('Validating Obj Filter Name ' || l_return_status);
  iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:Validate_Any_VARCHAR:'||l_return_status);

     -- if found API will return 'S' therefore we have a duplicate Filter_Name
     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_dup_status := IEX_SCORE_PVT.IEX_DUPLICATE_NAME;
        RAISE FND_API.G_EXC_ERROR;
	   --dbms_output.put_line('dup=' || x_dup_status);
     END IF;

     -- validate lookup_type/ code
  iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:Validate_lookup_Code:');
  iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:lookup_code:'||p_filter_rec.object_filter_type);
     IEX_UTILITIES.validate_lookup_code(P_LOOKUP_TYPE   => 'IEX_OBJECT_FILTERS',
                                       P_LOOKUP_CODE   => p_filter_rec.OBJECT_FILTER_TYPE,
                                       X_Return_Status => l_return_status,
                                       X_Msg_Count     => x_msg_count,
                                       X_Msg_Data      => x_msg_data,
                                       p_init_msg_list => fnd_api.g_false,
                                       p_lookup_view   => 'IEX_LOOKUPS_V');

  iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:Validate_lookup_Code:'||l_return_status);
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     --dbms_output.put_line('Validating Obj Filter Type ' || l_return_status);

     -- validate object_id
     if p_filter_rec.object_filter_type = 'IEXSCORE' then
        l_table_name := 'IEX_SCORES';
        l_col_name := 'SCORE_ID';
     elsif p_filter_rec.object_filter_type = 'IEXSTRAT' then
        l_table_name := 'IEX_STRATEGY_TEMPLATES_B';
        l_col_name := 'STRATEGY_TEMP_ID';
     elsif p_filter_rec.object_filter_type = 'IEXAGING' then
        l_table_name := 'AR_AGING_BUCKETS';
        l_col_name := 'AGING_BUCKET_ID';
     -- added by jypark 02/21/2002 for Customer Status Stratification
     elsif p_filter_Rec.object_filter_type = 'IEXCUST' then
        l_table_name := 'IEX_CUST_STATUS_RULES';
        l_col_name := 'STATUS_RULE_ID';
     end if;

  iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:Validate_any_id:');
     IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID        => p_filter_rec.object_id,
                                   P_COL_NAME      => l_col_name,
                                   P_TABLE_NAME    => l_table_name,
                                   X_Return_Status => l_return_status,
                                   X_Msg_Count     => x_msg_count,
                                   X_Msg_Data      => x_msg_data,
                                       p_init_msg_list => fnd_api.g_false);
     --dbms_output.put_line('Validating Object ID ' || l_return_status );
  iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:Validate_any_id:'||l_return_status);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

   /*******************************
    * BUG 4113025
    * since validate_filter will be called by create_object_filter only,
    * create_object_filter should be from HTML/ADMIN,
    * and ADMIN UI will check ENTITY and COLUMN,
    * we dont validate entity(view) and column here.
    *
     -- validate entity_name
  iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:Validate_any_varchar');
     IEX_UTILITIES.VALIDATE_ANY_VARCHAR(P_COL_VALUE     => p_filter_rec.ENTITY_NAME,
                                        P_COL_NAME      => 'VIEW_NAME',
                                        P_TABLE_NAME    => 'ALL_VIEWS',
                                        X_Return_Status => l_return_status,
                                        X_Msg_Count     => x_msg_count,
                                        X_Msg_Data      => x_msg_data,
                                       p_init_msg_list => fnd_api.g_false);
     --dbms_output.put_line('Validating Entity Name ' || l_return_status );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- validate select_column
  iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:Validate_any_varchar');
     IEX_UTILITIES.VALIDATE_ANY_VARCHAR(P_COL_VALUE     => p_filter_rec.SELECT_COLUMN,
                                        P_COL_NAME      => 'COLUMN_NAME',
                                        P_TABLE_NAME    => 'ALL_TAB_COLUMNS',
                                        X_Return_Status => l_return_status,
                                        X_Msg_Count     => x_msg_count,
                                        X_Msg_Data      => x_msg_data,
                                       p_init_msg_list => fnd_api.g_false);
     --dbms_output.put_line('Validating Select Column ' || l_return_status);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   ************************************************/


      x_return_status := l_return_status;
      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

Exception
          WHEN FND_API.G_EXC_ERROR THEN
             iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:EXC ERROR');
             x_return_status := FND_API.G_RET_STS_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:err='||SQLERRM);
             FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:UNEXC ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:OTHERS ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:Validate_Filter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );


END Validate_FILTER;


Procedure Create_OBJECT_FILTER
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
            P_FILTER_REC              IN IEX_FILTER_PUB.FILTER_REC_TYPE  := G_MISS_FILTER_REC,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            X_FILTER_ID               OUT NOCOPY NUMBER)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Object_Filter';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_FILTER_REC                  IEX_FILTER_PUB.FILTER_REC_TYPE ;
    l_object_filter_id            NUMBER ;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OBJECT_FILTER_PVT;

    l_FILTER_REC                  := P_FILTER_REC;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      iex_dunning_pvt.WriteLog('iexpfilb:CreateFilter:Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Validate Data
      iex_dunning_pvt.WriteLog('iexpfilb:CreateFilter:Calling Validate_Filter');
      Validate_FILTER(P_FILTER_rec        => l_filter_rec,
                      X_Dup_Status        => x_dup_status,
                      X_Return_Status     => l_return_status,
                      X_Msg_Count         => l_msg_count,
                      X_Msg_Data          => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      iex_dunning_pvt.WriteLog('iexpfilb:CreateFilter:get object_filter_id from seq');

      Select IEX_OBJECT_FILTERS_S.nextval into x_filter_id
        From Dual;
      iex_dunning_pvt.WriteLog('iexpfilb:CreateFilter:object_filter_id='||x_filter_id);

      iex_dunning_pvt.WriteLog('iexpfilb:CreateFilter:insert row');

      -- Create Filter
      IEX_OBJECT_FILTERS_PKG.insert_row(
           x_rowid                   => l_rowid
          ,p_object_filter_id        => x_filter_id
          ,p_object_filter_type      => l_FILTER_REC.object_filter_type
          ,p_object_filter_name      => l_FILTER_REC.object_filter_name
          ,p_object_id               => l_FILTER_REC.object_id
          ,p_select_column           => l_FILTER_REC.select_column
          ,p_entity_name             => l_FILTER_REC.entity_name
          ,p_active_flag             => l_filter_rec.active_flag
          ,p_object_version_number   => 1
          ,P_CREATED_BY              => FND_GLOBAL.USER_ID
          ,P_CREATION_DATE           => sysdate
          ,P_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID
          ,P_LAST_UPDATE_DATE        => sysdate
          ,P_LAST_UPDATE_LOGIN       => FND_GLOBAL.USER_ID);

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      iex_dunning_pvt.WriteLog('iexpfilb:CreateFilter:end');

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_OBJECT_FILTER_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:CreatedFilter:EXC ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:CreatedFilter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_OBJECT_FILTER_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:CreatedFilter:UNEXC ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:CreatedFilter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
              ROLLBACK TO CREATE_OBJECT_FILTER_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:CreatedFilter:OTHER ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:CreatedFilter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

END CREATE_OBJECT_FILTER;


Procedure Update_OBJECT_FILTER
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
            P_FILTER_REC              IN IEX_FILTER_PUB.FILTER_REC_TYPE  := G_MISS_FILTER_REC,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'UPdate_Object_Filter';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_FILTER_REC                  IEX_FILTER_PUB.FILTER_REC_TYPE ;
    l_filter_ref_rec              IEX_FILTER_PUB.FILTER_REC_TYPE;
    l_name_cnt                    NUMBER;


    CURSOR C_CHK_FILTER_NAME (IN_OBJECT_FILTER_ID NUMBER, IN_NAME VARCHAR) IS
	  SELECT COUNT(OBJECT_FILTER_NAME)
	    FROM IEX_OBJECT_FILTERS
        WHERE OBJECT_FILTER_ID <> IN_OBJECT_FILTER_ID
		AND OBJECT_FILTER_NAME = IN_NAME;

    CURSOR C_get_filter_Rec (IN_FILTER_ID NUMBER) is
       SELECT   ROWID
               ,OBJECT_FILTER_ID
               ,OBJECT_FILTER_TYPE
               ,OBJECT_FILTER_NAME
               ,OBJECT_ID
               ,SELECT_COLUMN
               ,ENTITY_NAME
               ,ACTIVE_FLAG
               ,OBJECT_VERSION_NUMBER
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,LAST_UPDATE_LOGIN
         from iex_object_filters
        where object_filter_id = in_filter_id
        FOR UPDATE NOWAIT;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OBJECT_FILTER_PVT;

    l_FILTER_REC          := P_FILTER_REC;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- added by clchang 02/25/2002
	 -- validate dup filter_Name
      iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:validation:chk_dup_filter_name');
      Open C_chk_filter_name(l_FILTER_REC.OBJECT_FILTER_ID,
			    l_FILTER_REC.OBJECT_FILTER_NAME);
      Fetch C_chk_filter_name into l_NAME_CNT;
      if (l_name_cnt > 0) then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'IEX_API_DUPLICATE_NAME');
            FND_MESSAGE.Set_Token ('COLUMN', 'OBJECT_FILTER_NAME', FALSE);
            FND_MESSAGE.Set_Token ('VALUE', l_Filter_rec.object_filter_name, FALSE);
            FND_MSG_PUB.Add;
        END IF;
        x_dup_status := IEX_SCORE_PVT.IEX_DUPLICATE_NAME;
        iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:dup object_filter_name');
        RAISE FND_API.G_EXC_ERROR;
	 end if;
      close C_chk_filter_name;

      --
      -- API body
      --
      Open C_get_filter_Rec(l_FILTER_REC.OBJECT_FILTER_ID);
      Fetch C_get_filter_Rec into
          l_rowid
         ,l_filter_ref_rec.OBJECT_FILTER_ID
         ,l_filter_ref_rec.OBJECT_FILTER_TYPE
         ,l_filter_ref_rec.OBJECT_FILTER_NAME
         ,l_filter_ref_rec.OBJECT_ID
         ,l_filter_ref_rec.SELECT_COLUMN
         ,l_filter_ref_rec.ENTITY_NAME
         ,l_filter_ref_rec.ACTIVE_FLAG
         ,l_filter_ref_rec.OBJECT_VERSION_NUMBER
         ,l_filter_ref_rec.CREATION_DATE
         ,l_filter_ref_rec.CREATED_BY
         ,l_filter_ref_rec.LAST_UPDATE_DATE
         ,l_filter_ref_rec.LAST_UPDATED_BY
         ,l_filter_ref_rec.LAST_UPDATE_LOGIN;

        IF (C_get_filter_Rec%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_object_filters', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      close C_get_filter_Rec;


      IF (l_filter_ref_rec.last_update_date is NULL or
         l_filter_ref_rec.last_update_date = FND_API.G_MISS_Date)
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      End IF;

      -- Transfer Data into target record
      l_filter_rec.CREATION_DATE := l_filter_ref_rec.CREATION_DATE;
      l_filter_rec.CREATED_BY := l_filter_ref_rec.CREATED_BY;

      IF ((l_filter_rec.OBJECT_FILTER_NAME = FND_API.G_MISS_CHAR) OR
          (l_filter_rec.OBJECT_FILTER_NAME = NULL))  THEN
         l_filter_rec.OBJECT_FILTER_NAME := l_filter_ref_rec.OBJECT_FILTER_NAME;
      END IF;
      IF ((l_filter_rec.OBJECT_FILTER_TYPE = FND_API.G_MISS_CHAR) OR
          (l_filter_rec.OBJECT_FILTER_TYPE = NULL)) THEN
         l_filter_rec.OBJECT_FILTER_TYPE := l_filter_ref_rec.OBJECT_FILTER_TYPE;
      END IF;
      IF ((l_filter_rec.OBJECT_ID = FND_API.G_MISS_NUM) OR
          (l_filter_rec.OBJECT_ID = NULL)) THEN
         l_filter_rec.OBJECT_ID := l_filter_ref_rec.OBJECT_ID;
      END IF;
      IF ((l_filter_rec.SELECT_COLUMN = FND_API.G_MISS_CHAR) OR
          (l_filter_rec.SELECT_COLUMN = NULL)) THEN
         l_filter_rec.SELECT_COLUMN := l_filter_ref_rec.SELECT_COLUMN;
      END IF;
      IF ((l_filter_rec.ENTITY_NAME = FND_API.G_MISS_CHAR) OR
          (l_filter_rec.ENTITY_NAME = NULL)) THEN
         l_filter_rec.ENTITY_NAME := l_filter_ref_rec.ENTITY_NAME;
      END IF;
      IF ((l_filter_rec.ACTIVE_FLAG = FND_API.G_MISS_CHAR) OR
          (l_filter_rec.ACTIVE_FLAG = NULL)) THEN
         l_filter_rec.ACTIVE_FLAG := l_filter_ref_rec.ACTIVE_FLAG;
      END IF;
      IF ((l_filter_rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM) OR
          (l_filter_rec.OBJECT_VERSION_NUMBER = NULL)) THEN
         l_filter_rec.OBJECT_VERSION_NUMBER := l_filter_ref_rec.OBJECT_VERSION_NUMBER;
      END IF;

      iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:update row');
      IEX_OBJECT_FILTERS_PKG.update_row(
           x_rowid                   => l_rowid
          ,p_object_filter_id        => l_filter_rec.object_filter_id
          ,p_object_filter_type      => l_FILTER_REC.object_filter_type
          ,p_object_filter_name      => l_FILTER_REC.object_filter_name
          ,p_object_id               => l_FILTER_REC.object_id
          ,p_select_column           => l_FILTER_REC.select_column
          ,p_entity_name             => l_FILTER_REC.entity_name
          ,p_active_flag             => l_filter_rec.active_flag
          ,p_object_version_number   => 1
          ,P_CREATED_BY              => FND_GLOBAL.USER_ID
          ,P_CREATION_DATE           => sysdate
          ,P_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID
          ,P_LAST_UPDATE_DATE        => sysdate
          ,P_LAST_UPDATE_LOGIN       => FND_GLOBAL.USER_ID);

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:end');

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO UPDATE_OBJECT_FILTER_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:EXC ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO UPDATE_OBJECT_FILTER_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:UNEXC ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
              ROLLBACK TO UPDATE_OBJECT_FILTER_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:OTHER ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:UpdateFilter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );


END UPDATE_OBJECT_FILTER;


Procedure Delete_OBJECT_FILTER
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
            P_OBJECT_FILTER_ID        IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Delete_Object_Filter';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);

    CURSOR C_GET_FILTER (IN_FILTER_ID NUMBER) IS
      SELECT rowid
        FROM IEX_OBJECT_FILTERS
       WHERE OBJECT_FILTER_ID = IN_FILTER_ID;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_OBJECT_FILTER_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      Open C_GET_FILTER(p_object_filter_id);
      Fetch C_GET_FILTER into
         l_rowid;

      IF ( C_GET_FILTER%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_object_filters', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      Close C_GET_FILTER;

      iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:Delete Row');

      -- Invoke table handler
      IEX_object_filters_PKG.Delete_Row(
             x_rowid  => l_rowid);


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:End');

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO DELETE_OBJECT_FILTER_PVT;
             iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:EXP ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:err='||SQLERRM);
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_OBJECT_FILTER_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:UNEXP ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
              ROLLBACK TO DELETE_OBJECT_FILTER_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:OTHER ERROR');
             iex_dunning_pvt.WriteLog('iexpfilb:DeleteFilter:err='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );


END DELETE_OBJECT_FILTER;

BEGIN

PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_FILTER_PUB;

/
