--------------------------------------------------------
--  DDL for Package IBC_CONTENT_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CONTENT_CTX_PKG" AUTHID DEFINER as
/* $Header: ibcintxs.pls 120.1 2005/08/23 04:07:51 srrangar noship $ */
/* This is the ibc_content_ctx_pkg spec in apps schema*/

  -- Used to synthesise all the related data for building index using user-datastore.
  -- Outputs the indexable content
  procedure Build_Content_Document(
    p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB
  );

end ibc_content_ctx_pkg;

/

  GRANT EXECUTE ON "APPS"."IBC_CONTENT_CTX_PKG" TO "CTXSYS";
