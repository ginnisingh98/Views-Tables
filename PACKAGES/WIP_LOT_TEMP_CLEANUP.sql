--------------------------------------------------------
--  DDL for Package WIP_LOT_TEMP_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_LOT_TEMP_CLEANUP" AUTHID CURRENT_USER AS
/* $Header: wipltcls.pls 115.6 2002/11/28 13:20:01 rmahidha ship $ */

  TYPE TRANSACTION_TEMP_ID_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.TRANSACTION_TEMP_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE LAST_UPDATE_DATE_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.LAST_UPDATE_DATE%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE LAST_UPDATED_BY_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.LAST_UPDATED_BY%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE CREATION_DATE_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.CREATION_DATE%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE CREATED_BY_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.CREATED_BY%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE LAST_UPDATE_LOGIN_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.LAST_UPDATE_LOGIN%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE REQUEST_ID_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.REQUEST_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE PROGRAM_APPLICATION_ID_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.PROGRAM_APPLICATION_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE PROGRAM_ID_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.PROGRAM_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE PROGRAM_UPDATE_DATE_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.PROGRAM_UPDATE_DATE%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE TRANSACTION_QUANTITY_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.TRANSACTION_QUANTITY%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE PRIMARY_QUANTITY_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.PRIMARY_QUANTITY%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE LOT_NUMBER_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.LOT_NUMBER%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE LOT_EXPIRATION_DATE_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.LOT_EXPIRATION_DATE%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE ERROR_CODE_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.ERROR_CODE%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE SERIAL_TRANSACTION_TEMP_ID_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.SERIAL_TRANSACTION_TEMP_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE GROUP_HEADER_ID_T IS TABLE OF
  MTL_TRANSACTION_LOTS_TEMP.GROUP_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE MTL_TRANSACTION_LOTS_TEMP_REC IS RECORD (
    NUMRECS NUMBER,
    TRANSACTION_TEMP_ID TRANSACTION_TEMP_ID_T,
    LAST_UPDATE_DATE LAST_UPDATE_DATE_T,
    LAST_UPDATED_BY LAST_UPDATED_BY_T,
    CREATION_DATE CREATION_DATE_T,
    CREATED_BY CREATED_BY_T,
    LAST_UPDATE_LOGIN LAST_UPDATE_LOGIN_T,
    REQUEST_ID REQUEST_ID_T,
    PROGRAM_APPLICATION_ID PROGRAM_APPLICATION_ID_T,
    PROGRAM_ID PROGRAM_ID_T,
    PROGRAM_UPDATE_DATE PROGRAM_UPDATE_DATE_T,
    TRANSACTION_QUANTITY TRANSACTION_QUANTITY_T,
    PRIMARY_QUANTITY PRIMARY_QUANTITY_T,
    LOT_NUMBER LOT_NUMBER_T,
    LOT_EXPIRATION_DATE LOT_EXPIRATION_DATE_T,
    ERROR_CODE ERROR_CODE_T,
    SERIAL_TRANSACTION_TEMP_ID SERIAL_TRANSACTION_TEMP_ID_T,
    GROUP_HEADER_ID GROUP_HEADER_ID_T
  );

  procedure insert_rows(p_lots in mtl_transaction_lots_temp_rec);

END WIP_LOT_TEMP_CLEANUP;

 

/