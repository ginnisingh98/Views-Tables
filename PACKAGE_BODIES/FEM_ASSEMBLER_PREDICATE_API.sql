--------------------------------------------------------
--  DDL for Package Body FEM_ASSEMBLER_PREDICATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_ASSEMBLER_PREDICATE_API" AS
--$Header: FEMASPRDB.pls 120.1.12000000.2 2007/10/26 17:41:12 gcheng ship $

PROCEDURE GENERATE_ASSEMBLER_PREDICATE(
   x_predicate_string OUT NOCOPY LONG,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2,
   p_DS_IO_Def_ID IN NUMBER,
   p_Output_Period_ID IN NUMBER,
   p_Request_ID IN NUMBER,
   p_Object_ID IN VARCHAR2,
   p_Ledger_ID IN NUMBER,
   p_by_dimension_column IN VARCHAR2,
   p_by_dimension_id IN NUMBER,
   p_by_dimension_value IN VARCHAR2,
   p_fact_table_name IN VARCHAR2,
   p_table_alias IN VARCHAR2,
   p_Ledger_Flag IN VARCHAR2 := 'N',
   p_api_version IN NUMBER := 1.0,
   p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
   p_commit IN VARCHAR2 := FND_API.G_FALSE,
   p_encoded IN VARCHAR2 := FND_API.G_TRUE) IS

