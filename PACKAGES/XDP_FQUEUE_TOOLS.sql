--------------------------------------------------------
--  DDL for Package XDP_FQUEUE_TOOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_FQUEUE_TOOLS" AUTHID CURRENT_USER as
/* $Header: XDPFQTLS.pls 120.2 2006/04/10 23:20:51 dputhiye noship $ */

  FUNCTION No_Entries(queued_id VARCHAR2)                  RETURN NUMBER;
  FUNCTION Max_Entry_Date(queued_id VARCHAR2)              RETURN DATE;
  FUNCTION Processors_Running(queued_id VARCHAR2)          RETURN NUMBER;
  PROCEDURE Do_Commit;
END XDP_FQueue_Tools;

 

/
