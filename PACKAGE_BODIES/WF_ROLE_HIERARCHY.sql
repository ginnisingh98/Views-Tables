--------------------------------------------------------
--  DDL for Package Body WF_ROLE_HIERARCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ROLE_HIERARCHY" as
 /*$Header: WFRHIERB.pls 120.27.12010000.12 2012/04/12 13:46:38 alsosa ship $*/

   ----
   -- Private Globals
   --
   --
   g_trustTimeStamp DATE;

   ----
   -- Private APIs
   --
   --

   -- RaiseEvent (PRIVATE)
   --   Wrapper to raise events to BES.
   -- IN
   --   p_eventName      (VARCHAR2)
   --   p_relationshipID (NUMBER)
   --   p_superName      (VARCHAR2)
   --   p_subName        (VARCHAR2)
   --   p_defer          (BOOLEAN)

   procedure RaiseEvent( p_eventName       VARCHAR2,
                         p_relationshipID  NUMBER,
                         p_superName       VARCHAR2,
                         p_subName         VARCHAR2,
                         p_defer           BOOLEAN) is

     l_params WF_PARAMETER_LIST_T;

   begin
     if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[5]
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.RaiseEvent',
                       'Begin RaiseEvent('||p_eventName||', '||
                       p_relationshipID||', '||p_superName||', '||
                       p_subName||')');
     end if;

     WF_EVENT.AddParameterToList('RELATIONSHIP_ID', p_relationshipID, l_params);
     WF_EVENT.AddParameterToList('SUPER_NAME', p_superName, l_params);
     WF_EVENT.AddParameterToList('SUB_NAME', p_subName, l_params);
     WF_EVENT.AddParameterToList('USER_ID', WFA_SEC.USER_ID, l_params);
     WF_EVENT.AddParameterToList('LOGIN_ID', WFA_SEC.LOGIN_ID, l_params);
     WF_EVENT.AddParameterToList('SECURITY_GROUP_ID',
                                 WFA_SEC.SECURITY_GROUP_ID, l_params);

     if (p_defer) then
       WF_EVENT.AddParameterToList('DEFER_PROPAGATION', 'TRUE', l_params);
     else
       WF_EVENT.AddParameterToList('DEFER_PROPAGATION', 'FALSE', l_params);
     end if;

     WF_EVENT.Raise(P_EVENT_NAME=>p_eventName,
                    P_EVENT_KEY=>p_relationshipID, P_PARAMETERS=>l_params);

     if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.RaiseEvent',
                       'End RaiseEvent('||p_eventName||', '||
                       p_relationshipID||', '||p_superName||', '||
                       p_subName||')');
     end if;
   exception
     when OTHERS then
      if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                         g_modulePkg||'.RaiseEvent',
                        'Exception: '||sqlerrm);
      end if;
      WF_CORE.Context('WF_ROLE_HIERARCHY', 'RaiseEvent', p_eventName,
                       p_relationshipID, p_superName, p_subName);
      raise;
   end RaiseEvent;


   --
   -- HierarchyEnabled (PRIVATE)
   --
   -- IN
   --   p_origSystem  (VARCHAR2)
   --
   -- RETURNS
   --   BOOLEAN
   --
   -- NOTES
   --  Checks to see if p_origSystem does NOT participate in bulk synch
   --  therefore is able to be hierarchy enabled.
   --
     function HierarchyEnabled (p_origSystem in VARCHAR2) return boolean
     is
       l_viewName  VARCHAR2(30);
       l_partitionID number;
       l_partitionName varchar2(30);
       l_hierarchyEnabled BOOLEAN;

     begin
       if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       -- Log only
       -- BINDVAR_SCAN_IGNORE[3]
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.HierarchyEnabled',
                       'Begin HierarchyEnabled('||p_origSystem||')');
       end if;

       WF_DIRECTORY.AssignPartition(p_origSystem, l_partitionID,
                                    l_partitionName);

       --First Check:If the partition is registered and the view names are
       --set to 'NOBS' or if the partition is not registered, we return true.
       begin
        SELECT ROLE_VIEW
        INTO   l_viewName
        FROM   WF_DIRECTORY_PARTITIONS
        WHERE  ORIG_SYSTEM = UPPER(p_origSystem)
        AND    PARTITION_ID <> 0 --<rwunderl:3588271>
        AND    (ROLE_VIEW is NULL
        or    ROLE_VIEW <> 'NOBS');

        l_hierarchyEnabled := FALSE;

       exception
        when NO_DATA_FOUND then
          l_hierarchyEnabled := TRUE;
          if wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level then
           WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION,
                            g_modulePkg||'.HierarchyEnabled',
                           p_origSystem||' is hierarchy enabled.');
          end if;
       end;

       --Second Check: If a hierarchical relationship was created then
       --we are hierarchy enabled.
       if NOT (l_hierarchyEnabled) then
         begin
           select 'NOBS'
           into   l_viewName
           from   dual
           where EXISTS (select NULL
                         from   WF_ROLE_HIERARCHIES
                         where  PARTITION_ID = l_partitionID
                         or     SUPERIOR_PARTITION_ID = l_partitionID);

           l_hierarchyEnabled := TRUE;
         exception
           when NO_DATA_FOUND then
             l_hierarchyEnabled := FALSE;
         end;
       end if;
       if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                         g_modulePkg||'.HierarchyEnabled',
                        'End HierarchyEnabled('||p_origSystem||')');
       end if;
       return l_HierarchyEnabled;

     exception
       when OTHERS then
        if(wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
         WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                           g_modulePkg||'.HierarchyEnabled',
                          'Exception: '||sqlerrm);
        end if;
        WF_CORE.Context('WF_ROLE_HIERARCHY', 'HierarchyEnabled', p_origSystem);
        raise;

     end HierarchyEnabled;

   --
   -- Calculate_Effective_Dates(PRIVATE)
   --
   -- IN
   -- p_startDate     DATE,
   -- p_endDate         DATE,
   -- p_userStartDate    DATE,
   -- p_userEndDate      DATE,
   -- p_roleStartDate    DATE,
   -- p_roleEndDate      DATE,
   -- p_assignRoleStart  DATE,
   -- p_assignRoleEnd    DATE,
   --
   -- IN OUT
   --   p_effStartDate    DATE
   --   p_effEndDate      DATE
   --
   -- NOTES
   --  Calculates the effective start and end dates in WF_USER_ROLE_ASSIGNMENTS
   -- from the user/role and asigning_Role start and end dates respectively

    procedure Calculate_Effective_Dates(
       p_startDate         in DATE,
       p_endDate         in DATE,
       p_userStartDate   in DATE,
             p_userEndDate     in DATE,
       p_roleStartDate   in DATE,
       p_roleEndDate     in DATE,
       p_assignRoleStart in DATE,
       p_assignRoleEnd   in DATE,
       p_effStartDate in out NOCOPY DATE,
       p_effEndDate   in out NOCOPY DATE
             )
    is

    begin

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
        -- Log only
        -- BINDVAR_SCAN_IGNORE[9]
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                  g_modulePkg||'.Calculate_Effective_Dates',
                  'Begin Calculate_Effective_Dates('||
                  to_char(p_startDate,WF_CORE.canonical_date_mask)|| ', ' ||
                  to_char(p_endDate,WF_CORE.canonical_date_mask)|| ', ' ||
                  to_char(p_userStartDate,WF_CORE.canonical_date_mask)||', '||
                  to_char(p_userEndDate,WF_CORE.canonical_date_mask)||', ' ||
                  to_char(p_roleStartDate,WF_CORE.canonical_date_mask)||', '||
                  to_char(p_roleEndDate,WF_CORE.canonical_date_mask)||', '||
                  to_char(p_assignRoleStart,WF_CORE.canonical_date_mask)||', '||
                  to_char(p_assignRoleEnd,WF_CORE.canonical_date_mask)||', '||
                  to_char( p_effStartDate,WF_CORE.canonical_date_mask)||', '||
                  to_char(p_effEndDate,WF_CORE.canonical_date_mask)||')');
      end if;
      --Intialize effective start date to beginning of time
      p_effStartDate := to_date(1,'J');
      --The effective start should be the greatest of all start dates.
      p_effStartDate  := greatest(nvl(p_startDate, p_effStartDate),
                                  nvl(p_userStartDate, p_effStartDate),
                                  nvl(p_roleStartDate, p_effStartDate),
                                  nvl(p_assignRoleStart, p_effStartDate));

      --Intialize effective start date to end of time
      p_effEndDate := to_date('9999/01/01','YYYY/MM/DD');
      --The effective end should be the least of all end dates.
      p_effEndDate  := least(nvl(p_endDate, p_effEndDate),
                             nvl(p_userEndDate, p_effEndDate),
                             nvl(p_roleEndDate, p_effEndDate),
                             nvl(p_assignRoleEnd, p_effEndDate));


        if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                            g_modulePkg||'.Calculate_Effective_Dates',
                            'End Calculate_Effective_Dates');
        end if;
    exception
      when OTHERS then
        if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                            g_modulePkg||'.Calculate_Effective_Dates',
                            'Exception: '||sqlerrm);
        end if;

        WF_CORE.Context('WF_ROLE_HIERARCHY', 'Calculate_Effective_Dates',
                         to_char(p_startDate,WF_CORE.canonical_date_mask),
                         to_char(p_endDate,WF_CORE.canonical_date_mask),
                         to_char(p_userStartDate,WF_CORE.canonical_date_mask),
                         to_char(p_userEndDate,WF_CORE.canonical_date_mask),
                         to_char(p_roleStartDate,WF_CORE.canonical_date_mask),
                         to_char(p_roleEndDate,WF_CORE.canonical_date_mask),
                         to_char(p_assignRoleStart,WF_CORE.canonical_date_mask),
                         to_char(p_assignRoleEnd,WF_CORE.canonical_date_mask),
                         to_char(p_effStartDate,WF_CORE.canonical_date_mask),
                         to_char(p_effEndDate,WF_CORE.canonical_date_mask));

        raise;
    end Calculate_Effective_Dates;

   --
   -- AssignmentType (PRIVATE)
   --
   -- IN
   --   p_UserName  (VARCHAR2)
   --   p_RoleName  (VARCHAR2)
   --
   -- RETURNS
   --   VARCHAR2
   --
   -- NOTES
   --  Checks to see if this is a direct, indirect or both.  Any exception
   --  or failure to determine the assignment type returns 'X'.
   --
   function AssignmentType(p_UserName VARCHAR2,
                           p_RoleName VARCHAR2) return varchar2 is

     TYPE numTAB is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_relIDTAB       numTAB;
     l_assignmentType VARCHAR2(1) := 'X';
     arIND            NUMBER;

   begin
     if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[4]
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.AssignmentType',
                       'Begin AssignmentType('||p_UserName||', '||
                       p_RoleName||')');
     end if;
     --Determine assignment type
     SELECT              RELATIONSHIP_ID
     BULK COLLECT INTO   l_relIDTAB
     FROM                WF_USER_ROLE_ASSIGNMENTS
     WHERE               ROLE_NAME = p_RoleName
     AND                 USER_NAME = p_UserName
     AND   trunc(sysdate) BETWEEN
     trunc(EFFECTIVE_START_DATE)
     AND trunc(EFFECTIVE_END_DATE);



     <<assignmentTypes>>
     for arIND in l_relIDTAB.FIRST..l_relIDTAB.LAST loop
       if (l_relIDTAB(arIND) = -1) then
         --This is a direct assignment, we will check to see if an
         --active inherited assignment was already registered.
         if (l_assignmentType = 'I') then
           l_assignmentType := 'B';

           --We can stop the comparison because we have already
           --determined that this assignment is both direct and
           --inherited.
           exit assignmentTypes;

         else
           --We are registering the direct assignment
           l_assignmentType := 'D';

         end if;
       else
         --This is not a direct assignment (it is inherited)
         --we will see if an active direct assignment was already registered.
         if (l_assignmentType = 'D') then
           l_assignmentType := 'B';

           --We can stop the comparison because we have already
           --determined that this assignment is both direct and inherited.
           exit assignmentTypes;

         else
           --We are registering the inherited assignment.
           l_assignmentType := 'I';

         end if;
       end if;
     end loop assignmentTypes;

     if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.AssignmentType',
                       'End AssignmentType('||p_UserName||', '||
                       p_RoleName||') returning ['||l_assignmentType||']');
     end if;
     return l_assignmentType;

   exception
     when OTHERS then
       return 'X';

   end AssignmentType;


   -- Cascade_RF (PRIVATE)
   --  Rule function to cascade changes according to the active hierarchy
   --  when a user/role relationship is assigned or revoked.
   -- IN
   --   p_sub_guid  (RAW)
   --   p_event     ([WF_EVENT_T])
   -- RETURNS
   --   VARCHAR2

   function Cascade_RF ( p_sub_guid  in            RAW,
                         p_event     in out NOCOPY WF_EVENT_T )
                         return VARCHAR2 is

     TYPE dateTab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
     TYPE idTab   IS TABLE OF ROWID INDEX BY BINARY_INTEGER;


     l_subordinates     WF_ROLE_HIERARCHY.relTAB;
     l_superiors        WF_ROLE_HIERARCHY.relTAB;
     l_rowIDTAB                idTab;
     l_roleStartTAB     dateTab;
     l_roleEndTAB       dateTab;
     l_effStartTAB      dateTab;
     l_effEndTAB              dateTab;
     l_RoleName         VARCHAR2(320);
     l_UserName         VARCHAR2(320);
     l_StartDate        DATE;
     l_EndDate          DATE;
     l_UserStartDate    DATE;
     l_UserEndDate        DATE;
     l_RoleStartDate    DATE;
     l_RoleEndDate        DATE;
     l_SupStartDate        DATE;
     l_SupEndDate          DATE;
     l_EffStartDate        DATE;
     l_EffEndDate          DATE;
     l_CreatedBy        NUMBER        := WFA_SEC.USER_ID;
     l_CreationDate     DATE;
     l_LastUpdatedBy    NUMBER        := WFA_SEC.USER_ID;
     l_LastUpdateDate   DATE;
     l_LastUpdateLogin  NUMBER        := WFA_SEC.LOGIN_ID;
     l_RoleOrigSystem   VARCHAR2(30);
     l_RoleOrigSystemID NUMBER;
     l_UserOrigSystem   VARCHAR2(30);
     l_UserOrigSystemID NUMBER;
     l_OwnerTag         VARCHAR2(50);
     l_assignmentType   VARCHAR2(1);
     l_assignmentReason VARCHAR2(4000);
     l_partitionID      NUMBER;
     l_partitionName    VARCHAR2(30);
     l_count            NUMBER;
     l_rowid            ROWID;
     OverWrite          BOOLEAN;
     UpdateWho          BOOLEAN := TRUE;

   begin
     if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[4]
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.Cascade_RF',
                       'Begin Cascade_RF('||rawtohex(p_sub_guid)||', '||
                       p_event.getEventName||')');
     end if;
    --Retrieve the parameters from the event and cast to appropiate data types.
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                       g_modulePkg||'.Cascade_RF',
                       'Retrieving parameters from the event.');
     end if;
     l_RoleName := p_event.getValueForParameter('ROLE_NAME');
     l_StartDate := to_date(p_event.getValueForParameter('START_DATE'),
                            WF_CORE.canonical_date_mask);
     l_EndDate   := to_date(p_event.getValueForParameter('END_DATE'),
                            WF_CORE.canonical_date_mask);
     l_UserName := p_event.getValueForParameter('USER_NAME');
     l_UserOrigSystem := p_event.getValueForParameter('USER_ORIG_SYSTEM');
     l_UserOrigSystemID := to_number(p_event.getValueForParameter(
                   'USER_ORIG_SYSTEM_ID'), WF_CORE.canonical_number_mask);
     l_RoleOrigSystem :=  p_event.getValueForParameter('ROLE_ORIG_SYSTEM');
     l_RoleOrigSystemID := to_number(p_event.getValueForParameter(
                          'ROLE_ORIG_SYSTEM_ID'),  WF_CORE.canonical_number_mask);
     l_OwnerTag := p_event.getValueForParameter('OWNER_TAG');
     l_CreatedBy := to_number(p_event.getValueForParameter('CREATED_BY'),
                               WF_CORE.canonical_number_mask);
     l_CreationDate := to_date(p_event.getValueForParameter('CREATION_DATE'),
                               WF_CORE.canonical_date_mask);
     l_LastUpdatedBy := to_number(p_event.getValueForParameter(
                                 'LAST_UPDATED_BY'), WF_CORE.canonical_number_mask);
     l_LastUpdateDate := to_date(p_event.getValueForParameter(
                                                          'LAST_UPDATE_DATE'),
                                 WF_CORE.canonical_date_mask);
     l_LastUpdateLogin := to_number(p_event.getValueForParameter(
                              'LAST_UPDATE_LOGIN'),  WF_CORE.canonical_number_mask);
     l_assignmentReason := p_event.getValueForParameter('ASSIGNMENT_REASON');
     l_rowid := chartorowid(p_event.getValueForParameter('ROWID'));
     if (p_event.getValueForParameter('WFSYNCH_OVERWRITE') ='TRUE') then
       OverWrite := TRUE;
     else
       OverWrite:= FALSE;
     end if;

     if (p_event.getValueForParameter('UPDATE_WHO') ='TRUE') then
      UpdateWho:= TRUE;
     else
      UpdateWho:= FALSE;
     end if;

    --If this is not a direct assignment, we don't need to cascade
     --the user/role creation, but we do need to validate the assignment type..
     if (p_event.getValueForParameter('ASSIGNMENT_TYPE') <> 'D') then
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.Cascade_RF',
                         'This is not a direct assignment, so nothing to '||
                         'cascade.  But we need to check of existing direct '||
                         'assignments that would cause the denormalized '||
                         'assignment_type to be set to B from D');
     end if;
     if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                         g_modulePkg||'.Cascade_RF',
                         'End Cascade_RF('||rawtohex(p_sub_guid)||', '||
                         p_event.getEventName||')');
     end if;
       l_assignmentType := AssignmentType(p_UserName=>l_UserName,
                                          p_RoleName=>l_RoleName);

       --Validate the assignment type status
       UPDATE WF_LOCAL_USER_ROLES
       SET    ASSIGNMENT_TYPE = l_assignmentType
       WHERE  ROWID = l_rowid;

      if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.Cascade_RF',
                       'End Cascade_RF('||rawtohex(p_sub_guid)||', '||
                       p_event.getEventName||') returning [SUCCESS]');
      end if;
       return 'SUCCESS';

     else

       -- Since this is a direct assignment we need to retrieve the
       -- user and role start/end dates

         WF_DIRECTORY.AssignPartition(p_orig_system=>l_UserOrigSystem,
                                      p_partitionID=>l_partitionID,
                                      p_partitionName=>l_partitionName);

         if (l_partitionID = 1) then
           SELECT START_DATE, EXPIRATION_DATE
           INTO   l_UserStartDate, l_UserEndDate
           FROM   WF_LOCAL_ROLES
           WHERE  NAME = l_UserName
           AND    PARTITION_ID = l_partitionID
           and rownum<2;
         else
           SELECT START_DATE, EXPIRATION_DATE
           INTO   l_UserStartDate, l_UserEndDate
           FROM   WF_LOCAL_ROLES
           WHERE  NAME = l_UserName
           AND    ORIG_SYSTEM= l_UserOrigSystem
           AND    ORIG_SYSTEM_ID = l_UserOrigSystemID
           AND    PARTITION_ID = l_partitionID
           AND rownum<2;
         end if;

         WF_DIRECTORY.AssignPartition(p_orig_system=>l_RoleOrigSystem,
                                      p_partitionID=>l_partitionID,
                                      p_partitionName=>l_partitionName);
         if (l_partitionID= 1) then
          SELECT START_DATE, EXPIRATION_DATE
          INTO   l_RoleStartDate, l_RoleEndDate
          FROM   WF_LOCAL_ROLES
          WHERE  NAME = l_RoleName
          AND    PARTITION_ID = l_partitionID
          AND rownum<2;
         else
          SELECT START_DATE, EXPIRATION_DATE
          INTO   l_RoleStartDate, l_RoleEndDate
          FROM   WF_LOCAL_ROLES
          WHERE  NAME = l_RoleName
          AND    ORIG_SYSTEM= l_RoleOrigSystem
          AND    ORIG_SYSTEM_ID = l_RoleOrigSystemID
          AND    PARTITION_ID = l_partitionID
          AND rownum<2;
         end if;
       -- If we are updating the user/role such as setting the end_date, then
       -- This part of the code will handle all of the assignments.

       -- we need to recalculate the effective dates as well since these
       -- might now be changed


         SELECT ROWID, ROLE_START_DATE, ROLE_END_DATE,EFFECTIVE_START_DATE,
         EFFECTIVE_END_DATE
         BULK COLLECT INTO l_RowIDTAB, l_roleStartTAB,l_roleEndTAB,
         l_effStartTAB,l_effEndTAB
     FROM WF_USER_ROLE_ASSIGNMENTS
     WHERE USER_NAME       = l_UserName
         AND ASSIGNING_ROLE    = l_RoleName;

     if (l_rowIDTAB.COUNT > 0) then
      -- Update Assignment Reason for direct assignment
        UPDATE WF_USER_ROLE_ASSIGNMENTS
        SET ASSIGNMENT_REASON = l_assignmentReason
        WHERE USER_NAME = l_UserName
        AND ASSIGNING_ROLE = l_RoleName
        AND RELATIONSHIP_ID = -1;

      --We don't want to loop if there are  no records that meet
      --our criteria, we could stop right now.

         for tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST loop
          --Now we want to calculate the effective start and end dates
          --for this  assignment.
              Calculate_Effective_Dates(l_StartDate, l_EndDate,
                         l_UserStartDate,l_UserEndDate,
          l_roleStartTAB(tabIndex),l_roleEndTAB(tabIndex),
                    l_RoleStartDate,l_RoleEndDate,
        l_effStartTAB(tabIndex),l_effEndTAB(tabIndex));
       end loop;
       if OverWrite and UpdateWho then
           --allow update of creation_date and created_by
       forall tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST
           update WF_USER_ROLE_ASSIGNMENTS
       set    START_DATE        = l_StartDate,
                END_DATE          = l_EndDate,
          LAST_UPDATED_BY   = nvl(l_LastUpdatedBy,WFA_SEC.USER_ID),
                    LAST_UPDATE_DATE  = nvl(l_LastUpdateDate,SYSDATE),
                    LAST_UPDATE_LOGIN = nvl(l_LastUpdateLogin,WFA_SEC.LOGIN_ID),
                  CREATION_DATE     = nvl(l_CreationDate,CREATION_DATE),
                  CREATED_BY        = nvl(l_CreatedBy, CREATED_BY),
                  EFFECTIVE_START_DATE = l_effStartTAB(tabIndex),
                  EFFECTIVE_END_DATE = l_effEndTAB(tabIndex)
                  where  rowid = l_rowIDTAB(tabIndex);
           elsif UpdateWho then
           forall tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST
           update WF_USER_ROLE_ASSIGNMENTS
           set    START_DATE        = l_StartDate,
                  END_DATE          = l_EndDate,
                  LAST_UPDATED_BY   = nvl(l_LastUpdatedBy,WFA_SEC.USER_ID),
                  LAST_UPDATE_DATE  = nvl(l_LastUpdateDate,SYSDATE),
                  LAST_UPDATE_LOGIN = nvl(l_LastUpdateLogin,WFA_SEC.LOGIN_ID),
                  EFFECTIVE_START_DATE = l_effStartTAB(tabIndex),
                  EFFECTIVE_END_DATE = l_effEndTAB(tabIndex)
                  where  rowid = l_rowIDTAB(tabIndex);
           else -- Donot update WHO columns
           forall tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST
           update WF_USER_ROLE_ASSIGNMENTS
           set    START_DATE        = l_StartDate,
                  END_DATE          = l_EndDate,
                  EFFECTIVE_START_DATE = l_effStartTAB(tabIndex),
                  EFFECTIVE_END_DATE = l_effEndTAB(tabIndex)
                  where  rowid = l_rowIDTAB(tabIndex);

            end if;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.Cascade_RF',
                         'Assignments for assigning role: '||
                         l_RoleName||' exist for user '||l_UserName||
                         '.  Updated existing assignments.');
        end if;
        if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
           WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                         g_modulePkg||'.Cascade_RF',
                         'End Cascade_RF('||rawtohex(p_sub_guid)||', '||
                         p_event.getEventName||')');
    end if;

     -- Bug 8337430, a self reference.
       if (l_UserName = l_RoleName) then
         WF_ROLE_HIERARCHY.Calculate_Effective_Dates
                (l_StartDate, l_EndDate, l_StartDate, l_EndDate, l_StartDate, l_EndDate,
                null, null, l_effStartDate, l_effEndDate);
           update WF_USER_ROLE_ASSIGNMENTS
           set    USER_START_DATE = l_StartDate,
                  ROLE_START_DATE = l_StartDate,
                  START_DATE = l_StartDate,
                  ASSIGNING_ROLE_START_DATE = l_StartDate,
                  EFFECTIVE_START_DATE = l_effStartDate,
                  USER_END_DATE = l_EndDate,
                  ROLE_END_DATE = l_EndDate,
                  END_DATE = l_EndDate,
                  ASSIGNING_ROLE_END_DATE = l_EndDate,
                  EFFECTIVE_END_DATE = l_effEndDate,
                  CREATION_DATE = nvl(l_CreationDate, SYSDATE),
                  LAST_UPDATE_DATE = nvl(l_LastUpdateDate,SYSDATE),
                  LAST_UPDATED_BY = nvl(l_LastUpdatedBy,WFA_SEC.USER_ID),
                  LAST_UPDATE_LOGIN = nvl(l_LastUpdateLogin,WFA_SEC.LOGIN_ID)
           where  USER_NAME = l_UserName
           and    ROLE_NAME = USER_NAME
           and    RELATIONSHIP_ID = -1;
       end if;
       return 'SUCCESS';
       end if;
     end if;

     -- We made it here so that means there are no assignments.
     -- First, we must create the assignment record for the direct assignment.

     --<rwunderl:3737114>
     WF_DIRECTORY.AssignPartition(p_orig_system=>l_RoleOrigSystem,
                                  p_partitionID=>l_partitionID,
                                  p_partitionName=>l_partitionName);
        --calculate the effective dates for the direct assignment

      Calculate_Effective_Dates(l_StartDate,
                            l_EndDate,
                            l_UserStartDate,
                            l_UserEndDate,
                            l_RoleStartDate,
                            l_RoleEndDate,
                            l_RoleStartDate,
                            l_RoleEndDate,
                            l_EffStartDate,
                            l_EffEndDate);

     --</rwunderl:3737114>

     INSERT INTO WF_USER_ROLE_ASSIGNMENTS
       ( USER_NAME,
         ROLE_NAME,
         RELATIONSHIP_ID,
         ASSIGNING_ROLE,
         START_DATE,
         END_DATE,
         ROLE_START_DATE,
         ROLE_END_DATE,
         USER_START_DATE,
         USER_END_DATE,
         ASSIGNING_ROLE_START_DATE,
         ASSIGNING_ROLE_END_DATE,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         PARTITION_ID,
         EFFECTIVE_START_DATE,
         EFFECTIVE_END_DATE,
         USER_ORIG_SYSTEM,
         USER_ORIG_SYSTEM_ID,
         ROLE_ORIG_SYSTEM,
         ROLE_ORIG_SYSTEM_ID,
         ASSIGNMENT_REASON)
     values
       ( l_UserName,
         l_RoleName,
         -1,
         l_RoleName,
         l_StartDate,
         l_EndDate,
         l_RoleStartDate,
         l_RoleEndDate,
         l_UserStartDate,
         l_UserEndDate,
         l_RoleStartDate,
         l_RoleEndDate,
         nvl(l_CreatedBy,WFA_SEC.User_ID),
         nvl(l_CreationDate,SYSDATE),
         nvl(l_LastUpdatedBy, WFA_SEC.User_ID),
         nvl(l_LastUpdateDate,SYSDATE),
         nvl(l_LastUpdateLogin,WFA_SEC.LOGIN_ID),
         l_partitionID,
         l_effStartDate,
         l_effEndDate,
         l_UserOrigSystem,
         l_UserOrigSystemId,
         l_RoleOrigSystem,
         l_RoleOrigSystemId,
         l_assignmentReason);



         GetRelationships(p_name=>l_RoleName,
                      p_superiors=>l_superiors,
                      p_subordinates=>l_subordinates,
                      p_direction=>'SUPERIORS');

         if (l_superiors.COUNT <= 0) then
         --There is nothing to do.
         if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                       g_modulePkg||'.Cascade_RF',
                       'There are no superiors, updates are limited to this '||
                       'user/role relationship.');
         end if;
         if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.Cascade_RF',
                       'End Cascade_RF('||rawtohex(p_sub_guid)||', '||
                       p_event.getEventName||')');
     end if;


          return 'SUCCESS';

         end if;
      --If we made it here, there is hierarchy processing to do.  First we need
         --to attempt to create a user/role for l_UserName to l_Superiors(i)
         --then we need to create a user/role assignment for l_RoleName as the
         --assigning role.
         if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.Cascade_RF',
                         'Beginning user/role inheritance for '||l_UserName||
                         ' to the superior roles of '||l_RoleName);
         end if;
         for l_count in l_superiors.FIRST..l_superiors.LAST loop
         if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.Cascade_RF',
                         'Beginning user/role inheritance for '||l_UserName||
                         ' to '||l_superiors(l_count).SUPER_NAME);
         end if;
          --WF_DIRECTORY.GetRoleOrigSysInfo(l_superiors(l_count).SUPER_NAME,
          --                           l_roleOrigSystem, l_roleOrigSystemID);

      -- Get superior roles' role orig system info, dates and partitionID
      SELECT ORIG_SYSTEM, ORIG_SYSTEM_ID,
          START_DATE, EXPIRATION_DATE, PARTITION_ID
          INTO l_roleOrigSystem,l_roleOrigSystemID,
          l_SupStartDate, l_SupEndDate, l_partitionID
          FROM WF_LOCAL_ROLES
          WHERE NAME=l_superiors(l_count).SUPER_NAME
          AND rownum<2;

           --Calculate the effective_dates for each of these assignments

       Calculate_Effective_Dates( l_StartDate,
                                    l_EndDate,
                          l_UserStartDate,
                      l_UserEndDate,
                      l_SupStartDate,
                      l_SupEndDate,
                      l_RoleStartDate,
                      l_RoleEndDate,
                      l_EffStartDate,
                      l_EffEndDate);

          --Creating the assignment record for each user/role assignment.
         begin
          INSERT INTO WF_USER_ROLE_ASSIGNMENTS
          (  USER_NAME,
             ROLE_NAME,
             RELATIONSHIP_ID,
             ASSIGNING_ROLE,
             START_DATE,
             END_DATE,
             USER_START_DATE,
         USER_END_DATE,
         ROLE_START_DATE,
         ROLE_END_DATE,
         ASSIGNING_ROLE_START_DATE,
         ASSIGNING_ROLE_END_DATE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             PARTITION_ID,
         EFFECTIVE_START_DATE,
         EFFECTIVE_END_DATE ,
             USER_ORIG_SYSTEM,
             USER_ORIG_SYSTEM_ID,
             ROLE_ORIG_SYSTEM,
             ROLE_ORIG_SYSTEM_ID
          )
             values
          (     l_UserName,
                l_superiors(l_count).SUPER_NAME,
                l_superiors(l_count).RELATIONSHIP_ID,
                l_RoleName,
                l_StartDate,
                l_EndDate,
        l_UserStartDate,
        l_UserEndDate,
        l_SupStartDate,
        l_SupEndDate,
        l_RoleStartDate,
        l_RoleEndDate,
               nvl(l_CreatedBy,WFA_SEC.User_ID),
               nvl(l_CreationDate,SYSDATE),
               nvl(l_LastUpdatedBy, WFA_SEC.User_ID),
               nvl(l_LastUpdateDate,SYSDATE),
               nvl(l_LastUpdateLogin,WFA_SEC.LOGIN_ID),
                l_partitionID,
        l_EffStartDate,
        l_EffEndDate,
                l_UserOrigSystem,
                l_UserOrigSystemID,
                l_RoleOrigSystem,
                l_RoleOrigSystemID
     );

         exception
          when DUP_VAL_ON_INDEX then
          if (OverWrite and UpdateWho) then
          --allow update of creation_date and created_by
           UPDATE  WF_USER_ROLE_ASSIGNMENTS
           SET     END_DATE = l_EndDate,
                   START_DATE = l_StartDate,
               USER_START_DATE = l_UserStartDate,
           USER_END_DATE = l_UserEndDate,
           ROLE_START_DATE = l_SupStartDate,
           ROLE_END_DATE = l_SupEndDate,
           ASSIGNING_ROLE_START_DATE = l_RoleStartDate,
           ASSIGNING_ROLE_END_DATE = l_RoleEndDate,
           EFFECTIVE_START_DATE = l_EffStartDate,
           EFFECTIVE_END_DATE = l_EffEndDate,
                   LAST_UPDATED_BY =  nvl(l_LastUpdatedBy, WFA_SEC.User_ID),
                   LAST_UPDATE_DATE =  nvl(l_LastUpdateDate,SYSDATE),
                   LAST_UPDATE_LOGIN = nvl(l_LastUpdateLogin,WFA_SEC.LOGIN_ID),
                   CREATED_BY = nvl(l_CreatedBy,CREATED_BY),
                   CREATION_DATE = nvl(l_CreationDate, CREATION_DATE)
           WHERE   RELATIONSHIP_ID =  l_superiors(l_count).RELATIONSHIP_ID
           AND     USER_NAME = l_UserName
           AND     ROLE_NAME = l_superiors(l_count).SUPER_NAME
           AND     ASSIGNING_ROLE = l_RoleName;
          elsif UpdateWho then
           UPDATE  WF_USER_ROLE_ASSIGNMENTS
           SET     END_DATE = l_EndDate,
                   START_DATE = l_StartDate,
                   USER_START_DATE = l_UserStartDate,
                   USER_END_DATE = l_UserEndDate,
                   ROLE_START_DATE = l_SupStartDate,
                   ROLE_END_DATE = l_SupEndDate,
                   ASSIGNING_ROLE_START_DATE = l_RoleStartDate,
                   ASSIGNING_ROLE_END_DATE = l_RoleEndDate,
                   EFFECTIVE_START_DATE = l_EffStartDate,
                   EFFECTIVE_END_DATE = l_EffEndDate,
                   LAST_UPDATED_BY = nvl(l_LastUpdatedBy, WFA_SEC.User_ID),
                   LAST_UPDATE_DATE = nvl(l_LastUpdateDate,SYSDATE),
                   LAST_UPDATE_LOGIN = nvl(l_LastUpdateLogin,WFA_SEC.LOGIN_ID)
           WHERE   RELATIONSHIP_ID =  l_superiors(l_count).RELATIONSHIP_ID
           AND     USER_NAME = l_UserName
           AND     ROLE_NAME = l_superiors(l_count).SUPER_NAME
           AND     ASSIGNING_ROLE = l_RoleName;
          else
           UPDATE  WF_USER_ROLE_ASSIGNMENTS
           SET     END_DATE = l_EndDate,
                   START_DATE = l_StartDate,
                   USER_START_DATE = l_UserStartDate,
                   USER_END_DATE = l_UserEndDate,
                   ROLE_START_DATE = l_SupStartDate,
                   ROLE_END_DATE = l_SupEndDate,
                   ASSIGNING_ROLE_START_DATE = l_RoleStartDate,
                   ASSIGNING_ROLE_END_DATE = l_RoleEndDate,
                   EFFECTIVE_START_DATE = l_EffStartDate,
                   EFFECTIVE_END_DATE = l_EffEndDate
           WHERE   RELATIONSHIP_ID =  l_superiors(l_count).RELATIONSHIP_ID
           AND     USER_NAME = l_UserName
           AND     ROLE_NAME = l_superiors(l_count).SUPER_NAME
           AND     ASSIGNING_ROLE = l_RoleName;
          end if;
          when OTHERS then
           raise;

         end;

         begin
         --We will create/update the actual user/role record's timestamp only
         --The effectivity dates will be set by the assignments.
         WF_DIRECTORY.CreateUserRole(user_name=>l_UserName,
                                    role_name=>l_superiors(l_count).SUPER_NAME,
                                    start_date=>l_startDate,
                                    end_date=>l_endDate,
                                    user_orig_system=>l_userOrigSystem,
                                    user_orig_system_id=>l_userOrigSystemID,
                                    role_orig_system=>l_roleOrigSystem,
                                    role_orig_system_id=>l_roleOrigSystemID,
                                    validateUserRole=>TRUE,
                                    created_by=>l_CreatedBy,
                                    creation_date=>l_CreationDate,
                                    last_updated_by=>l_LastUpdatedBy,
                                    last_update_date=>l_LastUpdateDate,
                                    last_update_login=>l_LastUpdateLogin,
                                    assignment_type=>'I');

         exception
          when OTHERS then
           if (WF_CORE.error_name = 'WF_DUP_USER_ROLE') then
           --Updating the existing user/role with an assignment_type of 'X'.
           --The recursive call to cascade_RF() will validate the
           --assignment_type and set it to the proper value.
             WF_CORE.Clear;
              WF_DIRECTORY.SetUserRoleAttr(user_name=>l_UserName,
                                    role_name=>l_superiors(l_count).SUPER_NAME,
                                    start_date=>l_startDate,
                                    end_date=>l_endDate,
                                    user_orig_system=>l_userOrigSystem,
                                    user_orig_system_id=>l_userOrigSystemID,
                                    role_orig_system=>l_roleOrigSystem,
                                    role_orig_system_id=>l_roleOrigSystemID,
                                    last_updated_by=>l_LastUpdatedBy,
                                    last_update_date=>l_LastUpdateDate,
                                    last_update_login=>l_LastUpdateLogin,
                                    assignment_type=>'X',
                                    updateWho=>UpdateWho);

           else
             WF_CORE.Context('WF_ROLE_HIERARCHY','Cascade_RF',
             p_event.getEventName( ), p_sub_guid);

             WF_EVENT.setErrorInfo(p_event, 'ERROR');

             return 'ERROR';

           end if;
         end;

     end loop;
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.Cascade_RF',
                       'End Cascade_RF('||rawtohex(p_sub_guid)||', '||
                       p_event.getEventName||')');
     end if;
     return 'SUCCESS';
   end Cascade_RF;


   --
   -- Propagate_RF (PRIVATE)
   --   Rule function to handle events when a relationship is created or
   --   expired
   -- IN
   --   p_sub_guid  (RAW)
   --   p_event     ([WF_EVENT_T])
   -- RETURNS
   --   VARCHAR2

   function Propagate_RF ( p_sub_guid  in            RAW,
                           p_event     in out NOCOPY WF_EVENT_T )
                           return VARCHAR2 is

     l_rel VARCHAR2(10);
     l_cp_ID NUMBER;

   begin
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[4]
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.Propagate_RF',
                       'Begin Propagate_RF('||rawtohex(p_sub_guid)||', '||
                       p_event.getEventName||')');
     end if;

     begin
       --First check to see if we are to defer propagation.
       -- Bug 8564193. If deferred is false we propagate immediately by calling Propagate()
       l_rel := nvl(p_event.GetValueForParameter('RELATIONSHIP_ID'), '-1');
       if (l_rel = -1) then
         WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                           g_modulePkg||'.Propagate_RF',
                           'Relationship_ID is NULL!');
         return 'ERROR';
       else
         if (nvl(p_event.GetValueForParameter('DEFER_PROPAGATION'),
                 'FALSE') = 'FALSE') then
           Propagate (to_number(l_rel), sysdate);
           return 'SUCCESS';
         else
           l_cp_id := FND_REQUEST.Submit_Request(APPLICATION=>'FND',
                                                 PROGRAM=>'FNDWFDSRHP',
                                                 ARGUMENT1=>l_rel);

           if (l_cp_id = -1) then
             WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                               g_modulePkg||'.Propagate_RF',
                               'Call to FND_SUBMIT failed!');
             return 'ERROR';
           end if;
         end if;
       end if;
       if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                             g_modulePkg||'.Propagate_RF',
                             'Concurrent request '||l_cp_id||
                             ' Submitted for '||l_rel);
       end if;
     end;
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.Propagate_RF',
                       'End Propagate_RF('||rawtohex(p_sub_guid)||', '||
                       p_event.getEventName||')');
     end if;
     return 'SUCCESS';

   end Propagate_RF;

   --
   -- Propagate (PRIVATE)
   --   Updates all existing assignments when a change occurs in a hierarchy.
   -- IN
   --   p_relationship_id (NUMBER)
   --



   procedure Propagate (p_relationship_id in NUMBER,
                        p_propagateDate   in DATE) is

     --Type declarations
     TYPE numberTAB   is TABLE of NUMBER index by binary_integer;
     TYPE dateTAB     is TABLE of DATE index by binary_integer;
     TYPE ownerTAB    is TABLE of VARCHAR2(50) index by binary_integer;
     TYPE flagTAB     is TABLE of VARCHAR2(1) index by binary_integer;

     --Local Variables.
     l_relIDTAB           numberTAB;
     l_userTAB            WF_DIRECTORY.UserTable;
     l_roleTAB            WF_DIRECTORY.RoleTable;
     l_assignTAB          WF_DIRECTORY.RoleTable;
     l_ownerTAB           WF_DIRECTORY.RoleTable;
     l_uorigSysTAB        WF_DIRECTORY.OrigSysTable;
     l_uorigSysIDTAB      numberTAB;
     l_rorigSysTAB        WF_DIRECTORY.RoleTable;
     l_rorigSysIDTAB      numberTAB;
     l_rpartIDTAB         numberTAB;
     l_apartIDTAB         numberTAB;
     l_startDateTAB       dateTAB;
     l_endDateTAB         dateTAB;
     l_uStartDateTAB      dateTAB;
     l_uEndDateTAB        dateTAB;
     l_rStartDateTAB      dateTAB;
     l_rEndDateTAB        dateTAB;
     l_aStartDateTAB      dateTAB;
     l_aEndDateTAB        dateTAB;
     l_enabledFlagTAB     flagTAB;
     l_user               VARCHAR2(320);
     l_role               VARCHAR2(320);
     l_assignmentType     VARCHAR2(1);

     l_effStartDate   DATE;
     l_effEndDate     DATE;
     l_superName   VARCHAR2(320);
     l_subName     VARCHAR2(320);
     l_enabledFlag VARCHAR2(1);

     --Index Variables
     subIND        PLS_INTEGER;
     hitIND        PLS_INTEGER;
     userIND       PLS_INTEGER;
     roleIND       PLS_INTEGER;

     --Cursor to select expired relationships.  This statement selects
     --the complete hierarchy then with the minus operator substracts
     --relationships from the active hierarchy leaving the relationship(s)
     --that should be expired.
     cursor expiredRelationships(p_subName in VARCHAR2) is
       select           WRH1.RELATIONSHIP_ID REL_ID
       from             WF_ROLE_HIERARCHIES WRH1
       connect by
       nocycle prior    SUPER_NAME = SUB_NAME
       start with       SUB_NAME = p_subName
       minus
       select           WRH2.RELATIONSHIP_ID REL_ID
       from             WF_ROLE_HIERARCHIES WRH2
       where            ENABLED_FLAG = 'Y'
       connect by prior SUPER_NAME = SUB_NAME
       and prior        ENABLED_FLAG = 'Y'
       start with       SUB_NAME = p_subName;

      -- Bug 7308460
      cursor relationships (p_subName in VARCHAR2, p_superName in VARCHAR2) is
       select           SUPER_NAME, RELATIONSHIP_ID
       from             WF_ROLE_HIERARCHIES
       where            ENABLED_FLAG = 'Y'
       connect by
       nocycle prior    SUPER_NAME = SUB_NAME
       and prior        ENABLED_FLAG = 'Y'
       start with       SUPER_NAME = p_superName and SUB_NAME = p_subName ;

   begin
     --Retrieve the relationship
     select     SUPER_NAME, SUB_NAME, ENABLED_FLAG
     into       l_superName, l_subName, l_enabledFlag
     from       WF_ROLE_HIERARCHIES
     where      RELATIONSHIP_ID = p_relationship_id;

     --Update the propagate timestamp
     update     WF_ROLE_HIERARCHIES
     set        PROPAGATE_DATE = p_propagateDate
     where      RELATIONSHIP_ID = p_relationship_id
     and        SUPER_NAME = l_superName
     and        SUB_NAME = l_subName;

     if (l_enabledFlag = 'N') then
       --We are propagating an expired relationship
       --To address the issue of a relationship being shared by parallel
       --Branches, we retrieve the subordinate relationships, then traverse
       --down the hierarchy.  For each subordinate relationship, we compare the
       --active and inactive superiors to remove truly expired hierarchy
       --relationships.
       --Retrieve the subordinates
       select            SUB_NAME
       bulk collect into l_assignTAB
       from              WF_ROLE_HIERARCHIES
       connect by
       nocycle prior     SUB_NAME = SUPER_NAME
       start with        SUPER_NAME = l_superName;

       --Outer loop to traverse down the subordinates in the hierarchy.
       if (l_assignTAB.COUNT > 0) then
         <<Subordinates>>
         for subIND in l_assignTAB.FIRST..l_assignTAB.LAST loop
           --Reset the hitList counter.
           hitIND := 0;
           l_relIDTAB.DELETE;  --Truncate the PL/SQL Table.
           --Inner loop to select expired relationships providing.
           <<ExpiredSuperiors>>
           for a in expiredRelationships(l_assignTAB(subIND)) loop
             --Load the potential relationship ids into a local table.
             l_relIDTAB(hitIND) := a.REL_ID;
             hitIND := hitIND + 1;  --Advance the counter
           end loop ExpiredSuperiors;
           --Now we will perform a bulk update to expire the user/role
           --assignments that are based on these relationship_ids and were
           --assigned from this subordinate (this protects a relationship that
           --may be serving more than one subordinate assignment as well as any
           --parallel branches).
           if (l_relIDTAB.COUNT > 0) then
             <<Assignments>>
             forall hitIND in l_relIDTAB.FIRST..l_relIDTAB.LAST
               delete from  WF_USER_ROLE_ASSIGNMENTS
               where      RELATIONSHIP_ID = l_relIDTAB(hitIND)
               and        ASSIGNING_ROLE  = l_assignTAB(subIND)
               returning  USER_NAME, ROLE_NAME
               bulk collect into l_userTAB, l_roleTAB;

               if (l_userTAB.COUNT > 0) then
                 for userIND in l_userTAB.FIRST..l_userTAB.LAST loop
                   l_assignmentType := AssignmentType(l_userTAB(userIND),
                                                    l_roleTAB(userIND));

                   select min(effective_start_Date),max(effective_end_date)
                   into l_effStartDate, l_effEndDate
                   from wf_user_role_assignments
                   where user_name= l_userTAB(userIND)
                   and role_name =  l_roleTAB(userIND);


                   if (l_effStartDate is null) then
                   -- implies there are no more active inherited assignments
                   -- to this user/role. So we can expire it. Since this was
                   -- only an inherited assignment therefore we can safely
                   -- remove it from WF_LOCAL_USER_ROLES knowing that only
                   -- direct assignments are shipped.

                    delete from
                    WF_LOCAL_USER_ROLES
                    where      USER_NAME = l_userTAB(userIND)
                    and        ROLE_NAME = l_roleTAB(userIND);

                   else
                   -- implies the assignment is still active through
                   -- some other branch.So we just update the effective
                   -- dates and assignment type.

                    update    WF_LOCAL_USER_ROLES
                    set       ASSIGNMENT_TYPE = l_assignmentType,
                              EFFECTIVE_START_DATE= l_effStartDate,
                              EFFECTIVE_END_DATE = l_effEndDate,
                              LAST_UPDATED_BY   = WFA_SEC.user_id,
                              LAST_UPDATE_DATE  = sysdate,
                              LAST_UPDATE_LOGIN = WFA_SEC.login_id
                    where      USER_NAME = l_userTAB(userIND)
                    and        ROLE_NAME = l_roleTAB(userIND);
                   end if;
                 end loop;
               end if;
            -- end loop Assignments;
             commit;  --Commiting this batch of updates.
           end if;
         end loop Subordinates;
       end if;
     else --(l_enabledFlag = 'Y')
       --Retrieve the superiors of this relationship.
       -- Bug 7308460. Need to use the super role, as using only
       -- the subrole will make the cursor include sibling hierarchies.
       open relationships (l_subName, l_superName);
         fetch relationships bulk collect into l_roleTAB, l_relIDTAB;
       close relationships;

       --Retrieve the role information for each superior.
       <<Superiors_Info>>
       for roleIND in l_roleTAB.FIRST..l_roleTAB.LAST loop
         select            ORIG_SYSTEM, ORIG_SYSTEM_ID, PARTITION_ID,
                           START_DATE, EXPIRATION_DATE
         into              l_rorigSysTAB(roleIND), l_rorigSysIDTAB(roleIND),
                           l_rpartIDTAB(roleIND), l_rStartDateTAB(roleIND),
                           l_rEndDateTAB(roleIND)
         from              WF_LOCAL_ROLES
         where             NAME = l_roleTAB(roleIND);
      end loop Superiors_Info;

      --Retrieve any direct or inherited assignments to the subordinate
      --of this relationship.
      select            USER_NAME, ASSIGNING_ROLE, START_DATE, END_DATE,
                        USER_START_DATE, USER_END_DATE,
                        ASSIGNING_ROLE_START_DATE, ASSIGNING_ROLE_END_DATE,
                        PARTITION_ID, USER_ORIG_SYSTEM, USER_ORIG_SYSTEM_ID
      bulk collect into l_userTAB, l_assignTAB, l_startDateTAB, l_endDateTAB,
                        l_uStartDateTAB, l_uEndDateTAB, l_aStartDateTAB,
                        l_aEndDateTAB, l_apartIDTAB, l_uorigSysTAB, l_uorigSysIDTAB
      from              WF_USER_ROLE_ASSIGNMENTS
      where             ROLE_NAME = l_subName;

      --We will propagate the newly inherited assignments before the
      --associated user/role relationships because of the functionality of the
      --WF_USER_ROLES view.  By propagating the assignments first, when we
      --create the actual records in WF_LOCAL_USER_ROLES, the WF_USER_ROLES
      --view will immediately pickup not only the user/role, but according
      --to the effective date-range.  If we did this the other way around,
      --there may possibly be a way that a user/role relationship that is
      --not supposed to be visable, would appear in the view.


     --Outer loop to select the superior role.
     <<Superiors>>
     for roleIND in l_roleTAB.FIRST..l_roleTAB.LAST loop
       --Inner loop to select select and propagate any existing assignments
       --up the hierarchy.
       <<User_Role_Assignments>>
       if (l_userTAB.COUNT > 0) then
         for userIND in l_userTAB.FIRST..l_userTAB.LAST loop
           begin

              --calculate the effective start and dates
              calculate_effective_dates ( l_startDateTAB(userIND),
                           l_endDateTAB(userIND),
                        l_uStartDateTAB(userIND),
                        l_uEndDateTAB(userIND),
                        l_rStartDateTAB(roleIND),
                        l_rEndDateTAB(roleIND),
                        l_aStartDateTAB(userIND),
                        l_aEndDateTAB(userIND),
                        l_effStartDate,
                        l_effEndDate);

             insert into WF_USER_ROLE_ASSIGNMENTS (USER_NAME,
                                                   ROLE_NAME,
                                                   RELATIONSHIP_ID,
                                                   ASSIGNING_ROLE,
                                                   START_DATE,
                                                   END_DATE,
                                                   USER_START_DATE,
                                                   USER_END_DATE,
                                                   ROLE_START_DATE,
                                                   ROLE_END_DATE,
                                                   ASSIGNING_ROLE_START_DATE,
                                                   ASSIGNING_ROLE_END_DATE,
                                                   EFFECTIVE_START_DATE,
                                                   EFFECTIVE_END_DATE,
                                                   USER_ORIG_SYSTEM,
                                                   USER_ORIG_SYSTEM_ID,
                                                   ROLE_ORIG_SYSTEM,
                                                   ROLE_ORIG_SYSTEM_ID,
                                                   CREATED_BY,
                                                   CREATION_DATE,
                                                   LAST_UPDATED_BY,
                                                   LAST_UPDATE_DATE,
                                                   LAST_UPDATE_LOGIN,
                                                   PARTITION_ID) values
                                                (
                                                l_userTAB(userIND),
                                                l_roleTAB(roleIND),
                                                l_relIDTAB(roleIND),
                                                l_assignTAB(userIND),
                                                trunc(l_startDateTAB(userIND)),
                                                trunc(l_endDateTAB(userIND)),
                                                trunc(l_uStartDateTAB(userIND)),
                                                trunc(l_uEndDateTAB(userIND)),
                                                trunc(l_rStartDateTAB(roleIND)),
                                                trunc(l_rEndDateTAB(roleIND)),
                                                trunc(l_aStartDateTAB(userIND)),
                                                trunc(l_aEndDateTAB(userIND)),
                                                l_effStartDate,
                                                l_effEndDate,
                                                l_uorigSysTAB(userIND),
                                                l_uorigSysIDTAB(userIND),
                                                l_rorigSysTAB(roleIND),
                                                l_rorigSysIDTAB(roleIND),
                                                WFA_SEC.user_id,
                                                sysdate,
                                                WFA_SEC.user_id,
                                                sysdate,
                                                WFA_SEC.login_id,
                                                l_rpartIDTAB(roleIND));
           exception
             when DUP_VAL_ON_INDEX then
               --This can happen if there is a parallel branch.
               --We will just update the timestamp.
               update     WF_USER_ROLE_ASSIGNMENTS
               set        START_DATE        = trunc(l_startDateTAB(userIND)),
                          END_DATE          = trunc(l_endDateTAB(userIND)),
                          USER_START_DATE   = trunc(l_uStartDateTAB(userIND)),
                          USER_END_DATE     = trunc(l_uEndDateTAB(userIND)),
                          ROLE_START_DATE   = trunc(l_rStartDateTAB(roleIND)),
                          ROLE_END_DATE     = trunc(l_rEndDateTAB(roleIND)),
                          ASSIGNING_ROLE_START_DATE = trunc(l_aStartDateTAB(userIND)),
                          ASSIGNING_ROLE_END_DATE = trunc(l_aEndDateTAB(userIND)),
                          EFFECTIVE_START_DATE = l_effStartDate,
                          EFFECTIVE_END_DATE = l_effEndDate,
                          LAST_UPDATED_BY   = WFA_SEC.user_id,
                          LAST_UPDATE_DATE  = sysdate,
                          LAST_UPDATE_LOGIN = WFA_SEC.login_id
               where      USER_NAME         = l_userTAB(userIND)
               and        ROLE_NAME         = l_roleTAB(roleIND)
               and        RELATIONSHIP_ID   = l_relIDTAB(roleIND)
               and        ASSIGNING_ROLE    = l_assignTAB(userIND);
           end;
         end loop User_Role_Assignments;
       end if;
       commit; --We will commit all of the user assignments to this superior.
     end loop Superiors;

     --Retrieve a list of the effected users.
     select            USER_NAME, USER_ORIG_SYSTEM, USER_ORIG_SYSTEM_ID,
                       OWNER_TAG, USER_START_DATE, USER_END_DATE, START_DATE,
                       EXPIRATION_DATE
     bulk collect into l_userTAB, l_uorigSysTAB, l_uorigSysIDTAB,
                       l_ownerTAB, l_uStartDateTAB, l_uEndDateTAB,
                       l_startDateTAB, l_endDateTAB
     from              WF_LOCAL_USER_ROLES
     where             ROLE_NAME = l_subName;

     --We will now create the user_role records in WF_LOCAL_USER_ROLES.
     --Outer loop to select an effected user (IE: A user that is assigned
     --either directly or indirectly to the subordinate role of this
     --relationship.
     if (l_userTAB.COUNT > 0) then
     <<Users>>
     for userIND in l_userTAB.FIRST..l_userTAB.LAST loop
       --Inner Loop, to select each role traversing up the hierarchy that
       --the effected user will inherit.
       <<UserRoles>>
       for roleIND in l_roleTAB.FIRST..l_roleTAB.LAST loop
         begin
           --determine the assignment type and effective dates.

           l_assignmentType := AssignmentType(l_userTAB(userIND),
                                              l_roleTAB(roleIND));

           select min(effective_start_date),
           max(effective_end_date)
       into l_effStartDate, l_effEndDate
       from wf_user_role_Assignments
       where user_name=l_userTAB(userIND)
       and role_name = l_roleTAB(roleIND);

           insert into  WF_LOCAL_USER_ROLES (USER_NAME,
                                             ROLE_NAME,
                                             USER_ORIG_SYSTEM,
                                             USER_ORIG_SYSTEM_ID,
                                             ROLE_ORIG_SYSTEM,
                                             ROLE_ORIG_SYSTEM_ID,
                                             START_DATE,
                                             EXPIRATION_DATE,
                                             USER_START_DATE,
                                             USER_END_DATE,
                                             ROLE_START_DATE,
                                             ROLE_END_DATE,
                                             EFFECTIVE_START_DATE,
                                             EFFECTIVE_END_DATE,
                                             SECURITY_GROUP_ID,
                                             PARTITION_ID,
                                             OWNER_TAG,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATE_LOGIN,
                                             ASSIGNMENT_TYPE) values
                                            (l_userTAB(userIND),
                                             l_roleTAB(roleIND),
                                             l_uorigSysTAB(userIND),
                                             l_uorigSysIDTAB(userIND),
                                             l_rorigSysTAB(roleIND),
                                             l_rorigSysIDTAB(roleIND),
                                             l_startDateTAB(userIND),
                                             l_endDateTAB(userIND),
                                             trunc(l_uStartDateTAB(userIND)),
                                             trunc(l_uEndDateTAB(userIND)),
                                             trunc(l_rStartDateTAB(roleIND)),
                                             trunc(l_rEndDateTAB(roleIND)),
                                             l_effStartDate,
                                             l_effEndDate,
                                             NULL,
                                             l_rpartIDTAB(roleIND),
                                             l_ownerTAB(userIND),
                                             WFA_SEC.user_id,
                                             sysdate,
                                             WFA_SEC.user_id,
                                             sysdate,
                                             WFA_SEC.login_id,
                                             l_AssignmentType);
         exception
           when DUP_VAL_ON_INDEX then
             --The record already exists, so we will just update the
             --timestamp
             if (l_assignmentType = 'I') then
               SELECT min(start_date)
               INTO   l_startDateTAB(userIND)
               FROM   WF_USER_ROLE_ASSIGNMENTS_V
               WHERE  USER_NAME = l_userTAB(userIND)
               AND    ROLE_NAME = l_roleTAB(roleIND);

               SELECT max(end_date)
               INTO   l_endDateTAB(userIND)
               FROM   WF_USER_ROLE_ASSIGNMENTS_V
               WHERE  USER_NAME = l_userTAB(userIND)
               AND    ROLE_NAME = l_roleTAB(roleIND);

             end if;

             update WF_LOCAL_USER_ROLES
             set    START_DATE        = trunc(l_startDateTAB(userIND)),
                    EXPIRATION_DATE   = trunc(l_endDateTAB(userIND)),
                    USER_START_DATE   = trunc(l_uStartDateTAB(userIND)),
                    USER_END_DATE     = trunc(l_uEndDateTAB(userIND)),
                    ROLE_START_DATE   = trunc(l_rStartDateTAB(roleIND)),
                    ROLE_END_DATE     = trunc(l_rEndDateTAB(roleIND)),
                    EFFECTIVE_START_DATE = l_effStartDate,
                    EFFECTIVE_END_DATE = l_effEndDate,
                    LAST_UPDATED_BY   = WFA_SEC.user_id,
                    LAST_UPDATE_DATE  = sysdate,
                    LAST_UPDATE_LOGIN = WFA_SEC.login_id,
                    ASSIGNMENT_TYPE   = l_AssignmentType
             where  USER_NAME           = l_userTAB(userIND)
             and    ROLE_NAME           = l_roleTAB(roleIND)
             and    USER_ORIG_SYSTEM    = l_uorigSysTAB(userIND)
             and    USER_ORIG_SYSTEM_ID = l_uorigSysIDTAB(userIND)
             and    ROLE_ORIG_SYSTEM    = l_rorigSysTAB(roleIND)
             and    ROLE_ORIG_SYSTEM_ID = l_rorigSysIDTAB(roleIND);


         end;
       end loop UserRoles;
       commit; --Commiting the inherited user/roles for this user.
     end loop Users;
     end if;
   end if; --(if ENABLED_FLAG = 'N')
 end Propagate;

   --
   -- Propagate_CP (PRIVATE)
   --   Concurrent program wrapper to call Propagate().
   -- IN
   --   p_relationship_id  (VARCHAR2)
   --   retcode            [VARCHAR2]
   --   errbuf             [VARCHAR2]

   procedure Propagate_CP (retcode           out NOCOPY VARCHAR2,
                           errbuf            out NOCOPY VARCHAR2,
                           p_relationship_id in         VARCHAR2) is

     TYPE numTAB is table of NUMBER;
     relIDTAB        numTAB;
     relIND          number;
     l_propagateDate date;

   begin
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[3]
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.Propagate_CP',
                       'Begin Propagate_CP('||p_relationship_id||')');
     end if;
     errbuf  := '';
     l_propagateDate := sysdate;
     if (p_relationship_id = 'ALL') then
       SELECT relationship_id
       BULK COLLECT INTO   relIDTAB
       FROM   WF_ROLE_HIERARCHIES
       WHERE  (PROPAGATE_DATE is NULL or
               ((PROPAGATE_DATE is NOT NULL) and
                 (PROPAGATE_DATE < LAST_UPDATE_DATE)));

       if (relIDTAB.COUNT > 0) then
         for relIND in relIDTAB.FIRST..relIDTAB.LAST loop
           propagate(p_relationship_id=>relIDTAB(relIND),
                     p_propagateDate=>l_propagateDate);
         end loop;
       end if;
     else
       propagate(p_relationship_id=>to_number(Propagate_CP.p_relationship_id));
     end if;

       retcode := '0';
       commit;
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.Propagate_CP',
                       'End Propagate_CP('||p_relationship_id||')');
     end if;
   exception
     when OTHERS then
       if(wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                         g_modulePkg||'.Propagate_CP', 'Exception: '||
                         sqlerrm);
       end if;

       retcode := '2';
       errbuf := sqlerrm;
       WF_CORE.Clear;
   end Propagate_CP;


    -- Denormalize_UR_Assignments(PRIVATE)
   --  Procedure to update the user and role dates and
   --  effective dates of user/role assignments.
   -- IN OUT
   -- p_event WF_EVENT_T



   procedure Denormalize_UR_Assignments( p_event     in out NOCOPY WF_EVENT_T)
   is


     l_UserName         VARCHAR2(320);
     l_RoleName         VARCHAR2(320);
     l_StartDate        DATE;
     l_EndDate          DATE;
     l_LastUpdatedBy    NUMBER        ;
     l_LastUpdateDate   DATE;
     l_LastUpdateLogin  NUMBER        ;
     l_OrigSystem       VARCHAR2(30);
     l_OrigSystemID     NUMBER;

     TYPE dateTab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
     TYPE idTab   IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
     TYPE numTab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_roleTAB             WF_DIRECTORY.roleTable;
     l_userTAB          WF_DIRECTORY.userTable;
     l_assigningRoleTAB     WF_DIRECTORY.roleTable;
     l_asgStartTAB     dateTab;
     l_asgEndTAB     dateTab;
     l_rowIDTAB      idTab;
     l_userStartTAB      dateTab;
     l_roleStartTAB      dateTab;
     l_userEndTAB        dateTab;
     l_roleEndTAB      dateTab;
     l_effStartTAB     dateTab;
     l_effEndTAB     dateTab;
     l_startTAB         dateTab;
     l_endTAB         dateTab;
     -- who column pl/sql source tables
     l_creatDtTAB     dateTab;
     l_creatByTAB     numTab;
     l_lastUpdDtTAB   dateTab;
     l_lastUpdByTAB   numTab;
     l_lastUpdLogTAB  numTab;

     cursor c_UserRoleAssignments (c_userName in varchar2,
                                   c_roleName in varchar2)
     is
     select ROWID, ROLE_NAME, USER_NAME,ASSIGNING_ROLE, START_DATE, END_DATE,
     ROLE_START_DATE, ROLE_END_DATE,USER_START_DATE, USER_END_DATE,
     ASSIGNING_ROLE_START_DATE, ASSIGNING_ROLE_END_DATE,  EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
     LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
     from WF_USER_ROLE_ASSIGNMENTS
     where (ROLE_NAME = c_roleName or ASSIGNING_ROLE = c_roleName)
     and USER_NAME=c_userName;

     cursor c_UserRoleAssignments_u (c_userName in varchar2)
     is
     select ROWID, ROLE_NAME, USER_NAME,ASSIGNING_ROLE, START_DATE, END_DATE,
     ROLE_START_DATE, ROLE_END_DATE,USER_START_DATE, USER_END_DATE,
     ASSIGNING_ROLE_START_DATE, ASSIGNING_ROLE_END_DATE,  EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE ,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
     LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
     from WF_USER_ROLE_ASSIGNMENTS
     where USER_NAME=c_userName;

     cursor c_UserRoleAssignments_r (c_roleName in varchar2)
     is
     select ROWID, ROLE_NAME, USER_NAME,ASSIGNING_ROLE, START_DATE, END_DATE,
     ROLE_START_DATE, ROLE_END_DATE,USER_START_DATE, USER_END_DATE,
     ASSIGNING_ROLE_START_DATE, ASSIGNING_ROLE_END_DATE,  EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
     LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
     from WF_USER_ROLE_ASSIGNMENTS
     where ROLE_NAME = c_roleName
     or ASSIGNING_ROLE = c_roleName;

  begin
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[3]
     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
          g_modulePkg||'.Denormalize_UR_Assignments',
          'Begin Denormalize_UR_Assignments('||p_event.getEventName||')');
     end if;

     l_RoleName := p_event.getValueForParameter('ROLE_NAME');
     l_UserName := p_event.getValueForParameter('USER_NAME');
     l_LastUpdatedBy := to_number(p_event.getValueForParameter(
                       'LAST_UPDATED_BY'),  WF_CORE.canonical_number_mask);
     l_LastUpdateDate := nvl(to_date(p_event.getValueForParameter(
                                      'LAST_UPDATE_DATE'),
                                 WF_CORE.canonical_date_mask),SYSDATE);
     l_LastUpdateLogin := to_number(p_event.getValueForParameter(
                          'LAST_UPDATE_LOGIN'),  WF_CORE.canonical_number_mask);

     l_OrigSystem := p_event.getValueForParameter('ORIG_SYSTEM');
     l_OrigSystemID := to_number(p_event.getValueForParameter(
                           'ORIG_SYSTEM_ID'), WF_CORE.canonical_number_mask);
     l_StartDate   := trunc(to_date(p_event.getValueForParameter('START_DATE'),
                            WF_CORE.canonical_date_mask));
     l_EndDate:= trunc(to_date(p_event.getValueForParameter('EXPIRATION_DATE'),
                          WF_CORE.canonical_date_mask));

     if (l_userName is NOT NULL and l_roleName is NOT NULL) then
       open c_userRoleAssignments (l_userName , l_roleName);
     elsif (l_userName is NOT NULL) then
       open c_userRoleAssignments_u (l_userName);
     elsif (l_roleName is NOT NULL) then
       open c_userRoleAssignments_r(l_roleName);
     else
       return;
     end if;
     loop

       if (l_userName is NOT NULL and l_roleName is NOT NULL) then
         fetch c_UserRoleAssignments
         bulk collect into l_rowIDTAB, l_roleTAB, l_userTAB,l_assigningRoleTAB,
         l_startTAB,l_endTAB, l_roleStartTAB,l_roleEndTAB, l_userStartTAB,
         l_userEndTAB, l_asgStartTAB,l_asgEndTAB, l_effStartTAB, l_effEndTAB,
         l_creatbyTAB, l_creatdtTAB, l_lastupdByTAB, l_lastupdDtTAB, l_lastupdlogTAB
         limit g_maxRows;
       elsif (l_userName is NOT NULL) then
         fetch c_UserRoleAssignments_u
         bulk collect into l_rowIDTAB, l_roleTAB, l_userTAB,l_assigningRoleTAB,
         l_startTAB,l_endTAB, l_roleStartTAB,l_roleEndTAB, l_userStartTAB,
         l_userEndTAB, l_asgStartTAB,l_asgEndTAB, l_effStartTAB, l_effEndTAB,
         l_creatbyTAB, l_creatdtTAB, l_lastupdByTAB, l_lastupdDtTAB, l_lastupdlogTAB
         limit g_maxRows;
       elsif (l_roleName is NOT NULL) then
         fetch c_UserRoleAssignments_r
         bulk collect into l_rowIDTAB, l_roleTAB, l_userTAB,l_assigningRoleTAB,
         l_startTAB,l_endTAB, l_roleStartTAB,l_roleEndTAB, l_userStartTAB,
         l_userEndTAB, l_asgStartTAB,l_asgEndTAB, l_effStartTAB, l_effEndTAB,
         l_creatbyTAB, l_creatdtTAB, l_lastupdByTAB, l_lastupdDtTAB, l_lastupdlogTAB
         limit g_maxRows;
       end if;

       --We now have pl/sql tables in memory that we can update with the new
       --values. So we loop through them and begin the processing.


        if (l_rowIDTAB.COUNT > 0) then
    ---We don't want to loop if there are  no records that meet our
        --criteria, we could stop right now.

        for tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST loop
            if (l_roleName is not null and l_userName is null
            and l_roleTAB(tabIndex) = l_roleName) then
               l_roleStartTAB(tabIndex) := l_startDate;
               l_roleEndTAB(tabIndex) := l_endDate;
            end if;

            if (l_roleName is not null and l_userName is null
            and l_assigningRoleTAB(tabIndex) = l_roleName) then
        --This was an  assigning role
              l_asgStartTAB(tabIndex) := l_startDate;
              l_asgEndTAB(tabIndex) := l_endDate;
            end if;


        if (l_userName is not null and l_roleName is null
            and l_userTAB(tabIndex) = l_userName) then
              l_userStartTAB(tabIndex) := l_startDate;
              l_userEndTAB(tabIndex) := l_endDate;
              --Check the self reference
              if (l_userTAB(tabIndex) = l_roleTab(tabIndex)) then
                l_roleStartTAB(tabIndex) := l_startDate;
                l_asgStartTAB(tabIndex) := l_startDate;
                l_roleEndTAB(tabIndex) := l_endDate;
                l_asgEndTAB(tabIndex) := l_endDate;
                l_startTAB(tabIndex) := l_startDate;
                l_endTAB(tabIndex) := l_endDate;
                -- also update WHO columns in case of self-reference
                l_lastUpdLogTAB(tabIndex):=nvl(l_lastUpdateLogin,WFA_SEC.Login_ID);
                l_lastUpdByTAB(tabIndex):=nvl(l_lastUpdatedBy, WFA_SEC.User_ID);
                l_lastUpdDtTAB(tabIndex):=nvl(l_lastUpdateDate,SYSDATE);
              end if;
            end if;

            if (l_userName is not null and l_roleName is null
            and l_roleTAB(tabIndex) = l_userName) then
        --Case when user=role
              l_roleStartTAB(tabIndex) := l_startDate;
              l_roleEndTAB(tabIndex) := l_endDate;
            end if;

        --Now we want to calculate the effective start and end dates
            --for this  assignment.
            Calculate_Effective_Dates(l_startTAB(tabIndex),
                                      l_endTAB(tabIndex),
                                      l_userStartTAB(tabIndex),
                                      l_userEndTAB(tabIndex),
                                      l_roleStartTAB(tabIndex),
                                      l_roleEndTAB(tabIndex),
                                      l_asgStartTAB(tabIndex),
                                      l_asgEndTAB(tabIndex),
                                      l_effStartTAB(tabIndex),
                                      l_effEndTAB(tabIndex));

      end loop;

         --After this point we have a complete series of pl/sql tables with
         --all of the start/end dates and calculated effective start/end dates
         --We can then issue the bulk  update.
          forall tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST

          update WF_USER_ROLE_ASSIGNMENTS
          set     ROLE_START_DATE = l_roleStartTAB(tabIndex),
                   ROLE_END_DATE = l_roleEndTAB(tabIndex),
          USER_START_DATE = l_userStartTAB(tabIndex),
          USER_END_DATE = l_userEndTAB(tabIndex),
                   EFFECTIVE_START_DATE = l_effStartTAB(tabIndex),
                   EFFECTIVE_END_DATE = l_effEndTAB(tabIndex),
                  START_DATE=l_startTAB(tabIndex),
                  END_DATE=l_endTAB(tabIndex),
                  ASSIGNING_ROLE_START_DATE = l_asgStartTAB(tabIndex),
                  ASSIGNING_ROLE_END_DATE = l_asgEndTAB(tabIndex),
                  LAST_UPDATED_BY = l_lastUpdByTAB(tabIndex),
                  LAST_UPDATE_DATE = l_lastUpdDtTAB(tabIndex),
                  LAST_UPDATE_LOGIN  = l_lastUpdLogTAB(tabIndex)
      where  rowid = l_rowIDTAB(tabIndex);

        end if; --if (l_rowIDTAB.COUNT > 0)

        if (l_userName is NOT NULL and l_roleName is NOT NULL) then
         exit when c_userRoleAssignments%notfound;
       elsif (l_userName is NOT NULL) then
         exit when c_userRoleAssignments_u%notfound;
       elsif (l_roleName is NOT NULL) then
         exit when c_userRoleAssignments_r%notfound;
       end if;

    end loop;


    if (l_userName is NOT NULL and l_roleName is NOT NULL) then
      close c_UserRoleAssignments;
    elsif (l_userName is NOT NULL) then
      close c_UserRoleAssignments_u;
    elsif (l_roleName is NOT NULL) then
      close c_UserRoleAssignments_r;
    end if;

    if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                     g_modulePkg||'.Denormalize_UR_Assignments',
                     'End Denormalize_UR_Assignments');
    end if;

   exception
       when OTHERS then
        if c_UserRoleAssignments%ISOPEN then
           close c_UserRoleAssignments;
        elsif c_UserRoleAssignments_u%ISOPEN then
           close c_UserRoleAssignments_u;
        elsif c_UserRoleAssignments_r%ISOPEN then
           close c_UserRoleAssignments_r;
        end if;

         if(wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                           g_modulePkg||'.Denormalize_UR_Assignments',
                          'Exception: '||sqlerrm);
         end if;
         WF_CORE.Context('WF_ROLE_HIERARCHY', 'Denormalize_UR_Assignments',
                          p_event.getEventName);
         raise;


  end Denormalize_UR_Assignments;



   -- Aggregate_User_Roles_RF(PRIVATE)
   -- Rule Function to update WF_LOCAL_USER_ROLES as
   -- summary table of WF_USER_ROLE_ASSIGNMENTS
   -- IN
   --   p_sub_guid  (RAW)
   --   p_event     ([WF_EVENT_T])
   -- returns
   --   VARCHAR2
   function Aggregate_User_Roles_RF ( p_sub_guid  in            RAW,
                            p_event     in out NOCOPY WF_EVENT_T)
                      return VARCHAR2 is

     l_UserName         VARCHAR2(320);
     l_RoleName         VARCHAR2(320);
     l_RoleStartDate    DATE;
     l_RoleEndDate      DATE;
     l_userStartDate    DATE;
     l_effStartDate     DATE;
     l_effEndDate    DATE;
     l_userEndDate    DATE;
     l_LastUpdatedBy    NUMBER;
     l_LastUpdateDate   DATE;
     l_LastUpdateLogin  NUMBER;
     l_CreatedBy        NUMBER;
     l_CreationDate     DATE;
     sumTabIndex    NUMBER;
     overWrite          BOOLEAN;
     l_AssignmentType   VARCHAR2(1);
     l_rowid            rowid;

     TYPE charTab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
     TYPE dateTab IS TABLE OF DATE       INDEX BY BINARY_INTEGER;
     TYPE numTab  IS TABLE OF NUMBER      INDEX BY BINARY_INTEGER;
     TYPE idTab   IS TABLE OF ROWID       INDEX BY BINARY_INTEGER;

     l_roleSrcTAB      WF_DIRECTORY.roleTable;
     l_userSrcTAB      WF_DIRECTORY.userTable;
     l_roleDestTAB      WF_DIRECTORY.roleTable;
     l_userDestTAB       WF_DIRECTORY.userTable;

     l_rowIDTAB          idTab;
     l_userStartSrcTAB      dateTab;
     l_roleStartSrcTAB     dateTab;
     l_userEndSrcTAB     dateTab;
     l_roleEndSrcTAB      dateTab;
     l_effStartSrcTAB     dateTab;
     l_effEndSrcTAB     dateTab;
     l_AssignTAB     charTab;
     l_userStartDestTAB     dateTab;
     l_roleStartDestTAB     dateTab;
     l_userEndDestTAB    dateTab;
     l_roleEndDestTAB      dateTab;
     l_effStartDestTAB   dateTab;
     l_effEndDestTAB     dateTab;
     l_startSrcTAB       dateTab;
     l_endSrcTAB         dateTab;
     l_startDestTAB      dateTab;
     l_endDestTAB        dateTab;
     l_relIDTAB             numTab;
     -- who column pl/sql source tables
     l_creatDtSrcTAB     dateTab;
     l_creatBySrcTAB     numTab;
     l_lastUpdDtSrcTAB   dateTab;
     l_lastUpdBySrcTAB   numTab;
     l_lastUpdLogSrcTAB  numTab;

     -- who column pl/sql summary tables
     l_creatDtDestTAB     dateTab;
     l_creatByDestTAB     numTab;
     l_lastUpdDtDestTAB   dateTab;
     l_lastUpdByDestTAB   numTab;
     l_lastUpdLogDestTAB  numTab;

     --retrieve all WF_USER_ROLE_ASSIGNMENTS records which need to
     --get summarised
     --A User/Role was updated.

     --<6028394:rwunderl> Sub-select necessary to catch effected user/roles
     cursor c_userRoleAssignments (c_userName in varchar2,
                                   c_roleName in varchar2) is
     select /*+ use_concat */ ROWID, ROLE_NAME, USER_NAME, ROLE_START_DATE,
     ROLE_END_DATE, USER_START_DATE, USER_END_DATE, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE, START_DATE, END_DATE, RELATIONSHIP_ID,
     LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
     CREATION_DATE, CREATED_BY
     from WF_USER_ROLE_ASSIGNMENTS
     where USER_NAME=c_userName
     and   ROLE_NAME in (select ROLE_NAME
                         from   WF_USER_ROLE_ASSIGNMENTS
                         where  ASSIGNING_ROLE = c_roleName
                         and    USER_NAME = c_userName)
     order by ROLE_NAME, USER_NAME;


     --A User was updated.
     cursor c_userRoleAssignments_u (c_userName in varchar2) is

     select ROWID, ROLE_NAME, USER_NAME, ROLE_START_DATE,
     ROLE_END_DATE, USER_START_DATE, USER_END_DATE, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE, START_DATE, END_DATE, RELATIONSHIP_ID,
     LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
     CREATION_DATE, CREATED_BY
     from WF_USER_ROLE_ASSIGNMENTS
     where USER_NAME=c_userName
     order by ROLE_NAME, USER_NAME;

     --A Role was updated.
     cursor c_userRoleAssignments_r (c_roleName in varchar2) is

     -- <bug 6665149> replaced query to also include those rows whose user, role
     --               pair match the directly effected user role through the
     --               given assigning role (the changed role).
