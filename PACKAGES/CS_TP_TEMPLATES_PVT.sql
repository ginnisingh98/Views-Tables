--------------------------------------------------------
--  DDL for Package CS_TP_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_TP_TEMPLATES_PVT" AUTHID CURRENT_USER as
/* $Header: cstptmms.pls 115.21 2003/02/14 04:29:09 wma noship $ */

-- *****************************************************************************
-- Start of Comments
--
--   Record: Template
--
--
--   mTemplateID	        NUMBER
--   mTemplateName              VARCHAR2(1000)
--   mStartDate		        VARCHAR2(120)
--   mEndDate			VARCHAR2(120)
--   mDefaultFlag		VARCHAR2(60)
--   mLast_Updated_Date		VARCHAR2(120)

--  Newly added
--  mUniQuestionNoteFlag, mUniQuestionNoteType
-- End of Comments

TYPE Template is RECORD (
     mTemplateID	        NUMBER:=FND_API.G_MISS_NUM,
     mTemplateName              VARCHAR2(1000):=FND_API.G_MISS_CHAR,
     mStartDate		        VARCHAR2(120):=FND_API.G_MISS_CHAR,
     mEndDate			VARCHAR2(120):=FND_API.G_MISS_CHAR,
     mDefaultFlag		VARCHAR2(1):=FND_API.G_FALSE,
     mShortCode			VARCHAR2(600):=FND_API.G_MISS_CHAR,
     mLast_Updated_Date		VARCHAR2(120):=FND_API.G_MISS_CHAR,
	mUniQuestionNoteFlag     VARCHAR2(1) := FND_API.G_MISS_CHAR,
	mUniQuestionNoteType     VARCHAR2(30) := FND_API.G_MISS_CHAR
);

-- *****************************************************************************
-- Start of Comments
--
--   Table:  Binary Indexed Table of Template
--
-- End of Comments

TYPE Template_List is TABLE OF Template
		INDEX BY BINARY_INTEGER;



-- *****************************************************************************
-- Start of Comments
--
--   Record: Template_Attribute
--
--
--   mAttributeID	        NUMBER
--   mAttributeName             VARCHAR2(1000)
--   mStartThreshold		NUMBER
--   mEndThreshold		NUMBER
--   mJTF_OBJECT_CODE		VARCHAR2(200)
--   mOther_ID                  NUMBER
--   mLast_Updated_Date		VARCHAR2(120)

-- End of Comments

TYPE Template_Attribute is RECORD (
     mAttributeID	        NUMBER :=FND_API.G_MISS_NUM,
     mAttributeName             VARCHAR2(1000):=FND_API.G_MISS_CHAR,
     mStartThreshold		NUMBER:=FND_API.G_MISS_NUM,
     mEndThreshold		NUMBER:=FND_API.G_MISS_NUM,
     mJTF_OBJECT_CODE		VARCHAR2(200):=FND_API.G_MISS_CHAR,
     mOther_ID                  NUMBER:=FND_API.G_MISS_NUM,
     mDefaultFlag		VARCHAR2(200):=FND_API.G_FALSE,
     mLast_Updated_Date		VARCHAR2(120):=FND_API.G_MISS_CHAR
);

-- *****************************************************************************
-- Start of Comments
--
--   Table:  Binary Indexed Table of Template Attribute
--

-- End of Comments

TYPE Template_Attribute_List is TABLE OF Template_Attribute
		INDEX BY BINARY_INTEGER;

-- *****************************************************************************
-- Start of Comments
--
--   Record: Template_Link
--
--
--   mLinkID	        	NUMBER
--   mLinkName             	VARCHAR2(1000)
--   mLinkDesc 			VARCHAR2(1000)
--   mJTF_OBJECT_CODE	        VARCHAR2(200)
--   mOther_ID                  NUMBER
--   mLast_Updated_Date		VARCHAR2(120)

-- End of Comments

TYPE Template_Link is RECORD (
     mLinkID	        	NUMBER :=FND_API.G_MISS_NUM,
     mLinkName             	VARCHAR2(1000):=FND_API.G_MISS_CHAR,
     mLinkDesc 			VARCHAR2(1000):=FND_API.G_MISS_CHAR,
     mJTF_OBJECT_CODE		VARCHAR2(200):=FND_API.G_MISS_CHAR,
     mOther_ID                  NUMBER:=FND_API.G_MISS_NUM,
     lookup_Code            VARCHAR2(30):= FND_API.G_MISS_CHAR,
     lookup_Type            VARCHAR2(30):=FND_API.G_MISS_CHAR,
     mLast_Updated_Date		VARCHAR2(120):=FND_API.G_MISS_CHAR
);

