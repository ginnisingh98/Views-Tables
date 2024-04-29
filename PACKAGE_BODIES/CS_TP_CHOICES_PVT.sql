--------------------------------------------------------
--  DDL for Package Body CS_TP_CHOICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_CHOICES_PVT" as
/* $Header: cstpcsmb.pls 120.1 2008/02/21 04:32:59 amganapa ship $ */

-- ---------------------------------------------------------
-- Define global variables and types
-- ---------------------------------------------------------
       l_default_last_up_date_format     CONSTANT       VARCHAR2(30)   := 'MM/DD/YYYY/SSSSS';
       G_PKG_NAME  CONSTANT                VARCHAR2(100) := 'CS_TP_CHOCIES_PVT';

       DEBUG      CONSTANT                 VARCHAR2(1) := FND_API.G_TRUE;
procedure Add_Choice (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    p_One_Choice      IN Choice,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data	OUT NOCOPY     VARCHAR2,
    X_Return_Status	OUT NOCOPY     VARCHAR2,
    X_Choice_ID	OUT NOCOPY     NUMBER)
is
        l_api_name     CONSTANT       VARCHAR2(30)   := 'Add_Choice';
        l_api_version  CONSTANT       NUMBER         := 1.0;
        Cursor LookupC is
             select count (*) from CS_TP_LOOKUPS where LOOKUP_ID = p_One_Choice.mLookupID;
        l_lookup_count                NUMBER;
        l_choice_id                   NUMBER;
        l_ROWID 		      VARCHAR2(30);
  	Cursor C is
           select max(SEQUENCE_NUMBER) from CS_TP_CHOICES_VL;
        l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_created_by                  NUMBER        :=FND_API.G_MISS_NUM;
        l_login                       NUMBER        :=FND_API.G_MISS_NUM;
        l_max_sequence                NUMBER;
begin
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body

        -- Perform validation
	 IF (P_One_Choice.mChoiceName is NULL OR P_One_Choice.mChoiceName= FND_API.G_MISS_CHAR) THEN
               X_Return_Status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CS','CS_TP_Choice_NAME_INVALID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

          IF (P_One_Choice.mScore is NULL OR P_One_Choice.mScore = FND_API.G_MISS_NUM) then
               X_Return_Status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CS','CS_TP_Choice_Score_INVALID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
          END IF;

         open LookupC;
         fetch LookupC into l_lookup_count;
         close LookupC;
         if (l_lookup_count <1 or l_lookup_count>1) then
               X_Return_Status :=  FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CS','CS_TP_LookUPID_INVALID');
               FND_MSG_PUB.Add;
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         open C;
         fetch C into l_max_sequence;
         if (C%notfound) then
              l_max_sequence := 0;
         end if;

         close C;
         if (l_max_sequence is NULL or l_max_sequence = FND_API.G_MISS_NUM) then
            l_max_sequence :=0;
         end if;

         --Insert into the Cs_TO_CHOICES_B table, note start_date_active and end_date_active are null
        l_current_date := sysdate;
        l_created_by := FND_GLOBAL.user_id;
        l_login := fnd_global.login_id;

         select CS_TP_CHOICES_S.NEXTVAL into l_choice_id from dual;
         CS_TP_CHOICES_PKG.INSERT_ROW (
                X_ROWID => l_ROWID,
   		X_CHOICE_ID => l_choice_id,
 		X_LOOKUP_ID => P_One_Choice.mLookupID,
                X_SEQUENCE_NUMBER => l_max_sequence +1,
                X_START_DATE_ACTIVE => NULL,
  		X_END_DATE_ACTIVE => NULL,
		X_SCORE => P_One_Choice.mScore,
  		X_VALUE => P_One_Choice.mChoiceName,
  		X_CREATION_DATE =>l_current_date,
  		X_CREATED_BY => l_created_by,
  		X_LAST_UPDATE_DATE =>l_current_date,
  		X_LAST_UPDATED_BY => l_created_by,
  		X_LAST_UPDATE_LOGIN => l_login
		,X_DEFAULT_FLAG  => P_One_Choice.mDefaultChoiceFlag
	 );
                   X_Choice_ID := L_Choice_ID;
     -- End of API Body

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );


      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          raise;
