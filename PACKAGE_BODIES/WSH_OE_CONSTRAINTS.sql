--------------------------------------------------------
--  DDL for Package Body WSH_OE_CONSTRAINTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_OE_CONSTRAINTS" as
/* $Header: WSHOECOB.pls 115.4 2002/11/13 20:10:50 nparikh ship $ */

  G_PKG_NAME  VARCHAR2(100) := 'WSH_OE_CONSTRAINTS';



PROCEDURE Validate_Reservations
(
        p_application_id                IN      NUMBER
,       p_entity_short_name             IN      VARCHAR2
,       p_validation_entity_short_name  IN      VARCHAR2
,       p_validation_tmplt_short_name   IN      VARCHAR2
,       p_record_set_short_name         IN      VARCHAR2
,       p_scope                         IN      VARCHAR2
,       x_result_out                    OUT NOCOPY      NUMBER
) IS

  -- Find out if we have delivery details
  -- that require checking the reservations.
  CURSOR c_details(x_line_id IN NUMBER) IS
    SELECT released_status
    FROM   wsh_delivery_details
    WHERE  source_code = 'OE'
    AND    source_line_id = x_line_id
    AND    released_status IN ('S', 'Y', 'X')
    AND    rownum = 1;

  -- Check the reservations
  CURSOR c_reservations(x_line_id IN NUMBER) IS
    SELECT staged_flag
    FROM   mtl_reservations
    WHERE  demand_source_line_id = x_line_id;

  l_details c_details%ROWTYPE;
  l_reservations c_reservations%ROWTYPE;
  l_cms_profile  VARCHAR2(100);

  lc_allowed    CONSTANT NUMBER := 0;
  lc_disallowed CONSTANT NUMBER := 1;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_RESERVATIONS';
--
BEGIN

    -- need to check that patchset level is pre-G.
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_APPLICATION_ID',P_APPLICATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_SHORT_NAME',P_ENTITY_SHORT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_ENTITY_SHORT_NAME',P_VALIDATION_ENTITY_SHORT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_TMPLT_SHORT_NAME',P_VALIDATION_TMPLT_SHORT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_RECORD_SET_SHORT_NAME',P_RECORD_SET_SHORT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_SCOPE',P_SCOPE);
    END IF;
    --
    fnd_profile.get('ONT_ACTIVATE_CMS', l_cms_profile);
    IF l_cms_profile = 'Y' THEN
      x_result_out := lc_allowed;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'X_RESULT_OUT',x_result_out);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;


    -- Full cancellation?
    IF OE_LINE_SECURITY.g_record.ordered_quantity = 0 THEN
      -- allow full cancellation
      x_result_out := lc_allowed;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'X_RESULT_OUT',x_result_out);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;



    OPEN  c_details(OE_LINE_SECURITY.g_record.line_id);
    FETCH c_details INTO l_details;

    IF c_details%NOTFOUND THEN
      -- OK to do the changes if nothing is found
      CLOSE c_details;
      x_result_out := lc_allowed;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'X_RESULT_OUT',x_result_out);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

    CLOSE c_details;



    OPEN  c_reservations(OE_LINE_SECURITY.g_record.line_id);
    FETCH c_reservations INTO l_reservations;

    IF c_reservations%NOTFOUND THEN
      -- OK to do the changes because there are no reservations
      x_result_out := lc_allowed;
    ELSE
      -- Make sure there is only one reservation record.
      FETCH c_reservations INTO l_reservations;
      IF c_reservations%NOTFOUND THEN
        x_result_out := lc_allowed;
      ELSE
        x_result_out := lc_disallowed;
      END IF;
    END IF;

    CLOSE c_reservations;


--
-- Debug Statements
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_RESULT_OUT',x_result_out);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
EXCEPTION
        WHEN OTHERS THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_MSG_PUB.CHECK_MSG_LEVEL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_MSG_PUB.ADD_EXC_MSG',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Reservations'
            );
          END IF;
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 )  );
          END IF;
          --
          IF c_details%ISOPEN THEN
            CLOSE c_details;
          END IF;
          IF c_reservations%ISOPEN THEN
            CLOSE c_reservations;
          END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Reservations;



PROCEDURE Validate_Sub_Change
(
        p_application_id                IN      NUMBER
,       p_entity_short_name             IN      VARCHAR2
,       p_validation_entity_short_name  IN      VARCHAR2
,       p_validation_tmplt_short_name   IN      VARCHAR2
,       p_record_set_short_name         IN      VARCHAR2
,       p_scope                         IN      VARCHAR2
,       x_result_out                    OUT NOCOPY      NUMBER
) IS

  -- Find out if we have delivery details
  -- that require checking the reservations.
  CURSOR c_details(x_line_id IN NUMBER) IS
    SELECT released_status
    FROM   wsh_delivery_details
    WHERE  source_code = 'OE'
    AND    source_line_id = x_line_id
    AND    released_status IN ('S', 'Y', 'C')
    AND    rownum = 1;


  l_details c_details%ROWTYPE;

  l_cms_profile  VARCHAR2(100);

  lc_allowed    CONSTANT NUMBER := 0;
  lc_disallowed CONSTANT NUMBER := 1;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SUB_CHANGE';
--
BEGIN
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_APPLICATION_ID',P_APPLICATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_SHORT_NAME',P_ENTITY_SHORT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_ENTITY_SHORT_NAME',P_VALIDATION_ENTITY_SHORT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_TMPLT_SHORT_NAME',P_VALIDATION_TMPLT_SHORT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_RECORD_SET_SHORT_NAME',P_RECORD_SET_SHORT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_SCOPE',P_SCOPE);
    END IF;
    --
    x_result_out := lc_disallowed;

    -- need to check that patchset level is pre-G.
    fnd_profile.get('ONT_ACTIVATE_CMS', l_cms_profile);
    IF l_cms_profile = 'Y' THEN
      x_result_out := lc_allowed;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'X_RESULT_OUT',x_result_out);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;


    OPEN  c_details(OE_LINE_SECURITY.g_record.line_id);
    FETCH c_details INTO l_details;

    IF c_details%NOTFOUND THEN
      -- OK to do the changes if nothing is found
      CLOSE c_details;
      x_result_out := lc_allowed;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'X_RESULT_OUT',x_result_out);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

    CLOSE c_details;


--
-- Debug Statements
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_RESULT_OUT',x_result_out);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
EXCEPTION
        WHEN OTHERS THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_MSG_PUB.CHECK_MSG_LEVEL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_MSG_PUB.ADD_EXC_MSG',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Sub_Change'
            );
          END IF;
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 )  );
          END IF;
          --

          IF c_details%ISOPEN THEN
            CLOSE c_details;
          END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Sub_Change;


END WSH_OE_CONSTRAINTS;

/
