--------------------------------------------------------
--  DDL for Package XDP_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_MESSAGE" AUTHID CURRENT_USER AS
/* $Header: XDPMSGPS.pls 120.2 2006/04/10 23:23:39 dputhiye noship $ */

-- Procedure:   retry_failed_message
-- Purpose:     Retries Failed message
-- Parameters:  Message to retry (character matching allowed, e.g. 'XNP%')
-- Comments:    Responds to Workflow notification sent for failed message.
--              which in turn invokes workflow which retries message.
-- Called from: Concurrent program 'XDP Resubmit Failed Messages' (XDPRESUB.sql)
PROCEDURE retry_failed_message
              ( errbuf         OUT NOCOPY VARCHAR2     -- Fixing 3957604. GSCC warning to add NOCOPY hint. Added hint
              , retcode        OUT NOCOPY VARCHAR2     -- to errbuf and retcode arguments
              , p_msg_to_retry IN  VARCHAR2 ) ;

END xdp_message;

 

/
