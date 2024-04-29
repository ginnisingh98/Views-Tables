--------------------------------------------------------
--  DDL for Package CS_KB_KWIC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_KWIC_UTIL" AUTHID CURRENT_USER AS
/* $Header: cskbkwics.pls 120.0 2005/06/24 13:36:33 appldev noship $ */

/*
 *
 * +======================================================================+
 * |                Copyright (c) 2005 Oracle Corporation                 |
 * |                   Redwood Shores, California, USA                    |
 * |                        All rights reserved.                          |
 * +======================================================================+
 *
 *   FILENAME
 *     cskbkwics.pls
 *   PURPOSE
 *     Creates the package for CS_KB_KWIC_UTIL
 *     CS_KB_KWIC_UTIL supports the Keywords In Context implementation
 *
 *   HISTORY
 *   12-APR-2005 HMEI Created.
 */

--
-- Procedures and Functions
--
  FUNCTION highlight_text
  (
  p_text_query  IN VARCHAR2,
  p_document    IN VARCHAR2,
  p_starttag    IN VARCHAR2,
  p_endtag      IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_set_snippet
  (
  p_set_id      IN NUMBER,
  p_text_query  IN VARCHAR2,
  p_starttag    IN VARCHAR2,
  p_endtag      IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_sr_snippet
  (
  p_sr_id       IN NUMBER,
  p_text_query  IN VARCHAR2,
  p_starttag    IN VARCHAR2,
  p_endtag      IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_segment_kwic
  (
  p_text_query  IN VARCHAR2,
  p_starttag    IN VARCHAR2,
  p_endtag      IN VARCHAR2,
  p_document    IN CLOB
  ) RETURN VARCHAR2;

end CS_KB_KWIC_UTIL;

 

/
