--------------------------------------------------------
--  DDL for Package Body AMS_LIST_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_MAINT_PVT" AS
/* $Header: amsvlmgb.pls 115.38 2002/11/20 23:00:16 jieli ship $ */

/*==========================================================================+
 | PROCEDURES.                                                              |
 | Schedule_List.                                                           |
 | Submit_List_For_Generation.                                              |
 | Check_List_Association.                                                  |
 | Create_Source_View.                                                      |
 | Copy_List.                                                               |
 | Create_Discoverer_Url.                                                   |
 +==========================================================================*/


 --global package variables.
 g_sqlerrm varchar2(500);
 g_sqlcode varchar2(500);

 ----------------------------------------------------------------------------
 --This Variable stores a record from the AMS_LIST_HEADERS_ALL table.      --
 ----------------------------------------------------------------------------
 g_listheader_rec        AMS_LISTHEADER_PVT.list_header_rec_type;

 ----------------------------------------------------------------------------
 --This Variable stores a record from the AMS_LIST_SELECT_ACTIONS table.   --
 ----------------------------------------------------------------------------
 g_listaction_rec        AMS_LISTACTION_PVT.action_rec_type;

 G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_List_Maint_PVT';
 G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvlmgb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


-----------------------------------------------------------------------------
-- Procedure
--   Create_Discoverer_Url

-- PURPOSE
--   Creates a URL which will launch Web Discoverer.
--
-- PARAMETERS

-- NOTES
-- created tdonohoe 09-May-2000
-----------------------------------------------------------------------------
PROCEDURE Create_Discoverer_Url(p_text              IN VARCHAR2,
                                p_application_id    IN NUMBER,
				p_responsibility_id IN NUMBER,
                                p_security_group_id IN NUMBER,
				p_function_id       IN NUMBER,
				p_target            IN VARCHAR2,
				p_session_id        IN NUMBER,
                                x_discoverer_url    OUT NOCOPY VARCHAR2
			       )
IS

BEGIN

       x_discoverer_url := ORACLEAPPS.CREATERFLINK( p_text              => p_text
                                                   ,p_application_id    => p_application_id
                                                   ,p_responsibility_id => p_responsibility_id
                                                   ,p_security_group_id => p_security_group_id
                             		           ,p_function_id       => p_function_id
                       			           ,p_target            => p_target
                   			           ,p_session_id        => p_session_id);



END;


----------------------------------------------------------------------------------------------------------
-- Procedure
--   Schedule_List

-- PURPOSE
--   Called by Concurrent Manager to Schedule The AMS_LISTGENERATION_PKG.GENERATE_LIST procedure.
--
--
-- PARAMETERS

-- NOTES
-- created tdonohoe 11/23/99
---------------------------------------------------------------------------------------------------------

Procedure SCHEDULE_LIST(errbuf                                 OUT NOCOPY    varchar2,
                        retcode                                OUT NOCOPY    number,
                        p_api_version                          IN     NUMBER,
                        p_init_msg_list                        IN     VARCHAR2   := FND_API.G_TRUE,
                        p_commit                               IN     VARCHAR2   := FND_API.G_FALSE,
                        p_validation_level                     IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
                        p_list_header_id                       IN     NUMBER,
                        p_list_used_by_id                      IN     VARCHAR2   := NULL,
                        p_arc_list_used_by                     IN     VARCHAR2   := NULL,
                        p_new_list_name                        IN     VARCHAR2   := NULL,
                        p_copy_entries                         IN     VARCHAR2   := 'Y') IS

l_return_status  varchar2(100);
l_msg_count      number;
l_msg_data       varchar2(2000);

Begin

null;
/*
-----------------------------------------
--The Result returned by SCHEDULE_LIST.--
-----------------------------------------
retcode :=0;


   AMS_Utility_PVT.Create_Log (
                               x_return_status   => l_return_status,
                               p_arc_log_used_by => 'LIST',
                               p_log_used_by_id  => p_list_header_id,
                               p_msg_data        => G_PKG_NAME || '.' || 'SCHEDULE_LIST: ' || TO_CHAR (p_validation_level));

   AMS_LISTGENERATION_PKG.Generate_List( p_api_version        => p_api_version,
                                         p_init_msg_list      => p_init_msg_list,
                                         p_commit             => p_commit,
                                         p_validation_level   => p_validation_level,
                                         p_list_header_id     => p_list_header_id,
                                         p_list_used_by_id    => p_list_used_by_id,
                                         p_arc_list_used_by   => p_arc_list_used_by,
                                         p_new_list_name      => p_new_list_name,
                                         p_copy_entries       => p_copy_entries,
                                         x_return_status      => l_return_status,
                                         x_msg_count          => l_msg_count,
                                         x_msg_data           => l_msg_data);


   IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
        retcode :=0;
   ELSE
        retcode  :=1;
   END IF;
*/


END SCHEDULE_LIST;

----------------------------------------------------------------------------------------------------------
-- Procedure
--   Submit_List_For_Generation

-- PURPOSE
--   Submit List for Generation to Concurrent Manager at the specified_time.
--
-- PARAMETERS

