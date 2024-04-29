--------------------------------------------------------
--  DDL for Package FND_ADPATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ADPATCH" AUTHID CURRENT_USER AS
/* $Header: AFADPATS.pls 120.1 2005/07/02 08:18:39 appldev noship $ */


FUNCTION Post_Patch(
	Session_ID in Number,           -- Autopatch Session ID
 	Message out nocopy Varchar2)	-- "Executed Successfully" or error.
RETURN VARCHAR2;		-- "TRUE" or "FALSE"


END fnd_adpatch;

 

/