--     select ROWID, ROLE_NAME, USER_NAME, ROLE_START_DATE,
--     ROLE_END_DATE, USER_START_DATE, USER_END_DATE, EFFECTIVE_START_DATE,
--     EFFECTIVE_END_DATE, START_DATE,END_DATE, RELATIONSHIP_ID,
--     LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
--     CREATION_DATE, CREATED_BY
--     from WF_USER_ROLE_ASSIGNMENTS
--     where ROLE_NAME=c_roleName or ASSIGNING_ROLE=c_roleName
--     order by ROLE_NAME, USER_NAME;
       select ura.ROWID, ura.ROLE_NAME, ura.USER_NAME, ura.ROLE_START_DATE,
              ura.ROLE_END_DATE, ura.USER_START_DATE, ura.USER_END_DATE, ura.EFFECTIVE_START_DATE,
              ura.EFFECTIVE_END_DATE, ura.START_DATE, ura.END_DATE, ura.RELATIONSHIP_ID,
              ura.LAST_UPDATE_DATE, ura.LAST_UPDATED_BY, ura.LAST_UPDATE_LOGIN,
              ura.CREATION_DATE, ura.CREATED_BY
       from WF_USER_ROLE_ASSIGNMENTS ura,
            WF_USER_ROLE_ASSIGNMENTS ura2
       where ura2.ASSIGNING_ROLE= c_roleName
       and ura2.ROLE_NAME= ura.ROLE_NAME
       and ura2.USER_NAME = ura.USER_NAME
       order by ura.ROLE_NAME, ura.USER_NAME;
      -- </bug 6665149>

    begin
      if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
            g_modulePkg||'.Aggregate_User_Roles_RF',
           'Begin Aggregate_User_Roles_RF('||rawtohex(p_sub_guid)||', '||
            p_event.getEventName||')');
      end if;



      l_rowid := chartorowid(p_event.getValueForParameter('ROWID'));

      l_RoleName := p_event.getValueForParameter('ROLE_NAME');
      l_UserName := p_event.getValueForParameter('USER_NAME');
 /*     l_LastUpdatedBy := to_number(p_event.getValueForParameter(
                                                       'LAST_UPDATED_BY'));
      l_LastUpdateDate := nvl(to_date(p_event.getValueForParameter(
                                                       'LAST_UPDATE_DATE'),
                                 WF_CORE.canonical_date_mask),SYSDATE);
      l_LastUpdateLogin := to_number(p_event.getValueForParameter(
                                                       'LAST_UPDATE_LOGIN'));
     l_CreatedBy := to_number(p_event.getValueForParameter('CREATED_BY'));
     l_CreationDate := to_date(p_event.getValueForParameter('CREATION_DATE'),
                               WF_CORE.canonical_date_mask);*/

     if (p_event.getValueForParameter('WFSYNCH_OVERWRITE') ='TRUE') then
       OverWrite := TRUE;
     else
       OverWrite:= FALSE;
     end if;


     --First check to see if we even have to run.
     if ((p_event.getValueForParameter('OLD_START_DATE') = '*UNDEFINED*') and
         (p_event.getValueForParameter('OLD_END_DATE') = '*UNDEFINED*')) then

        --we might need to  recalculate assignment type if a user/role propagation
        --has trigerred this rule function
     if (l_userName is NOT NULL and l_roleName is NOT NULL) then
         l_assignmentType := AssignmentType(p_UserName=>l_userName,
                                          p_RoleName=>l_roleName);

         --Validate the assignment type status
         UPDATE WF_LOCAL_USER_ROLES
         SET    ASSIGNMENT_TYPE = l_assignmentType
         WHERE  ROWID = l_rowid;
      end if;

       return 'SUCCESS';
     end if;

      ---retrieve all WF_USER_ROLE_ASSIGNMENTS records which need to
      --get summarized

      if (l_userName is NOT NULL and l_roleName is NOT NULL) then
        open c_userRoleAssignments (l_userName , l_roleName);
      elsif (l_userName is NOT NULL) then
        open c_userRoleAssignments_u (l_userName);
      elsif (l_roleName is NOT NULL) then
        open c_userRoleAssignments_r(l_roleName);
      else
        return 'SUCCESS';
      end if;

      sumTabIndex := 0;

      loop
      -- fetch a new batch of records
        if (l_userName is NOT NULL and l_roleName is NOT NULL) then
          fetch c_userRoleAssignments bulk collect into
          l_rowIDTAB, l_roleSrcTAB, l_userSrcTAB, l_roleStartSrcTAB,
          l_roleEndSrcTAB,l_userStartSrcTAB, l_userEndSrcTAB, l_effStartSrcTAB,
          l_effEndSrcTAB, l_StartSrcTAB, l_EndSrcTAB, l_relIDTAB,
          l_lastUpdDtSrcTAB, l_lastUpdBySrcTAB,l_lastUpdLogSrcTAB,
          l_creatDtSrcTAB, l_creatBySrcTAB limit g_maxRows;
        elsif (l_userName is NOT NULL) then
          fetch c_userRoleAssignments_u bulk collect into
          l_rowIDTAB, l_roleSrcTAB, l_userSrcTAB, l_roleStartSrcTAB,
          l_roleEndSrcTAB,l_userStartSrcTAB, l_userEndSrcTAB, l_effStartSrcTAB,
          l_effEndSrcTAB, l_StartSrcTAB, l_EndSrcTAB, l_relIDTAB,
          l_lastUpdDtSrcTAB, l_lastUpdBySrcTAB,l_lastUpdLogSrcTAB,
          l_creatDtSrcTAB, l_creatBySrcTAB limit g_maxRows;
        elsif (l_roleName is NOT NULL) then
          fetch c_userRoleAssignments_r bulk collect into
          l_rowIDTAB, l_roleSrcTAB, l_userSrcTAB, l_roleStartSrcTAB,
          l_roleEndSrcTAB,l_userStartSrcTAB, l_userEndSrcTAB, l_effStartSrcTAB,
          l_effEndSrcTAB, l_StartSrcTAB, l_EndSrcTAB, l_relIDTAB,
          l_lastUpdDtSrcTAB, l_lastUpdBySrcTAB,l_lastUpdLogSrcTAB,
          l_creatDtSrcTAB, l_creatBySrcTAB limit g_maxRows;
        end if;


        if (l_rowIDTAB.COUNT > 0) then
        ---We don't want to loop if there are no records that meet our criteria
        --we could stop right now.

          for tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST loop

          --we need to insert into summary table if this is the first
          --record to be inserted or, we have a new user/role combination
          --in the assignment table, which hasnt yet been inserted into the
          --summary table
            if ((tabIndex=l_rowIDTAB.FIRST and l_roleDestTab.COUNT < 1) or
            (l_roleDestTab.COUNT >=1 and
            ((l_roleSrcTAB(tabIndex) <> l_roleDestTAB(sumTabIndex))
            or (l_userSrcTAB(tabIndex)  <> l_userDestTAB(sumTabIndex))))) then

        -- before inserting, check whether the summarytable has
            -- grown too large

          if sumTabIndex >= g_maxRows then

           --limit reached for summary table, so perform
               --the bulk update and clear off the table.
           --We need to perform the bulk update here in addition to
               --bulk update after exit from the loop, so that clearing
               --the summary table will not lose user/role effective date
               --information when duplicate user/role
               --combinations are spread across multiple groups
                 if (OverWrite) then
                 --allow update of created_by and creation_date
             forall destTabIndex in l_roleDestTab.FIRST..l_roleDestTab.LAST

                   UPDATE WF_LOCAL_USER_ROLES wur
                   SET
                ROLE_START_DATE = l_roleStartDestTAB(destTabIndex),
                ROLE_END_DATE   = l_roleEndDestTAB(destTabIndex),
                USER_START_DATE = l_userStartDestTAB(destTabIndex),
                USER_END_DATE = l_userEndDestTAB(destTabIndex),
                EFFECTIVE_START_DATE = l_effStartDestTAB(destTabIndex),
                EFFECTIVE_END_DATE = l_effEndDestTAB(destTabIndex),
                   START_DATE = l_startDestTAB(destTabIndex),
                   EXPIRATION_DATE = l_endDestTAB(destTabIndex),
                ASSIGNMENT_TYPE = l_assignTAB(destTabIndex),
                   LAST_UPDATED_BY =  l_lastUpdByDestTAB(destTabIndex),
                   LAST_UPDATE_LOGIN =  l_lastUpdLogDestTAB(destTabIndex),
                   CREATION_DATE = nvl(l_creatDtSrcTAB(destTabIndex),CREATION_DATE),
                   CREATED_BY= nvl(l_creatBySrcTAB(destTabIndex), CREATED_BY),
                LAST_UPDATE_DATE  =  l_lastUpdDtDestTAB(destTabIndex)
                WHERE ROLE_NAME = l_roleDestTAB(destTabIndex)
               AND USER_NAME = l_userDestTAB(destTabIndex);
                else
                 forall destTabIndex in l_roleDestTab.FIRST..l_roleDestTab.LAST
                   UPDATE WF_LOCAL_USER_ROLES wur
                   SET
                   ROLE_START_DATE = l_roleStartDestTAB(destTabIndex),
                   ROLE_END_DATE   = l_roleEndDestTAB(destTabIndex),
                   USER_START_DATE = l_userStartDestTAB(destTabIndex),
                   USER_END_DATE = l_userEndDestTAB(destTabIndex),
                   EFFECTIVE_START_DATE = l_effStartDestTAB(destTabIndex),
                   EFFECTIVE_END_DATE = l_effEndDestTAB(destTabIndex),
                   START_DATE = l_startDestTAB(destTabIndex),
                   EXPIRATION_DATE = l_endDestTAB(destTabIndex),
                   ASSIGNMENT_TYPE = l_assignTAB(destTabIndex),
                   LAST_UPDATED_BY =  l_lastUpdByDestTAB(destTabIndex),
                   LAST_UPDATE_LOGIN =  l_lastUpdLogDestTAB(destTabIndex),
                   LAST_UPDATE_DATE = l_lastUpdDtDestTAB(destTabIndex)
                   WHERE ROLE_NAME = l_roleDestTAB(destTabIndex)
                   AND USER_NAME = l_userDestTAB(destTabIndex);
                end if;
                 l_roleStartDestTAB.DELETE;
                 l_roleEndDestTAB.DELETE;
                 l_userStartDestTAB.DELETE;
                 l_userEndDestTAB.DELETE;
                 l_effStartDestTAB.DELETE;
                 l_effEndDestTAB.DELETE;
                 l_assignTAB.DELETE;
                 l_roleDestTAB.DELETE;
                 l_userDestTAB.DELETE;
                   l_startDestTAB.DELETE;
                   l_endDestTAB.DELETE;
                   l_lastUpdDtDestTAB.DELETE;
                   l_lastUpdByDestTAB.DELETE;
                   l_lastUpdLogDestTAB.DELETE;
                   l_creatDtDestTAB.DELETE;
                   l_creatByDestTAB.DELETE;

           sumTabIndex := 0;

        end if;


        --now perform the insert
        sumTabIndex := sumTabIndex + 1;
        l_RoleDestTAB(sumTabIndex)     :=l_roleSrcTAB(tabIndex);
        l_UserDestTAB(sumTabIndex)     :=l_userSRcTAB(tabIndex);
        l_roleStartDestTAB(sumTabIndex):=l_roleStartSrcTAB(tabIndex);
        l_roleEndDestTAB(sumTabIndex)  :=l_roleEndSrcTAB(tabIndex);
        l_userStartDestTAB(sumTabIndex):=l_userStartSrcTAB(tabIndex);
        l_userEndDestTAB(sumTabIndex)  :=l_userEndSrcTAB(tabIndex);
        l_effStartDestTAB(sumTabIndex) :=l_effStartSrcTAB(tabIndex);
        l_effEndDestTAB(sumTabIndex)   :=l_effEndSrcTAB(tabIndex);
                l_lastUpdDtDestTAB(sumTabIndex):=l_lastUpdDtSrcTAB(tabIndex);
                l_lastUpdByDestTAB(sumTabIndex):=l_lastUpdBySrcTAB(tabIndex);
                l_lastUpdLogDestTAB(sumTabIndex):=l_lastUpdLogSrcTAB(tabIndex);
                l_creatDtDestTAB(sumTabIndex)   :=l_creatDtSrcTAB(tabIndex);
                l_creatByDestTAB(sumTabIndex)   := l_creatBySrcTAB(tabIndex);

             if l_relIDTAB(tabIndex) = -1 then
           l_AssignTAB(sumTabIndex):='D';
                   l_startDestTAB(sumTabIndex)    :=l_startSrcTAB(tabIndex);
                   l_endDestTAB(sumTabIndex)      :=l_endSrcTAB(tabIndex);
        else
               l_AssignTAB(sumTabIndex) :='I';
                  l_startDestTAB(sumTabIndex)    :=null;
                  l_endDestTAB(sumTabIndex)      :=null;
        end if;


        else
          -- check whether we have a duplicate user/role combination
          if ((l_roleSrcTAB(tabIndex) = l_roleDestTAB(sumTabIndex)) and
             (l_userSrcTAB(tabIndex)  = l_userDestTAB(sumTabIndex))) then

           --update effective_dates

           if l_effStartSrcTAB(tabIndex) <
                  l_effStartDestTAB(sumTabIndex) then
            l_effStartDestTAB(sumTabIndex):= l_effStartSrcTAB(tabIndex);
           end if;

           if l_effEndSrcTAB(tabIndex) > l_effEndDestTAB(sumTabIndex) then
        l_effEndDestTAB(sumTabIndex) := l_effEndSrcTAB(tabIndex);
           end if;

               -- update the last update date and last update login if it is later

               if l_lastUpdDtSrcTAB(tabIndex) > l_lastUpdDtDestTAB(sumTabIndex) then
                   l_lastUpdDtDestTAB(sumTabIndex):=l_lastUpdDtSrcTAB(tabIndex);
                   l_lastUpdByDestTAB(sumTabIndex):=l_lastUpdBySrcTAB(tabIndex);
                   l_lastUpdLogDestTAB(sumTabIndex):=l_lastUpdLogSrcTAB(tabIndex);
               end if;
               --if this is a direct assignment, the start and end dates need to
               --be set.
                if l_relIDTAB(tabIndex) = -1 then

                   l_startDestTAB(sumTabIndex)    :=l_startSrcTAB(tabIndex);
                   l_endDestTAB(sumTabIndex)      :=l_endSrcTAB(tabIndex);
                end if;

           --if the assignment type in summary table is Direct and
               --we encountered an inherited assignment in the Assignment table
           --or if the assignment type in summary table is inherited and we
               --encountered a direct assignment in the Assignment table
           --update the assignment_Type to Both

          if (((l_AssignTAB(sumTabIndex) = 'D') and
              (l_relIDTAB(tabIndex) <> -1)) or
             ((l_AssignTAB(sumTabIndex) = 'I') and
              (l_relIDTAB(tabIndex) = -1))) then

        l_AssignTAB(sumTabIndex) := 'B';

               end if;
        end if;
          end if;

        end loop;
      end if;

      if (l_userName is NOT NULL and l_roleName is NOT NULL) then
        exit when c_userRoleAssignments%notfound;
      elsif (l_userName is NOT NULL) then
        exit when c_userRoleAssignments_u%notfound;
      elsif (l_roleName is NOT NULL) then
        exit when c_userRoleAssignments_r%notfound;
      end if;

    end loop;

    if (l_userName is NOT NULL and l_roleName is NOT NULL) then
      close c_UserRoleAssignments;
    elsif (l_userName is NOT NULL) then
      close c_UserRoleAssignments_u;
    elsif (l_roleName is NOT NULL) then
      close c_UserRoleAssignments_r;
    end if;

    --when we reach here, we need to bulk update the leftover records ,
    --if any, in the summary table.
    if sumTabIndex> 0 then
     if (OverWrite) then
     --allow update of created_by and creation_date
      forall tabIndex in l_roleDestTab.FIRST..l_roleDestTab.LAST

          UPDATE WF_LOCAL_USER_ROLES wur
         SET
          ROLE_START_DATE = l_roleStartDestTAB(tabIndex),
          ROLE_END_DATE   = l_roleEndDestTAB(tabIndex),
          USER_START_DATE = l_userStartDestTAB(tabIndex),
          USER_END_DATE = l_userEndDestTAB(tabIndex),
          EFFECTIVE_START_DATE = l_effStartDestTAB(tabIndex),
          EFFECTIVE_END_DATE = l_effEndDestTAB(tabIndex),
         START_DATE = l_startDestTAB(tabIndex),
         EXPIRATION_DATE = l_endDestTAB(tabIndex),
          ASSIGNMENT_TYPE = l_assignTAB(tabIndex),
         LAST_UPDATED_BY =  l_lastUpdByDestTAB(tabIndex),
         LAST_UPDATE_LOGIN =  l_lastUpdLogDestTAB(tabIndex),
         LAST_UPDATE_DATE = l_lastUpdDtDestTAB(tabIndex),
         CREATION_DATE = nvl(l_creatDtSrcTAB(tabIndex),CREATION_DATE),
         CREATED_BY= nvl(l_creatBySrcTAB(tabIndex), CREATED_BY)
          WHERE ROLE_NAME = l_roleDestTAB(tabIndex)
     AND USER_NAME = l_userDestTAB(tabIndex);
     else
      forall tabIndex in l_roleDestTab.FIRST..l_roleDestTab.LAST

         UPDATE WF_LOCAL_USER_ROLES wur
         SET
         ROLE_START_DATE = l_roleStartDestTAB(tabIndex),
         ROLE_END_DATE   = l_roleEndDestTAB(tabIndex),
         USER_START_DATE = l_userStartDestTAB(tabIndex),
         USER_END_DATE = l_userEndDestTAB(tabIndex),
         EFFECTIVE_START_DATE = l_effStartDestTAB(tabIndex),
         EFFECTIVE_END_DATE = l_effEndDestTAB(tabIndex),
         START_DATE = l_startDestTAB(tabIndex),
         EXPIRATION_DATE = l_endDestTAB(tabIndex),
         ASSIGNMENT_TYPE = l_assignTAB(tabIndex),
         LAST_UPDATED_BY =  l_lastUpdByDestTAB(tabIndex),
         LAST_UPDATE_LOGIN =  l_lastUpdLogDestTAB(tabIndex),
         LAST_UPDATE_DATE = l_lastUpdDtDestTAB(tabIndex)
         WHERE ROLE_NAME = l_roleDestTAB(tabIndex)
         AND USER_NAME = l_userDestTAB(tabIndex);
     end if;
    end if;

    if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                   g_modulePkg||'.Aggregate_User_Roles_RF',
                   'End Aggregate_User_Roles_RF('||rawtohex(p_sub_guid)||', '||
                   p_event.getEventName||')');
    end if;
    return 'SUCCESS';

   EXCEPTION WHEN OTHERS THEN
    if c_UserRoleAssignments%ISOPEN then
      close c_UserRoleAssignments;
    elsif c_UserRoleAssignments_u%ISOPEN then
      close c_UserRoleAssignments_u;
    elsif c_UserRoleAssignments_r%ISOPEN then
      close c_UserRoleAssignments_r;
    end if;

    WF_CORE.Context('WF_ROLE_HIERARCHY', 'Aggregate_User_Roles_RF',
    p_event.getEventName( ), p_sub_guid);

    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    return 'ERROR';


  end Aggregate_User_Roles_RF;





   -- Public APIs
   --
   --

   --
   -- GetRelationships (PUBLIC)
   --   Retrieves the hierarchies for a given role.
   -- IN
   --   p_name           (VARCHAR2)
   --   p_superiors    (WF_ROLE_HIERARCHY.relTAB)
   --   p_subordinates (WF_ROLE_HIERARCHY.relTAB)

   procedure GetRelationships (p_name     in         VARCHAR2,
                         p_superiors      out NOCOPY WF_ROLE_HIERARCHY.relTAB,
                         p_subordinates   out NOCOPY WF_ROLE_HIERARCHY.relTAB,
                         p_direction      in         VARCHAR2 )
   is

   begin
      if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[4]
       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.GetRelationships',
                       'Begin GetRelationships('||
                       p_name||')');
      end if;
     begin

       if (p_direction in ('SUPERIORS', 'BOTH')) then
         if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.GetRelationships',
                         'Retrieving the superior relationships.');
         end if;
         SELECT            RELATIONSHIP_ID, SUB_NAME, SUPER_NAME,
                           ENABLED_FLAG
         BULK COLLECT INTO p_superiors
         FROM              WF_ROLE_HIERARCHIES
         WHERE             ENABLED_FLAG = 'Y'
         CONNECT BY PRIOR  SUPER_NAME = SUB_NAME
         START WITH        SUB_NAME = upper(p_name);

       end if;

       if (p_direction in ('SUBORDINATES', 'BOTH')) then
         if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.GetRelationships',
                         'Retrieving the subordinate relationships.');
         end if;
         SELECT            RELATIONSHIP_ID, SUB_NAME, SUPER_NAME,
                           ENABLED_FLAG
         BULK COLLECT INTO p_subordinates
         FROM              WF_ROLE_HIERARCHIES
         WHERE ENABLED_FLAG = 'Y'
         CONNECT BY PRIOR  SUB_NAME = SUPER_NAME
         START WITH        SUPER_NAME = upper(p_name);
       end if;
     end;
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.GetRelationships',
                       'End GetRelationships('||
                       p_name||')');
     end if;
   exception
     when OTHERS then
       if(wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                         g_modulePkg||'.GetRelationships', 'Exception: '||
                         sqlerrm);
       end if;
       WF_CORE.Context('WF_ROLE_HIERARCHY', 'GetRelationships', p_name);
       raise;

   end GetRelationships;

   --
   -- GetAllRelationships (PUBLIC)
   --   Retrieves both enabled and disabled hierarchies for a given role..
   -- IN
   --   p_name           (VARCHAR2)
   --   p_superiors    (WF_ROLE_HIERARCHY.relTAB)
   --   p_subordinates (WF_ROLE_HIERARCHY.relTAB)

   procedure GetAllRelationships (p_name     in         VARCHAR2,
                         p_superiors      out NOCOPY WF_ROLE_HIERARCHY.relTAB,
                         p_subordinates   out NOCOPY WF_ROLE_HIERARCHY.relTAB,
                         p_direction      in         VARCHAR2)
   is
     --<8i Support>
     TYPE super_name_Tab   is TABLE of VARCHAR2(320);
     TYPE sub_name_Tab     is TABLE of VARCHAR2(320);
     TYPE rel_ID_Tab       is TABLE of NUMBER;
     TYPE enabled_Tab      is TABLE OF VARCHAR2(1);

     superTab super_name_Tab;
     subTab   sub_name_Tab;
     relIDTAB rel_ID_Tab;
     enabledTab enabled_Tab;
     --</8i Support>

   begin
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[4]
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.GetAllRelationships',
                       'Begin GetAllRelationships('||
                       p_name||')');
     end if;
