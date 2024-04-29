--------------------------------------------------------
--  DDL for Package Body IBY_CC_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_CC_SECURITY_PUB" AS
/*$Header: ibyccscb.pls 120.1 2005/10/18 23:16:38 jleybovi noship $*/


  -- secure reference number prefix
  G_SEC_REF_PREFIX CONSTANT NUMBER := 9;
  -- secure reference number length
  G_SEC_REF_LENGTH CONSTANT NUMBER := 25;

  -- number of characters to leak unmasked
  G_UNMASK_LENGTH CONSTANT NUMBER := 4;
  -- masking character
  G_MASK_CHAR CONSTANT VARCHAR2(1) := 'X';

  -- USE
  --  Extracts the security segment primary key from a secured
  --  card reference number
  --
  FUNCTION Get_Segment_Id( p_sec_card_ref IN VARCHAR2 )
  RETURN iby_security_segments.sec_segment_id%TYPE
  IS
  BEGIN
    IF NOT ((SUBSTR(p_sec_card_ref,1,1) = G_SEC_REF_PREFIX)
           AND (LENGTH(p_sec_card_ref) = G_SEC_REF_LENGTH))
    THEN
      RETURN NULL;
    END IF;

    RETURN TO_NUMBER(SUBSTR(p_sec_card_ref,1 + LENGTH(G_SEC_REF_PREFIX),G_SEC_REF_LENGTH - LENGTH(G_SEC_REF_PREFIX) - G_UNMASK_LENGTH));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Segment_Id;

  FUNCTION Encryption_Enabled RETURN BOOLEAN
  IS
    l_mode             iby_sys_security_options.cc_encryption_mode%TYPE;

    CURSOR c_encrypt_mode
    IS
      SELECT cc_encryption_mode
      FROM iby_sys_security_options;
  BEGIN
    IF (c_encrypt_mode%ISOPEN) THEN CLOSE c_encrypt_mode; END IF;

    OPEN c_encrypt_mode;
    FETCH c_encrypt_mode INTO l_mode;
    CLOSE c_encrypt_mode;

    RETURN (l_mode = 'IMMEDIATE') OR (l_mode = 'SCHEDULED');
  END Encryption_Enabled;

END IBY_CC_SECURITY_PUB;

/
