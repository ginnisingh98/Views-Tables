--------------------------------------------------------
--  DDL for Package JTF_TERRITORY_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERRITORY_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: jtfptrcs.pls 120.0 2005/06/02 18:20:49 appldev ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_CUSTOM
--    ---------------------------------------------------
--    PURPOSE
--      This package will contain all of the user defined function
--      that can be used in Territory assignment rules. This can be
--      used by customers to include complex processing as part of
--      Territory rules.
--
--    PROCEDURES:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/09/99    VNEDUNGA         Created
--      04/10/00    VNEDUNGA         Adding new validation routines
--      05/08/00    VNEDUNGA         Adding inventory ietem validation
--      06/19/00    VNEDUNGA         Adding check_partnership function call
--      07/24/00    JDOCHERT         Adding Chk_party_id function call
--                                   Adding Chk_comp_name_range function call
--
--    End of Comments
--

  -- Function to check company name (party_id)
  FUNCTION chk_party_id
     ( p_Party_Id      IN NUMBER,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;

  -- Function to check customer name range
  FUNCTION chk_comp_name_range
     ( p_Company_Name  IN VARCHAR2,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;

  -- Function to check account hierarchy
  FUNCTION check_account_Hierarchy
     ( p_Hierarchy_Id  IN NUMBER,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;

  -- Function check whether the party is a partner
  FUNCTION check_partnership
     ( p_Partner_Id    IN NUMBER,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;


  -- Check account classification
  FUNCTION check_account_classification
     ( p_Party_Id      IN NUMBER,
       p_Terr_Id       IN NUMBER,
       p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;

  -- Check Oppor classification rule
  FUNCTION check_Oppor_classification
      ( p_Lead_Id       IN NUMBER,
        p_Terr_Id       IN NUMBER,
        p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;

  -- Check Opportunity Expected purchase
  FUNCTION check_Oppor_Exp_Purchase
      ( p_Lead_Id       IN NUMBER,
        p_Terr_Id       IN NUMBER,
        p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;

  -- Check lead Expected purchase
  FUNCTION check_Lead_Exp_Purchase
      ( p_Sales_Lead_Id IN NUMBER,
        p_Terr_Id       IN NUMBER,
        p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;

  -- Check Inventory Item
  FUNCTION check_Inventory_Item
      ( p_Lead_Id       IN NUMBER,
        p_Terr_Id       IN NUMBER,
        p_Terr_Qual_Id  IN NUMBER) RETURN BOOLEAN;

END JTF_TERRITORY_CUSTOM ;



 

/
