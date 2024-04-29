--------------------------------------------------------
--  DDL for Package WF_ROLE_HIERARCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ROLE_HIERARCHY" AUTHID CURRENT_USER as
 /*$Header: WFRHIERS.pls 120.2.12010000.2 2008/08/26 20:41:02 alepe ship $*/
   -- Type definitions
   --
   TYPE relationship_REC is RECORD (RELATIONSHIP_ID  NUMBER,
                                    SUB_NAME         VARCHAR2(320),
                                    SUPER_NAME       VARCHAR2(320),
                                    ENABLED_FLAG     VARCHAR2(1));


   TYPE relTAB is TABLE of relationship_REC index by binary_integer;

   -- Package Globals
   --
   g_modulePkg varchar2(100) := 'wf.plsql.WF_ROLE_HIERARCHY';
   g_maxRows   PLS_INTEGER := 10000;

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
     function HierarchyEnabled (p_origSystem in VARCHAR2) return boolean;

 -- Calculate_Effective_Dates(PRIVATE)
   --
   -- IN
   -- p_startDate	 DATE,
   -- p_endDate		 DATE,
   -- p_userStartDate    DATE,
   -- p_userEndDate      DATE,
   -- p_roleStartDate    DATE,
   -- p_roleEndDate      DATE,
   -- p_assignRoleStart  DATE,
   -- p_assignRoleEnd    DATE,
   --
   -- IN OUT
   --   p_effStartDate    DATE
   --   p_effEndDate	  DATE
   --
   -- NOTES
   --  Calculates the effective start and end dates in WF_USER_ROLE_ASSIGNMENTS
   -- from the user/role and asigning_Role start and end dates respectively

     procedure Calculate_Effective_Dates(
			   p_startDate	     in DATE ,
			   p_endDate	     in DATE ,
			   p_userStartDate   in DATE ,
		           p_userEndDate     in DATE ,
			   p_roleStartDate   in DATE ,
			   p_roleEndDate     in DATE ,
			   p_assignRoleStart in DATE ,
			   p_assignRoleEnd   in DATE ,
			   p_effStartDate in out NOCOPY DATE,
			   p_effEndDate   in out NOCOPY DATE
			 );

   -- AddRelationship (PUBLIC)
   --   Creates a super/sub role hierarchy relationship in WF_ROLE_HIERARCHIES.
   -- IN
   --   p_sub_name	(VARCHAR2)
   --   p_super_name	(VARCHAR2)
   --   p_deferMode     (BOOLEAN)
   --
   -- RETURNS
   --   NUMBER
   --
   -- NOTES
   --   Creates a hierarchy relationship between two roles and returns the
   --   relationship id.
   function AddRelationship (p_sub_name    in VARCHAR2,
                             p_super_name  in VARCHAR2,
                             p_deferMode   in BOOLEAN default FALSE,
			     p_enabled     in varchar2 default 'Y')
    return NUMBER;

   --
   -- ExpireRelationship(PUBLIC)
   --   Expires a super/sub role hierarchy relationship
   -- IN
   --   p_sub_name	(VARCHAR2)
   --   p_super_name	(VARCHAR2)
   --   p_deferMode     (BOOLEAN)
   --
   -- RETURNS
   --   NUMBER
   --
   -- NOTES
   --   Expires a hierarchy relationship between two roles and returns the
   --   relationship id.

   function ExpireRelationship (p_sub_name    in VARCHAR2,
                                p_super_name  in VARCHAR2,
                                p_defer_mode  in BOOLEAN default FALSE)
     return NUMBER;


   --
   -- Cascade_RF
   -- IN
   --   p_sub_guid  (RAW)
   --   p_event     ([WF_EVENT_T])
   -- RETURNS
   --   VARCHAR2

   function Cascade_RF ( p_sub_guid  in            RAW,
                         p_event     in out NOCOPY WF_EVENT_T ) return VARCHAR2;

   --
   --
   -- Propagate_RF
   --   Rule function to handle events when a relationship is created or expired
   -- IN
   --   p_sub_guid  (RAW)
   --   p_event     ([WF_EVENT_T])
   -- RETURNS
   --   VARCHAR2

   function Propagate_RF ( p_sub_guid  in            RAW,
                           p_event     in out NOCOPY WF_EVENT_T )
                           return VARCHAR2;

   --
   -- Propagate (PRIVATE)
   --   Updates all existing assignments when a change occurs in a hierarchy.
   -- IN
   --   p_relationship_id (NUMBER)
   --   p_propagateDate   (DATE)


   procedure Propagate (p_relationship_id in NUMBER,
                        p_propagateDate   in DATE default sysdate);


   --
   -- Propagate_CP (PRIVATE)
   --   Concurrent program wrapper to call Propagate().
   -- IN
   --   p_relationship_id (VARCHAR2)
   --   retcode           [VARCHAR2]
   --   errbuf            [VARCHAR2]

   procedure Propagate_CP (retcode           out NOCOPY VARCHAR2,
                           errbuf            out NOCOPY VARCHAR2,
                           p_relationship_id in         VARCHAR2);


   -- Aggregate_User_Roles_RF(PRIVATE)
   --  Rule Function to update WF_LOCAL_USER_ROLES as summary table of
   --  WF_USER_ROLE_ASSIGNMENTS
   -- IN
   --   p_sub_guid  (RAW)
   --   p_event     ([WF_EVENT_T])
   -- RETURNS
   --   VARCHAR2
   function Aggregate_User_Roles_RF ( p_sub_guid  in            RAW,
                                      p_event     in out NOCOPY WF_EVENT_T)
                                      return VARCHAR2;

   --
   -- GetRelationships (PUBLIC)
   --   Retrieves the hierarchies for a given role.
   -- IN
   --   p_name		 (VARCHAR2)
   --   p_superiors      (WF_ROLE_HIERARCHY.relTAB)
   --   p_subordinates   (WF_ROLE_HIERARCHY.relTAB)

   procedure GetRelationships (p_name     in         VARCHAR2,
                         p_superiors      out NOCOPY WF_ROLE_HIERARCHY.relTAB,
                         p_subordinates   out NOCOPY WF_ROLE_HIERARCHY.relTAB,
                         p_direction      in         VARCHAR2 default 'BOTH');

   --
   -- GetAllRelationships (PUBLIC)
   --   Retrieves the hierarchies for a given role.
   -- IN
   --   p_name	       (VARCHAR2)
   --   p_superiors    (WF_ROLE_HIERARCHY.relTAB)
   --   p_subordinates (WF_ROLE_HIERARCHY.relTAB)

   procedure GetAllRelationships (p_name     in         VARCHAR2,
                         p_superiors      out NOCOPY WF_ROLE_HIERARCHY.relTAB,
                         p_subordinates   out NOCOPY WF_ROLE_HIERARCHY.relTAB,
                         p_direction      in         VARCHAR2 default 'BOTH');

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
                         return VARCHAR2;

----
----
-- validateSession() --Checks to see if the hierarchy was updated.
--  IN
--    p_timeStamp DATE
--  RETURNS
--    BOOLEAN
  function validateSession (p_timeStamp in DATE) return boolean;


----
----
-- createSession() --Creates a new session to notify other processes of change
--  RETURNS
--    DATE
  function createSession return DATE;

----
----
-- removeRelationship()-- removes a relationship from the hierarchy
-- IN
--  p_relationshipID NUMBER

  procedure removeRelationship(p_relationshipID in NUMBER,
                               p_forceRemove in BOOLEAN default null);

end WF_ROLE_HIERARCHY;

/
