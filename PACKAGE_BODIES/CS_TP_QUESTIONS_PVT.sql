--------------------------------------------------------
--  DDL for Package Body CS_TP_QUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_QUESTIONS_PVT" as
/* $Header: cstpqsmb.pls 115.15 2002/12/04 03:30:13 wzli noship $ */
-- ---------------------------------------------------------
-- Define global variables and types
-- ---------------------------------------------------------
       l_default_last_up_date_format     CONSTANT       VARCHAR2(30)   := 'MM/DD/YYYY/SSSSS';
       G_PKG_NAME  CONSTANT                VARCHAR2(100) := 'CS_TP_QUESTIONS_PVT';

       DEBUG       CONSTANT                VARCHAR2(1) := FND_API.G_TRUE;
-- ---------------------------------------------------------
-- Define private procedures/functions (not in package spec)
-- ---------------------------------------------------------
function get_user_id return NUMBER
    as
      begin
        return FND_GLOBAL.USER_ID;
    end get_user_id;


function get_date_format_from_user(p_user_id IN NUMBER) return VARCHAR2
      as
      begin

        -- get the default date format for this user
        return FND_PROFILE.VALUE_SPECIFIC(
                  'ICX_DATE_FORMAT_MASK',
                  p_user_id,
                  null,
                  null);
      exception
        when others then
          return 'MON-DD-YYYY';         -- use this one as default
      end get_date_format_from_user;

function get_date_format return VARCHAR2
    as
      begin
          return get_date_format_from_user(get_user_id);
    end get_date_format;


-- ---------------------------------------------------------
-- Define public procedures
-- ---------------------------------------------------------


procedure Add_Question  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_One_Question  IN 	Question,
  p_Template_ID	IN      NUMBER,
  X_Msg_Count OUT NOCOPY    NUMBER,
  X_Msg_Data  OUT NOCOPY     VARCHAR2,
  X_Return_Status OUT NOCOPY     VARCHAR2,
	X_Question_ID OUT NOCOPY     NUMBER)


is
        l_api_name     CONSTANT       VARCHAR2(30)   := 'Add_Question';
        l_api_version  CONSTANT       NUMBER         := 1.0;
        l_question_id                 NUMBER         :=FND_API.G_MISS_NUM;
        l_lookup_id                   NUMBER         :=FND_API.G_MISS_NUM;
        l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_created_by                  NUMBER        :=FND_API.G_MISS_NUM;
        l_login                       NUMBER        :=FND_API.G_MISS_NUM;
        l_ROWID                      VARCHAR2(30);
        Cursor C is
           select max(SEQUENCE_NUMBER) from CS_TP_TEMPLATE_QUESTIONS;
        l_max_sequence               NUMBER;

