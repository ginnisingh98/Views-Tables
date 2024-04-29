--------------------------------------------------------
--  DDL for Package Body OE_FND_ATTACHMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FND_ATTACHMENTS_PVT" as
/* $Header: OEXVATTB.pls 120.3.12010000.2 2008/10/16 09:16:07 cpati ship $ */

--  Global constant holding the package name
G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'oe_fnd_attachments_pvt';

TYPE Attribute_Rec_Type IS RECORD
( attribute_code                   VARCHAR2(30)
, column_name                      VARCHAR2(30)
, data_type                        VARCHAR2(30)
, value                            VARCHAR2(50)
);

TYPE Attribute_Tbl_Type IS TABLE OF Attribute_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Document_Rec_Type IS RECORD
(
 document_id                    number
);

TYPE Document_Tbl_Type IS TABLE OF Document_Rec_Type
INDEX BY BINARY_INTEGER;

G_CACHED_ATTRIBUTES VARCHAR2(1) := 'N';
G_HDR_ENTITY_SQL VARCHAR2(2000);
G_LIN_ENTITY_SQL VARCHAR2(2000);
G_HDR_ATTRIBUTE_TBL Attribute_Tbl_Type;
G_LIN_ATTRIBUTE_TBL Attribute_Tbl_Type;

--------------------------------------------------------------------
/* LOCAL PROCEDURES/FUNCTIONS */
--------------------------------------------------------------------

--------------------------------------------------------------------------
-- FUNCTION Fetch_Attribute_Values
-- Called By: Add_Attachments_Automatic
-- This function will construct a dynamic sql to select the values of
-- all columns that are attachments enabled for the given entity
-- (p_entity_name) and for the given primary key values (p_pk1_value...)
-- The attributes and attribute values are returned in a table
--------------------------------------------------------------------------
FUNCTION Fetch_Attribute_Values
          ( p_entity_name           IN VARCHAR2
		, p_database_object_name  IN VARCHAR2
		, p_pk1_value             IN VARCHAR2
		, p_pk2_value             IN VARCHAR2
		, p_pk3_value             IN VARCHAR2
		, p_pk4_value             IN VARCHAR2
		, p_pk5_value             IN VARCHAR2
		)
RETURN ATTRIBUTE_TBL_TYPE
IS
l_database_object_name  VARCHAR2(30) := 'OE_AK_ORDER_HEADERS_V';

CURSOR c_attachment_attributes IS
      sELECT o.attribute_code, akoa.column_name, aka.data_type
      FROM oe_ak_obj_attr_ext o
           , ak_object_attributes akoa
		 , ak_attributes aka
      WHERE o.database_object_name = l_database_object_name
        AND o.attachments_enabled_flag = 'Y'
        AND o.database_object_name = akoa.database_object_name
        AND o.attribute_code = akoa.attribute_code
        AND o.attribute_application_id = akoa.attribute_application_id
	   AND aka.attribute_code = akoa.attribute_code
	   AND aka.attribute_application_id = akoa.attribute_application_id;