END Add_Choice;

procedure Delete_Choice  (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_Choice_ID	   IN   NUMBER,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data	OUT NOCOPY     VARCHAR2,
    X_Return_Status	OUT NOCOPY     VARCHAR2
)
is
       l_api_name     CONSTANT       VARCHAR2(30)   := 'Delete_Choice';
       l_api_version  CONSTANT       NUMBER         := 1.0;

begin
    -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

      -- Start API Body

      -- delete choice

         CS_TP_CHOICES_PKG.DELETE_ROW (  P_Choice_ID);

   -- End of API Body

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );

EXCEPTION
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          raise;

end Delete_Choice;

procedure Sort_Choices (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_Choices                In    Choice_List,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data	OUT NOCOPY     VARCHAR2,
    X_Return_Status	OUT NOCOPY     VARCHAR2
)

is
       l_api_name     CONSTANT       VARCHAR2(30)   := 'Sort_Choices';
       l_api_version  CONSTANT       NUMBER         := 1.0;
       i                             NUMBER;
        l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_last_updated_by                  VARCHAR2(200)        :=FND_API.G_MISS_CHAR;
        l_login                       VARCHAR2(200)        :=FND_API.G_MISS_CHAR;
        l_lookup_id                  NUMBER;
        l_score                      NUMBER;
        l_value                      VARCHAR2(500);
        Cursor last_updateC  (V_Choice_ID Number) is
           select last_update_date, LOOKUP_ID, SCORE, VALUE  from CS_TP_CHOICES_VL where choice_ID = V_Choice_ID;
         l_last_update_date            DATE;
begin
      -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body
         l_current_date := sysdate;
        l_last_updated_by := fnd_global.user_id;
        l_login := fnd_global.login_id;
        if (P_Choices.COUNT>0) then
           for i in P_Choices.FIRST..P_Choices.LAST loop
               open last_updateC (P_Choices(i).mChoiceID);
               fetch last_updateC into l_last_update_date, l_lookup_id, l_score, l_value;
               if (last_updateC%notfound) then
                 close last_updateC;
                 raise no_data_found;
               end if;
               close last_updateC;
               if (to_date( P_Choices(i).mLast_Updated_date, l_default_last_up_date_format) < l_last_update_date) then
                 X_Return_Status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('CS','CS_TP_CHOICE_UPDATED');
                 FND_MSG_PUB.Add;
            	 RAISE FND_API.G_EXC_ERROR;
               end if;
               CS_TP_CHOICES_PKG.UPDATE_ROW (
                   X_CHOICE_ID => P_Choices (i).mChoiceID,
                   X_LOOKUP_ID => l_lookup_id,
                   X_START_DATE_ACTIVE => null,
                   X_END_DATE_ACTIVE =>null,
                   X_SEQUENCE_NUMBER => i,
                   X_SCORE => l_score,
		   X_VALUE => l_value,
  		   X_LAST_UPDATE_DATE => l_current_date,
		   X_LAST_UPDATED_BY => l_last_updated_by,
		   X_LAST_UPDATE_LOGIN => l_login
		   ,X_DEFAULT_FLAG  => P_Choices (i).mDefaultChoiceFlag
		);
           end loop;
        end if;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );


      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          raise;

end Sort_Choices;


procedure Show_Choices (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_Lookup_Id		IN NUMBER,
    P_Display_Order     IN VARCHAR2,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data	OUT NOCOPY     VARCHAR2,
    X_Return_Status	OUT NOCOPY     VARCHAR2,
    X_Choice_List_To_Show   OUT NOCOPY   Choice_List
)

