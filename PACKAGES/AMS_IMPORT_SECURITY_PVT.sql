--------------------------------------------------------
--  DDL for Package AMS_IMPORT_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMPORT_SECURITY_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvimss.pls 115.1 2002/11/12 23:38:45 jieli noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Import_Security_PVT
-- Purpose
--
-- History
--
--    07-NOV-2002  huili       Created
-- NOTE
--
-- End of Comments
-- ===============================================================
FUNCTION Get_DeEncrypt_String (
	p_input_string		IN		VARCHAR2,
	p_header_id			IN		NUMBER,
	p_encrypt_flag    IN    BOOLEAN -- field to indicate whether it is
											  --  encrypt or decrypt
) RETURN VARCHAR2;

END AMS_Import_Security_PVT;

 

/
