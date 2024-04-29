--------------------------------------------------------
--  DDL for Package Body OE_REASONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_REASONS_UTIL" AS
/* $Header: OEXURSNB.pls 120.0 2005/06/01 00:52:06 appldev noship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Reasons_Util';

/*
Valid entity codes matches with OE_GLOBALS.G_ENTITY_%
HEADER
LINE
HEADER_ADJ
LINE_ADJ
HEADER_SCREDIT
LINE_SCREDIT
BLANKET_HEADER
BLANKET_LINE
*/

Procedure Apply_Reason(
p_entity_code IN VARCHAR2,
p_entity_id IN NUMBER,
p_header_id IN NUMBER := NULL,
p_version_number IN NUMBER,
p_reason_type IN VARCHAR2,
p_reason_code IN VARCHAR2,
p_reason_comments IN VARCHAR2,
x_reason_id OUT NOCOPY NUMBER,
x_return_status OUT NOCOPY VARCHAR2)
IS
  l_header_id NUMBER := p_header_id;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_version_number NUMBER := p_version_number;
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_header_id IS NULL THEN
  IF p_entity_code = 'HEADER' THEN
         l_header_id := p_entity_id;
    ELSIF p_entity_code = 'LINE' THEN
         SELECT header_id INTO l_header_id
         FROM oe_order_lines_all WHERE line_id = p_entity_id;
    ELSIF p_entity_code IN ('HEADER_ADJ','LINE_ADJ') THEN
         SELECT header_id INTO l_header_id
         FROM oe_price_adjustments WHERE price_adjustment_id = p_entity_id;
    ELSIF p_entity_code IN ('HEADER_SCREDIT','LINE_SCREDIT') THEN
         SELECT header_id INTO l_header_id
         FROM oe_sales_credits WHERE sales_credit_id = p_entity_id;
    ELSIF p_entity_code = 'BLANKET_HEADER' THEN
         l_header_id := p_entity_id;
    ELSIF p_entity_code = 'BLANKET_LINE' THEN
         SELECT header_id INTO l_header_id
         FROM oe_blanket_lines_all WHERE line_id = p_entity_id;
    ELSE
         x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
ELSE
   l_header_id := p_header_id;
END IF;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Entering OEXURSNB:Apply_Reason ',1);
        oe_debug_pub.add('Entity code,id, hdr id, vers, reason_type:'||
                p_entity_code || ',' || p_entity_id || ',' ||
                p_header_id || ',' || p_version_number || ',' || p_reason_type,1);

END IF;

/*IF p_reason_code IS NULL THEN
  IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Reason_Code is NULL ',1);
  END IF;

  RAISE FND_API.G_EXC_ERROR;
END IF;
*/
IF p_reason_type IS NULL THEN
  IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Reason_Type is NULL ',1);
  END IF;

  RAISE FND_API.G_EXC_ERROR;
END IF;

IF l_version_number IS NULL THEN
  IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Version_Number is NULL! ',1);
  END IF;

  l_version_number := 0;
END IF;

SELECT OE_REASONS_S.NEXTVAL INTO x_reason_id FROM dual;

INSERT INTO OE_REASONS
(reason_id,
entity_code,
entity_id,
header_id,
version_number,
reason_type,
reason_code,
comments,
creation_date,
created_by,
last_updated_by,
last_update_date)
VALUES
(x_reason_id,
p_entity_code,
p_entity_id,
l_header_id,
l_version_number,
p_reason_type,
p_reason_code,
p_reason_comments,
sysdate,
nvl(FND_GLOBAL.USER_ID,-1),
nvl(FND_GLOBAL.USER_ID,-1),
sysdate);

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Exiting OEXURSNB:Apply_Reasons ',1);
END IF;

EXCEPTION
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Apply_Reason'
        );
    END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Apply_Reason;

Procedure Get_Reason(
p_reason_id IN NUMBER DEFAULT NULL,
p_entity_code IN VARCHAR2 DEFAULT NULL,
p_entity_id IN NUMBER DEFAULT NULL,
p_version_number IN NUMBER,
x_reason_type OUT NOCOPY VARCHAR2,
x_reason_code OUT NOCOPY VARCHAR2,
x_reason_comments OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2
)
IS

BEGIN

IF p_reason_id IS NOT NULL THEN

  SELECT reason_type, reason_code, comments
  INTO x_reason_type, x_reason_code, x_reason_comments
  FROM OE_REASONS
  WHERE REASON_ID = p_reason_id;

ELSE

  SELECT reason_type, reason_code, comments
  INTO x_reason_type, x_reason_code, x_reason_comments
  FROM OE_REASONS
  WHERE entity_code = p_entity_code
  AND   entity_id   = p_entity_id
  AND   version_number = p_version_number;

END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Get_Reason'
        );
    END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Reason;

END OE_Reasons_Util;

/
