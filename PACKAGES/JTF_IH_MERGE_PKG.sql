--------------------------------------------------------
--  DDL for Package JTF_IH_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFIHAMS.pls 115.9 2003/01/10 20:37:06 ialeshin ship $ */


-- Start of Comments
-- Package name     : JTF_IH_MERGE
-- Purpose          : Merges duplicate customer accounts in Interaction History Table
--                    JTF_IH_ACTIVITIES.
--
-- History
-- MM-DD-YYYY    NAME          		MODIFICATIONS
-- 11-17-2000    James Baldo Jr.      	Created
--
-- End of Comments

-- Global variable declarations
   G_PROC_NAME               CONSTANT VARCHAR2(30)  := 'JTF_IH_MERGE';
   G_FILE_NAME               CONSTANT VARCHAR2(12)  := 'JTFIHAMS.pls';



   PROCEDURE MERGE(req_id   IN NUMBER,
                   set_number   IN NUMBER,
                   process_mode IN VARCHAR2);
   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE
   --   Purpose :  Calls all the individually defined account merge procedures
   --              of Interaction History.
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Parameters:
   --   IN
   --       p_request_id              IN   NUMBER     Required
   --       p_set_number              IN   NUMBER     Required
   --       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
   --   OUT:
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --


   PROCEDURE JTF_IH_MERGE(req_id   IN NUMBER,
	   		  set_num   IN NUMBER,
			  process_mode IN VARCHAR2);
   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  JTF_IH_MERGE
   --   Purpose :  Called by MERGE to update account for Interaction History table
   --              JTF_IH_ACTIVITIES.
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Parameters:
   --   IN
   --       p_request_id              IN   NUMBER     Required
   --       p_set_number              IN   NUMBER     Required
   --       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
   --   OUT:
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --



END JTF_IH_MERGE_PKG;

 

/
