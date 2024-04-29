--------------------------------------------------------
--  DDL for Package IGI_POST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_POST" AUTHID CURRENT_USER AS
-- $Header: igiposts.pls 120.4.12010000.2 2008/08/04 13:05:37 sasukuma ship $
--

  PROCEDURE IGI_POST_GL_POSTING(P_POSTING_RUN_ID IN NUMBER);

END IGI_POST;

/
