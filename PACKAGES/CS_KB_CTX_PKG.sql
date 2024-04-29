--------------------------------------------------------
--  DDL for Package CS_KB_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_CTX_PKG" AUTHID DEFINER as
/* $Header: cskbdsts.pls 120.0.12010000.2 2009/07/20 13:37:46 gasankar ship $ */
/* This is the cs_kb_ctx_pkg spec in apps schema*/

  -- Used for solution Text index user-datastore.
  -- Outputs the indexable content for a solution
  procedure Get_Composite_Elements(
    p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB
  );

  --12.1.3
   procedure Get_Composite_Attach_Elements(
    p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB
  );
  --12.1.3

  -- Used for statement Text index user-datastore.
  -- Outputs the indexable content for a statement
  procedure Build_Elements(
    p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB
  );

  -- Synthesizes content from a solution and its statements,
  -- categories, products, platforms, and other attributes
  -- into a single CLOB
  procedure Synthesize_Solution_Content
  ( p_solution_id IN            NUMBER,
    p_lang        IN            VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB);


  --Start 12.1.3
    -- Synthesizes content from a solution and its statements,
  -- categories, products, platforms, and other attributes
  -- into a single CLOB
  procedure Synthesize_Sol_Attach_Content
  ( p_solution_id IN            NUMBER,
    p_lang        IN            VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB);

  --End 12.1.3

  -- Synthesizes content of a statement, including its summary
  -- and description into a single CLOB
--  procedure Synthesize_Statement_Content
--  ( p_statement_id IN            NUMBER,
--    p_lang        IN            VARCHAR2,
--    p_clob        IN OUT NOCOPY CLOB);



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

end cs_kb_ctx_pkg;

/

  GRANT EXECUTE ON "APPS"."CS_KB_CTX_PKG" TO "CTXSYS";
  GRANT EXECUTE ON "APPS"."CS_KB_CTX_PKG" TO "CS";