l_predicate_string LONG;
l_sqlStmt LONG;
l_cond_predicate LONG := NULL;
l_ds_predicate LONG := NULL;
l_return_status1 VARCHAR2(100);
l_msg_count1 NUMBER;
l_msg_data1 VARCHAR2(500);
l_return_status2 VARCHAR2(100);
l_msg_count2 NUMBER;
l_msg_data2 VARCHAR2(500);
BEGIN
   IF (p_condition_obj_id IS NOT NULL AND p_condition_obj_id <> 0 ) THEN
      Fem_Conditions_Api.Generate_condition_predicate(
                     p_api_version => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     p_commit => p_commit,
                     p_encoded => p_encoded,
                     p_condition_obj_id => p_condition_obj_id,
                     p_rule_effective_date => p_rule_effective_date,
                     p_input_fact_table_name => p_fact_table_name,
                     p_table_alias => p_table_alias,
                     p_display_predicate => 'N',
                     p_return_predicate_type => 'BOTH',
                     p_logging_turned_on => 'Y',
                     p_by_dimension_column => p_by_dimension_column,
                     p_by_dimension_id => p_by_dimension_id,
                     p_by_dimension_value => p_by_dimension_value,
                     x_return_status => l_return_status1,
                     x_msg_count => l_msg_count1,
                     x_msg_data => l_msg_data1,
                     x_predicate_string => l_predicate_string);

      l_cond_predicate := l_predicate_string;

      IF ((l_return_status1 = FND_API.G_RET_STS_ERROR) OR (l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR)) THEN
         l_predicate_string := '';
      END IF;

      IF ((l_return_status1 = FND_API.G_RET_STS_SUCCESS) AND (substr(rtrim(l_ds_predicate,' '),1,LENGTH(l_ds_predicate)) = '()')) THEN
         l_predicate_string := '';
      END IF;

   ELSE
      l_predicate_string := '';
      l_return_status1 := FND_API.G_RET_STS_SUCCESS;
   END IF;

   Fem_ds_where_clause_generator.FEM_Gen_DS_WClause_PVT(
                                         p_api_version => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         p_encoded => p_encoded,
                                         x_return_status => l_return_status2,
                                         x_msg_count => l_msg_count2,
                                         x_msg_data => l_msg_data2,
                                         p_DS_IO_Def_ID => p_DS_IO_Def_ID,
                                         p_Output_Period_ID => p_Output_Period_ID,
                                         p_table_alias => p_table_alias,
                                         p_table_name => p_fact_table_name,
                                         p_Ledger_ID => p_Ledger_ID,
                                         p_where_clause => l_sqlStmt);

   l_ds_predicate := l_sqlStmt;

   IF ((l_return_status2 = FND_API.G_RET_STS_ERROR) OR (l_return_status2 = FND_API.G_RET_STS_UNEXP_ERROR)) THEN
       l_sqlStmt := '';
   END IF;

   IF ((l_return_status2 = FND_API.G_RET_STS_SUCCESS) AND (substr(rtrim(l_ds_predicate,' '),1,LENGTH(l_ds_predicate)) = '()')) THEN
       l_sqlStmt := '';
   END IF;

   IF (((l_return_status1 = FND_API.G_RET_STS_ERROR) OR (l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR)) AND
      (l_return_status2 = FND_API.G_RET_STS_SUCCESS)) THEN
       x_return_status := l_return_status1;
       x_msg_count := l_msg_count1;
       x_msg_data := l_msg_data1;
   ELSIF (((l_return_status2 = FND_API.G_RET_STS_ERROR) OR (l_return_status2 = FND_API.G_RET_STS_UNEXP_ERROR)) AND
      (l_return_status1 = FND_API.G_RET_STS_SUCCESS)) THEN
       x_return_status := l_return_status2;
       x_msg_count := l_msg_count2;
       x_msg_data := l_msg_data2;
   ELSIF (((l_return_status1 = FND_API.G_RET_STS_ERROR) OR (l_return_status1 = FND_API.G_RET_STS_UNEXP_ERROR)) AND
      ((l_return_status2 = FND_API.G_RET_STS_ERROR) OR (l_return_status2 = FND_API.G_RET_STS_UNEXP_ERROR))) THEN
       x_return_status := l_return_status1 || ' and ' || l_return_status2;
       x_msg_count := 1;
       x_msg_data := l_msg_data1 || ' and ' || l_msg_data2;
   ELSE
       x_return_status := l_return_status1;
       x_msg_count := l_msg_count1 + l_msg_count2;
       x_msg_data := l_msg_data1 || l_msg_data2;
   END IF;

   IF ((l_predicate_string is NOT NULL) AND (l_sqlStmt is NOT NULL) AND (p_Ledger_Flag = 'Y')) THEN
        x_predicate_string := l_predicate_string || ' AND ' || l_sqlStmt || ' AND '
                         --|| '(' || p_table_alias || '.' || 'CREATED_BY_REQUEST_ID' ||
                         --' <> ' || p_Request_ID || ')' || ' AND '
                         || '(' ||
                         p_table_alias || '.' || 'CREATED_BY_OBJECT_ID' || ' NOT IN(' ||
                         p_Object_ID || ')' || ')' || ' AND ' || '(' || p_table_alias ||
                         '.' || 'LEDGER_ID' || ' = ' || p_Ledger_ID || ')';
   END IF;

   IF ((l_predicate_string is NOT NULL) AND (l_sqlStmt is NOT NULL) AND (p_Ledger_Flag <> 'Y')) THEN
        x_predicate_string := l_predicate_string || ' AND ' || l_sqlStmt || ' AND ' || '(' ||
                         p_table_alias || '.' || 'LEDGER_ID' || ' = ' || p_Ledger_ID || ')';
   END IF;

   IF ((l_predicate_string is NOT NULL) AND (l_sqlStmt is NULL) AND (p_Ledger_Flag = 'Y')) THEN
        x_predicate_string := l_predicate_string || ' AND '
                         -- || '(' || p_table_alias || '.' || 'CREATED_BY_REQUEST_ID' || ' <> ' ||
                         --p_Request_ID || ')' || ' AND '
                         || '(' || p_table_alias || '.' || 'CREATED_BY_OBJECT_ID' || ' NOT IN(' ||
                         p_Object_ID || ')' || ')' || ' AND ' || '(' || p_table_alias ||
                         '.' || 'LEDGER_ID' || ' = ' || p_Ledger_ID || ')';
   END IF;

   IF ((l_predicate_string is NOT NULL) AND (l_sqlStmt is NULL) AND (p_Ledger_Flag <> 'Y')) THEN
        x_predicate_string := l_predicate_string || ' AND ' || '(' || p_table_alias || '.'
                         || 'LEDGER_ID' || ' = ' || p_Ledger_ID || ')';
   END IF;

   IF ((l_predicate_string is NULL) AND (l_sqlStmt is NOT NULL) AND (p_Ledger_Flag = 'Y')) THEN
        x_predicate_string := l_sqlStmt || ' AND '
                         --|| '(' || p_table_alias || '.' || 'CREATED_BY_REQUEST_ID' || ' <> ' ||
                         --p_Request_ID || ')' || ' AND '
                         || '(' ||
                         p_table_alias || '.' || 'CREATED_BY_OBJECT_ID' || ' NOT IN(' ||
                         p_Object_ID || ')' || ')' || ' AND ' || '(' || p_table_alias ||
                         '.' || 'LEDGER_ID' || ' = ' || p_Ledger_ID || ')';
   END IF;

   IF ((l_predicate_string is NULL) AND (l_sqlStmt is NOT NULL) AND (p_Ledger_Flag <> 'Y')) THEN
        x_predicate_string := l_sqlStmt || ' AND ' || '(' || p_table_alias || '.' ||
                         'LEDGER_ID' || ' = ' || p_Ledger_ID || ')';
   END IF;

   IF ((l_predicate_string is NULL) AND (l_sqlStmt is NULL) AND (p_Ledger_Flag = 'Y')) THEN
        x_predicate_string := --'(' || p_table_alias || '.' || 'CREATED_BY_REQUEST_ID'
                         --|| ' <> ' || p_Request_ID || ')' || ' AND ' ||
                         '(' || p_table_alias || '.' || 'CREATED_BY_OBJECT_ID' || ' NOT IN(' ||
                         p_Object_ID || ')' || ')' || ' AND ' || '(' || p_table_alias ||
                         '.' || 'LEDGER_ID' || ' = ' || p_Ledger_ID || ')';
   END IF;

   IF ((l_predicate_string is NULL) AND (l_sqlStmt is NULL) AND (p_Ledger_Flag <> 'Y')) THEN
        x_predicate_string := '(' || p_table_alias || '.' || 'LEDGER_ID' || ' = ' || p_Ledger_ID || ')';
   END IF;

END GENERATE_ASSEMBLER_PREDICATE;

END FEM_ASSEMBLER_PREDICATE_API;

/
