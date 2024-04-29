--------------------------------------------------------
--  DDL for Package Body OE_MSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_MSG_PUB" AS
/* $Header: OEXUMSGB.pls 120.13.12010000.4 2009/05/28 05:57:25 sgoli ship $ */

--  Constants used as tokens for unexpected error messages.

    G_PKG_NAME	  CONSTANT    VARCHAR2(15):=  'OE_MSG_PUB';
    G_HEADER_ID               NUMBER;
    G_ORDER_NUMBER            NUMBER;

--  Procedure	Initialize
--
--  Usage	Used by API callers and developers to intialize the
--		global message table.
--  Desc	Clears the G_msg_tbl and resets all its global
--		variables. Except for the message level threshold.
--

PROCEDURE Initialize
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   --Bug 8514085 Starts
   IF G_msg_timer_created
   THEN
      IF G_msg_tbl.COUNT > 0 THEN --Bug 8547831
         Add_Msgs_To_CopyMsgTbl;
         G_msg_init_with_timer := TRUE;
      END IF;
   END IF;
   --Bug 8514085 Ends
FND_MSG_PUB.Initialize;

G_msg_tbl.DELETE;
G_msg_count := 0;
G_msg_index := 0;
G_msg_context_tbl.DELETE;
G_msg_context_count := 0;
G_Msg_Context_index := 0;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING OE_MSG_PUB.INITIALIZE' , 1 ) ;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in procedure Initialize ' || sqlerrm);
   END IF;
END;

PROCEDURE Set_Process_Activity(
     p_process_activity IN NUMBER DEFAULT NULL)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    G_process_activity := p_process_activity;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in procedure Set_Process_Activity ' || sqlerrm);
   END IF;
END Set_Process_Activity;

PROCEDURE Set_Msg_Context (
     p_entity_code       	    IN	VARCHAR2	DEFAULT NULL
    ,p_entity_ref         	    IN	VARCHAR2	DEFAULT NULL
    ,p_entity_id         	    IN	NUMBER		DEFAULT NULL
    ,p_header_id         	    IN	NUMBER		DEFAULT NULL
    ,p_line_id           	    IN	NUMBER		DEFAULT NULL
    ,p_order_source_id              IN  NUMBER          DEFAULT NULL
    ,p_orig_sys_document_ref	    IN	VARCHAR2	DEFAULT NULL
    ,p_orig_sys_document_line_ref   IN	VARCHAR2	DEFAULT NULL
    ,p_orig_sys_shipment_ref   	    IN	VARCHAR2	DEFAULT NULL
    ,p_change_sequence   	    IN	VARCHAR2	DEFAULT NULL
    ,p_source_document_type_id      IN  NUMBER          DEFAULT NULL
    ,p_source_document_id	    IN  NUMBER		DEFAULT NULL
    ,p_source_document_line_id	    IN  NUMBER		DEFAULT NULL
    ,p_attribute_code       	    IN  VARCHAR2	DEFAULT NULL
    ,p_constraint_id		    IN  NUMBER		DEFAULT NULL
--  ,p_process_activity		    IN  NUMBER		DEFAULT NULL
  )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    --  Increment message context count
     G_msg_context_count := G_msg_context_count + 1;

     /* IF statements added for 2244395 */

    --  Write message context.

     IF p_entity_code = FND_API.G_MISS_CHAR THEN
       G_msg_context_tbl(G_msg_context_count).ENTITY_CODE :=  NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).ENTITY_CODE :=  p_entity_code;
     END IF;

     IF p_entity_id = FND_API.G_MISS_NUM THEN
       G_msg_context_tbl(G_msg_context_count).ENTITY_ID :=  NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).ENTITY_ID :=  p_entity_id;
     END IF;

     IF p_entity_ref = FND_API.G_MISS_CHAR THEN
       G_msg_context_tbl(G_msg_context_count).ENTITY_REF :=  NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).ENTITY_REF :=  p_entity_ref;
     END IF;

     IF p_header_id = FND_API.G_MISS_NUM THEN
       G_msg_context_tbl(G_msg_context_count).HEADER_ID :=  NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).HEADER_ID :=  p_header_id;
     END IF;

     IF p_line_id = FND_API.G_MISS_NUM THEN
       G_msg_context_tbl(G_msg_context_count).LINE_ID :=  NULL;
     ELSE

       IF p_line_id is not null
       AND (p_header_id is null
       OR  p_header_id = FND_API.G_MISS_NUM) THEN


        BEGIN
         SELECT header_id
         INTO   G_msg_context_tbl(G_msg_context_count).header_id
         FROM   oe_order_lines_all
         WHERE  line_id = p_line_id;


        EXCEPTION
         WHEN OTHERS THEN
            NULL;
        END;
       END IF;
       G_msg_context_tbl(G_msg_context_count).LINE_ID :=  p_line_id;
     END IF;

     IF p_order_source_id = FND_API.G_MISS_NUM THEN
       G_msg_context_tbl(G_msg_context_count).ORDER_SOURCE_ID := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).ORDER_SOURCE_ID := p_order_source_id;
     END IF;

     IF p_orig_sys_document_ref = FND_API.G_MISS_CHAR THEN
       G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF :=  NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF :=  p_orig_sys_document_ref;
     END IF;

     IF p_orig_sys_document_line_ref = FND_API.G_MISS_CHAR THEN
       G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF := p_orig_sys_document_line_ref;
     END IF;

     IF p_orig_sys_shipment_ref = FND_API.G_MISS_CHAR THEN
       G_msg_context_tbl(G_msg_context_count).ORIG_SYS_SHIPMENT_REF := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).ORIG_SYS_SHIPMENT_REF := p_orig_sys_shipment_ref;
     END IF;

     IF p_change_sequence = FND_API.G_MISS_CHAR THEN
       G_msg_context_tbl(G_msg_context_count).CHANGE_SEQUENCE := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).CHANGE_SEQUENCE := p_change_sequence;
     END IF;

     IF p_source_document_type_id = FND_API.G_MISS_NUM THEN
       G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_TYPE_ID := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_TYPE_ID := p_source_document_type_id;
     END IF;

     IF p_source_document_id = FND_API.G_MISS_NUM THEN
       G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID := p_source_document_id;
     END IF;

     IF p_source_document_line_id = FND_API.G_MISS_NUM THEN
       G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID := p_source_document_line_id;
     END IF;

     IF p_attribute_code = FND_API.G_MISS_CHAR THEN
       G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE := p_attribute_code;
     END IF;

     IF p_constraint_id = FND_API.G_MISS_NUM THEN
       G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID := NULL;
     ELSE
       G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID := p_constraint_id;
     END IF;

 --    G_msg_context_tbl(G_msg_context_count).PROCESS_ACTIVITY := p_process_activity;
     G_msg_context_tbl(G_msg_context_count).PROCESS_ACTIVITY := G_process_activity;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in procedure Set_Msg_Context ' || sqlerrm);
   END IF;
END;

PROCEDURE Update_Msg_Context (
     p_entity_code                    IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_entity_id                      IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_header_id                      IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_line_id                        IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_order_source_id                IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_orig_sys_document_ref          IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_orig_sys_document_line_ref     IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_orig_sys_shipment_ref          IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_change_sequence                IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_source_document_type_id        IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_source_document_id             IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_source_document_line_id        IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_attribute_code                 IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_constraint_id                  IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
--  ,p_process_activity               IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
  ) IS
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin

--   if G_msg_context_tbl(G_msg_context_count).ENTITY_CODE = p_entity_code then
     if p_entity_id <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).ENTITY_ID := p_entity_id;
     end if;
     if p_header_id <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).HEADER_ID := p_header_id;
     end if;
     if p_line_id <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).LINE_ID := p_line_id;
     end if;
     if p_order_source_id <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).ORDER_SOURCE_ID := p_order_source_id;
     end if;
     if p_orig_sys_document_ref <> FND_API.G_MISS_CHAR then
        G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF :=  p_orig_sys_document_ref;
     end if;
     if p_orig_sys_document_line_ref <> FND_API.G_MISS_CHAR then
        G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF := p_orig_sys_document_line_ref;
     end if;
     if p_orig_sys_shipment_ref <> FND_API.G_MISS_CHAR then
        G_msg_context_tbl(G_msg_context_count).ORIG_SYS_SHIPMENT_REF := p_orig_sys_shipment_ref;
     end if;
     if p_change_sequence <> FND_API.G_MISS_CHAR then
        G_msg_context_tbl(G_msg_context_count).CHANGE_SEQUENCE := p_change_sequence;
     end if;
     if p_source_document_type_id <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_TYPE_ID := p_source_document_type_id;
     end if;
     if p_source_document_id <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID := p_source_document_id;
     end if;
     if p_source_document_line_id <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID := p_source_document_line_id;
     end if;
     if p_attribute_code <> FND_API.G_MISS_CHAR then
        G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE := p_attribute_code;
     end if;
     if p_constraint_id <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID := p_constraint_id;
     end if;
/*     if p_process_activity <> FND_API.G_MISS_NUM then
        G_msg_context_tbl(G_msg_context_count).PROCESS_ACTIVITY := p_process_activity;
     end if;*/
/*
     G_msg_context_tbl(G_msg_context_count).ENTITY_ID :=  p_entity_id;
     G_msg_context_tbl(G_msg_context_count).HEADER_ID :=  p_header_id;
     G_msg_context_tbl(G_msg_context_count).LINE_ID :=  p_line_Id;
     G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF :=  p_orig_sys_document_ref;
     G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF := p_orig_sys_document_line_ref;
     G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID := p_source_document_id;
     G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID := p_source_document_line_id;
     G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE := p_attribute_code;
     G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID := p_constraint_id;
*/
--   end if;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in procedure Update_Msg_Context ' || sqlerrm);
   END IF;
End Update_Msg_Context;