-- NOTES
-- created tdonohoe 11/22/99
-- modified sugupta 04/24/2000  added timezone id..
---------------------------------------------------------------------------------------------------------
Procedure  Submit_List_For_Generation(p_list_header_id   in number,
                                      p_user_id          IN NUMBER,
                                      p_resp_id          IN NUMBER,
                                      p_list_used_by_id  in number    := NULL,
                                      p_arc_list_used_by in varchar2  := NULL,
									  p_timezone_id      in NUMBER    := NULL,
                                      p_time             in DATE	  := NULL,
                                      p_name             in varchar2  := NULL,
                                      p_copy_entries     in varchar2  := 'Y',
                                      x_schedule_id  OUT NOCOPY number ) IS

 PRAGMA AUTONOMOUS_TRANSACTION;

  l_return_number NUMBER      := NULL;

  l_return_status VARCHAR2(1) := NULL;
  l_msg_count NUMBER          := NULL;
  l_msg_data  VARCHAR2(2000)  := NULL;
  l_start_time  DATE		  := NULL;

Begin

null;
/*
 -- sugupta 04/24/2000 timezone_id and USER_ENTERED_START_TIME has been added in the table
 -- Screen passes timezone id and user entered date.. api should convert user entered date
 -- into date for system which will be passed as start time in call to submit_request
-- p_user_tz_id can be null... take value in profile option for User Timezone

	IF (p_time IS NOT NULL)
	THEN
		AMS_UTILITY_PVT.Convert_Timezone(
			  p_init_msg_list		=> FND_API.G_TRUE,
			  x_return_status		=> l_return_status,
			  x_msg_count			=> l_msg_count,
			  x_msg_data			=> l_msg_data,

			  p_user_tz_id			=> p_timezone_id,
			  p_in_time				=> p_time,
			  p_convert_type		=> 'SYS',

			  x_out_time			=> l_start_time
			);

		-- If any errors happen let start time be sysdate
		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			l_start_time := sysdate;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			l_start_time := sysdate;
		END IF;
	END IF;

   --tdonohoe 12-15-1999
   --setting up oracle applications profile values;

   fnd_global.apps_initialize(p_user_id, p_resp_id, 530);

   x_schedule_id :=  FND_REQUEST.SUBMIT_REQUEST(application => 'AMS',
                                                  program     => 'AMSLISTGEN',
                                                  start_time  => to_char(l_start_time,'DD-MON-YYYY HH24:MI'),
                                                  argument1   => 1.0,
                                                  argument2   => FND_API.G_TRUE,
                                                  argument3   => FND_API.G_FALSE,
                                                  argument4   => FND_API.G_VALID_LEVEL_FULL,

                                                  argument5   => p_list_header_id,
                                                  argument6   => p_list_used_by_id,
                                                  argument7   => p_arc_list_used_by,
                                                  argument8   => p_name,
                                                  argument9   => p_copy_entries );
   if(x_schedule_id <>0)then
       update ams_list_headers_all
       set status_code = 'PENDING', status_date = sysdate
       where list_header_id = p_list_header_id;

   end if;

   commit;

*/
 End;

----------------------------------------------------------------------------------------------------------
-- Procedure
--   Check_List_Association
-- PURPOSE
--   A List may optionally be associated with a valid marketing activity.
--   This Procedure checks that the specified activity and type exist.

-- PARAMETERS
--   P_ARC_LIST_USED_BY , valid values are CAMP,CSCH,EVEH,EVEO.
--   P_LIST_USED_BY_ID  , the foreign key to the marketing entity table.
-- NOTES
-- created tdonohoe 11/16/99
---------------------------------------------------------------------------------------------------------
Function Check_List_Association(p_arc_list_used_by varchar2,p_list_used_by_id number)
Return Varchar2 IS

l_return_status VARCHAR2(1);

Begin

null;
/*
             l_return_status := FND_API.G_TRUE;

             IF(p_arc_list_used_by = 'CSCH')THEN
                    IF AMS_Utility_PVT.check_fk_exists(
                        'ams_campaign_schedules',
                        'campaign_schedule_id',
                        p_list_used_by_id) = FND_API.g_false
                   THEN
                    l_return_status := FND_API.G_FALSE;
                    RETURN l_return_status;

                    END IF;
              ELSIF(p_arc_list_used_by = 'CAMP')THEN
                    IF AMS_Utility_PVT.check_fk_exists(
                          'ams_campaigns_all_b',
                          'campaign_id',
                          p_list_used_by_id) = FND_API.g_false
                    THEN
                      l_return_status := FND_API.G_FALSE;
                      RETURN l_return_status;
                    END IF;
              ELSIF(p_arc_list_used_by = 'EVEO')THEN
                    IF AMS_Utility_PVT.check_fk_exists(
                          'ams_event_offers_all_b',
                          'event_offer_id',
                          p_list_used_by_id) = FND_API.g_false
                    THEN
                      l_return_status := FND_API.G_FALSE;
                      RETURN l_return_status;
                    END IF;
              ELSIF(p_arc_list_used_by = 'EVEH')THEN
                    IF AMS_Utility_PVT.check_fk_exists(
                          'ams_event_headers_all_b',
                          'event_header_id',
                          p_list_used_by_id) = FND_API.g_false
                    THEN
                      l_return_status := FND_API.G_FALSE;
                      RETURN l_return_status ;
                    END IF;
              ELSE
                    l_return_status := FND_API.G_FALSE;
                    RETURN l_return_status ;
              END IF;

*/


