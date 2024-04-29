--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_ITEM_CAPACITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_ITEM_CAPACITY_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSICHS.pls 120.0 2005/06/01 16:28:39 appldev noship $*/


--===================
-- PROCEDURES
--===================
--========================================================================
-- PROCEDURE : Store_Line         PUBLIC
-- PARAMETERS:
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Stores a line
--========================================================================
PROCEDURE Store_Line
  ( p_asl_id                     IN VARCHAR2
    , p_from_date                IN VARCHAR2
    , p_to_date                  IN VARCHAR2
    , p_capacity_per_day         IN NUMBER
    , p_user_id                  IN NUMBER
    );

PROCEDURE Update_Line
  ( p_asl_id                     IN VARCHAR2
    , p_capacity_id              IN NUMBER
    , p_from_date                IN VARCHAR2
    , p_to_date                  IN VARCHAR2
    , p_capacity_per_day         IN NUMBER
    , p_user_id                  IN NUMBER
    );

PROCEDURE Delete_Line
  ( p_asl_id                     IN VARCHAR2
    , p_capacity_id              IN NUMBER
  );

END POS_SUPPLIER_ITEM_CAPACITY_PKG;


 

/
