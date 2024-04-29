--------------------------------------------------------
--  DDL for Package Body FUN_RULE_DFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_DFF_PKG" AS
/*$Header: FUNXTMRULDFFTBB.pls 120.1 2006/02/22 10:51:43 ammishra noship $ */

g_is_use_instance   BOOLEAN := FALSE;

PROCEDURE Process_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_RULE_OBJECT_ID		            IN     NUMBER
) IS
   l_num              NUMBER := 0;
   source_cursor      INTEGER;
   ignore             INTEGER;

BEGIN

  /*Determine, if the Rule Object Id passed is a Rule Object Instance or Not.
    If its a rule object instance, then the Rule Obejct Id will be populated in
    the DFF table, else the Rule Object id will be a NULL value.
   */

   g_is_use_instance := FUN_RULE_UTILITY_PKG.IS_USE_INSTANCE(X_RULE_OBJECT_ID);

-- Prepare a cursor to select from the source table:

  source_cursor := dbms_sql.open_cursor;
  DBMS_SQL.PARSE(source_cursor,
                 'SELECT COUNT(1) FROM ' || X_TABLE_NAME || ' WHERE RULE_DETAIL_ID = :X_RULE_DETAIL_ID' ,
                  DBMS_SQL.native);
  DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_DETAIL_ID', X_RULE_DETAIL_ID);

  if(g_is_use_instance) then
    DBMS_SQL.PARSE(source_cursor,
                 'SELECT COUNT(1) FROM ' || X_TABLE_NAME || ' WHERE RULE_DETAIL_ID = :X_RULE_DETAIL_ID AND RULE_OBJECT_ID = :X_RULE_OBJECT_ID' ,
                  DBMS_SQL.native);
    DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_DETAIL_ID', X_RULE_DETAIL_ID);
    DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_OBJECT_ID', X_RULE_OBJECT_ID);
  end if;


  DBMS_SQL.DEFINE_COLUMN(source_cursor, 1, l_num);
  ignore := DBMS_SQL.EXECUTE(source_cursor);

  IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN
    -- get column values of the row
    DBMS_SQL.COLUMN_VALUE(source_cursor, 1, l_num);
  END IF;

  IF (l_num = 0) THEN
	FUN_RULE_DFF_PKG.Insert_Row (
                X_TABLE_NAME,
		X_RULE_DETAIL_ID,
		X_ATTRIBUTE_CATEGORY,
		X_ATTRIBUTE1,
		X_ATTRIBUTE2,
		X_ATTRIBUTE3,
		X_ATTRIBUTE4,
		X_ATTRIBUTE5,
		X_ATTRIBUTE6,
		X_ATTRIBUTE7,
		X_ATTRIBUTE8,
		X_ATTRIBUTE9,
		X_ATTRIBUTE10,
		X_ATTRIBUTE11,
		X_ATTRIBUTE12,
		X_ATTRIBUTE13,
		X_ATTRIBUTE14,
		X_ATTRIBUTE15,
		X_RULE_OBJECT_ID);
   ELSE
	   FUN_RULE_DFF_PKG.Update_Row (
                   X_TABLE_NAME,
	           X_RULE_DETAIL_ID,
 	           X_ATTRIBUTE_CATEGORY,
	           X_ATTRIBUTE1,
	           X_ATTRIBUTE2,
	           X_ATTRIBUTE3,
	           X_ATTRIBUTE4,
	           X_ATTRIBUTE5,
	           X_ATTRIBUTE6,
	           X_ATTRIBUTE7,
	           X_ATTRIBUTE8,
	           X_ATTRIBUTE9,
	           X_ATTRIBUTE10,
	           X_ATTRIBUTE11,
	           X_ATTRIBUTE12,
	           X_ATTRIBUTE13,
	           X_ATTRIBUTE14,
                   X_ATTRIBUTE15,
		   X_RULE_OBJECT_ID);

  END IF;
  COMMIT;
  DBMS_SQL.CLOSE_CURSOR(source_cursor);

END;

PROCEDURE Insert_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_RULE_OBJECT_ID		            IN     NUMBER
) IS

   destination_cursor INTEGER;
   ignore             INTEGER;


BEGIN

/* Rule Object Instance Enhancement for MULTIVALUE:
 * Construct the dynamic SQL to use RULE_OBJECT_ID depending on if the Rule Object
 * uses Instances or not.
 */
