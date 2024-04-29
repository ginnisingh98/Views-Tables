--------------------------------------------------------
--  DDL for Package Body OE_ATCHMT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ATCHMT_UTIL" as
/* $Header: OEXUATTB.pls 120.0 2005/06/01 23:10:08 appldev noship $ */

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Atchmt_UTIL';

G_DEFAULT_DOC_CATEGORY_ID	CONSTANT NUMBER := 1000035;


-- LOCAL PROCEDURES/FUNCTIONS

FUNCTION Get_Document_Entity(p_entity_code IN VARCHAR2)
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
		RETURN OE_Atchmt_UTIL.G_DOC_ENTITY_ORDER_HEADER;
	ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN
		RETURN OE_Atchmt_UTIL.G_DOC_ENTITY_ORDER_LINE;
	END IF;

END Get_Document_Entity;


-- PUBLIC PROCEDURES/FUNCTIONS

---------------------------------------------------------
PROCEDURE Apply_Automatic_Attachments
(
 p_init_msg_list				in   varchar2 default fnd_api.g_false,
 p_entity_code                     in   varchar2,
 p_entity_id                       in   number,
 p_is_user_action				in   varchar2 default 'Y',
x_attachment_count out nocopy number,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

)
---------------------------------------------------------
IS
l_entity_name					VARCHAR2(30);
l_line_number					NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize message list.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;


	-- is_user_action is 'N' therefore check the profile option value
	-- find out if attachments should be applied automatically.
     IF p_is_user_action = 'N'
      AND NVL(FND_PROFILE.VALUE('OE_APPLY_AUTOMATIC_ATCHMT'),'Y') = 'N' THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'PROFILE OM: APPLY AUTOMATIC ATTACHMENTS IS NO' , 1 ) ;
          END IF;
               RETURN;
     END IF;

	l_entity_name := Get_Document_Entity(p_entity_code);

	IF l_entity_name IS NOT NULL THEN

		OE_FND_Attachments_PVT.Add_Attachments_Automatic
			(p_api_version		=> 1.0
			,p_entity_name		=> l_entity_name
			,p_pk1_value		=> to_char(p_entity_id)
			,x_attachment_count		=> x_attachment_count
			,x_return_status		=> x_return_status
			,x_msg_count			=> x_msg_count
			,x_msg_data			=> x_msg_data
			);

	END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

	-- Add information messages to indicate if automatic attachments
	-- were applied or not if it is a user action
	IF p_is_user_action = 'Y' THEN

       IF x_attachment_count > 0 THEN

          IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
               FND_MESSAGE.SET_NAME('ONT','OE_ORDER_ATTACHMENTS_APPLIED');
               FND_MESSAGE.SET_TOKEN('ORDER_COUNT',to_char(x_attachment_count));
               OE_MSG_PUB.ADD;
          ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN
               SELECT line_number
               INTO l_line_number
               FROM oe_order_lines
               WHERE line_id = p_entity_id;
               FND_MESSAGE.SET_NAME('ONT','OE_LINE_ATTACHMENTS_APPLIED');
               FND_MESSAGE.SET_TOKEN('LINE_COUNT',to_char(x_attachment_count));
               FND_MESSAGE.SET_TOKEN('LINE_NUMBER',to_char(l_line_number));
               OE_MSG_PUB.ADD;
          END IF;

       ELSIF x_attachment_count = 0 THEN

          IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
               FND_MESSAGE.SET_NAME('ONT','OE_NO_ORDER_ATCHMT_APPLIED');
               OE_MSG_PUB.ADD;
          ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN
               FND_MESSAGE.SET_NAME('ONT','OE_NO_LINE_ATCHMT_APPLIED');
               OE_MSG_PUB.ADD;
          END IF;

	  END IF;

     END IF;

	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	   OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_Automatic_Attachments'
			);
        END IF;
	   OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
END Apply_Automatic_Attachments;


------------------------------------------
PROCEDURE Delete_Attachments
(
 p_entity_code                     in   varchar2,
 p_entity_id                       in   number,
x_return_status out nocopy varchar2

)
------------------------------------------
IS
l_entity_name					VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_entity_name := Get_Document_Entity(p_entity_code);

	IF l_entity_name IS NOT NULL THEN

		FND_ATTACHED_DOCUMENTS2_PKG.Delete_Attachments
			(x_entity_name		=> l_entity_name
			,x_pk1_value		=> to_char(p_entity_id)
			,x_automatically_added_flag	=> null
                -- Bug 3280106
                -- Delete all FND one-time documents specific to this entity
                        ,x_delete_document_flag => 'Y'
			);

	END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Attachments'
			);
        END IF;
