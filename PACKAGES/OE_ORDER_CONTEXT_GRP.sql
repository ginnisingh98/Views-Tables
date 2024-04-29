--------------------------------------------------------
--  DDL for Package OE_ORDER_CONTEXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_CONTEXT_GRP" AUTHID CURRENT_USER AS
/* $Header: OEXGCTXS.pls 120.0 2005/06/01 23:18:05 appldev noship $ */

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
);

END OE_Order_Context_GRP;

 

/
