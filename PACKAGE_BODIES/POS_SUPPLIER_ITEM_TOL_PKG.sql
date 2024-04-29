--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_ITEM_TOL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_ITEM_TOL_PKG" AS
/*$Header: POSSITHB.pls 120.1 2005/06/29 15:44:02 jacheung noship $*/

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
)
IS

BEGIN

insert into po_supplier_item_tolerance
          (
           ASL_ID,
           USING_ORGANIZATION_ID,
           NUMBER_OF_DAYS,
           TOLERANCE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY
           )
        values (
           to_number(p_asl_id),
           -1,
           nvl(p_days_in_advance, 0),
           nvl(p_tolerance, 0),
           sysdate,
           p_user_id,
           p_user_id,
           sysdate,
           p_user_id );


EXCEPTION when others THEN
raise;

END Store_Line;

PROCEDURE Update_Line
  ( p_asl_id                   IN VARCHAR2
    , p_days_in_advance       IN NUMBER
    , p_tolerance               IN NUMBER
    , p_user_id                  IN NUMBER
    , p_days_in_advance_prev     IN NUMBER
    )
  IS

BEGIN

   UPDATE po_supplier_item_tolerance
     SET
     NUMBER_OF_DAYS = p_days_in_advance,
     TOLERANCE = p_tolerance,
     last_update_date = Sysdate,
     last_updated_by = p_user_id,
     last_update_login = p_user_id
     WHERE
     asl_id = To_number(p_asl_id) AND number_of_days = p_days_in_advance_prev;


EXCEPTION WHEN OTHERS THEN
   RAISE;

END update_line;

PROCEDURE delete
  ( p_asl_id                   IN VARCHAR2
   )
  IS

BEGIN

   DELETE from po_supplier_item_tolerance
     WHERE
     asl_id = To_number(p_asl_id);


EXCEPTION WHEN OTHERS THEN
   RAISE;

END delete;


END POS_SUPPLIER_ITEM_TOL_PKG;

/