-- Prepare a cursor to insert into the destination table:
     destination_cursor := DBMS_SQL.OPEN_CURSOR;
   if(g_is_use_instance) then
     DBMS_SQL.PARSE(destination_cursor,
                     'INSERT INTO ' || X_TABLE_NAME ||' ( '||
                     ' RULE_DETAIL_ID, '||
               	     ' ATTRIBUTE_CATEGORY, '||
		     ' ATTRIBUTE1, '||
    	             ' ATTRIBUTE2, '||
	             ' ATTRIBUTE3, '||
	             ' ATTRIBUTE4, '||
	             ' ATTRIBUTE5, '||
	             ' ATTRIBUTE6, '||
	             ' ATTRIBUTE7, '||
	             ' ATTRIBUTE8, '||
	             ' ATTRIBUTE9, '||
       	             ' ATTRIBUTE10, '||
 	             ' ATTRIBUTE11, '||
	             ' ATTRIBUTE12, '||
	             ' ATTRIBUTE13, '||
	             ' ATTRIBUTE14, '||
	             ' ATTRIBUTE15, '||
                     ' CREATED_BY, '||
                     ' CREATION_DATE, '||
                     ' LAST_UPDATE_LOGIN, '||
                     ' LAST_UPDATE_DATE, '||
                     ' LAST_UPDATED_BY, '||
                     ' RULE_OBJECT_ID '||
                     ' ) '||
                     ' VALUES( '||
		     '		:X_RULE_DETAIL_ID , '||
                     '		:X_ATTRIBUTE_CATEGORY , '||
                     '		:X_ATTRIBUTE1, '||
                     '		:X_ATTRIBUTE2, '||
                     '		:X_ATTRIBUTE3, '||
                     '		:X_ATTRIBUTE4, '||
                     '		:X_ATTRIBUTE5, '||
                     '		:X_ATTRIBUTE6, '||
                     '		:X_ATTRIBUTE7, '||
                     '		:X_ATTRIBUTE8, '||
                     '		:X_ATTRIBUTE9, '||
                     '		:X_ATTRIBUTE10, '||
                     '		:X_ATTRIBUTE11, '||
                     '		:X_ATTRIBUTE12, '||
                     '		:X_ATTRIBUTE13, '||
                     '		:X_ATTRIBUTE14, '||
                     '		:X_ATTRIBUTE15, '||
		     '		FUN_RULE_UTILITY_PKG.CREATED_BY, '||
                     '		FUN_RULE_UTILITY_PKG.CREATION_DATE, '||
                     '		FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN, '||
                     '		FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE, '||
                     '		FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY, '||
                     '		:X_RULE_OBJECT_ID )',
		     DBMS_SQL.native);
     else
     DBMS_SQL.PARSE(destination_cursor,
                     'INSERT INTO ' || X_TABLE_NAME ||' ( '||
                     ' RULE_DETAIL_ID, '||
               	     ' ATTRIBUTE_CATEGORY, '||
		     ' ATTRIBUTE1, '||
    	             ' ATTRIBUTE2, '||
	             ' ATTRIBUTE3, '||
	             ' ATTRIBUTE4, '||
	             ' ATTRIBUTE5, '||
	             ' ATTRIBUTE6, '||
	             ' ATTRIBUTE7, '||
	             ' ATTRIBUTE8, '||
	             ' ATTRIBUTE9, '||
       	             ' ATTRIBUTE10, '||
 	             ' ATTRIBUTE11, '||
	             ' ATTRIBUTE12, '||
	             ' ATTRIBUTE13, '||
	             ' ATTRIBUTE14, '||
	             ' ATTRIBUTE15, '||
                     ' CREATED_BY, '||
                     ' CREATION_DATE, '||
                     ' LAST_UPDATE_LOGIN, '||
                     ' LAST_UPDATE_DATE, '||
                     ' LAST_UPDATED_BY '||
                     ' ) '||
                     ' VALUES( '||
		     '		:X_RULE_DETAIL_ID , '||
                     '		:X_ATTRIBUTE_CATEGORY , '||
                     '		:X_ATTRIBUTE1, '||
                     '		:X_ATTRIBUTE2, '||
                     '		:X_ATTRIBUTE3, '||
                     '		:X_ATTRIBUTE4, '||
                     '		:X_ATTRIBUTE5, '||
                     '		:X_ATTRIBUTE6, '||
                     '		:X_ATTRIBUTE7, '||
                     '		:X_ATTRIBUTE8, '||
                     '		:X_ATTRIBUTE9, '||
                     '		:X_ATTRIBUTE10, '||
                     '		:X_ATTRIBUTE11, '||
                     '		:X_ATTRIBUTE12, '||
                     '		:X_ATTRIBUTE13, '||
                     '		:X_ATTRIBUTE14, '||
                     '		:X_ATTRIBUTE15, '||
		     '		FUN_RULE_UTILITY_PKG.CREATED_BY, '||
                     '		FUN_RULE_UTILITY_PKG.CREATION_DATE, '||
                     '		FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN, '||
                     '		FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE, '||
                     '		FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY )',
		     DBMS_SQL.native);
     end if;

     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_RULE_DETAIL_ID', X_RULE_DETAIL_ID);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE_CATEGORY', X_ATTRIBUTE_CATEGORY);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE1', X_ATTRIBUTE1);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE2', X_ATTRIBUTE2);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE3', X_ATTRIBUTE3);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE4', X_ATTRIBUTE4);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE5', X_ATTRIBUTE5);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE6', X_ATTRIBUTE6);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE7', X_ATTRIBUTE7);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE8', X_ATTRIBUTE8);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE9', X_ATTRIBUTE9);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE10', X_ATTRIBUTE10);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE11', X_ATTRIBUTE11);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE12', X_ATTRIBUTE12);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE13', X_ATTRIBUTE13);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE14', X_ATTRIBUTE14);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE15', X_ATTRIBUTE15);

     if(g_is_use_instance) then
       DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_RULE_OBJECT_ID', X_RULE_OBJECT_ID);
     end if;

     ignore := DBMS_SQL.EXECUTE(destination_cursor);
     DBMS_SQL.CLOSE_CURSOR(destination_cursor);