l_index			NUMBER;
l_entity_sql		VARCHAR2(2000);
l_sqlCursor         integer;
l_dummy             number;
l_attribute_tbl     ATTRIBUTE_TBL_TYPE;
l_entity_Table	  	fnd_document_entities.table_name%TYPE;
l_pk1_Column			fnd_document_entities.pk1_column%TYPE;
l_pk2_Column			fnd_document_entities.pk2_column%TYPE;
l_pk3_Column			fnd_document_entities.pk3_column%TYPE;
l_pk4_Column			fnd_document_entities.pk4_column%TYPE;
l_pk5_Column			fnd_document_entities.pk5_column%TYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER FETCH_ATTRIBUTE_VALUES' , 1 ) ;
   END IF;

   SELECT table_name, pk1_column, pk2_column
		, pk3_column, pk4_column, pk5_column
   INTO l_entity_table, l_pk1_column, l_pk2_column
		, l_pk3_column, l_pk4_column, l_pk5_column
   FROM FND_DOCUMENT_ENTITIES
   WHERE data_object_code = p_entity_name;

   --------------------------------------------------------------
   -- CONSTRUCT THE SQL STATEMENT
   --------------------------------------------------------------

   IF g_cached_attributes = 'N' THEN
     --cache header and line entities
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CACHING ATTACHMENT ATTRIBUTES' , 1 ) ;
     END IF;
    l_dummy := 1;

    LOOP            -- loop twice: once for header, once for lines
     IF l_dummy = 2 THEN
       l_database_object_name := 'OE_AK_ORDER_LINES_V';
       l_attribute_tbl.delete;
     END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BUILDING SQL TO SELECT COLUMNS FROM ENTITY' , 1 ) ;
   END IF;
   l_index := 1;

   -- select columns that have attachments_enabled_flag = 'Y'
   -- e.g SELECT CUSTOMER_PO_NUMBER, to_char(SOLD_TO_ORG_ID), to_char(ORDER_TYPE_ID)

   l_entity_sql  := 'SELECT ';
   OPEN c_attachment_attributes;
   LOOP
     FETCH c_attachment_attributes
	    INTO l_attribute_tbl(l_index).attribute_code
		   ,l_attribute_tbl(l_index).column_name
		   ,l_attribute_tbl(l_index).data_type;
     EXIT WHEN c_attachment_attributes%notfound;
	if l_index = 1 then
	  if l_attribute_tbl(l_index).data_type <> 'VARCHAR2' then
	  l_entity_sql := l_entity_sql||'to_char('||l_attribute_tbl(l_index).column_name||') ';
	  else
	  l_entity_sql := l_entity_sql||l_attribute_tbl(l_index).column_name||' ';
	  end if;
	else
	  if l_attribute_tbl(l_index).data_type <> 'VARCHAR2' then
	  l_entity_sql := l_entity_sql||' ,to_char('||l_attribute_tbl(l_index).column_name||') ';
	  else
	  l_entity_sql := l_entity_sql||' ,'||l_attribute_tbl(l_index).column_name||' ';
	  end if;
	end if;
     l_index := l_index+1;
   END LOOP;
   CLOSE c_attachment_attributes;

     IF l_dummy = 1 THEN
      g_hdr_entity_sql := l_entity_sql;
      g_hdr_attribute_tbl := l_attribute_tbl;
     ELSE
      g_lin_entity_sql := l_entity_sql;
      g_lin_attribute_tbl := l_attribute_tbl;
     END IF;

     EXIT WHEN l_dummy = 2;
     l_dummy := l_dummy + 1;
    END LOOP;  --loop twice: once for headers, once for lines

     g_cached_attributes := 'Y';

   END IF; --attributes aren't cached

   IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'USING HEADER ATTRIBUTES CACHE' , 1 ) ;
       END IF;
      l_entity_sql := g_hdr_entity_sql;
      l_attribute_tbl := g_hdr_attribute_tbl;
   ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'USING LINE ATTRIBUTES CACHE' , 1 ) ;
       END IF;
      l_entity_sql := g_lin_entity_sql;
      l_attribute_tbl := g_lin_attribute_tbl;
   END IF;


   <<WHERE_CLAUSE>>
   -- Append entity name and values for the primary keys
   -- e.g FROM OE_ORDER_HEADERS_ALL WHERE HEADER_ID = 1234

   l_entity_sql := l_entity_sql || 'FROM '  ||  l_entity_table;
   l_entity_sql := l_entity_sql || ' WHERE ' ||  l_pk1_Column || ' = :p_pk1_value';
   if (l_pk2_Column IS NOT NULL) then
      l_entity_sql := l_entity_sql || ' AND ( ' || l_pk2_column || ' IS NULL';
      l_entity_sql := l_entity_sql || ' OR    ' || l_pk2_column || ' = :p_pk2_value) ';
   end if;
   if (l_pk3_column IS NOT NULL) then
      l_entity_sql := l_entity_sql || ' AND ( ' || l_pk3_column || ' IS NULL';
      l_entity_sql := l_entity_sql || ' OR    ' || l_pk3_column || ' = :p_pk3_value) ';
   end if;
   if (l_pk4_column IS NOT NULL) then
      l_entity_sql := l_entity_sql || ' AND ( ' || l_pk4_column || ' IS NULL';
      l_entity_sql := l_entity_sql || ' OR    ' || l_pk4_column || ' = :p_pk4_value) ';
   end if;
   if (l_pk4_column IS NOT NULL) then
      l_entity_sql := l_entity_sql || ' AND ( ' || l_pk4_column || ' IS NULL';
      l_entity_sql := l_entity_sql || ' OR    ' || l_pk4_column || ' = :p_pk4_value) ';
   end if;
   if (l_pk5_column IS NOT NULL) then
      l_entity_sql := l_entity_sql || ' AND ( ' || l_pk5_column || ' IS NULL';
      l_entity_sql := l_entity_sql || ' OR    ' || l_pk5_column || ' = :p_pk5_value) ';
   end if;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FINAL SQL TO RETRIEVE ENTITY REFERENCE : ' ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  L_ENTITY_SQL ) ;
   END IF;


   -------------------------------------------------------------------
   -- CREATE DYNAMIC SQL CURSOR AND EXECUTE
   -------------------------------------------------------------------
   l_sqlCursor := DBMS_SQL.open_cursor;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FETCH_ATTRIBUTE_VALUES:CURSOR OPEN OK' ) ;
   END IF;

   DBMS_SQL.parse(l_sqlCursor, l_entity_sql, DBMS_SQL.NATIVE);

   DBMS_SQL.bind_variable(l_sqlCursor, 'p_pk1_value',p_pk1_value );
   if (l_pk2_column IS NOT NULL) then
	DBMS_SQL.bind_variable(l_sqlCursor, 'p_pk2_value',p_pk2_value );
   end if;
   if (l_pk3_column IS NOT NULL) then
	DBMS_SQL.bind_variable(l_sqlCursor, 'p_pk3_value',p_pk3_value );
   end if;
   if (l_pk4_column IS NOT NULL) then
	DBMS_SQL.bind_variable(l_sqlCursor, 'p_pk4_value',p_pk4_value );
   end if;
   if (l_pk5_column IS NOT NULL) then
	DBMS_SQL.bind_variable(l_sqlCursor, 'p_pk5_value',p_pk5_value );
   end if;

   for l_index in 1..l_attribute_tbl.COUNT loop
				    IF l_debug_level  > 0 THEN
				        oe_debug_pub.add(  'DEFINING COLUMN FOR ATTRIBUTE: '|| L_ATTRIBUTE_TBL ( L_INDEX ) .ATTRIBUTE_CODE ) ;
				    END IF;
        DBMS_SQL.define_column(l_sqlCursor, l_index, l_attribute_tbl(l_index).value, 50);
   end loop;

   l_dummy := DBMS_SQL.execute(l_sqlCursor);
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FETCH_ATTRIBUTE_VALUES:EXECUTE OK' ) ;
   END IF;


   -------------------------------------------------------------------
   -- FETCH VALUES FROM SQL CURSOR INTO l_attribute_tbl
   -------------------------------------------------------------------

   if (DBMS_SQL.fetch_rows(l_sqlCursor) <> 0) then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'FETCH_ATTRIBUTE_VALUES:FETCH_ROWS OK' ) ;
       END IF;
       for l_index in 1..l_attribute_tbl.COUNT loop
        DBMS_SQL.column_value(l_sqlcursor, l_index, l_attribute_tbl(l_index).value);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ATTRIBUTE VALUE: '||L_ATTRIBUTE_TBL ( L_INDEX ) .VALUE ) ;
        END IF;
       end loop;
   else
	  raise no_data_found;
   end if;
   DBMS_SQL.close_cursor(l_sqlCursor);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXIT FETCH_ATTRIBUTE_VALUES' , 1 ) ;
   END IF;

   RETURN l_attribute_tbl;

