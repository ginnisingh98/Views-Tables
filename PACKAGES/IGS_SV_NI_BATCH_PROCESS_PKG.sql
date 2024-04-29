--------------------------------------------------------
--  DDL for Package IGS_SV_NI_BATCH_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SV_NI_BATCH_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSV03S.pls 120.0 2006/02/21 06:51:03 prbhardw noship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Manoj Kumar

 Date Created By    : Feb-15-2006

 Purpose            : This package is to do the processing of NI.  Processing
                      for EV will continue to be in IGSSV01B

 remarks            : None

 Change History

Who             When           What
-----------------------------------------------------------
Manoj Kumar    15-Feb-2006    New Package created.

******************************************************************/

-- ------------------------------------------------------------------
-- Concurrent Program for the gathering of data on Non Immigrant Students
-- ------------------------------------------------------------------
PROCEDURE NIMG_Batch_Process(
  errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
  p_validate_only    IN  VARCHAR2,   -- Validate only flag  'Y'  'N'
  p_org_id           IN VARCHAR2,
  p_dso_id	     IN  VARCHAR2 DEFAULT NULL
);


END IGS_SV_NI_BATCH_PROCESS_PKG;

 

/