is
     l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Choices';
       l_api_version  CONSTANT       NUMBER         := 1.0;
       i                             NUMBER;
      l_CursorID			    NUMBER;
      l_statement                        VARCHAR2(500);
      l_CHOICE_ID 			NUMBER;
      l_CHOICE_NAME                     VARCHAR2(1000);
      l_LOOKUP_ID                       NUMBER;
      l_SCORE                           NUMBER;
      l_LAST_UPDATE_DATE                DATE;

      l_DEFAULT_CHOICE			VARCHAR2(1);
      l_total_choices_number		NUMBER;
      j 				NUMBER;
begin
      -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body

       -- Construct query statement, open cursor, execute query statement, retrieve results
       l_statement := 'SELECT CHOICE_ID, VALUE, LOOKUP_ID, SCORE, LAST_UPDATE_DATE, DEFAULT_CHOICE_FLAG from CS_TP_CHOICES_VL where LOOKUP_ID = : v_lookup_id';

       if (P_Display_Order is  NULL OR P_Display_Order=FND_API.G_MISS_CHAR OR length(P_Display_Order)<=0 OR P_Display_Order =NORMAL) then
             l_statement := l_statement || ' ORDER BY SEQUENCE_NUMBER ';

        elsif (P_Display_Order=ALPHABATICAL) then
            l_statement := l_statement || ' ORDER BY VALUE ';
        elsif (P_Display_Order = REVERSE_ALPHABATICAL) then
            l_statement := l_statement || ' ORDER BY VALUE desc ';
        elsif (P_Display_Order = CRONOLOGICAL) then
            l_statement := l_statement || ' ORDER BY LAST_UPDATE_DATE ';
        elsif (P_Display_Order = REVERSE_CRONOLOGICAL) then
            l_statement := l_statement || ' ORDER BY LAST_UPDATE_DATE desc ';
        else
            l_statement := l_statement || ' ORDER BY SEQUENCE_NUMBER ';
        end if;

       l_CursorID := dbms_sql.open_cursor;
       dbms_sql.parse (l_CursorID, l_statement, dbms_sql.NATIVE);

        dbms_sql.bind_variable(l_CursorID, 'v_lookup_id', P_Lookup_ID);

        dbms_sql.define_column(l_CursorID, 1, l_CHOICE_ID);
        dbms_sql.define_column(l_CursorID, 2, l_CHOICE_NAME,1000);
        dbms_sql.define_column(l_CursorID, 3, l_LOOKUP_ID);
        dbms_sql.define_column(l_CursorID, 4, l_SCORE);
 	dbms_sql.define_column(l_CursorID, 5,  l_LAST_UPDATE_DATE);

	dbms_sql.define_column(l_CursorID, 6, l_DEFAULT_CHOICE,1);

        l_total_choices_number:= dbms_sql.execute(l_CursorID);

	j:=0;
        while (dbms_sql.fetch_rows (l_CursorID) > 0) loop

       	 	dbms_sql.column_value(l_CursorID, 1, l_CHOICE_ID);
        	dbms_sql.column_value(l_CursorID, 2, l_CHOICE_NAME);
       		dbms_sql.column_value(l_CursorID, 3, l_LOOKUP_ID);
        	dbms_sql.column_value(l_CursorID, 4, l_SCORE);
 		dbms_sql.column_value(l_CursorID, 5,  l_LAST_UPDATE_DATE);

		dbms_sql.column_value(l_CursorID, 6, l_DEFAULT_CHOICE);
                X_Choice_List_To_Show (j).mChoiceID :=l_CHOICE_ID;
                X_Choice_List_To_Show (j).mChoiceName :=l_CHOICE_NAME;
                X_Choice_List_To_Show (j).mLookupID:=l_LOOKUP_ID;
                X_Choice_List_To_Show (j).mScore:=l_SCORE;
                X_Choice_List_To_Show (j).mLast_Updated_Date:=to_char (l_LAST_UPDATE_DATE, l_default_last_up_date_format);

		X_Choice_List_To_Show (j).mDefaultChoiceFlag := l_DEFAULT_CHOICE;
                j:=j+1;

        end loop;
        dbms_sql.close_cursor(l_CursorID);
 -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count,
           p_data => x_msg_data
          );

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );

      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          raise;
