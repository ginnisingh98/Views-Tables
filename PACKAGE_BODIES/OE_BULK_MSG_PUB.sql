--------------------------------------------------------
--  DDL for Package Body OE_BULK_MSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_MSG_PUB" AS
/* $Header: OEBUMSGB.pls 120.0 2005/06/01 01:55:40 appldev noship $ */


G_PKG_NAME	CONSTANT    VARCHAR2(30):=  'OE_BULK_MSG_PUB';

PROCEDURE Extend
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    g_msg_tbl.MESSAGE.EXTEND;
    g_msg_tbl.ENTITY_CODE.EXTEND;
    g_msg_tbl.ENTITY_ID.EXTEND;
    g_msg_tbl.HEADER_ID.EXTEND;
    g_msg_tbl.LINE_ID.EXTEND;
    g_msg_tbl.ORDER_SOURCE_ID.EXTEND;
    g_msg_tbl.ORIG_SYS_DOCUMENT_REF.EXTEND;
    g_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF.EXTEND;
    g_msg_tbl.SOURCE_DOCUMENT_TYPE_ID.EXTEND;
    g_msg_tbl.SOURCE_DOCUMENT_ID.EXTEND;
    g_msg_tbl.SOURCE_DOCUMENT_LINE_ID.EXTEND;
    g_msg_tbl.ATTRIBUTE_CODE.EXTEND;
    g_msg_tbl.CONSTRAINT_ID.EXTEND;
    g_msg_tbl.PROCESS_ACTIVITY.EXTEND;
    g_msg_tbl.NOTIFICATION_FLAG.EXTEND;
    g_msg_tbl.MESSAGE_TEXT.EXTEND;
    g_msg_tbl.TYPE.EXTEND;
    g_msg_tbl.ENTITY_REF.EXTEND;
    g_msg_tbl.ORIG_SYS_SHIPMENT_REF.EXTEND;
    g_msg_tbl.CHANGE_SEQUENCE.EXTEND;

END Extend;

PROCEDURE Delete_tbl(p_count NUMBER := NULL)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF p_count IS NULL THEN
        g_msg_tbl.MESSAGE.DELETE;
        g_msg_tbl.ENTITY_CODE.DELETE;
        g_msg_tbl.ENTITY_ID.DELETE;
        g_msg_tbl.HEADER_ID.DELETE;
        g_msg_tbl.LINE_ID.DELETE;
        g_msg_tbl.ORDER_SOURCE_ID.DELETE;
        g_msg_tbl.ORIG_SYS_DOCUMENT_REF.DELETE;
        g_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF.DELETE;
        g_msg_tbl.SOURCE_DOCUMENT_TYPE_ID.DELETE;
        g_msg_tbl.SOURCE_DOCUMENT_ID.DELETE;
        g_msg_tbl.SOURCE_DOCUMENT_LINE_ID.DELETE;
        g_msg_tbl.ATTRIBUTE_CODE.DELETE;
        g_msg_tbl.CONSTRAINT_ID.DELETE;
        g_msg_tbl.PROCESS_ACTIVITY.DELETE;
        g_msg_tbl.NOTIFICATION_FLAG.DELETE;
        g_msg_tbl.MESSAGE_TEXT.DELETE;
        g_msg_tbl.TYPE.DELETE;
        g_msg_tbl.ENTITY_REF.DELETE;
        g_msg_tbl.ORIG_SYS_SHIPMENT_REF.DELETE;
        g_msg_tbl.CHANGE_SEQUENCE.DELETE;
    ELSE
        g_msg_tbl.MESSAGE.DELETE(p_count);
        g_msg_tbl.ENTITY_CODE.DELETE(p_count);
        g_msg_tbl.ENTITY_ID.DELETE(p_count);
        g_msg_tbl.HEADER_ID.DELETE(p_count);
        g_msg_tbl.LINE_ID.DELETE(p_count);
        g_msg_tbl.ORDER_SOURCE_ID.DELETE(p_count);
        g_msg_tbl.ORIG_SYS_DOCUMENT_REF.DELETE(p_count);
        g_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF.DELETE(p_count);
        g_msg_tbl.SOURCE_DOCUMENT_TYPE_ID.DELETE(p_count);
        g_msg_tbl.SOURCE_DOCUMENT_ID.DELETE(p_count);
        g_msg_tbl.SOURCE_DOCUMENT_LINE_ID.DELETE(p_count);
        g_msg_tbl.ATTRIBUTE_CODE.DELETE(p_count);
        g_msg_tbl.CONSTRAINT_ID.DELETE(p_count);
        g_msg_tbl.PROCESS_ACTIVITY.DELETE(p_count);
        g_msg_tbl.NOTIFICATION_FLAG.DELETE(p_count);
        g_msg_tbl.MESSAGE_TEXT.DELETE(p_count);
        g_msg_tbl.TYPE.DELETE(p_count);
        g_msg_tbl.ENTITY_REF.DELETE(p_count);
        g_msg_tbl.ORIG_SYS_SHIPMENT_REF.DELETE(p_count);
        g_msg_tbl.CHANGE_SEQUENCE.DELETE(p_count);
    END IF;
