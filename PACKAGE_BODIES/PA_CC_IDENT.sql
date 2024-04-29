--------------------------------------------------------
--  DDL for Package Body PA_CC_IDENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_IDENT" 
--  $Header: PACCINTB.pls 120.5 2006/06/30 16:00:10 eyefimov noship $
AS

G_PrevPrvdrOrgId        NUMBER;
G_PrevCCProcessIOCode   VARCHAR2(1);
G_PrevCCProcessIUCode   VARCHAR2(1);
G_PrevTaskId            NUMBER;
G_PrevSysLink           VARCHAR2(30);
G_PrevRecvrOrgnId       NUMBER;
G_PrevCCPrjProcessFlag  VARCHAR2(1);
G_PrevPrjOrgId          NUMBER;


P_DEBUG_MODE BOOLEAN     := pa_cc_utils.g_debug_mode;

PROCEDURE PRINT_MESSAGE(p_msg  varchar2) IS

BEGIN
        If p_msg is NOT NULL then
            --r_debug.r_msg(p_msg => p_msg);
            Null;
        End if;
        IF P_DEBUG_MODE  THEN
           pa_cc_utils.LOG_MESSAGE('PRINT_MESSAGE: ' || p_msg);
        END IF;


END PRINT_MESSAGE;

  -- This procedure will be called from Forcast API.
  -- This wrapper API is created over the main identify procedure.
  -- This API derives the provider,receiver orgs and assumes that
  -- to process the records in plsql tables the param x_statusTab should be null
  -- other wise it will be treated as a error records.
PROCEDURE PA_CC_IDENTIFY_TXN_FI(
          P_ExpOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpOrgidTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ProjectIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TaskIdTab                IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemDateTab           IN  PA_PLSQL_DATATYPES.DateTabTyp,
          P_ExpItemIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PersonIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpTypeTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_SysLinkTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_PrjOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrjOrgIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TransSourceTab           IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_NLROrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrvdrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
/* Added nocopy for 2672653 */
          X_StatusTab                IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          X_CrossChargeTypeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char3TabTyp,
          X_CrossChargeCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_PrvdrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrgIdTab            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_PrvdrOrgIdTab            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER) IS

        l_PrevProjectId              pa_projects_all.project_id%type := Null;
        l_project_org_id             pa_projects_all.org_id%type := Null;
        l_recvr_organization_id      pa_projects_all.org_id%type := Null;
        l_prev_recvr_organization_id pa_projects_all.org_id%type := Null;
        l_prev_cc_prj_process_flag   varchar2(10);
        l_cc_prj_process_flag        varchar2(10);
        l_PrevRecvrOrgId             pa_projects_all.org_id%type := Null;
        l_MinRecs                    PLS_INTEGER;
        l_MaxRecs                    PLS_INTEGER;
        l_current_process_io_code    pa_implementations_all.cc_process_io_code%type;
        l_current_process_iu_code    pa_implementations_all.cc_process_iu_code%type;
        l_PrevCCProcessIOCode        pa_implementations_all.cc_process_io_code%type;
        l_PrevCCProcessIUCode        pa_implementations_all.cc_process_iu_code%type;
        l_prevexporgid               pa_projects_all.org_id%type := Null;
        l_CCProcessIOCodeTab         PA_PLSQL_DATATYPES.Char1TabTyp;
        l_CCProcessIUCodeTab         PA_PLSQL_DATATYPES.Char1TabTyp;
        l_CCPrjFlagTab               PA_PLSQL_DATATYPES.Char1TabTyp;
        l_current_org_id             pa_projects_all.org_id%type := Null;
        l_PrevPrvdrOrgId             pa_projects_all.org_id%type := Null;


BEGIN
        pa_cc_utils.set_curr_function('PA_CC_IDENTIFY_TXN_FI');
        l_MinRecs  := P_SysLinkTab.FIRST;
        l_MaxRecs  := P_SysLinkTab.LAST;

        FOR j IN l_MinRecs..l_MaxRecs  LOOP
            IF X_StatusTab(j) IS NOT NULL THEN
                -- If the FIs  are already erroneous which will be indicated
                -- by this PL/SQL able then do not process CC identification for th at

                -- forecast items

                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.01: This FI is already erroneous and needs no CC identification');
                END IF;

                NULL ;

            ELSE
                --
                -- Determine Current Operating Unit
                --
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.02: Determine the Expenditure OU and its cross charge options');
                END IF;

               IF nvl(l_prevexporgid,-99) <> P_ExpOrgidTab(j) Then
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.03: Derive the cross charge options from pa_implementations');
                END IF;

                        SELECT imp.org_id,
                                nvl(imp.cc_process_io_code,'N'),
                                nvl(imp.cc_process_iu_code,'N')
                        INTO    l_current_org_id,
                                l_current_process_io_code,
                                l_current_process_iu_code
                        FROM pa_implementations_all imp
                        WHERE imp.org_id = P_ExpOrgidTab(j) ; -- bug 5365276
                        -- WHERE nvl(imp.org_id,-99)  = nvl( P_ExpOrgidTab(j), -99) ; -- bug 5365276


                        l_PrevPrvdrOrgId      := l_current_org_id ;
                        l_PrevCCProcessIOCode := l_current_process_io_code ;
                        l_PrevCCProcessIUCode := l_current_process_iu_code ;
                        l_prevexporgid        := P_ExpOrgidTab(j);

               ELSE

                        IF P_DEBUG_MODE  THEN
                           pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.04: Retrive cross charge options from cache');
                        END IF;
                        l_current_org_id := l_PrevPrvdrOrgId;
                        l_current_process_io_code := l_PrevCCProcessIOCode;
                        l_current_process_iu_code := l_PrevCCProcessIUCode;

               END IF;

                --
                -- End get current operating unit
                --
               IF nvl(l_PrevProjectId,-99) <> P_ProjectIdTab(j) THEN
                   --
                   -- If the current project id is the same as the previous project id

                   -- then we do not need to join to the projects table to get the project

                   -- org id which is the receiver OU.
                   --
                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.05: Derive receiving org id for the given project');
                   END IF;


                   SELECT  p.carrying_out_organization_id,
                           decode(sl.LABOR_NON_LABOR_FLAG,
                                     'Y', p.cc_process_labor_flag,
                                          p.cc_process_nl_flag)
                     INTO  l_recvr_organization_id,
                           l_cc_prj_process_flag
                     FROM  pa_system_linkages sl,
                           pa_projects_all p
                    WHERE  p.project_id   = P_ProjectIdTab(j)
                      AND  sl.function = P_SysLinkTab(j) ;

                   l_PrevProjectId             := P_ProjectIdTab(j);
                   l_prev_recvr_organization_id := l_recvr_organization_id;
                   l_prev_cc_prj_process_flag   := l_cc_prj_process_flag;


               ELSE
                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.06: Retreive  receiving org id cache');
                   END IF;

                   l_recvr_organization_id := l_prev_recvr_organization_id;
                   l_cc_prj_process_flag   := l_prev_cc_prj_process_flag;


               END IF;

                --Assign the out varialbe with the derived values
                l_CCPrjFlagTab(j)           := l_cc_prj_process_flag;
                l_CCProcessIUCodeTab(j)     := l_current_process_iu_code;
                l_CCProcessIOCodeTab(j)     := l_current_process_io_code;
                X_PrvdrOrganizationIdTab(j) := P_ExpOrganizationIdTab(j);
                X_RecvrOrganizationIdTab(j) := l_recvr_organization_id ;
                X_RecvrOrgIdTab(j)          := P_PrjOrgIdTab(j);
                X_PrvdrOrgIdTab(j)          := l_current_org_id;

                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message
                ('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.07: Calling Client Extension to override the PRVDR_RECVR orgs');
                END IF;

                -- Call client extension to override the provider and receiver organizations.
                PA_CC_IDENT_CLIENT_EXTN.OVERRIDE_PRVDR_RECVR (
                P_PrvdrOrganizationId   => X_PrvdrOrganizationIdTab(j),
                P_PrvdrOrgId            => P_ExpOrgidTab(j),
                P_RecvrOrganizationId   => X_RecvrOrganizationIdTab(j),
                P_RecvrOrgId            => X_RecvrOrgIdTab(j),
                P_TransId               => P_ExpItemIdTab(j),
                P_SysLink               => P_SysLinkTab(j),
                P_calling_mode          => 'FORECAST',
                X_Status                => X_StatusTab(j),
                X_PrvdrOrganizationId   => X_PrvdrOrganizationIdTab(j),
                X_RecvrOrganizationId   => X_RecvrOrganizationIdTab(j),
                X_Error_Stage           => X_Error_Stage,
                X_Error_Code            => X_Error_Code );

        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || 'P_ProjectIdTab='||P_ProjectIdTab(j)||'P_PrvdrOrganizationId='||X_PrvdrOrganizationIdTab(j)
			||'X_RecvrOrganizationIdTab='||X_RecvrOrganizationIdTab(j)||'X_RecvrOrgIdTab='
			||X_RecvrOrgIdTab(j)||'P_SysLinkTab='||P_SysLinkTab(j)
			||'l_CCPrjFlagTab='||l_CCPrjFlagTab(j)||'l_CCProcessIUCodeTab='
			||l_CCProcessIUCodeTab(j)||'l_CCProcessIOCodeTab='||l_CCProcessIOCodeTab(j));
           pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.08: End of  Client Extension to override the PRVDR_RECVR orgs');
        END IF;

	END IF; -- end of status_tab

    END LOOP;
        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.09: Calling PA_CC_GET_CROSS_CHARGE_TYPE api');
        END IF;


        PA_CC_IDENT.PA_CC_GET_CROSS_CHARGE_TYPE (
          P_PrvdrOrganizationIdTab   => X_PrvdrOrganizationIdTab
          ,P_RecvrOrganizationIdTab   => X_RecvrOrganizationIdTab
          ,P_ProjectIdTab             => P_ProjectIdTab
          ,P_TaskIdTab                => P_TaskIdTab
          ,P_SysLinkTab               => P_SysLinkTab
          ,P_ExpItemIdTab             => P_ExpItemIdTab
          ,P_PersonIdTab              => P_PersonIdTab
          ,P_ExpItemDateTab           => P_ExpItemDateTab
          ,P_PrvdrOrgIdTab            => P_ExpOrgidTab
          ,P_RecvrOrgIdTab            => X_RecvrOrgIdTab
          ,P_PrvdrLEIdTab             => P_PrvdrLEIdTab
          ,P_RecvrLEIdTab             => P_RecvrLEIdTab
          ,P_TransSourceTab           => P_TransSourceTab
          ,P_CCProcessIOCodeTab       => l_CCProcessIOCodeTab
          ,P_CCProcessIUCodeTab       => l_CCProcessIUCodeTab
          ,P_CCPrjFlagTab             => l_CCPrjFlagTab
          ,P_calling_mode             => 'FORECAST'
          ,X_StatusTab                => X_StatusTab
          ,X_CrossChargeTypeTab       => X_CrossChargeTypeTab
          ,X_CrossChargeCodeTab       => X_CrossChargeCodeTab
          ,X_Error_Stage              => X_Error_Stage
          ,X_Error_Code               => X_Error_Code );
        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_FI: ' || '20.05.10: End of PA_CC_GET_CROSS_CHARGE_TYPE api');
        END IF;

    pa_cc_utils.reset_curr_function;

