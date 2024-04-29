--------------------------------------------------------
--  DDL for Package Body WSH_INBOUND_SHIP_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INBOUND_SHIP_REQUEST_PKG" as
/* $Header: WSHINSRB.pls 115.6 2002/11/12 01:42:29 nparikh ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INBOUND_SHIP_REQUEST_PKG';
--
PROCEDURE Process_Ship_Request(P_Item_Type			IN  VARCHAR2,
				       P_Item_Key				IN  VARCHAR2,
					 P_Action_Type    		IN  VARCHAR2,
					 P_Delivery_Interface_ID 	IN  NUMBER,
					 X_Delivery_ID			OUT NOCOPY  NUMBER,
 			    	       X_Return_Status 			OUT NOCOPY  VARCHAR2) IS

INVALID_INTERFACE_ID			EXCEPTION;
INVALID_ACTION_TYPE			EXCEPTION;
Delivery_Int_Wrapper_Failed	  	EXCEPTION;
Check_Cancel_Allowed_WF_Failed	EXCEPTION;
Before_Populating_BT_Others		EXCEPTION;
before_Check_Cancel_WF_others		EXCEPTION;
T_Return_Status				VARCHAR2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_SHIP_REQUEST';
--
Begin
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
  wsh_debug_sv.push(l_module_name);
  wsh_debug_sv.log (l_module_name,'ITEM_TYPE', P_Item_Type);
  wsh_debug_sv.log (l_module_name,'DELIVERY INTERFACE ID', P_Delivery_Interface_ID);
  wsh_debug_sv.log (l_module_name,'ACTION TYPE', P_Action_Type);
 END IF;

  IF ((P_Action_Type IS NULL) OR (P_Action_Type NOT IN ('A','D'))) Then
    Raise INVALID_ACTION_TYPE;
  End IF;

  IF (P_Delivery_Interface_ID is Not Null) Then

    IF (P_Action_Type = 'A') Then
      -- Added the following statement to fix Bug # 2342710
	SAVEPOINT Before_Populating_Base_Tables;
      -- End of Changes to fix Bug # 2342710

	Begin
  	  WSH_INTERFACE_COMMON_ACTIONS.Delivery_Interface_Wrapper(P_Delivery_Interface_ID,
	 									    'CREATE',
										    X_Delivery_ID,
										    X_Return_Status);

          IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'X_Delivery_ID,X_Return_Status', X_Delivery_ID||','||X_Return_Status);
          END IF;

          IF(X_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
  	    Raise Delivery_Int_Wrapper_Failed;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            Raise Before_Populating_BT_Others;
	End;

    Else -- If P_Action_Type = 'D'

      -- Added the following statement to fix Bug # 2342710
	SAVEPOINT Before_Check_Cancel_Allowed_WF;
      -- End of Changes to fix Bug # 2342710

      Begin
        WSH_TRANSACTIONS_TPW_UTIL.Check_Cancel_Allowed_WF(P_Item_Type => P_Item_Type,
 						 			    P_Item_Key  => P_Item_Key,
									    P_actid     => NULL,
									    P_funcmode  => NULL,
					  				    X_Resultout => X_Return_Status);
          IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'X_Return_Status',X_Return_Status);
          END IF;

        IF(X_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
 	    raise Check_Cancel_Allowed_WF_Failed;
  	  END IF;

      EXCEPTION
	WHEN OTHERS THEN
        Raise before_Check_Cancel_WF_others;
      END;

    End If; -- End of If p_Action_Type = 'A'

  Else -- If P_Delivery_Interface_ID is null
    Raise INVALID_INTERFACE_ID;
  End IF;

  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'Return Status for Process Inbound Ship Request. Return Status :'||X_Return_Status);
   wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
WHEN Check_Cancel_Allowed_WF_Failed THEN
  -- Added the following statement to fix Bug # 2342710.
  ROLLBACK TO SAVEPOINT Before_Check_Cancel_Allowed_WF;
  -- End of Changes for Bug # 2342710.
  X_Return_Status := WSH_UTIL_CORE.G_RET_STS_ERROR;

  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'Check_Cancel_Allowed_WF_Failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:check_Cancel_Allowed_WF_Failed');
  END IF;

WHEN before_Check_Cancel_WF_others THEN
  -- Added the following statement to fix Bug # 2342710.
  ROLLBACK TO SAVEPOINT Before_Check_Cancel_Allowed_WF;
  -- End of Changes for Bug # 2342710.
  X_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'before_Check_Cancel_WF_others exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:before_Check_Cancel_WF_others');
  END IF;

WHEN Delivery_Int_Wrapper_Failed THEN
  -- Added the following statement to fix Bug # 2342710.
  ROLLBACK TO SAVEPOINT Before_Populating_Base_Tables;
  -- End of Changes for Bug # 2342710.
  X_Return_Status := WSH_UTIL_CORE.G_RET_STS_ERROR;

  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'Delivery_Int_Wrapper_Failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Delivery_Int_Wrapper_Failed');
  END IF;

WHEN Before_Populating_BT_Others THEN
  -- Added the following statement to fix Bug # 2342710.
  ROLLBACK TO SAVEPOINT Before_Populating_Base_Tables;
  -- End of Changes for Bug # 2342710.
  X_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'Before_Populating_BT_Others exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Before_Populating_BT_Others');
  END IF;

WHEN INVALID_INTERFACE_ID THEN
  X_Return_Status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_INTERFACE_ID exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_INTERFACE_ID');
  END IF;

WHEN INVALID_ACTION_TYPE THEN
  X_Return_Status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_ACTION_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_ACTION_TYPE');
  END IF;

WHEN OTHERS THEN
  X_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
  IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
End Process_Ship_Request;

End WSH_INBOUND_SHIP_REQUEST_PKG;

/
