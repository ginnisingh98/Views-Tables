--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_UTIL_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_UTIL_MISC" AS
/* $Header: OEXUBMSB.pls 115.2 2003/11/12 21:59:36 spagadal ship $ */

Procedure Get_BlanketAgrName (p_blanket_number   IN  varchar2,
                              x_blanket_agr_name OUT NOCOPY VARCHAR2)
IS
l_sales_document_name   varchar2(240);
l_debug_level           CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Begin

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('ENTER IN OE_Blanket_Util_Misc.Get_BlanketAgrName '||p_blanket_number);
        END IF;

        if p_blanket_number is not null then


               SELECT sales_document_name
               INTO  l_sales_document_name
               FROM oe_blanket_headers
               WHERE order_number = p_blanket_number
               AND ROWNUM =1;
               x_blanket_agr_name := l_sales_document_name;

        else
               l_sales_document_name := null;
               x_blanket_agr_name := null;

        end if;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('EXIT IN OE_Blanket_Util_Misc.Get_BlanketAgrName '||l_sales_document_name);
        END IF;


    EXCEPTION

        WHEN NO_DATA_FOUND THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('IN EXCEPTION OE_Blanket_Util_Misc.Get_BlanketAgrName WHEN no_data_found');
           end if;
           l_sales_document_name := '';
        WHEN OTHERS THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('IN EXCEPTION OE_Blanket_Util_Misc.Get_BlanketAgrName WHEN OTEHRS');
           end if;
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
               OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                       'get_blanketagrname');
           END IF;

end Get_BlanketAgrName;


end oe_blanket_util_misc;

/
