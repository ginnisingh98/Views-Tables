--------------------------------------------------------
--  DDL for Package Body WIP_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_GLOBALS" AS
/* $Header: WIPSGLBB.pls 115.11 2002/12/01 16:16:23 rmahidha ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Globals';

--  Procedure Get_Entities_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  entity constants.
--
--  DO NOT REMOVE

PROCEDURE Get_Entities_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_entity_tbl.DELETE;

--  START GEN entities
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'ALL';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'WIP_ENTITIES';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'FLOWSCHEDULE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'DISCRETEJOB';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'REPSCHEDULE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'WIPTRANSACTION';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'COMPONENTISSUE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'OSP';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'SHOPFLOORMOVE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'RESOURCE';
--  END GEN entities

END Get_Entities_Tbl;

--  Initialize control record.

FUNCTION Init_Control_Rec
(   p_action                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
)RETURN Control_Rec_Type
IS
l_control_rec                 Control_Rec_Type;
BEGIN

    IF p_control_rec.controlled_operation THEN

        RETURN p_control_rec;

    ELSIF p_action = G_OPR_NONE OR p_action IS NULL THEN

        l_control_rec.default_attributes:=  FALSE;
        l_control_rec.change_attributes :=  FALSE;
        l_control_rec.validate_entity	:=  FALSE;
        l_control_rec.write_to_DB	:=  FALSE;
        l_control_rec.process		:=  p_control_rec.process;
        l_control_rec.process_entity	:=  p_control_rec.process_entity;
        l_control_rec.request_category	:=  p_control_rec.request_category;
        l_control_rec.request_name	:=  p_control_rec.request_name;
        l_control_rec.clear_api_cache	:=  p_control_rec.clear_api_cache;
        l_control_rec.clear_api_requests:=  p_control_rec.clear_api_requests;

    ELSIF p_action = G_OPR_CREATE THEN

        l_control_rec.default_attributes:=   TRUE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity  :=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_action = G_OPR_UPDATE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   TRUE;
        l_control_rec.validate_entity	:=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_action = G_OPR_DELETE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity	  :=   TRUE;
        l_control_rec.write_to_DB	  :=   TRUE;
        l_control_rec.process		  :=   TRUE;
        l_control_rec.process_entity	  :=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	  :=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSE

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Init_Control_Rec'
            ,   'Invalid action'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    RETURN l_control_rec;

END Init_Control_Rec;

--  Function Equal
--  Number comparison.

FUNCTION Equal
(   p_attribute1                    IN  NUMBER
,   p_attribute2                    IN  NUMBER
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;

--  Varchar2 comparison.

FUNCTION Equal
(   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;

--  Date comparison.

FUNCTION Equal
(   p_attribute1                    IN  DATE
,   p_attribute2                    IN  DATE
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;


PROCEDURE Add_Error_Message(p_product        VARCHAR2   := 'WIP',
			    p_message_name   VARCHAR2,
			    p_token1_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token1_value   VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token2_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token2_value   VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token3_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token3_value   VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token4_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token4_value   VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token5_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token5_value   VARCHAR2   := FND_API.G_MISS_CHAR)

IS
BEGIN

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

      FND_MESSAGE.SET_NAME(p_product,p_message_name);

      IF p_token1_name <> FND_API.G_MISS_CHAR
	AND p_token1_value <> FND_API.G_MISS_CHAR THEN
	 FND_MESSAGE.SET_TOKEN(p_token1_name,p_token1_value);
      END IF;
      IF p_token2_name <> FND_API.G_MISS_CHAR
	AND p_token2_value <> FND_API.G_MISS_CHAR THEN
	 FND_MESSAGE.SET_TOKEN(p_token2_name,p_token2_value);
      END IF;
      IF p_token3_name <> FND_API.G_MISS_CHAR
	AND p_token3_value <> FND_API.G_MISS_CHAR THEN
	 FND_MESSAGE.SET_TOKEN(p_token3_name,p_token3_value);
      END IF;
      IF p_token4_name <> FND_API.G_MISS_CHAR
	AND p_token4_value <> FND_API.G_MISS_CHAR THEN
	 FND_MESSAGE.SET_TOKEN(p_token4_name,p_token4_value);
      END IF;
      IF p_token5_name <> FND_API.G_MISS_CHAR
	AND p_token5_value <> FND_API.G_MISS_CHAR THEN
	 FND_MESSAGE.SET_TOKEN(p_token5_name,p_token5_value);
      END IF;

      FND_MSG_PUB.Add;

   END IF;

END Add_Error_Message;


-- Displays 'p_msg_count' messages to the screen (dbms) then clears
-- the message stack.

Procedure Display_all_msgs ( p_msg_count  IN NUMBER) IS
	i		NUMBER;
	cnt		NUMBER;
	msg_data	VARCHAR2(240);
BEGIN
	fnd_msg_pub.reset;
        for i in 1..p_msg_count loop

            fnd_msg_pub.get (p_encoded    => FND_API.G_FALSE,
                             p_data => msg_data,
                             p_msg_index_out => cnt);

--            dbms_output.put_line('error # ' || cnt || ': ' || msg_data);
         end loop ;
	 fnd_msg_pub.initialize;
END Display_all_msgs;



PROCEDURE  Get_Locator_Control
  ( p_org_id 	        IN   NUMBER,
    p_subinventory_code IN   VARCHAR2,
    p_primary_item_id   IN   NUMBER,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    x_locator_control   OUT NOCOPY  NUMBER
    ) IS
l_org_control     NUMBER;
l_sub_control     NUMBER;
l_item_control    NUMBER;
x_level           NUMBER;

CURSOR org_loc_control  IS
SELECT  STOCK_LOCATOR_CONTROL_CODE
FROM    MTL_PARAMETERS
WHERE   ORGANIZATION_ID = p_org_id;

CURSOR item_loc_control IS
SELECT  Location_Control_Code
FROM  mtl_system_items
WHERE  inventory_item_id = p_primary_item_id
AND    ORGANIZATION_ID = p_org_id;

CURSOR sub_loc_control IS
SELECT  LOCATOR_TYPE
FROM  mtl_secondary_inventories
WHERE  ORGANIZATION_ID = p_org_id
AND    SECONDARY_INVENTORY_NAME = p_subinventory_code;

BEGIN
   OPEN org_loc_control;
   FETCH org_loc_control INTO l_org_control;
   CLOSE org_loc_control;

   OPEN item_loc_control;
   FETCH item_loc_control INTO l_item_control;
   CLOSE item_loc_control;

   OPEN sub_loc_control;
   FETCH sub_loc_control INTO l_sub_control;
   CLOSE sub_loc_control;

   MTL_INV_VALIDATE_GRP.LOCATOR_CONTROL(
					p_api_version => 0.9,
					x_return_status => x_return_status,
					x_msg_count => x_msg_count,
					x_msg_data => x_msg_data,
					p_org_control =>l_org_control,
					p_sub_control => l_sub_control,
					p_item_control => l_item_control,
					x_locator_control => x_locator_control,
					x_level => x_level);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       Add_Error_Message(p_message_name => 'UNEXPECTED_ERROR',
			 p_token1_name  => 'TEXT',
			 p_token1_value => Sqlerrm);


END  Get_Locator_Control;


function USE_PHANTOM_ROUTINGS(p_org_id in number) return number is
x_use_phantom_routings number;
begin

   Select USE_PHANTOM_ROUTINGS
   INTO   x_use_phantom_routings
   FROM   BOM_PARAMETERS
   WHERE  organization_Id = p_org_id;

   if (x_use_phantom_routings = 1 ) then
        return 1 ;
   else
        return 2 ;
   end if ;

   exception
        when no_data_found then
                return -2 ;
        when others then
                return -1 ;

end USE_PHANTOM_ROUTINGS;

function INHERIT_PHANTOM_OP_SEQ(p_org_id in number) return number is
x_inherit_phantom_op_seq number;
begin

   Select INHERIT_PHANTOM_OP_SEQ
   INTO   x_inherit_phantom_op_seq
   FROM   BOM_PARAMETERS
   WHERE  organization_Id = p_org_id;

   if (x_inherit_phantom_op_seq = 1 ) then
        return 1 ;
   else
        return 2 ;
   end if ;

   exception
        when no_data_found then
                return -2 ;
        when others then
                return -1 ;

end INHERIT_PHANTOM_OP_SEQ;



END WIP_Globals;

/
