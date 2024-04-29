--------------------------------------------------------
--  DDL for Package Body RCV_TRX_INTERFACE_DELETE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRX_INTERFACE_DELETE_PKG" as
/* $Header: RCVTIR4B.pls 120.2.12010000.9 2014/03/13 07:31:52 smididud ship $ */

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM RCV_TRANSACTIONS_INTERFACE
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END RCV_TRX_INTERFACE_DELETE_PKG;

/