PROCEDURE Reset_Msg_Context (p_entity_code  IN VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  if G_msg_context_count > 0 then
    if G_msg_context_tbl.EXISTS(G_msg_context_count) AND
       G_msg_context_tbl(G_msg_context_count).ENTITY_CODE = p_entity_code then
	  G_msg_context_tbl.delete(G_msg_context_count) ;
          G_msg_context_count  := G_msg_context_count - 1;
    end if;
  end if;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in procedure Reset_Msg_Context ' || sqlerrm);
   END IF;
END Reset_Msg_Context;



--  FUNCTION	Count_Msg
--
--  Usage	Used by API callers and developers to find the count
--		of messages in the  message list.
--  Desc	Returns the value of G_msg_count
--
--  Parameters	None
--
--  Return	NUMBER

FUNCTION    Count_Msg 	RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN G_msg_Count;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Function Count_msg ' || sqlerrm);
   END IF;
END Count_Msg;

--  PROCEDURE	Count_And_Get
--

PROCEDURE    Count_And_Get
(   p_encoded		    IN	VARCHAR2    := FND_API.G_TRUE	    ,
p_count OUT NOCOPY NUMBER ,

p_data OUT NOCOPY VARCHAR2

)
IS
l_msg_count	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_msg_count :=  Count_Msg;

    IF l_msg_count = 1 THEN

	p_data := Get ( p_msg_index =>  G_FIRST	    ,
			p_encoded   =>	p_encoded   );

	Reset;

    END IF;

    p_count := l_msg_count ;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LEAVING OE_MSG_PUB.COUNT_AND_GET '|| L_MSG_COUNT , 3 ) ;
    END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Function Count_And_Get ' || sqlerrm);
   END IF;
END Count_And_Get;

--  PROCEDURE 	Add
--
--  Usage	Used to add messages to the global message table.
--
--  Desc	Reads a message off the message dictionary stack and
--  	    	writes it in an encoded format to the global PL/SQL
--		message table.
--  	    	The message is appended at the bottom of the message
--    	    	table.
--

PROCEDURE Add(p_context_flag IN VARCHAR2 DEFAULT 'Y')
IS
l_type         VARCHAR2(30);
l_app_id       VARCHAR2(30);
l_message_name VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   --   Increment message count
   G_msg_count := G_msg_count + 1;

   --   Write message.
   G_msg_tbl(G_msg_count).Message := FND_MESSAGE.GET_ENCODED;

   IF p_context_flag = 'Y' AND G_msg_context_count <> 0 then

      BEGIN

         fnd_message.parse_encoded(G_msg_tbl(G_msg_count).Message,
                                   l_app_id,
                                   l_message_name);


         Select type
         Into   l_type
         from   fnd_new_messages a,
                   fnd_application  b
         where a.application_id = b.application_id
         and   a.language_code = USERENV('LANG')
         and   a.message_name = l_message_name
         and   b.application_short_name = l_app_id;

      EXCEPTION

         WHEN OTHERS THEN

            l_type := 'ERROR';

      END;

      G_msg_tbl(G_msg_count).ENTITY_CODE := G_msg_context_tbl(G_msg_context_count).ENTITY_CODE;
      G_msg_tbl(G_msg_count).ENTITY_ID   := G_msg_context_tbl(G_msg_context_count).ENTITY_ID;
      G_msg_tbl(G_msg_count).HEADER_ID   := G_msg_context_tbl(G_msg_context_count).HEADER_ID;
      G_msg_tbl(G_msg_count).LINE_ID     := G_msg_context_tbl(G_msg_context_count).LINE_ID;
      G_msg_tbl(G_msg_count).ORDER_SOURCE_ID     := G_msg_context_tbl(G_msg_context_count).ORDER_SOURCE_ID;
      G_msg_tbl(G_msg_count).ORIG_SYS_DOCUMENT_REF := G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF;
      G_msg_tbl(G_msg_count).ORIG_SYS_DOCUMENT_LINE_REF := G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_TYPE_ID := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_TYPE_ID;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_ID := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_LINE_ID := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID;
      G_msg_tbl(G_msg_count).ATTRIBUTE_CODE := G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE;
      G_msg_tbl(G_msg_count).CONSTRAINT_ID := G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID;
      G_msg_tbl(G_msg_count).PROCESS_ACTIVITY := G_msg_context_tbl(G_msg_context_count).PROCESS_ACTIVITY;
      G_msg_tbl(G_msg_count).TYPE := l_type;
      G_msg_tbl(G_msg_count).ORG_ID := MO_GLOBAL.Get_Current_Org_Id;

   ELSE
      G_msg_tbl(G_msg_count).ENTITY_CODE := NULL;
      G_msg_tbl(G_msg_count).ENTITY_ID  := NULL;
      G_msg_tbl(G_msg_count).HEADER_ID  := NULL;
      G_msg_tbl(G_msg_count).LINE_ID    := NULL;
      G_msg_tbl(G_msg_count).ORDER_SOURCE_ID := NULL;
      G_msg_tbl(G_msg_count).ORIG_SYS_DOCUMENT_REF := NULL;
      G_msg_tbl(G_msg_count).ORIG_SYS_DOCUMENT_LINE_REF := NULL;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_TYPE_ID := NULL;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_ID := NULL;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_LINE_ID := NULL;
      G_msg_tbl(G_msg_count).ATTRIBUTE_CODE := NULL;
      G_msg_tbl(G_msg_count).CONSTRAINT_ID := NULL;
      G_msg_tbl(G_msg_count).PROCESS_ACTIVITY := NULL;
      G_msg_tbl(G_msg_count).TYPE := NULL;
      G_msg_tbl(G_msg_count).ORG_ID := NULL;
   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING OE_MSG_PUB.ADD' , 3 ) ;
   END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in  Procedure Add  ' || sqlerrm);
   END IF;
END Add;

--  PROCEDURE 	Add_text
--
--  Usage	Used by Devlopers to add messages to Global stack from FND
--              stack .
--
--  Desc	Accepts the  message as input and writes to global_PL/SQL
--              message table.
--  	    	The message is appended at the bottom of the message
--    	    	table.
--

PROCEDURE Add_Text(p_message_text IN VARCHAR2
              ,p_type IN VARCHAR2 DEFAULT 'ERROR'
              ,p_context_flag IN VARCHAR2 DEFAULT 'Y')
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --	Increment message count
    G_msg_count := G_msg_count + 1;

    --	Write message.
    G_msg_tbl(G_msg_count).Message_text := p_message_text;

    IF p_context_flag = 'Y' AND G_msg_context_count <> 0 then
      G_msg_tbl(G_msg_count).ENTITY_CODE := G_msg_context_tbl(G_msg_context_count).ENTITY_CODE;
      G_msg_tbl(G_msg_count).ENTITY_ID 	 := G_msg_context_tbl(G_msg_context_count).ENTITY_ID;
      G_msg_tbl(G_msg_count).HEADER_ID	 := G_msg_context_tbl(G_msg_context_count).HEADER_ID;
      G_msg_tbl(G_msg_count).LINE_ID 	 := G_msg_context_tbl(G_msg_context_count).LINE_ID;
      G_msg_tbl(G_msg_count).ORDER_SOURCE_ID 	 := G_msg_context_tbl(G_msg_context_count).ORDER_SOURCE_ID;
      G_msg_tbl(G_msg_count).ORIG_SYS_DOCUMENT_REF := G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF;
      G_msg_tbl(G_msg_count).ORIG_SYS_DOCUMENT_LINE_REF := G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_TYPE_ID := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_TYPE_ID;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_ID := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_LINE_ID := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID;
      G_msg_tbl(G_msg_count).ATTRIBUTE_CODE := G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE;
      G_msg_tbl(G_msg_count).CONSTRAINT_ID := G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID;
      G_msg_tbl(G_msg_count).PROCESS_ACTIVITY := G_msg_context_tbl(G_msg_context_count).PROCESS_ACTIVITY;
      G_msg_tbl(G_msg_count).TYPE := p_type;
      G_msg_tbl(G_msg_count).ORG_ID := MO_GLOBAL.Get_Current_Org_Id;

    ELSE
      G_msg_tbl(G_msg_count).ENTITY_CODE := NULL;
      G_msg_tbl(G_msg_count).ENTITY_ID 	:= NULL;
      G_msg_tbl(G_msg_count).HEADER_ID	:= NULL;
      G_msg_tbl(G_msg_count).LINE_ID 	:= NULL;
      G_msg_tbl(G_msg_count).ORDER_SOURCE_ID := NULL;
      G_msg_tbl(G_msg_count).ORIG_SYS_DOCUMENT_REF := NULL;
      G_msg_tbl(G_msg_count).ORIG_SYS_DOCUMENT_LINE_REF := NULL;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_TYPE_ID := NULL;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_ID := NULL;
      G_msg_tbl(G_msg_count).SOURCE_DOCUMENT_LINE_ID := NULL;
      G_msg_tbl(G_msg_count).ATTRIBUTE_CODE := NULL;
      G_msg_tbl(G_msg_count).CONSTRAINT_ID := NULL;
      G_msg_tbl(G_msg_count).PROCESS_ACTIVITY := NULL;
      G_msg_tbl(G_msg_count).TYPE := NULL;
      G_msg_tbl(G_msg_count).ORG_ID := NULL;
    END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING OE_MSG_PUB.ADD_TEXT' , 3 ) ;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Add_text ' || sqlerrm);
   END IF;
END Add_Text;

--
--  Usage	Used to delete a specific message from the message
--		list, or clear the whole message list.
--
--  Desc	If instructed to delete a specific message, the
--		message is removed from the message table and the
--		table is compressed by moving the messages coming
--		after the deleted messages up one entry in the message
--		table.
--		If there is no entry found the Delete procedure does
--		nothing, and  no exception is raised.
--		If delete is passed no parameters it deletes the whole
--		message table.
--
--  Prameters	p_msg_index	IN NUMBER := FND_API.G_MISS_NUM  Optional
--		    holds the index of the message to be deleted.
--