END Delete_tbl;

PROCEDURE Initialize
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

FND_MSG_PUB.Initialize;

IF g_msg_tbl.MESSAGE IS NOT NULL THEN
   Delete_tbl(p_count => NULL);
END IF;

g_msg_tbl.MESSAGE := T_TBL_V2000();
g_msg_tbl.ENTITY_CODE := T_TBL_V30();
g_msg_tbl.ENTITY_ID := T_TBL_NUM();
g_msg_tbl.HEADER_ID := T_TBL_NUM();
g_msg_tbl.LINE_ID := T_TBL_NUM();
g_msg_tbl.ORDER_SOURCE_ID := T_TBL_NUM();
g_msg_tbl.ORIG_SYS_DOCUMENT_REF := T_TBL_V50();
g_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF := T_TBL_V50();
g_msg_tbl.SOURCE_DOCUMENT_TYPE_ID := T_TBL_NUM();
g_msg_tbl.SOURCE_DOCUMENT_ID := T_TBL_NUM();
g_msg_tbl.SOURCE_DOCUMENT_LINE_ID := T_TBL_NUM();
g_msg_tbl.ATTRIBUTE_CODE := T_TBL_V30();
g_msg_tbl.CONSTRAINT_ID := T_TBL_NUM();
g_msg_tbl.PROCESS_ACTIVITY := T_TBL_NUM();
g_msg_tbl.NOTIFICATION_FLAG := T_TBL_V1();
g_msg_tbl.MESSAGE_TEXT := T_TBL_V2000();
g_msg_tbl.TYPE := T_TBL_V30();
g_msg_tbl.ENTITY_REF := T_TBL_V50();
g_msg_tbl.ORIG_SYS_SHIPMENT_REF := T_TBL_V50();
g_msg_tbl.CHANGE_SEQUENCE := T_TBL_V50();

G_msg_count := 0;
G_msg_index := 0;
G_msg_context_tbl.DELETE;
G_msg_context_count := 0;
G_Msg_Context_index := 0;

END;

PROCEDURE Set_Process_Activity(
     p_process_activity IN NUMBER DEFAULT NULL)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    G_process_activity := p_process_activity;

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
  )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     G_msg_context_count := G_msg_context_count + 1;

     G_msg_context_tbl(G_msg_context_count).ENTITY_CODE :=  p_entity_code;
     G_msg_context_tbl(G_msg_context_count).ENTITY_ID :=  p_entity_id;
     G_msg_context_tbl(G_msg_context_count).ENTITY_REF :=  p_entity_ref;
     G_msg_context_tbl(G_msg_context_count).HEADER_ID :=  p_header_id;
     G_msg_context_tbl(G_msg_context_count).LINE_ID :=  p_line_Id;
     G_msg_context_tbl(G_msg_context_count).ORDER_SOURCE_ID := p_order_source_id;
     G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF :=  p_orig_sys_document_ref;
     G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF := p_orig_sys_document_line_ref;
     G_msg_context_tbl(G_msg_context_count).ORIG_SYS_SHIPMENT_REF := p_orig_sys_shipment_ref;
     G_msg_context_tbl(G_msg_context_count).CHANGE_SEQUENCE := p_change_sequence;
     G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_TYPE_ID := p_source_document_type_id;
     G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID := p_source_document_id;
     G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID := p_source_document_line_id;
     G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE := p_attribute_code;
     G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID := p_constraint_id;
     G_msg_context_tbl(G_msg_context_count).PROCESS_ACTIVITY := G_process_activity;

