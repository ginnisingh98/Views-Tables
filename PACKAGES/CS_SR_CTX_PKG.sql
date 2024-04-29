--------------------------------------------------------
--  DDL for Package CS_SR_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_CTX_PKG" AUTHID DEFINER as
/* $Header: csctxsrs.pls 120.0 2005/06/01 09:28:07 appldev noship $ */
/* This is the cs_sr_ctx_pkg spec in apps schema*/


  -- Used for statement Text index user-datastore.
  -- Outputs the indexable content for a statement
  procedure Build_SR_Text(
    p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB
  );

--     Remove_Tags:
--       - enable indexing of words between tags
--       - replaces all occurrences of '<' with '!'
--       p_text: the original varchar
--       returns: the modified varchar
  function Remove_Tags
  ( p_text IN VARCHAR2)
   return VARCHAR2;


--     Remove_Tags_Clob:
--       - enable indexing of words between tags
--       - replaces all occurrences of '<' with '!'
--       p_clob: the original data
--       p_temp_clob: if necessary, modified data is stored here
--       returns: pointer to either p_clob or p_temp_clob
  function Remove_Tags_Clob
  ( p_clob        IN CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB
  )
  RETURN CLOB;


end cs_sr_ctx_pkg;

/

  GRANT EXECUTE ON "APPS"."CS_SR_CTX_PKG" TO "CTXSYS";
  GRANT EXECUTE ON "APPS"."CS_SR_CTX_PKG" TO "CS";
