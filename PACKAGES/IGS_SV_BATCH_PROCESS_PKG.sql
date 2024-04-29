--------------------------------------------------------
--  DDL for Package IGS_SV_BATCH_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SV_BATCH_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSV01S.pls 120.2 2006/04/27 22:14:54 prbhardw noship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Don Shellito

 Date Created By    : Oct-01-2002

 Purpose            : This package is to be used for the processing and
                      gathering of the SEVIS related information that is
                      to be sent for transmital.

                      The concurrent programs that are to be executed are
                      defined globally.  All other procedures are to be
                      defined internally.

 remarks            : None

 Change History

Who             When           What
-----------------------------------------------------------
Don Shellito    28-Jan-2002    New Package created.

******************************************************************/

-- ------------------------------------------------------------------
-- Concurrent Program for the gathering of data on Exchange Visitors
-- ------------------------------------------------------------------
PROCEDURE EV_Batch_Process(
  errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
  p_validate_only    IN  VARCHAR2,   -- Validate only flag  'Y'  'N'
  p_org_id           IN VARCHAR2,
  p_dso_id	     IN  VARCHAR2 DEFAULT NULL
);

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

-- ------------------------------------------------------------------
-- Concurrent Program for the Deleting of unprocessed EV records.
-- ------------------------------------------------------------------
PROCEDURE EV_Purge_Batch (
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER     -- Request standard return status
);

-- ------------------------------------------------------------------
-- Concurrent Program for the Deleting of unprocessed Non immigrant records.
-- ------------------------------------------------------------------
PROCEDURE NIMG_Purge_Batch (
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER     -- Request standard return status
);

-- ------------------------------------------------------------------
-- Procedure for processing the transaction header.
-- ------------------------------------------------------------------
PROCEDURE process_trans_header (
  p_BatchID        IN NUMBER,
  p_FileErrorCode  IN VARCHAR2,
  p_FileValidation IN VARCHAR2
);

-- ------------------------------------------------------------------
-- Procedure for processing transaction errors.
-- ------------------------------------------------------------------
PROCEDURE process_trans_errors (
  p_BatchID        IN NUMBER,
  p_ErrorCode      IN VARCHAR2,
  p_ErrorMessage   IN VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2
);

-- ------------------------------------------------------------------
-- Procedure for processing Student return information.
-- ------------------------------------------------------------------
PROCEDURE process_student_record (
  p_BatchID        IN NUMBER,
  p_sevisID        IN VARCHAR2,
  p_PersonID   IN VARCHAR2,
  p_Status         IN VARCHAR2,
  p_SEVIS_ErrorCode    IN VARCHAR2,
  p_SEVIS_ErrorElement IN VARCHAR2
);

-- ------------------------------------------------------------------
-- Procedure for processing dependent return information.
-- ------------------------------------------------------------------
PROCEDURE process_dep_record (
  p_BatchID        IN NUMBER,
  p_DepPersonID        IN NUMBER,
  p_DepSevisID        IN VARCHAR2,
  p_PersonID   IN VARCHAR2,
  p_Status         IN VARCHAR2,
  p_SEVIS_ErrorCode    IN VARCHAR2,
  p_SEVIS_ErrorElement IN VARCHAR2
 );


-- ------------------------------------------------------------------
-- Procedure for generating XML.
-- ------------------------------------------------------------------
 PROCEDURE Generate_Batch_XML(
          errbuf   OUT NOCOPY VARCHAR2,
	  retcode  OUT NOCOPY NUMBER  ,
	  batch_id IN NUMBER
);

-- ------------------------------------------------------------------
-- Procedure for assigning new DSO.
-- ------------------------------------------------------------------
 PROCEDURE Assign_DSO(
          errbuf   OUT NOCOPY VARCHAR2,
	  retcode  OUT NOCOPY NUMBER  ,
	  p_group_type IN VARCHAR2,
	  p_dummy_1 IN VARCHAR2,
	  p_dummy_2 IN VARCHAR2,
	  p_old_dso_id IN VARCHAR2 DEFAULT NULL,
	  p_group_id IN VARCHAR2 DEFAULT NULL,
	  p_new_dso_id IN VARCHAR2
);

END IGS_SV_BATCH_PROCESS_PKG;

 

/