begin
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body

        -- Perform validation

            IF (P_One_Question.mQuestionName is NULL OR P_One_Question.mQuestionName= FND_API.G_MISS_CHAR) THEN
               X_Return_Status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CS','CS_TP_Question_NAME_INVALID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (P_One_Question.mAnswerType is NULL OR P_One_Question.mAnswerType= FND_API.G_MISS_CHAR OR length(P_One_Question.mAnswerType)<=0)THEN
               X_Return_Status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CS','CS_TP_Question_Answer_INVALID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_current_date := sysdate;
            l_created_by := FND_GLOBAL.user_id;
            l_login := fnd_global.login_id;

            --Create Lookup
            select CS_TP_LOOKUP_S.NEXTVAL into l_lookup_id from dual;

            --Insert a new lookup, note DEFAULT_VALUE, X_START_DATE_ACTIVE, X_END_DATE_ACTIVE are null
            CS_TP_LOOKUPS_PKG.INSERT_ROW  (
		    X_ROWID => l_ROWID,
		    X_LOOKUP_ID  => l_lookup_id,
		    X_LOOKUP_TYPE  => P_One_Question.mAnswerType,
		    X_DEFAULT_VALUE => NULL,
		    X_CREATION_DATE => l_current_date,
		    X_CREATED_BY => l_created_by,
		    X_LAST_UPDATE_DATE => l_current_date,
		    X_LAST_UPDATED_BY => l_created_by,
		    X_LAST_UPDATE_LOGIN => l_login,
                    X_START_DATE_ACTIVE => NULL,
                    X_END_DATE_ACTIVE => NULL);


            --Get the question id from the next available sequence number
            select CS_TP_QUESTIONS_S.NEXTVAL into l_question_id from dual;

            --insert into question table

            CS_TP_QUESTIONS_PKG.INSERT_ROW (
	    	  X_ROWID => l_ROWID,
		  X_QUESTION_ID => l_question_id,
		  X_LOOKUP_ID => l_lookup_id,
		  X_MANDTORY_FLAG => P_One_Question.mMandatoryFlag,
		  X_SCORING_FLAG => P_One_Question.mScoringFlag,
		  X_START_DATE_ACTIVE => NULL,
		  X_END_DATE_ACTIVE => NULL,
		  X_NAME => P_One_Question.mQuestionName,
		 -- X_TEXT => P_One_Question.mQuestionName,
                  X_TEXT => 'temp question text',
		  X_DESCRIPTION => NULL,
		  X_CREATION_DATE => l_current_date,
		  X_CREATED_BY => l_created_by,
		  X_LAST_UPDATE_DATE => l_current_date,
		  X_LAST_UPDATED_BY =>l_created_by,
		  X_LAST_UPDATE_LOGIN => l_login,
		  X_NOTE_TYPE => P_One_Question.mNoteType,
		  X_SHOW_ON_CREATION_FLAG => P_One_Question.mShowOnCreationFlag
		  );
           open C;
           fetch C into l_max_sequence;
           if (C%notfound) then
              l_max_sequence := 0;
           end if;
           close C;
           if (l_max_sequence is NULL) then
              l_max_sequence := 0;
           end if;


           --insert into the question template linking table

           CS_TP_TEMPLATE_QUESTIONS_PKG.INSERT_ROW  (
		 X_ROWID => l_ROWID,
		 X_TEMPLATE_ID => P_Template_ID,
		 X_QUESTION_ID  => l_question_id,
		 X_SEQUENCE_NUMBER => l_max_sequence + 1,
                 X_CREATION_DATE => l_current_date,
		  X_CREATED_BY => l_created_by,
		  X_LAST_UPDATE_DATE => l_current_date,
		  X_LAST_UPDATED_BY =>l_created_by,
		  X_LAST_UPDATE_LOGIN => l_login,
		  X_NOTE_TYPE => P_One_Question.mNoteType,
		  X_SHOW_ON_CREATION_FLAG => P_One_Question.mShowOnCreationFlag
	    );
         X_Question_ID :=l_question_id;
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
END Add_Question;

procedure UPDATE_QUESTION (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit                 IN VARCHAR          := FND_API.G_FALSE,
	P_One_Question           IN 	Question,
  X_Msg_Count              OUT NOCOPY     NUMBER,
  X_Msg_Data	             OUT NOCOPY     VARCHAR2,
  X_Return_Status	         OUT NOCOPY     VARCHAR2)
is
        l_api_name     CONSTANT       VARCHAR2(30)   := 'Update_Question';
        l_api_version  CONSTANT       NUMBER         := 1.0;

        l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_last_updated_by                  VARCHAR2(200)        :=FND_API.G_MISS_CHAR;
        l_login                       VARCHAR2(200)        :=FND_API.G_MISS_CHAR;
        l_last_updated_date            DATE;
        l_lookup_id                    NUMBER;
        cursor c is
         select last_update_date, LOOKUP_ID  from CS_TP_QUESTIONS_B
            where QUESTION_ID = P_One_Question.mQuestionID;