-- *****************************************************************************
-- Start of Comments
--
--   Table:  Binary Indexed Table of Template Link
--
-- End of Comments

TYPE Template_Link_List is TABLE OF Template_Link
		INDEX BY BINARY_INTEGER;

-- *****************************************************************************
-- Start of Comments
--
--   Record: ID_NAME_PAIR
--   mOBJECT_CODE        	VARCHAR2(1000)
--   mName              	VARCHAR2(1000)
-- End of Comments
-- *****************************************************************************
TYPE ID_NAME_PAIR is RECORD (
     mOBJECT_CODE			VARCHAR2(1000):=FND_API.G_MISS_CHAR,
     mName			VARCHAR2(1000):=FND_API.G_MISS_CHAR);


-- *****************************************************************************
-- Start of Comments
--
--   Table of ID_NAME_PAIR index by binary integer
-- End of Comments
TYPE ID_NAME_PAIRS  is TABLE OF ID_NAME_PAIR
		INDEX BY BINARY_INTEGER;

-- *****************************************************************************
-- Start of Comments
--
--   Record: OBJECT_OTHER_ID_PAIR
--   mOTHER_ID		        	NUMBER
--   mOBJECT_CODE   	           	VARCHAR2(1000)
-- End of Comments
-- *****************************************************************************
TYPE  OBJECT_OTHER_ID_PAIR is RECORD (
     mOTHER_ID		        	NUMBER,
     mLOOKUP_CODE               VARCHAR2(30),
     mOBJECT_CODE   	           	VARCHAR2(1000)
);

-- *****************************************************************************
-- Start of Comments
--
--   Table of OBJECT_OTHER_ID_PAIR  index by binary integer
-- End of Comments
TYPE OBJECT_OTHER_ID_PAIRS  is TABLE OF OBJECT_OTHER_ID_PAIR
		INDEX BY BINARY_INTEGER;


-- *****************************************************************************
-- Start of Comments
--
--   Constant Integer
--        g_attr_max_threshold
--        g_attr_min_threshold

--	 These two constants define the maxmimum and minimum threshold values for the threshold values in the template attribute.  These two values are used in the threshold values validation.

--   Display Order Constants are used to dictate the  order of the list of templates/questions queried
--        ALPHABATICAL
--        REVERSE_ALPHABATICAL
--        NORMAL
--        CRONOLOGICAL
--        REVERSE_CRONOLOGICAL
-- End of Comments
          g_attr_max_threshold	    CONSTANT      NUMBER:=100;
          g_attr_min_threshold       CONSTANT      NUMBER:=0;
          ALPHABATICAL          CONSTANT       VARCHAR(60):='ALPHABATICAL';
          REVERSE_ALPHABATICAL       CONSTANT   VARCHAR(60):='REVERSE_ALPHABATICAL';
          NORMAL              CONSTANT             VARCHAR(60):='NORMAL';
          CRONOLOGICAL        CONSTANT              VARCHAR(60):='CRONOLOGICAL';
          REVERSE_CRONOLOGICAL        CONSTANT              VARCHAR(60):='REVERSE_CRONOLOGICAL';

--   Constant G_JTF_LINK, G_JTF_ATTRIBUTE
--        G_JTF_LINK
--        G_JTF_ATTRIBUTE

--	 These two constants define JTF_OBJECTS_TL, _B object function for the link and attribute
	  G_JTF_LINK         CONSTANT 		VARCHAR2(200) :='IBU_LINK';
          G_JTF_ATTRIBUTE    CONSTANT		VARCHAR2(200) :='IBU_ATTRIBUTE';

          DEBUG       CONSTANT                VARCHAR2(100):=FND_API.G_TRUE;
-- *****************************************************************************
-- Start of Comments
--   This procedure Add_Template Add an additional template to the CS_TP_Templates_B Table
-- The user needs to pass in a template record which holds the template attribu
--tes.  User can leave the template id and last_updated_date field  in the temp
--late record blank.  However, user needs to pass in the rest of the fields in
--the template record.  In addition, the mEndDate must be later than mStartDate
--
-- @param	P_One_Template    required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Template_ID
--   	 	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status

-- End of Comments

procedure Add_Template  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_One_Template  IN 	Template,
        X_Msg_Count	OUT NOCOPY     NUMBER,
        X_Msg_Data	OUT NOCOPY     VARCHAR2,
  	X_Return_Status	OUT NOCOPY     VARCHAR2,
	X_Template_ID	OUT NOCOPY     NUMBER);