PROCEDURE Delete_Msg
(   p_msg_index IN    NUMBER	:=  NULL
)
IS
l_msg_index	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_msg_index IS NULL THEN

	--  Delete the whole table.

	G_msg_tbl.DELETE;
	G_msg_count := 0;
	G_msg_index := 0;

    ELSE

	--  Check if entry exists

	IF G_msg_tbl.EXISTS(p_msg_index) THEN

	    IF p_msg_index <= G_msg_count THEN

		--  Move all messages up 1 entry.

		FOR I IN p_msg_index..G_msg_count-1 LOOP

            G_msg_tbl( I ).MESSAGE := G_msg_tbl( I + 1 ).MESSAGE;
            G_msg_tbl( I ).MESSAGE := G_msg_tbl( I + 1 ).MESSAGE_TEXT;
      		G_msg_tbl( I ).ENTITY_CODE := G_msg_tbl( I + 1 ).ENTITY_CODE;
      		G_msg_tbl( I ).ENTITY_ID   := G_msg_tbl( I + 1 ).ENTITY_ID;
      		G_msg_tbl( I ).HEADER_ID   := G_msg_tbl( I + 1 ).HEADER_ID;
      		G_msg_tbl( I ).LINE_ID 	   := G_msg_tbl( I + 1 ).LINE_ID;
      		G_msg_tbl( I ).ORDER_SOURCE_ID 	   := G_msg_tbl( I + 1 ).ORDER_SOURCE_ID;
      		G_msg_tbl( I ).ORIG_SYS_DOCUMENT_REF := G_msg_tbl( I + 1 ).ORIG_SYS_DOCUMENT_REF;
      		G_msg_tbl( I ).ORIG_SYS_DOCUMENT_LINE_REF := G_msg_tbl( I + 1 ).ORIG_SYS_DOCUMENT_LINE_REF;
      		G_msg_tbl( I ).SOURCE_DOCUMENT_TYPE_ID := G_msg_tbl( I + 1 ).SOURCE_DOCUMENT_TYPE_ID;
      		G_msg_tbl( I ).SOURCE_DOCUMENT_ID := G_msg_tbl( I + 1 ).SOURCE_DOCUMENT_ID;
      		G_msg_tbl( I ).SOURCE_DOCUMENT_LINE_ID := G_msg_tbl( I + 1 ).SOURCE_DOCUMENT_LINE_ID;
      		G_msg_tbl( I ).ATTRIBUTE_CODE := G_msg_tbl( I + 1 ).ATTRIBUTE_CODE;
      		G_msg_tbl( I ).CONSTRAINT_ID := G_msg_tbl( I + 1 ).CONSTRAINT_ID;
      		G_msg_tbl( I ).PROCESS_ACTIVITY := G_msg_tbl( I + 1 ).PROCESS_ACTIVITY;
      		G_msg_tbl( I ).NOTIFICATION_FLAG := G_msg_tbl( I + 1 ).NOTIFICATION_FLAG;
      		G_msg_tbl( I ).TYPE := G_msg_tbl( I + 1 ).TYPE;
            G_msg_tbl( I ).PROCESSED := G_msg_tbl( I + 1 ).PROCESSED;

		END LOOP;

		--  Delete the last message table entry.

		G_msg_tbl.DELETE(G_msg_count)	;
		G_msg_count := G_msg_count - 1	;

	    END IF;

	END IF;

    END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Delete_msg ' || sqlerrm);
   END IF;
END Delete_Msg;

procedure get_msg_context(
     p_msg_index 		    IN  NUMBER
,x_entity_code OUT NOCOPY VARCHAR2

,x_entity_ref OUT NOCOPY VARCHAR2

,x_entity_id OUT NOCOPY NUMBER

,x_header_id OUT NOCOPY NUMBER

,x_line_id OUT NOCOPY NUMBER

,x_order_source_id OUT NOCOPY NUMBER

,x_orig_sys_document_ref OUT NOCOPY VARCHAR2

,x_orig_sys_line_ref OUT NOCOPY VARCHAR2

,x_orig_sys_shipment_ref OUT NOCOPY VARCHAR2

,x_change_sequence OUT NOCOPY VARCHAR2

,x_source_document_type_id OUT NOCOPY NUMBER

,x_source_document_id OUT NOCOPY NUMBER

,x_source_document_line_id OUT NOCOPY NUMBER

,x_attribute_code OUT NOCOPY VARCHAR2

,x_constraint_id OUT NOCOPY NUMBER

,x_process_activity OUT NOCOPY NUMBER

,x_notification_flag OUT NOCOPY VARCHAR2

,x_type OUT NOCOPY VARCHAR2

 ) IS
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
Begin
    x_entity_code     		 := G_msg_tbl(p_msg_index).ENTITY_CODE;
    x_entity_ref     		 := G_msg_tbl(p_msg_index).ENTITY_REF;
    x_entity_id   		 := G_msg_tbl(p_msg_index).ENTITY_ID;
    x_header_id   		 := G_msg_tbl(p_msg_index).HEADER_ID;
    x_line_id     		 := G_msg_tbl(p_msg_index).LINE_ID;
    x_order_source_id  		 := G_msg_tbl(p_msg_index).ORDER_SOURCE_ID;
    x_orig_sys_document_ref 	 := G_msg_tbl(p_msg_index).ORIG_SYS_DOCUMENT_REF;
    x_orig_sys_line_ref 	 := G_msg_tbl(p_msg_index).ORIG_SYS_DOCUMENT_LINE_REF;
    x_orig_sys_shipment_ref 	 := G_msg_tbl(p_msg_index).ORIG_SYS_SHIPMENT_REF;
    x_change_sequence 	 	 := G_msg_tbl(p_msg_index).CHANGE_SEQUENCE;
    x_source_document_type_id 	 := G_msg_tbl(p_msg_index).SOURCE_DOCUMENT_TYPE_ID;
    x_source_document_id 	 := G_msg_tbl(p_msg_index).SOURCE_DOCUMENT_ID;
    x_source_document_line_id 	 := G_msg_tbl(p_msg_index).SOURCE_DOCUMENT_LINE_ID;
    x_attribute_code 		 := G_msg_tbl(p_msg_index).ATTRIBUTE_CODE;
    x_constraint_id 		 := G_msg_tbl(p_msg_index).CONSTRAINT_ID;
    x_process_activity 		 := G_msg_tbl(p_msg_index).PROCESS_ACTIVITY;
    x_notification_flag		 := G_msg_tbl(p_msg_index).NOTIFICATION_FLAG;
    x_type               	 := G_msg_tbl(p_msg_index).TYPE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        --  message not found return NULL;
    	x_entity_code     		:= NULL;
    	x_entity_ref     		:= NULL;
    	x_entity_id   		 	:= NULL;
    	x_header_id   		 	:= NULL;
    	x_line_id     		 	:= NULL;
        x_order_source_id               := NULL;
    	x_orig_sys_document_ref 	:= NULL;
    	x_orig_sys_line_ref 		:= NULL;
    	x_orig_sys_shipment_ref 	:= NULL;
    	x_change_sequence 		:= NULL;
        x_source_document_type_id       := NULL;
    	x_source_document_id 	 	:= NULL;
    	x_source_document_line_id 	:= NULL;
   	x_attribute_code 		:= NULL;
   	x_constraint_id 		:= NULL;
   	x_process_activity 		:= NULL;
        x_notification_flag             := NULL;
        x_type                  	:= NULL;
End get_msg_context;


--  PROCEDURE 	Get
--

PROCEDURE    Get
(   p_msg_index	    IN	NUMBER	    := G_NEXT		,
    p_encoded	    IN	VARCHAR2    := FND_API.G_TRUE	,
p_data OUT NOCOPY VARCHAR2 ,

p_msg_index_out OUT NOCOPY NUMBER

)
IS
l_msg_index NUMBER := G_msg_index;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_msg_index = G_NEXT THEN
	G_msg_index := G_msg_index + 1;
    ELSIF p_msg_index = G_FIRST THEN
	G_msg_index := 1;
    ELSIF p_msg_index = G_PREVIOUS THEN
	G_msg_index := G_msg_index - 1;
    ELSIF p_msg_index = G_LAST THEN
	G_msg_index := G_msg_count ;
    ELSE
	G_msg_index := p_msg_index ;
    END IF;


    IF G_msg_tbl(G_msg_index).Message_Text IS NOT NULL THEN

       p_data := G_msg_tbl(G_msg_index).Message_Text;

    ELSE
      IF FND_API.To_Boolean( p_encoded ) THEN

	    p_data := G_msg_tbl( G_msg_index ).Message;

      ELSE

        FND_MESSAGE.SET_ENCODED ( G_msg_tbl( G_msg_index ).Message );

	   p_data := FND_MESSAGE.GET;

	 END IF;
    END IF;

    p_msg_index_out	:=  G_msg_index		    ;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

	--  No more messages, revert G_msg_index and return NULL;

	G_msg_index := l_msg_index;

	p_data		:=  NULL;
	p_msg_index_out	:=  NULL;
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Get ' || sqlerrm);
   END IF;
END Get;

--  FUNCTION	Get
--

FUNCTION    Get
(   p_msg_index	    IN NUMBER	:= G_NEXT	    ,
    p_encoded	    IN VARCHAR2	:= FND_API.G_TRUE
)
RETURN VARCHAR2
IS
    l_data	    VARCHAR2(2000)  ;
    l_msg_index_out NUMBER	    ;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

    Get
    (	p_msg_index	    ,
	p_encoded	    ,
	l_data		    ,
	l_msg_index_out
    );

    RETURN l_data ;

EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Function Get ' || sqlerrm);
   END IF;
END Get;

--  PROCEDURE	Reset
--
--  Usage	Used to reset the message table index used in reading
--		messages to point to the top of the message table or
--		the botom of the message table.
--
--  Desc	Sets G_msg_index to 0 or G_msg_count+1 depending on
--		the reset mode.
--
--  Parameters	p_mode	IN NUMBER := G_FIRST	Optional
--		    possible values are :
--			G_FIRST	resets index to the begining of msg tbl
--			G_LAST  resets index to the end of msg tbl
--

