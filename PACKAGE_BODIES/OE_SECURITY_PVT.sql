--------------------------------------------------------
--  DDL for Package Body OE_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SECURITY_PVT" AS
/* $Header: OEXVSECB.pls 120.0 2005/06/01 01:24:45 appldev noship $ */

--  Start of Comments
--  API name    OE_SECURITY_PVT
--  Type        PRIVATE
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
Procedure ChkProcConstraints(
           x_sec_req        IN OUT NOCOPY /* file.sql.39 change */ OE_SECURITY_PVT.G_SECURITY_REC_TYPE
,x_return_status OUT NOCOPY Varchar2

,x_result OUT NOCOPY Varchar2

,x_msg_data OUT NOCOPY Varchar2

,x_msg_count OUT NOCOPY Number) IS

l_rslt            number := 1;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'CHKPROCCONSTRAINTS: CALLING SECURITY FOR KEY ' || X_SEC_REQ.WF_ITEM_KEY || ' WITH RESP ID ' || TO_CHAR ( X_SEC_REQ.RESPONSIBILITY_ID ) ) ;
                    END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_result := FND_API.G_FALSE;
    -- call processing constraints api
    /* l_rslt := OE_PC_CONSTRAINTS_MANAGER_PUB.Is_Entity_Op_Constrained(
                     p_api_version => '1.0'
                     ,p_application_id => x_sec_req.application_id
                     ,p_responsibility_id => x_sec_req.responsibility_id
                     ,p_work_item_type => x_sec_req.wf_item_type
                     ,p_work_item_key  => x_sec_req.wf_item_key
                     ,p_attribute_group => x_sec_req.attribute_group
                     ,p_attribute_code => x_sec_req.attribute_code
                     ,p_operation_code => x_sec_req.operation_code
                     ,p_constraint_id =>  x_sec_req.constraint_id
                     ,p_constraint_type => x_sec_req.constraint_type
                     ,p_resolving_activity_name =>
                                 x_sec_req.resolving_activity_name
                     ,p_resolving_activity_item_type =>
                                 x_sec_req.resolving_activity_item_type
                     ,p_resolving_responsibility_id =>
                                 x_sec_req.resolving_responsibility_id
                     ,p_error_code => x_sec_req.err_code
                     ,p_msg_count => x_msg_count
                     ,p_msg_data  => x_msg_data
                     ); */
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'THE THE SECURITY TYPE ' || X_SEC_REQ.CONSTRAINT_TYPE || 'WITH RESULT :' || TO_CHAR ( L_RSLT ) || ' FOR CONSTRINTID ' || TO_CHAR ( X_SEC_REQ.CONSTRAINT_ID ) ) ;
                  END IF;
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'THE RESOLVING ITEM : ' || X_SEC_REQ.RESOLVING_ACTIVITY_ITEM_TYPE || ' ACTIVITY : ' || X_SEC_REQ.RESOLVING_ACTIVITY_NAME);
                                oe_debug_pub.add( ' RESPONSIBILITY ID : ' || TO_CHAR ( X_SEC_REQ.RESOLVING_RESPONSIBILITY_ID ) ) ;
                            END IF;
/*   if (l_rslt = wfx_constraintsmanager_pub.G_error) then
      -- unexpected error occured in processing constraints API
       IF FND_MSG_PUB.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'ChkProcConstraints'
           ,'wfx_constraintsManager_pub.isOperationConstrained Returned unexpected error');
       END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    elsif (l_rslt =wfx_constraintsManager_pub.G_yes) --Security constraint exists,
                                                  -- Cancellation not permitted.
   then
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_result := FND_API.G_FALSE;
   else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_result := FND_API.G_TRUE;
  end if; */
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_result := FND_API.G_FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_result := FND_API.G_FALSE;
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'ChkProcConstraints');
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_result := FND_API.G_FALSE;
END ChkProcConstraints;

END;

/