END Fetch_Attribute_Values;

--------------------------------------------------------------------------
-- FUNCTION Fetch_Documents
-- This function will evaluate the existing attachment rules/rule elements
-- based on the attribute values passed to it (p_attribute_tbl) and
-- identify the rules that apply to the entity and returns the
-- documents corresponding to the applicable rules
-- This function also constructs a dynamic sql to select the rules/documents
-- that apply to this entity
--------------------------------------------------------------------------
FUNCTION Fetch_Documents
		( p_database_object_name  IN VARCHAR2
		, p_attribute_tbl         IN Attribute_Tbl_Type
		)
RETURN Document_Tbl_Type IS
l_index			NUMBER;
l_rule_sql		VARCHAR2(5000);
l_sqlCursor         integer;
l_dummy             number;
l_document_tbl      Document_Tbl_Type;
l_document_id       NUMBER;
l_newline           CONSTANT VARCHAR2(10) := '
';
l_first_value       BOOLEAN;
l_rows              NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER FETCH_DOCUMENTS' , 1 ) ;
   END IF;

   -------------------------------------------------------------------
   -- CONSTRUCT THE SQL STATEMENT
   -------------------------------------------------------------------

   -- select valid documents attached to applicable rules for this entity

   l_rule_sql := 'select distinct r.document_id'||l_newline||
		  'from oe_attachment_rules r'||l_newline||
		  '     , oe_attachment_rule_elements e1'||l_newline||
		  '     , fnd_documents d'||l_newline||
		  'where r.database_object_name = :p_database_object_name'||l_newline||
		  '  and e1.rule_id = r.rule_id'||l_newline||
		  '  and r.document_id = d.document_id'||l_newline||
	       '  AND sysdate between NVL(d.start_date_active, sysdate)'||l_newline||
	       '		   and  NVL(d.end_date_active, sysdate )'||l_newline||
		  '  and ('
		  ;

   -- select only those rules where the attribute values match those
   -- on the entity record

   l_first_value := TRUE;
   for l_index in 1..p_attribute_tbl.COUNT loop

    if p_attribute_tbl(l_index).value is not null then

       -- include 'or' in the statement if it is not the first attribute
       if (l_first_value) then
       l_rule_sql := l_rule_sql||l_newline||
		  '        (e1.attribute_code = :p_attribute_code'||l_index||l_newline||
		  '         and e1.attribute_value = :p_attribute_value'||l_index||')';
       else
       l_rule_sql := l_rule_sql||l_newline||
		  '        or (e1.attribute_code = :p_attribute_code'||l_index||l_newline||
		  '         and e1.attribute_value = :p_attribute_value'||l_index||')';
       end if;

    l_first_value := FALSE;
    end if;

   end loop;

   -- but do not select the rules if they are AND conditions with attribute
   -- values that do not match ( or <>) those on the entity

   l_rule_sql := l_rule_sql||l_newline||
            '        )'||l_newline||
            '  and not exists ( select null'||l_newline||
            '          from oe_attachment_rule_elements e2'||l_newline||
            '          where e2.rule_id = r.rule_id'||l_newline||
            '            and e2.group_number = e1.group_number'||l_newline||
            '            and e2.rowid <> e1.rowid'||l_newline||
            '            and (';

   for l_index in 1..p_attribute_tbl.COUNT loop

       -- include 'or' in the statements if it is not the first attribute
       if l_index = 1 then
         l_rule_sql := l_rule_sql||l_newline
		  ||'                 (e2.attribute_code = :p_attribute_code'||l_index||l_newline||
		  '                  and e2.attribute_value <> nvl(:p_attribute_value'||l_index||','' ''))';
       else
         l_rule_sql := l_rule_sql||l_newline||
		  '                  or (e2.attribute_code = :p_attribute_code'||l_index||l_newline||
		  '                  and e2.attribute_value <> nvl(:p_attribute_value'||l_index||','' ''))';
       end if;

   end loop;

   l_rule_sql := l_rule_sql||l_newline
		  ||'   )  )';

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FINISHED BUILDING RULES SQL:' ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  L_RULE_SQL ) ;
   END IF;

   -------------------------------------------------------------------
   -- CREATE DYNAMIC SQL CURSOR AND EXECUTE
   -------------------------------------------------------------------
   l_sqlCursor := DBMS_SQL.open_cursor;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FETCH_DOCUMENTS:CURSOR OPEN OK' ) ;
   END IF;

   DBMS_SQL.parse(l_sqlCursor, l_rule_sql, DBMS_SQL.NATIVE);

	DBMS_SQL.bind_variable(l_sqlCursor, 'p_database_object_name',p_database_object_name);
   for l_index in 1..p_attribute_tbl.COUNT loop
	DBMS_SQL.bind_variable(l_sqlCursor, 'p_attribute_code'||l_index,p_attribute_tbl(l_index).attribute_code );
	DBMS_SQL.bind_variable(l_sqlCursor, 'p_attribute_value'||l_index,p_attribute_tbl(l_index).value );
   end loop;

   DBMS_SQL.define_column(l_sqlCursor, 1, l_document_id);

   l_dummy := DBMS_SQL.execute(l_sqlCursor);
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FETCH_DOCUMENTS:EXECUTE OK' ) ;
   END IF;


   -------------------------------------------------------------------
   -- FETCH VALUES FROM SQL CURSOR INTO l_document_tbl
   -------------------------------------------------------------------

   l_index := 1;
   while (DBMS_SQL.fetch_rows(l_sqlCursor)<> 0) loop
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'FETCH_DOCUMENTS:FETCH_ROWS OK' ) ;
       END IF;
       DBMS_SQL.column_value(l_sqlcursor, 1, l_document_id);
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'DOCUMENT ID:'||L_DOCUMENT_ID ) ;
       END IF;
	  l_document_tbl(l_index).document_id := l_document_id;
	  l_index := l_index+1;
   end loop;
   DBMS_SQL.close_cursor(l_sqlCursor);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXIT FETCH_DOCUMENTS' , 1 ) ;
   END IF;

   RETURN l_document_tbl;