END;

PROCEDURE Update_Msg_Context (
     p_entity_code                    IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_entity_id                      IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_header_id                      IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_line_id                        IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_order_source_id                IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_orig_sys_document_ref          IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_orig_sys_document_line_ref     IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_source_document_type_id        IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_source_document_id             IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_source_document_line_id        IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_attribute_code                 IN  VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_constraint_id                  IN  NUMBER    DEFAULT FND_API.G_MISS_NUM
  ) IS
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin

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
END Reset_Msg_Context;

FUNCTION    Count_Msg 	RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN G_msg_Count;

END Count_Msg;

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

END Count_And_Get;


PROCEDURE Add(p_context_flag IN VARCHAR2 DEFAULT 'Y',
              p_msg_type IN VARCHAR2 DEFAULT NULL)
IS
l_type         VARCHAR2(30);
l_app_id       VARCHAR2(30);
l_message_name VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF p_msg_type IS NOT NULL THEN
     l_type := p_msg_type;
  END IF;
  G_msg_count := G_msg_count + 1;
  Extend;

  G_msg_tbl.Message(G_msg_count) := FND_MESSAGE.GET_ENCODED;

  IF p_context_flag = 'Y' THEN

    BEGIN

      fnd_message.parse_encoded(G_msg_tbl.Message(G_msg_count),
						  l_app_id,
						  l_message_name);

      IF l_type IS NULL THEN
         Select type
         Into   l_type
	    from   fnd_new_messages a,
		      fnd_application  b
	    where a.application_id = b.application_id
	    and   a.language_code = USERENV('LANG')
	    and   a.message_name = l_message_name
	    and   b.application_short_name = l_app_id;
      END IF;

     EXCEPTION

      WHEN OTHERS THEN

       l_type := 'ERROR';

     END;

  END IF;

    IF G_msg_context_tbl.COUNT >0 THEN

      G_msg_tbl.ENTITY_CODE(G_msg_count) := G_msg_context_tbl(G_msg_context_count).ENTITY_CODE;
      G_msg_tbl.ENTITY_ID(G_msg_count):= G_msg_context_tbl(G_msg_context_count).ENTITY_ID;
      G_msg_tbl.HEADER_ID(G_msg_count):= G_msg_context_tbl(G_msg_context_count).HEADER_ID;
      G_msg_tbl.LINE_ID(G_msg_count):= G_msg_context_tbl(G_msg_context_count).LINE_ID;
      G_msg_tbl.ORDER_SOURCE_ID(G_msg_count):= G_msg_context_tbl(G_msg_context_count).ORDER_SOURCE_ID;
      G_msg_tbl.ORIG_SYS_DOCUMENT_REF(G_msg_count):= G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF;
      G_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF(G_msg_count):= G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF;
      G_msg_tbl.SOURCE_DOCUMENT_TYPE_ID(G_msg_count):= G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_TYPE_ID;
      G_msg_tbl.SOURCE_DOCUMENT_ID(G_msg_count):= G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID;
      G_msg_tbl.SOURCE_DOCUMENT_LINE_ID(G_msg_count):= G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID;
      G_msg_tbl.ATTRIBUTE_CODE(G_msg_count):= G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE;
      G_msg_tbl.CONSTRAINT_ID(G_msg_count):= G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID;
      G_msg_tbl.PROCESS_ACTIVITY(G_msg_count):= G_msg_context_tbl(G_msg_context_count).PROCESS_ACTIVITY;
      G_msg_tbl.TYPE(G_msg_count) := l_type;
      G_msg_tbl.message(G_msg_count) := Get(G_msg_count, 'F');

    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO CONTEXT , ADD TO MSG TBL' ) ;
      END IF;
      G_msg_tbl.ENTITY_CODE(G_msg_count) := NULL;
      G_msg_tbl.ENTITY_ID(G_msg_count) 	:= NULL;
      G_msg_tbl.HEADER_ID(G_msg_count)	:= NULL;
      G_msg_tbl.LINE_ID(G_msg_count) 	:= NULL;
      G_msg_tbl.ORDER_SOURCE_ID(G_msg_count) := NULL;
      G_msg_tbl.ORIG_SYS_DOCUMENT_REF(G_msg_count) := NULL;
      G_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF(G_msg_count) := NULL;
      G_msg_tbl.SOURCE_DOCUMENT_TYPE_ID(G_msg_count) := NULL;
      G_msg_tbl.SOURCE_DOCUMENT_ID(G_msg_count) := NULL;
      G_msg_tbl.SOURCE_DOCUMENT_LINE_ID(G_msg_count) := NULL;
      G_msg_tbl.ATTRIBUTE_CODE(G_msg_count) := NULL;
      G_msg_tbl.CONSTRAINT_ID(G_msg_count) := NULL;
      G_msg_tbl.PROCESS_ACTIVITY(G_msg_count) := NULL;
      G_msg_tbl.TYPE(G_msg_count) := l_type;
      G_msg_tbl.message(G_msg_count) := Get(G_msg_count, 'F');
    END IF;

