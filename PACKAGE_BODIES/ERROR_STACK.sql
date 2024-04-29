--------------------------------------------------------
--  DDL for Package Body ERROR_STACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ERROR_STACK" AS
/* $Header: PORERSTB.pls 120.2 2005/07/01 13:44:39 dkfchan noship $*/

 p_error_stack  ErrorStackType;


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
                      p_value5       IN     VARCHAR2 DEFAULT NULL) IS

  l_index NUMBER;
  l_count NUMBER;

BEGIN
  IF (p_message_name IS NOT NULL) THEN
    l_index := p_error_stack.LAST;
    IF (l_index IS NULL) THEN
      l_index := 1;
    ELSE
      l_index := l_index + 1;
    END IF;
    l_count := 0;
    p_error_stack(l_index).message_name := p_message_name;
    p_error_stack(l_index).appl_code := p_appl_code;
    IF (p_token1 IS NOT NULL) THEN
      p_error_stack(l_index).token1 := p_token1;
      p_error_stack(l_index).value1 := p_value1;
      l_count := l_count + 1;
      IF (p_token2 IS NOT NULL) THEN
        p_error_stack(l_index).token2 := p_token2;
        p_error_stack(l_index).value2 := p_value2;
        l_count := l_count + 1;
        IF (p_token3 IS NOT NULL) THEN
          p_error_stack(l_index).token3 := p_token3;
          p_error_stack(l_index).value3 := p_value3;
          l_count := l_count + 1;
          IF (p_token4 IS NOT NULL) THEN
            p_error_stack(l_index).token4 := p_token4;
            p_error_stack(l_index).value4 := p_value4;
            l_count := l_count + 1;
            IF (p_token5 IS NOT NULL) THEN
              p_error_stack(l_index).token5 := p_token5;
              p_error_stack(l_index).value5 := p_value5;
              l_count := l_count + 1;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    p_error_stack(l_index).number_of_tokens := l_count;
  END IF;

END PushMessage;


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
                      p_value5       OUT NOCOPY /* file.sql.39 change */     VARCHAR2) IS

  l_progress   VARCHAR2(10) := '000';
  l_index      NUMBER;
  l_num_tokens NUMBER;
  p_return_code VARCHAR2(10);
BEGIN

  IF (p_error_stack.COUNT <= 0) THEN
    p_return_code := E_EMPTY_ERROR_STACK;
    RETURN;
  END IF;

  l_index := p_error_stack.FIRST;
 IF  (l_index IS NOT NULL) THEN
    l_progress := '001.'||to_char(l_index);
    p_message_name := p_error_stack(l_index).message_name;
    p_appl_code    := p_error_stack(l_index).appl_code;
     p_token1 := p_error_stack(l_index).token1;
     p_value1 := p_error_stack(l_index).value1;
     p_token2 := p_error_stack(l_index).token2;
     p_value2 := p_error_stack(l_index).value2;
     p_token3 := p_error_stack(l_index).token3;
     p_value3 := p_error_stack(l_index).value3;
     p_token4 := p_error_stack(l_index).token4;
     p_value4 := p_error_stack(l_index).value4;
     p_token5 := p_error_stack(l_index).token5;
     p_value5 := p_error_stack(l_index).value5;
     p_error_stack.DELETE(l_index);
 END IF;
  p_return_code := E_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
END PopMessage;

PROCEDURE SQL_ERROR (
			routine IN VARCHAR2,
			location IN VARCHAR2,
			error_code IN VARCHAR2) is

BEGIN

 PushMessage('PO_ALL_SQL_ERROR','PO','ROUTINE',routine,'ERR_NUMBER',location,'SQL_ERR',SQLERRM(error_code));

END;

PROCEDURE dummy_test is
begin
  NULL;
end;

function GETMSGCOUNT  return number is
begin
 return p_error_stack.COUNT;
end GETMSGCOUNT;

END ERROR_STACK;

/