End Check_List_Association;

-----------------------------------------------------------------------------------------------
-- Procedure
--   Create_Source_View
--
-- PURPOSE
--  1. Creates a view based on the mapping information specified in the AMS_LIST_SRC_TYPES
--     and AMS_LIST_SRC_FIELDS tables.

--  2. The view will select only the columns which have been mapped to in the FIELD_TABLE_NAME
--     column in the AMS_LIST_SRC_FIELDS table.

--  3. Each column in the view will be given an alias which corresponds to
--     the SOURCE_COLUMN_MEANING column in the AMS_LIST_SRC_FIELDS table.

-- PARAMETERS
--  1. p_list_source_type specifies the type of mapping which the view is being created for.
--     IMPORT or TARGET.

--  2. p_source_type_code specifies the mapping code which the view is being created for.
--

-- NOTES
--  1. The view name is constucted as follows AMS_||P_LIST_SOURCE_TYPE||P_SOURCE_CODE||_V.

-- HISTORY
--   07/26/1999  tdonohoe created
--   03/06/2000  tdonohoe modified 1) If the name of the source type starts with "AMS_" then
--                                    this is added to the name of the view.
--                                 2) The view will include all columns from any sub source types
--                                    which are associated with the the master source type.
--   05/07/2000  tdonohoe modified 1) remove any occurances of '-' from the cursors
--                                    C_Source_Fields and C_Sub_Source_Fields
--   07/13/2000  vbhandar modified 1)fixed problem with view not being generated in target
--                                   sql string not constructed properly
-----------------------------------------------------------------------------------------------
-- End of Comments

Procedure Create_Source_View(p_api_version       IN  NUMBER,
                             p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
                             p_commit            IN  VARCHAR2  := FND_API.g_false,
                             p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

                             p_user_id           IN  NUMBER,
                             p_resp_id           IN  NUMBER,
                             p_resp_appl_id      IN  NUMBER,

                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,

                             p_list_source_type VARCHAR2,
                             p_source_type_code VARCHAR2) IS


l_api_name            CONSTANT VARCHAR2(30)  := 'Create_Source_View';
l_api_version         CONSTANT NUMBER        := 1.0;

--selects the "mapped to" fields for the specified list_source_type and source_type_code.

Cursor C_Source_Fields Is Select f.Field_Column_Name,replace(replace(substr(f.SOURCE_COLUMN_MEANING,1,30),' ','_'),'-','')
                          From   Ams_List_Src_Fields f,
                                 Ams_List_Src_Types  t
                          Where  upper(t.Source_Type_Code)    = upper(P_Source_Type_Code)
                          And    upper(t.list_source_type)    = upper(P_List_Source_Type)
                          And    f.list_source_type_id = t.list_source_type_id
						  order by 2;

--selects the "mapped to" fields for the specified list_source_type and source_type_code.
Cursor    C_Sub_Source_Fields
Is Select f.Field_Column_Name,replace(replace(substr(f.SOURCE_COLUMN_MEANING,1,30),' ','_'),'-','')
From      Ams_List_Src_Fields      f,
          Ams_List_Src_Types       t,
		  Ams_List_Src_Type_Assocs a
Where  upper(t.Source_Type_Code)      = upper(P_Source_Type_Code)
And    upper(t.list_source_type)      = upper(P_List_Source_Type)
And    a.master_source_type_id        = t.list_source_type_id
And    a.sub_source_type_id           = f.list_source_type_id
order by 2;


l_column_name    varchar2(50);
l_column_meaning varchar2(50);

l_view_name      varchar2(40);
l_sql_str        varchar2(10000);

l_source_code    varchar2(50);
l_type           varchar2(50);


l_result boolean;
l_stmt varchar2(8000);
l_status varchar2(10);
l_industry varchar2(10);
l_applsys_schema varchar2(30);
l_counter number;

