--------------------------------------------------------
--  DDL for Package Body JTF_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_OBJECTS_PVT" AS
/* $Header: jtfvobmb.pls 115.4 2004/04/20 11:49:10 abraina ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_OBJECTS_PVT';

--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : GET_OBJECT_INSTANCE_NAME
--  Description : Will determine the Name of the Object Instance based
--                on the objects definition in JTF_OBJECTS. This function
--                is used in the JTF_OBJECT_MAPPINGS_V.
--  Parameters  :
--      name                 direction  type        required?
--      ----                 ---------  ----        ---------
--      p_ObjectCode         IN         VARCHAR2   required
--      p_ObjectID           IN         VARCHAR2   required
--      RETURN                          VARCHAR2
--
--  Notes :
--
-- End of comments
--------------------------------------------------------------------------
FUNCTION GET_OBJECT_INSTANCE_NAME
( p_ObjectCode IN VARCHAR2
, p_ObjectID   IN VARCHAR2
)RETURN VARCHAR2
IS
  CURSOR c_JTFObjectDefinition
  /*****************************************************************************
  ** Get the Object definition parameters required to build the query
  *****************************************************************************/
  (b_ObjectCode  IN  VARCHAR2
  )IS SELECT select_id
      ,      select_name
      ,      select_details
      ,      from_table
      ,      where_clause
      FROM   jtf_objects_b
      WHERE  object_code = b_ObjectCode;

  CURSOR c_SelectIDType
  (b_table_name   IN VARCHAR2
  ,b_column_name  IN VARCHAR2
  ,p_oracle_schema IN VARCHAR2 )IS SELECT DISTINCT data_type
      FROM   all_tab_columns
      WHERE  table_name  = b_table_name
      AND    column_name = b_column_name
      AND    owner = p_oracle_schema ;

  l_SelectID           VARCHAR2(200);
  l_SelectName         VARCHAR2(2000);
  l_SelectDetails      VARCHAR2(2000);
  l_FromTable          VARCHAR2(200);
  l_WhereClause        VARCHAR2(2000);
  l_Query              VARCHAR2(6400);
  l_SelectIDType       VARCHAR2(106);
  l_ObjectInstanceName VARCHAR2(80);

  l_return_status BOOLEAN;
  l_status        VARCHAR2(1);
  l_oracle_schema VARCHAR2(30);
  l_industry      VARCHAR2(1);

BEGIN
  /*****************************************************************************
  ** Get the Object Definition
  *****************************************************************************/
  FOR l_JTFObject IN c_JTFObjectDefinition(p_ObjectCode)
  LOOP
    l_SelectID      := l_JTFObject.select_id;
    l_SelectName    := l_JTFObject.select_name;
    l_SelectDetails := l_JTFObject.select_details;
    l_FromTable     := l_JTFObject.from_table;
    l_WhereClause   := l_JTFObject.where_clause;
  END LOOP;

  l_return_status := FND_INSTALLATION.GET_APP_INFO(
            application_short_name => 'JTF',
            status                 => l_status,
            industry               => l_industry,
            oracle_schema          => l_oracle_schema);

  if (NOT l_return_status) or (l_oracle_schema IS NULL)
  then
        -- defaulted to the JTF
        l_oracle_schema := 'JTF';
  end if;

  /*****************************************************************************
  ** Get the datatype of the select ID
  *****************************************************************************/
  FOR r_SelectIDType IN c_SelectIDType(UPPER(l_FromTable)
                                      ,UPPER(l_SelectID)
                                      ,l_oracle_schema)
  LOOP
    l_SelectIDType := r_SelectIDType.data_type;
  END LOOP;

  /*****************************************************************************
  ** Build the query
  *****************************************************************************/
  IF (l_SelectIDType = 'NUMBER')
  THEN
    l_Query := 'SELECT '||l_SelectName ||
               ' FROM '||l_FromTable;

    IF (l_WhereClause IS NOT NULL)
    THEN
      l_Query := l_Query ||' WHERE '||l_WhereClause ||
                           ' AND '||l_SelectID||' = :1';
    ELSE
      l_Query := l_Query||' WHERE ' ||l_SelectID||' = :1';
    END IF;

  ELSE
    l_Query := 'SELECT '||l_SelectName ||
               ' FROM '||l_FromTable;

    IF (l_WhereClause IS NOT NULL)
    THEN
      l_Query := l_Query ||' WHERE '||l_WhereClause ||
                           ' AND '||l_SelectID||' = :1';
    ELSE
      l_Query := l_Query ||' WHERE ' ||l_SelectID||' = :1';
    END IF;

  END IF;

  EXECUTE IMMEDIATE l_query
  INTO l_ObjectInstanceName
  USING p_ObjectID;

  RETURN l_ObjectInstanceName;

EXCEPTION
  WHEN OTHERS
    THEN RETURN l_query||SQLERRM;

END GET_OBJECT_INSTANCE_NAME;

END JTF_OBJECTS_PVT;

/