PROCEDURE Reset ( p_mode    IN NUMBER := G_FIRST )
IS
l_procedure_name    CONSTANT VARCHAR2(15):='Reset';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_mode = G_FIRST THEN

	G_msg_index := 0;

    ELSIF p_mode = G_LAST THEN

	G_msg_index := G_msg_count;

    ELSE

	--  Invalid mode.

	OE_MSG_PUB.Add_Exc_Msg
    	(   p_pkg_name		=>  G_PKG_NAME			,
    	    p_procedure_name	=>  l_procedure_name		,
    	    p_error_text	=>  'Invalid p_mode: '||p_mode
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Reset ' || sqlerrm);
   END IF;
END Reset;

--  FUNCTION 	Check_Msg_Level
--
--  Usage   	Used by API developers to check if the level of the
--  	    	message they want to write to the message table is
--  	    	higher or equal to the message level threshold or not.
--  	    	If the function returns TRUE the developer should go
--  	    	ahead and write the message to the message table else
--  	    	he/she should skip writing this message.
--  Desc    	Accepts a message level as input fetches the value of
--  	    	the message threshold profile option and compares it
--  	    	to the input level.
--  Return  	TRUE if the level is equal to or higher than the
--  	    	threshold. Otherwise, it returns FALSE.
--

FUNCTION Check_Msg_Level
(   p_message_level IN NUMBER := G_MSG_LVL_SUCCESS
) RETURN BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF G_msg_level_threshold = FND_API.G_MISS_NUM THEN

    	--  Read the Profile option value.

    	G_msg_level_threshold :=
    	TO_NUMBER ( FND_PROFILE.VALUE('FND_AS_MSG_LEVEL_THRESHOLD') );

    	IF G_msg_level_threshold IS NULL THEN

       	    G_msg_level_threshold := G_MSG_LVL_SUCCESS;

    	END IF;

    END IF;

    RETURN p_message_level >= G_msg_level_threshold ;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Function Check_Msg_Level ' || sqlerrm);
   END IF;
END; -- Check_Msg_Level

PROCEDURE Build_Exc_Msg
( p_pkg_name	    IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
  p_procedure_name  IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
  p_error_text	    IN VARCHAR2 :=FND_API.G_MISS_CHAR
)
IS
l_error_text	VARCHAR2(2000)	:=  p_error_text ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- If p_error_text is missing use SQLERRM.

    IF p_error_text = FND_API.G_MISS_CHAR THEN

	l_error_text := SUBSTR (SQLERRM , 1 , 2000);

    END IF;

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');

    IF p_pkg_name <> FND_API.G_MISS_CHAR THEN
    	FND_MESSAGE.SET_TOKEN('PKG_NAME',p_pkg_name);
    END IF;

    IF p_procedure_name <> FND_API.G_MISS_CHAR THEN
    	FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',p_procedure_name);
    END IF;

    IF l_error_text <> FND_API.G_MISS_CHAR THEN
    	FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_error_text);
    END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Function Build_Exc_Msg ' || sqlerrm);
   END IF;
END; -- Build_Exc_Msg

PROCEDURE Add_Exc_Msg
(   p_pkg_name		IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
    p_procedure_name	IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
    p_error_text	IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
    p_context_flag      IN VARCHAR2  DEFAULT  'Y'
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    Build_Exc_Msg
    (	p_pkg_name	    ,
	p_procedure_name    ,
	p_error_text
    );
    Add((p_context_flag));
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Add_Exc_Msg ' || sqlerrm);
   END IF;
END Add_Exc_Msg ;

--  PROCEDURE	Dump_Msg
--

PROCEDURE    Dump_Msg
(   p_msg_index		IN NUMBER )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    OE_DEBUG_PUB.debug_on;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'MESSAGE NUMBER : '||P_MSG_INDEX ) ;
        oe_debug_pub.add(  'DATA = '||G_MSG_TBL ( P_MSG_INDEX ) .MESSAGE ) ;
        oe_debug_pub.add(  'ENTITY_CODE = '||G_MSG_TBL ( P_MSG_INDEX ) .ENTITY_CODE ) ;
        oe_debug_pub.add(  'ENTITY_ID = '||G_MSG_TBL ( P_MSG_INDEX ) .ENTITY_ID ) ;
        oe_debug_pub.add(  'HEADER_ID = '||G_MSG_TBL ( P_MSG_INDEX ) .HEADER_ID ) ;
        oe_debug_pub.add(  'LINE_ID = '||G_MSG_TBL ( P_MSG_INDEX ) .LINE_ID ) ;
        oe_debug_pub.add(  'ORDER_SOURCE_ID = '||G_MSG_TBL ( P_MSG_INDEX ) .ORDER_SOURCE_ID ) ;
        oe_debug_pub.add(  'ORIG_SYS_DOC_REF = '||G_MSG_TBL ( P_MSG_INDEX ) .ORIG_SYS_DOCUMENT_REF ) ;
        oe_debug_pub.add(  'ORIG_SYS_LIN_REF = '||G_MSG_TBL ( P_MSG_INDEX ) .ORIG_SYS_DOCUMENT_LINE_REF ) ;
        oe_debug_pub.add(  'SOURCE_DOC_TYPE_ID = '||G_MSG_TBL ( P_MSG_INDEX ) .SOURCE_DOCUMENT_TYPE_ID ) ;
        oe_debug_pub.add(  'SOURCE_DOC_ID = '||G_MSG_TBL ( P_MSG_INDEX ) .SOURCE_DOCUMENT_ID ) ;
        oe_debug_pub.add(  'SOURCE_LIN_ID = '||G_MSG_TBL ( P_MSG_INDEX ) .SOURCE_DOCUMENT_LINE_ID ) ;
        oe_debug_pub.add(  'ATTRIBUTE_CODE = '||G_MSG_TBL ( P_MSG_INDEX ) .ATTRIBUTE_CODE ) ;
        oe_debug_pub.add(  'CONSTRAINT_ID = '||G_MSG_TBL ( P_MSG_INDEX ) .CONSTRAINT_ID ) ;
        oe_debug_pub.add(  'PROCESS_ACTIVITY = '||G_MSG_TBL ( P_MSG_INDEX ) .PROCESS_ACTIVITY ) ;
    END IF;
    OE_DEBUG_PUB.dumpdebug;
    OE_DEBUG_PUB.debug_off;
EXCEPTION
  WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Dump_Msg ' || sqlerrm);
   END IF;
END Dump_Msg;

