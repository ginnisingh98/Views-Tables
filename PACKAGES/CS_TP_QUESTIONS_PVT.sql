--------------------------------------------------------
--  DDL for Package CS_TP_QUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_TP_QUESTIONS_PVT" AUTHID CURRENT_USER as
/* $Header: cstpqsms.pls 115.15 2002/12/05 22:47:32 wzli noship $ */


-- *****************************************************************************
-- Start of Comments
--
--   Record: Question
--
--
--   mQuestionID	        NUMBER
--   mQuestionName              VARCHAR2(1000)
--   mAnswerType		VARCHAR2(60)
--   mMandatoryFlag		VARCHAR2(60)
--   mScoringFlag		VARCHAR2(60)
--   mLookUpID			NUMBER
--   mLast_Updated_Date		VARCHAR2(60)


--   newly added  3-11-2002
--   mNoteType			VARCHAR2(30)
--   mShowOnCreationFlag VARCHAR2(1)
-- End of Comments

TYPE Question is RECORD (
     mQuestionID	        NUMBER := FND_API.G_MISS_NUM,
     mQuestionName              VARCHAR2(2000) := FND_API.G_MISS_CHAR ,
     mAnswerType		VARCHAR2(60) := FND_API.G_MISS_CHAR,
     mMandatoryFlag		VARCHAR2(60) := FND_API.G_MISS_CHAR,
     mScoringFlag		VARCHAR2(60) := FND_API.G_MISS_CHAR,
     mLookUpID			NUMBER := FND_API.G_MISS_NUM,
     mLast_Updated_Date		VARCHAR2(60) := FND_API.G_MISS_CHAR ,

	mNoteType			VARCHAR2(30),
     mShowOnCreationFlag VARCHAR2(1)
);

-- *****************************************************************************
-- Start of Comments
--
--   Table:  Binary Indexed Table of Questions
--
-- End of Comments

TYPE Question_List is TABLE OF Question
		INDEX BY BINARY_INTEGER;

-- *****************************************************************************
--   Display Order Constants are used to dictate the  order of the list of templates/questions queried
--        ALPHABATICAL
--        REVERSE_ALPHABATICAL
--        NORMAL
--        CRONOLOGICAL
--        REVERSE_CRONOLOGICAL
         ALPHABATICAL          CONSTANT       VARCHAR(60):='ALPHABATICAL';
          REVERSE_ALPHABATICAL       CONSTANT   VARCHAR(60):='REVERSE_ALPHABATICAL';
          NORMAL              CONSTANT             VARCHAR(60):='NORMAL';
          CRONOLOGICAL        CONSTANT              VARCHAR(60):='CRONOLOGICAL';
          REVERSE_CRONOLOGICAL        CONSTANT              VARCHAR(60):='REVERSE_CRONOLOGICAL';

--       Anwser Type
--       Anwer type denotes the answer format to a question.  The two answer types are  freetext and multiple choice.

         FREETEXT             CONSTANT      VARCHAR (60):='FREETEXT';
         CHOICE             CONSTANT      VARCHAR (60):='CHOICE';


-- *****************************************************************************
-- Start of Comments
--   This procedure Add_Question add an additional question to the CS_TP_QUESIONS_B and CS_TP_QUESTIONS_TL as well as associate the question to the template id passed in.
--   In addition, it will create a lookup id with answer information such as answer type--  and associate it with the question.
--  In the Question Record, Question Name and AnswerType need to be valid.  Mandatory Flag and Scoring Flag need to either FND_API.G_TRUE or FND_API.G_FALSE.  Lookup ID, Question ID, Last Updated Date are not needed.
-- @param	One_Question          required
-- @param	Template_ID           required
-- @param	p_api_version_number  required
-- @param       p_commit
-- @param	p_init_msg_list


-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--              X_Question_ID
-- End of Comments
procedure Add_Question  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_One_Question  IN 	Question,
        p_Template_ID	IN      NUMBER,
        X_Msg_Count OUT NOCOPY     NUMBER,
        X_Msg_Data  OUT NOCOPY     VARCHAR2,
  	X_Return_Status OUT NOCOPY     VARCHAR2,
	X_Question_ID OUT NOCOPY     NUMBER);


