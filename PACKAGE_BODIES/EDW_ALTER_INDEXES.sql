--------------------------------------------------------
--  DDL for Package Body EDW_ALTER_INDEXES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ALTER_INDEXES" AS
/* $Header: EDWINDXB.pls 115.6 2004/02/13 05:11:06 smulye noship $ */

g_file  utl_file.file_type;
OUT number := 0;
LOG number := 1;
BOTH number :=2;

/*-------------------------------------------------------------------

  Write to the log or out files.

--------------------------------------------------------------------*/

Procedure writelog( l_text varchar2) IS

BEGIN
	fnd_file.put_line(fnd_file.log, l_text);
END;

/*-------------------------------------------------------------------

  Given a table name, get the schema.

--------------------------------------------------------------------*/

FUNCTION getTableSchema(tableName in varchar2) RETURN varchar2  IS


Type CurTyp is Ref Cursor;stmt varchar2(100) := 'select table_owner from user_synonyms where table_name = :s1';
schema varchar2(100):= null;
cv 		CurTyp;
BEGIN
	open cv for stmt using tableName;
	fetch cv into schema;
    	close cv;
	return schema;
END;


/*-------------------------------------------------------------------

  Given a table name and owner, return all the indexes.

--------------------------------------------------------------------*/


FUNCTION getIndexes(tableName in varchar2, schema in varchar2)
	RETURN tab_indexes IS

stmt varchar2(400) := ' SELECT column_name, index_name FROM all_ind_columns '||
              	' where table_name = :s1 AND table_owner= :s2';

indexList tab_indexes;
ind indexInfo;
Type CurTyp is Ref Cursor;
cv 		CurTyp;
counter number :=0;

BEGIN

	OPEN cv FOR stmt USING tableName, schema;
	LOOP
     		FETCH cv into ind.columnName, ind.indexName;
		EXIT WHEN cv%NOTFOUND;

                indexList(counter).columnName := ind.columnName;
		indexList(counter).indexName  := ind.indexName;
		counter := counter + 1;
	END LOOP;
	return indexList;
END;


/*-------------------------------------------------------------------

  Given a index_name , table_owner, get the status of the index.
	Statuses are

--------------------------------------------------------------------*/
FUNCTION getIndexStatus(p_index in varchar2, p_table in varchar2, p_owner in varchar2) return VARCHAR2 IS
l_status varchar2(20);

l_stmt varchar2(200) :=
	'SELECT status
	FROM all_indexes
	WHERE table_name = :s1 and
	table_owner = :s2 and index_name = :s3';

Type CurTyp is Ref Cursor;
cv CurTyp;
BEGIN
	utl_file.put_line(g_file, 'Inside getIndexStatus for :'||p_index);

	OPEN cv FOR l_stmt USING p_table, p_owner, p_index;
     	FETCH cv into l_status;
	CLOSE cv;
	utl_file.put_line(g_file, 'Completed getIndexStatus for :'||p_index||' : '||l_status);
	RETURN l_status;

END;

FUNCTION getFactFKS(p_fact_name in varchar2) RETURN tab_fact_fks IS
tabfks tab_fact_fks;
fk c_fact_fks%ROWTYPE;
counter number :=0;
BEGIN
	OPEN c_fact_fks(p_fact_name);
	LOOP
		FETCH c_fact_fks INTO fk;
		EXIT WHEN c_fact_fks%NOTFOUND;
		tabfks(counter).name := fk.name;
		tabfks(counter).skip := fk.skip;
		counter := counter + 1;
	END LOOP;
	CLOSE c_fact_fks;
	return tabfks;
END;


FUNCTION getIndexForFK(p_fk_name in varchar2) return varchar2 IS

counter number;
indexName varchar2(30) := null;

BEGIN

	utl_file.put_line(g_file, 'Inside getIndexForFK for :'||p_fk_name);

	counter := g_indexes.first;

	LOOP
		EXIT WHEN (NOT g_indexes.exists(counter));

		IF (g_indexes(counter).columnName = p_fk_name) THEN
			indexName := g_indexes(counter).indexName;
			--g_indexes.delete(counter);
			EXIT;
		END IF;
		counter := counter + 1;
	END LOOP;
	utl_file.put_line(g_file, 'Completed getIndexForFK for :'||p_fk_name || ' returning '||indexName);

	return indexName;

END;
/*-------------------------------------------------------------------

	Disable/enable indexes based on settings changed using
	Apps Integrator.
--------------------------------------------------------------------*/

Procedure alterIndexesforFact(p_fact_name in varchar2) IS

fkCounter number := 0;
itemSetCounter number :=0;
schema varchar2(30);

l_fact_fks tab_fact_fks;
l_stmt varchar2(100);
l_index varchar2(100);
BEGIN
	schema := getTableSchema(p_fact_name);
	l_fact_fks := getFactFKs(p_fact_name);
	g_indexes := getIndexes(p_fact_name, schema);
	fkCounter := l_fact_fks.first;

	writelog( 'Inside alterIndexesForFact for :'||p_fact_name);
	writelog( 'Altering indexes for '||p_fact_name);



	LOOP

	   EXIT WHEN (NOT l_fact_fks.exists(fkCounter));

	   l_index := getIndexForFK(l_fact_fks(fkCounter).name);


	   IF (l_index is not null) THEN
	   IF(l_fact_fks(fkCounter).skip = 'Y') THEN
		/* index should be unusable */

		IF (getIndexStatus(l_index, p_fact_name, schema) <> 'UNUSABLE') THEN
			writelog( ' Status for '||l_index||
				' is not unusable... Altering index to make it unusable');
			l_stmt := 'ALTER INDEX '||schema||'.'||l_index||' UNUSABLE';
			writelog( l_stmt);
			execute immediate l_stmt;
		END IF;
	   ELSE    /* Index should be valid */
		IF (getIndexStatus(l_index, p_fact_name, schema) <> 'VALID') THEN
			writelog( ' Status for '||l_index||
				' is not valid... Rebuilding index to make it valid');

			l_stmt := 'ALTER INDEX '||schema||'.'||l_index||' REBUILD';
			writelog(l_stmt);
			execute immediate l_stmt;
		END IF;
	   END IF;
	   END IF;

	fkCounter := fkCounter + 1;
	END LOOP;

END;


/*-------------------------------------------------------------------

	This API is called from the concurrent program. If fact name
	is passed then alter indexes for this fact. Else alter indexes
	for all facts.

--------------------------------------------------------------------*/

Procedure alterIndexes(errbuf in varchar2, retcode in number,
			p_fact_name in varchar2 default null) IS
cursor c_getFacts is
SELECT distinct object_short_name from edw_attribute_properties
where nvl(level_name, 'null') = 'null';
l_fact varchar2(50);
l_dir varchar2(100);

BEGIN

/*
   l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');

   IF l_dir is null THEN
     l_dir:='/sqlcom/log';
   END IF;

   FND_FILE.put_names(p_fact_name||'.log',p_fact_name||'.out',l_dir);

	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'Alter Indexes for Configured Objects');


	OPEN c_getFacts;
	LOOP
		fetch c_getFacts into l_fact;
		EXIT WHEN c_getFacts%NOTFOUND;

		alterIndexesForFact(l_fact);
	END LOOP;

	CLOSE c_getFacts;
	utl_file.fclose(g_file);

*/

null;

END;

end edw_alter_indexes;

/