--  PROCEDURE	Dump_List
--
PROCEDURE    Dump_List
(   p_messages	IN BOOLEAN  :=	FALSE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    OE_DEBUG_PUB.debug_on;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DUMPING MESSAGE LIST :' ) ;
        oe_debug_pub.add(  'G_MSG_TBL.COUNT = '||G_MSG_TBL.COUNT ) ;
        oe_debug_pub.add(  'G_MSG_COUNT = '||G_MSG_COUNT ) ;
        oe_debug_pub.add(  'G_MSG_INDEX = '||G_MSG_INDEX ) ;
    END IF;
    OE_DEBUG_PUB.dumpdebug;
    OE_DEBUG_PUB.debug_off;

    IF p_messages THEN

	FOR I IN 1..G_msg_tbl.COUNT LOOP

	    dump_Msg (I);

	END LOOP;

    END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Dump_List ' || sqlerrm);
   END IF;
END Dump_List;


--  PROCEDURE	save_messages
--
--  Usage   	Used by API developers to save messages in database.
--		This procedure is used to save massages which were created by
--              batch programs.
--
--  Desc	Accepts request_id as input and assign the same to all
--              messages.
--
--
--  Parameters	p_request_id	IN NUMBER.

Procedure save_messages(p_request_id     IN NUMBER
                        ,p_message_source_code IN VARCHAR2 DEFAULT 'C')
IS
l_count_msg NUMBER := OE_MSG_PUB.Count_Msg;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER SAVE_MESSAGES' , 1 ) ;
   END IF;
   FOR I IN 1..l_count_msg  LOOP
    IF nvl(g_msg_tbl(I).processed,'N') = 'N' THEN
     insert_message(I,p_request_id,p_message_source_code);
    END IF;
   End Loop;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXIT SAVE_MESSAGES' , 1 ) ;
   END IF;
   oe_msg_pub.initialize;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure save_messages ' || sqlerrm);
   END IF;
end;

-- Bug 5007836, Created this overloaded API which is to be called
-- from OEXERMSG.pld, OE_UI_MESSAGE.Save API
Function save_messages(p_request_id     IN NUMBER
                        ,p_message_source_code IN VARCHAR2 DEFAULT 'A')
RETURN VARCHAR2
IS
Pragma AUTONOMOUS_TRANSACTION;
l_count_msg NUMBER := OE_MSG_PUB.Count_Msg;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_count     NUMBER := 0;
begin
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER Function SAVE_MESSAGES' , 1 ) ;
   END IF;
   FOR I IN 1..l_count_msg  LOOP
    IF nvl(g_msg_tbl(I).processed,'N') = 'N' THEN
     insert_message(I,p_request_id,p_message_source_code);
     l_count := l_count +1;
    END IF;
   End Loop;

   oe_msg_pub.initialize;

   COMMIT;
   IF l_count = l_count_msg THEN
     -- All messages processed
     RETURN('A');
   ELSIF l_count >0 THEN
     -- Some messages processed
     RETURN('S');
   ELSE
     -- No message processed
     RETURN('N');
   END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Function save_messages ' || sqlerrm);
   END IF;
end save_messages;

--  PROCEDURE	insert_messages
--
--  Usage   	Used by save_messages procedure to insert messages in database.
--
--  Desc	Accepts request_id and index as input
--              Reads the message from stack based on the index and inserts the
--              same in OE_PROCESSING_MSGS. This procedure resolvs message
--              text before inserting in database.
--
--
procedure insert_message (
         p_msg_index           IN NUMBER
        ,p_request_id          IN NUMBER
        ,p_message_source_code IN VARCHAR2)
IS
l_msg_data                     VARCHAR2(2000);
l_entity_code                  VARCHAR2(30);
l_entity_ref                   VARCHAR2(50);
l_entity_id                    NUMBER;
l_header_id                    NUMBER;
l_line_id                      NUMBER;
l_order_source_id              NUMBER;
l_orig_sys_document_ref        VARCHAR2(50);
l_orig_sys_line_ref   	       VARCHAR2(50);
l_orig_sys_shipment_ref        VARCHAR2(50);
l_change_sequence              VARCHAR2(50);
l_source_document_type_id      NUMBER;
l_source_document_id           NUMBER;
l_source_document_line_id      NUMBER;
l_attribute_code               VARCHAR2(30);
l_constraint_id		       NUMBER;
l_process_activity             NUMBER;
l_transaction_id	       NUMBER;
l_notification_flag            VARCHAR2(1) := 'N' ;
l_type                	       VARCHAR2(30) ;
l_org_id                   NUMBER;
l_order_number                 NUMBER;
l_line_number                  VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


   IF G_msg_tbl(p_msg_index).message_text IS NOT NULL THEN
      l_msg_data := G_msg_tbl(p_msg_index).message_text;
   ELSE
      l_msg_data := Get(p_msg_index, 'F');
   END IF;
   l_org_id :=  G_msg_tbl(p_msg_index).ORG_ID;

   Get_msg_context(
         p_msg_index			=> p_msg_index
        ,x_entity_code			=> l_entity_code
        ,x_entity_ref			=> l_entity_ref
        ,x_entity_id			=> l_entity_id
        ,x_header_id			=> l_header_id
        ,x_line_id			=> l_line_id
        ,x_order_source_id		=> l_order_source_id
        ,x_orig_sys_document_ref	=> l_orig_sys_document_ref
        ,x_orig_sys_line_ref		=> l_orig_sys_line_ref
        ,x_orig_sys_shipment_ref	=> l_orig_sys_shipment_ref
        ,x_change_sequence		=> l_change_sequence
        ,x_source_document_type_id 	=> l_source_document_type_id
        ,x_source_document_id		=> l_source_document_id
        ,x_source_document_line_id 	=> l_source_document_line_id
        ,x_attribute_code		=> l_attribute_code
	,x_constraint_id		=> l_constraint_id
	,x_process_activity		=> l_process_activity
        ,x_notification_flag		=> l_notification_flag
        ,x_type				=> l_type
	);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_MSG_DATA='||L_MSG_DATA,3 ) ;
   END IF;

   if nvl(fnd_profile.value('CONC_REQUEST_ID'),0) > 0 then
    BEGIN  --bug 7184951
      IF l_header_id IS NOT NULL
        AND NOT OE_GLOBALS.Equal(l_header_id,g_header_id) THEN
         SELECT order_number
           INTO l_order_number
           FROM oe_order_headers_all
          WHERE header_id = l_header_id;
         g_order_number := l_order_number;
         g_header_id := l_header_id;

      END IF;
      l_line_number := OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(l_line_id);

      FND_FILE.put_line(FND_FILE.LOG,'Order Number :'||g_order_number  ||'  Line Number :'||l_line_number);
      FND_FILE.put_line(FND_FILE.LOG,'Message :'|| l_msg_data);
   EXCEPTION  ---start bug 7184951
      WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
       oe_debug_pub.add('Error in Procedure insert_message  ' || sqlerrm);
       oe_debug_pub.add('Order number not found');
      END IF;
   /*End bug 7184951*/
    END ;


   end if;


if p_msg_index IS NOT NULL then

   BEGIN

     SELECT  oe_msg_id_S.NEXTVAL
     INTO    l_transaction_id
     FROM    dual;

   END;

   insert into OE_PROCESSING_MSGS
   (  Transaction_id
     ,request_Id
--     ,message_text
     ,entity_code
     ,entity_ref
     ,entity_id
     ,header_id
     ,line_id
     ,order_source_id
     ,original_sys_document_ref
     ,original_sys_document_line_ref
     ,orig_sys_shipment_ref
     ,change_sequence
     ,source_document_type_id
     ,source_document_id
     ,source_document_line_id
     ,attribute_code
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,program_application_id
     ,program_id
     ,program_update_date
     ,process_activity
     ,notification_flag
     ,type
     ,message_source_code
     ,message_status_code
     ,org_id
    ) VALUES
    ( l_transaction_id
     ,p_request_id
--     ,l_msg_data
     ,l_entity_code
     ,l_entity_ref
     ,l_entity_id
     ,l_header_id
     ,l_line_id
     ,l_order_source_id
     ,l_orig_sys_document_ref
     ,l_orig_sys_line_ref
     ,l_orig_sys_shipment_ref
     ,l_change_sequence
     ,l_source_document_type_id
     ,l_source_document_id
     ,l_source_document_line_id
     ,l_attribute_code
     ,sysdate
     ,FND_GLOBAL.USER_ID
     ,sysdate
     ,FND_GLOBAL.USER_ID
     ,decode(p_message_source_code,'C',FND_GLOBAL.CONC_LOGIN_ID,FND_GLOBAL.LOGIN_ID)
     ,NULL
     ,NULL
     ,NULL
     ,l_process_activity
     ,l_notification_flag
     ,l_type
     ,p_message_source_code
     ,'OPEN'
     ,nvl(l_org_id,MO_GLOBAL.get_current_org_id)
     );

     BEGIN

       INSERT INTO OE_PROCESSING_MSGS_TL
       (Transaction_id
       ,language
       ,source_lang
       ,message_text
       ,created_by
       ,creation_date
       ,last_updated_by
       ,last_update_date
       ,last_update_login
       )
       SELECT
        l_transaction_id
        ,l.language_code
        ,USERENV('LANG')
        ,l_msg_data
        ,FND_GLOBAL.USER_ID
        ,sysdate
        ,FND_GLOBAL.USER_ID
        ,sysdate
        ,decode(p_message_source_code,'C',FND_GLOBAL.CONC_LOGIN_ID,FND_GLOBAL.LOGIN_ID)
        FROM fnd_languages l
        WHERE l.installed_flag in ('I','B')
	   AND   language_code = USERENV('LANG')
        AND   not exists
              (SELECT null
               FROM  oe_processing_msgs_tl t
               WHERE t.transaction_id = l_transaction_id
               AND   t.language       = l.language_code);

     END;

    G_msg_tbl(p_msg_index).processed := 'Y';
  end if;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure insert_message ' || sqlerrm);
   END IF;
End insert_message;


--  PROCEDURE	Get_msg_tbl
--
--  Usage   	Used by process messages form to retreive messages from stack .
--
--  Desc	This procedure returns message_table to the caller.
--              This procedure also resolvs message text before returning
--              message table to the caller.
--
--
PROCEDURE Get_msg_tbl(x_msg_tbl IN OUT NOCOPY /* file.sql.39 change */ msg_tbl_type)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   FOR i IN G_msg_tbl.FIRST .. G_msg_tbl.LAST LOOP


    IF G_msg_tbl(i).message_text IS NOT NULL THEN

       x_msg_tbl(i).message := G_msg_tbl(i).message_text;

    ELSE

       x_msg_tbl(i).message := GET(i,'F');

    END IF;

--    x_msg_tbl(i).message := GET(i,'F');
--    x_msg_tbl(i).message := G_msg_tbl(i).message;
    x_msg_tbl(i).entity_code := G_msg_tbl(i).entity_code;
    x_msg_tbl(i).entity_id := G_msg_tbl(i).entity_id;
    x_msg_tbl(i).header_id := G_msg_tbl(i).header_id;
    x_msg_tbl(i).line_id := G_msg_tbl(i).line_id;
    x_msg_tbl(i).order_source_id := G_msg_tbl(i).order_source_id;
    x_msg_tbl(i).orig_sys_document_ref := G_msg_tbl(i).orig_sys_document_ref;
    x_msg_tbl(i).orig_sys_document_line_ref := G_msg_tbl(i).orig_sys_document_line_ref;
    x_msg_tbl(i).source_document_type_id := G_msg_tbl(i).source_document_type_id;
    x_msg_tbl(i).source_document_id := G_msg_tbl(i).source_document_id;
    x_msg_tbl(i).source_document_line_id := G_msg_tbl(i).source_document_line_id;
    x_msg_tbl(i).attribute_code := G_msg_tbl(i).attribute_code;
    x_msg_tbl(i).constraint_id := G_msg_tbl(i).constraint_id;
    x_msg_tbl(i).process_activity := G_msg_tbl(i).process_activity;
    x_msg_tbl(i).notification_flag := G_msg_tbl(i).notification_flag;
    x_msg_tbl(i).message_text := null;
    x_msg_tbl(i).type := G_msg_tbl(i).type;
    x_msg_tbl(i).processed := g_msg_tbl(i).processed;
    x_msg_tbl(i).org_id := g_msg_tbl(i).org_id;

   END LOOP;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure get_msg_tbl ' || sqlerrm);
   END IF;

END;
/* Added the below procedure for bug 4716444 */
PROCEDURE Populate_Msg_tbl ( p_msg_tbl IN msg_tbl_type )
IS
BEGIN
  FOR i IN p_msg_tbl.first .. p_msg_tbl.last LOOP
     --Increment message count
     G_msg_count := G_msg_count + 1;

--     G_msg_tbl(G_msg_count):= p_msg_tbl(i);
     --Add the message
     G_msg_tbl(G_msg_count).message_text := p_msg_tbl(i).message;
     G_msg_tbl(G_msg_count).entity_code := p_msg_tbl(i).entity_code;
     G_msg_tbl(G_msg_count).entity_id := p_msg_tbl(i).entity_id;
     G_msg_tbl(G_msg_count).header_id := p_msg_tbl(i).header_id;
     G_msg_tbl(G_msg_count).line_id := p_msg_tbl(i).line_id;
     G_msg_tbl(G_msg_count).order_source_id := p_msg_tbl(i).order_source_id;
     G_msg_tbl(G_msg_count).orig_sys_document_ref := p_msg_tbl(i).orig_sys_document_ref;
     G_msg_tbl(G_msg_count).orig_sys_document_line_ref := p_msg_tbl(i).orig_sys_document_line_ref;
     G_msg_tbl(G_msg_count).source_document_type_id := p_msg_tbl(i).source_document_type_id;
     G_msg_tbl(G_msg_count).source_document_id := p_msg_tbl(i).source_document_id;
     G_msg_tbl(G_msg_count).source_document_line_id := p_msg_tbl(i).source_document_line_id;
     G_msg_tbl(G_msg_count).attribute_code := p_msg_tbl(i).attribute_code;
     G_msg_tbl(G_msg_count).constraint_id := p_msg_tbl(i).constraint_id;
     G_msg_tbl(G_msg_count).process_activity := p_msg_tbl(i).process_activity;
     G_msg_tbl(G_msg_count).notification_flag := p_msg_tbl(i).notification_flag;
     G_msg_tbl(G_msg_count).type := p_msg_tbl(i).type;
     G_msg_tbl(G_msg_count).processed := p_msg_tbl(i).processed;
     G_msg_tbl(G_msg_count).org_id := p_msg_tbl(i).org_id;


  END LOOP;

END;
/* End of code for bug 4716444 */

--  PROCEDURE   Save_UI_Messages.
--
--  Usage   	Used by process messages form to store messages in database
--              by using autonomous transaction .
--
--  Desc	This procedure is set for autonomous transaction.
--              This procedure calls save_messages procedure to insert messages
--              in OE_PROCESSING_MSGS.
--		This procedure accepts request_id as input from the caller
--
--  Note        This procedure uses autonomous transaction.That means
--              commit or rollback with in this procedure will not affect
--              the callers transaction.


PROCEDURE Save_UI_Messages(p_request_id    IN NUMBER
                          ,p_message_source_code IN VARCHAR2)
IS
Pragma AUTONOMOUS_TRANSACTION;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   Save_Messages(p_request_id
                ,p_message_source_code);
   COMMIT;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure save_ui_messages ' || sqlerrm);
   END IF;
END Save_UI_Messages;

--  PROCEDURE   Update_notification_flag.
--
--  Usage   	Used by process messages form to set notification_flag
--              for batch program generated messages.
--
--  Desc	This procedure is set for autonomous transaction.
--              This procedure accepts transaction_id and updates
--              the OE_PROCESSING_MSGS.
--
--  Note        This procedure uses autonomous transaction.That means
--              commit or rollback with in this procedure will not affect
--              the callers transaction.

PROCEDURE Update_Notification_Flag(p_transaction_id IN NUMBER)
IS
Pragma AUTONOMOUS_TRANSACTION;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    UPDATE oe_processing_msgs
    SET    notification_flag = 'Y'
    WHERE  transaction_id = p_transaction_id;

    COMMIT;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Update_Notification_Flag ' || sqlerrm);
   END IF;
END Update_Notification_Flag;

--  PROCEDURE   Update_UI_notification_flag.
--
--  Usage   	Used by process messages form to set notification_flag
--              for UI generated messages.
--
--  Desc	This procedure accepts stack index and updates
--              the msg stack.
--

PROCEDURE Update_UI_Notification_Flag(p_msg_ind IN NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    G_msg_tbl(p_msg_ind).Notification_flag := 'Y';
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Update_UI_Notification_Flag ' || sqlerrm);
   END IF;

END Update_UI_Notification_Flag;


--  FUNCTION   	Get_Single_Message
--
--  Usage   	Used by form developers when one process message
--              to be shown on the screen.
--
--  Desc	This function makes sure that there is only one
--              message in the stack and returns the message based
--              on the constraint_id. If the constraint_id is null
--              then only the message will be return to the caller
--              , Otherwise message will be returned with resolving
--              responsibilities.
--

FUNCTION Get_Single_Message
(
x_return_status OUT NOCOPY VARCHAR2

)
RETURN VARCHAR2
IS

 l_WF_Roles_Tbl         OE_PC_GLOBALS.Authorized_WF_Roles_TBL;
 l_return_status 	VARCHAR2(1);
 l_message              VARCHAR2(2000);
 l_constraint_id        NUMBER;
 l_msg_length           NUMBER := 0;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF  OE_Msg_pub.Count_Msg <> 1   THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    ELSE


    IF G_msg_tbl(1).message_text IS NOT NULL THEN

       l_message := G_msg_tbl(1).message_text;

    ELSE

       l_message := GET(1,'F');

    END IF;


      l_constraint_id := G_msg_tbl(1).constraint_id;

      IF l_constraint_id IS NOT NULL THEN

        l_WF_Roles_Tbl :=  Oe_PC_Constraints_Admin_Pub.Get_Authorized_WF_Roles
        		   (p_constraint_id =>  l_constraint_id
			    ,x_return_status =>  l_return_status);

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_msg_length := length(l_message);

        IF l_msg_length < 1600 THEN

          FOR i IN l_WF_Roles_Tbl.FIRST .. l_WF_Roles_Tbl.LAST LOOP

           l_msg_length := l_msg_length + nvl(length(l_WF_Roles_Tbl(i).display_name),0);

           IF l_msg_length <= 1600 THEN

             l_message := l_message || ' , ' || l_WF_Roles_Tbl(i).display_name;

           ELSE

            Delete_msg;
            RETURN l_message;

           END IF;

          END LOOP;

        END IF;

      END IF;

    END IF;

    Delete_msg;
    RETURN l_message;

EXCEPTION

 WHEN OTHERS THEN
/*        l_message := 'Something wrong';
        Return  l_message;*/
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END Get_Single_Message;


--  PROCEDURE  	Delete_Message
--
--  Usage   	Used by process message form to delete queried
--              messages.
--
--  Desc	This procedure accepts where clause parameters
--              from the caller and deletes data from OE_PROCESSING_MSGS_TL
--              and  OE_PROCESSING_MSGS.
--

PROCEDURE DELETE_MESSAGE
          (p_message_source_code     IN VARCHAR2   DEFAULT  NULL
          ,p_request_id_from         IN NUMBER     DEFAULT  NULL
          ,p_request_id_to           IN NUMBER     DEFAULT  NULL
          ,p_order_number_from       IN NUMBER     DEFAULT  NULL
          ,p_order_number_to         IN NUMBER     DEFAULT  NULL
          ,p_creation_date_from      IN VARCHAR2       DEFAULT  NULL
          ,p_creation_date_to        IN VARCHAR2       DEFAULT  NULL
          ,p_program_id              IN NUMBER     DEFAULT  NULL
          ,p_process_activity_name   IN VARCHAR2   DEFAULT  NULL
          ,p_order_type_id           IN NUMBER     DEFAULT  NULL
          ,p_attribute_code          IN VARCHAR2   DEFAULT  NULL
          ,p_organization_id         IN NUMBER     DEFAULT  NULL
          ,p_created_by              IN NUMBER     DEFAULT  NULL)


IS
 /* These types and variables introduced to fix 1922443 */
 TYPE Transactionidtab is TABLE OF oe_processing_msgs.transaction_id%TYPE;
 TYPE Transactionrowidtab is TABLE OF varchar2(100);
 Transactionids Transactionidtab := Transactionidtab();
 Transactionrowids Transactionrowidtab := Transactionrowidtab();

 l_stmt                          VARCHAR2(4000) :=NULL;
 l_cursor_id                     INTEGER;
 l_retval                        INTEGER;
 J                               NUMBER := 0;
 d                               NUMBER;
 l_transaction_id                NUMBER;
 l_creation_date_from            DATE;
 l_creation_date_to              DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN OE_MSG_PUB.DELETE_MESSAGE' ) ;
     END IF;
            /* 1922443 */
/*            select msg.rowid,
                   msg.transaction_id
            bulk collect
            into   transactionrowids,
                   transactionids
            from   oe_processing_msgs msg,
                   oe_order_headers hdr,
                   wf_process_activities wpa,
                   wf_activities_tl wa
            Where  msg.header_id = hdr.header_id (+)
            AND    msg.process_activity = wpa.instance_id(+)
            AND    wpa.activity_name = wa.name(+)
            AND    wpa.activity_item_type =wa.item_type(+)
            AND    wpa.process_version = wa.version(+)
            AND    wa.language(+) = USERENV('LANG')
            AND    nvl(msg.message_source_code,0)   = nvl(p_message_source_code
                                               ,nvl(msg.message_source_code,0))
            AND    nvl(msg.request_id,0)    between   nvl(p_request_id_from
                                               ,nvl(msg.request_id,0))
                                 and       nvl(p_request_id_to
                                               ,nvl(msg.request_id,0))
            AND    nvl(hdr.order_number,0)  between   nvl(p_order_number_from
                                               ,nvl(hdr.order_number,0))
                                 and       nvl(p_order_number_to
                                               ,nvl(hdr.order_number,0))
            AND    msg.creation_date between   nvl(p_creation_date_from
                                               ,msg.creation_date)
                                 and       nvl(p_creation_date_to
                                               ,msg.creation_date)
            AND    nvl(msg.program_id,0)            = nvl(p_program_id
                                               ,nvl(msg.program_id,0))
            AND    nvl(wa.display_name,0)         = nvl(p_process_activity_name
                                               ,nvl(wa.display_name,0))
            AND    nvl(hdr.order_type_id,0)         = nvl(p_order_type_id
                                               ,nvl(hdr.order_type_id,0))
            AND    nvl(msg.attribute_code,0)        = nvl(p_attribute_code
                                               ,nvl(msg.attribute_code,0))
            AND    nvl(hdr.sold_to_org_id,0)       = nvl(p_organization_id
                                               ,nvl(hdr.sold_to_org_id,0))
            AND    msg.created_by            = nvl(p_created_by
                                               ,msg.created_by);
*/


   l_cursor_id := DBMS_SQL.OPEN_CURSOR;


   IF p_order_type_id is null
   AND p_order_number_from is null
   AND p_order_number_to is null
   AND p_organization_id is null
   AND p_process_activity_name is null

   THEN

    l_stmt := 'select transaction_id ' ||
        ' from oe_processing_msgs msg';

    l_stmt := l_stmt ||' WHERE 1 = 1';
   ELSIF p_process_activity_name is null
   THEN

    l_stmt := 'select transaction_id ' ||
        ' from oe_processing_msgs msg, oe_order_headers_all hdr';

    l_stmt := l_stmt ||' WHERE msg.header_id = hdr.header_id';
   ELSE

    l_stmt := 'select transaction_id ' ||
        ' from oe_processing_msgs msg, oe_order_headers hdr' ||
         ',wf_process_activities wpa, wf_activities_tl wa ';

     l_stmt := l_stmt ||'   WHERE  msg.header_id = hdr.header_id' ||
            ' AND    msg.process_activity = wpa.instance_id(+)' ||
            ' AND    wpa.activity_name = wa.name(+)' ||
            ' AND    wpa.activity_item_type =wa.item_type(+)' ||
            ' AND    wpa.process_version = wa.version(+)' ||
            ' AND    wa.language(+) = USERENV('||'''LANG''' ||')';
   END IF;


   IF p_message_source_code IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  msg.message_source_code =:message_source_code';
   END IF;

   IF p_request_id_from IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  msg.request_id >= :request_id_from';
   END IF;

   IF p_request_id_to IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  msg.request_id <= :request_id_to';
   END IF;
   --5121760
   IF p_creation_date_from IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  trunc(msg.creation_date) >= :creation_date_from';
   END IF;

   IF p_creation_date_to IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  trunc(msg.creation_date) <= :creation_date_to';
   END IF;

   IF p_program_id IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  msg.program_id = :program_id';
   END IF;

   IF p_attribute_code IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  msg.attribute_code = :attribute_code';
   END IF;

   IF p_created_by IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  msg.created_by = :created_by'; --Bug # 5398729
   END IF;

   IF p_order_number_from IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  hdr.order_number >= :order_number_from';
   END IF;

   IF p_order_number_to IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  hdr.order_number <= :order_number_to';
   END IF;

   IF p_order_type_id IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  hdr.order_type_id = :order_type_id';
   END IF;

   IF p_organization_id IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  hdr.sold_to_org_id = :sold_to_org_id';
   END IF;

   IF p_process_activity_name IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  wa.display_name = :process_activity_name';
   END IF;

   OE_DEBUG_PUB.Add(substr(l_stmt,1,length(l_stmt)),1);

   DBMS_SQL.PARSE(l_cursor_id, l_stmt, DBMS_SQL.native);

   OE_DEBUG_PUB.Add('after parse',1);
   --5121760
   SELECT fnd_date.chardt_to_date(p_creation_date_from),
          fnd_date.chardt_to_date(p_creation_date_to)
   INTO   l_creation_date_from,l_creation_date_to
   FROM DUAL;
   IF p_message_source_code IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':message_source_code',p_message_source_code);
   END IF;

   IF p_request_id_from IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':request_id_from',p_request_id_from);
   END IF;

   IF p_request_id_to IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':request_id_to',p_request_id_to);
   END IF;
   --5121760
   IF p_creation_date_from IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':creation_date_from',trunc(l_creation_date_from));
   END IF;
   IF p_creation_date_to IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':creation_date_to',trunc(l_creation_date_to));
   END IF;

   IF p_program_id IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':program_id',p_program_id);
   END IF;

   IF p_attribute_code IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':attribute_code',p_attribute_code);
   END IF;

   IF p_created_by IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':created_by',p_created_by);
   END IF;

   IF p_order_number_from IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':order_number_from',p_order_number_from);
   END IF;

   IF p_order_number_to IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':order_number_to',p_order_number_to);
   END IF;

   IF p_order_type_id IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':order_type_id',p_order_type_id);
   END IF;

   IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':sold_to_org_id',p_organization_id);
   END IF;

   IF p_process_activity_name IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':process_activity_name',p_process_activity_name);
   END IF;

   DBMS_SQL.DEFINE_COLUMN(l_cursor_id,1,l_transaction_id);
   oe_debug_pub.add('Before execute ',1);
   l_retval := DBMS_SQL.EXECUTE(l_cursor_id);

   LOOP
      oe_debug_pub.add('J: ' || J,1);

      IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
        EXIT;
      END IF;

      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_transaction_id);
      J :=  J +1 ;

      oe_debug_pub.add('l_transaction_id: ' || l_transaction_id,1);
      oe_debug_pub.add('J1: ' || J,1);

     Transactionids.extend(1);
     Transactionids(J) := l_transaction_id;

   END LOOP;

   oe_debug_pub.add('Before Close ',1);
   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);


   oe_debug_pub.add('Count: ' || Transactionids.COUNT,1);

   FORALL J in 1..Transactionids.COUNT
   Delete
   from   oe_processing_msgs_tl
   Where  transaction_id = Transactionids(J);

   FORALL J in 1..Transactionids.COUNT
   Delete
   from   oe_processing_msgs
   Where  transaction_id = Transactionids(J);

