--------------------------------------------------------
--  DDL for Package Body OE_ORDER_UPGRADE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_UPGRADE_UTIL" as
/* $Header: OEXUUPGB.pls 120.0 2005/06/01 00:51:39 appldev noship $ */


FUNCTION Get_entity_Scolumn_value (
	     p_entity_type IN VARCHAR2,
		p_entity_key IN NUMBER,
		p_SColumn_name IN VARCHAR2)
RETURN  NUMBER
IS
l_sColumn_value NUMBER;
l_so_line_id NUMBER;
l_sql VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF (p_entity_type = 'OEOL') then

	-- Fetch original so_lines.line_id based on  oe_order_lines.line_id

     SELECT NVL(MAX(old_line_id), -99)
	  INTO l_so_line_id
	  FROM OE_UPGRADE_LOG_V
      WHERE new_line_ID = p_entity_key;

    IF (l_so_line_id = -99) THEN
	  raise NO_DATA_FOUND;
    END IF;

    l_sql := 'SELECT '||p_SColumn_name||' FROM so_lines_all WHERE line_id = :so_line_id';

    EXECUTE IMMEDIATE l_sql INTO l_sColumn_value USING l_so_line_id;

  ELSE -- Entity is OEOH

  l_sql := 'SELECT '||p_SColumn_name||' FROM so_headers_all WHERE header_id = :hdr_id';

  EXECUTE IMMEDIATE l_sql INTO l_sColumn_value USING p_entity_key;

  END IF;

  return l_sColumn_value;

END Get_entity_Scolumn_value;

PROCEDURE Get_Invoice_Status_Code(
     p_line_id  IN NUMBER,
x_invoice_status_code OUT NOCOPY VARCHAR2)

IS
l_invoice_status_code VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  SELECT nvl(invoice_interface_status_code, 'NO')
  INTO l_invoice_status_code
  FROM oe_order_lines_all
  WHERE line_id = p_line_id;

  IF l_invoice_status_code = 'YES' THEN
     x_invoice_status_code := 'COMPLETE';
  ELSIF l_invoice_status_code = 'NOT_ELIGIBLE' THEN
     x_invoice_status_code := 'NOT_ELIGIBLE';
  ELSIF l_invoice_status_code = 'RFR-PENDING' OR
	   l_invoice_status_code = 'MANUAL-PENDING' THEN
     x_invoice_status_code := l_invoice_status_code;
  ELSE
     x_invoice_status_code := 'INCOMPLETE';
  END IF;

END Get_Invoice_Status_Code;

/*---------------------------------------------------------------------
PROCEDURE Get_Demand_Interface_Status
---------------------------------------------------------------------- */

PROCEDURE Get_Demand_Interface_Status(
p_line_id	IN  NUMBER,
x_result OUT NOCOPY NUMBER)


IS
l_schedule_status_code VARCHAR2(30);
l_s28                  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     l_s28 := Get_entity_Scolumn_value
                   (p_entity_type  => 'OEOL',
                    p_entity_key   => p_line_id,
                    p_SColumn_name => 'S28');

     x_result := l_s28;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Schedule_Status'
	);
  END IF;
END Get_Demand_Interface_Status;

/*---------------------------------------------------------------------
PROCEDURE Get_Pur_Rel_Status

---------------------------------------------------------------------- */

PROCEDURE Get_Pur_Rel_Status(
p_line_id	IN  NUMBER,
x_result OUT NOCOPY NUMBER)


IS
l_s26              NUMBER;
l_shipped_quantity NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   l_s26 := Get_entity_Scolumn_value
                   (p_entity_type  => 'OEOL',
                    p_entity_key   => p_line_id,
                    p_SColumn_name => 'S26');

   IF l_s26= OE_WF_UPGRADE_UTIL.RES_PARTIAL THEN

      SELECT shipped_quantity
      INTO l_shipped_quantity
      FROM oe_order_lines_all
      WHERE line_id=p_line_id;

      IF l_shipped_quantity is null THEN
         x_result :=  OE_WF_UPGRADE_UTIL.RES_INTERFACED;
      ELSE
         x_result :=  OE_WF_UPGRADE_UTIL.RES_CONFIRMED;
      END IF;
   ELSE
     x_result :=  l_s26;
   END IF;