--<8i Support>
     if (p_direction in ('SUPERIORS', 'BOTH')) then
       SELECT            RELATIONSHIP_ID, SUB_NAME, SUPER_NAME,
                         ENABLED_FLAG
       BULK COLLECT INTO relIDTab, subTab, superTab, enabledTab
       FROM              WF_ROLE_HIERARCHIES
       CONNECT BY PRIOR  SUPER_NAME = SUB_NAME
       START WITH        SUB_NAME = upper(p_name);

       if (relIDTab.COUNT > 0) then
         for a in relIDTab.FIRST..relIDTab.LAST loop
           p_superiors(a).RELATIONSHIP_ID := relIDTab(a);
           p_superiors(a).SUB_NAME := subTab(a);
           p_superiors(a).SUPER_NAME := superTab(a);
           p_superiors(a).ENABLED_FLAG := enabledTab(a);
         end loop;
       end if;
     end if;

     if (p_direction in ('SUBORDINATES', 'BOTH')) then
       if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                       g_modulePkg||'.GetAllRelationships',
                       'Retrieving the subordinate relationships.');
       end if;
       SELECT            RELATIONSHIP_ID, SUB_NAME, SUPER_NAME,
                         ENABLED_FLAG
       BULK COLLECT INTO relIDTab, subTab, superTab, enabledTab
       FROM              WF_ROLE_HIERARCHIES
       CONNECT BY PRIOR  SUB_NAME = SUPER_NAME
       START WITH        SUPER_NAME = upper(p_name);

       if (relIDTab.COUNT > 0) then
         for a in relIDTab.FIRST..relIDTab.LAST loop
           p_subordinates(a).RELATIONSHIP_ID := relIDTab(a);
           p_subordinates(a).SUB_NAME := subTab(a);
           p_subordinates(a).SUPER_NAME := superTab(a);
           p_subordinates(a).ENABLED_FLAG := enabledTab(a);
         end loop;
       end if;
     end if;