EXCEPTION

  WHEN OTHERS THEN
        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('Failed in PA_CC_IDENTIFY_TXN_FI Error:'||SQLCODE||SQLERRM);
        END IF;
     RAISE ;

END PA_CC_IDENTIFY_TXN_FI;

PROCEDURE PA_CC_IDENTIFY_TXN_ADJ (
          P_ExpOrganizationId    IN  NUMBER,
          P_ExpOrgid             IN  NUMBER,
          P_ProjectId            IN  NUMBER,
          P_TaskId               IN  NUMBER,
          P_ExpItemDate          IN  DATE,
          P_ExpItemId            IN  NUMBER,
          P_ExpType              IN  VARCHAR2,
          P_PersonId             IN  NUMBER,
          P_SysLink              IN  VARCHAR2,
          P_PrjOrganizationId    IN  NUMBER,
          P_PrjOrgId             IN  NUMBER,
          P_TransSource          IN  VARCHAR2,
          P_NLROrganizationId    IN  NUMBER,
          P_PrvdrLEId            IN  NUMBER,
          P_RecvrLEId            IN  NUMBER,
          X_Status               IN OUT NOCOPY VARCHAR2,
          X_CrossChargeType      IN OUT NOCOPY VARCHAR2,
          X_CrossChargeCode      IN OUT NOCOPY VARCHAR2,
          X_PrvdrOrganizationId  IN OUT NOCOPY NUMBER,
          X_RecvrOrganizationId  IN OUT NOCOPY NUMBER,
          X_RecvrOrgId           IN OUT NOCOPY NUMBER,
          X_Error_Stage          OUT NOCOPY VARCHAR2,
          X_Error_Code           OUT NOCOPY NUMBER,
  	  /* Added calling module for 3234973 */
	  X_Calling_Module           IN VARCHAR2)