/*
   FORALL J in 1..Transactionrowids.COUNT
   Delete
   from   oe_processing_msgs
   Where  rowid = Transactionrowids(J);
*/
   Transactionids.DELETE;
   Transactionrowids.DELETE;

   commit;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_MSG_PUB.DELETE_MESSAGE' ) ;
   END IF;

EXCEPTION

  WHEN  OTHERS THEN

      oe_debug_pub.add ('error :' || sqlerrm,1);
      oe_debug_pub.add (l_stmt,1);
END DELETE_MESSAGE;

PROCEDURE DELETE_OI_MESSAGE
           (p_request_id                  IN NUMBER     DEFAULT  NULL
           ,p_order_source_id             IN NUMBER     DEFAULT  NULL
           ,p_orig_sys_document_ref       IN VARCHAR2   DEFAULT  NULL
           ,p_change_sequence             IN VARCHAR2   DEFAULT  NULL
           ,p_orig_sys_document_line_ref  IN VARCHAR2   DEFAULT  NULL
           ,p_orig_sys_shipment_ref       IN VARCHAR2   DEFAULT  NULL
           ,p_entity_code                 IN VARCHAR2   DEFAULT  NULL
           ,p_entity_ref                  IN VARCHAR2   DEFAULT  NULL
           ,p_org_id                      IN NUMBER     DEFAULT  NULL)

