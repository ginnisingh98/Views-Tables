--------------------------------------------------------
--  DDL for Package Body INV_GRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_GRADE_PKG" AS
  /* $Header: INVUPLGB.pls 120.1 2006/09/21 14:38:59 jsrivast noship $ */

PROCEDURE print_debug(p_err_msg VARCHAR2,
                      p_level 	NUMBER default 4)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg 	=> p_err_msg,
      p_module 		=> 'INV_GRADE_UPDATE',
      p_level 		=> p_level);
   END IF;
END print_debug;

PROCEDURE UPDATE_GRADE
    (   p_organization_id        IN  NUMBER   DEFAULT NULL
      , p_update_method          IN  NUMBER
      , p_inventory_item_id      IN  NUMBER
      , p_from_grade_code        IN  VARCHAR2
      , p_to_grade_code          IN  VARCHAR2
      , p_reason_id              IN  NUMBER
      , p_lot_number             IN  VARCHAR2
      , x_Status                 OUT NOCOPY VARCHAR2
      , x_Message                OUT NOCOPY VARCHAR2
      , p_update_from_mobile     IN  VARCHAR2  DEFAULT 'N'
      , p_primary_quantity       IN  NUMBER
      , p_secondary_quantity       IN  NUMBER
   ) IS
       -- BEGIN SCHANDRU INVERES
	l_grade_update_id NUMBER := NULL;
	g_eres_enabled varchar2(1):= NVL(fnd_profile.VALUE('EDR_ERES_ENABLED'), 'N');

        -- END SCHANDRU INVERES
  BEGIN

     /* Initialize API return status to success */
     x_Status := FND_API.G_RET_STS_SUCCESS;


    print_debug(' In Grade Update Package - Before Updating record ')  ;

-- BEGIN SCHANDRU INVERES
	select mtl_lot_grade_history_s.nextval
	into l_grade_update_id
	from dual;
 -- END SCHANDRU INVERES

    UPDATE mtl_lot_numbers
    SET    grade_code = p_to_grade_code
    WHERE  lot_number = p_lot_number
    AND    organization_id = p_organization_id
    AND    inventory_item_id = p_inventory_item_id ;

    --COMMIT ;-- SCHANDRU INVERES

    print_debug(' In Grade Update Package - Before inserting record ')  ;

     /*  Define Savepoint */

 -- BEGIN SCHANDRU INVERES
      if ( p_update_from_mobile = 'Y') then
	SAVEPOINT  Insert_GradeUpdate_PVT;
      end if;
-- END SCHANDRU INVERES
     INSERT INTO MTL_LOT_GRADE_HISTORY
     (
       GRADE_UPDATE_ID
     , INVENTORY_ITEM_ID
     , ORGANIZATION_ID
     , LOT_NUMBER
     , UPDATE_METHOD
     , NEW_GRADE_CODE
     , OLD_GRADE_CODE
     , PRIMARY_QUANTITY
     , SECONDARY_QUANTITY
     , UPDATE_REASON_ID
     , INITIAL_GRADE_FLAG
     , FROM_MOBILE_APPS_FLAG
     , GRADE_UPDATE_DATE
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
     , ATTRIBUTE_CATEGORY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATED_BY
     , LAST_UPDATE_DATE
     , LAST_UPDATE_LOGIN
      ) VALUES
      (
-- BEGIN  SCHANDRU INVERES
--        MTL_LOT_GRADE_HISTORY_S.NEXTVAL
	l_grade_update_id
-- END SCHADRU INVERES
      , p_inventory_item_id
      , p_organization_id
      , p_lot_number
      , p_update_method      -- UPDATE_METHOD  /* Jalaj Srivastava Bug 4998256 pass p_update_method instead of null */
      , p_to_grade_code      -- NEW_GRADE_CODE
      , p_from_grade_code    -- OLD_GRADE_CODE
      , p_primary_quantity   -- PRIMARY_QUANTITY
      , p_secondary_quantity -- SECONDARY_QUANTITY
      , p_reason_id          -- UPDATE_REASON_ID
      , 'N'                  -- INITIAL_GRADE_FLAG
      , 'N'                  -- FROM_MOBILE_APPS_FLAG
      , SYSDATE              -- GRADE_UPDATE_DATE
      , NULL                 -- ATTRIBUTE1
      , NULL                 -- ATTRIBUTE2
      , NULL                 -- ATTRIBUTE3
      , NULL                 -- ATTRIBUTE4
      , NULL                 -- ATTRIBUTE5
      , NULL                 -- ATTRIBUTE6
      , NULL                 -- ATTRIBUTE7
      , NULL                 -- ATTRIBUTE8
      , NULL                 -- ATTRIBUTE9
      , NULL                 -- ATTRIBUTE10
      , NULL                 -- ATTRIBUTE11
      , NULL                 -- ATTRIBUTE12
      , NULL                 -- ATTRIBUTE13
      , NULL                 -- ATTRIBUTE14
      , NULL                 -- ATTRIBUTE15
      , NULL                 -- ATTRIBUTE_CATEGORY
      , SYSDATE              --  CREATION_DATE
      , FND_GLOBAL.USER_ID   --  CREATED_BY
      , FND_GLOBAL.USER_ID   --  LAST_UPDATED_BY
      , SYSDATE              --  LAST_UPDATE_DATE
      , FND_GLOBAL.LOGIN_ID  --  LAST_UPDATE_LOGIN
      ) ;

-- BEGIN SCHANDRU INVERES
      IF g_eres_enabled <> 'N' THEN

	Insert into MTL_GRADE_STATUS_ERES_GTMP(status_update_id, grade_update_id) values ( NULL, l_grade_update_id);
      END IF;
-- END SCHANDRU INVERES

     print_debug(' In Grade Update Package - AFtrer inserting record ') ;

      --COMMIT ;-- SCHANDRU INVERES

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      -- BEGIN SCHANDRU INVERES
      if ( p_update_from_mobile = 'Y') then
	ROLLBACK TO Insert_GradeUpdate_PVT;
      end if;
	-- END SCHANDRU INVERES
       x_Status  := FND_API.G_RET_STS_ERROR;
       x_Message := SQLERRM ;
       print_debug(' In Grade Update Package - Encountered exec error ') ;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      -- BEGIN SCHANDRU INVERES
      if ( p_update_from_mobile = 'Y') then
	ROLLBACK TO Insert_GradeUpdate_PVT;
      end if;
	-- END SCHANDRU INVERES

       x_Status  := FND_API.G_RET_STS_ERROR;
       x_Message := SQLERRM ;
       print_debug(' In Grade Update Package - Encountered unexpected error ') ;
     WHEN OTHERS THEN
       -- BEGIN SCHANDRU INVERES
      if ( p_update_from_mobile = 'Y') then
	ROLLBACK TO Insert_GradeUpdate_PVT;
      end if;
	-- END SCHANDRU INVERES

       x_Status  := FND_API.G_RET_STS_UNEXP_ERROR;
       X_Message := SQLERRM ;
       print_debug(' In Grade Update Package - Encountered other error ') ;

  END UPDATE_GRADE ;


END INV_GRADE_PKG ;

/
