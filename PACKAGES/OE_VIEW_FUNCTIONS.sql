--------------------------------------------------------
--  DDL for Package OE_VIEW_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VIEW_FUNCTIONS" AUTHID CURRENT_USER AS
--$Header: OEXVIFNS.pls 120.0 2005/05/31 23:21:04 appldev noship $

FUNCTION GET_AGREEMENT_REVISION
(
  p_Agreement_Name  Varchar2,
  p_revision        Varchar2
)
RETURN VARCHAR2;

END OE_VIEW_FUNCTIONS;

 

/