IS
 /* Replaced with the following to fix 1922443
 TYPE Transaction_tab is TABLE OF oe_processing_msgs.transaction_id%TYPE;
 Transactions_oi Transaction_tab;
 */

 TYPE Transactionidtab is TABLE OF oe_processing_msgs.transaction_id%TYPE;
 TYPE Transactionrowidtab is TABLE OF varchar2(100);
 Transactionids Transactionidtab := Transactionidtab();
 Transactionrowids Transactionrowidtab := Transactionrowidtab();

 l_stmt                          VARCHAR2(4000) :=NULL;
 l_cursor_id                     INTEGER;
 l_retval                        INTEGER;
 J                               NUMBER := 0;
 d                               NUMBER;
 l_transaction_id                NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN OE_MSG_PUB.DELETE_OI_MESSAGE' ) ;
     END IF;
            /* Replaced with the following for 1922443
            Select transaction_id
		  Bulk Collect Into  transactions_oi

            select rowid,
                   transaction_id
            bulk collect
            into   transactionrowids,
                   transactionids
            from   oe_processing_msgs
            Where  nvl(request_id,0) = nvl(p_request_id,
							    nvl(request_id,0))
            Removed nvl condition as we expect order_source_id and
              original_sys_document_ref to be passed # 2467558
            And    order_source_id = p_order_source_id
            And    original_sys_document_ref = p_orig_sys_document_ref
            And    nvl(Original_sys_document_line_ref,0) =
		                             nvl(p_Orig_sys_document_line_ref,
							    nvl(Original_sys_document_line_ref,0))
            And    nvl(orig_sys_shipment_ref,0) = nvl(p_orig_sys_shipment_ref,
							    nvl(orig_sys_shipment_ref,0))
            And    nvl(change_sequence,0) = nvl(p_change_sequence,
							    nvl(change_sequence,0))
            And    nvl(entity_code,0) = nvl(p_entity_code,
							    nvl(entity_code,0))
            And    nvl(entity_ref,0) = nvl(p_entity_ref,
							    nvl(entity_ref,0));

      Replaced with the following to fix 1922443
     FORALL J in 1..Transactions_oi.COUNT
	  Delete
	  from   oe_processing_msgs_tl
	  Where  transaction_id = Transactions_oi(J);


     FORALL J in 1..Transactions_oi.COUNT
	  Delete
	  from   oe_processing_msgs
	  Where  transaction_id = Transactions_oi(J);

     Transactions_oi.DELETE;


     FORALL J in 1..Transactionids.COUNT
	  Delete
	  from   oe_processing_msgs_tl
	  Where  transaction_id = Transactionids(J);


     FORALL J in 1..Transactionrowids.COUNT
	  Delete
	  from   oe_processing_msgs
	  Where  rowid = Transactionrowids(J);


     Transactionids.DELETE;
     Transactionrowids.DELETE;
     commit;
*/

   l_cursor_id := DBMS_SQL.OPEN_CURSOR;



    l_stmt := 'select transaction_id ' ||
        ' from oe_processing_msgs';



   l_stmt := l_stmt ||' WHERE  order_source_id = :order_source_id';

   IF p_request_id IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  request_id = :request_id';
   END IF;

   IF p_orig_sys_document_ref IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  original_sys_document_ref = :orig_sys_document_ref';
   END IF;

   IF p_Orig_sys_document_line_ref IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  Original_sys_document_line_ref = :Orig_sys_document_line_ref';
   END IF;

   IF p_orig_sys_shipment_ref IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  orig_sys_shipment_ref = :orig_sys_shipment_ref';
   END IF;

   IF p_change_sequence IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  change_sequence = :change_sequence';
   END IF;

   IF p_entity_code IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  entity_code = :entity_code';
   END IF;

   IF p_entity_ref IS NOT NULL THEN
      l_stmt := l_stmt ||' AND  entity_ref = :entity_ref';
   END IF;

   IF p_org_id IS NOT NULL THEN
      l_stmt := l_stmt ||' AND org_id = :org_id';
   END IF;

   OE_DEBUG_PUB.Add(substr(l_stmt,1,length(l_stmt)),1);

   DBMS_SQL.PARSE(l_cursor_id, l_stmt, DBMS_SQL.native);

   OE_DEBUG_PUB.Add('after parse',1);
   IF p_order_source_id IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':order_source_id',p_order_source_id);
   END IF;

   IF p_request_id IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':request_id',p_request_id);
   END IF;

   IF p_orig_sys_document_ref IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':orig_sys_document_ref',p_orig_sys_document_ref);
   END IF;

   IF p_Orig_sys_document_line_ref IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':Orig_sys_document_line_ref',p_Orig_sys_document_line_ref);
   END IF;

   IF p_orig_sys_shipment_ref IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':orig_sys_shipment_ref',p_orig_sys_shipment_ref);
   END IF;

   IF p_change_sequence IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':change_sequence',p_change_sequence);
   END IF;

   IF p_entity_code IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':entity_code',p_entity_code);
   END IF;

   IF p_entity_ref IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':entity_ref',p_entity_ref);
   END IF;

   IF p_org_id IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':org_id',p_org_id);
   END IF;

   DBMS_SQL.DEFINE_COLUMN(l_cursor_id,1,l_transaction_id);
   oe_debug_pub.add('Before execute ',1);
   l_retval := DBMS_SQL.EXECUTE(l_cursor_id);

   LOOP
      oe_debug_pub.add('J: ' || J,1);

      IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
        EXIT;
      END IF;

      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_transaction_id);
      J :=  J +1 ;

      oe_debug_pub.add('l_transaction_id: ' || l_transaction_id,1);
      oe_debug_pub.add('J1: ' || J,1);

     Transactionids.extend(1);
     Transactionids(J) := l_transaction_id;

   END LOOP;

   oe_debug_pub.add('Before Close ',1);
   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);


   oe_debug_pub.add('Count: ' || Transactionids.COUNT,1);

   FORALL J in 1..Transactionids.COUNT
   Delete
   from   oe_processing_msgs_tl
   Where  transaction_id = Transactionids(J);

   FORALL J in 1..Transactionids.COUNT
   Delete
   from   oe_processing_msgs
   Where  transaction_id = Transactionids(J);

   Transactionids.DELETE;
   Transactionrowids.DELETE;

   commit;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_MSG_PUB.DELETE_OI_MESSAGE' ) ;
     END IF;

/*
EXCEPTION

 WHEN OTHERS THEN

   oe_debug_pub.add('Error : ' || sqlerrm);*/
END DELETE_OI_MESSAGE;

-- 4091185 - Added parameter p_type.
PROCEDURE Transfer_Msg_Stack
( p_msg_index IN  NUMBER DEFAULT  NULL,
  p_type      IN  VARCHAR2 DEFAULT NULL)
