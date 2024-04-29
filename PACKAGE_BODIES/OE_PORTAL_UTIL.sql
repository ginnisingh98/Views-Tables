--------------------------------------------------------
--  DDL for Package Body OE_PORTAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PORTAL_UTIL" AS
/* $Header: OEXUPORB.pls 120.0 2005/05/31 23:18:16 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Portal_Util';


PROCEDURE get_values
(   p_header_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   x_header_val_rec_type         OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Val_Rec_Type
)
IS
BEGIN
  x_header_val_rec_type := OE_HEADER_UTIL.get_values
    ( p_header_rec      =>p_header_rec,
      p_old_header_rec  =>p_old_header_rec );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'get_values'
			);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_values;


PROCEDURE lines
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_line_tbl                    IN  OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type
,   p_return_status                 OUT NOCOPY VARCHAR2
)
IS
   l_return_status         VARCHAR2(1);
   l_old_line_tbl        OE_ORDER_PUB.Line_Tbl_Type;

BEGIN
   oe_debug_pub.add('entering oe_portal_util.lines', 1);
   if p_x_line_tbl(1).operation = OE_GLOBALS.G_OPR_CREATE THEN
   	l_old_line_tbl    :=OE_Order_PUB.G_MISS_LINE_TBL;
   elsif p_x_line_tbl(1).operation = OE_GLOBALS.G_OPR_UPDATE THEN
        oe_oe_form_line.Get_line
        (	p_db_record 		=> TRUE
	,       p_line_id 		=> p_x_line_tbl(1).line_id
	,       x_line_rec		=> l_old_line_tbl(1)
	);
    l_old_line_tbl(1).transaction_phase_code := 'F';
    p_x_line_tbl(1).transaction_phase_code := 'F';
    end if;



   OE_ORDER_PVT.lines
 (  p_init_msg_list      =>  p_init_msg_list
,   p_validation_level   =>  p_validation_level
,   p_control_rec        =>  p_control_rec
,   p_x_line_tbl         =>  p_x_line_tbl
,   p_x_old_line_tbl     =>  l_old_line_tbl
,   x_return_status      =>  l_return_status);

 p_return_status := l_return_status;


EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'lines'
			);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END lines;

PROCEDURE set_header_cache
(   p_header_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
)
IS
   l_return_status         VARCHAR2(1);
   l_ak_header_rec   OE_AK_ORDER_HEADERS_V%rowtype;
BEGIN
  oe_header_util.api_rec_to_rowtype_rec(p_header_rec,l_ak_header_rec);

  ONT_HEADER_DEF_UTIL.g_cached_record := l_ak_header_rec;

 IF p_header_rec.order_type_id IS NOT NULL THEN
  select default_inbound_line_type_id,
         default_outbound_line_type_id
  into   ONT_HEADER_Def_Util.g_cached_record.default_inbound_line_type_id,
         ONT_HEADER_Def_Util.g_cached_record.default_outbound_line_type_id
  from oe_order_types_v
  where order_type_id=p_header_rec.order_type_id;

 END IF;

  OE_DEBUG_PUB.ADD('In OE_PORTAL_UTIL.Set_header_cache, default_outbound_line_type_id =' || ONT_HEADER_DEF_UTIL.g_cached_record.Default_Outbound_Line_Type_Id);

  OE_ORDER_CACHE.g_header_rec := p_header_rec;
  OE_GLOBALS.G_HTML_FLAG := TRUE;



END set_header_cache;


PROCEDURE process_requests_and_notify
(   p_return_status                 OUT NOCOPY VARCHAR2
 )
IS
   l_return_status         VARCHAR2(1);

BEGIN
  Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => TRUE
    ,   p_init_msg_list               => FND_API.G_TRUE
     ,  p_notify                     => FALSE
     ,  x_return_status              => l_return_status
    );

  p_return_status := l_return_status;
 OE_GLOBALS.G_RECURSION_MODE :='N';

END process_requests_and_notify;

PROCEDURE get_header
    (
     p_header_id IN NUMBER,
     x_header_rec                    OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.HEADER_Rec_Type
    )
IS
BEGIN

   OE_Header_Util.Query_Row
            (   p_header_id                   => p_header_id
            ,   x_header_rec                  => x_header_rec
            );

END get_header;

PROCEDURE get_line
    (
     p_line_id IN NUMBER,
     x_line_rec                    OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Rec_Type
    )
IS
BEGIN
   OE_Line_Util.Query_Row
            (   p_line_id                 => p_line_id
            ,   x_line_rec                  => x_line_rec
            );

END get_line;

END OE_Portal_Util;

/
