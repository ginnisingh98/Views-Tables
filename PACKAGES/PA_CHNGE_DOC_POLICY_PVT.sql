--------------------------------------------------------
--  DDL for Package PA_CHNGE_DOC_POLICY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CHNGE_DOC_POLICY_PVT" AUTHID CURRENT_USER AS
--$Header: PACIPOLS.pls 120.1.12010000.2 2009/10/06 13:18:25 jravisha noship $

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  FUNCTION SUPP_AUDT_POLICY
                       (
                          p_owner         IN          VARCHAR2,
                          p_obj_name      IN          VARCHAR2
                       )  RETURN VARCHAR2;

  PROCEDURE SET_SUPP_AUDT;

  PROCEDURE RESET_SUPP_AUDT;

  FUNCTION GET_SUPP_AUDT_POLICY RETURN VARCHAR2;

  FUNCTION CHNGE_DOC_VERS_POLICY
                       (
                          p_owner         IN          VARCHAR2,
                          p_obj_name      IN          VARCHAR2
                       )  RETURN VARCHAR2;

  PROCEDURE SET_CHNGE_DOC_VERS;

  PROCEDURE RESET_CHNGE_DOC_VERS;

  PROCEDURE ALL_CHNGE_DOC_VERS;

  FUNCTION GET_CHNGE_DOC_VERS_POLICY RETURN VARCHAR2;

END  PA_CHNGE_DOC_POLICY_PVT;

/
