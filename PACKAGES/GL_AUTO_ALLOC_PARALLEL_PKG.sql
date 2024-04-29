--------------------------------------------------------
--  DDL for Package GL_AUTO_ALLOC_PARALLEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTO_ALLOC_PARALLEL_PKG" AUTHID CURRENT_USER AS
/* $Header: glalplls.pls 120.1 2002/04/10 19:26:01 djogg ship $ */

diagn_msg_flag       BOOLEAN := TRUE;
PROCEDURE diagn_msg (message_string   IN  VARCHAR2);

  --   get_unique_id
  -- Purpose
  --    Submit generation concurrent program for each step in the allocation set
  --    And insert record for each concurrent program launched into
  --    GL_AUTO_ALLOC_BAT_HIST_DET
  -- Arguments
  --    Allocation set request Id
  -- Notes
  --

Procedure Start_Auto_Allocation_Parallel(p_request_Id       IN NUMBER);

End GL_AUTO_ALLOC_PARALLEL_PKG;

 

/