IS

  -- This procedure will be called by adjustments. Because adjustments will
  -- not pass the values as tables, this wrapper procedure is created over
  -- the main identify procedure. This procedure will assign the values passed
  -- to tables and then call the main identify procedure.

  -- The following PL/SQL tables are created to store the values passed in to
  -- this procedure.

  l_ExpOrganizationIdTab       PA_PLSQL_DATATYPES.IdTabTyp;
  l_ExpOrgIdTab                PA_PLSQL_DATATYPES.IdTabTyp;
  l_ProjectIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  l_TaskIdTab                  PA_PLSQL_DATATYPES.IdTabTyp;
  l_ExpItemDateTab             PA_PLSQL_DATATYPES.DateTabTyp;
  l_ExpItemIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  l_PersonIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_ExpTypeTab                 PA_PLSQL_DATATYPES.Char30TabTyp;
  l_SysLinkTab                 PA_PLSQL_DATATYPES.Char30TabTyp;
  l_PrjOrganizationIdTab       PA_PLSQL_DATATYPES.IdTabTyp;
  l_PrjorgIdTab                PA_PLSQL_DATATYPES.IdTabTyp;
  l_TransSourceTab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_NLROrganizationIdTab       PA_PLSQL_DATATYPES.IdTabTyp;
  l_PrvdrLEIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  l_RecvrLEIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  l_CrossChargeTypeTab         PA_PLSQL_DATATYPES.Char3TabTyp;
  l_CrossChargeCodeTab         PA_PLSQL_DATATYPES.Char1TabTyp;
  l_CCProcessIOCodeTab         PA_PLSQL_DATATYPES.Char1TabTyp;
  l_CCProcessIUCodeTab         PA_PLSQL_DATATYPES.Char1TabTyp;
  l_PrvdrOrganizationIdTab     PA_PLSQL_DATATYPES.IdTabTyp;
  l_RecvrOrganizationIdTab     PA_PLSQL_DATATYPES.IdTabTyp;
  l_PrvdrOrgIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_RecvrOrgIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_Error_Stage                VARCHAR2(2000);
  l_Error_Code                 NUMBER;
  l_StageTab                   PA_PLSQL_DATATYPES.NewAmtTabTyp;
  l_StatusTab                  PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN

      -- Assign all the input values to the tables. These tables will be passed
      -- to the the main identification procedure.

      pa_cc_utils.set_curr_function('PA_CC_IDENTIFY_TXN_ADJ');
      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_ADJ: ' || '10: Assign all the input values to the tables');
      END IF;

      l_ExpOrganizationIdTab(1)   := P_ExpOrganizationId ;
      l_ExpOrgIdTab(1)            := P_ExpOrgId ;
      l_ProjectIdTab(1)           := P_ProjectId;
      l_TaskIdTab(1)              := P_TaskId;
      l_ExpItemDateTab(1)         := P_ExpItemDate;
      l_ExpItemIdTab(1)           := P_ExpItemId;
      l_PersonIdTab(1)          := P_PersonId;
      l_ExpTypeTab(1)             := P_ExpType;
      l_SysLinkTab(1)             := P_SysLink;
      l_PrjOrganizationIdTab(1)   := P_PrjOrganizationId;
      l_PrjorgIdTab(1)            := P_PrjorgId;
      l_TransSourceTab(1)         := P_TransSource;
      l_NLROrganizationIdTab(1)   := P_NLROrganizationId;
      l_PrvdrLEIdTab(1)           := NULL ;
      l_RecvrLEIdTab(1)           := NULL ;
      l_StatusTab(1)              := NULL ;
      l_Error_Stage               := X_Error_Stage;
      l_Error_Code                := X_Error_Code;

      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_ADJ: ' || '20: Calling procedure PA_CC_IDENT.PA_CC_IDENTIFY_TXN');
      END IF;

      PA_CC_IDENT.PA_CC_IDENTIFY_TXN(
          P_ExpOrganizationIdTab    => l_ExpOrganizationIdTab,
          P_ExpOrgidTab             => l_ExpOrgidTab,
          P_ProjectIdTab            => l_ProjectIdTab,
          P_TaskIdTab               => l_TaskIdTab,
          P_ExpItemDateTab          => l_ExpItemDateTab,
          P_ExpItemIdTab            => l_ExpItemIdTab,
          P_PersonIdTab             => l_PersonIdTab,
          P_ExpTypeTab              => l_ExpTypeTab,
          P_SysLinkTab              => l_SysLinkTab,
          P_PrjOrganizationIdTab    => l_PrjOrganizationIdTab,
          P_PrjOrgIdTab             => l_PrjOrgIdTab,
          P_TransSourceTab          => l_TransSourceTab,
          P_NLROrganizationIdTab    => l_NLROrganizationIdTab,
          P_PrvdrLEIdTab            => l_PrvdrLEIdTab,
          P_RecvrLEIdTab            => l_RecvrLEIdTab,
          X_StatusTab               => l_StatusTab,
          X_CrossChargeTypeTab      => l_CrossChargeTypeTab,
          X_CrossChargeCodeTab      => l_CrossChargeCodeTab,
          X_PrvdrOrganizationIdTab  => l_PrvdrOrganizationIdTab,
          X_RecvrOrganizationIdTab  => l_RecvrOrganizationIdTab,
          X_RecvrOrgIdTab           => l_RecvrOrgIdTab,
          X_Error_Stage             => l_Error_Stage,
          X_Error_Code              => l_Error_Code,
  	  /* Added calling module for 3234973 */
	  X_Calling_Module          =>  X_Calling_Module);

      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN_ADJ: ' || '30: Assigning the returned values to the output variables');
      END IF;

      X_status                   := l_StatusTab(1);
      X_CrossChargeType          := l_CrossChargeTypeTab(1);
      X_CrossChargeCode          := l_CrossChargeCodeTab(1);
      X_PrvdrOrganizationId      := l_PrvdrOrganizationIdTab(1);
      X_RecvrOrganizationId      := l_RecvrOrganizationIdTab(1);
      X_RecvrOrgId               := l_RecvrOrgIdTab(1);

      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('40: Exiting the procedure PA_CC_IDENT.PA_CC_IDENTIFY_TXN_ADJ');
      END IF;

      pa_cc_utils.reset_curr_function;
EXCEPTION

  WHEN OTHERS THEN
     x_error_stage := l_error_stage;
     x_error_code := l_error_code;
     RAISE ;

END PA_CC_IDENTIFY_TXN_ADJ;

PROCEDURE PA_CC_IDENTIFY_TXN(
          P_ExpOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpOrgidTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ProjectIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TaskIdTab                IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemDateTab           IN  PA_PLSQL_DATATYPES.DateTabTyp,
          P_ExpItemIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PersonIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpTypeTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_SysLinkTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_PrjOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrjOrgIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TransSourceTab           IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_NLROrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrvdrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
/* Added nocopy for 2672653 */
          X_StatusTab                IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          X_CrossChargeTypeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char3TabTyp,
          X_CrossChargeCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_PrvdrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrgIdTab            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER,
  	  /* Added calling module for 3234973 */
	  X_Calling_Module           IN VARCHAR2)

IS

  l_CCProcessIOCodeTab         PA_PLSQL_DATATYPES.Char1TabTyp;
  l_CCProcessIUCodeTab         PA_PLSQL_DATATYPES.Char1TabTyp;
  l_CCPrjFlagTab               PA_PLSQL_DATATYPES.Char1TabTyp;


    l_CCProcessIOCode          VARCHAR2(1);
    l_CCProcessIUCode          VARCHAR2(1);
    l_CCPrjFlag                VARCHAR2(1);

BEGIN

      --
      -- This procedure is called for determining the following attributes of
      -- a transactions
      --   1. Provider Organization
      --   2. Receiver Organization
      --   3. Provider Operating Unit
      --   4. Receiver Operating Unit

      pa_cc_utils.set_curr_function('PA_CC_IDENTIFY_TXN');

      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN: ' || '20.10: Calling the procedure to determine the orgs');
      END IF;

      PA_CC_IDENT.PA_CC_GET_PRVDR_RECVR_ORGS (
           P_ExpOrganizationIdTab   => P_ExpOrganizationIdTab,
           P_ExpOrgidTab            => P_ExpOrgidTab,
           P_TaskIdTab              => P_TaskIdTab,
           P_ExpItemIdTab           => P_ExpItemIdTab,
           P_SysLinkTab             => P_SysLinkTab,
           P_ProjectIdTab           => P_ProjectIdTab,
           P_NLROrganizationIdTab   => P_NLROrganizationIdTab,
           P_ExpItemDateTab         => P_ExpItemDateTab,
           P_ExpTypeTab             => P_ExpTypeTab,
           P_PrjOrganizationIdTab   => P_PrjOrganizationIdTab,
           P_PrjOrgIdTab            => P_PrjOrgIdTab,
           X_StatusTab              => X_StatusTab,
           X_PrvdrOrganizationIdTab => X_PrvdrOrganizationIdTab,
           X_RecvrOrganizationIdTab => X_RecvrOrganizationIdTab,
           X_RecvrOrgIdTab          => X_RecvrOrgIdTab,
           X_CCProcessIOCodeTab     => l_CCProcessIOCodeTab,
           X_CCProcessIUCodeTab     => l_CCProcessIUCodeTab,
           X_CCPrjFlagTab           => l_CCPrjFlagTab,
           X_Error_Stage            => X_Error_Stage,
           X_Error_Code             => X_Error_Code,
   	   /* Added calling module for 3234973 */
	   X_Calling_Module         => X_Calling_Module);

      --
      -- This procedure is called for determining the cross charge code.
      --

      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('PA_CC_IDENTIFY_TXN: ' || '20.20: Calling the procedure to determine the cross charge code and type');
      END IF;

      PA_CC_IDENT.PA_CC_GET_CROSS_CHARGE_TYPE (
           P_PrvdrOrganizationIdTab => X_PrvdrOrganizationIdTab,
           P_RecvrOrganizationIdTab => X_RecvrOrganizationIdTab,
           P_ProjectIdTab           => P_ProjectIdTab,
           P_TaskIdTab              => P_TaskIdTab,
           P_SysLinkTab             => P_SysLinkTab,
           P_ExpItemIdTab           => P_ExpItemIdTab,
           P_PersonIdTab          => P_PersonIdTab,
           P_ExpItemDateTab         => P_ExpItemDateTab,
           P_PrvdrOrgIdTab          => P_ExpOrgidTab,
           P_RecvrOrgIdTab          => X_RecvrOrgIdTab,
           P_PrvdrLEIdTab           => P_PrvdrLEIdTab,
           P_RecvrLEIdTab           => P_RecvrLEIdTab,
           P_TransSourceTab         => P_TransSourceTab,
           P_CCProcessIOCodeTab     => l_CCProcessIOCodeTab,
           P_CCProcessIUCodeTab     => l_CCProcessIUCodeTab,
           P_CCPrjFlagTab           => l_CCPrjFlagTab,
	   /* Passing calling module instead of hard coded 'TRANSACTION' for 3234973 */
	   P_calling_mode           => X_Calling_Module,
           X_StatusTab              => X_StatusTab,
           X_CrossChargeTypeTab     => X_CrossChargeTypeTab,
           X_CrossChargeCodeTab     => X_CrossChargeCodeTab,
           X_Error_Stage            => X_Error_Stage,
           X_Error_Code             => X_Error_Code);

       pa_cc_utils.reset_curr_function;