EXCEPTION
     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(destination_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(destination_cursor);
       END IF;
       RAISE;

END Insert_Row;

PROCEDURE Update_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_RULE_OBJECT_ID		            IN     NUMBER
) IS

   destination_cursor INTEGER;
   ignore             INTEGER;

BEGIN

/* Rule Object Instance Enhancement for MULTIVALUE:
 * Construct the dynamic SQL to use RULE_OBJECT_ID depending on if the Rule Object
 * uses Instances or not.
 */

-- Prepare a cursor to insert into the destination table:
     destination_cursor := DBMS_SQL.OPEN_CURSOR;
   if(g_is_use_instance) then
     DBMS_SQL.PARSE(destination_cursor,
                     'UPDATE ' || X_TABLE_NAME ||' SET '||
                     '    ATTRIBUTE_CATEGORY = :X_ATTRIBUTE_CATEGORY, '||
                     '    ATTRIBUTE1 = :X_ATTRIBUTE1, '||
                     '    ATTRIBUTE2 = :X_ATTRIBUTE2, '||
                     '    ATTRIBUTE3 = :X_ATTRIBUTE3, '||
                     '    ATTRIBUTE4 = :X_ATTRIBUTE4, '||
                     '    ATTRIBUTE5 = :X_ATTRIBUTE5, '||
                     '    ATTRIBUTE6 = :X_ATTRIBUTE6, '||
                     '    ATTRIBUTE7 = :X_ATTRIBUTE7, '||
                     '    ATTRIBUTE8 = :X_ATTRIBUTE8, '||
                     '    ATTRIBUTE9 = :X_ATTRIBUTE9, '||
                     '    ATTRIBUTE10 = :X_ATTRIBUTE10, '||
                     '    ATTRIBUTE11 = :X_ATTRIBUTE11, '||
                     '    ATTRIBUTE12 = :X_ATTRIBUTE12, '||
                     '    ATTRIBUTE13 = :X_ATTRIBUTE13, '||
                     '    ATTRIBUTE14 = :X_ATTRIBUTE14, '||
                     '    ATTRIBUTE15 = :X_ATTRIBUTE15, '||
                     '    CREATED_BY = FUN_RULE_UTILITY_PKG.CREATED_BY, '||
                     '    CREATION_DATE = FUN_RULE_UTILITY_PKG.CREATION_DATE, '||
                     '    LAST_UPDATE_LOGIN = FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN, '||
                     '    LAST_UPDATE_DATE = FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE, '||
                     '    LAST_UPDATED_BY = FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY '||
                     ' WHERE RULE_DETAIL_ID = :X_RULE_DETAIL_ID AND RULE_OBJECT_ID = :X_RULE_OBJECT_ID',
		    DBMS_SQL.native);
     else
     DBMS_SQL.PARSE(destination_cursor,
                     'UPDATE ' || X_TABLE_NAME ||' SET '||
                     '    ATTRIBUTE_CATEGORY = :X_ATTRIBUTE_CATEGORY, '||
                     '    ATTRIBUTE1 = :X_ATTRIBUTE1, '||
                     '    ATTRIBUTE2 = :X_ATTRIBUTE2, '||
                     '    ATTRIBUTE3 = :X_ATTRIBUTE3, '||
                     '    ATTRIBUTE4 = :X_ATTRIBUTE4, '||
                     '    ATTRIBUTE5 = :X_ATTRIBUTE5, '||
                     '    ATTRIBUTE6 = :X_ATTRIBUTE6, '||
                     '    ATTRIBUTE7 = :X_ATTRIBUTE7, '||
                     '    ATTRIBUTE8 = :X_ATTRIBUTE8, '||
                     '    ATTRIBUTE9 = :X_ATTRIBUTE9, '||
                     '    ATTRIBUTE10 = :X_ATTRIBUTE10, '||
                     '    ATTRIBUTE11 = :X_ATTRIBUTE11, '||
                     '    ATTRIBUTE12 = :X_ATTRIBUTE12, '||
                     '    ATTRIBUTE13 = :X_ATTRIBUTE13, '||
                     '    ATTRIBUTE14 = :X_ATTRIBUTE14, '||
                     '    ATTRIBUTE15 = :X_ATTRIBUTE15, '||
                     '    CREATED_BY = FUN_RULE_UTILITY_PKG.CREATED_BY, '||
                     '    CREATION_DATE = FUN_RULE_UTILITY_PKG.CREATION_DATE, '||
                     '    LAST_UPDATE_LOGIN = FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN, '||
                     '    LAST_UPDATE_DATE = FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE, '||
                     '    LAST_UPDATED_BY = FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY '||
                     ' WHERE RULE_DETAIL_ID = :X_RULE_DETAIL_ID',
		    DBMS_SQL.native);
     end if;


     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE_CATEGORY', X_ATTRIBUTE_CATEGORY);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE1', X_ATTRIBUTE1);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE2', X_ATTRIBUTE2);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE3', X_ATTRIBUTE3);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE4', X_ATTRIBUTE4);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE5', X_ATTRIBUTE5);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE6', X_ATTRIBUTE6);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE7', X_ATTRIBUTE7);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE8', X_ATTRIBUTE8);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE9', X_ATTRIBUTE9);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE10', X_ATTRIBUTE10);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE11', X_ATTRIBUTE11);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE12', X_ATTRIBUTE12);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE13', X_ATTRIBUTE13);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE14', X_ATTRIBUTE14);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_ATTRIBUTE15', X_ATTRIBUTE15);
     DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_RULE_DETAIL_ID', X_RULE_DETAIL_ID);

     if(g_is_use_instance) then
       DBMS_SQL.BIND_VARIABLE(destination_cursor, 'X_RULE_OBJECT_ID', X_RULE_OBJECT_ID);
     end if;


     ignore := DBMS_SQL.EXECUTE(destination_cursor);
     DBMS_SQL.CLOSE_CURSOR(destination_cursor);

   EXCEPTION
     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(destination_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(destination_cursor);
       END IF;
       RAISE;

END Update_Row;


/*
PROCEDURE Lock_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_RULE_OBJECT_ID		            IN     NUMBER
) IS

    CURSOR C IS
        SELECT * FROM FUN_RULE_DFF
        WHERE  RULE_DETAIL_ID = X_RULE_DETAIL_ID
        FOR UPDATE NOWAIT;
    Recinfo C%ROWTYPE;

BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    IF ( C%NOTFOUND ) THEN
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
       ( ( RULE_DETAIL_ID = X_RULE_DETAIL_ID )
        OR ( ( RULE_DETAIL_ID IS NULL )
            AND (  X_RULE_DETAIL_ID IS NULL ) ) )
    AND ( ( ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY )
        OR ( ( ATTRIBUTE_CATEGORY IS NULL )
            AND (  X_ATTRIBUTE_CATEGORY IS NULL ) ) )
    AND ( ( ATTRIBUTE1 = X_ATTRIBUTE1 )
        OR ( ( ATTRIBUTE1 IS NULL )
            AND (  X_ATTRIBUTE1 IS NULL ) ) )
    AND ( ( ATTRIBUTE2 = X_ATTRIBUTE2 )
        OR ( ( ATTRIBUTE2 IS NULL )
            AND (  X_ATTRIBUTE2 IS NULL ) ) )
    AND ( ( ATTRIBUTE3 = X_ATTRIBUTE3 )
        OR ( ( ATTRIBUTE3 IS NULL )
            AND (  X_ATTRIBUTE3 IS NULL ) ) )
    AND ( ( ATTRIBUTE4 = X_ATTRIBUTE4 )
        OR ( ( ATTRIBUTE4 IS NULL )
            AND (  X_ATTRIBUTE4 IS NULL ) ) )
    AND ( ( ATTRIBUTE5 = X_ATTRIBUTE5 )
        OR ( ( ATTRIBUTE5 IS NULL )
            AND (  X_ATTRIBUTE5 IS NULL ) ) )
    AND ( ( ATTRIBUTE6 = X_ATTRIBUTE6 )
        OR ( ( ATTRIBUTE6 IS NULL )
            AND (  X_ATTRIBUTE6 IS NULL ) ) )
    AND ( ( ATTRIBUTE7 = X_ATTRIBUTE7 )
        OR ( ( ATTRIBUTE7 IS NULL )
            AND (  X_ATTRIBUTE7 IS NULL ) ) )
    AND ( ( ATTRIBUTE8 = X_ATTRIBUTE8 )
        OR ( ( ATTRIBUTE8 IS NULL )
            AND (  X_ATTRIBUTE8 IS NULL ) ) )
    AND ( ( ATTRIBUTE9 = X_ATTRIBUTE9 )
        OR ( ( ATTRIBUTE9 IS NULL )
            AND (  X_ATTRIBUTE9 IS NULL ) ) )
    AND ( ( ATTRIBUTE10 = X_ATTRIBUTE10 )
        OR ( ( ATTRIBUTE10 IS NULL )
            AND (  X_ATTRIBUTE10 IS NULL ) ) )
    AND ( ( ATTRIBUTE11 = X_ATTRIBUTE11 )
        OR ( ( ATTRIBUTE11 IS NULL )
            AND (  X_ATTRIBUTE11 IS NULL ) ) )
    AND ( ( ATTRIBUTE12 = X_ATTRIBUTE12 )
        OR ( ( ATTRIBUTE12 IS NULL )
            AND (  X_ATTRIBUTE12 IS NULL ) ) )
    AND ( ( ATTRIBUTE13 = X_ATTRIBUTE13 )
        OR ( ( ATTRIBUTE13 IS NULL )
            AND (  X_ATTRIBUTE13 IS NULL ) ) )
    AND ( ( ATTRIBUTE14 = X_ATTRIBUTE14 )
        OR ( ( ATTRIBUTE14 IS NULL )
            AND (  X_ATTRIBUTE14 IS NULL ) ) )
    AND ( ( ATTRIBUTE15 = X_ATTRIBUTE15 )
        OR ( ( ATTRIBUTE15 IS NULL )
            AND (  X_ATTRIBUTE15 IS NULL ) ) )
    AND ( ( CREATED_BY = X_CREATED_BY )
        OR ( ( CREATED_BY IS NULL )
            AND (  X_CREATED_BY IS NULL ) ) )
    AND ( ( CREATION_DATE = X_CREATION_DATE )
        OR ( ( CREATION_DATE IS NULL )
            AND (  X_CREATION_DATE IS NULL ) ) )
    AND ( ( LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN )
        OR ( ( LAST_UPDATE_LOGIN IS NULL )
            AND (  X_LAST_UPDATE_LOGIN IS NULL ) ) )
    AND ( ( LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
        OR ( ( LAST_UPDATE_DATE IS NULL )
            AND (  X_LAST_UPDATE_DATE IS NULL ) ) )
    AND ( ( LAST_UPDATED_BY = X_LAST_UPDATED_BY )
        OR ( ( LAST_UPDATED_BY IS NULL )
            AND (  X_LAST_UPDATED_BY IS NULL ) ) )
    ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;
*/

PROCEDURE Lock_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_RULE_OBJECT_ID		            IN     NUMBER
) IS

     source_cursor                       INTEGER;
     destination_cursor                  INTEGER;
     ignore                              INTEGER;

     RULE_DETAIL_ID	                 NUMBER;
     ATTRIBUTE_CATEGORY	                 VARCHAR2(150);
     ATTRIBUTE1			         VARCHAR2(150);
     ATTRIBUTE2			         VARCHAR2(150);
     ATTRIBUTE3			         VARCHAR2(150);
     ATTRIBUTE4			         VARCHAR2(150);
     ATTRIBUTE5			         VARCHAR2(150);
     ATTRIBUTE6			         VARCHAR2(150);
     ATTRIBUTE7			         VARCHAR2(150);
     ATTRIBUTE8			         VARCHAR2(150);
     ATTRIBUTE9			         VARCHAR2(150);
     ATTRIBUTE10		         VARCHAR2(150);
     ATTRIBUTE11		         VARCHAR2(150);
     ATTRIBUTE12		         VARCHAR2(150);
     ATTRIBUTE13		         VARCHAR2(150);
     ATTRIBUTE14		         VARCHAR2(150);
     ATTRIBUTE15		         VARCHAR2(150);
     CREATED_BY                          NUMBER;
     CREATION_DATE                       DATE;
     LAST_UPDATE_LOGIN                   NUMBER;
     LAST_UPDATE_DATE                    DATE;
     LAST_UPDATED_BY                     NUMBER;
     RULE_OBJECT_ID                      NUMBER;