end Show_Choices;

procedure Update_Choices (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_Choices                In    Choice_List,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data	OUT NOCOPY     VARCHAR2,
    X_Return_Status	OUT NOCOPY     VARCHAR2
)

is
       l_api_name     CONSTANT       VARCHAR2(30)   := 'Update_Choices';
       l_api_version  CONSTANT       NUMBER         := 1.0;

        Cursor last_updateC  (V_Choice_ID Number) is
           select last_update_date,sequence_number,value  from CS_TP_CHOICES_VL
		where choice_ID = V_Choice_ID;
         l_last_update_date            DATE;
	 l_sequence_number		NUMBER;
	 l_value			VARCHAR2(240);

	 i                             NUMBER;

        l_last_updated_by              NUMBER        :=FND_API.G_MISS_NUM;
        l_login                        NUMBER        :=FND_API.G_MISS_NUM;
begin
      -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        l_last_updated_by := fnd_global.user_id;
        l_login := fnd_global.login_id;
        if (P_Choices.COUNT>0) then
           for i in P_Choices.FIRST..P_Choices.LAST loop

               open last_updateC (P_Choices(i).mChoiceID);
               fetch last_updateC into l_last_update_date, l_sequence_number, l_value;
               if (last_updateC%notfound) then
                 close last_updateC;
                 raise no_data_found;
               end if;
               close last_updateC;

/*
               if (to_date( P_Choices(i).mLast_Updated_date, l_default_last_up_date_format)
			< l_last_update_date) then
                 X_Return_Status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('CS','CS_TP_CHOICE_UPDATED');
                 FND_MSG_PUB.Add;
            	 RAISE FND_API.G_EXC_ERROR;
               end if;
*/

               CS_TP_CHOICES_PKG.UPDATE_ROW (
                   X_CHOICE_ID => P_Choices (i).mChoiceID,
                   X_LOOKUP_ID => P_Choices (i).mLookupID,
                   X_START_DATE_ACTIVE => null,
                   X_END_DATE_ACTIVE =>null,
                   X_SEQUENCE_NUMBER => l_sequence_number,
                   X_SCORE => P_Choices (i).mScore,
		   X_VALUE => l_value,
  		   X_LAST_UPDATE_DATE => sysdate,
		   X_LAST_UPDATED_BY => l_last_updated_by,
		   X_LAST_UPDATE_LOGIN => l_login
		   ,X_DEFAULT_FLAG  => P_Choices (i).mDefaultChoiceFlag
		);


	   end loop;
	end if;


     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );


      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          --raise;

end Update_Choices;

procedure Add_Freetext (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_One_Freetext		in    Freetext,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data	OUT NOCOPY     VARCHAR2,
    X_Return_Status	OUT NOCOPY     VARCHAR2,
    X_Freetext_ID       OUT NOCOPY NUMBER
)

is
    l_api_name     CONSTANT       VARCHAR2(30)   := 'Add_Freetext';
    l_api_version  CONSTANT       NUMBER         := 1.0;

    Cursor LookupC is
           select count (*) from CS_TP_LOOKUPS where LOOKUP_ID = p_One_Freetext.mLookupID;
    Cursor FreetextC is
           select FREETEXT_ID from CS_TP_FREETEXTS where LOOKUP_ID= p_One_Freetext.mLookupID;


        l_lookup_count                NUMBER;
        l_freetext_id                   NUMBER:=NULL;
        l_freetext_update_id           number;
        l_ROWID 		      VARCHAR2(30);
        l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_created_by                  NUMBER        :=FND_API.G_MISS_NUM;
        l_login                       NUMBER       :=FND_API.G_MISS_NUM;
        l_freetext_count              NUMBER;