EXCEPTION

  WHEN OTHERS THEN
     RAISE ;

END PA_CC_IDENTIFY_TXN;

PROCEDURE PA_CC_GET_PRVDR_RECVR_ORGS (
          P_ExpOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpOrgidTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TaskIdTab                IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_SysLinkTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_ProjectIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_NLROrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemDateTab           IN  PA_PLSQL_DATATYPES.DateTabTyp,
          P_ExpTypeTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_PrjOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrjOrgIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
/* Added nocopy for 2672653 */
          X_StatusTab                IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          X_PrvdrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrgIdTab            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_CCProcessIOCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_CCProcessIUCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_CCPrjFlagTab             IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER,
  	  /* Added calling module for 3234973 */
	  X_Calling_Module           IN VARCHAR2) IS

----------------------------------------------------------------------------------------
    -- These variables store the values during the previous iteration. These values are
    -- compared with the values in the current iteration. Only if the values are different
    -- the required SELECT is performed. Otherwise the previous results are used as the
    -- current results

    l_PrevTaskId                             NUMBER;
    l_PrevRecvrOrganizationId                NUMBER;
    l_PrevRecvrOrgId                         NUMBER;
    l_PrevPrvdrOrgId                         NUMBER;
    l_PrevProjectId                          NUMBER;
    l_PrevCCPrjFlag                          VARCHAR2(1);
----------------------------------------------------------------------------------------
    l_MaxRecs                                NUMBER;
    l_MinRecs                                NUMBER;
    l_Recvr_Organization_Id                  NUMBER;
    l_Prvdr_Organization_Id                  NUMBER;
    l_project_Org_Id                         NUMBER;
    l_current_org_id                         NUMBER;
    l_cc_prj_process_flag                    VARCHAR2(1);
    l_cc_process_io_code                     VARCHAR2(1);
    l_cc_process_iu_code                     VARCHAR2(1);
    l_current_process_io_code                VARCHAR2(1);
    l_current_process_iu_code                VARCHAR2(1);
    l_PrevCCProcessIOCode                    VARCHAR2(1);
    l_PrevCCProcessIUCode                    VARCHAR2(1);

BEGIN

    l_MinRecs  := P_SysLinkTab.FIRST;
    l_MaxRecs  := P_SysLinkTab.LAST;

    pa_cc_utils.set_curr_function('PA_CC_GET_PRVDR_RECVR_ORGS');

    --
    -- Determine Current Operating Unit
    --
    -- Expenditure Operating Unit is the OU in which the expenditure item is created. If
    -- it is not passed to this procedure then the current operating unit is used as the
    -- Expenditure Operating Unit. But usually the Expenditure Operating Unit is passed
    -- to the procedure except Transaction Import.
    --

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.10: Determine the Expenditure OU and its cross charge options');
       print_message('G_PrevCCProcessIOCode=' ||G_PrevCCProcessIOCode);
       print_message('l_current_org_id=' ||l_current_org_id);
       print_message('l_current_process_io_code=' ||l_current_process_io_code);
       print_message('l_current_process_iu_code=' ||l_current_process_iu_code);
    END IF;

    If G_PrevCCProcessIOCode is NULL Then

       IF P_DEBUG_MODE THEN
          print_message('Selecting from pa_implementaions');
       END IF;

       SELECT imp.org_id,
               nvl(imp.cc_process_io_code,'N'),
               nvl(imp.cc_process_iu_code,'N')
         INTO l_current_org_id,
              l_current_process_io_code,
              l_current_process_iu_code
         FROM pa_implementations imp ;

       G_PrevPrvdrOrgId      := l_current_org_id ;
       G_PrevCCProcessIOCode := l_current_process_io_code ;
       G_PrevCCProcessIUCode := l_current_process_iu_code ;

    Else
       l_current_org_id := G_PrevPrvdrOrgId;/* 3933401 */
       l_current_process_io_code := G_PrevCCProcessIOCode;/* 3933401 */
       l_current_process_iu_code := G_PrevCCProcessIUCode;/* 3933401 */

    End If;

       l_PrevPrvdrOrgId      := G_PrevPrvdrOrgId ;
       l_PrevCCProcessIOCode := G_PrevCCProcessIOCode ;
       l_PrevCCProcessIUCode := G_PrevCCProcessIUCode ;

    IF P_DEBUG_MODE THEN
       print_message('After l_current_org_id=' ||l_current_org_id);
       print_message('l_current_process_io_code=' ||l_current_process_io_code);
       print_message('l_current_process_iu_code=' ||l_current_process_iu_code);
    END IF;

    --
    -- End get current operating unit
    --

    --
    --
    FOR j IN l_MinRecs..l_MaxRecs
    LOOP
        IF X_StatusTab(j) IS NOT NULL THEN
            -- If the expenditure items are already erroneous which will be indicated
            -- by this PL/SQL able then do not process CC identification for that
            -- expenditure item

            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.20: This expenditure item is already erroneous and needs no CC identification');
            END IF;
            NULL ;

        ELSE
            --
            -- Initialize local variables
            --
            l_project_org_id := NULL ;

            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.30: Determine Provider Organization');
            END IF;

            -- Determine Provider Organization
            --
            --
            -- The provider organization is Non-Labor Organization if the system linkage
            -- is a Usage and Expenditure organization for the others
            --
            X_Error_Stage := 'Checking if system linkage function is Usage';
            IF P_SysLinkTab(j) = 'USG' THEN
               -- If the system_linkage_function is  'USG' the provider  organization
               -- will be the non-labor resource organization of the resource.  So if

               X_Error_Stage := 'Checking if NLR organization id is NULL for usages';
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' ||  '20.10.40: Checking if NLR organization id is NULL for usages');
               END IF;
               IF P_NLROrganizationIdTab(j) IS NULL THEN
                  -- So if non-labor resource organization is not provided then an error
                  -- code is returned.

                  IF P_DEBUG_MODE  THEN
                     pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.50: Setting the error code for null NLR organization Id');
                  END IF;
                  X_Error_Stage := 'Setting the error code for null NLR organization Id';
                  X_StatusTab(j) := 'PA_CC_NO_NL_ORG_FOR_USG';
               ELSE
                  -- Return non-labor resource organization as the provider organization.

                  IF P_DEBUG_MODE  THEN
                     pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.60: Returning the NLR organization Id');
                  END IF;
                  X_Error_Stage := 'Returning the NLR organization Id';
                  l_Prvdr_Organization_Id :=  P_NLROrganizationIdTab(j);
               END IF;

            ELSE
               -- Else the provider organization is the expenditure organization. Return
               -- expenditure organization as provider organization.

               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.70: Returning the expenditure organization id');
               END IF;
               X_Error_Stage := 'Returning the expenditure organization id';
               l_Prvdr_Organization_Id :=  P_ExpOrganizationIdTab(j);
            END IF;

            -- Determine Receiver Organization
            --
            --
            -- Receiver Organization is the organization that owns the task
            -- ( Carrying_Out_Organization_Id). In this select we also

            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.80: Checking if current task id is the same as the previous task id');
            END IF;
            X_Error_Stage := 'Checking if project OU is NULL';
            IF l_PrevTaskId = P_TaskIdTab(j) THEN
               -- If the current task id is the same as the previous task id then
               -- the receiver organization and receiver operating unit will be
               -- the same as previous one

               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.90: current task id is the same as the previous task id');
               END IF;
               l_Recvr_Organization_Id     := l_PrevRecvrOrganizationId ;
               l_project_org_id            := l_PrevRecvrOrgId ;
               l_cc_prj_process_flag       := l_PrevCCPrjFlag ;


            ELSE
               -- If the current task id is not the same as the previous task id
               -- then select the new receiver organization and receiver operating
               -- unit
               -- In this select we also get the project operating unit if it is not
               -- passed to this procedure. This is done so that we can avoid an
               -- extra SELECT later on while deriving the value of Provider OU.

               X_Error_Stage := 'Checking if current project id is the same as the previous project id' ;

               IF l_PrevProjectId = P_ProjectIdTab(j) THEN
                   --
                   -- If the current project id is the same as the previous project id
                   -- then we do not need to join to the projects table to get the project
                   -- org id which is the receiver OU.
                   --
                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.100: If current project id is the same as the previous project id do not join to projects table');
                   END IF;

                  If (G_PrevTaskId = P_TaskIdTab(j) and G_PrevSysLink = P_SysLinkTab(j)) Then

                     l_recvr_organization_id := G_PrevRecvrOrgnId;
                     l_cc_prj_process_flag   := G_PrevCCPrjProcessFlag;

                  Else
                   SELECT  t.carrying_out_organization_id,
                           decode(sl.LABOR_NON_LABOR_FLAG,
                                     'Y', t.cc_process_labor_flag,
                                          t.cc_process_nl_flag)
                     INTO  l_recvr_organization_id,
                           l_cc_prj_process_flag
                     FROM  pa_system_linkages sl,
                           pa_tasks t
                    WHERE  t.task_id   = P_TaskIdTab(j)
                      AND  sl.function = P_SysLinkTab(j) ;

                    G_PrevTaskId           := P_TaskIdTab(j);
                    G_PrevSysLink          := P_SysLinkTab(j);
                    G_PrevRecvrOrgnId      := l_recvr_organization_id;
                    G_PrevCCPrjProcessFlag := l_cc_prj_process_flag;

                   End If;

                   l_project_org_id            := l_PrevRecvrOrgId ;

               ELSE
                   --
                   -- If the current project id is not the same as the previous project
                   -- id the we need to join to the projects table to get the project
                   -- org id also.
                   --

                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.110: If current project id is not the same as the previous project id join to projects table to get org_id');
                   END IF;

		   BEGIN -- 2650361

                   SELECT  t.carrying_out_organization_id,
                           p.org_id,
                           decode(sl.LABOR_NON_LABOR_FLAG,
                                     'Y', t.cc_process_labor_flag,
                                          t.cc_process_nl_flag)
                     INTO  l_recvr_organization_id,
                           l_project_org_id,
                           l_cc_prj_process_flag
                     FROM  pa_system_linkages sl,
                           pa_projects_all p,
                           pa_tasks t
                    WHERE  p.project_id = t.project_id
                      AND  t.task_id   = P_TaskIdTab(j)
                      AND  sl.function = P_SysLinkTab(j) ;
