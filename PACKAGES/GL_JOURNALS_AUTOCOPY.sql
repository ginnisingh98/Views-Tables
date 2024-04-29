--------------------------------------------------------
--  DDL for Package GL_JOURNALS_AUTOCOPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JOURNALS_AUTOCOPY" AUTHID CURRENT_USER AS
/* $Header: glujecps.pls 120.1 2005/05/05 01:39:21 kvora ship $ */

-- ********************************************************************
-- Procedure
--   do_autocopy
-- Purpose
--   This routine autocopies journal batches.
-- History
--   21-OCT-03		D J Ogg		Created
-- Arguments
--   Jeb_id		Id of Journal entry batch to be copied
--   New_Name		Name of new journal entry batch
--   New_Period_name    Period of new journal entry batch
--   X_Debug		Indicate if program is running in debug mode,
--			type VARCHAR2.  Default value is NULL.
-- Example
--   GL_JOURNALS_AUTOCOPY.do_autocopy('SH', 1002714, 'Y');
--

  PROCEDURE do_autocopy(Jeb_id			NUMBER,
			New_Name		VARCHAR2,
                        New_Period_Name         VARCHAR2,
			New_Eff_Date		DATE,
			X_Debug			VARCHAR2 DEFAULT NULL);

-- ********************************************************************
-- Procedure
--   do_autocopy
-- Purpose
--   This is the concurrent job version of do_autocopy.  This will be used
--   when submitting the program through SRS.
-- History
--   21-OCT-03		D J Ogg		Created
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code
--   Jeb_id		Id of Journal entry batch to be copied
--   New_Name		Name of new journal entry batch
--   New_Period_name    Period of new journal entry batch
--   New_Eff_Date	Effective Date of new journal entry batch
--   X_Debug		Indicate if program is running in debug mode,
--			type VARCHAR2.  Default value is NULL.
-- Example
--   GL_JOURNALS_AUTOCOPY.do_autocopy('SH', 1002714, 'Y');
--

  PROCEDURE do_autocopy(errbuf	OUT NOCOPY	VARCHAR2,
		 	retcode	OUT NOCOPY	VARCHAR2,
			Jeb_id			NUMBER,
			New_Name		VARCHAR2,
			New_Period_Name		VARCHAR2,
			New_Eff_Date		VARCHAR2,
			X_Debug			VARCHAR2 DEFAULT NULL);

END GL_JOURNALS_AUTOCOPY;

 

/