begin
       -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body

        -- Perform validation
	 IF (p_One_Freetext.mFreetextSize is NULL OR p_One_Freetext.mFreetextSize= FND_API.G_MISS_NUM) THEN
               X_Return_Status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CS','CS_TP_FreetextSize_INVALID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         open LookupC;
         fetch LookupC into l_lookup_count;
         close LookupC;
         if (l_lookup_count <1 or l_lookup_count>1) then
               X_Return_Status :=  FND_API.G_RET_STS_ERROR;
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         l_current_date := sysdate;
         l_created_by := FND_GLOBAL.user_id;
         l_login := fnd_global.login_id;

         open FreetextC;
         fetch FreetextC into l_freetext_update_id;
         close FreeTextC;

         if (l_freetext_update_id is NULL ) then
                select CS_TP_FREETEXTS_S.NEXTVAL into l_freetext_id from dual;
        	CS_TP_FREETEXTS_PKG.INSERT_ROW (
                X_ROWID => l_ROWID,
   		X_FREETEXT_ID => l_freetext_id,
 		X_LOOKUP_ID => P_One_Freetext.mLookupID,
                X_FREETEXT_SIZE => P_One_Freetext.mFreetextSize,
                X_CREATION_DATE =>l_current_date,
  		X_CREATED_BY => l_created_by,
  		X_LAST_UPDATE_DATE =>l_current_date,
  		X_LAST_UPDATED_BY => l_created_by,
  		X_LAST_UPDATE_LOGIN => l_login );

         elsif (l_freetext_update_id  is not NULL ) then
                CS_TP_FREETEXTS_PKG.UPDATE_ROW (
                  X_FREETEXT_ID => l_freetext_update_id,
                  X_FREETEXT_SIZE => P_One_Freetext.mFreetextSize,
                  X_LOOKUP_ID => P_One_Freetext.mLookUpID,
                  X_LAST_UPDATE_DATE => l_current_date,
  		  X_LAST_UPDATED_BY => l_created_by,
  		  X_LAST_UPDATE_LOGIN =>l_login
                );
         end if;
           X_Freetext_ID := l_Freetext_ID ;
     -- End of API Body

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );

/*
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          raise;
*/
end Add_Freetext;

procedure Show_Freetext (
   p_api_version_number     IN   NUMBER,
   p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
   p_commit       IN VARCHAR          := FND_API.G_FALSE,
   P_Lookup_ID          IN NUMBER,
   X_Msg_Count OUT NOCOPY     NUMBER,
   X_Msg_Data	OUT NOCOPY     VARCHAR2,
   X_Return_Status	OUT NOCOPY     VARCHAR2,
   X_Freetext		OUT NOCOPY     FREETEXT
  )

is
        l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Freetext';
        l_api_version  CONSTANT       NUMBER         := 1.0;
        Cursor freetextC is
           SELECT ftxt.freetext_id,  -- Bug 6705077
	     ftxt.freetext_size,
	     ftxt.lookup_id,
	     ftxt.last_update_date,
	     flkup.default_value
	   FROM cs_tp_freetexts ftxt,
	     cs_tp_lookups flkup
	   WHERE flkup.lookup_id = p_lookup_id
	    AND ftxt.lookup_id = flkup.lookup_id;

        l_freetext freetextC%ROWTYPE;

begin
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body
         open freetextC;



         fetch freetextC into l_freetext;
          if (freetextC%notfound) then
              /*
            IF (fND_API.to_boolean (DEBUG)) then
               dbms_output.put_line ('Freetext cursor not found for the lookup id');
             end if;
             */
            close freetextC;
         end if;
         X_Freetext.mFreetextID := l_freetext.FREETEXT_ID;
         X_Freetext.mFreetextSize := l_freetext.FREETEXT_SIZE;
         X_Freetext.mFreeTextDefaultText := l_freetext.DEFAULT_VALUE; -- Bug 6705077
         X_Freetext.mLookupID :=l_freetext.LOOKUP_ID;
         X_Freetext.mLast_Updated_Date :=l_freetext.LAST_UPDATE_DATE;

      -- End of API Body

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );

/*
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          raise;

*/
end  Show_Freetext;

end CS_TP_CHOICES_PVT;

/