END Fetch_Documents;

--------------------------------------------------------------------
/* PUBLIC PROCEDURES/FUNCTIONS */
--------------------------------------------------------------------

--------------------------------------------------------------------
PROCEDURE Add_Attachments_Automatic
(
 p_api_version                      in   number,
 p_entity_name                      in   varchar2,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_commit					in   varchar2 := fnd_api.G_FALSE,
x_attachment_count out nocopy number,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

)
IS
   l_api_name			CONSTANT	VARCHAR2(30) := 'ADD_ATTACHMENTS_AUTOMATIC';
   l_api_version_number 	CONSTANT 	NUMBER := 1.0;
   l_attachment_id			NUMBER;
   l_attribute_tbl       Attribute_Tbl_Type;
   l_database_object_name    VARCHAR2(30);
   l_documentTbl	  	 Document_Tbl_Type;
   l_documentID           number;
   i  				 number;
   l_attachment_exist           number:=0;
   l_need_delete_insert         BOOLEAN :=TRUE;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER OE_FND_ATTACHMENTS_PVT.ADD_ATTACHMENTS_AUTOMATIC' , 1 ) ;
   END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   x_attachment_count := 0;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'GET DATABASE_OBJECT_NAME' , 1 ) ;
   END IF;

   SELECT database_object_name
   INTO l_database_object_name
   FROM oe_ak_objects_ext
   WHERE data_object_code = p_entity_name;

   --------------------------------------------------------------
   -- FETCH VALUES OF ALL THE ATTACHMENTS ENABLED ATTRIBUTES
   -- FROM THE ENTITY
   --------------------------------------------------------------

   l_attribute_tbl := Fetch_Attribute_Values
			(p_entity_name      => p_entity_name
			,p_database_object_name  => l_database_object_name
			,p_pk1_value        => p_pk1_value
			,p_pk2_value		=> p_pk2_value
			,p_pk3_value		=> p_pk3_value
			,p_pk4_value		=> p_pk4_value
			,p_pk5_value		=> p_pk5_value
               );

   ---------------------------------------------------------------
   -- EVALUATE ADDITION RULES AND FETCH DOCUMENTS THAT SHOULD
   -- BE ATTACHED TO THIS ENTITY
   ---------------------------------------------------------------

   l_documentTbl := Fetch_Documents
			(p_database_object_name  => l_database_object_name
			,p_attribute_tbl => l_attribute_tbl
			);

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'COUNT OF DOCUMENTS :'||L_DOCUMENTTBL.COUNT ||'FIRST ELEMENT: '||L_DOCUMENTTBL.FIRST ) ;
			END IF;


   ---------------------------------------------------------------------
   -- DELETE EXISTING AUTOMATIC ATTACHMENTS
   ---------------------------------------------------------------------

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'DELETING EXISTING AUTOMATIC ATTACHMENTS' ) ;
   END IF;