Begin


        -- Standard Start of API savepoint
        SAVEPOINT Create_Source_View;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Maint_PVT.Create_Source_View: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


    fnd_global.apps_initialize(p_user_id,p_resp_id,p_resp_appl_id);


    --replacing any spaces in the p_source_type_code variable with "_".
    --replacing any spaces in the p_list_source_type variable with "_".
    l_source_code := replace(p_source_type_code,' ','_');
    l_type        := replace(p_list_source_type,' ','_');
    l_type := substr(l_type,1,3);

    --if the source code starts with "AMS_" remove from string.
    if(substr(l_source_code,1,4) = 'AMS_')then
           l_source_code := substr(l_source_code,5);
	end if;

	--getting a 20 character substring to ensure that the view name is not
	--longer than 30 characters when we add the strings "AMS_"+ 3 character list type + "_V"
    l_source_code := substr(l_source_code,1,20);


    --constructing the full view name.
    l_view_name := 'AMS_'||upper(l_type)||'_'||upper(l_source_code)||'_V';
	l_sql_str   := ' create or replace view '||l_view_name||' as Select ';


        open   c_source_fields;
        loop
          fetch  c_source_fields  INTO l_column_name,l_column_meaning;
          exit when c_source_fields%NOTFOUND;
          l_sql_str := l_sql_str||'ale.'||l_column_name||' '||l_column_meaning||',';

        end loop;
        close  c_source_fields;

        open   c_sub_source_fields;
        loop
          fetch  c_sub_source_fields  INTO l_column_name,l_column_meaning;
          exit when c_sub_source_fields%NOTFOUND;
          l_sql_str := l_sql_str||l_column_name||' '||l_column_meaning||',';

        end loop;
        close  c_sub_source_fields;


        l_result := fnd_installation.get_app_info('FND',
                                                  l_status,
                                                  l_industry,
                                                  l_applsys_schema);




        if(p_list_source_type = 'TARGET')then

            l_sql_str := l_sql_str
	               ||' ale.LIST_ENTRY_ID,ale.LIST_HEADER_ID,ale.OBJECT_VERSION_NUMBER,ale.LIST_SELECT_ACTION_ID,ale.ARC_LIST_SELECT_ACTION_FROM,ale.LIST_SELECT_ACTION_FROM_NAME,'
                       ||' ale.SOURCE_CODE,ale.ARC_LIST_USED_BY_SOURCE,ale.PIN_CODE,ale.LIST_ENTRY_SOURCE_SYSTEM_ID,ale.LIST_ENTRY_SOURCE_SYSTEM_TYPE,'
                       ||'ale.VIEW_APPLICATION_ID,ale.MANUALLY_ENTERED_FLAG,ale.MARKED_AS_DUPLICATE_FLAG,ale.MARKED_AS_RANDOM_FLAG,ale.PART_OF_CONTROL_GROUP_FLAG,'
                       ||' ale.ENABLED_FLAG,ale.CELL_CODE,ale.CAMPAIGN_ID,ale.MEDIA_ID,ale.CHANNEL_ID,ale.CHANNEL_SCHEDULE_ID,ale.EVENT_OFFER_ID,ale.LAST_UPDATE_DATE,ale.LAST_UPDATED_BY,ale.CREATION_DATE,ale.CREATED_BY FROM ams_list_entries ale '
	  	       ||' WHERE ale.LIST_ENTRY_SOURCE_SYSTEM_TYPE ='||''''||P_SOURCE_TYPE_CODE||'''';

	elsif(p_list_source_type = 'IMPORT')then

	    l_sql_str := l_sql_str||' ale.IMPORT_SOURCE_LINE_ID, '
               || ' ale.OBJECT_VERSION_NUMBER,ale.LAST_UPDATE_DATE, '
               || ' ale.LAST_UPDATED_BY,ale.CREATION_DATE,ale.CREATED_BY,'
               || ' ale.LAST_UPDATE_LOGIN,ale.IMPORT_LIST_HEADER_ID, '
               || ' ale.IMPORT_SUCCESSFUL_FLAG,ale.ENABLED_FLAG, '
               || ' ale.IMPORT_FAILURE_REASON,'
               || ' ale.RE_IMPORT_LAST_DONE_DATE,ale.DEDUPE_KEY '
               || ' FROM AMS_IMP_SOURCE_LINES ale , '
               || ' ams_imp_list_headers_all ail, '
               || ' ams_list_src_types alt '
	  ||' WHERE alt.list_source_type  =  ' || ''''|| 'IMPORT' ||''''
	  ||' and  ail.list_source_type_id = alt.list_source_type_id '
	  ||' and  alt.source_type_code =  '|| ''''||
             upper(p_source_type_code)  ||''''
	  ||' and  ale.import_list_header_id = ail.import_list_header_id ';
        else
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        end if;



       ad_ddl.do_ddl(l_applsys_schema,FND_GLOBAL.APPLICATION_SHORT_NAME,ad_ddl.create_view,l_sql_str, l_view_name);





     -- Standard check of p_commit.
     IF FND_API.To_Boolean ( p_commit )
     THEN
        COMMIT WORK;
     END IF;

     -- Success Message
     -- MMSG
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
     THEN
        FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'AMS_List_Maint_PVT.Create_Source_View', TRUE);
        FND_MSG_PUB.Add;
     END IF;


     IF (AMS_DEBUG_HIGH_ON) THEN
        FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('ROW','AMS_List_Maint_PVT.Create_Source_View: END', TRUE);
        FND_MSG_PUB.Add;
     END IF;


     -- Standard call to get message count AND IF count is 1, get message info.
     FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded     =>      FND_API.G_FALSE
            );



      EXCEPTION

            WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO Create_Source_View;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                g_sqlerrm := SQLERRM;
                g_sqlcode := SQLCODE;
                --dbms_output.put_line('AMS_List_Maint_PVT.Create_Source_View:'||g_sqlerrm||g_sqlcode);

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );


            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO Create_Source_View;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                g_sqlerrm := SQLERRM;
                g_sqlcode := SQLCODE;
                --dbms_output.put_line('AMS_List_Maint_PVT.Create_Source_View:'||g_sqlerrm||g_sqlcode);

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
                );

             WHEN OTHERS THEN

                ROLLBACK TO Create_Source_View;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                g_sqlerrm := SQLERRM;
                g_sqlcode := SQLCODE;
                --dbms_output.put_line('AMS_List_Maint_PVT.Create_Source_View:'||g_sqlerrm||g_sqlcode);

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

