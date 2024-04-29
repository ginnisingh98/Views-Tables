--------------------------------------------------------
--  DDL for Package Body OE_ORDER_CONTEXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_CONTEXT_GRP" AS
/* $Header: OEXGCTXB.pls 120.2 2005/06/21 21:57:48 appldev ship $ */

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Order_Context_GRP';


--  Start of Comments
--  API name    Set_Created_By_Context
--  Type        Group
--
--  Function    This API may be used when group callers in an operating
--              unit need to update orders in a DIFFERENT operating unit.
--
--              Used to re-initialize application context based on user, resp
--              and application combination for user who created the order or line.
--              This would ensure that operating unit is re-set to operating
--              unit in which order or line was created.
--
--              Please NOTE that order processing will then run in the context of
--              created by and NOT the caller i.e. user, responsibility level
--              profiles and other user/resp specific functions (e.g. OM
--              security constraints) will be evaluated for the order created by.
--
--              IMPORTANT: After calling this API and calling respective OM API
--              to process this update (e.g. Process_Order), you should re-set to
--              your original context using FND_GLOBAL.Apps_Initialize with
--              original user, resp,application returned by this function.
--
--  Parameters  Pass p_header_id if the context should be set using
--              created by for the order.
--              Pass p_line_id if the context should be set using
--              created by for the line.
--              If you pass both p_line_id and p_header_id, context will be set
--              using created_by for the line.
--              Original application context values for the API caller are returned
--              in : x_orig_user_id, x_orig_resp_id, x_orig_resp_appl_id
--
--  Examples    1. If you are updating/deleting only one line and/or only the child
--                 entities of this line e.g. price adjustments, sales credits
--                 - pass p_line_id.
--              2. When you are CREATING/UPDATING lines, you can pass p_header_id.
--                 If lines being processed are under ONE model, you can pass
--                 top_model_line_id in the p_line_id parameter.
--              3. For all other operations spanning multiple lines or multiple
--                 child entities of one order, pass p_header_id.
--
--     The earlier logic of setting the CREATED BY context stored in the WF
--     tables was removed for the MOAC project in R12
--
--  End of Comments

PROCEDURE Set_Created_By_Context
(p_header_id            IN  NUMBER    DEFAULT NULL
,p_line_id              IN  NUMBER    DEFAULT NULL
,x_orig_user_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,x_orig_resp_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,x_orig_resp_appl_id    OUT NOCOPY /* file.sql.39 change */ NUMBER
,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_user_id               NUMBER;
/* MOAC
l_resp_id               NUMBER;
l_resp_appl_id          NUMBER;
l_itemtype              VARCHAR2(8);
l_itemkey               VARCHAR2(30);
*/
l_org_id                NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTER SET_CREATED_BY_CONTEXT' , 1 ) ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Return the original context values
    x_orig_user_id := FND_GLOBAL.USER_ID;
    x_orig_resp_id := FND_GLOBAL.RESP_ID;
    x_orig_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
    -- MOAC changes starts
    IF p_line_id IS NOT NULL THEN
         SELECT org_id
         INTO l_org_id
         FROM oe_order_lines_all
         WHERE line_id = p_line_id;
    ELSIF p_header_id IS NOT NULL THEN
         SELECT org_id
         INTO l_org_id
         FROM oe_order_headers_all
         WHERE header_id = p_header_id;
    END IF;

    IF l_org_id IS NOT NULL THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXGCTXB.pls - setting single org context to '||l_org_id , 1 );
      END IF;
      MO_GLOBAL.Set_Policy_Context('S', l_org_id);
    END IF;

    /* commented for MOAC
    IF p_line_id IS NOT NULL THEN
      l_itemtype := 'OEOL';
      l_itemkey := to_char(p_line_id);
    ELSIF p_header_id IS NOT NULL THEN
      l_itemtype := 'OEOH';
      l_itemkey := to_char(p_header_id);
    END IF;

    IF l_itemkey IS NOT NULL THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SET CONTEXT' , 2 ) ;
       END IF;

       l_user_id := WF_Engine.GetItemAttrNumber
                               (itemtype   => l_itemtype
                               ,itemkey    => l_itemkey
                               ,aname      => 'USER_ID');
       l_resp_id := WF_Engine.GetItemAttrNumber
                               (itemtype   => l_itemtype
                               ,itemkey    => l_itemkey
                               ,aname      => 'RESPONSIBILITY_ID');
       l_resp_appl_id := WF_Engine.GetItemAttrNumber
                               (itemtype   => l_itemtype
                               ,itemkey    => l_itemkey
                               ,aname      => 'APPLICATION_ID');

       IF l_user_id IS NULL
          OR l_resp_id IS NULL
          OR l_resp_appl_id IS NULL
       THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SET CONTEXT: NO DATA FOUND' , 2 ) ;
          END IF;
          RAISE NO_DATA_FOUND;
       END IF;

       FND_GLOBAL.Apps_Initialize
                    (user_id    => l_user_id
                    ,resp_id    => l_resp_id
                    ,resp_appl_id => l_resp_appl_id);

    END IF; */

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT SET_CREATED_BY_CONTEXT' , 1 ) ;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Set_Created_By_Context'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END Set_Created_By_Context;

END OE_Order_Context_GRP;

/