--</8i Support>
/*--<9i Support>
     begin
       if (p_direction in ('SUPERIORS', 'BOTH')) then
         if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.GetAllRelationships',
                         'Retrieving the superior relationships.');
         end if;
         SELECT            RELATIONSHIP_ID, SUB_NAME, SUPER_NAME,
                           ENABLED_FLAG
         BULK COLLECT INTO p_superiors
         FROM              WF_ROLE_HIERARCHIES
         CONNECT BY PRIOR  SUPER_NAME = SUB_NAME
         START WITH        SUB_NAME = upper(p_name);
       end if;

       if (p_direction in ('SUBORDINATES', 'BOTH')) then
         if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.GetAllRelationships',
                         'Retrieving the subordinate relationships.');
         end if;
         SELECT            RELATIONSHIP_ID, SUB_NAME, SUPER_NAME,
                           ENABLED_FLAG
         BULK COLLECT INTO p_subordinates
         FROM              WF_ROLE_HIERARCHIES
         CONNECT BY PRIOR  SUB_NAME = SUPER_NAME
         START WITH        SUPER_NAME = upper(p_name);
       end if;
     end;
*/
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.GetAllRelationships',
                       'End GetAllRelationships('||
                       p_name||')');
     end if;
   exception
     when OTHERS then
       if(wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                         g_modulePkg||'.GetAllRelationships', 'Exception: '||
                         sqlerrm);
       end if;
       WF_CORE.Context('WF_ROLE_HIERARCHY', 'GetAllRelationships', p_name);
       raise;

   end GetAllRelationships;

   -- AddRelationship (PUBLIC)
   --   Creates a super/sub role hierarchy relationship in WF_ROLE_HIERARCHIES.
   -- IN
   --   p_sub_name      (VARCHAR2)
   --   p_super_name    (VARCHAR2)
   --   p_deferMode     (BOOLEAN)
   --   p_enabled       (VARCHAR2)
   --
   -- RETURNS
   --   NUMBER

   function AddRelationship (p_sub_name    in VARCHAR2,
                             p_super_name  in VARCHAR2,
                             p_deferMode   in BOOLEAN,
                 p_enabled     in varchar2) return number is
     l_RelationshipID NUMBER;
     l_sub_origSys    VARCHAR2(30);
     l_super_origSys  VARCHAR2(30);
     l_roleView       VARCHAR2(30);

     l_superiors      WF_ROLE_HIERARCHY.relTAB;
     l_subordinates   WF_ROLE_HIERARCHY.relTAB;

     HierarchyLoop     EXCEPTION;
     pragma exception_init(HierarchyLoop, -01436);

     --<rwunderl:3634880>
     trig_SavePoint  EXCEPTION;
     pragma exception_init(trig_SavePoint, -04092);
     called_from_trigger BOOLEAN := FALSE;
     l_updateTime DATE;
     l_partitionID NUMBER;
     l_superPartitionID number;

     --set the enabled_flag default to 'Y'
     l_enabled   varchar2(1) := 'Y';
     l_enabled_flag varchar2(1);

   begin
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[4]
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                         g_modulePkg||'.AddRelationship',
                        'Begin AddRelationship('||
                        p_sub_name||', '||p_super_name||')');
     end if;
     --need to serialize here to prevent potential circular loops

     g_trustTimeStamp := WF_ROLE_HIERARCHY.CreateSession;
     -- Validating Roles
     begin
       begin
         SELECT ORIG_SYSTEM, PARTITION_ID
         INTO   l_sub_origSys, l_partitionID
         FROM   WF_LOCAL_ROLES
         WHERE  NAME = p_sub_name;
       exception
         when NO_DATA_FOUND then
           WF_CORE.Token('NAME', p_sub_name);
           WF_CORE.Raise('WF_NO_ROLE');
       end;

       begin
         SELECT ORIG_SYSTEM, PARTITION_ID
         INTO   l_super_origSys, l_superPartitionID
         FROM   WF_LOCAL_ROLES
         WHERE  NAME = p_super_name;
       exception
         when NO_DATA_FOUND then
           WF_CORE.Token('NAME', p_super_name);
           WF_CORE.Raise('WF_NO_ROLE');
       end;

       -- Obtain the relationship_id from WF_ROLE_HIERARCHIES_S.
       select WF_ROLE_HIERARCHIES_S.NEXTVAL
       into   l_RelationshipID
       from   dual;

       -- Perform the insert
       if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                       g_modulePkg||'.AddRelationship.Insert',
                       'Inserting record');
       end if;
       begin
        if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                       g_modulePkg||'.AddRelationship',
                       'Setting savepoint loopCheck');
       end if;
         savepoint loopCheck;
       exception
         when trig_SavePoint then
         if(wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
           WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION,
                       g_modulePkg||'.AddRelationship',
                       'Call stack initiated from trigger, unable to set '||
                       'savepoint.  Any exception will result in complete '||
                       'rollback.');
         end if;
         called_from_trigger := TRUE;
       end;

       --Once ready to insert record verify that the enabled_flag
       --is essentially binay ie 'Y' or 'N'
       --Hence anything other than 'Y' set it to 'N'
       if (p_enabled <> 'Y') then
         l_enabled := 'N';
       end if;

       insert into WF_ROLE_HIERARCHIES
        (RELATIONSHIP_ID,
         SUB_NAME,
         SUPER_NAME,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         ENABLED_FLAG,
         SECURITY_GROUP_ID,
         PARTITION_ID,
         SUPERIOR_PARTITION_ID)
        values
         ( l_RelationshipID,
           p_sub_name,
           p_super_name,
           WFA_SEC.USER_ID,
           sysdate,
           WFA_SEC.USER_ID,
           sysdate,
           WFA_SEC.LOGIN_ID,
           l_enabled,
           WFA_SEC.SECURITY_GROUP_ID,
           l_partitionID,
           l_superPartitionID);
     exception
       when DUP_VAL_ON_INDEX then
         -- The row already exists, if it is expired, we can update with
         -- with the new information, if it is active, we will raise an error.
        if(wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION,
                         g_modulePkg||
                        '.AddRelationship.Insert.DUP_VAL_ON_INDEX',
                         'Updating existing relationship');
         end if;
         select ENABLED_FLAG into l_enabled_flag
         from WF_ROLE_HIERARCHIES
         where SUB_NAME = p_sub_name and
               SUPER_NAME = p_super_name;
         if (l_enabled_flag='Y' and l_enabled='Y') then
           --We already encountered a dup_val_on_index and the relationship is
           -- being activated despite of being active. We raise an error:
           if(wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
             WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION, g_modulePkg||
                               '.AddRelationship.Insert.DUP_VAL_ON_INDEX.NoUpdate',
                               'Active relationship exists, raising WFDS_DUP_HIERARCHY');
           end if;
           WF_CORE.Token('P_SUB_NAME', p_sub_name);
           WF_CORE.Token('P_SUPER_NAME', p_super_name);
           WF_CORE.Raise('WFDS_DUP_HIERARCHY');
         end if;
         -- If we are here then the ENABLED_FLAG is being changed, so we update
         update WF_ROLE_HIERARCHIES set
           LAST_UPDATED_BY = WFA_SEC.USER_ID,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN= WFA_SEC.USER_ID,
           ENABLED_FLAG = l_enabled,
           SECURITY_GROUP_ID = WFA_SEC.SECURITY_GROUP_ID
         where SUB_NAME = p_sub_name
         and   SUPER_NAME = p_super_name
         returning RELATIONSHIP_ID into l_relationshipID;
     end;

     --If either the superior or the subordinate is a newly created role we
     --know that it is impossible to have created a loop in the hierarchy so
     --we only validate the hierarchy if neither is in the WF_LOCAL_SYNCH.Cache
     if (NOT (WF_LOCAL_SYNCH.CheckCache(p_sub_name)) and
         NOT (WF_LOCAL_SYNCH.CheckCache(p_super_name))) then
       --Access the hierarchy to make sure a loop was not created.

       GetRelationships(p_name=>p_sub_name,
                        p_superiors=>l_superiors,
                        p_subordinates=>l_subordinates);
    else
     --We must be sure to delete the super and sub name from the
     --WF_LOCAL_SYNCH cache because they are no longer "trusted" to not
     --potentially cause a loop in the hierarchy.
     WF_LOCAL_SYNCH.DeleteCache(p_sub_name);
     WF_LOCAL_SYNCH.DeleteCache(p_super_name);
    end if;

     --Raise the oracle.apps.wf.ds.roleHierarchy.relationshipCreated event
     RaiseEvent(
        p_eventName=>'oracle.apps.fnd.wf.ds.roleHierarchy.relationshipCreated',
        p_relationshipID=>l_RelationshipID,
        p_superName=>p_super_name,
        p_subName=>p_sub_name,
        p_defer=>p_deferMode);
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, g_modulePkg||
                       '.AddRelationship',
                      'End AddRelationship('|| p_sub_name||', '||
                      p_super_name||')');
     end if;
     return l_RelationshipID;

   exception
     when HierarchyLoop then
       if(wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
         WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION,
                          g_modulePkg||'.AddRelationship',
                         'Circular reference detected in hierarchy.');
       end if;
       if (called_from_trigger) then
        if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                       g_modulePkg||'.AddRelationship',
                       'Initiation from trigger prevents rollback to '||
                       'savepoint executing complete rollback.');
        end if;
        rollback;
       else
        rollback to loopCheck;
       end if;
       if(wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                         g_modulePkg||'.AddRelationship', 'Exception: '||
                         sqlerrm);
       end if;
       WF_CORE.Context('WF_ROLE_HIERARCHY', 'AddRelationship', p_sub_name,
                       p_super_name);
       WF_CORE.Raise('WFDS_HIERARCHY_LOOP');

     when OTHERS then
       if(wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                         g_modulePkg||'.AddRelationship', 'Exception: '||
                         sqlerrm);
       end if;
       WF_CORE.Context('WF_ROLE_HIERARCHY', 'AddRelationship', p_sub_name,
                       p_super_name);
       raise;
   end AddRelationship;

   --
   -- ExpireRelationship(PUBLIC)
   --   Expires a super/sub role hierarchy relationship
   -- IN
   --   p_sub_name    (VARCHAR2)
   --   p_super_name    (VARCHAR2)
   --   p_deferMode     (BOOLEAN)
   --
   -- RETURNS
   --   NUMBER

   function ExpireRelationship (p_sub_name    in VARCHAR2,
                                p_super_name  in VARCHAR2,
                                p_defer_mode  in BOOLEAN) return number is

     l_relationshipID   NUMBER;

   begin
     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     -- Log only
     -- BINDVAR_SCAN_IGNORE[4]
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       g_modulePkg||'.ExpireRelationship',
                       'Begin ExpireRelationship('||
                       p_sub_name||', '||p_super_name||')');
     end if;
     begin
       if(wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT,
                         g_modulePkg||'.ExpireRelationship.Update',
                         'Updating record');
       end if;
       update WF_ROLE_HIERARCHIES
       set    LAST_UPDATED_BY = WFA_SEC.USER_ID,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATE_LOGIN= WFA_SEC.USER_ID,
              ENABLED_FLAG = 'N'
       where  SUB_NAME = p_sub_name
         and  SUPER_NAME = p_super_name
         and  ENABLED_FLAG = 'Y'
   returning  RELATIONSHIP_ID into l_relationshipID;

       if (sql%ROWCOUNT = 0) then
         -- There is no active role hierarchy relationship to expire
         if(wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION, g_modulePkg||
                           '.ExpireRelationship.Update.NoActiveRelationship',
                           'No Active relationship exists, '||
                           'raising WFDS_NO_HIERARCHY');
         end if;
         WF_CORE.Token('P_SUB_NAME', p_sub_name);
         WF_CORE.Token('P_SUPER_NAME', p_super_name);
         WF_CORE.Raise('WFDS_NO_HIERARCHY');
       end if;

     end;

     --Raise the oracle.apps.wf.ds.roleHierarchy.relationshipUpdated event
     RaiseEvent(
        p_eventName=>'oracle.apps.fnd.wf.ds.roleHierarchy.relationshipUpdated',
        p_relationshipID=>l_RelationshipID,
        p_superName=>p_super_name,
        p_subName=>p_sub_name,
        p_defer=>p_defer_mode);

     if(wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, g_modulePkg||
                       '.ExpireRelationship',
                      'End ExpireRelationship('|| p_sub_name||', '||
                       p_super_name||')');
     end if;

     return l_RelationshipID;

   exception
     when OTHERS then
       if(wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                         g_modulePkg||'.ExpireRelationship', 'Exception: '||
                         sqlerrm);
       end if;
       WF_CORE.Context('WF_ROLE_HIERARCHY', 'ExpireRelationship', p_sub_name,
                       p_super_name);
       raise;
   end ExpireRelationship;

   -- Denormalize_UserRole_RF (PRIVATE)
   --  Rule function to update the user and role dates of user/role
   --  relationships as well as assignments.
   -- IN
   --   p_sub_guid  (RAW)
   --   p_event     ([WF_EVENT_T])
   -- RETURNS
   --   VARCHAR2