/* Adding exception handling for 2650361 */
		    EXCEPTION
			   WHEN   NO_DATA_FOUND THEN
		    IF P_DEBUG_MODE  THEN
		       pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.115: Setting the rejection code to INV_DATA when no data found');
		    END IF;
			   UPDATE pa_expenditure_items_all
			   SET    cost_dist_rejection_code = 'INV_DATA'
			   WHERE  task_id = P_TaskIdTab(j)
			   AND    cost_distributed_flag = 'S'
			   AND    cost_dist_rejection_code is null;
		    END;
/* 2650361 */

                    G_PrevTaskId           := P_TaskIdTab(j);
                    G_PrevSysLink          := P_SysLinkTab(j);
                    G_PrevRecvrOrgnId      := l_recvr_organization_id;
                    G_PrevCCPrjProcessFlag := l_cc_prj_process_flag;
                    G_PrevPrjOrgId         := l_project_org_id;

               END IF;

               l_PrevRecvrOrgId          := l_project_org_id ;
               l_PrevRecvrOrganizationId := l_recvr_organization_id ;
               l_PrevCCPrjFlag           := l_cc_prj_process_flag   ;

            END IF;

            -- Determine Provider Operating Unit
            --
            --
            -- The Operating Unit in which the Expenditure is charged. In this case it is the
            -- same as p_expenditure_org_id.

            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.120: Determine the cross charge process codes in implementations');
            END IF;
            X_Error_Stage := 'Determine the cross charge process codes in implementations';

            --
            -- Also determine the cross charge process codes in implementations
            --

            IF nvl(l_PrevPrvdrOrgId,-99) = nvl(P_ExpOrgidTab(j),-99) THEN
            /* bug#3167296 added nvlto handle single org case, please note that single org case
             was handled before this fix also using l_current_org_id is null condition below
             first time its fine but second time it fails because l_current_process_io_code
             being not available, after fix it works first as well as subsequent time */

               --
               -- If the current operating unit is the same as the previous operating
               -- unit then we can use the same implementation options as that of the
               -- previous one
               --
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.130: If expenditure OUs are not changed use previous values');
                END IF;

                l_cc_process_io_code := l_PrevCCProcessIOCode  ;
                l_cc_process_iu_code := l_PrevCCProcessIUCode  ;
                IF P_DEBUG_MODE THEN
                   print_message('l_cc_process_io_code=' ||l_cc_process_io_code);
                   print_message('l_cc_process_iu_code=' ||l_cc_process_iu_code);
                END IF;
            ELSE
                IF l_current_org_id IS NULL THEN
                    --
                    -- If the current operating unit is null then it is a single org
                    -- implementation. For the single org implementation we use the
                    -- same implementation options that were used at the start of the
                    -- procedure.
                    --

                    IF P_DEBUG_MODE  THEN
                       pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.140: Expenditure OU is the same as current OU ');
                    END IF;
                    l_cc_process_io_code := l_current_process_io_code ;
                    l_cc_process_iu_code := l_current_process_iu_code ;

                ELSE
                    IF P_DEBUG_MODE  THEN
                       pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.150: Determine cross charge codes of current Expenditure OU');
                    END IF;

                    SELECT nvl(imp.cc_process_io_code,'N'),
                           nvl(imp.cc_process_iu_code,'N')
                      INTO l_cc_process_io_code,
                           l_cc_process_iu_code
                      FROM pa_implementations_all imp
                     WHERE imp.org_id = nvl(P_ExpOrgidTab(j), l_current_org_id) ;

                END IF;
                IF P_DEBUG_MODE THEN
                   print_message('l_cc_process_io_code=' ||l_cc_process_io_code);
                   print_message('l_cc_process_iu_code=' ||l_cc_process_iu_code);
                END IF;

            END IF ;

            l_PrevCCProcessIUCode    := l_cc_process_iu_code ;
            l_PrevCCProcessIOCode    := l_cc_process_io_code ;
            X_CCProcessIUCodeTab(j)  := l_cc_process_iu_code ;
            X_CCProcessIOCodeTab(j)  := l_cc_process_io_code ;

            --
            -- Determine Receiver Operating Unit
            --
            --

            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.160: Determine Receiver Operating Unit');
            END IF;

            X_Error_Stage := 'Assigning the project OU as provider OU';
            X_PrvdrOrganizationIdTab(j) := l_Prvdr_Organization_Id ;
            X_RecvrOrganizationIdTab(j) := l_recvr_organization_id ;

            l_PrevPrvdrOrgId   :=  P_ExpOrgidTab(j);
            X_RecvrOrgIdTab(j) := NVL(  P_PrjOrgIdTab(j), l_project_org_id);
            X_CCPrjFlagTab(j)     := l_cc_prj_process_flag;

        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.170: Calling the client extension PA_CC_IDENT_CLIENT_EXTN.OVERRIDE_PRVDR_RECVR');
        END IF;

        PA_CC_IDENT_CLIENT_EXTN.OVERRIDE_PRVDR_RECVR (
          P_PrvdrOrganizationId   => X_PrvdrOrganizationIdTab(j),
          P_PrvdrOrgId            => P_ExpOrgidTab(j),
          P_RecvrOrganizationId   => X_RecvrOrganizationIdTab(j),
          P_RecvrOrgId            => X_RecvrOrgIdTab(j),
          P_TransId               => P_ExpItemIdTab(j),
          P_SysLink               => P_SysLinkTab(j),
          X_Status                => X_StatusTab(j),
          X_PrvdrOrganizationId   => X_PrvdrOrganizationIdTab(j),
          X_RecvrOrganizationId   => X_RecvrOrganizationIdTab(j),
          X_Error_Stage           => X_Error_Stage,
          X_Error_Code            => X_Error_Code,
  	  /* Added calling module for 3234973
          P_calling_mode          => 'TRANSACTION', */
	  P_calling_mode          => X_Calling_Module);

        END IF;

        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.180: After determining the orgs for this transaction');
           print_message('Exiting..l_cc_process_io_code=' ||l_cc_process_io_code);
           print_message('l_cc_process_iu_code=' ||l_cc_process_iu_code);
        END IF;
    END LOOP;

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('PA_CC_GET_PRVDR_RECVR_ORGS: ' || '20.10.180: After determining the orgs for the bulk of transactions');
    END IF;

    pa_cc_utils.reset_curr_function;