EXCEPTION
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Schedule_Status'
	);
  END IF;
END Get_Pur_Rel_Status;

/*---------------------------------------------
     PROCEDURE GET_MFG_RELEASE_STATUS
----------------------------------------------- */

PROCEDURE Get_Mfg_Release_Status(
p_line_id	IN  NUMBER,
x_result OUT NOCOPY NUMBER)


IS

  l_s27  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  l_s27 := Get_entity_Scolumn_value
                   (p_entity_type  => 'OEOL',
                    p_entity_key   => p_line_id,
                    p_SColumn_name => 'S27');

  x_result := l_s27;

EXCEPTION
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Cancelled_Status'
	);
  END IF;
END Get_Mfg_Release_Status;

PROCEDURE Get_responsibility_application(
	p_user_id             IN  NUMBER,
	p_org_id              IN  NUMBER,
x_return_status OUT NOCOPY VARCHAR2,

x_error_message OUT NOCOPY VARCHAR2,

x_responsibility_id OUT NOCOPY NUMBER,

x_application_id OUT NOCOPY NUMBER)

IS
     l_responsibility_id   NUMBER;
     l_application_id      NUMBER;
     l_org_count           NUMBER := 0;
     l_res_count           Number := 0;
     l_org_id              VARCHAR2(38):= NULL;
     l_profile_value       VARCHAR2(1);
     l_multi_org_flag      VARCHAR2(1);

     cursor C_RES(l_user_id NUMBER) is
	select DISTINCT responsibility_id,
	responsibility_application_id application_id
	from fnd_user_resp_groups
	where user_id = l_user_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT nvl(multi_org_flag, 'N')
    INTO l_multi_org_flag
    FROM fnd_product_groups;

    l_org_count := 0;
    l_res_count := 0;

    FOR  c1 in C_RES(p_user_id) loop
        IF l_multi_org_flag = 'Y' THEN
            l_org_id := FND_PROFILE.Value_Specific(
                        'ORG_ID',
                        p_user_id,
                        c1.responsibility_id,
                        c1.APPLICATION_ID);
            IF l_org_id is NULL THEN
		      x_error_message :=  'Profile option - MO: Operating Unit - is not set for this responsibility '|| to_char(c1.responsibility_id);
                RAISE FND_API.G_EXC_ERROR;
            END IF;

       END IF;
       IF l_org_id = to_char(p_org_id) OR l_multi_org_flag = 'N' THEN
           l_org_count := l_org_count + 1;
           l_profile_value := FND_PROFILE.Value_Specific(
                      'OE_RESP_FOR_WF_UPGRADE',
                     p_user_id,
                     c1.responsibility_id,
                     c1.APPLICATION_ID);
           IF l_profile_value = 'Y' THEN
               l_res_count := l_res_count + 1;
           END IF;
           IF l_profile_value = 'Y' OR l_org_count = 1 THEN
               l_responsibility_id := c1.responsibility_id;
               l_application_id := c1.application_id;
           END IF;
       END IF;

    END LOOP;

    IF l_org_count = 1  OR l_res_count = 1 THEN
        x_responsibility_id := l_responsibility_id;
        x_application_id := l_application_id;
    END IF;

    IF l_org_count = 0 THEN
	   x_error_message := 'There are no responsibilities defined for the user/Org '|| to_char(p_user_id)|| '/'|| to_char(p_org_id);
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF l_org_count > 1 AND
       l_res_count = 0  THEN
	   x_error_message := 'There are multiple responsibilities defined for the user/org '|| to_char(p_user_id)|| '/'|| to_char(p_org_id) || ' But the profile option OE_RESP_FOR_WF_UPGRADE is not set for any of those';
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_org_count > 1 AND
       l_res_count > 1  THEN
	   x_error_message := 'There are multiple responsibilities defined for the user/org_id '|| to_char(p_user_id) ||'/' ||to_char(p_org_id) || ' But the profile option OE_RESP_FOR_WF_UPGRADE is set for more than one responsibilites';
       RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_responsibility_id := NULL;
        x_application_id := NULL;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_responsibility_id := NULL;
        x_application_id := NULL;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_responsibility_id := NULL;
        x_application_id := NULL;

END Get_responsibility_application;


END OE_ORDER_UPGRADE_UTIL;

/