-- *****************************************************************************
-- Start of Comments
--
-- Delete Template will delete the template with the passed in template id in the CS_TP_Templates_B and CS_TP_Templates_TL table with the passed in P_Template_ID
--
-- An exception will be raised if the template with passed in templated id cannot be found
-- @param	P_Template_ID          required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list
-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--
-- End of Comments
procedure Delete_Template (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_Template_ID 		IN NUMBER,
 	X_Msg_Count   OUT NOCOPY NUMBER,
 	X_Msg_Data		OUT NOCOPY VARCHAR2,
 	X_Return_Status		OUT NOCOPY VARCHAR2
	);
-- *****************************************************************************
-- Start of Comments
--
-- Update Template will update the template with a specific template id  in the CS_TP_Templates_B and CS_TP_Templates_TL table with the new template attributes
-- All fields inside the template are required
-- An exception is raised if template with template id cannot be found
--Same validation are performed for Update_Template as Add_Template
-- @param	P_One_Template   required
--  @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--
-- End of Comments

procedure Update_Template (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_One_Template  IN 	Template,
        X_Msg_Count	OUT NOCOPY     NUMBER,
        X_Msg_Data	OUT NOCOPY     VARCHAR2,
  	X_Return_Status	OUT NOCOPY     VARCHAR2);


-- *****************************************************************************
-- Start of Comments
-- Update_Template_Attributes will save the the template attributes, such as urgency/severity to the
-- CS_TP_Template_Attribute_Link table.
-- The Attribute record passed needs to include the Attribute Name, StartThresh
--old and EndThreshold, valid JTF_OBJECT_CODE and Other_ID which is the ID of t
--he object table.  EndThreshold needs to be greater than StartThreshold and bo
--th Thresholds need to be in the boundary of  g_attr_max_threshold and g_attr_
--min_threshold.  If attributeID is passed, the procedure assumes an update on
--the attribute record and the last updated date needs to be passed in as well.

-- @param	P_Template_ID  required
-- @param	P_Template_Attributes  required
--  @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
-- End of Comments

procedure Update_Template_Attributes  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	 P_Template_ID    IN  NUMBER,
	 P_Template_Attributes  IN     Template_Attribute_List,
	 X_Msg_Count      OUT NOCOPY NUMBER,
 	 X_Msg_Data			OUT NOCOPY VARCHAR2,
 	 X_Return_Status		OUT NOCOPY VARCHAR2
	);
-- *****************************************************************************
-- Start of Comments
--
--  Update_Template_Links  will insert and update template links to the CS_TP_TEMPLATE_LINKS  table.
--  User needs to pass in a valid template id.  For each Link record, a valid link name, JTF_OBJECT_CODE, and other_id  need to be passed.
--  If the Link ID is passed in, the procedure will update the row corresponding to the link id in the CS_TP_TEMPLATE_LINKS table
--  If the link id is not passed, the procedure will insert a new row
--  Any rows in the CS_TP_TEMPLATE_LINKS that not are in the P_Template_Links passed in are deleted.
--
-- @param	P_Template_ID  required
-- @param	P_Template_Links required
--  @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list
-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status

-- End of Comments
procedure Update_Template_Links (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	 P_Template_ID 	 	 IN NUMBER,
	  P_JTF_OBJECT_CODE	 IN VARCHAR2,
	 P_Template_Links  	 IN  Template_Link_List,
    	 X_Msg_Count		 OUT NOCOPY NUMBER,
 	 X_Msg_Data		 OUT NOCOPY VARCHAR2,
 	 X_Return_Status	 OUT NOCOPY VARCHAR2
);
-- *****************************************************************************
-- Start of Comments
--
-- Show templates takes two numbers P_Start_Temlate and P_End_Template as the start number and end number of the template, the Display Order of the templates, and a template name to search with.  It will return a table of templates.
--@param	P_Start_Template
--@param	P_End_Template
--@param	P_Display_Order
--@param	P_Template_Name
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--		X_Template_List_To_Show
--		X_Total_Templates
--       	X_Retrieved_Template_Num

-- End of Comments

procedure Show_Templates  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR2          := FND_API.G_FALSE,
	P_Template_Name 	IN VARCHAR2,
	P_Start_Template 	IN NUMBER,
	P_End_Template 		IN NUMBER,
	P_Display_Order 	IN VARCHAR2,
 	X_Msg_Count   OUT NOCOPY NUMBER,
 	X_Msg_Data		OUT NOCOPY VARCHAR2,
 	X_Return_Status		OUT NOCOPY VARCHAR2,
	X_Template_List_To_Show OUT NOCOPY Template_List,
        X_Total_Templates       OUT NOCOPY NUMBER,
        X_Retrieved_Template_Num    OUT NOCOPY NUMBER );

