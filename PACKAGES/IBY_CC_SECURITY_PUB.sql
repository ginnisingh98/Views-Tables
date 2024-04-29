--------------------------------------------------------
--  DDL for Package IBY_CC_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_CC_SECURITY_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyccscs.pls 120.1 2005/10/18 23:16:38 jleybovi noship $*/


  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FNDCPT_COMMON_PUB';

  --
  -- Return: True if encryption is enabled for the system
  --
  FUNCTION Encryption_Enabled RETURN BOOLEAN;

  FUNCTION Get_Segment_Id( p_sec_card_ref IN VARCHAR2 )
  RETURN iby_security_segments.sec_segment_id%TYPE;

END IBY_CC_SECURITY_PUB;

 

/