End Create_Source_View;



----------------------------------------------------------------------------------
-- Procedure
--   Copy_List
--
-- PURPOSE
--   1. Copies a List Header and optionally its actions or existing entries.
--   2. If the list is REPEATING then all existing REPEATED lists are created
--      as EXCLUDE actions in the new list.

-- PARAMETERS
--   P_List_Id           The List_Header_Id of The List to be Copied.
--   P_List_Used_By_ID   The Foreign Key to the Entity using the list.
--   p_arc_list_used_by  The Qualifier code which identifies the type of entity
--                       which is using the list.
--   P_Copy_Option       'A' Create New List Header and Copy Actions.
--                       'E' Create New List Header and create one INCLUDE action
--                       of the copied list name.
--   P_Repeat_Option     If this is a repeating list then this option specifies
--                       how to copy the list.
--                       'R' create a new list with a generation type of 'REPEAT'.
--                       'I' create a new list with a generation type of 'INCREMENTAL',
--                        additionally create 'EXCLUDE' actions for all previously
--                       generated children lists of the parent list.
--
-- NOTES
-- 10/27/1999 tdonohoe created
-- 06/22/2000 tdonohoe modified cursors to explicitly name columns
---------------------------------------------------------------------
Procedure Copy_List         (p_api_version       IN  NUMBER,
                             p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
                             p_commit            IN  VARCHAR2  := FND_API.g_false,
                             p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,


                             p_list_id           IN  NUMBER,
                             p_list_used_by_id   IN  NUMBER   := NULL,
                             p_arc_list_used_by  IN  VARCHAR2 := NULL,
                             p_list_type         IN  VARCHAR2 := NULL,
                             p_copy_option       IN  VARCHAR2 :='A',
                             p_repeat_option     IN  VARCHAR2 :='R',
                             x_list_id           OUT NOCOPY NUMBER,
                             x_listheader_rec    OUT NOCOPY AMS_LISTHEADER_PVT.list_header_rec_type) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'COPY_LIST';
  l_api_version         CONSTANT NUMBER        := 1.0;

  ------------------------------------------------------------------------------------
  --This Cursor retreves the list header details from the AMS_LIST_HEADERS_ALL table.-
  ------------------------------------------------------------------------------------
  Cursor C_ListHeader_Dets(p_list_header_id NUMBER) IS
			   SELECT
			    list_header_id
                           ,last_update_date
                           ,last_updated_by
                           ,creation_date
                           ,created_by
			   ,last_update_login
			   ,object_version_number
			   ,request_id
			   ,program_id
                           ,program_application_id
		   	   ,program_update_date
			   ,view_application_id
                           ,list_name
		           ,list_used_by_id
			   ,arc_list_used_by
			   ,list_type
			   ,status_code
			   ,status_date
			   ,generation_type
			   ,repeat_exclude_type
			   ,row_selection_type
			   ,owner_user_id
			   ,access_level
			   ,enable_log_flag
			   ,enable_word_replacement_flag
			   ,enable_parallel_dml_flag
			   ,dedupe_during_generation_flag
    	   		   ,generate_control_group_flag
			   ,last_generation_success_flag
			   ,forecasted_start_date
			   ,forecasted_end_date
			   ,actual_end_date
 	 		   ,sent_out_date
			   ,dedupe_start_date
			   ,last_dedupe_date
			   ,last_deduped_by_user_id
			   ,workflow_item_key
			   ,no_of_rows_duplicates
			   ,no_of_rows_min_requested
		   	   ,no_of_rows_max_requested
			   ,no_of_rows_in_list
			   ,no_of_rows_in_ctrl_group
			   ,no_of_rows_active
			   ,no_of_rows_inactive
			   ,no_of_rows_manually_entered
			   ,no_of_rows_do_not_call
			   ,no_of_rows_do_not_mail
			   ,no_of_rows_random
			   ,org_id
			   ,main_gen_start_time
			   ,main_gen_end_time
			   ,main_random_nth_row_selection
			   ,main_random_pct_row_selection
			   ,ctrl_random_nth_row_selection
			   ,ctrl_random_pct_row_selection
			   ,repeat_source_list_header_id
			   ,result_text
			   ,keywords
			   ,description
			   ,list_priority
			   ,assign_person_id
			   ,list_source
			   ,list_source_type
			   ,list_online_flag
			   ,random_list_id
			   ,enabled_flag
			   ,assigned_to
			   ,query_id
			   ,owner_person_id
			   ,archived_by
			   ,archived_date
			   ,attribute_category
			   ,attribute1
			   ,attribute2
			   ,attribute3
			   ,attribute4
			   ,attribute5
			   ,attribute6
			   ,attribute7
			   ,attribute8
			   ,attribute9
			   ,attribute10
			   ,attribute11
			   ,attribute12
			   ,attribute13
			   ,attribute14
			   ,attribute15
			   ,timezone_id
			   ,user_entered_start_time
                           FROM   ams_list_headers_all
                           WHERE  list_header_id = p_list_header_id;


  ------------------------------------------------------------------------------------
  --This Cursor retreves all list criteraias from the AMS_LIST_SELECT_ACTIONS table.--
  ------------------------------------------------------------------------------------
  Cursor  C_ListAction_Dets(p_list_header_id NUMBER)
                            IS SELECT
			        list_select_action_id
                               ,last_update_date
			       ,last_updated_by
			       ,creation_date
			       ,created_by
			       ,last_update_login
			       ,object_version_number
			       ,list_header_id
			       ,order_number
			       ,list_action_type
			       ,incl_object_name
			       ,arc_incl_object_from
			       ,incl_object_id
			       ,incl_object_wb_sheet
			       ,incl_object_wb_owner
			       ,incl_object_cell_code
			       ,rank
			       ,no_of_rows_available
			       ,no_of_rows_requested
			       ,no_of_rows_used
			       ,distribution_pct
			       ,result_text
			       ,description
                               FROM     ams_list_select_actions
                               WHERE    list_header_id = p_list_header_id
                               ORDER BY order_number;


  ---------------------------------------------------------------
  --used to select all previously generated repeatible lists.  --
  --these lists must be created as "EXCLUDE" actions from the  --
  --currently generated list. this guarantees uniqueness of    --
  --list entries across lists.                                 --
  ---------------------------------------------------------------
  CURSOR C_Repeat_Lists(p_source_list_id number,p_current_list_id  number)IS
  SELECT list_header_Id,
         list_name
  FROM   ams_list_headers_all
  WHERE  repeat_source_list_header_id  =  p_source_list_id
  AND    list_header_id                <> p_current_list_id
  ORDER BY list_header_id;

  ----------------------------------------------------------------------------
  --These table records will store a set of list header and list name fields--
  ----------------------------------------------------------------------------
  TYPE t_list_header_id is TABLE OF ams_list_headers_all.list_header_id%type;
  TYPE t_list_name      is TABLE OF ams_list_headers_all.list_name%type;

  ----------------------------------------------------------------------------
  --These variables will store the results of cursor c_repeat_lists.        --
  ----------------------------------------------------------------------------
  l_repeat_list_header_id t_list_header_id;
  l_repeat_list_name      t_list_name;

  l_list_name         ams_list_headers_all.list_name%type;
  l_list_header_id    NUMBER;
  l_action_id         NUMBER;

  ----------------------------------------------------------------------------
  --The count of generated lists for this REPEAT_LIST_SOURCE_TYPE.          --
  ----------------------------------------------------------------------------
  l_repeat_list_count NUMBER;


  ----------------------------------------------------------------------------------
  --These Variables store the result status of the call to the create_list_header --
  --and create_list_actions API procedures                                        --
  ----------------------------------------------------------------------------------
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

