--------------------------------------------------------
--  DDL for Package ICX_CAT_STORE_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_STORE_ASSIGNMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: ICXSTAGS.pls 120.1 2005/12/27 04:40:11 svasamse noship $*/

FUNCTION GET_ASSIGNED_STORE_ID(p_contentType VARCHAR2,
                               p_contentId NUMBER)
RETURN NUMBER;

FUNCTION GET_STORE_ASSIGNMENT(p_contentType VARCHAR2,
                              p_contentId NUMBER)
RETURN VARCHAR2;

END ICX_CAT_STORE_ASSIGNMENT_PKG;

 

/
