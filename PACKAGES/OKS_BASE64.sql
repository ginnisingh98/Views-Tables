--------------------------------------------------------
--  DDL for Package OKS_BASE64
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BASE64" AUTHID CURRENT_USER AS
/* $Header: OKSBASES.pls 120.0 2005/05/25 17:57:57 appldev noship $ */

   -- Base64-encode a piece of binary data.
   --
   -- Note that this encode function does not split the encoded text into
   -- multiple lines with no more than 76 bytes each as required by
   -- the MIME standard.
   --
   FUNCTION encode(r IN RAW) RETURN VARCHAR2;

END;

 

/
