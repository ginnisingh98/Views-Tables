--------------------------------------------------------
--  DDL for Package Body IEX_PARTY_PREF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PARTY_PREF_PUB" AS
/* $Header: iexphppb.pls 120.0.12010000.9 2009/08/12 15:05:10 ehuh ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_PARTY_PREF_PUB';
G_USER_ID    NUMBER := FND_GLOBAL.User_Id;

PROCEDURE assign_collection_level
(
    P_Api_Version_Number         IN   NUMBER DEFAULT 1.0,
    P_Init_Msg_List              IN   VARCHAR2 DEFAULT NULL,
    P_Commit                     IN   VARCHAR2 DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_Insert_Count               OUT NOCOPY  NUMBER,
    X_Update_Count               OUT NOCOPY  NUMBER,
    p_level_tbl                  IN   level_tbl_type) AS

	l_result               VARCHAR2(10);
	l_error_msg            VARCHAR2(2000);
	l_return_status        VARCHAR2(20);
	l_msg_count            NUMBER;
	l_msg_data             VARCHAR2(2000);
	l_api_name             VARCHAR2(100) := 'assign_collection_level' ;
	l_api_version_number   CONSTANT NUMBER   :=1.0;
        l_object_version_number NUMBER;
        l_store_acct          NUMBER :=0;
        l_store_billto        NUMBER :=0;
        l_store_party         NUMBER :=0;
        l_pref_id             NUMBER :=0;
        l_party_preference_id NUMBER;
        j                     NUMBER;
        k                     NUMBER;
	m		      NUMBER;

        I_level_tbl           level_tbl_type;
        U_level_tbl           ulevel_tbl;
	--R_level_tbl           ulevel_tbl;

        type U_level_party_id_t is table of hz_party_preferences.party_id%type index by binary_integer;
        type U_level_objectcode_t is table of hz_party_preferences.value_varchar2%type index by binary_integer;
        type U_level_version_t is table of hz_party_preferences.object_version_number%type index by binary_integer;
	type U_level_pref_id_t is table of hz_party_preferences.party_preference_id%type index by binary_integer;

        U_level_partyids    U_level_party_id_t;
        U_level_objectcodes U_level_objectcode_t;
        U_level_versions    U_level_version_t;
	R_level_prefids     U_level_pref_id_t;

        type I_level_party_id_t is table of hz_party_preferences.party_id%type index by binary_integer;
        type I_level_objectcode_t is table of hz_party_preferences.value_varchar2%type index by binary_integer;

        I_level_partyids    I_level_party_id_t;
        I_level_objectcodes I_level_objectcode_t;

        CURSOR object_version_cur(c_party_id IN NUMBER) IS
           SELECT party_preference_id, object_version_number FROM hz_party_preferences
             WHERE  party_id = c_party_id
               AND  category = 'COLLECTIONS LEVEL'
               AND  preference_code = 'PARTY_ID'
               AND  module = 'COLLECTIONS';


BEGIN

    SAVEPOINT IEX_PARTY_PREF_PUB_START;

    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := 'S';


    iex_debug_pub.logmessage (' IEX_PARTY_PREF_PUB.assign_collection_level - Input Count = ' ||p_level_tbl.count);

    j := 0;
    k := 0;
    m := 0;

    For i In 1..p_level_tbl.count
    Loop

      if p_level_tbl(i).ObjectCode IS NULL then
	   begin
               Open object_version_cur(p_level_tbl(i).party_id);
               Fetch object_version_cur INTO l_pref_id,l_object_version_number;
               if object_version_cur%NOTFOUND then
                  l_object_version_number := 1;
                  l_pref_id := 0;
               end if;
               Close object_version_cur;
              exception
                  when others then
                      l_pref_id := 0;
                      l_object_version_number := 1;
            end;
	    if l_pref_id > 0 then
               m := m + 1;
               R_level_prefids(m) := l_pref_id;
	    end if;
      end if;

      if p_level_tbl(i).ObjectCode in ('CUSTOMER','ACCOUNT','BILL_TO','DELINQUENCY') then

           begin
               Open object_version_cur(p_level_tbl(i).party_id);
               Fetch object_version_cur INTO l_pref_id,l_object_version_number;
               if object_version_cur%NOTFOUND then
                  l_object_version_number := 1;
                  l_pref_id := 0;
               end if;
               Close object_version_cur;
              exception
                  when others then
                      l_pref_id := 0;
                      l_object_version_number := 1;
            end;

            if l_pref_id > 0 then
               j := j + 1;
               U_level_tbl(j).party_id := p_level_tbl(i).party_id;
               U_level_tbl(j).ObjectCode := p_level_tbl(i).ObjectCode;
               U_level_tbl(j).version := l_object_version_number + 1;
               U_level_partyids(j) := p_level_tbl(i).party_id;
               U_level_ObjectCodes(j) := p_level_tbl(i).ObjectCode;
               U_level_versions(j) := l_object_version_number + 1;
            else
               k := k + 1;
               I_level_tbl(k).party_id := p_level_tbl(i).party_id;
               I_level_tbl(k).ObjectCode := p_level_tbl(i).ObjectCode;
               I_level_partyids(k) := p_level_tbl(i).party_id;
               I_level_ObjectCodes(k) := p_level_tbl(i).ObjectCode;
            end if;

      End if;
    End Loop;

    begin
       If R_level_prefids.count > 0 then

          FORALL m IN 1..R_level_prefids.count
                  DELETE from hz_party_preferences
                   where party_preference_id = R_level_prefids(m)
                     and module = 'COLLECTIONS'
                     and category = 'COLLECTIONS LEVEL'
                     and preference_code = 'PARTY_ID';

       End if;

       x_return_status := 'S';
       x_update_count := R_level_prefids.count;

       exception
          when others then
               iex_debug_pub.logmessage (' IEX_PARTY_PREF_PUB.assign_collection_level - deleting - Exception = ' ||SQLERRM);
               x_return_status := 'E';
               x_msg_data := SQLERRM||'Deleting Party preferences..';
               x_update_count := 0;
               RETURN;
    end;

    begin
       If U_level_tbl.count > 0 then

          FORALL m IN 1..U_level_tbl.count
                  UPDATE hz_party_preferences
                     set
                         --value_varchar2 = U_level_tbl(m).ObjectCode
                         --,object_version_number = U_level_tbl(m).version
                         value_varchar2 = U_level_ObjectCodes(m)
                        ,object_version_number = U_level_versions(m)
                        ,last_updated_by = G_user_id
                        ,last_update_date = sysdate
                        ,last_update_login = G_user_id
                   --where party_id = U_level_tbl(m).party_id
                   where party_id = U_level_partyids(m)
                     and module = 'COLLECTIONS'
                     and category = 'COLLECTIONS LEVEL'
                     and preference_code = 'PARTY_ID';

       End if;

       x_return_status := 'S';
       x_update_count := U_level_tbl.count;

       exception
          when others then
               iex_debug_pub.logmessage (' IEX_PARTY_PREF_PUB.assign_collection_level - Updating - Exception = ' ||SQLERRM);
               x_return_status := 'E';
               x_msg_data := SQLERRM||'Updating Party ';
               x_update_count := 0;
               RETURN;
    end;

    begin
       If I_level_tbl.count > 0 then

          FORALL n IN 1..I_level_tbl.count


              INSERT into HZ_PARTY_PREFERENCES (
                   PARTY_PREFERENCE_ID,
                   PARTY_ID,
                   MODULE,
                   CATEGORY,
                   PREFERENCE_CODE,
                   VALUE_VARCHAR2,
                   VALUE_NUMBER,
                   VALUE_DATE,
                   VALUE_NAME,
                   ADDITIONAL_VALUE1,
                   ADDITIONAL_VALUE2,
                   ADDITIONAL_VALUE3,
                   ADDITIONAL_VALUE4,
                   ADDITIONAL_VALUE5,
                   OBJECT_VERSION_NUMBER,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN
              )
           VALUES   (
                hz_party_preferences_s.nextval,
                --I_level_tbl(n).party_id,
                I_level_partyids(n),
                'COLLECTIONS',
                'COLLECTIONS LEVEL',
                'PARTY_ID',
                --I_level_tbl(n).ObjectCode,
                I_level_ObjectCodes(n),
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                1,
                G_user_id,
                sysdate,
                G_user_id,
                sysdate,
                G_user_id);
        End if;

        x_return_status := 'S';
        x_insert_count := I_level_tbl.count;

       exception
          when others then
               iex_debug_pub.logmessage (' IEX_PARTY_PREF_PUB.assign_collection_level - Inserting - Exception = ' ||SQLERRM);
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               x_msg_data := SQLERRM||'Inserting Party  ';
               x_insert_count := 0;
               RETURN;
    end;

    IF FND_API.to_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

END assign_collection_level;

END IEX_PARTY_PREF_PUB;

/