begin
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body

        -- Perform validation

            IF (P_One_Question.mQuestionName is NULL OR P_One_Question.mQuestionName= FND_API.G_MISS_CHAR) THEN
               X_Return_Status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CS','CS_TP_Question_NAME_INVALID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

             IF (P_One_Question.mAnswerType is NULL OR P_One_Question.mAnswerType= FND_API.G_MISS_CHAR OR length(P_One_Question.mAnswerType)<=0)THEN
               X_Return_Status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CS','CS_TP_Question_Answer_INVALID');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

       --check to see if the question is modified after the client's query
        open c;
        fetch c into l_last_updated_date, l_lookup_id;
        if (c%notfound) then
           close c;
            X_Return_Status := FND_API.G_RET_STS_ERROR;
           raise no_data_found;
        end if;
        close c;
        -- is the last updated date from db later than the date from client
        if (l_last_updated_date >  TO_DATE (P_One_Question.mLast_Updated_Date, l_default_last_up_date_format )) then
            X_Return_Status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CS','CS_TP_QUESTION_UPDATED');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        end if;

     -- Update the  question  table , note lookup_id is not modified.
        l_current_date := sysdate;
        l_last_updated_by := fnd_global.user_id;
        l_login := fnd_global.login_id;

         CS_TP_QUESTIONS_PKG.UPDATE_ROW (
	    X_QUESTION_ID => P_One_Question.mQuestionID,
	    X_LOOKUP_ID => l_lookup_id,
	    X_MANDTORY_FLAG =>P_One_Question.mMandatoryFlag,
	    X_SCORING_FLAG =>P_One_Question.mScoringFlag,
	    X_START_DATE_ACTIVE => NULL,
	    X_END_DATE_ACTIVE =>NULL,
	    X_NAME =>P_One_Question.mQuestionName,
	    --X_TEXT =>P_One_Question.mQuestionName,
            X_TEXT =>'temp question text',
	    X_DESCRIPTION => NULL,
	    X_LAST_UPDATE_DATE => l_current_date,
	    X_LAST_UPDATED_BY => l_last_updated_by,
	    X_LAST_UPDATE_LOGIN => l_login,
         X_NOTE_TYPE => P_One_Question.mNoteType,
	    X_SHOW_ON_CREATION_FLAG => P_One_Question.mShowOnCreationFlag

            );
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
end UPDATE_QUESTION;

procedure Delete_Question (
	p_api_version_number     IN   NUMBER,
  p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
  p_commit       		       IN VARCHAR        := FND_API.G_FALSE,
  p_Question_ID  	         IN      NUMBER,
	p_Template_ID            IN      NUMBER,
	X_Msg_Count              OUT NOCOPY     NUMBER,
  X_Msg_Data	             OUT NOCOPY     VARCHAR2,
  X_Return_Status	         OUT NOCOPY     VARCHAR2)

is
        type choice_list  is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        l_api_name     CONSTANT       VARCHAR2(30)   := 'Delete_Question';
        l_api_version  CONSTANT       NUMBER         := 1.0;

        l_choice_list     choice_list;
        l_freetext_id      NUMBER;
        l_freetext_num     NUMBER;
         l_lookup_id                Number;
        i                      NUMBER;
        Cursor lookup_c is
            select lookup_id from CS_TP_QUESTIONS_B where question_id = p_Question_ID;

        Cursor
          freetext_num_c (v_lookup_id NUMBER)
            is select count (*) from CS_TP_FREETEXTS where LOOKUP_ID = v_lookup_id;
        Cursor
          free_text_c (v_lookup_id NUMBER) is
            select freetext_id from CS_TP_FREETEXTS where LOOKUP_ID = v_lookup_id;
        Cursor
          choice_c (v_lookup_id NUMBER) is
            select choice_id from CS_TP_CHOICES_VL  where LOOKUP_ID = v_lookup_id;


begin
      -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

      -- Start API Body
         open lookup_c;
         fetch lookup_c into l_lookup_id;
         if (lookup_c%notfound) then
              close lookup_c;
              raise no_data_found;
         end if;
         close lookup_c;

       --delete template question link
         CS_TP_TEMPLATE_QUESTIONS_PKG.DELETE_ROW (
               X_TEMPLATE_ID  => p_Template_ID,
	       X_QUESTION_ID  => p_Question_ID);
        --delete lookup
         CS_TP_LOOKUPS_PKG.DELETE_ROW (l_lookup_id);
       --delete question
         CS_TP_QUESTIONS_PKG.DELETE_ROW (X_QUESTION_ID => p_Question_ID);



         --delete freetext or choices
         open freetext_num_c(l_lookup_id);
         fetch freetext_num_c into l_freetext_num;
         close freetext_num_c;
         if (l_freetext_num=1) then
             open free_text_c(l_lookup_id);
             fetch free_text_c into l_freetext_id;
             close free_text_c;
             CS_TP_FREETEXTS_PKG.DELETE_ROW (
	        X_FREETEXT_ID => l_freetext_id);

         elsif (l_freetext_num>1) then
             X_Return_Status := FND_API.G_RET_STS_ERROR;
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         --delete choice
         open choice_c (l_lookup_id);
         i:=0;
         loop
           fetch choice_c into l_choice_list (i);
           exit when (choice_c%notfound);
           i:=i+1;
         end loop;
         close choice_c;

         if (l_choice_list.COUNT > 0) then
         for i in l_choice_list.FIRST..l_choice_list.LAST loop
             CS_TP_CHOICES_PKG.DELETE_ROW (
                X_CHOICE_ID => l_choice_list (i)
              );
         end loop;
         end if;
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

