--------------------------------------------------------
--  DDL for Package Body AHL_STATUS_ORDER_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_STATUS_ORDER_RULES_PVT" AS
/* $Header: AHLVSORB.pls 115.1 2003/10/20 19:37:12 sikumar noship $ */

G_PKG_NAME  VARCHAR2(30)  := 'AHL_STATUS_ORDER_RULES_PVT';
--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

--
-----------------------------------------------------------
-- PACKAGE
--    AHL_STATUS_ORDER_RULES_PVT
--
-- PURPOSE
--    This package is a Private API for retrieving the valid
--    statuses for the current status
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_STATUS_ORDER_RULES
--    Get_Valid_Status_Order_Values (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 09-May-2003    sdevaki      Created

-------------------------------------------------------------
--  procedure name: Get_Status_Order_Rules(private procedure)
--  description :  To Retrieve the valid Status Order Rules for the current Status
--------------------------------------------------------------

PROCEDURE Get_Status_Order_Rules (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_current_status_code     IN      VARCHAR2,
   p_system_status_type      IN      VARCHAR2,
   x_status_order_rules_tbl      OUT NOCOPY Status_Order_Rules_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)

IS


   l_api_name       CONSTANT    VARCHAR2(30)  := 'Get_Status_Order_Rules';
   l_api_version    CONSTANT    NUMBER        := 1.0;

   l_index NUMBER := 0;

   CURSOR status_order_rules_cur
          ( c_current_status_code
            AHL_STATUS_ORDER_RULES.CURRENT_STATUS_CODE%TYPE,
            c_system_status_type
            AHL_STATUS_ORDER_RULES.SYSTEM_STATUS_TYPE%TYPE
          )
   IS
   	SELECT
   		SOR.NEXT_STATUS_CODE,
   		FND.MEANING

   	FROM
   		AHL_STATUS_ORDER_RULES SOR, FND_LOOKUP_VALUES_VL FND
   	WHERE
   		SOR.CURRENT_STATUS_CODE = c_current_status_code AND
   		SOR.SYSTEM_STATUS_TYPE = c_system_status_type AND
   		FND.LOOKUP_TYPE(+) = c_system_status_type AND
   		FND.LOOKUP_CODE(+) = SOR.NEXT_STATUS_CODE;

    v_status_order_rules_rec status_order_rules_cur%ROWTYPE;

BEGIN

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
      --FND_PROFILE.put('AHL_API_FILE_DEBUG_NAME','ahlsdevakidebug.log');
      AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'enter ahl_status_order_rules_pvt.get_status_order_rules','+STORULE+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF G_DEBUG='Y'
   THEN
      AHL_DEBUG_PUB.debug( 'p_current_status_code ' || p_current_status_code);
      AHL_DEBUG_PUB.debug( 'p_system_status_type ' || p_system_status_type);
   END IF;

   OPEN status_order_rules_cur( p_current_status_code, p_system_status_type );

   LOOP
        FETCH status_order_rules_cur INTO v_status_order_rules_rec;

        EXIT WHEN status_order_rules_cur%NOTFOUND;

        x_status_order_rules_tbl(l_index).next_status_code := v_status_order_rules_rec.next_status_code;
        x_status_order_rules_tbl(l_index).next_status_meaning := v_status_order_rules_rec.meaning;

        IF G_DEBUG='Y'
        THEN
           AHL_DEBUG_PUB.debug( 'next_status_code ' || v_status_order_rules_rec.next_status_code );
           AHL_DEBUG_PUB.debug( 'meaning ' || v_status_order_rules_rec.meaning );
           AHL_DEBUG_PUB.debug( 'l_index ' || l_index );
        END IF;

   	    l_index := l_index + 1;

   END LOOP;

   IF G_DEBUG='Y'
   THEN
      AHL_DEBUG_PUB.debug( 'Number of Status Order Rules is : ' || status_order_rules_cur%ROWCOUNT );
   END IF;

   CLOSE status_order_rules_cur;

   -- Check if API is called in debug mode. If yes, enable debug.


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.disable_debug;
      END IF;

   WHEN TOO_MANY_ROWS THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.disable_debug;
      END IF;

   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.disable_debug;
      END IF;
      RAISE;
END Get_Status_Order_Rules;

END AHL_STATUS_ORDER_RULES_PVT;

/
