--------------------------------------------------------
--  DDL for Package CS_TP_CHOICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_TP_CHOICES_PVT" AUTHID CURRENT_USER as
/* $Header: cstpcsms.pls 115.13 2002/12/04 02:02:15 wzli noship $ */


--
-- Start of Comments
--
--   Record: Choice
--
--
--   mChoiceID	        NUMBER
--   mChoiceName        VARCHAR2(1000)
--   mLookUpID		NUMBER
--   mScore			NUMBER
--   mLast_Updated_Date		VARCHAR2(60)

-- End of Comments

TYPE Choice  is RECORD (
     mChoiceID	        NUMBER := FND_API.G_MISS_NUM,
     mChoiceName              VARCHAR2(1000) := FND_API.G_MISS_CHAR ,
     mLookupID		NUMBER := FND_API.G_MISS_NUM,
     mScore		NUMBER := FND_API.G_MISS_NUM,
     mLast_Updated_Date		VARCHAR2(60) := FND_API.G_MISS_CHAR
     ,mDefaultChoiceFlag VARCHAR2(1) := FND_API.G_MISS_CHAR
   );

--
-- Start of Comments
--
--   Table:  Binary Indexed Table of Choice
--
-- End of Comments

TYPE Choice_List is TABLE OF Choice
		INDEX BY BINARY_INTEGER;

--
-- Start of Comments
--
--   Record: Freetext
--   mFreetextID           NUMBER
--   mFreetextSize              NUMBER
--   mFreeTextDefaultText       VARCAHR2
--   mLookUpID              NUMBER
--   mLast_Updated_Date      VARCHAR2

TYPE FREETEXT is RECORD (
    mFreetextID           NUMBER  :=FND_API.G_MISS_NUM,
    mFreetextSize                NUMBER  :=FND_API.G_MISS_NUM,
    mFreeTextDefaultText       VARCHAR2(1000)  :=FND_API.G_MISS_CHAR,
    mLookUpID              NUMBER  :=FND_API.G_MISS_NUM,
    mLast_Updated_Date      VARCHAR2(200)   :=FND_API.G_MISS_CHAR
);

--
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

--
-- Start of Comments
--   This procedure Add_Choice add an additional choice to the CS_TP_CHOICES_B and CS_TP_CHOICES_TL
--   In each choice record, the choice name, score, and lookup ID are required.
--   Validation is performed to see if the lookup ID is valid.
--
--
-- @param	p_Choice             required
-- @param	p_api_version_number  required
-- @param       p_commit
-- @param	p_init_msg_list


-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--              X_Choice_ID
-- End of Comments

procedure Add_Choice (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    p_One_Choice      IN Choice,
    X_Msg_Count OUT NOCOPY  NUMBER,
    X_Msg_Data  OUT NOCOPY  VARCHAR2,
    X_Return_Status OUT NOCOPY  VARCHAR2,
    X_Choice_ID OUT NOCOPY  NUMBER);

--
-- Start of Comments
--   This procedure Delete_Choice  deletes an existing choice  with passed in Choice_ID
--@param	p_api_version_number
--@param	p_init_msg_list
--@param	p_commit
--@param        p_One_Question

--@return	X_Msg_Count
--        	X_Msg_Data
--  		X_Return_Status
-- End of Comments

procedure Delete_Choice  (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_Choice_ID	   IN   NUMBER,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data OUT NOCOPY     VARCHAR2,
    X_Return_Status OUT NOCOPY     VARCHAR2
);

--
-- Start of Comments
--   This procedure Sort_Choicess sorts the choices in the order of the list of
-- the choices passed in.  The user calls Show_Choices with P_Display_Order equ
--al to normal after calling Sort_Choices and the Show_Choices will return a li
--st of choices in the same order as the order user passed into the Sort_Choice
--s.
--   In the list of choices passed in, the lookup ID needs to be the same for each choice.
--@param	p_api_version_number  required
--@param	p_init_msg_list
--@param	p_commit
--@param        P_Choice   required

--@return	X_Msg_Count
--        	X_Msg_Data
--  		X_Return_Status
-- End of Comments
procedure Sort_Choices (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN VARCHAR          := FND_API.G_FALSE,
    P_Choices                In    Choice_List,
    X_Msg_Count              OUT NOCOPY     NUMBER,
    X_Msg_Data               OUT NOCOPY     VARCHAR2,
    X_Return_Status          OUT NOCOPY     VARCHAR2
);
--
-- Start of Comments
--
-- Show_Choices takes a Lookup_ID and returns a list of choices associated with the Lookup_ID
--@param    P_Lookup_Id
--@param    P_Display_Order
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list
-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--              X_Choice_List_To_Show

procedure Show_Choices (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_Lookup_Id		IN NUMBER,
    P_Display_Order     IN VARCHAR2,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data  OUT NOCOPY     VARCHAR2,
    X_Return_Status	 OUT NOCOPY     VARCHAR2,
    X_Choice_List_To_Show  OUT NOCOPY   Choice_List
);
--
-- Start of Comments
--
-- Update_Choices takes a list of choices and save it to database
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list
-- @param	Choice_List
-- @param
-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status

procedure Update_Choices (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_Choices                In    Choice_List,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data  OUT NOCOPY     VARCHAR2,
    X_Return_Status OUT NOCOPY     VARCHAR2
);
--
-- Start of Comments
--
-- Add Freetext adds the freetext to the CS_TP_FREETEXTS table
-- There is a freetext row associated with the lookup id in the freetext record passed in , then update the CS_TP_FREETEXTS table
-- otherwise insert the freetext.
--@param        P_Lookup_Id  required
--@param        P_Freetext    required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list
-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--              X_Freetext_ID

procedure Add_Freetext (
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit       IN VARCHAR          := FND_API.G_FALSE,
    P_One_Freetext		in    Freetext,
    X_Msg_Count OUT NOCOPY     NUMBER,
    X_Msg_Data OUT NOCOPY     VARCHAR2,
    X_Return_Status OUT NOCOPY     VARCHAR2,
    X_Freetext_ID       OUT NOCOPY NUMBER
);

--
-- Start of Comments
--
-- Show_Freetext displays the freetext.
--@param         P_Lookup_Id  required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list
-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--              X_Freetext
procedure Show_Freetext (
   p_api_version_number     IN   NUMBER,
   p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
   p_commit       IN VARCHAR          := FND_API.G_FALSE,
   P_Lookup_ID          IN NUMBER,
   X_Msg_Count OUT NOCOPY     NUMBER,
   X_Msg_Data OUT NOCOPY     VARCHAR2,
   X_Return_Status OUT NOCOPY     VARCHAR2,
   X_Freetext  OUT NOCOPY     FREETEXT
  );

end CS_TP_CHOICES_PVT;

 

/
