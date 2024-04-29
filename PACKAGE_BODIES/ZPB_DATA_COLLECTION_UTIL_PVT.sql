--------------------------------------------------------
--  DDL for Package Body ZPB_DATA_COLLECTION_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DATA_COLLECTION_UTIL_PVT" AS
/* $Header: ZPBVDCUB.pls 120.0.12010.2 2005/12/23 06:05:12 appldev noship $ */


  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ZPB_DATA_COLLECTION_UTIL_PVT';

-------------------------------------------------------------------------------

   -- values for IN_MOVE_DATA_FLAG and IN_MOVE_TARGET_FLAG are 'Y' or 'N'

   PROCEDURE DISTRIBUTE_TEMPLATE(IN_TEMPLATE_ID IN NUMBER,
                                 IN_FROM_USER_ID IN NUMBER,
                                 IN_TO_USER_ID IN NUMBER,
                                 IN_MOVE_DATA_FLAG IN VARCHAR2,
                                 IN_MOVE_TARGET_FLAG IN VARCHAR2,
                                 IN_STRUCT_OR_DATA IN VARCHAR2)
   IS
   BEGIN

      ZPB_AW.EXECUTE('call DC.DISTRIBUTE(' || TO_CHAR(IN_TEMPLATE_ID) || ', ' || TO_CHAR(IN_FROM_USER_ID) || ', ' || TO_CHAR(IN_TO_USER_ID) || ', ''' || IN_MOVE_DATA_FLAG || ''', ''' || IN_MOVE_TARGET_FLAG || ''', ''' || IN_STRUCT_OR_DATA || ''')' );

   END;

   PROCEDURE UPDATE_AW_DATA(IN_QDRS IN VARCHAR2)
   IS
   BEGIN
      ZPB_AW.EXECUTE('');
   END;

   PROCEDURE COMMIT_AW_DATA
   IS
   BEGIN
      ZPB_AW.EXECUTE('');
   END;


   PROCEDURE get_dc_owners(p_object_id         IN  NUMBER,
                           p_user_id           IN  NUMBER,
                           p_query_type        IN  VARCHAR2,
                           p_api_version       IN  NUMBER,
                           p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                           p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
                           p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                           x_owner_list        OUT NOCOPY CLOB,
                           x_return_status     OUT NOCOPY varchar2,
                           x_msg_count         OUT NOCOPY number,
                           x_msg_data          OUT NOCOPY varchar2)


        IS

          l_api_name      CONSTANT VARCHAR2(32) := 'get_dc_owners';
          l_api_version   CONSTANT NUMBER       := 1.0;

          l_owners        VARCHAR2(2000);
          l_owner_val     VARCHAR2(128);
          l_stat_len      VARCHAR2(128);
          l_query_path    ZPB_DC_OBJECTS.DATAENTRY_OBJ_PATH%type;
          l_query_name    ZPB_DC_OBJECTS.DATAENTRY_OBJ_NAME%type;
          l_query_key     VARCHAR2(512);
          i               NUMBER;
          j               NUMBER;
          l_length        NUMBER;
          l_lob           CLOB;

        BEGIN

          -- Standard Start of API savepoint
          SAVEPOINT zpb_excp_pvt_populate_results;
          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call( l_api_version,
                                                                                           p_api_version,
                                                                                           l_api_name,
                                                                                           G_PKG_NAME)
          THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- Initialize message list if p_init_msg_list is set to TRUE.
          IF FND_API.to_Boolean(p_init_msg_list) THEN
             FND_MSG_PUB.initialize;
          END IF;
          --  Initialize API return status to success
          x_return_status := FND_API.G_RET_STS_SUCCESS;

          -- API body

          ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Building Data Collection ownership view...');

          select dataentry_obj_path, dataentry_obj_name
             into l_query_path, l_query_name
             from zpb_dc_objects
             where object_id = p_object_id;

          l_query_key := l_query_path || '/' || l_query_name;

          --set zpb_status_sql_members
          --ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'running zpb_aw_status.run_olapi_queries(' ||
--                                   l_query_key || ').');

          --not needed for new cm.setsqlstatus procecure
          --zpb_aw_status.run_olapi_queries(l_query_key);

          --run the ownership query
          ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'running sc.get.dstr.own');

          l_stat_len := zpb_aw.interp('shw sc.get.dstr.own(''' || to_char(p_object_id) || ''', ''' ||
                                      to_char(p_user_id) || ''', ''' || p_query_type || ''')');

          ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'sc.get.dstr.own found ' || l_stat_len || ' owners.');

          --dbms_output.put_line('Stat Length = ' || l_stat_len);

          l_length := to_number(l_stat_len);
          if (l_length > 0) then
             l_owners := zpb_aw.interp('shw joinchars(joincols(values(secuser), '' ''))');
             --dbms_output.put_line(l_owners);
             l_owners := substr(l_owners, 1, length(l_owners) - 1);
             i := 1;
             loop
                j := instr(l_owners, ' ', i);
                if (j = 0) then
                   l_owner_val := substr(l_owners, i);
                else
                   l_owner_val := substr(l_owners, i, j -i);
                   i := j +1;
                end if;

                l_lob := l_lob || l_owner_val || ',';

                exit when j=0;
             end loop;

             --remove the comma at end of lob
             l_length := dbms_lob.getlength(l_lob);
             dbms_lob.trim(l_lob, l_length -1);

             x_owner_list := l_lob;
          end if;

          ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Data Collection ownership view complete.');

          -- End of API body.

          -- Standard check of p_commit.
          IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
          END IF;
          -- Standard call to get message count and if count is 1, get message info.
          FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count, p_data  =>  x_msg_data );

          EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO zpb_excp_pvt_populate_results;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data
              );
            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO zpb_excp_pvt_populate_results;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data
              );
            WHEN OTHERS THEN
              ROLLBACK TO zpb_excp_pvt_populate_results;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg(
                  G_PKG_NAME,
                  l_api_name
                );
              END IF;
              FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data
              );


 END get_dc_owners;

 END ZPB_DATA_COLLECTION_UTIL_PVT;


/