-- *****************************************************************************
-- Start of Comments
--   This procedure Update_Question modifys an existing question in the CS_TP_QUESIONS_B and CS_TP_QUESTIONS_TL table with what is in the P_One_Question record
--  In the Question Record, Question ID is used to identify the question.  Last
-- Updated Date is required to check whether the record is updated after the u
--ser last queries.    Question Name and AnswerType need to be valid.  Mandato
--ry Flag and Scoring Flag need to either FND_API.G_TRUE or FND_API.G_FALSE.  Lookup ID is not needed.
--
-- @param	P_One_Question          required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list
-- @param       X_Msg_Count
-- @param	X_Msg_Data
-- @param       X_Return_Status

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status

-- End of Comments

procedure Update_Question  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_One_Question  IN 	Question,
        X_Msg_Count OUT NOCOPY     NUMBER,
        X_Msg_Data  OUT NOCOPY     VARCHAR2,
  	X_Return_Status OUT NOCOPY     VARCHAR2);


-- *****************************************************************************
-- Start of Comments
--   This procedure Delete_Question deletes an existing question with passed in Question_ID
--@param	p_api_version_number
--@param	p_init_msg_list
--@param	p_commit
--@param        p_One_Question

--@return	X_Msg_Count
--        	X_Msg_Data
--  		X_Return_Status
-- End of Comments

procedure Delete_Question (
	p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
        p_commit       		IN VARCHAR        := FND_API.G_FALSE,
        p_Question_ID  	IN      NUMBER,
	p_Template_ID   IN      NUMBER,
	X_Msg_Count OUT NOCOPY     NUMBER,
        X_Msg_Data  OUT NOCOPY     VARCHAR2,
  	X_Return_Status OUT NOCOPY     VARCHAR2);

-- *****************************************************************************
-- Start of Comments
--   This procedure Sort_Questions sorts the questions in the order of the list
-- of the questions passed in.  The user calls Show_Questions after calling So
--rt_Questions and the Show_Questions will return a list of questions in the s
--ame order as the order user passed in to the Sort questions.
--   User needs to pass in a template ID and a question list in the order that
-- the user wishes for the questions to be stored.  In each of the question rec
--ord, only the question ID is required.
--@param	p_api_version_number  required
--@param	p_init_msg_list
--@param	p_commit
--@param        P_Question_List
--@param        P_Template_ID required
--@return	X_Msg_Count
--        	X_Msg_Data
--  		X_Return_Status
-- End of Comments

procedure Sort_Questions (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_Questions		IN    Question_List,
         P_Template_ID            IN      NUMBER,
	X_Msg_Count  OUT NOCOPY NUMBER,
  	X_Msg_Data    OUT NOCOPY VARCHAR2,
 	X_Return_Status   OUT NOCOPY VARCHAR2
);

-- *****************************************************************************
-- Start of Comments
--
-- Show_Questions  takes two numbers P_Start_Question  and P_End_Question as th
--e start question number and end question number,and the Display Order of the
--questions.  It will return a table of questions, the total number of questio
-- available and the total number retrieved.
--@param	P_Start_Question
--@param	P_End_Question
--@param	P_Display_Order
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--		X_Question_List_To_Show
--		X_Total_Questions
--		X_Retrieved_Question_Number

-- End of Comments

procedure Show_Questions  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
        P_Template_ID           IN NUMBER,
	P_Start_Question 	IN NUMBER,
	P_End_Question 		IN NUMBER,
	P_Display_Order 	IN VARCHAR2,
 	X_Msg_Count   OUT NOCOPY NUMBER,
 	X_Msg_Data    OUT NOCOPY VARCHAR2,
 	X_Return_Status  OUT NOCOPY VARCHAR2,
	X_Question_List_To_Show OUT NOCOPY Question_List,
        X_Total_Questions      OUT NOCOPY NUMBER,
        X_Retrieved_Question_Number OUT NOCOPY NUMBER
       );

-- *****************************************************************************
-- Start of Comments
--
-- Show_Question returns a quesion record which takes a question id and returns a question record.
-- @param 	p_Question_ID  required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--		X_Question_To_Show
-- End of Comments

procedure Show_Question (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_Question_ID   	IN NUMBER,
   	X_Msg_Count   OUT NOCOPY NUMBER,
  	X_Msg_Data		OUT NOCOPY VARCHAR2,
  	X_Return_Status		OUT NOCOPY VARCHAR2,
	X_Question_To_Show  OUT NOCOPY Question
        );


end  CS_TP_QUESTIONS_PVT;

 

/