/* Check if the same attachment is already there */

/*6896311
  BEGIN
    select  1
    into l_attachment_exist
    from fnd_attached_documents
    where entity_name = p_entity_name
     and pk1_value = p_pk1_value
     and nvl(pk2_value,'NULL')  =  nvl(p_pk2_value,'NULL')
     and nvl(pk3_value,'NULL')  =  nvl(p_pk3_value,'NULL')
     and nvl(pk4_value,'NULL')  =  nvl(p_pk4_value,'NULL')
     and nvl(pk5_value,'NULL')  =  nvl(p_pk5_value,'NULL') ;

    if l_attachment_exist > 0 THEN
        l_need_delete_insert := FALSE;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add( 'ATTACHMENTS EXIST DO NOT DELETE IT' ) ;
            oe_debug_pub.add( 'entity Name :'|| p_entity_name,1);
            oe_debug_pub.add( 'x_pk1_value:'|| p_pk1_value,1);
            oe_debug_pub.add( 'x_pk2_value:'|| p_pk2_value,1);
            oe_debug_pub.add( 'x_pk3_value:'|| p_pk3_value,1);
            oe_debug_pub.add( ' x_pk4_value:'|| p_pk4_value,1);
            oe_debug_pub.add( 'x_pk5_value:'|| p_pk5_value,1);
         END IF;
   else
      l_need_delete_insert := TRUE;
     IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ATTACHMENTS DO NOT  EXIST DELETE IF THERE IS
ANY' ) ;
            oe_debug_pub.add( 'entity Name :'|| p_entity_name,1);
            oe_debug_pub.add( 'x_pk1_value:'|| p_pk1_value,1);
            oe_debug_pub.add( 'x_pk2_value:'|| p_pk2_value,1);
            oe_debug_pub.add( 'x_pk3_value:'|| p_pk3_value,1);
            oe_debug_pub.add( 'x_pk4_value:'|| p_pk4_value,1);
            oe_debug_pub.add( 'x_pk5_value:'|| p_pk5_value,1);
     END IF;
   end if;
 EXCEPTION
   when others then
       null;
 END;

IF l_need_delete_insert  THEN
6896311*/

   FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS
			(x_entity_name      => p_entity_name
			,x_pk1_value        => p_pk1_value
			,x_pk2_value		=> p_pk2_value
			,x_pk3_value		=> p_pk3_value
			,x_pk4_value		=> p_pk4_value
			,x_pk5_value		=> p_pk5_value
			,x_automatically_added_flag	=> 'Y'
			);


   ---------------------------------------------------------------------
   -- CREATE AUTOMATIC ATTACHMENTS
   ---------------------------------------------------------------------

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CREATING AUTOMATIC ATTACHMENTS' ) ;
   END IF;

   i := l_documentTbl.first;
   while i is not null loop

   	-- attach the document to the entity
   	oe_fnd_attachments_pvt.Add_Attachment(
			p_api_version			=> 1.0,
		     p_entity_name			=> p_entity_name,
			p_pk1_value			=> p_pk1_value,
			p_pk2_value			=> p_pk2_value,
			p_pk3_value			=> p_pk3_value,
			p_pk4_value			=> p_pk4_value,
			p_pk5_value			=> p_pk5_value,
			p_automatic_flag		=> 'Y',
			p_document_id 			=> l_documentTbl(i).document_id,
			x_attachment_id 		=> l_attachment_id,
			x_return_status		=> x_return_status,
			x_msg_count			=> x_msg_count,
			x_msg_data			=> x_msg_data
               );

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

	i := l_documentTbl.next(i);

   end loop;

   x_attachment_count := l_documentTbl.COUNT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

      OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);

