--------------------------------------------------------
--  DDL for Package XDP_WF_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_WF_MIGRATE" AUTHID CURRENT_USER AS
/* $Header: XDPMWFS.pls 120.0 2005/05/30 12:51:00 appldev noship $ */

-- These are Package Level Variables which stores the new ID's during Pre Processing
 g_WF_ADHOC_ROLE_S_SEQ number;
 g_WF_NOTIFICATIONS_S_SEQ number;
 g_WF_PROCESS_ACTIVITIES_S_SEQ number;
 g_UniqueSuffix varchar2(3);

-- The COMMIT count. If large amounts of data is expected set this appropriately.
 g_CommitCount number;
 g_ItemKeyCount number;

 e_WrongDataException exception;

-- PL/SQL Record to store any Lookup Type (Internal Name) Conflicts
 TYPE WF_LOOKUP_TYPE_TL_REC is RECORD
        (LOOKUP_TYPE varchar2(30),
	 LOOKUP_TYPE_NEW varchar2(30));

-- PL/SQL Record to store any Lookup Type (Display Name) Conflicts
 TYPE WF_LOOKUP_TYPE_TL_DISP_REC is RECORD
        (DISPLAY_NAME varchar2(80),
         LANGUAGE varchar2(30),
	 DISPLAY_NAME_NEW varchar2(80));

-- PL/SQL Record to store Item Types to be moved
 TYPE WF_ITEM_TYPE_REC is RECORD
        (ITEM_TYPE varchar2(8));

-- Table of Lookup Type Conflicts Record
 TYPE WF_LOOKUP_TYPE_TL_LIST is TABLE of WF_LOOKUP_TYPE_TL_REC
	INDEX BY BINARY_INTEGER;

-- Table of Display Name Conflicts Record
 TYPE WF_LOOKUP_TYPE_TL_DISP_LIST is TABLE of WF_LOOKUP_TYPE_TL_DISP_REC
	INDEX BY BINARY_INTEGER;

-- Table of Item Types
 TYPE WF_ITEM_TYPE_LIST is TABLE of WF_ITEM_TYPE_REC
	INDEX BY BINARY_INTEGER;

-- Global Table of Records used
 g_WF_LOOKUP_TYPE_TL_LIST WF_LOOKUP_TYPE_TL_LIST;
 g_WF_LOOKUP_TYPE_TL_DISP_LIST WF_LOOKUP_TYPE_TL_DISP_LIST;
 g_WF_ITEM_TYPE_LIST WF_ITEM_TYPE_LIST;


-- Function to Verify the Suffix which will be used when Lookup Type and Display Name
-- conflicts are found
  Function VerifySuffix (UniqueSuffix in varchar2) return boolean;

-- Function to Verify if the Item Type can be moved. Non WF Item Types which are
-- NOT present in the Target can only be moved
  Function VerifyItemType return boolean;

-- Verify the WF_ROLES definition. Check is the values from Source are present at Target
  Function VerifyDirectory return boolean;

-- Construct the new lookup type when a conflict is found
  Function GetUniqueLookupType(LookupType in varchar2, Suffix in varchar2) return varchar2;

-- Construct the new lookup type when a conflict is found
  Function GetUniqueLookupType(LookupType in varchar2) return varchar2;
   pragma RESTRICT_REFERENCES(GetUniqueLookupType, WNDS, WNPS);

-- Construct the new display name when a conflict is found
  Function GetUniqueDisplayName(DisplayName in varchar2, Suffix in varchar2) return varchar2;

-- Construct the new display name when a conflict is found
  Function GetUniqueDisplayName(DisplayName in varchar2) return varchar2;
   pragma RESTRICT_REFERENCES(GetUniqueDisplayName, WNDS, WNPS);

-- Procedures used in the Pre Processing Stage
  Procedure InitializeSequences;
  Procedure PreProcessMigration;
  Procedure PreProcessLookupTypes;
  Procedure ResetSequenceNumbers;


-- Move Configuration Data
  Procedure MoveConfigData;

-- Move Move RunTime Data Data
  Procedure MoveRunTimeData;

-- Move WF_LOCAL Roles
  Procedure MoveLocalRoles;

-- Move WF_LOCAL Users
  Procedure MoveLocalUsers;

-- Move WF_LOCAL User Roles
  Procedure MoveLocalUserRoles;


-- Post Processing
  Procedure ReEnqueueDefferedAct;
  Procedure PostProcess;

  Procedure Display(text_value in varchar2, which in varchar2) ;

-- Create log files
  Procedure Create_Log_Files (p_log_prefix IN VARCHAR2 DEFAULT 'XDPMIGRT_');

end XDP_WF_MIGRATE;

 

/
