--------------------------------------------------------
--  DDL for Package CLN_RESEND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_RESEND" AUTHID CURRENT_USER AS
/* $Header: ECXRSNDS.pls 120.0 2006/06/05 07:11:04 susaha noship $ */
--  Package
--      CLN_RESEND
--
--  Purpose
--      Resend a collaboration
--
--


  -- Name
  --   RESEND_DOC
  -- Purpose
  --   This procedure is called when resend button is clicked in the Collaboration HIstory
  --   Forms.The main purpose is to resend the document from XML gateway.
  -- Arguments
  --
  -- Notes
  --   No specific notes.



 PROCEDURE RESEND_DOC(
    p_collaboration_id      IN  NUMBER );


END CLN_RESEND;

 

/