END Add;

PROCEDURE Add_Text(p_message_text IN VARCHAR2
              ,p_type IN VARCHAR2 DEFAULT 'ERROR'
              ,p_context_flag IN VARCHAR2 DEFAULT 'Y')
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    G_msg_count := G_msg_count + 1;
    extend;
    G_msg_tbl.Message_text(G_msg_count) := p_message_text;

    IF p_context_flag = 'Y' AND G_msg_context_count > 0 then
      G_msg_tbl.ENTITY_CODE(G_msg_count) := G_msg_context_tbl(G_msg_context_count).ENTITY_CODE;
      G_msg_tbl.ENTITY_ID(G_msg_count) 	 := G_msg_context_tbl(G_msg_context_count).ENTITY_ID;
      G_msg_tbl.HEADER_ID(G_msg_count)	 := G_msg_context_tbl(G_msg_context_count).HEADER_ID;
      G_msg_tbl.LINE_ID(G_msg_count) 	 := G_msg_context_tbl(G_msg_context_count).LINE_ID;
      G_msg_tbl.ORDER_SOURCE_ID(G_msg_count) 	 := G_msg_context_tbl(G_msg_context_count).ORDER_SOURCE_ID;
      G_msg_tbl.ORIG_SYS_DOCUMENT_REF(G_msg_count) := G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_REF;
      G_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF(G_msg_count) := G_msg_context_tbl(G_msg_context_count).ORIG_SYS_DOCUMENT_LINE_REF;
      G_msg_tbl.SOURCE_DOCUMENT_TYPE_ID(G_msg_count) := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_TYPE_ID;
      G_msg_tbl.SOURCE_DOCUMENT_ID(G_msg_count) := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_ID;
      G_msg_tbl.SOURCE_DOCUMENT_LINE_ID(G_msg_count) := G_msg_context_tbl(G_msg_context_count).SOURCE_DOCUMENT_LINE_ID;
      G_msg_tbl.ATTRIBUTE_CODE(G_msg_count) := G_msg_context_tbl(G_msg_context_count).ATTRIBUTE_CODE;
      G_msg_tbl.CONSTRAINT_ID(G_msg_count) := G_msg_context_tbl(G_msg_context_count).CONSTRAINT_ID;
      G_msg_tbl.PROCESS_ACTIVITY(G_msg_count) := G_msg_context_tbl(G_msg_context_count).PROCESS_ACTIVITY;
      G_msg_tbl.TYPE(G_msg_count) := p_type;

    ELSE
      G_msg_tbl.ENTITY_CODE(G_msg_count) := NULL;
      G_msg_tbl.ENTITY_ID(G_msg_count) 	:= NULL;
      G_msg_tbl.HEADER_ID(G_msg_count)	:= NULL;
      G_msg_tbl.LINE_ID(G_msg_count) 	:= NULL;
      G_msg_tbl.ORDER_SOURCE_ID(G_msg_count) := NULL;
      G_msg_tbl.ORIG_SYS_DOCUMENT_REF(G_msg_count) := NULL;
      G_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF(G_msg_count) := NULL;
      G_msg_tbl.SOURCE_DOCUMENT_TYPE_ID(G_msg_count) := NULL;
      G_msg_tbl.SOURCE_DOCUMENT_ID(G_msg_count) := NULL;
      G_msg_tbl.SOURCE_DOCUMENT_LINE_ID(G_msg_count) := NULL;
      G_msg_tbl.ATTRIBUTE_CODE(G_msg_count) := NULL;
      G_msg_tbl.CONSTRAINT_ID(G_msg_count) := NULL;
      G_msg_tbl.PROCESS_ACTIVITY(G_msg_count) := NULL;
      G_msg_tbl.TYPE(G_msg_count) := p_type;
    END IF;