--6896311 END IF;  --l_need_delete_insert ?

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXIT OE_FND_ATTACHMENTS_PVT.ADD_ATTACHMENTS_AUTOMATIC' , 1 ) ;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
    WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ADD_ATTACHMENTS_AUTOMATIC:AN EXCEPTION HAS OCCURED' , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ERROR: '||SUBSTR ( SQLERRM , 1 , 250 ) , 1 ) ;
     END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level
           (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   l_api_name
                        );
      END IF;
      OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
			);
END Add_Attachments_Automatic;


--------------------------------------------------------------------
PROCEDURE Add_Attachment
(
 p_api_version					 in   number,
 p_entity_name					 in   varchar,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_automatic_flag				 in   varchar2 default 'N',
 p_document_id					 in   number,
 p_validate_flag   				 in   varchar2 default 'Y',
x_attachment_id out nocopy number,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

)
--------------------------------------------------------------------
IS
   l_api_name              CONSTANT VARCHAR2(30) := 'ADD_ATTACHMENT';
   l_api_version_number    CONSTANT NUMBER := 1.0;

   l_attachment_id number;
   l_dummy				varchar(1);

   CURSOR C_DOC
   IS
      SELECT 'Y'
      FROM FND_DOCUMENTS
      WHERE document_id = p_document_id;

   l_user_id	      	number:=fnd_global.USER_ID;
   l_login_id	      	number:=fnd_global.LOGIN_ID;

   l_seq_num				NUMBER;
   l_attached_document_id	NUMBER;
   l_media_id				NUMBER;
   l_document_id			NUMBER := p_document_id;
   l_rowid				VARCHAR2(60);