function Denormalize_User_Role_RF ( p_sub_guid  in            RAW,
                                    p_event     in out NOCOPY WF_EVENT_T )
                                    return VARCHAR2 is



   begin
        --First check to see if we even have to run.
     if ((p_event.getValueForParameter('OLD_START_DATE') = '*UNDEFINED*') and
         (p_event.getValueForParameter('OLD_END_DATE') = '*UNDEFINED*')) then
       return 'SUCCESS';
     end if;
     Denormalize_UR_Assignments(p_event);

     return 'SUCCESS';

   exception
     when OTHERS then

       WF_CORE.Context('WF_ROLE_HIERARCHY', 'Denormalize_User_Role_RF',
          p_event.getEventName( ), p_sub_guid);

       WF_EVENT.setErrorInfo(p_event, 'ERROR');
       return 'ERROR';
end Denormalize_User_Role_RF;



----
----
-- validateSession()
--  IN
--    p_timeStamp DATE
--  RETURNS
--    BOOLEAN
function validateSession (p_timeStamp in DATE) return boolean
is
  l_updateTime DATE;

begin
  select to_date(text, WF_CORE.canonical_date_mask)
  into   l_UpdateTime
  from   WF_RESOURCES
  where  TYPE='WFTKN'
  and    NAME = 'WFDS_HIERARCHY_UPD'
  and    LANGUAGE = 'US';

    if ((p_timeStamp is NOT NULL) and (l_updateTime is NOT NULL) and
        (p_timeStamp = l_updateTime) and g_trustTimeStamp = l_updateTime) then
      return TRUE;
    else
      return FALSE;
    end if;