END Add_Text;

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

	Delete_tbl(p_count => NULL);
	G_msg_count := 0;
	G_msg_index := 0;

    ELSE

	IF G_msg_tbl.message.EXISTS(p_msg_index) THEN

	    IF p_msg_index <= G_msg_count THEN

		FOR I IN p_msg_index..G_msg_count-1 LOOP

                G_msg_tbl.MESSAGE( I ) := G_msg_tbl.MESSAGE( I + 1 );
                G_msg_tbl.MESSAGE(I) := G_msg_tbl.MESSAGE_TEXT( I + 1 );
      		G_msg_tbl.ENTITY_CODE(I) := G_msg_tbl.ENTITY_CODE( I + 1 );
      		G_msg_tbl.ENTITY_ID(I)   := G_msg_tbl.ENTITY_ID( I + 1 );
      		G_msg_tbl.HEADER_ID(I)   := G_msg_tbl.HEADER_ID( I + 1 );
      		G_msg_tbl.LINE_ID(I) 	   := G_msg_tbl.LINE_ID( I + 1 );
      		G_msg_tbl.ORDER_SOURCE_ID(I) 	   := G_msg_tbl.ORDER_SOURCE_ID( I + 1 );
      		G_msg_tbl.ORIG_SYS_DOCUMENT_REF(I) := G_msg_tbl.ORIG_SYS_DOCUMENT_REF( I + 1 );
      		G_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF(I) := G_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF( I + 1 );
      		G_msg_tbl.SOURCE_DOCUMENT_TYPE_ID(I) := G_msg_tbl.SOURCE_DOCUMENT_TYPE_ID( I + 1 );
      		G_msg_tbl.SOURCE_DOCUMENT_ID(I) := G_msg_tbl.SOURCE_DOCUMENT_ID( I + 1 );
      		G_msg_tbl.SOURCE_DOCUMENT_LINE_ID(I) := G_msg_tbl.SOURCE_DOCUMENT_LINE_ID( I + 1 );
      		G_msg_tbl.ATTRIBUTE_CODE(I) := G_msg_tbl.ATTRIBUTE_CODE( I + 1 );
      		G_msg_tbl.CONSTRAINT_ID(I) := G_msg_tbl.CONSTRAINT_ID( I + 1 );
      		G_msg_tbl.PROCESS_ACTIVITY(I) := G_msg_tbl.PROCESS_ACTIVITY( I + 1 );
      		G_msg_tbl.NOTIFICATION_FLAG(I) := G_msg_tbl.NOTIFICATION_FLAG( I + 1 );
      		G_msg_tbl.TYPE(I) := G_msg_tbl.TYPE( I + 1 );

		END LOOP;


		Delete_tbl(G_msg_count);
		G_msg_count := G_msg_count - 1	;

	    END IF;

	END IF;

    END IF;