IS
l_count NUMBER;
l_message VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF p_msg_index IS NOT NULL THEN

     l_message := fnd_msg_pub.get(p_msg_index,'F');
     add_text(p_message_text => l_message,
              p_type         => p_type);

  ELSE

	l_count := fnd_msg_pub.count_msg;

	FOR i in 1..l_count LOOP

        l_message := fnd_msg_pub.get(i,'F');
        add_text(p_message_text => l_message,
                 p_type         => p_type);


	END LOOP;

  END IF; -- p_msg_index

  fnd_msg_pub.delete_msg; -- Adding this call to fix 4642102.
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Transfer_Msg_Stack ' || sqlerrm);
   END IF;
END Transfer_Msg_Stack;

/* Procedure Save_API_Messages will be used by many API's to store the
error messages before raising the exceptions or rolling back the transaction
so that the errors are captured.

This API can be called from anywhere to save the messages without affecting the
actual transaction. If the call is made from the concurrent program, this API will
store the messages against the concurrent ID.

This API will also capture the sql errors if there are any.

Message source Code 'A' will be used for 'API' calls.
*/

PROCEDURE Save_API_Messages (p_request_id    IN NUMBER DEFAULT  NULL
                            ,p_message_source_code IN VARCHAR2 DEFAULT 'A')
IS
Pragma AUTONOMOUS_TRANSACTION;

l_count_msg           NUMBER;
l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_errmsg              VARCHAR2(1000) :=  Null;
l_request_id          NUMBER := p_request_id;
l_message_source_code VARCHAR2(3) := p_message_source_code;

BEGIN


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER Save_API_Messages' , 1 ) ;
   END IF;

   IF nvl(fnd_profile.value('CONC_REQUEST_ID'),0)  > 0
   THEN
      l_request_id          := fnd_profile.value('CONC_REQUEST_ID');
      l_message_source_code := 'C';
   END IF;

   l_errmsg := ltrim(Substr(SQLERRM,1,1000));

   IF l_errmsg IS NOT NULL  THEN
      oe_debug_pub.add('l_errmsg ' || l_errmsg, 2 ) ;
   END IF;

   /* Commenting the following code
      to fix the bug 5201283 as we do not need to
      show the tech messages to users
      We will continue to write the messages to log files

   IF l_errmsg IS NOT NULL
   AND substr(l_errmsg,5,4) <> '0000'
   AND rtrim(ltrim(l_errmsg)) <> 'ORA-20001:'
   AND upper(substr(ltrim(l_errmsg),1,5)) <> 'USER-' THEN
      oe_debug_pub.add('l_errmsg ' || l_errmsg, 2 ) ;
      oe_msg_pub.add_text(p_message_text => l_errmsg);
   END IF;

   */
   l_count_msg := OE_MSG_PUB.Count_Msg;

   FOR I IN 1..l_count_msg  LOOP
     IF nvl(g_msg_tbl(I).processed,'N') = 'N' THEN
        insert_message(I,l_request_id,l_message_source_code);
     END IF;
   End Loop;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXIT Save_API_Messages' , 1 ) ;
   END IF;

   COMMIT;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Save_API_Messages ' || sqlerrm);
   END IF;
END Save_API_Messages;
PROCEDURE Update_status_code(
     p_request_id                  IN  NUMBER      DEFAULT NULL
    ,p_org_id                      IN  NUMBER      DEFAULT NULL
    ,p_entity_code                 IN  VARCHAR2    DEFAULT NULL
    ,p_entity_id                   IN  NUMBER      DEFAULT NULL
    ,p_header_id                   IN  NUMBER      DEFAULT NULL
    ,p_line_id                     IN  NUMBER      DEFAULT NULL
    ,p_order_source_id             IN  NUMBER      DEFAULT NULL
    ,p_orig_sys_document_ref       IN  VARCHAR2    DEFAULT NULL
    ,p_orig_sys_document_line_ref  IN  VARCHAR2    DEFAULT NULL
    ,p_orig_sys_shipment_ref       IN  VARCHAR2    DEFAULT NULL
    ,p_change_sequence             IN  VARCHAR2    DEFAULT NULL
    ,p_source_document_type_id     IN  NUMBER      DEFAULT NULL
    ,p_source_document_id          IN  NUMBER      DEFAULT NULL
    ,p_source_document_line_id     IN  NUMBER      DEFAULT NULL
    ,p_attribute_code              IN  VARCHAR2    DEFAULT NULL
    ,p_constraint_id               IN  NUMBER      DEFAULT NULL
    ,p_process_activity            IN  NUMBER      DEFAULT NULL
    ,p_sold_to_org_id              IN  NUMBER      DEFAULT NULL
    ,p_status_code                 IN  Varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_transaction_id NUMBER;
l_cursor_id                     INTEGER;
l_retval                        INTEGER;
l_stmt                          VARCHAR2(4000) :=NULL;
--
BEGIN

     oe_debug_pub.add('p_entity_code: ' || p_entity_code,2);
     oe_debug_pub.add('p_entity_id: ' || p_entity_id,2);
     oe_debug_pub.add('p_header_id: ' || p_header_id,2);
     oe_debug_pub.add('p_line_id: ' || p_line_id,2);
     oe_debug_pub.add('p_order_source_id: ' || p_order_source_id,2);
     oe_debug_pub.add('p_orig_sys_document_ref: ' || p_orig_sys_document_ref,2);
     oe_debug_pub.add('p_process_activity: ' || p_process_activity,2);
     oe_debug_pub.add('p_sold_to_org_id: ' || p_sold_to_org_id,2);
     oe_debug_pub.add('p_status_code: ' || p_status_code,2);
     oe_debug_pub.add('p_request_id: ' || p_request_id,2);

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;


    l_stmt := 'Select transaction_id from oe_processing_msgs Where 1 = 1';


    IF p_request_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  request_id = :request_id';
    END IF;
    IF p_entity_code IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  entity_code = :entity_code';
    END IF;
    IF p_entity_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  entity_id = :entity_id';
    END IF;
    IF p_header_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  header_id = :header_id';
    END IF;
    IF p_line_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  line_id = :line_id';
    END IF;
    IF p_order_source_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  order_source_id = :order_source_id';
    END IF;
    IF p_orig_sys_document_ref IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  original_sys_document_ref = :orig_sys_document_ref';
    END IF;
    IF p_orig_sys_document_line_ref IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  original_sys_document_line_ref = :orig_sys_document_line_ref';
    END IF;
    IF p_orig_sys_shipment_ref IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  orig_sys_shipment_ref = :orig_sys_shipment_ref';
    END IF;
    IF p_change_sequence IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  change_sequence = :change_sequence';
    END IF;
    IF p_source_document_type_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  source_document_type_id = :source_document_type_id';
    END IF;
    IF p_source_document_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  source_document_id = :source_document_id';
    END IF;
    IF p_source_document_line_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  source_document_line_id = :source_document_line_id';
    END IF;
    IF p_attribute_code IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  attribute_code = :attribute_code';
    END IF;
    IF p_constraint_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  constraint_id = :constraint_id';
    END IF;
    IF p_process_activity IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  process_activity = :process_activity';
    END IF;
    IF p_sold_to_org_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  sold_to_org_id = :sold_to_org_id';
    END IF;
    IF p_org_id IS NOT NULL THEN
         l_stmt := l_stmt ||' AND  org_id = :org_id';
    END IF;

    DBMS_SQL.PARSE(l_cursor_id,l_stmt,DBMS_SQL.NATIVE);


    IF p_request_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':request_id',p_request_id);
    END IF;
    IF p_entity_code IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':entity_code',p_entity_code);
    END IF;
    IF p_entity_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':entity_id',p_entity_id);
    END IF;
    IF p_header_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':header_id',p_header_id);
    END IF;
    IF p_line_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':line_id',p_line_id);
    END IF;
    IF p_order_source_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':order_source_id',p_order_source_id);
    END IF;
    IF p_orig_sys_document_ref IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':orig_sys_document_ref',p_orig_sys_document_ref);
    END IF;
    IF p_orig_sys_document_line_ref IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':orig_sys_document_line_ref',p_orig_sys_document_line_ref);
    END IF;
    IF p_orig_sys_shipment_ref IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':orig_sys_shipment_ref',p_orig_sys_shipment_ref);
    END IF;
    IF p_change_sequence IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':change_sequence',p_change_sequence);
    END IF;
    IF p_source_document_type_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':source_document_type_id',p_source_document_type_id);
    END IF;
    IF p_source_document_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':source_document_id',p_source_document_id);
    END IF;
    IF p_source_document_line_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':source_document_line_id',p_source_document_line_id);
    END IF;
    IF p_attribute_code IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':attribute_code',p_attribute_code);
    END IF;
    IF p_constraint_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':constraint_id',p_constraint_id);
    END IF;
    IF p_process_activity IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':process_activity',p_process_activity);
    END IF;
    IF p_sold_to_org_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':sold_to_org_id',p_sold_to_org_id);
    END IF;
    IF p_org_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':org_id',p_org_id);
    END IF;


   DBMS_SQL.DEFINE_COLUMN(l_cursor_id,1,l_transaction_id);

   l_retval := DBMS_SQL.EXECUTE(l_cursor_id);

   LOOP
      IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
        EXIT;
      END IF;
      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_transaction_id);


      Update oe_processing_msgs
      Set    message_status_code = p_status_code
      Where  transaction_id = l_transaction_id;

   END LOOP;
   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Error in Procedure Update_status_code ' || sqlerrm);
   END IF;
End Update_status_code;

--Bug 8514085 Starts
PROCEDURE Add_Msgs_To_CopyMsgTbl
IS
l_msg_tbl msg_tbl_type;
BEGIN
  Get_msg_tbl(l_msg_tbl);
  G_msg_tbl_Copy   := l_msg_tbl;
END Add_Msgs_To_CopyMsgTbl;

PROCEDURE Add_Msgs_From_CopyMsgTbl
IS
BEGIN
  Populate_Msg_tbl(G_msg_tbl_copy);
  G_msg_tbl_Copy.DELETE;
  G_msg_timer_created      := FALSE;
  G_msg_init_with_timer    := FALSE;
END Add_Msgs_From_CopyMsgTbl;

PROCEDURE Set_Msg_Timer_Created(p_msg_timer_created IN BOOLEAN)
IS
BEGIN
   G_msg_timer_created := p_msg_timer_created;
END Set_Msg_Timer_Created;

FUNCTION Get_Msg_Init_with_timer
RETURN BOOLEAN
IS
BEGIN
   RETURN G_msg_init_with_timer;
END Get_Msg_Init_with_timer;
--Bug 8514085 Ends

END OE_MSG_PUB ;

/
