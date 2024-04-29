--------------------------------------------------------
--  DDL for Package IRC_DOC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOC_UTIL" AUTHID CURRENT_USER AS
/* $Header: iridoutl.pkh 120.0.12010000.1 2008/07/28 12:42:15 appldev ship $ */


  FUNCTION getContentTeaser(p_document_id INTEGER,
                            p_search_string VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION getContentTeaser(p_document_id           INTEGER,
                            p_search_string    VARCHAR2,
                            p_ctx_index VARCHAR2)
    RETURN VARCHAR2;

IRC_DEFAULT_INDEX CONSTANT VARCHAR2(30) DEFAULT 'IRC_DOCUMENTS_CTX1';
MARKUP_START_TAG CONSTANT VARCHAR2(3) := '<B>';
MARKUP_END_TAG CONSTANT VARCHAR2(4) := '</B>';
MAX_TEASER_LINES CONSTANT PLS_INTEGER DEFAULT 2;
TEASER_LINE_LENGTH CONSTANT PLS_INTEGER DEFAULT 150;
ADD_EXTRA_CHARS CONSTANT PLS_INTEGER DEFAULT 10;


END IRC_DOC_UTIL;

/
