--------------------------------------------------------
--  DDL for Package JTY_TERR_TRIGGER_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TERR_TRIGGER_HANDLERS" AUTHID CURRENT_USER as
/* $Header: jtfyrhds.pls 120.1 2006/03/30 17:26:10 achanda noship $ */
--    ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTY_TERR_TRIGGER_HANDLERS
--  ---------------------------------------------------
--  PURPOSE
--    This package defines Territory Trigger handlers.
--    Trigger handler API Spec for TABLES:
--        JTF_TERR, JTF_TERR_VALUES, JTF_TERR_RSC, JTF_TERR_RSC_ACCESS, JTF_TERR_QTYPE_USGS, JTF_TERR_QUAL
--
--  Procedures:
--    (see below for specification)
--
--  HISTORY
--    08/25/05    achanda     Created
--  End of Comments

PROCEDURE Territory_Trigger_Handler (
    p_terr_id              IN       NUMBER,
    o_parent_territory_id  IN       NUMBER,
    o_start_date_active    IN       DATE,
    o_end_date_active      IN       DATE,
    o_rank                 IN       NUMBER,
    o_num_winners          IN       NUMBER,
    o_named_acct_flag      IN       VARCHAR2,
    n_parent_territory_id  IN       NUMBER,
    n_start_date_active    IN       DATE,
    n_end_date_active      IN       DATE,
    n_rank                 IN       NUMBER,
    n_num_winners          IN       NUMBER,
    n_named_acct_flag      IN       VARCHAR2,
    Trigger_Mode           IN       VARCHAR2);

PROCEDURE Terr_Values_Trigger_Handler(
    p_terr_qual_id IN NUMBER);

PROCEDURE Terr_Rsc_Trigger_Handler(
    p_TERR_ID IN NUMBER);

PROCEDURE Terr_QType_Trigger_Handler(
    p_terr_id IN NUMBER);

PROCEDURE Terr_RscAccess_Trigger_Handler(
    p_terr_rsc_id IN NUMBER);

PROCEDURE Terr_Qual_Trigger_Handler(
    p_terr_id IN NUMBER);

PROCEDURE Terr_Usgs_Trigger_Handler(
  p_terr_id       IN NUMBER,
  p_source_id     IN NUMBER,
  triggering_mode IN VARCHAR2);

End JTY_TERR_TRIGGER_HANDLERS;

 

/
