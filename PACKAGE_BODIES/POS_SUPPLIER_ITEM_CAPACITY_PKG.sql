--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_ITEM_CAPACITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_ITEM_CAPACITY_PKG" AS
/* $Header: POSSICHB.pls 120.1 2005/06/29 15:43:28 jacheung noship $*/

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
    , p_from_date                IN VARCHAR2
    , p_to_date                  IN VARCHAR2
    , p_capacity_per_day         IN NUMBER
    , p_user_id                  IN NUMBER
    )
  IS

BEGIN

   insert into po_supplier_item_capacity
     (CAPACITY_ID,
      ASL_ID,
      USING_ORGANIZATION_ID,
      FROM_DATE,
      TO_DATE,
      CAPACITY_PER_DAY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
     values (
	     po_supplier_item_capacity_s.nextval,
	     to_number(p_asl_id),
	     -1,
	     to_date(p_from_date, 'YYYY-MM-DD'),
	     to_date(p_to_date, 'YYYY-MM-DD'),
	     p_capacity_per_day,
	     sysdate,
	     p_user_id,
	     p_user_id,
	     sysdate,
	     p_user_id);


EXCEPTION when others THEN
   raise;

END Store_Line;

PROCEDURE Update_Line
  ( p_asl_id                   IN VARCHAR2
    , p_capacity_id              IN NUMBER
    , p_from_date                IN VARCHAR2
    , p_to_date                  IN VARCHAR2
    , p_capacity_per_day         IN NUMBER
    , p_user_id                  IN NUMBER
    )
  IS

sourcedate      date;
destdate        date;

BEGIN

   sourcedate := to_date(p_from_date, 'YYYY-MM-DD');
   destdate   := to_date(p_to_date, 'YYYY-MM-DD');

   UPDATE po_supplier_item_capacity
     SET
     FROM_DATE = sourcedate,
     TO_DATE = destdate,
     CAPACITY_PER_DAY = p_capacity_per_day,
     last_update_date = Sysdate,
     last_updated_by = p_user_id,
     last_update_login = p_user_id
     WHERE
     asl_id = To_number(p_asl_id) AND capacity_id = p_capacity_id;



EXCEPTION WHEN OTHERS THEN
   RAISE;

END update_line;


PROCEDURE Delete_Line
  ( p_asl_id                   IN VARCHAR2
    , p_capacity_id              IN NUMBER
    )
  IS

BEGIN

   DELETE from po_supplier_item_capacity
     WHERE
     asl_id = To_number(p_asl_id) AND capacity_id = p_capacity_id;

EXCEPTION WHEN OTHERS THEN
   RAISE;

END delete_line;

END POS_SUPPLIER_ITEM_CAPACITY_PKG;

/