END Delete_Msg;

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


    IF G_msg_tbl.Message_Text(G_msg_index) IS NOT NULL THEN

       p_data := G_msg_tbl.Message_Text(G_msg_index);
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ENTERING THE MESSAGE_TEXT NOT NULL' ) ;
       END IF;

    ELSE
      IF FND_API.To_Boolean( p_encoded ) THEN

	    p_data := G_msg_tbl.Message( G_msg_index );
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ENTERING P_ENCODED AS TRUE ' ) ;
       END IF;

      ELSE

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ENTERING P_ENCODED AS FALSE ' ) ;
       END IF;
        FND_MESSAGE.SET_ENCODED ( G_msg_tbl.Message( G_msg_index ));

	   p_data := FND_MESSAGE.GET;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'THE MESSAGE IS '||P_DATA ) ;
       END IF;

	 END IF;
    END IF;

    p_msg_index_out	:=  G_msg_index		    ;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

	G_msg_index := l_msg_index;

	p_data		:=  NULL;
	p_msg_index_out	:=  NULL;

END Get;

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
l_PROCEDURE_name    CONSTANT VARCHAR2(15):='Reset';
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

	OE_BULK_MSG_PUB.Add_Exc_Msg
    	(   p_pkg_name		=>  G_PKG_NAME			,
    	    p_PROCEDURE_name	=>  l_procedure_name		,
    	    p_error_text	=>  'Invalid p_mode: '||p_mode
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

END Reset;

--  FUNCTION 	Check_Msg_Level
--
--  Usage   	Used by API developers to check if the level of the
--  	    	message they want to write to the message table is
--  	    	higher or equal to the message level threshold or not.
--  	    	If the FUNCTION returns TRUE the developer should go
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

END; -- Check_Msg_Level

PROCEDURE Build_Exc_Msg
( p_pkg_name	    IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
  p_PROCEDURE_name  IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
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

    IF p_PROCEDURE_name <> FND_API.G_MISS_CHAR THEN
    	FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',p_procedure_name);
    END IF;

    IF l_error_text <> FND_API.G_MISS_CHAR THEN
    	FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_error_text);
    END IF;

END; -- Build_Exc_Msg

PROCEDURE Add_Exc_Msg
(   p_pkg_name		IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
    p_PROCEDURE_name	IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
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
	p_PROCEDURE_name    ,
	p_error_text
    );
    Add((p_context_flag));
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
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORDER_SOURCE_ID = '||G_MSG_TBL.ORDER_SOURCE_ID ( P_MSG_INDEX ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORIG_SYS_DOC_REF = '||G_MSG_TBL.ORIG_SYS_DOCUMENT_REF ( P_MSG_INDEX ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORIG_SYS_LIN_REF = '||G_MSG_TBL.ORIG_SYS_DOCUMENT_LINE_REF ( P_MSG_INDEX ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOURCE_DOC_TYPE_ID = '||G_MSG_TBL.SOURCE_DOCUMENT_TYPE_ID ( P_MSG_INDEX ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOURCE_DOC_ID = '||G_MSG_TBL.SOURCE_DOCUMENT_ID ( P_MSG_INDEX ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOURCE_LIN_ID = '||G_MSG_TBL.SOURCE_DOCUMENT_LINE_ID ( P_MSG_INDEX ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ATTRIBUTE_CODE = '||G_MSG_TBL.ATTRIBUTE_CODE ( P_MSG_INDEX ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CONSTRAINT_ID = '||G_MSG_TBL.CONSTRAINT_ID ( P_MSG_INDEX ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS_ACTIVITY = '||G_MSG_TBL.PROCESS_ACTIVITY ( P_MSG_INDEX ) ) ;
    END IF;
    OE_DEBUG_PUB.dumpdebug;
    OE_DEBUG_PUB.debug_off;
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
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'G_MSG_TBL.MESSAGE.COUNT = '||G_MSG_TBL.MESSAGE.COUNT ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'G_MSG_COUNT = '||G_MSG_COUNT ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'G_MSG_INDEX = '||G_MSG_INDEX ) ;
    END IF;
    OE_DEBUG_PUB.dumpdebug;
    OE_DEBUG_PUB.debug_off;

    IF p_messages THEN

	FOR I IN 1..G_msg_tbl.Message.COUNT LOOP

	    dump_Msg (I);

	END LOOP;

    END IF;

END Dump_List;


--  PROCEDURE	save_messages
--
--  Usage   	Used by API developers to save messages in database.
--		This PROCEDURE is used to save massages which were created by
--              batch programs.
--
--  Desc	Accepts request_id as input and assign the same to all
--              messages.
--
--
--  Parameters	p_request_id	IN NUMBER.

PROCEDURE save_messages(p_request_id     IN NUMBER
                        ,p_message_source_code IN VARCHAR2 DEFAULT 'C')
IS
l_count_msg NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER SAVE_MESSAGES' , 1 ) ;
   END IF;
   l_count_msg := G_msg_tbl.ENTITY_ID.COUNT;

   FORALL i IN 1..l_count_msg
   INSERT INTO OE_PROCESSING_MSGS
   (
      TRANSACTION_ID
   ,  REQUEST_ID
   ,  ENTITY_CODE
   ,  ENTITY_ID
   ,  HEADER_ID
   ,  LINE_ID
   ,  ORIGINAL_SYS_DOCUMENT_REF
   ,  ORIGINAL_SYS_DOCUMENT_LINE_REF
   ,  SOURCE_DOCUMENT_ID
   ,  SOURCE_DOCUMENT_LINE_ID
   ,  ORDER_SOURCE_ID
   ,  SOURCE_DOCUMENT_TYPE_ID
   ,  ATTRIBUTE_CODE
   ,  PROGRAM_UPDATE_DATE
   ,  PROGRAM_APPLICATION_ID
   ,  PROGRAM_ID
   ,  LAST_UPDATE_LOGIN
   ,  LAST_UPDATED_BY
   ,  LAST_UPDATE_DATE
   ,  CREATED_BY
   ,  CREATION_DATE
   ,  CONSTRAINT_ID
   ,  PROCESS_ACTIVITY
   ,  NOTIFICATION_FLAG
   ,  ENTITY_REF
   ,  CHANGE_SEQUENCE
   ,  ORIG_SYS_SHIPMENT_REF
   ,  TYPE
   ,  MESSAGE_SOURCE_CODE
   ,  LANGUAGE
   ,  MESSAGE_TEXT
   )
   VALUES
   (
      OE_MSG_ID_S.NEXTVAL
   ,  p_request_id
   ,  G_msg_tbl.ENTITY_CODE(i)
   ,  G_msg_tbl.ENTITY_ID(i)
   ,  G_msg_tbl.HEADER_ID(i)
   ,  G_msg_tbl.LINE_ID(i)
   ,  G_msg_tbl.ORIG_SYS_DOCUMENT_REF(i)
   ,  G_msg_tbl.ORIG_SYS_DOCUMENT_LINE_REF(i)
   ,  G_msg_tbl.SOURCE_DOCUMENT_ID(i)
   ,  G_msg_tbl.SOURCE_DOCUMENT_LINE_ID(i)
   ,  G_msg_tbl.ORDER_SOURCE_ID(i)
   ,  G_msg_tbl.SOURCE_DOCUMENT_TYPE_ID(i)
   ,  G_msg_tbl.ATTRIBUTE_CODE(i)
   ,  NULL
   ,  660
   ,  NULL
   ,  FND_GLOBAL.USER_ID
   ,  FND_GLOBAL.USER_ID
   ,  sysdate
   ,  FND_GLOBAL.USER_ID
   ,  sysdate
   ,  G_msg_tbl.CONSTRAINT_ID(i)
   ,  G_msg_tbl.PROCESS_ACTIVITY(i)
   ,  G_msg_tbl.NOTIFICATION_FLAG(i)
   ,  G_msg_tbl.ENTITY_REF(i)
   ,  G_msg_tbl.change_sequence(i)
   ,  G_msg_tbl.ORIG_SYS_SHIPMENT_REF(i)
   ,  G_msg_tbl.TYPE(i)
   ,  'C'
   ,  USERENV('LANG')
   ,  G_msg_tbl.message(i)
   );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXIT SAVE_MESSAGES' , 1 ) ;
   END IF;
   OE_BULK_MSG_PUB.initialize;

EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OTHERS ERROR , SAVE_MESSAGES' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
     END IF;
end;


--  PROCEDURE	Get_msg_tbl
--
--  Usage   	Used by process messages form to retreive messages from stack .
--
--  Desc	This PROCEDURE returns message_table to the caller.
--              This PROCEDURE also resolvs message text before returning
--              message table to the caller.
--
--
PROCEDURE Get_msg_tbl(x_msg_tbl IN OUT NOCOPY /* file.sql.39 change */ G_MSG_REC_TYPE)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   FOR i IN G_msg_tbl.Message.FIRST .. G_msg_tbl.Message.LAST LOOP


    IF G_msg_tbl.message_text(i) IS NOT NULL THEN

       x_msg_tbl.message(i) := G_msg_tbl.message_text(i);

    ELSE

       x_msg_tbl.message(i) := GET(i,'F');

    END IF;

    x_msg_tbl.entity_code(i) := G_msg_tbl.entity_code(i);
    x_msg_tbl.entity_id(i) := G_msg_tbl.entity_id(i);
    x_msg_tbl.header_id(i) := G_msg_tbl.header_id(i);
    x_msg_tbl.line_id(i) := G_msg_tbl.line_id(i);
    x_msg_tbl.order_source_id(i) := G_msg_tbl.order_source_id(i);
    x_msg_tbl.orig_sys_document_ref(i) := G_msg_tbl.orig_sys_document_ref(i);
    x_msg_tbl.orig_sys_document_line_ref(i) := G_msg_tbl.orig_sys_document_line_ref(i);
    x_msg_tbl.source_document_type_id(i) := G_msg_tbl.source_document_type_id(i);
    x_msg_tbl.source_document_id(i) := G_msg_tbl.source_document_id(i);
    x_msg_tbl.source_document_line_id(i) := G_msg_tbl.source_document_line_id(i);
    x_msg_tbl.attribute_code(i) := G_msg_tbl.attribute_code(i);
    x_msg_tbl.constraint_id(i) := G_msg_tbl.constraint_id(i);
    x_msg_tbl.process_activity(i) := G_msg_tbl.process_activity(i);
    x_msg_tbl.notification_flag(i) := G_msg_tbl.notification_flag(i);
    x_msg_tbl.message_text(i) := null;
    x_msg_tbl.type(i) := G_msg_tbl.type(i);


   END LOOP;


END;


PROCEDURE Transfer_Msg_Stack
( p_msg_index IN  NUMBER	DEFAULT  NULL
)
IS
l_count NUMBER;
l_message VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF p_msg_index IS NOT NULL THEN

	l_message := fnd_msg_pub.get(p_msg_index,'F');
     add_text(l_message);

  ELSE

	l_count := fnd_msg_pub.count_msg;

	FOR i in 1..l_count LOOP

	  l_message := fnd_msg_pub.get(i,'F');
       add_text(l_message);


	END LOOP;

  END IF; -- p_msg_index

END Transfer_Msg_Stack;

END OE_BULK_MSG_PUB ;

/
