--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_ITEM_TOL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_ITEM_TOL_PKG" AUTHID CURRENT_USER AS
/*$Header: POSSITHS.pls 120.0 2005/06/01 14:07:41 appldev noship $*/

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
( p_asl_id                   IN VARCHAR2
, p_days_in_advance          IN NUMBER
, p_tolerance                IN NUMBER
, p_user_id                  IN NUMBER
);

PROCEDURE Update_Line
  ( p_asl_id                   IN VARCHAR2
    , p_days_in_advance       IN NUMBER
    , p_tolerance               IN NUMBER
    , p_user_id                  IN NUMBER
    , p_days_in_advance_prev     IN NUMBER
    );

PROCEDURE delete
  ( p_asl_id                   IN VARCHAR2
 );

END POS_SUPPLIER_ITEM_TOL_PKG;

 

/
