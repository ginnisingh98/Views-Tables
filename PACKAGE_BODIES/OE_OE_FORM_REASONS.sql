--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_REASONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_REASONS" AS
/* $Header: OEXFREAB.pls 120.0 2005/06/01 02:38:00 appldev noship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Oe_Form_Header';

PROCEDURE Apply_Reason(
                          p_reason_type    IN VARCHAR2
                        , p_reason_code    IN VARCHAR2
                        , p_comments       IN VARCHAR2
                        , p_entity_id      IN NUMBER
                        , p_version_number IN NUMBER
                        , p_entity_code    IN VARCHAR2
                        , x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                        , x_msg_count OUT NOCOPY NUMBER
                        , x_msg_data OUT NOCOPY VARCHAR2
                      )

IS
l_reason_id Number;
BEGIN
    oe_debug_pub.add('Entering Apply Reason');
    OE_MSG_PUB.initialize;
  IF p_reason_type IN ('OFFER_LOST','OFFER_LOST_REASON') THEN
    OE_NEGOTIATE_WF.Lost
                    (
                     p_header_id =>p_entity_id,
                     p_entity_code=>p_entity_code,
                     p_version_number=>p_version_number,
                     p_reason_type =>p_reason_type,
                     p_reason_code =>p_reason_code,
                     p_reason_comments=>p_comments ,
                     x_return_status => x_return_status
                     );
  ELSIF p_reason_type IN ('CUSTOMER_REJECTION','CUSTOMER_REJECTION_REASON') THEN
    oe_debug_pub.add('Enter Customer Rejection');
    oe_debug_pub.add('Enter Customer Rejection'||p_entity_id);
    oe_debug_pub.add('Enter Customer Rejection'||p_entity_code);
    oe_debug_pub.add('Enter Customer Rejection'||p_version_number);
    oe_debug_pub.add('Enter Customer Rejection'||p_reason_type);
    OE_NEGOTIATE_WF.Customer_Rejected
                    (
                     p_header_id =>p_entity_id,
                     p_entity_code=>p_entity_code,
                     p_version_number=>p_version_number,
                     p_reason_type =>p_reason_type,
                     p_reason_code =>p_reason_code,
                     p_reason_comments=>p_comments ,
                     x_return_status => x_return_status
                     );
    oe_debug_pub.add('Exit Customer Rejection');

  ELSIF p_reason_type='CONTRACT_TERMINATION' THEN
   OE_BLANKET_WF.Terminate(p_header_id => p_entity_id,
                             p_terminated_by => nvl(FND_GLOBAL.USER_ID,-1),
                             p_version_number => p_version_number,
                             p_reason_type => p_reason_type,
                             p_reason_code => p_reason_code,
                             p_reason_comments => p_comments,
                             x_return_status => x_return_status);
  ELSE
    OE_REASONS_UTIL.Apply_Reason
                     (
                      p_entity_code=>p_entity_code,
                      p_entity_id =>p_entity_id,
                      p_version_number =>p_version_number,
                      p_reason_type =>p_reason_type,
                      p_reason_code =>p_reason_code,
                      p_reason_comments =>p_comments,
                      x_reason_id =>l_reason_id,
                      x_return_status =>x_return_status
                      );
  END IF;
    IF x_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_FORM_REASONS');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_Reasons'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Apply_Reason;


PROCEDURE Submit_Draft(
                          p_header_id      IN NUMBER
                        , x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                        , x_msg_count OUT NOCOPY NUMBER
                        , x_msg_data OUT NOCOPY VARCHAR2

                      )
IS
BEGIN
    oe_debug_pub.add('Entering OE_OE_FORM_REASONS.Submit_Draft');
  OE_NEGOTIATE_WF.Submit_Draft(
                          p_header_id=>  p_header_id,
                          x_return_status=>  x_return_status
                               );


    IF x_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_FORM_REASONS.Submit_Draft');
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Submit_Draft'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Submit_Draft;

PROCEDURE Populate_Version_Number
                      (
                        x_return_status     OUT NOCOPY VARCHAR2
                      , x_msg_count         OUT NOCOPY NUMBER
                      , x_msg_data          OUT NOCOPY VARCHAR2
                      , p_header_id         IN  NUMBER
                      , p_order_version_number IN NUMBER
                      )  IS
l_old_header_rec    OE_Order_PUB.Header_Rec_Type;
l_header_rec        OE_Order_PUB.Header_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
BEGIN
  IF p_header_id IS NOT NULL THEN
    OE_Header_Util.Query_Row(p_header_id  => p_header_id,
                            x_header_rec => l_old_header_rec);
    l_header_rec:=l_old_header_rec;
    l_header_rec.version_number:=p_order_version_number;
    OE_GLOBALS.G_UI_FLAG := TRUE;
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

     Oe_Order_Pvt.Header
    (
        p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_header_rec
    ,   p_x_old_header_rec            => l_old_header_rec
    ,   x_return_status                => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  OE_GLOBALS.G_UI_FLAG := FALSE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Populate_Version_Number'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Populate_Version_Number;

PROCEDURE Get_Reason_Rqd_Info
                      (
                        p_entity_id         IN  NUMBER
                      , p_entity_code       IN VARCHAR2
                      , x_audit_reason_capt OUT NOCOPY /* file.sql.39 change */ BOOLEAN
                      , x_reason            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                      , x_comments          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                      , x_is_reason_rqd     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                      , x_return_status     OUT NOCOPY VARCHAR2
                      , x_msg_count         OUT NOCOPY NUMBER
                      , x_msg_data          OUT NOCOPY VARCHAR2
                      )  IS
BEGIN
 x_audit_reason_capt:=
                        OE_Versioning_Util.IS_AUDIT_REASON_CAPTURED
                         (
                           p_entity_code=>p_entity_code
                        ,  p_entity_id=>p_entity_id
                         );
 OE_Versioning_Util.Get_Reason_Info(
                                x_reason_code=>x_reason,
                                x_reason_comments=>x_comments
                                );
  x_is_reason_rqd:=OE_Versioning_Util.IS_REASON_RQD;

  oe_debug_pub.add('Is_Reason_Rqd:'||x_is_reason_rqd);
  oe_debug_pub.add('x_reason:'||x_reason);
  IF x_audit_reason_capt THEN
   oe_debug_pub.add('audit reason captured');
  ELSE
   oe_debug_pub.add('audit reason not  captured');

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Reason_Rqd_Info'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Reason_Rqd_Info;

END Oe_Oe_Form_Reasons;


/