-- *****************************************************************************
-- Start of Comments
--
-- Show_Template returns a template record which takes a template id and returns a template record.
-- @param P_Template_ID  required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--		X_Template_To_Show
-- End of Comments

procedure Show_Template (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_Template_ID   	IN NUMBER,
   	X_Msg_Count   OUT NOCOPY NUMBER,
  	X_Msg_Data		OUT NOCOPY VARCHAR2,
  	X_Return_Status		OUT NOCOPY VARCHAR2,
	X_Template_To_Show 	OUT NOCOPY Template
        );

-- *****************************************************************************
-- Start of Comments
--
-- Show_Templates_With_Attr show the list of templates with a certain attribute id
--@param 	P_Other_ID  required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--		X_Template_List

-- End of Comments

procedure Show_Templates_With_Link (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	p_Object_Other_list	IN OBJECT_OTHER_ID_PAIRS,
  	X_Msg_Count		OUT NOCOPY NUMBER,
  	X_Msg_Data		OUT NOCOPY VARCHAR2,
 	X_Return_Status		OUT NOCOPY VARCHAR2,
	X_Template_List 	OUT NOCOPY  Template_List);

-- *****************************************************************************
-- Start of Comments
--
--	Show_Template_Attributes show a list of attributes associated with a template

--@param P_Template_ID     required
--@param P_JTF_OBJECT_CODE    required
--@param	p_api_version_number   required
--@param       p_commit
--@param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--		X_Template_Attributes

-- End of Comments

procedure Show_Template_Attributes
	(
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	P_Template_ID 			IN NUMBER,
	P_JTF_OBJECT_CODE 		IN VARCHAR2,
 	X_Msg_Count     OUT NOCOPY NUMBER,
  	X_Msg_Data      OUT NOCOPY VARCHAR2,
 	X_Return_Status			OUT NOCOPY VARCHAR2,
	X_Template_Attributes		OUT NOCOPY Template_Attribute_List );

-- *****************************************************************************
-- Start of Comments
--
--   	Show_Template_Links will return a table of of Template_Link that's associated with a template.
--@param	P_Template_ID   required
--@param	P_JTF_OBJECT_CODE  required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--       	X_Template_Links

-- End of Comments
procedure Show_Template_Links
	(
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	 P_Template_ID			IN NUMBER,
	 P_JTF_OBJECT_CODE		IN VARCHAR2,
	 X_Msg_Count     OUT NOCOPY NUMBER,
  	 X_Msg_Data			OUT NOCOPY VARCHAR2,
 	 X_Return_Status		OUT NOCOPY VARCHAR2,
	 X_Template_Links		OUT NOCOPY Template_Link_List);

-- *****************************************************************************
-- Start of Comments
--
--	Show_Link_Attribute_List returns a list of seeded links or a list of seeded attributes, depending on the P_Identify passed in.
--@param		P_Identify   required
-- @param	p_api_version_number   required
-- @param       p_commit
-- @param	p_init_msg_list

-- @return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status


-- End of Comments

procedure Show_Non_Asso_Links
	(
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	 P_Template_ID			IN NUMBER,
	 P_JTF_OBJECT_CODE		IN VARCHAR2,
	 X_Msg_Count     OUT NOCOPY NUMBER,
  	 X_Msg_Data			OUT NOCOPY VARCHAR2,
 	 X_Return_Status		OUT NOCOPY VARCHAR2,
	 X_Template_Link_List		OUT NOCOPY  Template_Link_List);


procedure Show_Link_Attribute_List (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR2          := FND_API.G_FALSE,
	P_Identify			IN VARCHAR2,
	X_Msg_Count			OUT NOCOPY NUMBER,
  	X_Msg_Data			OUT NOCOPY VARCHAR2,
 	X_Return_Status			OUT NOCOPY VARCHAR2,
	X_IDName_Pairs			OUT NOCOPY  ID_NAME_PAIRS
	);

procedure Retrieve_Constants (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR2          := FND_API.G_FALSE,
	X_Msg_Count			OUT NOCOPY NUMBER,
  	X_Msg_Data			OUT NOCOPY VARCHAR2,
 	X_Return_Status			OUT NOCOPY VARCHAR2,
        X_IDName_Pairs    OUT NOCOPY ID_NAME_PAIRS
	);