END Delete_Attachments;


-----------------------------------------------------------------
PROCEDURE Copy_Attachments
(
 p_entity_code			in   varchar2,
 p_from_entity_id		in   number,
 p_to_entity_id			in   number,
 p_manual_attachments_only			in   varchar2 default 'N',
x_return_status out nocopy varchar2

)
-----------------------------------------------------------------
IS
l_entity_name						VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_entity_name := Get_Document_Entity(p_entity_code);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTITY NAME :'||L_ENTITY_NAME ) ;
	END IF;

	IF l_entity_name IS NOT NULL THEN

	  IF p_manual_attachments_only = 'Y' THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'CPY MANUAL ATCHMT' , 1 ) ;
		END IF;

		FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments
			( x_from_entity_name		=> l_entity_name
			, x_from_pk1_value			=> to_char(p_from_entity_id)
			, x_to_entity_name			=> l_entity_name
			, x_to_pk1_value			=> to_char(p_to_entity_id)
			, x_automatically_added_flag  => 'N'
			);
	  ELSE

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'CPY ALL ATCHMT' , 1 ) ;
		END IF;

		FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments
			( x_from_entity_name		=> l_entity_name
			, x_from_pk1_value			=> to_char(p_from_entity_id)
			, x_to_entity_name			=> l_entity_name
			, x_to_pk1_value			=> to_char(p_to_entity_id)
			, x_automatically_added_flag  => null
			);

	  END IF;

	END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Copy_Attachments'
			);
        END IF;
END Copy_Attachments;


-------------------------------------
PROCEDURE Add_Attachment
(
 p_api_version		in   number,
 p_entity_code  		in   varchar2,
 p_entity_id	  	in   number,
 p_document_desc    	in   varchar2 default null,
 p_document_text  	in   varchar2 default null,
 p_category_id  		in   number   default null,
 p_document_id   		in   number default null,
x_attachment_id out nocopy number,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

)
IS
   l_return_status 	varchar2(1);
   l_msg_count		number;
   l_msg_data		varchar2(80);
   l_entity_name  	varchar2(30);
   l_media_id		number;
   l_category_id   	number   := p_category_id;
   l_document_id		number := p_document_id;
   l_seq_num			number;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

	l_entity_name := Get_Document_Entity(p_entity_code);

    if (l_category_id IS NULL or l_category_id =  fnd_api.G_MISS_NUM ) then
        l_category_id := G_DEFAULT_DOC_CATEGORY_ID;
    end if;


   -- document ID not passed therfore
   -- create the short text document and attach to the entity
   if (l_document_id = fnd_api.G_MISS_NUM OR l_document_id IS NULL) then

      select (nvl(max(seq_num),0) + 10)
      into l_seq_num
      from fnd_attached_documents
      where entity_name = l_entity_name
        and pk1_value = to_char(p_entity_id);

	FND_WEBATTCH.Add_Attachment
		(seq_num				=> l_seq_num
		,category_id			=> l_category_id
		,document_description	=> p_document_desc
		,datatype_id			=> G_DATATYPE_SHORT_TEXT
		,text				=> p_document_text
		,file_name			=> null
		,url					=> null
		,function_name			=> null
		,entity_name			=> l_entity_name
		,pk1_value			=> to_char(p_entity_id)
		,pk2_value			=> null
		,pk3_value			=> null
		,pk4_value			=> null
		,pk5_value			=> null
		,media_id				=> l_media_id
		,user_id				=> FND_GLOBAL.USER_ID
		);

   -- document id passed, just attach the document
   else

   	-- attach the document to the entity
   	Oe_Fnd_Attachments_PVT.Add_Attachment(
			p_api_version			=> 1.0,
		     p_entity_name			=> l_entity_name,
			p_pk1_value			=> to_char(p_entity_id),
			p_automatic_flag		=> 'N',
			p_document_id 			=> l_document_id,
			x_attachment_id 		=> x_attachment_id,
			x_return_status		=> x_return_status,
			x_msg_count			=> x_msg_count,
			x_msg_data			=> x_msg_data
               );

   end if;

END Add_Attachment;
-----------------------------------------------------------------------------


END OE_Atchmt_UTIL;

/