Begin
null;
/*
        -- Standard Start of API savepoint
        SAVEPOINT Copy_List;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
        THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Maint_PVT.Copy_List: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --------------------------------------------------------------------------------
        --Check that(if specified) the entity to associate the list with is valid.    --
        --------------------------------------------------------------------------------
        IF(p_list_used_by_id IS NOT NULL and p_arc_list_used_by IS NOT NULL)THEN
            IF ( Check_List_Association(p_arc_list_used_by,p_list_used_by_id) = FND_API.g_false )THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                  THEN
                       FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_USED_BY_ID');
                       FND_MSG_PUB.add;
                  END IF;
                  x_return_status := FND_API.g_ret_sts_error;
                  RETURN;
            END IF;
        END IF;--P_ARC_LIST_USED_BY AND P_LIST_USED_BY_ID CHECK

        --------------------------------------------------------------------------------
        --Check that(if specified) the list type is valid.                            --
        --------------------------------------------------------------------------------
        IF(p_list_type IS NOT NULL)THEN
            IF AMS_Utility_PVT.check_lookup_exists(
                              p_lookup_type => 'AMS_LIST_TYPE',
                              p_lookup_code => p_list_type) = FND_API.g_false THEN

               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_TYPE');
                  FND_MSG_PUB.add;
               END IF;

             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
            END IF;
         END IF;

     ------------------------------------
     --getting the list header details.--
     ------------------------------------
     OPEN   C_ListHeader_Dets(p_list_id);
     FETCH  C_ListHeader_Dets INTO g_listheader_rec;

     IF(C_ListHeader_Dets%NOTFOUND)THEN
          CLOSE  C_ListHeader_Dets;
          IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ID_NOT_EXIST');
                FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;
     CLOSE  C_ListHeader_Dets;

     IF(g_listheader_rec.generation_type = 'INCREMENTAL')THEN
          IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_BAD_COPY_INC');
                FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

     -------------------------------------------------------------------------
     --copying the original list name, as it may be needed if a criteria is --
     --created to INCLUDE the original list entries.                        --
     -------------------------------------------------------------------------
     l_list_name := g_listheader_rec.list_name;

     g_listheader_rec.list_name := g_listheader_rec.list_name||' '||to_char(sysdate,'DD-MON-YY HH24:MI:SS');
     g_listheader_rec.status_code :='NEW';
     g_listheader_rec.status_date := SYSDATE;

     ------------------------------------------------------------------------
     --copying the source code values into the record type to be created.  --
     ------------------------------------------------------------------------
     IF(p_list_used_by_id IS NOT NULL and p_arc_list_used_by IS NOT NULL)THEN
          g_listheader_rec.list_used_by_id  := p_list_used_by_id;
          g_listheader_rec.arc_list_used_by := p_arc_list_used_by;
     END IF;

     ------------------------------------------------------------------------
     --copying the list type value into the record type to be created.     --
     ------------------------------------------------------------------------
     IF(p_list_type IS NOT NULL)THEN
          g_listheader_rec.list_type        := p_list_type;
     END IF;

     ------------------------------------------------------------------------
     --If a REPEATIBLE list is copied then the new list must have          --
     --a generation type of INCREMENTAL.                                   --
     ------------------------------------------------------------------------
     IF(g_listheader_rec.generation_type='REPEAT')THEN
           IF(p_repeat_option = 'R')THEN
              g_listheader_rec.generation_type := 'REPEAT';
           ELSE
              g_listheader_rec.generation_type := 'INCREMENTAL';
           END IF;
     END IF;

     ------------------------------------------------------------------------
     --setting the list_header_id to NULL.                                 --
     ------------------------------------------------------------------------
     g_listheader_rec.list_header_id := NULL;


     ------------------------------------------------------------------------
     --Creating a new List Header.                                         --
     ------------------------------------------------------------------------
     AMS_ListHeader_PVT.Create_ListHeader(
                                          p_api_version     => 1.0,
                                          x_return_status   => l_return_status,
                                          x_msg_count       => l_msg_count,
                                          x_msg_data        => l_msg_data,
                                          p_listheader_rec  => g_listheader_rec,
                                          x_listheader_id   => l_list_header_id);

     IF(l_return_status = FND_API.G_RET_STS_ERROR)THEN
           Raise FND_API.G_EXC_ERROR;
     ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     x_list_id := l_list_header_id;

     ------------------------------------------------------------------------
     --Fetching The new list header details into the OUT NOCOPY variable.         --
     ------------------------------------------------------------------------
     OPEN  c_listheader_dets(x_list_id);
     FETCH c_listheader_dets INTO x_listheader_rec;
     CLOSE c_listheader_dets;

     ------------------------------------------------------------------------
     --Copy all Actions from the parent list into the new list.            --
     ------------------------------------------------------------------------
     IF(p_copy_option = 'A')THEN
         OPEN c_listaction_dets(p_list_id);
           LOOP
             FETCH c_listaction_dets into g_listaction_rec;
             EXIT  when c_listaction_dets%NOTFOUND;

             g_listaction_rec.list_header_id        := l_list_header_id;
             g_listaction_rec.list_select_action_id := NULL;

             AMS_ListAction_Pvt.Create_ListAction(p_api_version    => 1.0,
                                                  x_return_status  => l_return_status,
                                                  x_msg_count      => l_msg_count,
                                                  x_msg_data       => l_msg_data,
                                                  p_action_rec     => g_listaction_rec,
                                                  x_action_id      => l_action_id);

                IF(l_return_status = FND_API.G_RET_STS_ERROR)THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

            END LOOP;
            CLOSE c_listaction_dets;
     ------------------------------------------------------------------------
     --INCLUDE The parent list as a criteria in the new list.              --
     ------------------------------------------------------------------------
     ELSIF(p_copy_option = 'E')THEN
             g_listaction_rec.incl_object_name      := l_list_name;
            g_listaction_rec.arc_incl_object_from  := 'LIST';
            g_listaction_rec.list_action_type      := 'INCLUDE';
            g_listaction_rec.incl_object_id        := p_list_id;
            g_listaction_rec.list_header_id        := l_list_header_id;
            g_listaction_rec.order_number          := 1;
            g_listaction_rec.rank                  := 1;


            AMS_ListAction_Pvt.Create_ListAction(p_api_version    => 1.0,
                                                 x_return_status  => l_return_status,
                                                 x_msg_count      => l_msg_count,
                                                 x_msg_data       => l_msg_data,
                                                 p_action_rec     => g_listaction_rec,
                                                 x_action_id      => l_action_id);

            IF(l_return_status = FND_API.G_RET_STS_ERROR)THEN
                  Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
     END IF;--P_COPY_OPTION CHECK.

     -----------------------------------------------------------------------------------
     --If this is an INCREMENTAL list then we must create EXCLUDE actions for all the --
     --previously generated REPEATING\INCREMENTAL lists for the parent list.          --
     -----------------------------------------------------------------------------------
     IF(g_listheader_rec.generation_type = 'INCREMENTAL')THEN
         ------------------------------------------------------------------------
         --getting the number of times a repeated list header has been created.--
         ------------------------------------------------------------------------
         SELECT COUNT(*)
         INTO   l_repeat_list_count
         FROM   ams_list_headers_all
         WHERE  repeat_source_list_Header_id = p_list_id;

         IF(l_repeat_list_count >0)THEN
            ------------------------------------------------------------------------
            --Fetch the existing set of already generated Repeated Lists.         --
	    ------------------------------------------------------------------------
            OPEN  c_repeat_lists(p_list_id,l_list_header_id);
            FETCH c_repeat_lists BULK COLLECT INTO l_repeat_list_header_id,l_repeat_list_name;
            CLOSE c_repeat_lists;

            -----------------------------------------------------------------------------------
            --Creating Exclude Actions for the set of repeated lists generated so far.       --
            --this guarantees the latest list never has entries which have been targeted     --
            --in a previous list.                                                            --
	    -----------------------------------------------------------------------------------
            FOR I in l_repeat_list_header_id.first .. l_repeat_list_header_id.last LOOP
                        g_listaction_rec.list_header_id        := l_list_header_id;
                        g_listaction_rec.incl_object_name      := l_repeat_list_name(i);
                        g_listaction_rec.arc_incl_object_from  := 'LIST';
                        g_listaction_rec.list_action_type      := 'EXCLUDE';
                        g_listaction_rec.incl_object_id        := l_repeat_list_header_id(i);
                        g_listaction_rec.order_number          := g_listaction_rec.order_number + 1;
                        g_listaction_rec.rank                  := g_listaction_rec.rank + 1;

                        AMS_ListAction_Pvt.Create_ListAction( p_api_version   => 1.0,
                                                              x_return_status => l_return_status,
                                                              x_msg_count     => l_msg_count,
                                                              x_msg_data      => l_msg_data,
                                                              p_action_rec    => g_listaction_rec,
                                                              x_action_id     => l_action_id);

                        IF(l_return_status = FND_API.G_RET_STS_ERROR)THEN
                               Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
             END LOOP;
        END IF; --REPEAT LIST COUNT CHECK;
      END IF; --REPEAT LIST CHECK.

     -- Standard check of p_commit.
     IF FND_API.To_Boolean ( p_commit )
     THEN
            COMMIT WORK;
     END IF;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
     THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Maint_PVT.Copy_List', TRUE);
            FND_MSG_PUB.Add;
     END IF;


     IF (AMS_DEBUG_HIGH_ON) THEN
     THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW','AMS_List_Maint_PVT.Copy_List: END', TRUE);
            FND_MSG_PUB.Add;
     END IF;

     -- Standard call to get message count AND IF count is 1, get message info.
     FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded         =>      FND_API.G_FALSE);


     EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO Copy_List;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                g_sqlerrm := SQLERRM;
                g_sqlcode := SQLCODE;
                --dbms_output.put_line('AMS_List_Maint_PVT.Copy_List:'||g_sqlerrm||g_sqlcode);

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );


            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO Copy_List;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                g_sqlerrm := SQLERRM;
                g_sqlcode := SQLCODE;
                --dbms_output.put_line('AMS_List_Maint_PVT.Copy_List:'||g_sqlerrm||g_sqlcode);

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
                );

             WHEN OTHERS THEN

                ROLLBACK TO Copy_List;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                g_sqlerrm := SQLERRM;
                g_sqlcode := SQLCODE;
                --dbms_output.put_line('AMS_List_Maint_PVT.Copy_List:'||g_sqlerrm||g_sqlcode);

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );


*/
End Copy_List;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_PinCodeData_Rec
--
-- PURPOSE
--    Gets customer record for a given pincode.
--
-- PARAMETERS
--    x_listentry_rec: the record representing AMS_LIST_ENTRIES.
--    p_pincode: the pincode.
--
-- NOTES
--    1. since pincode is unique only one record will be returned.
--    2. Raise exception incase of invalid pincode.
--    created vbhandar 2/16/2000
---------------------------------------------------------------------
PROCEDURE  Get_PinCodeData_Rec (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_pincode            IN  VARCHAR2,
   x_listentry_rec      OUT NOCOPY ListEntryType_Rec_Type
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Get_PinCodeData_Rec';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'||l_api_name;

    --Retrieve all necessary List entry parameters  .
   Cursor C_ListEntry_Dets IS Select  LIST_ENTRY_ID,LIST_HEADER_ID,
                                      SOURCE_CODE,ARC_LIST_USED_BY_SOURCE,
                                      SOURCE_CODE_FOR_ID,PIN_CODE,
                                      LIST_ENTRY_SOURCE_SYSTEM_ID,
                                      LIST_ENTRY_SOURCE_SYSTEM_TYPE,
                                      VIEW_APPLICATION_ID,
                                      CELL_CODE,CAMPAIGN_ID,
                                      CHANNEL_SCHEDULE_ID,
                                      EVENT_OFFER_ID,SUFFIX,
                                      FIRST_NAME,LAST_NAME,
                                      CUSTOMER_NAME,TITLE,
                                      ADDRESS_LINE1,ADDRESS_LINE2,
                                      CITY,STATE,ZIPCODE,COUNTRY,FAX,PHONE,EMAIL_ADDRESS
                              From   ams_list_entries
                              Where  ams_list_entries.pin_code = p_pincode;

BEGIN
 --------------------- initialize -----------------------
   SAVEPOINT Get_PinCodeData_Rec;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ select ------------------------
   OPEN C_ListEntry_Dets;
   FETCH C_ListEntry_Dets INTO x_listentry_rec;
   IF C_ListEntry_Dets%NOTFOUND THEN
      CLOSE C_ListEntry_Dets;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE C_ListEntry_Dets;

END Get_PinCodeData_Rec;


END AMS_LIST_MAINT_PVT;

/
