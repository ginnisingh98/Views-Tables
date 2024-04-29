--------------------------------------------------------
--  DDL for Package GL_MANAGEMENT_SEGMENT_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MANAGEMENT_SEGMENT_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: glumsups.pls 120.1 2005/05/05 01:41:23 kvora ship $ */
--
-- Package
--   gl_management_segment_upgrade
-- Purpose
--   Package procedures for the Management Segment Upgrade Program
-- History
--   07-APR-04	T Cheng		Created
--

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   request_lock
  -- Purpose
  --   Allocate and request a user name lock. Returns TRUE if succeeded,
  --   FALSE if failed.
  -- Arguments
  --   X_Chart_Of_Accounts_Id	Chart of accounts id
  --   X_Lock_Mode		Lock mode
  --   X_Timeout_Secs		Timeout in seconds
  --   X_Keep_Trying		Whether to keep trying in case of timeout
  --   X_Try_Times		Number of times to try
  --   X_Wait_Secs		Time to wait before retry, in seconds
  -- Example
  --   GL_MAGAGEMENT_SEGMENT_UPGRADE.request_lock(101, DBMS_LOCK.x_mode,
  --                                              60, 'Y', 10, 60);
  -- Notes
  --   Available lock modes from DBMS_LOCK:
  --    nl_mode  constant integer := 1;
  --    ss_mode  constant integer := 2;	-- Also called 'Intended Share'
  --    sx_mode  constant integer := 3;	-- Also called 'Intended Exclusive'
  --    s_mode   constant integer := 4;
  --    ssx_mode constant integer := 5;
  --    x_mode   constant integer := 6;
  --
  FUNCTION request_lock(
    X_Chart_Of_Accounts_Id NUMBER,
    X_Lock_Mode            INTEGER,
    X_Timeout_Secs         INTEGER DEFAULT 1,
    X_Keep_Trying          BOOLEAN DEFAULT FALSE,
    X_Try_Times            NUMBER DEFAULT 1,
    X_Wait_Secs            NUMBER DEFAULT 60) RETURN BOOLEAN;

  --
  -- Procedure
  --   release_lock
  -- Purpose
  --   Allocate and release a user name lock. Returns TRUE if succeeded,
  --   FALSE if failed.
  -- Arguments
  --   X_Chart_Of_Accounts_Id	Chart of accounts id
  -- Example
  --   GL_MAGAGEMENT_SEGMENT_UPGRADE.release_lock(101);
  -- Notes
  --
  FUNCTION release_lock(X_Chart_Of_Accounts_Id NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   Setup_Upgrade
  -- Purpose
  --
  -- Arguments
  --   X_Chart_Of_Accounts_Id	Chart of accounts ID
  --   X_Mgt_Seg_Column_Name	Column name of the selected management segment
  -- Example
  --   GL_MANAGEMENT_SEGMENT_UPGRADE.Setup_Upgrade
  --                                   (errbuf, retcode, 101, 'SEGMENT2');
  -- Notes
  --
  PROCEDURE Setup_Upgrade(
    X_Errbuf                OUT NOCOPY VARCHAR2,
    X_Retcode               OUT NOCOPY VARCHAR2,
    X_Chart_Of_Accounts_Id  NUMBER,
    X_Mgt_Seg_Column_Name   VARCHAR2);

  --
  -- Procedure
  --   Process_Incremental_Data
  -- Purpose
  --
  -- Arguments
  --   X_Chart_Of_Accounts_Id	Chart of accounts ID
  -- Example
  --   GL_MANAGEMENT_SEGMENT_UPGRADE.Process_Incremental_Data
  --                                   (errbuf, retcode, 101);
  -- Notes
  --
  PROCEDURE Process_Incremental_Data(
    X_Errbuf                OUT NOCOPY VARCHAR2,
    X_Retcode               OUT NOCOPY VARCHAR2,
    X_Chart_Of_Accounts_Id  NUMBER);

  --
  -- Procedure
  --   Assign_Management_Segment
  -- Purpose
  --
  -- Arguments
  --   X_Chart_Of_Accounts_Id	Chart of accounts ID
  -- Example
  --   GL_MANAGEMENT_SEGMENT_UPGRADE.Assign_Management_Segment
  --                                   (errbuf, retcode, 101);
  -- Notes
  --
  PROCEDURE Assign_Management_Segment(
    X_Errbuf                OUT NOCOPY VARCHAR2,
    X_Retcode               OUT NOCOPY VARCHAR2,
    X_Chart_Of_Accounts_Id  NUMBER);

END GL_MANAGEMENT_SEGMENT_UPGRADE;

 

/
