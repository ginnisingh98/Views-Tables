--------------------------------------------------------
--  DDL for Package Body OE_PORTAL_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PORTAL_ORDER" AS
/* $Header: OEXPOBKB.pls 120.0 2005/06/01 00:01:18 appldev noship $ */
--  Procedure      Submit_Order
--


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Portal_Order';

PROCEDURE Submit_Order
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_book_flag                     IN VARCHAR2 := 'N'
)
IS
l_atp_tbl                   OE_ATP.Atp_Tbl_Type;
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_line_tbl                    OE_ORDER_PUB.LINE_TBL_TYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER.PROCESS_OBJECT' , 1 ) ;
    END IF;
/* For submitted orders, first schedule the order*/
    if p_book_flag = 'Y' Then
		OE_GRP_SCH_UTIL.Schedule_Order
	   (p_header_id      => p_header_id,
	    p_sch_action     => OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE,
         p_entity_type    => 'ORDER',
	    p_line_id        => '',
	    x_atp_tbl        => l_atp_tbl,
	    x_return_status  => l_return_status,
	    x_msg_count      => x_msg_count,
	    x_msg_data       => x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;



    -- we are using this flag to selectively requery the block,
    -- if any of the delayed req. get executed changing rows.
    -- currently all the work done in post line process will
    -- eventually set the global cascading flag to TRUE.
    -- if some one adds code to post lines, whcih does not
    -- set cascadinf flga to TURE and still modifes records,
    -- that will be incorrect.
    -- this flag helps to requery the block if any thing changed
    -- after validate and write.

    OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := TRUE;

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_ALL;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    oe_line_util.Post_Line_Process
    (   p_control_rec    => l_control_rec
    ,   p_x_line_tbl   => l_line_tbl );

    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => TRUE
    ,   p_init_msg_list               => FND_API.G_TRUE
     ,  p_notify                     => TRUE
     ,  x_return_status              => l_return_status
    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

--    x_cascade_flag := OE_GLOBALS.G_CASCADING_REQUEST_LOGGED;
    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    OE_GLOBALS.G_UI_FLAG := FALSE;
    OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;

    IF (p_book_flag = 'Y') Then
	 -- Progress the workflow so that booking process is kicked off.
	 -- This call should come back with a message OE_ORDER_BOOKED
	 -- if booking completed successfully and if booking was deferred,
	 -- message OE_ORDER_BOOK_DEFERRED is added to the stack.
	 -- If booking was not successful, it should come back with a
	 -- return status of FND_API.G_RET_STS_ERROR or
	 -- FND_API.G_RET_STS_UNEXP_ERROR
	 OE_Order_Book_Util.Complete_Book_Eligible
			( p_api_version_number	=> 1.0
			, p_init_msg_list		=> FND_API.G_TRUE
			, p_header_id			=> p_header_id
			, x_return_status		=> l_return_status
			, x_msg_count			=> x_msg_count
			, x_msg_data			=> x_msg_data);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

 /*   --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );*/
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER.PROCESS_OBJECT' , 1 ) ;
    END IF;


commit;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Object'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END;

END Oe_Portal_Order;

/