procedure Show_Default_Template  (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR2          := FND_API.G_FALSE,
	X_Msg_Count			OUT NOCOPY NUMBER,
  	X_Msg_Data			OUT NOCOPY VARCHAR2,
 	X_Return_Status			OUT NOCOPY VARCHAR2,
	X_Default_Template		OUT NOCOPY Template
	);
procedure Show_Error_Message (
	p_api_version_number 	IN   NUMBER,
	X_Out_Message	OUT NOCOPY	VARCHAR2
);

/*
procedure Check_Attribute_Error (P_Template_Attributes IN Template_Attribute_List,
				 X_Return_Status OUT NOCOPY VARCHAR2);
*/


/*
  this procedure is used to copy the template
*/
procedure Copy_Template(
   p_api_version_number IN NUMBER,
   B_Template_ID        IN NUMBER,
   X_Template_Name      IN VARCHAR2,
   p_init_msg_list      IN VARCHAR2    := FND_API.G_FALSE,
   p_commit             IN VARCHAR     := FND_API.G_FALSE,
   X_Msg_Count          OUT NOCOPY NUMBER,
   X_Msg_Data           OUT NOCOPY VARCHAR2,
   X_Return_Status     OUT NOCOPY VARCHAR2,
   X_Template_ID        OUT NOCOPY NUMBER);

/*
  This procedure is used to test if one template is obsolete or not
*/

 procedure Test_Template_Obsolete(
   p_api_version_number IN NUMBER,
   B_Template_ID        IN NUMBER,
   p_init_msg_list      IN VARCHAR2    := FND_API.G_FALSE,
   p_commit             IN VARCHAR     := FND_API.G_FALSE,
   X_Msg_Count          OUT NOCOPY NUMBER,
   X_Msg_Data           OUT NOCOPY VARCHAR2,
   X_Return_Status      OUT NOCOPY VARCHAR2,
   B_Obsolete           OUT NOCOPY VARCHAR2);


-- *****************************************************************************
-- Start of Comments
--
-- Show_Template_Links_Two will return a table of of Template_Link that's associated with a template by the given start link number and end link number.
--@param	P_Template_ID   required
--@param	P_JTF_OBJECT_CODE  required
--@param	p_api_version_number   required
--@param        p_start_link
--@param        p_end_link
--@param        p_commit
--@param	p_init_msg_list

--@return	X_Msg_Count
--              X_Msg_Data
--  	        X_Return_Status
--       	X_Template_Links
--              X_Total_Link_Number
--              X_Retrieved_Link_Number

-- End of Comments
procedure Show_Template_Links_Two
	(
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
        P_Template_ID		 IN NUMBER,
	P_JTF_OBJECT_CODE	 IN VARCHAR2,
        p_start_link             IN NUMBER,
        p_end_link               IN NUMBER,
	X_Msg_Count              OUT NOCOPY NUMBER,
  	X_Msg_Data               OUT NOCOPY VARCHAR2,
 	X_Return_Status	         OUT NOCOPY VARCHAR2,
	X_Template_Links         OUT NOCOPY Template_Link_List,
        X_Total_Link_Number      OUT NOCOPY NUMBER,
        X_Retrieved_Link_Number  OUT NOCOPY NUMBER );


-- **************************************************************************
-- query the availabe product link by the start link number and
-- end link number

procedure Show_Non_Asso_Links_Two
	(
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
        P_Template_ID		 IN NUMBER,
	P_JTF_OBJECT_CODE        IN VARCHAR2,
        p_start_link             IN NUMBER,
        p_end_link               IN NUMBER,
        p_link_name              IN VARCHAR2,
	X_Msg_Count              OUT NOCOPY NUMBER,
  	X_Msg_Data	         OUT NOCOPY VARCHAR2,
 	X_Return_Status		 OUT NOCOPY VARCHAR2,
	X_Template_Link_List	 OUT NOCOPY  Template_Link_List,
        X_Total_Link_Number      OUT NOCOPY NUMBER,
        X_Retrieved_Link_Number  OUT NOCOPY NUMBER );


-- ***********************************************************************
-- Delete the template links

PROCEDURE Delete_Template_Links (
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR   := FND_API.G_FALSE,
    p_template_id            IN  NUMBER,
    p_jtf_object_code        IN  VARCHAR2,
    p_template_links         IN  Template_Link_List,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2);


-- ***********************************************************************
-- Add the template links

PROCEDURE Add_Template_Links (
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR   := FND_API.G_FALSE,
    p_template_id            IN  NUMBER,
    p_jtf_object_code        IN  VARCHAR2,
    p_template_links         IN  Template_Link_List,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2);



end CS_TP_TEMPLATES_PVT;

 

/
