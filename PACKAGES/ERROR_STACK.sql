--------------------------------------------------------
--  DDL for Package ERROR_STACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ERROR_STACK" AUTHID CURRENT_USER AS
/* $Header: PORERSTS.pls 120.1 2005/06/30 04:40:06 srmani noship $*/



-- Record to hold the error stack entries
TYPE ErrorStackEltType IS RECORD (
  message_name     VARCHAR2(2000),
  appl_code        VARCHAR2(10),
  number_of_tokens NUMBER,
  token1           VARCHAR2(30),
  value1           VARCHAR2(300),
  token2           VARCHAR2(30),
  value2           VARCHAR2(300),
  token3           VARCHAR2(30),
  value3           VARCHAR2(300),
  token4           VARCHAR2(30),
  value4           VARCHAR2(300),
  token5           VARCHAR2(30),
  value5           VARCHAR2(300)
);

-- Table of ErrorStackEltType records
TYPE ErrorStackType IS TABLE OF ErrorStackEltType INDEX BY BINARY_INTEGER;

E_SUCCESS                      CONSTANT NUMBER := 0;
E_EMPTY_ERROR_STACK            CONSTANT NUMBER := 1.18;

PROCEDURE PushMessage(p_message_name IN     VARCHAR2,
		      p_appl_code    IN     VARCHAR2,
                      p_token1       IN     VARCHAR2 DEFAULT NULL,
                      p_value1       IN     VARCHAR2 DEFAULT NULL,
                      p_token2       IN     VARCHAR2 DEFAULT NULL,
                      p_value2       IN     VARCHAR2 DEFAULT NULL,
                      p_token3       IN     VARCHAR2 DEFAULT NULL,
                      p_value3       IN     VARCHAR2 DEFAULT NULL,
                      p_token4       IN     VARCHAR2 DEFAULT NULL,
                      p_value4       IN     VARCHAR2 DEFAULT NULL,
                      p_token5       IN     VARCHAR2 DEFAULT NULL,
                      p_value5       IN     VARCHAR2 DEFAULT NULL);

PROCEDURE PopMessage(
		      p_message_name OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
		      p_appl_code    OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_token1       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_value1       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_token2       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_value2       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_token3       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_value3       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_token4       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_value4       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_token5       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                      p_value5       OUT NOCOPY /* file.sql.39 change */     VARCHAR2);

PROCEDURE SQL_ERROR (
			routine IN VARCHAR2,
			location IN VARCHAR2,
			error_code IN VARCHAR2);

PROCEDURE dummy_test;

FUNCTION GETMSGCOUNT  return number;

END ERROR_STACK;

 

/