exception
  when NO_DATA_FOUND then
    return FALSE;

  when others then
    raise;

end validateSession;


----
----
-- createSession()
--  RETURNS
--    DATE
function createSession return DATE
is
 PRAGMA AUTONOMOUS_TRANSACTION;

begin
  g_trustTimeStamp := sysdate;
  update WF_RESOURCES
  set text = to_char(g_trustTimeStamp, WF_CORE.canonical_date_mask)
  where  name = 'WFDS_HIERARCHY_UPD';

  if (sql%rowcount = 0) then
    begin
      insert into WF_RESOURCES (TYPE,
                                NAME,
                                LANGUAGE,
                                SOURCE_LANG,
                                ID,
                                TEXT,
                                PROTECT_LEVEL,
                                CUSTOM_LEVEL) values
                             ('WFTKN',
                              'WFDS_HIERARCHY_UPD',
                              'US',
                              'US',
                              0,
                              to_char(g_trustTimeStamp,
                                      WF_CORE.canonical_date_mask),
                              0,
                              0);
    exception
      when DUP_VAL_ON_INDEX then
        null;

      when others then
        raise;

    end;
  end if;
  commit;
  return g_trustTimeStamp;

end createSession;

----
----
-- removeRelationship()
--  IN
--    relationship_id NUMBER
--  RETURNS
--    BOOLEAN
procedure removeRelationship  (p_relationshipID in NUMBER,
                               p_forceRemove in BOOLEAN
                               )
is
  l_enabled varchar2(1);
  l_relationshipID number;
  l_subName varchar2(320);
  l_superName varchar2(320);
begin

  --check the relationship status

  select enabled_flag,sub_name,super_name
  into l_enabled, l_subName , l_superName
  from wf_role_hierarchies
  where relationship_id=p_relationshipID;

  if (l_enabled='Y') then
    if (p_forceRemove is null or  not p_forceRemove) then
     -- raise error
     wf_core.token('P_RELATIONSHIPID',p_relationshipID);
     wf_core.raise('WFDS_ACTIVE_RELN');
  else
      --call API  to expire this remationship forcefully
     l_relationshipID:=ExpireRelationship(l_subName,l_superName);

     --propagate the change to user role assignments
     propagate(l_relationshipID, SYSDATE);
   end if;
  end if;

  --now remove the realtionship from the table

  Delete from WF_ROLE_HIERARCHIES
  where relationship_id=p_relationshipID;



exception
  when others then
    raise;

end removeRelationship;

 end WF_ROLE_HIERARCHY;

/
