--------------------------------------------------------
--  DDL for Package Body PO_CHANGE_ORDER_TOLERANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHANGE_ORDER_TOLERANCES_PKG" as
/* $Header: PO_CHANGE_ORDER_TOLERANCES_PKG.plb 120.2.12010000.2 2008/11/24 11:03:15 rojain ship $ */

------------------------------------------------------------------------------
--Start of Comments
--Name: INSERT_ROW
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--   1. inserts a record into PO_CHANGE_ORDER_TOLERANCES_ALL table
--Parameters:
--IN:
--   X_CHANGE_ORDER_TYPE Change Order Type
--   X_TOLERANCE_NAME    Tolerance name
--   X_ORG_ID            Operating Unit Id
--   X_SEQUENCE_NUMBER   Tolerance sequence number
--   X_MAXIMUM_INCREMENT maximum increment value
--   X_MAXIMUM_DECREMENT minimum increment value
--   X_ROUTING_FLAG      approval routing flag
--   X_CREATION_DATE     creation date (Standard Who Column)
--   X_CREATED_BY        created date (Standard Who Column)
--   X_LAST_UPDATE_DATE  last update date (Standard Who Column)
--   X_LAST_UPDATED_BY   last updated by (Standard Who Column)
--   X_LAST_UPDATE_LOGIN last update login (Standard Who Column)
--OUT:
--  None
--End of Comment
-------------------------------------------------------------------------------
procedure INSERT_ROW (
 X_CHANGE_ORDER_TYPE in VARCHAR2,
 X_TOLERANCE_NAME in VARCHAR2,
 X_ORG_ID in NUMBER,
 X_SEQUENCE_NUMBER in NUMBER,
 X_MAXIMUM_INCREMENT in NUMBER,
 X_MAXIMUM_DECREMENT in NUMBER,
 X_ROUTING_FLAG in VARCHAR2,
 X_CREATION_DATE in DATE,
 X_CREATED_BY in NUMBER,
 X_LAST_UPDATE_DATE in DATE,
 X_LAST_UPDATED_BY in NUMBER,
 X_LAST_UPDATE_LOGIN in NUMBER)
 is
 x_tolerance_id number;
begin

    select to_char(PO_CHANGE_ORDER_TOLERANCES_S.NEXTVAL)
          into X_TOLERANCE_ID from sys.dual;

  insert into PO_CHANGE_ORDER_TOLERANCES_ALL (
  TOLERANCE_ID,
  CHANGE_ORDER_TYPE,
  TOLERANCE_NAME,
  ORG_ID,
  SEQUENCE_NUMBER,
  MAXIMUM_INCREMENT,
  MAXIMUM_DECREMENT,
  ROUTING_FLAG,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN
  ) values (
  X_TOLERANCE_ID,
  X_CHANGE_ORDER_TYPE,
  X_TOLERANCE_NAME,
  X_ORG_ID,
  X_SEQUENCE_NUMBER,
  X_MAXIMUM_INCREMENT,
  X_MAXIMUM_DECREMENT,
  X_ROUTING_FLAG,
  X_CREATION_DATE,
  X_CREATED_BY,
  X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN);

end INSERT_ROW;

------------------------------------------------------------------------------
--Start of Comments
--Name: LOAD_ROW
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--   1. Load the row into PO_CHANGE_ORDER_TOLERANCES_ALL table
--Parameters:
--IN:
--   X_CHANGE_ORDER_TYPE Change Order Type
--   X_TOLERANCE_NAME    Tolerance name
--   X_ORG_ID            Operating Unit Id
--   X_SEQUENCE_NUMBER   Tolerance sequence number
--   X_MAXIMUM_INCREMENT maximum increment value
--   X_MAXIMUM_DECREMENT minimum increment value
--   X_ROUTING_FLAG      approval routing flag
--OUT:
--  None
--End of Comment
-------------------------------------------------------------------------------
procedure LOAD_ROW (
  X_CHANGE_ORDER_TYPE in VARCHAR2,
  X_TOLERANCE_NAME in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_MAXIMUM_INCREMENT in NUMBER,
  X_MAXIMUM_DECREMENT in NUMBER,
  X_ROUTING_FLAG in VARCHAR2,
  X_CUSTOM_MODE  in VARCHAR2
) IS

    f_luby    number;  -- entity owner in file
    f_ludate  date;    -- entity update date in file
    db_luby   number;  -- entity owner in db
    db_ludate date;    -- entity update date in db

  begin

     f_luby := fnd_load_util.owner_id(X_OWNER);
     f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'DD/MM/YYYY'), sysdate);

     -- bug3703523
     -- for old see data we have last_updated_by as -1.
     -- upload_test procedure will consider the record as being customized,
     -- which is not the case here. Therefore we need to update
     -- last_updated_by to 1 when it is -1 so that the record can be updated.

     select DECODE(LAST_UPDATED_BY, -1, 1, LAST_UPDATED_BY), LAST_UPDATE_DATE
     into  db_luby, db_ludate
     from PO_CHANGE_ORDER_TOLERANCES_ALL
     where change_order_Type  = X_CHANGE_ORDER_TYPE
     and  TOLERANCE_NAME   = X_TOLERANCE_NAME
     and  ( (X_ORG_ID is null and org_id = -3113 )
          or (X_ORG_ID is not null and org_id = X_ORG_ID));

    -- Chanded the condition in such a way that only date is considered while updating owner is not updated
    -- if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then
    if (fnd_load_util.upload_test(f_luby, f_ludate, f_luby, db_ludate, X_CUSTOM_MODE)) then

       UPDATE PO_CHANGE_ORDER_TOLERANCES_ALL
       SET MAXIMUM_INCREMENT =  X_MAXIMUM_INCREMENT,
           MAXIMUM_DECREMENT =  X_MAXIMUM_DECREMENT,
           ROUTING_FLAG	     =  X_ROUTING_FLAG,
           LAST_UPDATE_DATE  =  f_ludate ,
           LAST_UPDATED_BY   = 	f_luby,
           LAST_UPDATE_LOGIN = 0
       WHERE CHANGE_ORDER_TYPE  = X_CHANGE_ORDER_TYPE
       AND  TOLERANCE_NAME   = X_TOLERANCE_NAME
       AND  ( (X_ORG_ID IS NULL AND ORG_ID = -3113 )
           OR (X_ORG_ID IS NOT NULL AND ORG_ID = X_ORG_ID));

    end if;


  exception
     when NO_DATA_FOUND then
          INSERT_ROW (
            X_CHANGE_ORDER_TYPE,
            X_TOLERANCE_NAME,
            X_ORG_ID,
            X_SEQUENCE_NUMBER,
            X_MAXIMUM_INCREMENT,
            X_MAXIMUM_DECREMENT,
            X_ROUTING_FLAG,
            f_ludate ,
            f_luby ,
            f_ludate ,
            f_luby ,
            0);
end LOAD_ROW;


end PO_CHANGE_ORDER_TOLERANCES_PKG;

/