end Delete_Question;


procedure Sort_Questions (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_Questions		IN    Question_List,
  P_Template_ID            IN      NUMBER,
	X_Msg_Count   OUT NOCOPY NUMBER,
  X_Msg_Data			OUT NOCOPY VARCHAR2,
 	X_Return_Status  OUT NOCOPY VARCHAR2
)

is
       l_api_name     CONSTANT       VARCHAR2(30)   := 'Sort_Questions';
       l_api_version  CONSTANT       NUMBER         := 1.0;
       i                             NUMBER;
        l_current_date                DATE           :=FND_API.G_MISS_DATE;
        l_last_updated_by                  VARCHAR2(200)        :=FND_API.G_MISS_CHAR;
        l_login                       VARCHAR2(200)        :=FND_API.G_MISS_CHAR;
        Cursor last_updateC  (V_Question_ID Number)  is
           select last_update_date from CS_TP_QUESTIONS_VL  where QUESTION_ID = V_Question_ID ;
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

        if (P_Questions.COUNT>0) then
           for i in P_Questions.FIRST..P_Questions.LAST  loop
                open last_updateC (P_Questions(i).mQuestionID);
               fetch last_updateC into l_last_update_date;
               if (last_updateC%notfound) then
                 close last_updateC;
                 raise no_data_found;
               end if;
               close last_updateC;
               if (to_date( P_Questions(i).mLast_Updated_date, l_default_last_up_date_format) < l_last_update_date) then
                 X_Return_Status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('CS','CS_TP_QUESTION_UPDATED');
                 FND_MSG_PUB.Add;
            	 RAISE FND_API.G_EXC_ERROR;
               end if;

               CS_TP_TEMPLATE_QUESTIONS_PKG.UPDATE_ROW (
                   X_TEMPLATE_ID => P_Template_ID,
                   X_QUESTION_ID => P_Questions (i).mQuestionID,
			    X_NOTE_TYPE => P_Questions (i).mNoteType,
			    X_SHOW_ON_CREATION_FLAG =>
						P_Questions (i).mShowOnCreationFlag,
                   X_SEQUENCE_NUMBER => i,
		   X_LAST_UPDATE_DATE => l_current_date,
		   X_LAST_UPDATED_BY => l_last_updated_by,
		   X_LAST_UPDATE_LOGIN => l_login );
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
end SORT_QUESTIONS;

procedure Show_Questions  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
  p_Template_ID           IN NUMBER,
	P_Start_Question 	IN NUMBER,
	P_End_Question 		IN NUMBER,
	P_Display_Order 	IN VARCHAR2,
 	X_Msg_Count   OUT NOCOPY NUMBER,
 	X_Msg_Data    OUT NOCOPY VARCHAR2,
 	X_Return_Status  OUT NOCOPY VARCHAR2,
	X_Question_List_To_Show OUT NOCOPY Question_List,
        X_Total_Questions        OUT NOCOPY NUMBER,
        X_Retrieved_Question_Number OUT NOCOPY NUMBER
       )
is
        l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Questions';
        l_api_version  CONSTANT       NUMBER         := 1.0;
        l_statement                   VARCHAR2(1000);
        L_QUESTION_ID                 NUMBER;
        L_QUESTION_NAME               VARCHAR2(2000);
        L_ANSWER_TYPE                 VARCHAR2(60);
        L_MANDATORY_FLAG              VARCHAR2(60);
        L_SCORING_FLAG                VARCHAR2(60);
        L_LOOKUP_ID                   NUMBER;
        L_LAST_UPDATED_DATE	      DATE;
        l_CursorID                    INTEGER;
        i                             NUMBER;
        j                             NUMBER;
        L_Start_Question      NUMBER;
        L_End_Question       NUMBER;
        L_Total_Questions_NotUsed     NUMBER;

		L_NOTE_TYPE	VARCHAR2(30);
		L_SHOW_ON_CREATION_FLAG VARCHAR2(1);