EXCEPTION

WHEN OTHERS THEN
     RAISE ;

END PA_CC_GET_PRVDR_RECVR_ORGS ;

PROCEDURE PA_CC_GET_CROSS_CHARGE_TYPE (
          P_PrvdrOrganizationIdTab   IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrOrganizationIdTab   IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ProjectIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TaskIdTab                IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_SysLinkTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_ExpItemIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PersonIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemDateTab           IN  PA_PLSQL_DATATYPES.DateTabTyp,
          P_PrvdrOrgIdTab            IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrOrgIdTab            IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrvdrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TransSourceTab           IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_CCProcessIOCodeTab       IN  PA_PLSQL_DATATYPES.Char1TabTyp,
          P_CCProcessIUCodeTab       IN  PA_PLSQL_DATATYPES.Char1TabTyp,
          P_CCPrjFlagTab             IN  PA_PLSQL_DATATYPES.Char1TabTyp,
		  P_calling_mode             IN  VARCHAR2 ,
/* Added nocopy for 2672653 */
          X_StatusTab                IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          X_CrossChargeTypeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char3TabTyp,
          X_CrossChargeCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER) IS

----------------------------------------------------------------------------------------
    -- These variables store the values during the previous iteration. These values are
    -- compared with the values in the current iteration. Only if the values are different
    -- the required SELECT is performed. Otherwise the previous results are used as the
    -- current results

    l_PrevCCTrScFlag                     VARCHAR2(1);
    l_PrevRecvrOrgId                     NUMBER;
    l_PrevPrvdrOrgId                     NUMBER;
    l_PrevPrvdrLEId                      NUMBER;
    l_PrevRecvrLEId                      NUMBER;
    l_PrevProjectId                      NUMBER;
    l_PrevCCPrjFlag                      VARCHAR2(1);
    l_PrevSysLink                        VARCHAR2(30);
    l_PrevTransSource                    VARCHAR2(30);
    l_PrevCrossChargeCode                VARCHAR2(1);
    l_PrevCrossChargeType                VARCHAR2(3);

----------------------------------------------------------------------------------------
    l_CallExtnTab                PA_PLSQL_DATATYPES.Char1TabTyp;
    l_OvrridCrossChargeCodeTab   PA_PLSQL_DATATYPES.Char1TabTyp;
    l_MaxRecs                    NUMBER;
    l_MinRecs                    NUMBER;
    l_Recvr_Organization_Id      NUMBER;
    l_Recvr_Org_Id               NUMBER;
    l_Prvdr_Org_Id               NUMBER;
    l_Recvr_LE_Id                NUMBER;
    l_Prvdr_LE_Id                NUMBER;
    l_Recvr_LE_Id_1              NUMBER;/*4482589*/
    l_Prvdr_LE_Id_1              NUMBER;/*4482589*/
    l_project_Org_Id             NUMBER;
    l_prvdr_project_id           NUMBER;
    l_vendor_site_id             NUMBER;
    l_cross_charge_code          VARCHAR2(1);
    l_cross_charge_type          VARCHAR2(3);
    l_cc_tr_src_process_flag     VARCHAR2(1);
    l_cc_prj_process_flag        VARCHAR2(1);
    l_calling_module             VARCHAR2(100);

    CURSOR GetCCOrgRel(c_prvdr_org_id  NUMBER,
                       c_recvr_org_id  NUMBER) IS
           SELECT DECODE(co.prvdr_allow_cc_flag, 'N','N', co.cross_charge_code),
                  co.prvdr_project_id, co.vendor_site_id
             FROM pa_cc_org_relationships co
            WHERE co.prvdr_org_id = c_prvdr_org_id
              AND co.recvr_org_id = c_recvr_org_id;

