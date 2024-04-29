--------------------------------------------------------
--  DDL for Package Body PA_CC_IDENT_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_IDENT_CLIENT_EXTN" 
--  $Header: PACCIXTB.pls 120.1 2005/08/10 14:36:23 eyefimov noship $
AS


-- PROCEDURE OVERRIDE_PRVDR_RECVR (
--           P_PrvdrOrganizationId      IN  NUMBER,
--           P_PrvdrOrgId               IN  NUMBER,
--           P_RecvrOrganizationId      IN  NUMBER,
--           P_RecvrOrgId               IN  NUMBER,
--           P_TransId                  IN  NUMBER,
--           P_SysLink                  IN  VARCHAR2,
--           P_calling_mode          IN  VARCHAR2 default 'TRANSACTION',
--           X_Status                   IN OUT NOCOPY VARCHAR2,
--           X_PrvdrOrganizationId      IN OUT NOCOPY NUMBER,
--           X_RecvrOrganizationId      IN OUT NOCOPY NUMBER,
--           X_Error_Stage              OUT NOCOPY VARCHAR2,
--           X_Error_Code               OUT NOCOPY NUMBER)
-- IS
--
--  The following example gets the parent organization Id of the provider
--  and receiver organizations. If you want to run the sample code then
--  remove REM at the begining of the sample code and commemting out the
--  default.
--  NOTE : P_calling_mode is 'TRANSACTION' then P_TransId stores the expenditure_item_id
--         if P_calling_mode is 'TRANSACTION_IMPORT' then P_TransId stores the transaction_interface_id
--         which is unique on table pa_transaction_interface_all.
--         if P_calling_mode is 'FORECAST' the p_transid stores the value of forecast_item_id
--         so code your logic accordingly.
--
--   --
--   -- Sample code for provider and receiver organization override
--   --
--   -- The following cursor retrieves the parent organization
--   -- from the hierarchy that is used for the provider organization
--   -- that is passed in.
--   --
--
--   CURSOR C_PRVDR_OVERRIDE IS
--      SELECT se.ORGANIZATION_ID_PARENT
--        FROM per_org_structure_elements se,
--             pa_implementations_all i
--       WHERE i.EXP_ORG_STRUCTURE_VERSION_ID = se.ORG_STRUCTURE_VERSION_ID
--         AND i.ORG_ID  = P_PrvdrOrgId
--         AND se.ORGANIZATION_ID_CHILD = P_PrvdrOrganizationId ;
--
--   --
--   -- The following cursor retrieves the parent organization
--   -- from the hierarchy that is used for the receiver organization
--   -- that is passed in.
--   --
--
--   CURSOR C_RECVR_OVERRIDE IS
--      SELECT se.ORGANIZATION_ID_PARENT
--        FROM per_org_structure_elements se,
--             pa_implementations_all i
--       WHERE i.PROJ_ORG_STRUCTURE_VERSION_ID = se.ORG_STRUCTURE_VERSION_ID
--         AND i.ORG_ID  = P_RecvrOrgId
--         AND se.ORGANIZATION_ID_CHILD = P_RecvrOrganizationId ;
--
--   l_parent_prvdr_organization_id  NUMBER;
--   l_parent_recvr_organization_id  NUMBER;
--
-- BEGIN
--     --
--     -- Get the parent of the provider organization
--     --
--     OPEN c_prvdr_override ;
--     FETCH c_prvdr_override
--      INTO l_parent_prvdr_organization_id ;
--     IF c_prvdr_override%NOTFOUND THEN
--         l_parent_prvdr_organization_id := P_PrvdrOrganizationId ;
--     END IF;
--     CLOSE c_prvdr_override  ;
--
--     --
--     -- Get the parent of the receiver organization
--     --
--     OPEN c_recvr_override ;
--     FETCH c_recvr_override
--      INTO l_parent_recvr_organization_id ;
--     IF c_prvdr_override%NOTFOUND THEN
--         l_parent_recvr_organization_id := P_PrvdrOrganizationId ;
--     END IF;
--     CLOSE c_recvr_override  ;
--
--     X_PrvdrOrganizationId :=  l_parent_prvdr_organization_id ;
--     X_RecvrOrganizationId :=  l_parent_recvr_organization_id ;
--
--
-- EXCEPTION
--
-- WHEN OTHERS THEN
--      RAISE ;
--
-- END OVERRIDE_PRVDR_RECVR ;
-- /

--
-- Default code for provider and receiver organization override.
--
-- Default code returns the provider and receiver organizations that were passed into
-- the procedure.
--

PROCEDURE OVERRIDE_PRVDR_RECVR (
          P_PrvdrOrganizationId      IN  NUMBER,
          P_PrvdrOrgId               IN  NUMBER,
          P_RecvrOrganizationId      IN  NUMBER,
          P_RecvrOrgId               IN  NUMBER,
          P_TransId                  IN  NUMBER,
          P_SysLink                  IN  VARCHAR2,
	      P_calling_mode             IN  VARCHAR2 default 'TRANSACTION',
          X_Status                   IN OUT NOCOPY VARCHAR2,
          X_PrvdrOrganizationId      IN OUT NOCOPY NUMBER,
          X_RecvrOrganizationId      IN OUT NOCOPY NUMBER,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER)
IS


BEGIN

            pa_cc_utils.set_curr_function('PA_CC_IDENT_CLIENT_EXTN.OVERRIDE_PRVDR_RECVR');
            --
            -- Default code returns the provider organization and receiver organization
            -- that were passed to it.
            --
            IF pa_cc_utils.g_debug_mode THEN
               pa_cc_utils.log_message('20.10.170.10: Calling the custom code in client extension ');
            END IF;
            X_Error_Stage := 'Assigning the original values back to it';

            X_PrvdrOrganizationId :=  P_PrvdrOrganizationId ;
            X_RecvrOrganizationId :=  P_RecvrOrganizationId ;

            pa_cc_utils.reset_curr_function;