BEGIN

  -- Prepare a cursor to select from the source table:

     source_cursor := dbms_sql.open_cursor;
     if(g_is_use_instance) then
       DBMS_SQL.PARSE(source_cursor,
           'SELECT * FROM '|| X_TABLE_NAME || ' WHERE  RULE_DETAIL_ID = :X_RULE_DETAIL_ID AND RULE_OBJECT_ID = :X_RULE_OBJECT_ID FOR UPDATE NOWAIT',
            DBMS_SQL.native);
     else
       DBMS_SQL.PARSE(source_cursor,
           'SELECT * FROM '|| X_TABLE_NAME || ' WHERE  RULE_DETAIL_ID = :X_RULE_DETAIL_ID FOR UPDATE NOWAIT',
            DBMS_SQL.native);
     end if;

     if(g_is_use_instance) then
       DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_OBJECT_ID', X_RULE_OBJECT_ID);
     end if;

     DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_DETAIL_ID', X_RULE_DETAIL_ID);

     DBMS_SQL.DEFINE_COLUMN(source_cursor , 1, RULE_DETAIL_ID);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 2, ATTRIBUTE_CATEGORY, 150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 3, ATTRIBUTE1,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 4, ATTRIBUTE2,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 5, ATTRIBUTE3,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 6, ATTRIBUTE4,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 7, ATTRIBUTE5,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 8, ATTRIBUTE6,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 9, ATTRIBUTE7,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 10,ATTRIBUTE8,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 11,ATTRIBUTE9,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 12,ATTRIBUTE10,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 13,ATTRIBUTE11,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 14,ATTRIBUTE12,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 15,ATTRIBUTE13,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 16,ATTRIBUTE14,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 17,ATTRIBUTE15,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 18,CREATED_BY);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 19,CREATION_DATE);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 20,LAST_UPDATE_LOGIN);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 21,LAST_UPDATE_DATE);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 22,LAST_UPDATED_BY);
     if(g_is_use_instance) then
       DBMS_SQL.DEFINE_COLUMN(source_cursor , 23,RULE_OBJECT_ID);
     end if;


     ignore := DBMS_SQL.EXECUTE(source_cursor);

    IF (
       ( ( RULE_DETAIL_ID = X_RULE_DETAIL_ID )
        OR ( ( RULE_DETAIL_ID IS NULL )
            AND (  X_RULE_DETAIL_ID IS NULL ) ) )
    AND ( ( ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY )
        OR ( ( ATTRIBUTE_CATEGORY IS NULL )
            AND (  X_ATTRIBUTE_CATEGORY IS NULL ) ) )
    AND ( ( ATTRIBUTE1 = X_ATTRIBUTE1 )
        OR ( ( ATTRIBUTE1 IS NULL )
            AND (  X_ATTRIBUTE1 IS NULL ) ) )
    AND ( ( ATTRIBUTE2 = X_ATTRIBUTE2 )
        OR ( ( ATTRIBUTE2 IS NULL )
            AND (  X_ATTRIBUTE2 IS NULL ) ) )
    AND ( ( ATTRIBUTE3 = X_ATTRIBUTE3 )
        OR ( ( ATTRIBUTE3 IS NULL )
            AND (  X_ATTRIBUTE3 IS NULL ) ) )
    AND ( ( ATTRIBUTE4 = X_ATTRIBUTE4 )
        OR ( ( ATTRIBUTE4 IS NULL )
            AND (  X_ATTRIBUTE4 IS NULL ) ) )
    AND ( ( ATTRIBUTE5 = X_ATTRIBUTE5 )
        OR ( ( ATTRIBUTE5 IS NULL )
            AND (  X_ATTRIBUTE5 IS NULL ) ) )
    AND ( ( ATTRIBUTE6 = X_ATTRIBUTE6 )
        OR ( ( ATTRIBUTE6 IS NULL )
            AND (  X_ATTRIBUTE6 IS NULL ) ) )
    AND ( ( ATTRIBUTE7 = X_ATTRIBUTE7 )
        OR ( ( ATTRIBUTE7 IS NULL )
            AND (  X_ATTRIBUTE7 IS NULL ) ) )
    AND ( ( ATTRIBUTE8 = X_ATTRIBUTE8 )
        OR ( ( ATTRIBUTE8 IS NULL )
            AND (  X_ATTRIBUTE8 IS NULL ) ) )
    AND ( ( ATTRIBUTE9 = X_ATTRIBUTE9 )
        OR ( ( ATTRIBUTE9 IS NULL )
            AND (  X_ATTRIBUTE9 IS NULL ) ) )
    AND ( ( ATTRIBUTE10 = X_ATTRIBUTE10 )
        OR ( ( ATTRIBUTE10 IS NULL )
            AND (  X_ATTRIBUTE10 IS NULL ) ) )
    AND ( ( ATTRIBUTE11 = X_ATTRIBUTE11 )
        OR ( ( ATTRIBUTE11 IS NULL )
            AND (  X_ATTRIBUTE11 IS NULL ) ) )
    AND ( ( ATTRIBUTE12 = X_ATTRIBUTE12 )
        OR ( ( ATTRIBUTE12 IS NULL )
            AND (  X_ATTRIBUTE12 IS NULL ) ) )
    AND ( ( ATTRIBUTE13 = X_ATTRIBUTE13 )
        OR ( ( ATTRIBUTE13 IS NULL )
            AND (  X_ATTRIBUTE13 IS NULL ) ) )
    AND ( ( ATTRIBUTE14 = X_ATTRIBUTE14 )
        OR ( ( ATTRIBUTE14 IS NULL )
            AND (  X_ATTRIBUTE14 IS NULL ) ) )
    AND ( ( ATTRIBUTE15 = X_ATTRIBUTE15 )
        OR ( ( ATTRIBUTE15 IS NULL )
            AND (  X_ATTRIBUTE15 IS NULL ) ) )
    AND ( ( CREATED_BY = X_CREATED_BY )
        OR ( ( CREATED_BY IS NULL )
            AND (  X_CREATED_BY IS NULL ) ) )
    AND ( ( CREATION_DATE = X_CREATION_DATE )
        OR ( ( CREATION_DATE IS NULL )
            AND (  X_CREATION_DATE IS NULL ) ) )
    AND ( ( LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN )
        OR ( ( LAST_UPDATE_LOGIN IS NULL )
            AND (  X_LAST_UPDATE_LOGIN IS NULL ) ) )
    AND ( ( LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
        OR ( ( LAST_UPDATE_DATE IS NULL )
            AND (  X_LAST_UPDATE_DATE IS NULL ) ) )
    AND ( ( LAST_UPDATED_BY = X_LAST_UPDATED_BY )
        OR ( ( LAST_UPDATED_BY IS NULL )
            AND (  X_LAST_UPDATED_BY IS NULL ) ) )
    ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       RAISE;

END Lock_Row;

PROCEDURE Select_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID			    IN  OUT NOCOPY   NUMBER,
    X_ATTRIBUTE_CATEGORY	            OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE1			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE2			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE3			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE4			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE5			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE6			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE7			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE8			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE9			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE10			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE11			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE12			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE13			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE14			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE15			    OUT NOCOPY     VARCHAR2,
    X_RULE_OBJECT_ID		            OUT NOCOPY     NUMBER
) IS

l_select_stmt          VARCHAR2(2000);
source_cursor      INTEGER;
ignore             INTEGER;


BEGIN

/* Rule Object Instance Enhancement for MULTIVALUE:
 * Construct the dynamic SQL to use RULE_OBJECT_ID depending on if the Rule Object
 * uses Instances or not.
 */

-- Prepare a cursor to select from the source table:
  source_cursor := dbms_sql.open_cursor;

if(g_is_use_instance) then
	l_select_stmt :='SELECT '||
			'  RULE_DETAIL_ID, '||
			'  ATTRIBUTE_CATEGORY, '||
			'  ATTRIBUTE1, '||
			'  ATTRIBUTE2, '||
			'  ATTRIBUTE3, '||
			'  ATTRIBUTE4, '||
			'  ATTRIBUTE5, '||
			'  ATTRIBUTE6, '||
			'  ATTRIBUTE7, '||
			'  ATTRIBUTE8, '||
			'  ATTRIBUTE9, '||
			'  ATTRIBUTE10, '||
			'  ATTRIBUTE11, '||
			'  ATTRIBUTE12, '||
			'  ATTRIBUTE13, '||
			'  ATTRIBUTE14, '||
			'  ATTRIBUTE15 '||
			' FROM '|| X_TABLE_NAME ||
			'  WHERE RULE_DETAIL_ID = :X_RULE_DETAIL_ID AND RULE_OBJECT_ID = :X_RULE_OBJECT_ID ' ||
			'  AND ROWNUM = 1 ';
else
	l_select_stmt :='SELECT '||
			'  RULE_DETAIL_ID, '||
			'  ATTRIBUTE_CATEGORY, '||
			'  ATTRIBUTE1, '||
			'  ATTRIBUTE2, '||
			'  ATTRIBUTE3, '||
			'  ATTRIBUTE4, '||
			'  ATTRIBUTE5, '||
			'  ATTRIBUTE6, '||
			'  ATTRIBUTE7, '||
			'  ATTRIBUTE8, '||
			'  ATTRIBUTE9, '||
			'  ATTRIBUTE10, '||
			'  ATTRIBUTE11, '||
			'  ATTRIBUTE12, '||
			'  ATTRIBUTE13, '||
			'  ATTRIBUTE14, '||
			'  ATTRIBUTE15 '||
			' FROM '|| X_TABLE_NAME ||
			'  WHERE RULE_DETAIL_ID = :X_RULE_DETAIL_ID ' ||
			'  AND ROWNUM = 1 ';
end if;
     DBMS_SQL.PARSE(source_cursor,l_select_stmt , DBMS_SQL.native);

     DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_DETAIL_ID', X_RULE_DETAIL_ID);
     if(g_is_use_instance) then
       DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_OBJECT_ID', X_RULE_OBJECT_ID);
     end if;

     DBMS_SQL.DEFINE_COLUMN(source_cursor , 1, X_RULE_DETAIL_ID);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 2, X_ATTRIBUTE_CATEGORY, 150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 3, X_ATTRIBUTE1,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 4, X_ATTRIBUTE2,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 5, X_ATTRIBUTE3,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 6, X_ATTRIBUTE4,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 7, X_ATTRIBUTE5,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 8, X_ATTRIBUTE6,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 9, X_ATTRIBUTE7,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 10,X_ATTRIBUTE8,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 11,X_ATTRIBUTE9,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 12,X_ATTRIBUTE10,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 13,X_ATTRIBUTE11,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 14,X_ATTRIBUTE12,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 15,X_ATTRIBUTE13,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 16,X_ATTRIBUTE14,150);
     DBMS_SQL.DEFINE_COLUMN(source_cursor , 17,X_ATTRIBUTE15,150);
     if(g_is_use_instance) then
       DBMS_SQL.DEFINE_COLUMN(source_cursor , 18, X_RULE_OBJECT_ID);
     end if;
     ignore := DBMS_SQL.EXECUTE(source_cursor);

     IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN
        -- get column values of the row
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 1, X_RULE_DETAIL_ID);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 2, X_ATTRIBUTE_CATEGORY);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 3, X_ATTRIBUTE1);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 4, X_ATTRIBUTE2);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 5, X_ATTRIBUTE3);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 6, X_ATTRIBUTE4);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 7, X_ATTRIBUTE5);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 8, X_ATTRIBUTE6);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 9, X_ATTRIBUTE7);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 10,X_ATTRIBUTE8);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 11,X_ATTRIBUTE9);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 12,X_ATTRIBUTE10);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 13,X_ATTRIBUTE11);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 14,X_ATTRIBUTE12);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 15,X_ATTRIBUTE13);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 16,X_ATTRIBUTE14);
	     DBMS_SQL.COLUMN_VALUE(source_cursor , 17,X_ATTRIBUTE15);
             if(g_is_use_instance) then
               DBMS_SQL.COLUMN_VALUE(source_cursor , 18, X_RULE_OBJECT_ID);
             end if;
     END IF;

     DBMS_SQL.CLOSE_CURSOR(source_cursor);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;

       FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_NO_RECORD' );
       FND_MESSAGE.SET_TOKEN( 'RECORD', 'FUN_RULE_DFF');
       FND_MESSAGE.SET_TOKEN( 'VALUE', X_RULE_DETAIL_ID);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       RAISE;