BEGIN

	If P_calling_mode is NULL then
		l_calling_module := 'TRANSACTION';
	Else
		l_calling_module := P_calling_mode;
	End if;

    pa_cc_utils.set_curr_function('PA_CC_GET_CROSS_CHARGE_TYPE');

    l_MinRecs  := P_SysLinkTab.FIRST;
    l_MaxRecs  := P_SysLinkTab.LAST;

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.10: Determine cross charge code and type');
    END IF;

    FOR j IN l_MinRecs..l_MaxRecs
    LOOP
      IF X_StatusTab(j) IS NOT NULL THEN
        -- If the expenditure items are already erroneous which will be indicated
        -- by this PL/SQL able then do not process CC identification for that
        -- expenditure item

        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.20: Since expenditure item is already erroneous no CC identification is necessary');
        END IF;
        NULL ;

      ELSE

        --
        -- After we have the provider OU, receiver OU, provider and receiver
        -- organizations check if the transaction requires cc processing.
        --

        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.30: Check for never cross charged');
        END IF;

        IF ( ( P_PrvdrOrganizationIdTab(j) = P_RecvrOrganizationIdTab(j) AND
               nvl(P_RecvrOrgIdTab(j), -99) =  nvl(P_PrvdrOrgIdTab(j), -99)) OR
             P_SysLinkTab(j) = 'BTC' ) THEN

          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.40: Same provider and receiver org and same provider and receiver OU or a BTC');
          END IF;
          --
          -- If provider organization is the same as the receiver organization
          -- and provider OU is the same as the receiver OU then the transaction
          -- is never cross charged. Another situation where the transaction is
          -- never cross charged is if the transaction is a burden transaction.
          --

          l_cross_charge_code := 'X' ;
          l_cross_charge_type := 'NO' ;
          l_PrevRecvrLEId     := NULL; /*4482589*/
          l_PrevPrvdrLEId     := NULL; /*4482589*/
          l_CallExtnTab(j)    := 'N' ;

        ELSIF P_RecvrOrgIdTab(j) IS NULL THEN

          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.50: Single org implementation, cross charge code is IO code at the implementation .');
          END IF;

          l_cross_charge_code :=  P_CCProcessIOCodeTab(j) ;
          l_cross_charge_type :=  'NO' ;
          l_PrevRecvrLEId     := NULL; /*4482589*/
          l_PrevPrvdrLEId     := NULL; /*4482589*/
          l_CallExtnTab(j)    :=  'Y' ;

        ELSE
          --
          -- Determine the cross charge type
          --

          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.60: Determine the cross charge type');
          END IF;

          IF P_PrvdrLEIdTab(j)  = l_PrevPrvdrLEId AND
             P_RecvrLEIdTab(j)  = l_PrevRecvrLEId AND
             P_RecvrOrgIdTab(j) = l_PrevRecvrOrgId AND
             P_PrvdrOrgIdTab(j) = l_PrevPrvdrOrgId THEN

            --
            -- If the current provider legal entity is the same as the
            -- previous provider legal entity and the current receiver legal
            -- entity is the same as the previous receiver legal entity then
            -- use the same cross charge code as that of the previous one
            --
            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.70: If parameters for determining cross charge type is same as previous ones, use the same cross charge type');
            END IF;

            l_cross_charge_type := l_PrevCrossChargeType;

          ELSE
            --
            -- Get the value of the provider legal entity
            --
            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.80: Determining provider legal entity');
            END IF;

            IF P_PrvdrLEIdTab(j) IS NULL THEN
              --
              -- If the provider legal entity parameter passed into the
              -- procedure is null then derrive it based on the provider
              -- OU.
              --

              IF  nvl(P_PrvdrOrgIdTab(j),-99) = NVL(l_PrevPrvdrOrgId, -99) THEN  /*4482589*/

                --
                -- If the previous provider OU is the same as the current
                -- provider OU then use the legal entity value derrived in
                -- the previous iteration.
                --
                IF P_DEBUG_MODE THEN
                   print_message('Inside P_PrvdrOrgIdTab =  NVL(l_PrevPrvdrOrgId, -99)');
                END IF;
                If l_PrevPrvdrLEId is null Then  /*4482589*/
                  l_PrevPrvdrLEId := GetLegalEntity(P_PrvdrOrgIdTab(j));
                End if;

                l_Prvdr_LE_Id := l_PrevPrvdrLEId ;
                l_prvdr_le_id_1 := GetLegalEntity(P_PrvdrOrgIdTab(j));

              ELSE
                --
                -- Derrive the provider legal entity based on the current
                -- provider OU
                --
                l_Prvdr_LE_Id := GetLegalEntity(P_PrvdrOrgIdTab(j));

                l_PrevPrvdrLEId := l_Prvdr_LE_Id ;
                IF P_DEBUG_MODE THEN
                   print_message('After Getlegalentity - '||l_Prvdr_LE_Id);
                END IF;
              END IF;
            ELSE
              l_Prvdr_LE_Id := P_PrvdrLEIdTab(j);

              l_PrevPrvdrLEId := l_Prvdr_LE_Id ;
            END IF;
            IF P_DEBUG_MODE THEN
               print_message('l_Prvdr_LE_Id ='||l_Prvdr_LE_Id);
               print_message('l_PrevPrvdrLEId ='||l_PrevPrvdrLEId);
            END IF;

            --
            -- Get the value of the receiver legal entity
            --
            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.90: Determining receiver legal entity');
            END IF;

            IF P_RecvrLEIdTab(j) IS NULL THEN
              --
              -- If the provider legal entity parameter passed into the
              -- procedure is null then derrive it based on the provider
              -- OU.
              --
              IF  nvl(P_RecvrOrgIdTab(j),-99) = NVL(l_PrevRecvrOrgId, -99) THEN  /*4482589*/
                --
                -- If the previous provider OU is the same as the current
                -- provider OU then use the legal entity value derrived in
                -- the previous iteration.
                --
                 If l_PrevRecvrLEId is null Then /*4482589*/
                   l_PrevRecvrLEId := GetLegalEntity(NVL(P_RecvrOrgIdTab(j),l_Recvr_Org_Id));
                 End if;

                l_Recvr_LE_Id := l_PrevRecvrLEId ;
                l_recvr_le_id_1:= GetLegalEntity(NVL(P_RecvrOrgIdTab(j),l_Recvr_Org_Id));

              ELSE
                --
                -- Derrive the provider legal entity based on the current
                -- provider OU
                --
                l_Recvr_LE_Id := GetLegalEntity(NVL(P_RecvrOrgIdTab(j),
                                               l_Recvr_Org_Id));
                l_PrevRecvrLEId := l_Recvr_LE_Id ;
              END IF;
            ELSE
              l_Recvr_LE_Id := P_RecvrLEIdTab(j);

              l_PrevRecvrLEId := l_Recvr_LE_Id ;
            END IF;
            IF P_DEBUG_MODE THEN
               print_message('l_Recvr_LE_Id ='||l_Recvr_LE_Id);
               print_message('l_PrevRecvrLEId ='||l_PrevRecvrLEId);
            END IF;

            --
            -- Get the cross charge type
            --

            IF nvl(l_Recvr_LE_Id,-99)  <> nvl(l_Prvdr_LE_Id,-99)  THEN
                l_cross_charge_type := 'IC' ;
            ELSIF nvl(P_RecvrOrgIdTab(j),-99) <> nvl(P_PrvdrOrgIdTab(j),-99) THEN
                l_cross_charge_type := 'IU' ;
            ELSE
                l_cross_charge_type := 'IO' ;
            END IF;
            IF P_DEBUG_MODE THEN
               print_message('l_cross_charge_type ='||l_cross_charge_type);
            END IF;

          END IF; -- Determine Cross Charge Type

          --
          -- Check if the project requires cross charge processing  to be done
          -- for that class(labor or non-labor) of  transactions charged to that
          -- project as for some cases cross charge processing may be done
          -- externally.
          --


          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.100: Check if project is cross chargeable');
          END IF;

          IF P_CCPrjFlagTab(j) = 'N' THEN
             --
             -- Section : Check if the project is cross chargeable.
             --
             -- If the labor non-labor process flag on the project is 'N' then
             -- there is no need of processing cross charge for this project.
             --

             l_cross_charge_code := 'N';
             l_CallExtnTab(j)    := 'N' ;

          ELSE

             IF P_DEBUG_MODE  THEN
                pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.110: Check if transaction source is cross chargeable');
             END IF;

             IF P_TransSourceTab(j) IS NOT NULL THEN
               --
               -- Section : Not Null transaction source.
               --
               -- Check if this transaction is from an external transactions source
               -- i.e. if the transaction source element is NULL.
               --

               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.120: Check if transaction source is same as previous one');
               END IF;

               IF P_TransSourceTab(j) = l_PrevTransSource THEN
                 --
                 -- Section : Get the cross charge process flag.
                 --
                 -- If the current transaction source is the same as the previous one
                 -- then use the previous value of the cc_process_flag.
                 --

                 l_cc_tr_src_process_flag := l_PrevCCTrScFlag;

               ELSE
                 --
                 -- If the transaction source is different then get the value of
                 -- cross charge process flag for the current transaction source.
                 --
                 IF P_DEBUG_MODE  THEN
                    pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.130: Get the cc process flag for current transaction source');
                 END IF;

                 SELECT t.cc_process_flag
                   INTO l_cc_tr_src_process_flag
                   FROM pa_transaction_sources t
                  WHERE t.transaction_source = P_TransSourceTab(j) ;

                 l_PrevCCTrScFlag := l_cc_tr_src_process_flag ;
                 l_PrevTransSource:= P_TransSourceTab(j);                 /*Bug#3364107*/

               END IF; -- End Section : Get the cross charge process flag.

             END IF;

             IF (P_TransSourceTab(j) IS NOT NULL ) AND (l_cc_tr_src_process_flag <> 'Y' )  THEN       /*Bug#3364107*/
                 --
                 -- Section : Check if transaction source is cross chargeable.
                 --
                 -- If the transaction source does not require cross charge processing
                 -- then set the value of cross charge code and skip all the other
                 -- checks.
                 --

                 IF P_DEBUG_MODE  THEN
                    pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.140: Setting l_cross_charge_code to N if transaction source is not CC');
                 END IF;
                 l_cross_charge_code := 'N' ;

             ELSE

                 IF P_DEBUG_MODE  THEN
                    pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.150: Check if provider OU is same as receiver OU');
                 END IF;

                 IF P_PrvdrOrgIdTab(j) = P_RecvrOrgIdTab(j) THEN
                      --
                      -- Section : Same provider OU and receiver OU.
                      --
                      -- If the provider OU is the same as the receiver OU then get the
                      -- processing method from the implementation option of the provider
                      -- OU.
                      --

                      IF P_DEBUG_MODE  THEN
                         pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.160: If provider OU is same as receiver OU assign cc code of implementation option');
                      END IF;

                      l_cross_charge_code := P_CCProcessIOCodeTab(j) ;

                 ELSE
                   -- If the provider OU is different from the receiver OU then check
                   -- in the cross charge org relationships entity if  there any record
                   -- for that combination of provider ou and receiver OU. If there is
                   -- any record then the cross charge code on that record is used.

                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.170: For different provider and receiver ous check if any controls exist');
                   END IF;
                   OPEN GetCCOrgRel(P_PrvdrOrgIdTab(j),
                                P_RecvrOrgIdTab(j));
                   FETCH GetCCOrgRel
                    INTO l_cross_charge_code,
                         l_prvdr_project_id,
                         l_vendor_site_id ;

                   IF GetCCOrgRel%FOUND THEN
                     --
                     -- Section : Check for entry in CC Org relationships entity.
                     --
                     -- If there is a record in cross charge org relationships entity
                     -- then the value is assigned to l_cross_charge_code in the fetch.
                     --

                     NULL ;

                   ELSE
                     --
                     -- If there is not record in cross charge org relationships entity
                     -- then the value then check in the implementations option of the
                     -- provider operating unit.
                     --
                     IF P_DEBUG_MODE  THEN
                        pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.180: If there are no controls, then check cross charge type');
                     END IF;

                     IF l_cross_charge_type = 'IU' THEN
                        --
                        -- Section : No entry in CC Org relationships entity.
                        --
                        -- If the cross charge type is 'IU' which means the legal entities
                        -- of the provider and receiver OUs are the same then check the
                        -- implementation option for the process iu code which is determined
                        -- in the override orgs procedure and passed into this procedure.
                        --

                        l_cross_charge_code := P_CCProcessIUCodeTab(j) ;

                        IF P_DEBUG_MODE  THEN
                           pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.190: For IU CC type set the CC code as the IU code in the implementation options');
                        END IF;

                     ELSE

                        --
                        -- This section indicates that cross charge type is 'IC' and there is
                        -- no processing method defined in cross charge org relationships entity.
                        -- So we cannot process cross charge for this item.

                        IF P_DEBUG_MODE  THEN
                           pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.200: This scenario exists when CC type is IU and not controls exist');
                        END IF;
                        l_cross_charge_code := 'N' ;

                     END IF; -- End Section : No entry in CC Org relationships entity.
                   END IF; -- End Section : Check for entry in CC Org relationships entity.

                   Close GetCCOrgRel ;
                 END IF; -- End Section : Same provider OU and receiver OU.

             END IF; -- Section : Not Null transaction source.

          END IF ; -- Section : Check if the project is cross chargeable.
        --

        END IF;

        X_CrossChargeCodeTab(j)   := l_cross_charge_code ;
        X_CrossChargeTypeTab(j)   := l_cross_charge_type ;
        l_PrevCrossChargeType     := l_cross_charge_type ;
        l_PrevRecvrOrgId          := P_RecvrOrgIdTab(j) ;
        l_PrevPrvdrOrgId          := P_PrvdrOrgIdTab(j) ;      /*4154761*/
        l_PrevCrossChargeCode     := l_cross_charge_code ;
        l_PrevProjectId           := P_ProjectIdTab(j) ;
    /*  l_PrevTransSource         := P_TransSourceTab(j) ;   Commented for bug# 3364107 */
        l_cc_tr_src_process_flag  := NULL ;                  /*Bug# 3364107*/

    IF P_DEBUG_MODE  THEN
       print_message('l_cross_charge_code=' ||l_cross_charge_code);
       print_message('l_cross_charge_type=' ||l_cross_charge_type);
       pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.210: Calling client extension');
    END IF;
        --
        -- Call client extension
        --
    PA_CC_IDENT_CLIENT_EXTN.OVERRIDE_CC_PROCESSING_METHOD (
          P_PrvdrOrganizationId    => P_PrvdrOrganizationIdTab(j),
          P_RecvrOrganizationId    => P_RecvrOrganizationIdTab(j),
          P_PrvdrOrgId             => P_PrvdrOrgIdTab(j),
          P_RecvrOrgId             => P_RecvrOrgIdTab(j),
          P_PrvdrLEId              => P_PrvdrLEIdTab(j),
          P_RecvrLEId              => P_RecvrLEIdTab(j),
          P_PersonId               => P_PersonIdTab(j),
          P_ProjectId              => P_ProjectIdTab(j),
          P_TaskId                 => P_TaskIdTab(j),
          P_SysLink                => P_SysLinkTab(j),
          P_TransDate              => P_ExpItemDateTab(j),
          P_TransSource            => P_TransSourceTab(j),
          P_TransId                => P_ExpItemIdTab(j),
          P_CrossChargeCode        => X_CrossChargeCodeTab(j),
          P_CrossChargeType        => X_CrossChargeTypeTab(j),
          P_calling_mode           => l_calling_module,
          X_OvrridCrossChargeCode  => l_OvrridCrossChargeCodeTab(j),
          X_Status                 => X_StatusTab(j),
          X_Error_Stage            => X_Error_Stage,
          X_Error_Code             => X_Error_Code ) ;
        --
        -- After Client extension
        --

        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.220: Validating the overriden CC code');
        END IF;
        IF l_OvrridCrossChargeCodeTab(j) = X_CrossChargeCodeTab(j) THEN

            NULL ;
        ELSE
            IF l_OvrridCrossChargeCodeTab(j) = 'I' THEN

               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.230: If the overriden CC code is I the check for validity');
               END IF;
               IF X_CrossChargeTypeTab(j) = 'IO' THEN

                  IF P_DEBUG_MODE  THEN
                     pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.240: If CC type is IO then the overriden code is invalid');
                  END IF;

                  X_StatusTab(j) := 'PA_CC_CODE_TYPE_INVALID';
                  X_CrossChargeCodeTab(j) := NULL;
               ELSE
                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.250: If CC type is IU the check for valid controls ');
                   END IF;
                   OPEN GetCCOrgRel(P_PrvdrOrgIdTab(j), P_RecvrOrgIdTab(j));
                   FETCH GetCCOrgRel
                    INTO l_cross_charge_code,
                         l_prvdr_project_id,
                         l_vendor_site_id ;
                   IF GetCCOrgRel%NOTFOUND OR
                      l_prvdr_project_id IS NULL OR
                      l_vendor_site_id IS NULL THEN

                      X_StatusTab(j) := 'PA_CC_CODE_TYPE_INVALID';
                      X_CrossChargeCodeTab(j) := NULL;
                   ELSE
                      X_CrossChargeCodeTab(j) := l_OvrridCrossChargeCodeTab(j);

                   END IF;
                   close GetCCOrgRel ;
               END IF ;
            ELSIF l_OvrridCrossChargeCodeTab(j) = 'B' THEN

               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.260: If the overriden CC code is B the check for validity');
               END IF;
               IF X_CrossChargeTypeTab(j) = 'IC' THEN

                  IF P_DEBUG_MODE  THEN
                     pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.240: If CC type is IC then the overriden code is invalid');
                  END IF;
                  X_StatusTab(j) := 'PA_CC_CODE_TYPE_INVALID';
                  X_CrossChargeCodeTab(j) := NULL;
               ELSE

                  X_CrossChargeCodeTab(j) := l_OvrridCrossChargeCodeTab(j);

               END IF ;
            ELSE
               X_CrossChargeCodeTab(j) := l_OvrridCrossChargeCodeTab(j);

            END IF ;

        END IF;
      END IF;

      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.250: End of determination of CC code and Type for this transaction');
      END IF;
    END LOOP ;

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('PA_CC_GET_CROSS_CHARGE_TYPE: ' || '20.20.260: End of CC code and type determination for the bulk of transactions');
       print_message('Exiting afetr checking client extn l_cross_charge_code=' ||l_cross_charge_code);
       print_message('l_cross_charge_type=' ||l_cross_charge_type);
    END IF;

    pa_cc_utils.reset_curr_function;

EXCEPTION
  WHEN OTHERS THEN
     RAISE;

END PA_CC_GET_CROSS_CHARGE_TYPE;


-- ==========================================================================
-- = FUNCTION  GetLegalEntity
-- ==========================================================================

FUNCTION  GetLegalEntity( p_org_id  IN NUMBER )
RETURN NUMBER
IS

  l_legal_entity_id     VARCHAR2(150);
BEGIN



/* R12 Legal entity changes - get from HR not PA Imp */
     SELECT  org_information2
       INTO  l_legal_entity_id
       FROM  hr_organization_information
      WHERE  organization_id = p_org_id
        AND  org_information_context = 'Operating Unit Information';

      RETURN (to_number(l_legal_entity_id));


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN (NULL);
   WHEN OTHERS THEN
      RAISE ;

END GetLegalEntity;

END PA_CC_IDENT;

/