begin
      -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body

        L_Start_Question := P_Start_Question;
        L_End_Question := P_End_Question;
        -- Check for null L_Start_Question and P_End_Question
           if (L_Start_Question is NULL or L_Start_Question = FND_API.G_MISS_NUM) then
               L_Start_Question :=1;
           end if;
        --If L_End_Question is NULL, set it to G_MISS_NUM which should be a greater than index of the last question
           if (L_End_Question is NULL or L_End_Question = FND_API.G_MISS_NUM) then
               L_End_Question :=FND_API.G_MISS_NUM;
           end if;
        -- validation
           if (L_Start_Question > L_End_Question OR L_Start_Question<=0 OR L_End_Question<=0) then
                 X_Return_Status := FND_API.G_RET_STS_ERROR;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;
        -- Construct query statement, open cursor, execute query statement, retrieve results
        l_statement := 'SELECT Q.QUESTION_ID, Q.NAME, L.LOOKUP_TYPE, Q.MANDTORY_FLAG, Q.SCORING_FLAG, Q.LOOKUP_ID, Q.LAST_UPDATE_DATE, Q.NOTE_TYPE, Q.SHOW_ON_CREATION_FLAG '
	||  ' FROM CS_TP_QUESTIONS_VL Q, CS_TP_LOOKUPS L, CS_TP_TEMPLATE_QUESTIONS TQ' ||
	' where Q.LOOKUP_ID = L.LOOKUP_ID and TQ.QUESTION_ID = Q.QUESTION_ID and TQ.TEMPLATE_ID=:v_Template_ID';

        if (P_Display_Order is  NULL OR P_Display_Order=FND_API.G_MISS_CHAR OR length(P_Display_Order)<=0 OR P_Display_Order =NORMAL) then
             l_statement := l_statement || ' ORDER BY TQ.SEQUENCE_NUMBER ';

        elsif (P_Display_Order=ALPHABATICAL) then
            l_statement := l_statement || ' ORDER BY Q.NAME ';
        elsif (P_Display_Order = REVERSE_ALPHABATICAL) then
            l_statement := l_statement || ' ORDER BY Q.NAME desc ';
        elsif (P_Display_Order = CRONOLOGICAL) then
            l_statement := l_statement || ' ORDER BY LAST_UPDATE_DATE ';
        elsif (P_Display_Order = REVERSE_CRONOLOGICAL) then
            l_statement := l_statement || ' ORDER BY LAST_UPDATE_DATE desc ';
        else
            l_statement := l_statement || ' ORDER BY TQ.SEQUENCE_NUMBER ';
        end if;
        l_CursorID := dbms_sql.open_cursor;

	/*
        IF (FND_API.To_Boolean (DEBUG)) then
           dbms_output.put_line ('Statement is ' || substr (l_statement, 1, 200));
            dbms_output.put_line ( substr (l_statement, 201, 400));
        end if;
    	*/

        dbms_sql.parse(l_CursorID, l_statement, dbms_sql.NATIVE);

        dbms_sql.bind_variable(l_CursorID, 'v_Template_ID', P_Template_ID);

         dbms_sql.define_column(l_CursorID, 1, L_QUESTION_ID);
        dbms_sql.define_column(l_CursorID, 2, L_QUESTION_NAME,2000);
        dbms_sql.define_column(l_CursorID, 3, L_ANSWER_TYPE, 60);
        dbms_sql.define_column(l_CursorID, 4, L_MANDATORY_FLAG, 60 );
        dbms_sql.define_column(l_CursorID, 5, L_SCORING_FLAG, 60);
        dbms_sql.define_column(l_CursorID, 6, L_LOOKUP_ID);
        dbms_sql.define_column(l_CursorID, 7, L_LAST_UPDATED_DATE);

	   dbms_sql.define_column(l_CursorID, 8, L_NOTE_TYPE, 30);
	   dbms_sql.define_column(l_CursorID, 9, L_SHOW_ON_CREATION_FLAG,1);


         L_Total_Questions_NotUsed := dbms_sql.execute(l_CursorID);

        i:=1;
        j:=0;

        while (dbms_sql.fetch_rows(l_CursorID) > 0) loop
            if (i>= L_Start_Question AND i<=L_End_Question) then
                 dbms_sql.column_value(l_CursorID, 1, L_QUESTION_ID);
                 dbms_sql.column_value(l_CursorID, 2, L_QUESTION_NAME);
                 dbms_sql.column_value(l_CursorID, 3, L_ANSWER_TYPE);
                 dbms_sql.column_value(l_CursorID, 4, L_MANDATORY_FLAG);
                 dbms_sql.column_value(l_CursorID, 5, L_SCORING_FLAG);
                 dbms_sql.column_value(l_CursorID, 6, L_LOOKUP_ID);
                 dbms_sql.column_value(l_CursorID, 7, L_LAST_UPDATED_DATE);

			  dbms_sql.column_value(l_CursorID, 8, L_NOTE_TYPE);
			  dbms_sql.column_value(l_CursorID, 9, L_SHOW_ON_CREATION_FLAG);

                 X_Question_List_To_Show(j).mQuestionID := L_Question_ID;
                 X_Question_List_To_Show(j).mQuestionName := L_Question_NAME;
                 X_Question_List_To_Show(j).mAnswerType := L_ANSWER_TYPE;
                 X_Question_List_To_Show(j).mMandatoryFlag:= L_MANDATORY_FLAG;
                 X_Question_List_To_Show(j).mScoringFlag :=L_SCORING_FLAG;
                 X_Question_List_To_Show(j).mLookUpID := L_LOOKUP_ID;
                 X_Question_List_To_Show(j).mLast_Updated_Date := to_char( L_LAST_UPDATED_DATE, l_default_last_up_date_format);

			  X_Question_List_To_Show(j).mNoteType := L_NOTE_TYPE;
			  X_Question_List_To_Show(j).mShowOnCreationFlag :=
											L_SHOW_ON_CREATION_FLAG;
                 j:=j+1;
            elsif (i > L_End_Question) then
                 --exit;
                 null;
            end if;
                 i:=i+1;
        end loop;

       dbms_sql.close_cursor(l_CursorID);
       X_Retrieved_Question_Number := j;
       X_Total_Questions := i-1;
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