--included to fix bug 1903257   Begin
   l_usage_type   fnd_documents.usage_type%TYPE  := null;
   l_datatype_id  fnd_documents.datatype_id%TYPE := null;
   l_category_id  fnd_documents.category_id%TYPE := null;
   l_security_type fnd_documents.security_type%TYPE := null;
   l_publish_flag  fnd_documents.publish_flag%TYPE := null;
   l_description   fnd_documents_vl.description%TYPE := null;
   l_file_name     fnd_documents_vl.file_name%TYPE := null;
   l_create_doc   varchar2(1):= null;
--included to fix bug 1903257    End

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   if ( p_validate_flag = 'Y') then

      -- validate the document_id
      open C_DOC;
      fetch C_DOC into l_dummy;
      if (C_DOC%NOTFOUND)   then
         -- invalid document id!
         close C_DOC;
	    FND_MESSAGE.SET_NAME('ONT','OE_INVALID_DOCUMENT_ID');
	    OE_MSG_PUB.ADD;
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      close C_DOC;

   end if;

/*
	-- validate the entity
	BEGIN
	select data_object_code
	into l_data_object
	from oe_ak_obj_attr_ext
	where database_object_name = p_database_object_name
	  and data_object_code is not null;
	EXCEPTION
	WHEN no_data_found THEN
	    FND_MESSAGE.SET_NAME('ONT','OE_INVALID_DOCUMENT_ENTITY');
	    OE_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	END;
	*/

	 -- calculate the sequence number for the document and
	 -- the attached document id to be passed to the AOL API

	 select (nvl(max(seq_num),0) + 10)
	 into l_seq_num
	 from fnd_attached_documents
	 where entity_name = p_entity_name
	   and pk1_value = p_pk1_value;

	 select fnd_attached_documents_s.nextval
	 into l_attached_document_id
	 from dual;
      --Code changes made to fix bug 1903257    Begin
        begin
          select usage_type
          into l_usage_type
          from fnd_documents
          where document_id = p_document_id ;
         if l_usage_type = 'S' then
            l_create_doc := null;
         elsif l_usage_type in ('T','O') then
          begin
           select datatype_id,category_id,security_type,
           publish_flag,media_id,file_name,description
           into l_datatype_id,l_category_id,l_security_type,
           l_publish_flag,l_media_id,l_file_name,l_description
           from fnd_documents_vl where document_id = p_document_id;
           l_create_doc := 'Y';
           l_document_id := null;
           exception
            when others then
                 null;
          end;
         end if;
        exception
          when others then
            null;
        end;
   --Code changes made to fix bug 1903257    End
   -- included a new parameter X_Create_doc below to fix bug 1903257

	 FND_ATTACHED_DOCUMENTS_PKG.INSERT_ROW
		(x_rowid			=> l_rowid
		, x_attached_document_id	=> l_attached_document_id
		, x_document_id			=> l_document_id
		, x_seq_num			=> l_seq_num
		, x_entity_name			=> p_entity_name
		, x_pk1_value			=> p_pk1_value
		, x_pk2_value			=> p_pk2_value
		, x_pk3_value			=> p_pk3_value
		, x_pk4_value			=> p_pk4_value
		, x_pk5_value			=> p_pk5_value
		, x_automatically_added_flag	=> p_automatic_flag
		, x_creation_date		=> sysdate
		, x_created_by			=> l_user_id
		, x_last_update_date		=> sysdate
		, x_last_updated_by		=> l_user_id
		, x_last_update_login		=> l_login_id
		-- following parameters are required for the API but we do not
		-- use so send in as null
		, x_column1			=> null
    		, x_datatype_id			=> l_datatype_id
		, x_category_id			=> l_category_id
		, x_security_type		=> l_security_type
		, X_security_id			=> null
		, X_publish_flag		=> l_publish_flag
		, X_image_type			=> null
		, X_storage_type		=> null
		, X_usage_type			=> l_usage_type
		, X_language			=> null
		, X_description			=> l_description
		, X_file_name			=> l_file_name
		, X_media_id			=> l_media_id
		, X_doc_attribute_Category	=> null
		, X_doc_attribute1		=> null
		, X_doc_attribute2		=> null
		, X_doc_attribute3		=> null
		, X_doc_attribute4		=> null
		, X_doc_attribute5		=> null
		, X_doc_attribute6		=> null
		, X_doc_attribute7		=> null
		, X_doc_attribute8		=> null
		, X_doc_attribute9		=> null
		, X_doc_attribute10		=> null
		, X_doc_attribute11		=> null
		, X_doc_attribute12		=> null
		, X_doc_attribute13		=> null
		, X_doc_attribute14		=> null
		, X_doc_attribute15		=> null
                , X_create_doc => l_create_doc
		);

      x_attachment_id := l_attached_document_id;

      OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level
           (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   l_api_name
                        );
      END IF;
      OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
			);
END Add_Attachment;
--------------------------------------------------------------------


--  Start of Comments
--  API name    Delete_Attachments
--  Type        PRIVATE
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
---------------------------------------------------------------------
PROCEDURE Delete_Attachments
--------------------------------------------------------------------
(
 p_api_version                      in   number,
 p_entity_name                      in   varchar2,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_automatic_atchmts_only	 	 in 	 varchar2 default 'N',
x_return_status out nocopy varchar2

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	FND_ATTACHED_DOCUMENTS2_PKG.Delete_Attachments
			(x_entity_name		=> p_entity_name
			,x_pk1_value		=> p_pk1_value
			,x_pk2_value		=> p_pk2_value
			,x_pk3_value		=> p_pk3_value
			,x_pk4_value		=> p_pk4_value
			,x_pk5_value		=> p_pk5_value
			);

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Attachments'
			);
        END IF;
END Delete_Attachments;

END oe_fnd_attachments_pvt;

/