EXCEPTION

WHEN OTHERS THEN
     RAISE ;

END OVERRIDE_PRVDR_RECVR ;

--
-- -- The sample code for overriding processing method sets the cross charge
-- -- code to 'N' if the system linkage function is expense reports and the
-- -- the cost rate flag is 'Y'.
--  NOTE : P_calling_mode is 'TRANSACTION' then P_TransId stores the expenditure_item_id
--         P_TransDate will store expenditure_item_date
--         if P_calling_mode is 'TRANSACTION_IMPORT' then P_TransId stores the transaction_interface_id
--         which is unique on table pa_transaction_interface_all.
--         if P_calling_mode is 'FORECAST' then P_Transid stores the value of forecast_item_id
--         and P_TaskId  will be NULL,
--         P_TransDate   will be NULL,
--         P_TransSource will be NULL
--         so code your logic accordingly.
--
-- PROCEDURE OVERRIDE_CC_PROCESSING_METHOD (
--           P_PrvdrOrganizationId      IN  NUMBER,
--           P_RecvrOrganizationId      IN  NUMBER,
--           P_PrvdrOrgId               IN  NUMBER,
--           P_RecvrOrgId               IN  NUMBER,
--           P_PrvdrLEId                IN  NUMBER,
--           P_RecvrLEId                IN  NUMBER,
--           P_PersonId                 IN  NUMBER,
--           P_ProjectId                IN  NUMBER,
--           P_TaskId                   IN  NUMBER,
--           P_SysLink                  IN  VARCHAR2,
--           P_TransDate                IN  DATE,
--           P_TransSource              IN  VARCHAR2,
--           P_TransId                  IN  NUMBER,
--           P_CrossChargeCode          IN  VARCHAR2,
--           P_CrossChargeType          IN  VARCHAR2,
--           P_calling_mode             IN  VARCHAR2 default 'TRANSACTION',
--           X_OvrridCrossChargeCode    OUT NOCOPY VARCHAR2,
--           X_Status                   IN OUT NOCOPY VARCHAR2,
--           X_Error_Stage              OUT NOCOPY VARCHAR2,
--           X_Error_Code               OUT NOCOPY NUMBER)
-- IS
--
--  CURSOR C_get_cost_rate_flag IS
--      SELECT cost_rate_flag
--        FROM pa_expenditure_types et,
--             pa_expenditure_items_all ei
--       WHERE ei.expenditure_type = et.expenditure_type
--         AND ei.expenditure_item_id = P_ExpItemId ;
--
--  l_cr_flag      VARCHAR2(1);
--
-- BEGIN
--     IF P_calling_mode = 'TRANSACTION' then
--         OPEN C_get_cost_rate_flag;
--         FETCH C_get_cost_rate_flag
--         INTO l_cr_flag ;
--         IF l_cr_flag = 'Y' AND P_SysLink = 'ER' THEN
--               X_OvrridCrossChargeCode := 'N' ;
--         ELSE
--               X_OvrridCrossChargeCode := P_CrossChargeCode ;
--         END IF ;
--
--         CLOSE C_get_cost_rate_flag ;
--     ELSE
--          X_OvrridCrossChargeCode := P_CrossChargeCode ;
--     END IF;
--
-- EXCEPTION
--   WHEN OTHERS THEN
--      RAISE;
--
-- END OVERRIDE_CC_PROCESSING_METHOD ;
--

-- Default code for cross charge code override.
--
-- The default code returns the cross charge code that has been provided to it.
--
PROCEDURE OVERRIDE_CC_PROCESSING_METHOD (
          P_PrvdrOrganizationId      IN  NUMBER,
          P_RecvrOrganizationId      IN  NUMBER,
          P_PrvdrOrgId               IN  NUMBER,
          P_RecvrOrgId               IN  NUMBER,
          P_PrvdrLEId                IN  NUMBER,
          P_RecvrLEId                IN  NUMBER,
          P_PersonId                 IN  NUMBER,
          P_ProjectId                IN  NUMBER,
          P_TaskId                   IN  NUMBER,
          P_SysLink                  IN  VARCHAR2,
          P_TransDate                IN  DATE,
          P_TransSource              IN  VARCHAR2,
          P_TransId                  IN  NUMBER,
          P_CrossChargeCode          IN  VARCHAR2,
          P_CrossChargeType          IN  VARCHAR2,
          P_calling_mode             IN  VARCHAR2 default 'TRANSACTION',
          X_OvrridCrossChargeCode    OUT NOCOPY VARCHAR2,
          X_Status                   IN OUT NOCOPY VARCHAR2,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER)
IS

BEGIN

        pa_cc_utils.set_curr_function('PA_CC_IDENT_CLIENT_EXTN.OVR_CC_PROCESS');
        --
        -- Return the cross charge code that was passed into this procedure.
        --
        IF pa_cc_utils.g_debug_mode THEN
           pa_cc_utils.log_message('20.20.210.10: Calling custom code in client extension');
        END IF;

        X_OvrridCrossChargeCode   := P_CrossChargeCode ;

        pa_cc_utils.reset_curr_function;

EXCEPTION
  WHEN OTHERS THEN
     RAISE;

END OVERRIDE_CC_PROCESSING_METHOD ;

END PA_CC_IDENT_CLIENT_EXTN;

/
