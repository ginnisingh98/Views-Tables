--------------------------------------------------------
--  DDL for Package Body AMS_IMPORT_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMPORT_SECURITY_PVT" as
/* $Header: amsvimsb.pls 115.6 2004/04/20 01:58:52 sranka ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Import_Security_PVT
-- Purpose
--
-- History
--    07-Nov-2002   HUILI      Created
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_HASH_FORMAT CONSTANT VARCHAR2(2000) := rpad( 'X',29,'X')||'X';
G_HARD_CODE_KEY CONSTANT VARCHAR2(20) := 'AMSIMPORT';

PROCEDURE Get_Encrypt_Key (
	p_import_header_id	IN		NUMBER,
	x_key					 OUT NOCOPY VARCHAR2
)
IS
	CURSOR c_get_created_by (p_imp_header_id IN NUMBER) IS
      SELECT CREATED_BY
      FROM AMS_IMP_LIST_HEADERS_ALL
      WHERE  IMPORT_LIST_HEADER_ID = p_imp_header_id;
	l_created_by  NUMBER;
BEGIN
	OPEN c_get_created_by (p_import_header_id);
	FETCH c_get_created_by INTO l_created_by;
	CLOSE c_get_created_by;

	x_key :=
		ltrim( to_char( dbms_utility.get_hash_value(p_import_header_id || l_created_by,1000000000, power(2,30) ), G_HASH_FORMAT) );
END Get_Encrypt_Key;

FUNCTION Get_DeEncrypt_String (
	p_input_string		IN		VARCHAR2,
	p_header_id			IN		NUMBER,
	p_encrypt_flag    IN    BOOLEAN -- field to indicate whether it is
											  --  encrypt or decrypt
) RETURN VARCHAR2
IS
	l_key  VARCHAR2(2000);
	l_out_string VARCHAR2(2000);
  l_length NUMBER;
  l_input_string VARCHAR2(2000);

BEGIN
	IF p_header_id IS NULL THEN
		l_key := G_HARD_CODE_KEY;
	ELSE
		Get_Encrypt_Key (
			p_import_header_id => p_header_id,
			x_key					 => l_key
		);
	END IF;

	IF p_encrypt_flag THEN
		l_length := (trunc(length(p_input_string)/8)+1)*8;
    l_input_string := p_input_string;
    WHILE length(l_input_string) < l_length
    LOOP
      l_input_string := l_input_string || chr(0);
    END LOOP;
    dbms_obfuscation_toolkit.DESEncrypt(
			--input_string		=> rpad(p_input_string, (trunc(length(p_input_string)/8)+1)*8, chr(0) ),
      input_string		=> l_input_string,
			key_string			=> l_key,
			encrypted_string  => l_out_string);
	ELSE
		dbms_obfuscation_toolkit.DESDecrypt(
			input_string		=> p_input_string,
			key_string			=> l_key,
			decrypted_string  => l_out_string);
		l_out_string := rtrim (l_out_string, chr(0));
	END IF;
	RETURN l_out_string;
END Get_DeEncrypt_String;


END AMS_Import_Security_PVT;

/