end Show_Questions;

procedure Show_Question (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_Question_ID   	IN NUMBER,
   	X_Msg_Count   OUT NOCOPY NUMBER,
  	X_Msg_Data    OUT NOCOPY VARCHAR2,
  	X_Return_Status   OUT NOCOPY VARCHAR2,
	X_Question_To_Show  OUT NOCOPY Question
        )

is
      l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Question';
      l_api_version  CONSTANT       NUMBER         := 1.0;
      cursor C (v_Question_ID NUMBER) is
	   SELECT Q.QUESTION_ID, Q.NAME, L.LOOKUP_TYPE, Q.MANDTORY_FLAG, Q.SCORING_FLAG, Q.LOOKUP_ID, Q.LAST_UPDATE_DATE, Q.NOTE_TYPE, Q.SHOW_ON_CREATION_FLAG
	   FROM CS_TP_QUESTIONS_VL Q, CS_TP_LOOKUPS L  where Q.LOOKUP_ID = L.LOOKUP_ID and Q.QUESTION_ID = v_Question_ID;
        One_Question       C%ROWTYPE;

begin
     -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        X_Return_Status := FND_API.G_RET_STS_SUCCESS;

        -- Start API Body
        open C (P_Question_ID);
        fetch C into One_Question;
        if (C%notfound) then
          close C;
          X_Return_Status := FND_API.G_RET_STS_ERROR;
          raise no_data_found;
        end if;
        close C;
        X_Question_To_Show.mQuestionID := One_Question.Question_ID;
        X_Question_To_Show.mQuestionName :=  One_Question.Name;
        X_Question_To_Show.mAnswerType := One_Question.Lookup_Type ;
        X_Question_To_Show.mMandatoryFlag:= One_Question.Mandtory_Flag;
        X_Question_To_Show.mScoringFlag :=  One_Question.Scoring_Flag;
        X_Question_To_Show.mLookUpID :=  One_Question.LookUp_ID;
        X_Question_To_Show.mLast_Updated_Date := to_char( One_Question.Last_Update_Date , l_default_last_up_date_format);
	   X_Question_To_Show.mNoteType := One_Question.Note_Type;
	   X_Question_To_Show.mShowOnCreationFlag := One_Question.Show_On_Creation_Flag;

      -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit) THEN
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

end Show_Question;

end CS_TP_QUESTIONS_PVT;

/