END Select_Row;

PROCEDURE Delete_Row (
    X_TABLE_NAME                             IN     VARCHAR2,
    X_RULE_DETAIL_ID	  		     IN     NUMBER,
    X_RULE_OBJECT_ID		             IN     NUMBER
) IS

source_cursor      INTEGER;
ignore             INTEGER;

BEGIN

/* Rule Object Instance Enhancement for MULTIVALUE:
 * Construct the dynamic SQL to use RULE_OBJECT_ID depending on if the Rule Object
 * uses Instances or not.
 */

-- Prepare a cursor to select from the source table:
   source_cursor := DBMS_SQL.OPEN_CURSOR;

   if(g_is_use_instance) then
      DBMS_SQL.PARSE(source_cursor, 'delete from ' || X_TABLE_NAME ||' WHERE RULE_DETAIL_ID = :X_RULE_DETAIL_ID AND RULE_OBJECT_ID = :X_RULE_OBJECT_ID',
                     DBMS_SQL.native);
   else
      DBMS_SQL.PARSE(source_cursor, 'delete from ' || X_TABLE_NAME ||' WHERE RULE_DETAIL_ID = :X_RULE_DETAIL_ID',
                     DBMS_SQL.native);
   end if;

   DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_DETAIL_ID', X_RULE_DETAIL_ID);
   if(g_is_use_instance) then
    DBMS_SQL.BIND_VARIABLE(source_cursor, 'X_RULE_OBJECT_ID', X_RULE_OBJECT_ID);
   end if;
   ignore := DBMS_SQL.EXECUTE(source_cursor);

   DBMS_SQL.CLOSE_CURSOR(source_cursor);
   COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;

       FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_NO_RECORD' );
       FND_MESSAGE.SET_TOKEN( 'RECORD', 'FUN_RULE_DFF');
       FND_MESSAGE.SET_TOKEN( 'VALUE', X_RULE_DETAIL_ID);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       RAISE;


END Delete_Row;

END FUN_RULE_DFF_PKG;

/
