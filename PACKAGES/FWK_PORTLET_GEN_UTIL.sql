--------------------------------------------------------
--  DDL for Package FWK_PORTLET_GEN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FWK_PORTLET_GEN_UTIL" AUTHID CURRENT_USER as
/* $Header: fwkportgenutls.pls 120.0.12010000.3 2009/07/22 17:55:49 gjimenez noship $ */

  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC METHODS ---------------------------------
  -----------------------------------------------------------------------------

  -- Return back the full Page Metadata.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  FUNCTION getPageMetaData(p_document in VARCHAR2)
  RETURN CLOB;



    -----------------------------------------------------------------------------
    ---------------------------- PUBLIC METHODS ---------------------------------
    -----------------------------------------------------------------------------

    -- Return Path Name for specific document ID.
    --
    -- Parameters:
    --  p_docid    - the fully qualified document id

  FUNCTION getPathName(p_docid in NUMBER)
  RETURN VARCHAR;

    -----------------------------------------------------------------------------
    ---------------------------- PUBLIC METHODS ---------------------------------
    -----------------------------------------------------------------------------

    -- Return Path Name for specific document ID.
    --
    -- Parameters:
    --  p_docid    - the fully qualified document id


  PROCEDURE refresh_mview(errbuf    out nocopy varchar2,
                          retcode   out nocopy number);

END FWK_PORTLET_GEN_UTIL;

/
