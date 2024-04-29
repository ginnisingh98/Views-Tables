--------------------------------------------------------
--  DDL for Package Body CAC_SR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SR_UTIL_PVT" as
/* $Header: cacsrutilvb.pls 120.2 2005/08/17 22:13:12 akaran noship $ */

function GET_OBJECT_NAME (
  P_OBJECT_TYPE in VARCHAR2,
  P_OBJECT_ID in NUMBER)
  RETURN VARCHAR2 is
      CURSOR c_references (p_object_type_code VARCHAR2)
      IS
     SELECT select_id, select_name, from_table, where_clause
       FROM jtf_objects_b
      WHERE object_code = p_object_type_code;
      --- Removed the reference from JTF_OBJECTS_VL to JT_OBJECTS_B.


      l_id_column      jtf_objects_b.select_id%TYPE;
      l_name_column    jtf_objects_b.select_name%TYPE;
      l_from_clause    jtf_objects_b.from_table%TYPE;
      l_where_clause   jtf_objects_b.where_clause%TYPE;
      l_object_name    VARCHAR2(2000);
      sql_stmt         VARCHAR2(2000);

   BEGIN
    OPEN c_references(P_OBJECT_TYPE);
    FETCH c_references
    INTO l_id_column,
         l_name_column,
         l_from_clause,
         l_where_clause;

    IF c_references%NOTFOUND
    THEN
     CLOSE c_references;
     RETURN NULL;
    END IF;
    CLOSE c_references;

    IF (l_where_clause IS NULL)
    THEN
       l_where_clause := '  ';
    ELSE
       l_where_clause := l_where_clause || ' AND ';
    END IF;

    sql_stmt := ' SELECT ' ||
          l_name_column ||
          ' from ' ||
          l_from_clause ||
          '  where ' ||
          l_where_clause ||
          l_id_column ||
          ' = :object_id and rownum = 1';
    EXECUTE IMMEDIATE sql_stmt
       INTO l_object_name
       USING p_object_id;

    RETURN l_object_name;

   EXCEPTION
     WHEN NO_DATA_FOUND
      THEN
          RETURN NULL;
     WHEN OTHERS
      THEN
          RETURN NULL;

END GET_OBJECT_NAME;

end CAC_SR_UTIL_PVT;

/
