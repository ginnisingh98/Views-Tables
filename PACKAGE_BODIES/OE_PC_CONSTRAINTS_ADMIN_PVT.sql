--------------------------------------------------------
--  DDL for Package Body OE_PC_CONSTRAINTS_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_CONSTRAINTS_ADMIN_PVT" as
/* $Header: OEXVPCAB.pls 120.0.12000000.2 2007/11/26 09:24:21 vbkapoor ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_PC_Constraints_Admin_Pvt';

--  Record/Table used to cache conditions for a constraint
TYPE ConstraintRule_Rec_Type IS RECORD
 (
	application_id				 number,
	entity_short_name			 varchar2(15),
     condition_id                   number,
     group_number                   number,
     modifier_flag	                varchar2(1),
     validation_application_id      number,
     validation_entity_short_name   varchar2(15),
     validation_tmplt_short_name    varchar2(8),
     record_set_short_name          varchar2(8),
     scope_op	                      varchar2(3),
     validation_pkg	                varchar2(30),
     validation_proc	          varchar2(30),
	validation_tmplt_id            number,
	record_set_id                  number,
	validation_entity_id           number,
	entity_id                      number
 );

TYPE ConstraintRule_Tbl_Type IS TABLE OF ConstraintRule_Rec_Type
INDEX BY BINARY_INTEGER;

G_ConstraintRuleTbl     ConstraintRule_Tbl_Type;

-- Constant to indicate maximum number of condition records that
-- can be cached per constraint
G_MAX_CONDITIONS        NUMBER := 100;

--  Record/Table used to cache results of a validated condition
TYPE Result_Rec_Type IS RECORD
   (
	validation_tmplt_id            number,
	record_set_id                  number,
	validation_entity_id           number,
	entity_id                      number,
     scope_op                       varchar2(3),
     result                         number
 );

TYPE Result_Tbl_Type IS TABLE OF Result_Rec_Type
INDEX BY BINARY_INTEGER;

G_RESULT_CACHE                  Result_Tbl_Type;

-- Record/Table Type to cache constraints
TYPE Constraint_Cache_Rec_Type IS RECORD
( ENTITY_ID                   NUMBER
, COLUMN_NAME                           VARCHAR2(30)
, CONSTRAINT_ID               NUMBER
, ON_OPERATION_ACTION        NUMBER
);

TYPE Constraint_Cache_TBL_Type IS TABLE OF Constraint_Cache_Rec_Type
INDEX BY BINARY_INTEGER;

G_CHECK_ON_INSERT_CACHE         Constraint_Cache_TBL_Type;

-- Maximum check on insert constraints that can be cached
-- per entity
G_MAX_CONSTRAINTS               CONSTANT NUMBER := 1000;

-- ** For other validations, modify the value_string
-- ** to make them more intelligent to datatype conversions, string padding (strings
-- ** that may contain single quotes and double quotes etc.
FUNCTION Convert_Value_String
		( value_string			IN VARCHAR2
		, data_type			IN VARCHAR2)
RETURN VARCHAR2
IS
l_value_string		VARCHAR2(300) := NULL;
from_char		NUMBER;
found_char		NUMBER;
BEGIN

	IF value_string IS NOT NULL THEN
		IF data_type = 'VARCHAR2' THEN
		   l_value_string := value_string;
		   from_char := 1;
		   -- Padding for single quotes
		   WHILE TRUE LOOP
			SELECT INSTR(l_value_string,'''',1,from_char)
			INTO found_char
			FROM DUAL;
			EXIT WHEN (found_char=0);
			l_value_string := substr(l_value_string,1,found_char)||
						''''||substr(l_value_string,found_char+1,
							length(l_value_string));
			from_char := found_char+2;
		   END LOOP;
		   l_value_string := ''''||l_value_string||'''';
		ELSIF (data_type = 'DATE') THEN
		   l_value_string := 'TO_DATE('''||value_string||''',''RRRR/MM/DD HH24:MI:SS'')';
		ELSE
		   l_value_string := value_string;
		END IF;
	END IF;

	RETURN l_value_string;
END;


------------------------------------------------------------------
FUNCTION Concatenate_VTMPLTCOL_SQL
		( p_vc_sql				IN LONG
		, p_validation_tmplt_id		IN NUMBER
		, p_use_where				IN BOOLEAN := TRUE
		)
RETURN VARCHAR2 IS
------------------------------------------------------------------
-- Validation Template Columns selected such that state attribute columns
-- are selected first. This way, if there is even one condition for state
-- attribute, that will be selected first and this will help in appending
-- the database object name to the FROM cursor.
   CURSOR C_VTMPLTCOLS IS
   SELECT vc.column_name, attr.data_type, vc.validation_op, vc.value_string
	, decode(attr.state_attribute_flag,NULL,1,'Y',0,'N',1) state_attribute
   FROM oe_pc_vtmplt_cols vc,
	oe_pc_vtmplts vt,
	oe_pc_attributes_v attr
   WHERE vc.validation_tmplt_id = p_validation_tmplt_id
     AND vc.validation_tmplt_id = vt.validation_tmplt_id
     AND attr.entity_id = vt.entity_id
     AND attr.column_name = vc.column_name
   ORDER BY state_attribute;
l_value_string				VARCHAR2(240);
l_vc_sql					LONG := p_vc_sql;
i						NUMBER := 1;
BEGIN

   for val_rec in C_VTMPLTCOLS loop

  	l_value_string := Convert_Value_String(val_rec.value_string, val_rec.data_type);

	if (i = 1) and (p_use_where) then
        -- where clause only for the first one
         l_vc_sql := l_vc_sql || '   WHERE a.' || val_rec.column_name ||
			' ' ||val_rec.validation_op || ' ' || l_value_string  || OE_PC_GLOBALS.NEWLINE;
	else
         l_vc_sql := l_vc_sql || '   AND   a.' || val_rec.column_name ||
			' ' ||val_rec.validation_op || ' ' || l_value_string  || OE_PC_GLOBALS.NEWLINE;
     end if;
     i := i + 1;

    end loop;

    RETURN l_vc_sql;

END Concatenate_VTMPLTCOL_SQL;


------------------------------------------------------------------
FUNCTION Concatenate_VTMPLTWF_SQL
		( p_vc_sql				IN LONG
		, p_wf_item_type		     IN VARCHAR2
		, p_wf_activity_name		IN VARCHAR2
		, p_wf_activity_status_code	IN VARCHAR2
		, p_wf_activity_result_code	IN VARCHAR2
		, p_validation_db_object_name IN VARCHAR2 := NULL
		, p_use_where				IN BOOLEAN := TRUE
                , x_bind_var_stmt               OUT NOCOPY LONG
		)
RETURN VARCHAR2 IS
------------------------------------------------------------------
l_vc_sql					LONG := p_vc_sql;
BEGIN

  -- Bug 3739681
  -- Use bind variables for WF columns to be passed to the
  -- validation cursor

     x_bind_var_stmt := x_bind_var_stmt||
            ' l_wf_item_type varchar2(8) :='||
            ''''|| p_wf_item_type||''';' || OE_PC_GLOBALS.NEWLINE;
     x_bind_var_stmt := x_bind_var_stmt||
             ' l_wf_activity_name varchar2(30) :='||
             ''''||p_wf_activity_name||''';' || OE_PC_GLOBALS.NEWLINE;

     l_vc_sql := l_vc_sql || '   FROM wf_item_activity_statuses  w, wf_process_activities wpa'
		|| OE_PC_GLOBALS.NEWLINE;

     IF p_validation_db_object_name IS NOT NULL THEN
        	l_vc_sql := l_vc_sql || '       ,' || p_validation_db_object_name
			||' a '  || OE_PC_GLOBALS.NEWLINE;
     END IF;

     IF (p_use_where) THEN
     	l_vc_sql := l_vc_sql || '   WHERE w.item_type     = l_wf_item_type'
				|| OE_PC_GLOBALS.NEWLINE;
	ELSE
		l_vc_sql := l_vc_sql || '   AND w.item_type = l_wf_item_type'
						|| OE_PC_GLOBALS.NEWLINE;
	END IF;

     l_vc_sql := l_vc_sql || '   AND w.process_activity = wpa.instance_id'
				 || OE_PC_GLOBALS.NEWLINE;

     l_vc_sql := l_vc_sql || '   AND wpa.activity_name = l_wf_activity_name'
				|| OE_PC_GLOBALS.NEWLINE;

     IF p_wf_activity_status_code IS NOT NULL THEN
        x_bind_var_stmt := x_bind_var_stmt||
             ' l_wf_activity_status_code varchar2(8) :='||
             ''''||p_wf_activity_status_code||''';' || OE_PC_GLOBALS.NEWLINE;
        l_vc_sql := l_vc_sql || '   AND w.activity_status = l_wf_activity_status_code'
			|| OE_PC_GLOBALS.NEWLINE;
     END IF;

     IF p_wf_activity_result_code IS NOT NULL THEN
        x_bind_var_stmt := x_bind_var_stmt||
             ' l_wf_activity_result_code varchar2(30) :='||
             ''''||p_wf_activity_result_code||''';' || OE_PC_GLOBALS.NEWLINE;
        l_vc_sql := l_vc_sql || '   AND w.activity_result_code = l_wf_activity_result_code'
			|| OE_PC_GLOBALS.NEWLINE;
     END IF;

	RETURN l_vc_sql;

END Concatenate_VTMPLTWF_SQL;


------------------------------------------------------------------
PROCEDURE  Concatenate_Itemkey_Cols(
    p_prefix        in  varchar2
   ,p_delimiter     in  varchar2
   ,p_column1       in  varchar2
   ,p_column2       in  varchar2
   ,p_column3       in  varchar2
   ,p_column4       in  varchar2
,x_conc_string out nocopy varchar2

)
------------------------------------------------------------------
is
  DOT      varchar2(1) := '.';
  CONC     varchar2(4) := ' || ';
  l_string varchar2(500);
begin
  l_string := p_prefix || DOT || p_column1;
  if (p_column2 is not null) then
     l_string := l_string || CONC || p_delimiter || p_prefix || DOT || p_column2;
  end if;
  if (p_column3 is not null) then
     l_string := l_string || CONC || p_delimiter || p_prefix || DOT || p_column3;
  end if;
  if (p_column4 is not null) then
     l_string := l_string || CONC || p_delimiter || p_prefix || DOT || p_column4;
  end if;
  x_conc_string   := l_string || CONC || '''''';

end Concatenate_Itemkey_Cols;


--------------------------------------------------------------
PROCEDURE  Make_Validation_Cursors(
    p_entity_id             in number
   ,p_validation_entity_id  in number
   ,p_validation_tmplt_id   in number
   ,p_record_set_id         in number
   ,p_global_record_name    in varchar2
,x_valid_count_cursor out nocopy long

,x_set_count_cursor out nocopy long

,x_validation_stmt out nocopy long
,x_bind_var_stmt out nocopy long
)
--------------------------------------------------------------
is
   l_vc_sql     long;
   l_rs_sql     long;
   l_vc_pk_list varchar2(1000);
   l_rs_pk_list varchar2(1000);
   l_concatenated_itemkey_columns  varchar2(1000);

   l_wf_item_type            OE_PC_ENTITIES_V.WF_ITEM_TYPE%TYPE;

   CURSOR C_VTBL IS
   SELECT application_id, db_object_name, db_object_type,
          wf_item_type, itemkey_column1, itemkey_column2,
          itemkey_column3,itemkey_column4, itemkey_delimiter
   FROM OE_PC_ENTITIES_V
   where entity_id = p_validation_entity_id;

   CURSOR C_VTBL1 IS
   SELECT e.application_id, e.db_object_name, e.db_object_type,
          wf.itemkey_column1, wf.itemkey_column2,
          wf.itemkey_column3,wf.itemkey_column4, wf.itemkey_delimiter
   FROM OE_PC_ENTITIES_V e, OE_AK_OBJ_WF_ITEMS wf
   where e.entity_id = p_validation_entity_id
     and wf.database_object_name(+) = e.db_object_name
     and (l_wf_item_type IS NULL
     or  wf.item_type = l_wf_item_type);

   CURSOR C_DTBL IS
   SELECT application_id, db_object_name, db_object_type
   FROM OE_PC_ENTITIES_V
   where entity_id = p_entity_id;

   CURSOR C_VTMPLT  IS
   SELECT validation_type, activity_name, activity_status_code, activity_result_code, wf_item_type
   FROM   oe_pc_vtmplts
   WHERE  validation_tmplt_id = p_validation_tmplt_id
   and    (validation_type = 'WF'
           OR validation_type = 'TBL');

-- Validation Template Columns selected such that state attribute columns
-- are selected first. This way, if there is even one condition for state
-- attribute, that will be selected first and this will help in appending
-- the database object name to the FROM cursor.
   CURSOR C_VTMPLTCOLS IS
   SELECT vc.column_name, attr.data_type, vc.validation_op, vc.value_string
	, decode(attr.state_attribute_flag,NULL,1,'Y',0,'N',1) state_attribute
   FROM oe_pc_vtmplt_cols vc,
	oe_pc_vtmplts vt,
	oe_pc_attributes_v attr
   WHERE vc.validation_tmplt_id = p_validation_tmplt_id
     AND vc.validation_tmplt_id = vt.validation_tmplt_id
     AND attr.entity_id = vt.entity_id
     AND attr.column_name = vc.column_name
   ORDER BY state_attribute;

   CURSOR C_RS IS
   SELECT pk_record_set_flag
   FROM oe_pc_rsets
   WHERE record_set_id = p_record_set_id;

   CURSOR C_RSCOLS IS
   SELECT column_name
   FROM oe_pc_rset_sel_cols
   WHERE record_set_id = p_record_set_id;


   CURSOR C_PKCOLS (cp_application_id     number,
                    cp_db_object_name     varchar2,
                    cp_db_object_type     varchar2)
   IS
   SELECT uk_column_name  pk_column_name
   FROM   oe_pc_ukey_cols_v
   WHERE  application_id  = cp_application_id
   AND    db_object_name  = cp_db_object_name
   ANd    db_object_type  = cp_db_object_type
   AND    primary_key_flag = 'Y'
   AND    uk_column_sequence <= 5
   ORDER BY uk_column_sequence;

   CURSOR C_FKCOLS (cp_fk_application_id     number,
                    cp_fk_db_object_name     varchar2,
                    cp_uk_application_id     number,
                    cp_uk_db_object_name     varchar2,
                    cp_db_object_type        varchar2)
   IS
   SELECT fk_column_name, uk_column_name
   FROM   oe_pc_fkey_cols_v
   WHERE  application_id = cp_fk_application_id
   AND    db_object_name    = cp_fk_db_object_name
   AND    db_object_type    = cp_db_object_type
   AND    uk_application_id = cp_uk_application_id
   AND    uk_db_object_name = cp_uk_db_object_name
   ORDER BY fk_column_sequence;


   CURSOR C_DFK
   IS SELECT 'Y'
   FROM   sys.dual
   WHERE  EXISTS (SELECT 'EXISTS'
                  FROM  oe_pc_rentities_v re
                  WHERE entity_id         = p_entity_id
                  AND   related_entity_id = p_validation_entity_id);


   --driver is the term used to descibe the entity using which we have
   --to identify the record of the validation (validated) entity to
   --perform the validations. for example, if you are checking
   --constraints against Order Line, but the condition is to check the
   --status of its header, then the driver entity is LINE, and the
   --validation entity is HEADER. you should use the foreign key
   --definition of HEADER or LINE (ofcouse it's on LINE in this case but
   --the foreign key may be on either of the entities, if you treat
   --the problem as generic) to navigate to the HEADER.
   ------------------------------------------------------------------------
   l_driver_appln_id      	  number;
   l_driver_db_object_name      OE_PC_ENTITIES_V.db_object_name%TYPE;
   l_driver_db_object_type      OE_PC_ENTITIES_V.db_object_type%TYPE;
   l_driver_entity_fk_flag	  varchar2(1) := 'N';

   l_validation_appln_id        number;
   l_validation_db_object_name  OE_PC_ENTITIES_V.db_object_name%TYPE;
   l_validation_db_object_type  OE_PC_ENTITIES_V.db_object_type%TYPE;
   l_itemkey_column1            OE_PC_ENTITIES_V.ITEMKEY_COLUMN1%TYPE;
   l_itemkey_column2            OE_PC_ENTITIES_V.ITEMKEY_COLUMN2%TYPE;
   l_itemkey_column3            OE_PC_ENTITIES_V.ITEMKEY_COLUMN3%TYPE;
   l_itemkey_column4            OE_PC_ENTITIES_V.ITEMKEY_COLUMN4%TYPE;
   l_itemkey_delimiter          OE_PC_ENTITIES_V.ITEMKEY_DELIMITER%TYPE;
   l_pk_record_set_flag         OE_PC_RSETS.pk_record_set_flag%TYPE;
   l_validation_type            OE_PC_VTMPLTS.VALIDATION_TYPE%TYPE;
   l_wf_activity_name           OE_PC_VTMPLTS.ACTIVITY_NAME%TYPE;
   l_wf_activity_status_code    OE_PC_VTMPLTS.ACTIVITY_STATUS_CODE%TYPE;
   l_wf_activity_result_code    OE_PC_VTMPLTS.ACTIVITY_RESULT_CODE%TYPE;
   l_value_string			  VARCHAR2(240);
   l_ve_condn_sql			  VARCHAR2(240);
   from_char				  NUMBER;
   found_char				  NUMBER;

   -- LOOP variables/counters
   i    number := 0;
   j    number := 0;
   use_where BOOLEAN;

   l_condn_logic_only           BOOLEAN;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin


   -- find out the validation type
   OPEN  C_VTMPLT;
   fetch C_VTMPLT into l_validation_type, l_wf_activity_name,
                      l_wf_activity_status_code, l_wf_activity_result_code, l_wf_item_type;
   CLOSE C_VTMPLT;

   OPEN  C_RS;
   fetch C_RS into l_pk_record_set_flag;
   CLOSE C_RS;

   -- get validation tbl and WF item/key details
   IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN
     OPEN C_VTBL;
     Fetch C_VTBL into l_validation_appln_id,l_validation_db_object_name,
                     l_validation_db_object_type, l_wf_item_type,
                     l_itemkey_column1,l_itemkey_column2,
                     l_itemkey_column3, l_itemkey_column4, l_itemkey_delimiter;
     Close C_VTBL;
   ELSE
     OPEN C_VTBL1;
     Fetch C_VTBL1 into l_validation_appln_id,l_validation_db_object_name,
                     l_validation_db_object_type,
                     l_itemkey_column1,l_itemkey_column2,
                     l_itemkey_column3, l_itemkey_column4, l_itemkey_delimiter;
     Close C_VTBL1;

   END IF;

   if (p_entity_id = p_validation_entity_id) then

      --
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTITY ID = VALIDATION ENTITY ID' , 2 ) ;
      END IF;
      --
      if(l_validation_type = OE_PC_GLOBALS.WF_VALIDATION) then
         --
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'VALIDATION TYPE = WF' , 2 ) ;
         END IF;
         --

         if(l_pk_record_set_flag = OE_PC_GLOBALS.YES_FLAG) then
             --
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'PK_RECORD_SET_FLAG = Y' , 2 ) ;
             END IF;
             --------------------------------------------------------------------
             -- 1. e.g. for entity LINE, validation_type = 'WF' and
             --         entity = LINE; validation_entity = LINE (SAME)
             --         validation_tmplt =  'Invoice Complete'
             --         record set is LINE (Single record set)

             -- the procedure body will look like
             --    -- assume that the condition will fail
             --    x_result := 0;
             --    l_valid_count := 0;
             --
             --    SELECT count(*)
             --    INTO   x_valid_count
             --    FROM   wf_item_activity_statuses_v w
             --    WHERE  w.item_type = 'OEOL'
             --    AND    w.activity_name = 'INVOICE'
             --    AND    w.activity_status_code = 'COMPLETE'
             --    AND    w.activity_result_code = '#NULL'
             --    AND    w.item_key = '||p_global_record_name||'.itemkey_col1 || '||p_global_record_name||'.itemkey_cols
             --
             --    x_result := l_valid_count;
             --    return;
             ---------------------------------------------------------------------

             Concatenate_Itemkey_Cols(p_prefix    => p_global_record_name
	                            ,p_delimiter    => l_itemkey_delimiter
         	                      ,p_column1      => l_itemkey_column1
                                  ,p_column2      => l_itemkey_column2
                                  ,p_column3      => l_itemkey_column3
                                  ,p_column4      => l_itemkey_column4
                                  ,x_conc_string  => l_concatenated_itemkey_columns);

            -- construct the the FROM .. WHERE clasue for the cursor

            l_vc_sql := Concatenate_VTMPLTWF_SQL
                        (p_vc_sql => l_vc_sql
                        ,p_wf_item_type => l_wf_item_type
                        ,p_wf_activity_name => l_wf_activity_name
                        ,p_wf_activity_status_code => l_wf_activity_status_code
                        ,p_wf_activity_result_code =>  l_wf_activity_result_code
                        ,x_bind_var_stmt => x_bind_var_stmt
                        );

            l_vc_sql := l_vc_sql || '   AND   w.item_key = ' ||
				l_concatenated_itemkey_columns  || OE_PC_GLOBALS.NEWLINE;


         else

            --
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'PK_RECORD_SET_FLAG <> Y' , 2 ) ;
            END IF;
            -- l_pk_record_set_flag <> OE_PC_GLOBALS.YES_FLAG)
            -- mult record set
            ---------------------------------------------------------------------
            -- 2. e.g. for validation_type = 'WF' and
            --         entity = LINE; validation_entity = LINE (SAME)
            --         validation_tmplt =  'Invoice Complete'
            --         record_set =  'Ship Set' (Mult Record Set)
            --
            -- the procedure body will look like
            --    -- assume that the validation will fail
            --    x_result := 0;
            --    l_valid_count := 0;
            --    l_set_count   := 0;
            --
            --    SELECT count(*)
            --    INTO   l_valid_count
            --    FROM   wf_item_activity_statuses_v w
            --    WHERE  w.item_type = 'OEOL'
            --    AND    w.activity_name = 'INVOICE'
            --    AND    w.activity_status_code = 'COMPLETE'
            --    AND    w.activity_result_code = '#NULL'
            --    AND    w.item_key   IN
            --           (SELECT b.concatenated_itemkey_columns
            -- 	        FROM   oe_order_lines b
            --            WHERE  b.record_set_selector_columns = '||p_global_record_name||'.record_set_selector_columns);
            --
            --    if (l_valid_count > 0 ) then
            --       if (scope = 'ALL') then
            --          SELECT count(*)
            --          into   l_set_count
            -- 	      FROM   oe_order_lines b
            --	      WHERE  b.record_set_selector_columns = '||p_global_record_name||'.record_set_selector_columns;
            --
            --          if (l_set_count = l_valid_count) then
            --             x_result = 1;
            --          end if;
            --       else
            --          x_result = 1;
            --       end if;
            --    end if;
            --    return;
            ---------------------------------------------------------------------
            Concatenate_Itemkey_Cols(p_prefix     => 'b'
	                            ,p_delimiter    => l_itemkey_delimiter
         	                      ,p_column1      => l_itemkey_column1
                                  ,p_column2      => l_itemkey_column2
                                  ,p_column3      => l_itemkey_column3
                                  ,p_column4      => l_itemkey_column4
                                  ,x_conc_string  => l_concatenated_itemkey_columns);


            -- first let's make the record set sql
            l_rs_sql :=             '   FROM ' || l_validation_db_object_name ||' b ' || OE_PC_GLOBALS.NEWLINE;


            -- add logic to select the record set
            i := 1;
            for rs_rec in C_RSCOLS loop
               if (i = 1) then
                  -- where clause only for the first one
                  l_rs_sql := l_rs_sql || '   WHERE  b.' || rs_rec.column_name || ' =  '||p_global_record_name||'.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
               else
                  l_rs_sql := l_rs_sql || '   AND   b.' || rs_rec.column_name || ' =  '||p_global_record_name||'.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
               end if;
               i := i+ 1;
            end loop;


            -- construct the the FROM .. WHERE clasue for the cursor

            l_vc_sql := Concatenate_VTMPLTWF_SQL
                        (p_vc_sql => l_vc_sql
                        ,p_wf_item_type => l_wf_item_type
                        ,p_wf_activity_name => l_wf_activity_name
                        ,p_wf_activity_status_code => l_wf_activity_status_code
                        ,p_wf_activity_result_code =>  l_wf_activity_result_code
                        ,x_bind_var_stmt => x_bind_var_stmt
                        );

            l_vc_sql := l_vc_sql || '   AND   w.item_key IN '  || OE_PC_GLOBALS.NEWLINE;
            l_vc_sql := l_vc_sql || '                    ( SELECT ' || l_concatenated_itemkey_columns  || OE_PC_GLOBALS.NEWLINE;
            l_vc_sql := l_vc_sql || '                      ' || l_rs_sql  || OE_PC_GLOBALS.NEWLINE;
            l_vc_sql := l_vc_sql || '                    )';

         end if;

      else

         -- l_validation_type <> OE_PC_GLOBALS.WF_VALIDATION
         -- validation type is database column validation
         if(l_pk_record_set_flag = OE_PC_GLOBALS.YES_FLAG) then
            ---------------------------------------------------------------------
            -- 3. e.g. for p_validation_type = 'COLS' and
            --         entity = LINE; validation_entity = LINE (SAME)
            --         validation_tmplt =  'Prorated Price Exists'
            --         record set = LINE (Single Record Set)
            -- the procedure body will look like
            --    -- assume that the validation will fail
            --    x_result := 0;
            --    l_valid_count := 0;
            --
            --    SELECT count(*)
            --    INTO   x_valid_count
            --    FROM   sys.dual
            --    WHERE  '||p_global_record_name||'.prorated_price = 'YES'
            --
            --    x_result := l_valid_count;
            --    return;
            ---------------------------------------------------------------------


          i := 1;
		l_condn_logic_only := FALSE;
          FOR val_rec in C_VTMPLTCOLS LOOP

		  l_value_string := Convert_Value_String(val_rec.value_string, val_rec.data_type);

            IF (i = 1) THEN

		   -- Even if one state attribute makes up this validation template,
		   -- then it will be selected first because cursor C_VTMPLTCOLS
		   -- orders by state_attribute

		   -- If state attribute THEN FROM cursor selects from the database object
		   IF val_rec.state_attribute = 0 THEN

			l_vc_sql :=             '   FROM '|| l_validation_db_object_name ||
									' a '  || OE_PC_GLOBALS.NEWLINE;
            	-- IF state attribute THEN add logic to get to the DB record
			-- E.g. WHERE a.line_id = '||p_global_record_name||'.line_id
               j := 1;
               FOR pk_rec in C_PKCOLS (l_validation_appln_id, l_validation_db_object_name, l_validation_db_object_type) loop
			 IF j= 1 THEN
                         l_vc_sql := l_vc_sql || '   WHERE   a.' || pk_rec.pk_column_name || ' = '||p_global_record_name||'.'||pk_rec.pk_column_name || OE_PC_GLOBALS.NEWLINE;
			 ELSE
                         l_vc_sql := l_vc_sql || '   AND   a.' || pk_rec.pk_column_name || ' = '||p_global_record_name||'.' ||pk_rec.pk_column_name|| OE_PC_GLOBALS.NEWLINE;
			 END IF;
                         j:= j + 1;
            	END LOOP;

               l_vc_sql := l_vc_sql || '   AND a.' || val_rec.column_name ||
						' ' || val_rec.validation_op || ' ' || l_value_string  || OE_PC_GLOBALS.NEWLINE;

		   -- If first attribute NOT state attribute THEN there are no state attributes
		   -- on this validation template, hence select FROM  SYS.DUAL
		   ELSE
			l_condn_logic_only := TRUE;
               l_vc_sql := '  IF '||p_global_record_name||'.' || val_rec.column_name ||
							' ' || val_rec.validation_op || ' ' || l_value_string  || OE_PC_GLOBALS.NEWLINE;
			/*
                  	l_vc_sql :=             '   FROM  SYS.DUAL'  || OE_PC_GLOBALS.NEWLINE;
                  	l_vc_sql := l_vc_sql || '   WHERE '||p_global_record_name||'.' || val_rec.column_name ||
							' ' || val_rec.validation_op || ' ' || l_value_string  || OE_PC_GLOBALS.NEWLINE;
							*/
		   END IF;

		  -- AND clause if not the first attribute
	       ELSE

		  IF val_rec.state_attribute = 0 THEN
                  	l_vc_sql := l_vc_sql || '   AND   a.' || val_rec.column_name || ' ' || val_rec.validation_op || ' ' || l_value_string  || OE_PC_GLOBALS.NEWLINE;
		  ELSE
                  	l_vc_sql := l_vc_sql || '   AND   '||p_global_record_name||'.' || val_rec.column_name || ' ' || val_rec.validation_op || ' ' || l_value_string  || OE_PC_GLOBALS.NEWLINE;
		  END IF;

           END IF; -- end of check to see if i= 1
           i := i + 1;

	     END LOOP;

         else
            -- l_pk_record_set_flag <> OE_PC_GLOBALS.YES_FLAG)
            -- mult record set
            ---------------------------------------------------------------------
            -- 4. e.g. for p_validation_type = 'COLS' and
            --         entity = LINE; validation_entity = LINE (SAME)
            --         validation_tmplt =  'Prorated Price Exists'
            --         record_set =  'Ship Set' (Multi Record Set)
            -- the procedure body will look like
            --    -- assume that the condition will fail
            --    x_result := 0;
            --    l_valid_count := 0;
            --    l_set_count   := 0;
            --
            --    SELECT count(*)
            --    INTO   x_valid_count
            --    FROM   oe_order_lines a
            --    WHERE  a.prorated_price = 'YES'
            --    AND    (a.pk1_columns) 	 IN
            --                      (SELECT (b.pk1_columns)
            -- 	  		       FROM   oe_order_lines b
            --                       WHERE  b.record_set_selector_columns = '||p_global_record_name||'.record_set_selector_columns);
            --    if (l_valid_count > 0 ) then
            --       if (scope = 'ALL') then
            --          SELECT count(*)
            --          into   l_set_count
            -- 	      FROM   oe_order_lines b
            --	  	WHERE  b.record_set_selector_columns = '||p_global_record_name||'.record_set_selector_columns);
            --
            --          if (l_set_count = l_valid_count) then
            --             x_result = 1;
            --          end if;
            --       else
            --          x_result = 1;
            --       end if;
            --    end if;
            --    return;
            --
            --------------------------------------------------------------------
            -- first let's make the record set sql

            -- first let's make the record set sql
            l_rs_sql :=             '   FROM ' || l_validation_db_object_name ||' b '  || OE_PC_GLOBALS.NEWLINE;

            -- add logic to get to the intented record
            i := 1;
            for pk_rec in C_PKCOLS (l_validation_appln_id, l_validation_db_object_name, l_validation_db_object_type) loop
               if (i = 1) then
                  l_rs_pk_list := ' b.' || pk_rec.pk_column_name;
                  l_vc_pk_list := ' a.' || pk_rec.pk_column_name;
               else
                  l_rs_pk_list := l_rs_pk_list || ', b.'|| pk_rec.pk_column_name;
                  l_vc_pk_list := l_vc_pk_list || ', a.'|| pk_rec.pk_column_name;

               end if;
               i := i + 1;
            end loop;
            -- add logic to select the record set
            i := 1;
            for rs_rec in C_RSCOLS loop
               if (i = 1) then
                  l_rs_sql := l_rs_sql || '   WHERE   b.' || rs_rec.column_name || ' =  '||p_global_record_name||'.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
               else
                  l_rs_sql := l_rs_sql || '   AND     b.' || rs_rec.column_name || ' =  '||p_global_record_name||'.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
               end if;
               i := i + 1;
            end loop;


            -- make the validation sql
            l_vc_sql :=             '   FROM '|| l_validation_db_object_name ||' a '  || OE_PC_GLOBALS.NEWLINE;

		  l_vc_sql := Concatenate_VTMPLTCOL_Sql(l_vc_sql, p_validation_tmplt_id);

            -- add logic to get to the intented record
            l_vc_sql := l_vc_sql || '   AND   ( ' || l_vc_pk_list || ' ) IN  ' || OE_PC_GLOBALS.NEWLINE;
            l_vc_sql := l_vc_sql || '                 ( SELECT ' || l_rs_pk_list || OE_PC_GLOBALS.NEWLINE;
            l_vc_sql := l_vc_sql ||                    l_rs_sql  || OE_PC_GLOBALS.NEWLINE;
            l_vc_sql := l_vc_sql || '                  )';

         end if;
      end if;
   else
      -- p_entity_id <> p_validation_entity_id;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'P_ENTITY_ID <> P_VALIDATION_ENTITY_ID' , 2 ) ;
      END IF;
      --

      -- get the driver tbl details
      OPEN C_DTBL;
      Fetch C_DTBL into l_driver_appln_id, l_driver_db_object_name, l_driver_db_object_type;
      Close C_DTBL;

      -- we need to find out the direction of the foreign key.
      -- the foreign key could be on the validating entity(driver) or on the validation entity
      -- for example when LINE is validating HEADER the fk (Line.header_id)is on the LINE (validating entity)
      --             when HEADER is validating LINE the fk (line.header_id)is on the LINE (validation entity)
      --
      l_driver_entity_fk_flag := 'N';
      -- is the validating entity the fk entity?
      OPEN C_DFK;
      Fetch C_DFK into l_driver_entity_fk_flag;
      CLOSE C_DFK;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'L_DRIVER_ENTITY_FK_FLAG IS ' || L_DRIVER_ENTITY_FK_FLAG , 2 ) ;
      END IF;


      if(l_validation_type = OE_PC_GLOBALS.WF_VALIDATION) then

         if(l_driver_entity_fk_flag = 'Y') then

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'L_DRIVER_ENTITY_FK_FLAG =Y AND L_VALIDATION_TYPE =WF' , 2 ) ;
            END IF;

            ---------------------------------------------------------------------
            -- 6. e.g. entity = LINE; validation_entity = HEADER (DIFFERENT)
            --         validation_type = 'WF' and
            --         validation_tmplt =  'Invoice Complete'
            --         record_set =  only the PK record set is allowed so it doesn't matter
            -- since you are navigating to another record based on a the fk_values,
            -- of the validating record identified using its pk_valuess,
            -- the resulting record set will always be one record (parent record)
            -- the procedure body will look like
            --    -- assume that the condition will fail
            --    x_result := 0;
            --    l_valid_count := 0;
            --    l_set_count := 0;
            --
            --    SELECT count(*)
            --    INTO   l_valid_count
            --    FROM   wf_item_activity_statuses_v w,
            --           oe_order_headers a
            --    WHERE  w.item_type = 'OEOH'
            --    AND    w.activity_name = 'INVOICE'
            --    AND    w.activity_status_code = 'COMPLETE'
            --    AND    w.activity_result_code = '#NULL'
            --    AND    w.item_key = a.concatenated_itemkey_columns
            --	AND    a.uk_columns = '||p_global_record_name||'.fk_columns;

            --
            --    if (l_valid_count > 0 ) then
            --        x_result = 1;
            --    end if;
            --    return;
            ---------------------------------------------------------------------

            Concatenate_Itemkey_Cols(p_prefix        => 'a'
	                            ,p_delimiter     => l_itemkey_delimiter
         	                      ,p_column1      => l_itemkey_column1
                                  ,p_column2      => l_itemkey_column2
                                  ,p_column3      => l_itemkey_column3
                                  ,p_column4      => l_itemkey_column4
                                  ,x_conc_string  => l_concatenated_itemkey_columns);



            -- construct the the FROM .. WHERE clasue for the cursor

            l_vc_sql := Concatenate_VTMPLTWF_SQL
                        (p_vc_sql => l_vc_sql
                        ,p_wf_item_type => l_wf_item_type
                        ,p_wf_activity_name => l_wf_activity_name
                        ,p_wf_activity_status_code => l_wf_activity_status_code
                        ,p_wf_activity_result_code =>  l_wf_activity_result_code
                        ,p_validation_db_object_name => l_validation_db_object_name
                        ,x_bind_var_stmt => x_bind_var_stmt
                        );

            l_vc_sql := l_vc_sql || '   AND   w.item_key = ' || l_concatenated_itemkey_columns  || OE_PC_GLOBALS.NEWLINE;


            -- navigate to the validation table
            -- note that here the fk is defined on the driver entity
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'DR DBO: ' || L_DRIVER_DB_OBJECT_NAME || ' VDBO: ' || L_VALIDATION_DB_OBJECT_NAME || ' TYPE: ' || L_DRIVER_DB_OBJECT_TYPE , 2 ) ;
            END IF;

            for fk_rec in C_FKCOLS (l_driver_appln_id, l_driver_db_object_name,
                                    l_validation_appln_id, l_validation_db_object_name, l_driver_db_object_type) loop

               l_vc_sql := l_vc_sql || '   AND a.' || fk_rec.uk_column_name || ' = '||p_global_record_name||'.' || fk_rec.fk_column_name  || OE_PC_GLOBALS.NEWLINE;
            end loop;

         else

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'L_DRIVER_ENTITY_FK_FLAG =N AND L_VALIDATION_TYPE =WF' , 2 ) ;
            END IF;

            -- l_driver_entity_fk_flag <> OE_PC_GLOBALS.YES_FLAG
            ---------------------------------------------------------------------
            -- 7. e.g. entity = HEADER; validation_entity = LINE (DIFFERENT)
            --         validation_type = 'WF' and
            --         validation_tmplt =  'Invoice Complete'
            --         record_set =  'Ship Set' OR LINE (doesn't matter)
            -- since you are navigating to another record using pk_values,
            -- the resulting record set will laways be multi record set
            -- the procedure body will look like
            --    -- assume that the condition will fail
            --    x_result := 0;
            --    l_valid_count := 0;
            --    l_set_count := 0;
            --
            --    SELECT count(*)
            --    INTO   l_valid_count
            --    FROM   wf_item_activity_statuses_v w
            --    WHERE  w.item_type = 'OEOL'
            --    AND    w.activity_name = 'INVOICE'
            --    AND    w.activity_status_code = 'COMPLETE'
            --    AND    w.activity_result_code = '#NULL'
            --    AND    w.item_key   IN
            --           (SELECT a.concatenated_itemkey_columns
            -- 	        FROM   oe_order_lines a,
            -- 	               oe_order_lines b
            --            WHERE  b.fk_columns = '||p_global_record_name||'.uk_column
            --            AND    a.record_set_selector_columns = b.record_set_selector_columns);
            --
            --    if (l_valid_count > 0 ) then
            --       if (scope = 'ALL') then
            --          SELECT count(*)
            --          into   l_set_count
            -- 	      FROM   oe_order_lines a,
            -- 	             oe_order_lines b
            --          WHERE  b.fk_columns = '||p_global_record_name||'.uk_column
            --          AND    a.record_set_selector_columns = b.record_set_selector_columns;
            --
            --          if (l_set_count = l_valid_count) then
            --             x_result = 1;
            --          end if;
            --       else
            --          x_result = 1;
            --       end if;
            --    end if;
            --    return;
            ---------------------------------------------------------------------

            Concatenate_Itemkey_Cols(p_prefix        => 'a'
	                            ,p_delimiter     => l_itemkey_delimiter
         	                      ,p_column1      => l_itemkey_column1
                                  ,p_column2      => l_itemkey_column2
                                  ,p_column3      => l_itemkey_column3
                                  ,p_column4      => l_itemkey_column4
                                  ,x_conc_string  => l_concatenated_itemkey_columns);

            -- (i) make the validation sql
            l_vc_sql := Concatenate_VTMPLTWF_SQL
                        (p_vc_sql => l_vc_sql
                        ,p_wf_item_type => l_wf_item_type
                        ,p_wf_activity_name => l_wf_activity_name
                        ,p_wf_activity_status_code => l_wf_activity_status_code
                        ,p_wf_activity_result_code =>  l_wf_activity_result_code
                        ,x_bind_var_stmt => x_bind_var_stmt
                        );

            l_vc_sql := l_vc_sql || '   AND   w.item_key IN '  || OE_PC_GLOBALS.NEWLINE;
            l_vc_sql := l_vc_sql || '          ( SELECT  '|| l_concatenated_itemkey_columns  || OE_PC_GLOBALS.NEWLINE;

            -- (ii) make the record set sql
            l_rs_sql :=             '   FROM ' || l_validation_db_object_name ||' a '  || OE_PC_GLOBALS.NEWLINE;
		  use_where := TRUE;
		  if l_pk_record_set_flag = 'N' then
               l_rs_sql := l_rs_sql ||'       ,' || l_validation_db_object_name ||' b '  || OE_PC_GLOBALS.NEWLINE;
		     i := 1;
               for rs_rec in C_RSCOLS loop
			 if (i=1) then
               	l_rs_sql := l_rs_sql || '                         WHERE   b.'
					|| rs_rec.column_name || ' =  a.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
				use_where := FALSE;
			 else
               	l_rs_sql := l_rs_sql || '                         AND   b.'
					|| rs_rec.column_name || ' =  a.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
			 end if;
			 i := i+1;
               end loop;
		  end if;

            -- (iii) add navigate to the validation tbl
            for fk_rec in C_FKCOLS (l_validation_appln_id, l_validation_db_object_name,
                 l_driver_appln_id, l_driver_db_object_name, l_driver_db_object_type )
		  loop
			if (use_where) then
              		l_rs_sql := l_rs_sql || '  WHERE   a.' || fk_rec.fk_column_name ||
					' =  '||p_global_record_name||'.' || fk_rec.uk_column_name  || OE_PC_GLOBALS.NEWLINE;
				use_where := FALSE;
			else
              		l_rs_sql := l_rs_sql || '  AND   a.' || fk_rec.fk_column_name ||
					' =  '||p_global_record_name||'.' || fk_rec.uk_column_name  || OE_PC_GLOBALS.NEWLINE;
		     end if;
            end loop;

            l_vc_sql := l_vc_sql || '                      ' || l_rs_sql  || OE_PC_GLOBALS.NEWLINE;
		  l_vc_sql := l_vc_sql || '                         )'|| OE_PC_GLOBALS.NEWLINE;

         end if;

      else

         -- l_validation_type <> OE_PC_GLOBALS.WF_VALIDATION
         -- validation type is database column validation

         if(l_driver_entity_fk_flag = 'Y') then
            --
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'L_DRIVER_ENTITY_FK_FLAG =Y AND L_VALIDATION_TYPE =COL' , 2 ) ;
            END IF;
            --
            ---------------------------------------------------------------------
            -- 9. e.g. for p_validation_type = 'COL' and
            --         entity <> validation_entity (DIFFERENT)
            --         entity = LINE, validation_entiy = HEADER
            --         validation_tmplt =  'Prorated Price Exists'
            --         record_set =  'Order'(doesn't matter)
            -- since you are navigating to another record based on a the fk_values,
            -- of the validating record identified using its pk_valuess,
            -- the resulting record set will always be one record (parent record)
            -- the procedure body will look like
            --    -- assume that the condition will fail
            --    x_result      := 0;
            --    l_valid_count := 0;
            --    l_set_count   := 0;
            --
            --    SELECT count(*)
            --    INTO   l_valid_count
            --    FROM   oe_order_headers a
            --    WHERE  a.uk_columns = '||p_global_record_name||'.fk_columns;
            --    AND    a.prorated_price = 'YES'
            --
            --    if (l_valid_count > 0 ) then
            --       x_result = 1;
            --    end if;
            --    return;
            ---------------------------------------------------------------------

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'VALIDATION OBJ: '||L_VALIDATION_DB_OBJECT_NAME , 2 ) ;
         END IF;

            -- make the validation sql
            l_vc_sql :=             '   FROM '|| l_validation_db_object_name  ||' a ' || OE_PC_GLOBALS.NEWLINE;


            -- add navigate to the validation tbl
	i:= 1;
	use_where := TRUE;
            for fk_rec in C_FKCOLS (l_driver_appln_id, l_driver_db_object_name,
                                l_validation_appln_id, l_validation_db_object_name, l_driver_db_object_type)loop
               if (use_where) then
                  -- where clause only for the first one
                  l_vc_sql  := l_vc_sql  || '   WHERE a.' || fk_rec.uk_column_name || ' =  '||p_global_record_name||'.' || fk_rec.fk_column_name  || OE_PC_GLOBALS.NEWLINE;
               else
                  l_vc_sql  := l_vc_sql  || '   AND   a.' || fk_rec.uk_column_name || ' =  '||p_global_record_name||'.' || fk_rec.fk_column_name  || OE_PC_GLOBALS.NEWLINE;
               end if;
               i := i + 1;
	       use_where := FALSE;

            end loop;

		  l_vc_sql := Concatenate_VTMPLTCOL_Sql(l_vc_sql
									, p_validation_tmplt_id
									, use_where);

         else
            ---------------------------------------------------------------------
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'DRIVER_ENTITY_FK_FLAG =N AND L_VALIDATION_TYPE =COL' , 2 ) ;
            END IF;

            -- 9. e.g. for p_validation_type = 'COL' and
            --         entity <> validation_entity (DIFFERENT)
            --         entity = HEADER, validation_entiy = LINE
            --         validation_tmplt =  'Prorated Price Exists'
            --         record_set =  'Ship Set' OR LINE (doesn't matter)
            -- since you are navigating to another record using pk_values,
            -- the resulting record set will laways be multi record set
            -- the procedure body will look like
            --    -- assume that the condition will fail
            --    x_result      := 0;
            --    l_valid_count := 0;
            --    l_set_count   := 0;
            --
            --    SELECT count(*)
            --    INTO   l_valid_count
            --    FROM   oe_order_lines a
            --    WHERE  a.prorated_price = 'YES'
            --    AND    a.pk_columns 	 IN
            --                      (SELECT b.pk_columns
            -- 	   	             FROM  oe_order_lines b,
            -- 			             oe_order_lines c
            --                       WHERE   c.fk_columns = '||p_global_record_name||'.uk_columns
            --	                   AND    b.record_set_selector_columns = c.record_set_selector_columns);
            --    if (l_valid_count > 0 ) then
            --       if (scope = 'ALL') then
            --          SELECT count(*)
            --          INTO l_set_count
            -- 	      FROM  oe_order_lines b,
            -- 	            oe_order_lines c,
            --          WHERE  c.fk_columns = '||p_global_record_name||'.uk_columns
            --	      AND    b.record_set_selector_columns = c.record_set_selector_columns
            --
            --          if (l_set_count = l_valid_count) then
            --             x_result = 1;
            --          end if;
            --       else
            --          x_result = 1;
            --       end if;
            --    end if;
            --    return;
            ---------------------------------------------------------------------

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'VALIDATION OBJ NAME: '||L_VALIDATION_DB_OBJECT_NAME , 2 ) ;
            END IF;

            -- first let's make the record set sql
            l_rs_sql :=             '   FROM ' || l_validation_db_object_name ||' a '  || OE_PC_GLOBALS.NEWLINE;

		  if l_pk_record_set_flag = 'N' then
               l_rs_sql := l_rs_sql ||'       ,' || l_validation_db_object_name ||' b '  || OE_PC_GLOBALS.NEWLINE;
		  end if;

		  use_where := TRUE;
            -- add navigate to the validation tbl
            i := 1;
            for fk_rec in C_FKCOLS (l_validation_appln_id, l_validation_db_object_name,
                                    l_driver_appln_id, l_driver_db_object_name, l_driver_db_object_type )loop
               if (i = 1) then
                  l_ve_condn_sql := '  WHERE   a.' || fk_rec.fk_column_name ||
					' =  '||p_global_record_name||'.' || fk_rec.uk_column_name  || OE_PC_GLOBALS.NEWLINE;
			   use_where := FALSE;
               else
                  l_ve_condn_sql := l_ve_condn_sql || '   AND   a.' || fk_rec.fk_column_name ||
					' =  '||p_global_record_name||'.' || fk_rec.uk_column_name  || OE_PC_GLOBALS.NEWLINE;
               end if;
               i := i + 1;
            end loop;
		  l_rs_sql := l_rs_sql || l_ve_condn_sql;

            -- make the validation sql
            l_vc_sql := '   FROM ' || l_validation_db_object_name ||' a '  || OE_PC_GLOBALS.NEWLINE;
		  l_vc_sql := l_vc_sql || l_ve_condn_sql;
		  l_vc_sql := Concatenate_VTMPLTCOL_Sql(l_vc_sql
								, p_validation_tmplt_id
								, use_where);

            -- add logic to get to the intented record
            i := 1;
            for pk_rec in C_PKCOLS (l_validation_appln_id, l_validation_db_object_name
					, l_validation_db_object_type) loop

               if (i = 1) then
                  l_rs_pk_list := ' b.' || pk_rec.pk_column_name;
                  l_vc_pk_list := ' a.' || pk_rec.pk_column_name;
               else
                  l_rs_pk_list := l_rs_pk_list || ', b.'|| pk_rec.pk_column_name;
                  l_vc_pk_list := l_vc_pk_list || ', a.'|| pk_rec.pk_column_name;
               end if;
               i := i + 1;
            end loop;

		if l_pk_record_set_flag = 'N' then
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  'NOT PK RECORD SET' ) ;
		  END IF;
            -- add logic to select the record set
		  l_vc_sql := l_vc_sql || '   AND ('||l_vc_pk_list||') IN ( SELECT '||
						l_rs_pk_list|| OE_PC_GLOBALS.NEWLINE;
		  l_vc_sql := l_vc_sql || '                         FROM '||
						l_validation_db_object_name||' b'||OE_PC_GLOBALS.NEWLINE;
		  i := 1;
            for rs_rec in C_RSCOLS loop
			if (i=1) then
               l_vc_sql := l_vc_sql || '                         WHERE   b.'
					|| rs_rec.column_name || ' =  a.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
			else
               l_vc_sql := l_vc_sql || '                         AND   b.'
					|| rs_rec.column_name || ' =  a.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
			end if;
               l_rs_sql := l_rs_sql || '     AND   b.'
					|| rs_rec.column_name || ' =  a.' || rs_rec.column_name  || OE_PC_GLOBALS.NEWLINE;
			i := i+1;
            end loop;
			l_vc_sql := l_vc_sql || '                         )'
					|| OE_PC_GLOBALS.NEWLINE;
		end if;

         end if;
      end if;
   end if;

   IF (l_condn_logic_only) THEN
      x_validation_stmt := l_vc_sql;
   ELSE
      x_valid_count_cursor := '   CURSOR C_VC  IS ' || OE_PC_GLOBALS.NEWLINE ||
				'   SELECT count(*) ' || OE_PC_GLOBALS.NEWLINE || l_vc_sql || ';';
   END IF;

   IF l_rs_sql is not null THEN
      x_set_count_cursor   := '   CURSOR C_RSC IS ' || OE_PC_GLOBALS.NEWLINE ||
				'   SELECT count(*) ' || OE_PC_GLOBALS.NEWLINE || l_rs_sql || ';';
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'VALID COUNT CURSOR: '||X_VALID_COUNT_CURSOR , 2 ) ;
       oe_debug_pub.add(  'VALIDATION STMT: '||X_VALIDATION_STMT ) ;
       oe_debug_pub.add(  'SET COUNT CURSOR: '||X_SET_COUNT_CURSOR ) ;
       oe_debug_pub.add(  'BIND VAR STMT :'||X_BIND_VAR_STMT);
       oe_debug_pub.add(  'RETURNING FROM MAKE_VALIDATION_CURSORS' , 2 ) ;
   END IF;

End  Make_Validation_Cursors;

-----------------------------------
PROCEDURE Make_Control_Tbl_Sql(
   p_entity_id              in  number,
   p_validation_entity_id   in  number,
   p_validation_tmplt_id    in  number,
   p_record_set_id          in  number,
   p_pkg_name               in  varchar2,
   p_proc_name              in  varchar2,
x_control_tbl_sql out nocopy varchar2

)
IS

  CURSOR C IS
  SELECT 'Y'
  FROM  OE_PC_VALIDATION_PKGS
  WHERE validating_entity_id  = p_entity_id
  AND   validation_entity_id  = p_validation_entity_id
  AND   validation_tmplt_id   = p_validation_tmplt_id
  AND   record_set_id         = p_record_set_id;

  l_update  varchar2(1) := 'N';
  l_sql     varchar2(2000);
  COMMA     varchar2(1) := ',';
  Q         varchar2(1) := '''';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

  OPEN C;
  Fetch C into l_update;
  Close C;

  -- BUG 2935346
  -- Use bind variables instead of literals. The only exception is p_proc_name
  -- in the INSERT sql as this is always set to one value - 'Is_Valid' and thus
  -- is equivalent to hardcoding a string. Also, this sql is executed from
  -- OEXPCRQB.pls which does not have visibility to p_proc_name value.

  if (l_update = 'Y') then
     -- make update statement
     l_sql  := 'UPDATE OE_PC_VALIDATION_PKGS SET last_update_date = sysdate ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || ' WHERE validating_entity_id = :b1 '||OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || ' AND   validation_entity_id = :b2 '||OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || ' AND   validation_tmplt_id = :b3 '||OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || ' AND   record_set_id = :b4 '||OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || ' AND   EXISTS (SELECT 1 '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '               FROM USER_OBJECTS u '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '               WHERE OBJECT_NAME = :b5 '||OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '               AND   OBJECT_TYPE = '|| Q || 'PACKAGE BODY'|| Q || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '               AND   STATUS      = '|| Q || 'VALID'|| Q || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '              ) ' || OE_PC_GLOBALS.NEWLINE;


  else
     -- make insert statement
     l_sql  := l_sql || 'INSERT INTO OE_PC_VALIDATION_PKGS ';
     l_sql  := l_sql || '( ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  validating_entity_id ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,validation_entity_id ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,validation_tmplt_id ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,record_set_id ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,validation_pkg ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,validation_proc ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,created_by ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,creation_date ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,last_updated_by ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,last_update_date ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '  ,last_update_login ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || ') ' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || 'SELECT '  || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || ' :b1 '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   COMMA ||' :b2 '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   COMMA ||' :b3 '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   COMMA ||' :b4 '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   COMMA ||' :b5 '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   COMMA || Q || p_proc_name || Q || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   ',1'  || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   ',sysdate'  || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   ',1'  || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   ',sysdate'  || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql ||   ',1'  || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || 'FROM SYS.DUAL' || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || 'WHERE EXISTS (SELECT ''EXISTS'''|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '               FROM USER_OBJECTS u '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '               WHERE u.OBJECT_NAME = :b5 '|| OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '               AND   u.OBJECT_TYPE = '|| Q || 'PACKAGE BODY'|| Q || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '               AND   u.STATUS      = '|| Q || 'VALID'|| Q || OE_PC_GLOBALS.NEWLINE;
     l_sql  := l_sql || '              ) ' || OE_PC_GLOBALS.NEWLINE;

  end if;
  x_control_tbl_sql := l_sql;
End Make_Control_Tbl_Sql;


--------------------------------
PROCEDURE Make_Validation_Pkg
(
   p_entity_id                      in number,
   p_entity_short_name              in varchar2,
   p_db_object_name                 in varchar2,
   p_validation_entity_id           in number,
   p_validation_entity_short_name   in varchar2,
   p_validation_db_object_name      in varchar2,
   p_validation_tmplt_id            in number,
   p_validation_tmplt_short_name    in varchar2,
   p_record_set_id                  in number,
   p_record_set_short_name          in varchar2,
   p_global_record_name             in varchar2,
x_pkg_name out nocopy varchar2,

x_pkg_spec out nocopy long,

x_pkg_body out nocopy long,

x_control_tbl_sql out nocopy varchar2,

x_return_status out nocopy varchar2,

x_msg_data out nocopy varchar2,

x_msg_count out nocopy number

)
IS
  l_pkg_name		varchar2(30);
  l_pkg_spec		LONG;
  l_pkg_body 		LONG;
  l_pkg_end	 		VARCHAR2(40);
  l_proc_name	     	VARCHAR2(30);
  l_proc_spec 		VARCHAR2(2000);
  l_control_tbl_sql    varchar2(2000);

  l_valid_count_cursor  long;
  l_set_count_cursor    long;
  l_validation_stmt     long;
  -- Bug 3739681
  l_bind_var_stmt       long;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   --
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' ' , 2 ) ;
       oe_debug_pub.add(  'BEING : MAKE_VALIDATION_PKG' , 2 ) ;
       oe_debug_pub.add(  'VALIDATION TMPLT = ' || P_VALIDATION_TMPLT_ID , 2 ) ;
       oe_debug_pub.add(  'RECORD SET = ' || P_RECORD_SET_ID , 2 ) ;
   END IF;
   --

   -- the package name
   -- example : OE_101PC100_HEADER_BOOKED
   l_pkg_name := 'OE_' || to_char(p_entity_id) || 'PC' ||
                       to_char(p_validation_entity_id) || '_' ||
                       p_record_set_short_name || '_' ||
                       p_validation_tmplt_short_name;

   l_pkg_spec := 'CREATE OR REPLACE PACKAGE ' || l_pkg_name || ' AS '  || OE_PC_GLOBALS.NEWLINE;
   l_pkg_body := 'CREATE OR REPLACE PACKAGE BODY ' || l_pkg_name || ' AS '  || OE_PC_GLOBALS.NEWLINE;
   l_pkg_end    := 'END ' || l_pkg_name || ';'  || OE_PC_GLOBALS.NEWLINE;


   l_proc_name := 'Is_Valid';
   l_proc_spec := ' PROCEDURE ' || l_proc_name   || OE_PC_GLOBALS.NEWLINE;
   l_proc_spec := l_proc_spec || ' ( '  || OE_PC_GLOBALS.NEWLINE;
   l_proc_spec := l_proc_spec || '   p_application_id        in    number,'   || OE_PC_GLOBALS.NEWLINE;
   l_proc_spec := l_proc_spec || '   p_entity_short_name     in    varchar2,' || OE_PC_GLOBALS.NEWLINE;
   l_proc_spec := l_proc_spec || '   p_validation_entity_short_name in varchar2, ' || OE_PC_GLOBALS.NEWLINE;
   l_proc_spec := l_proc_spec || '   p_validation_tmplt_short_name  in varchar2,' || OE_PC_GLOBALS.NEWLINE;
   l_proc_spec := l_proc_spec || '   p_record_set_short_name        in varchar2,' || OE_PC_GLOBALS.NEWLINE;
   l_proc_spec := l_proc_spec || '   p_scope                        in varchar2,' || OE_PC_GLOBALS.NEWLINE;
l_proc_spec := l_proc_spec || ' x_result out nocopy number' || OE_PC_GLOBALS.NEWLINE;

   l_proc_spec := l_proc_spec || '  )';

   -- add a ; to end the PROCEDURE specs
   l_pkg_spec := l_pkg_spec || l_proc_spec || ';' || OE_PC_GLOBALS.NEWLINE;


   -- continue building procedure body
   l_pkg_body := l_pkg_body || l_proc_spec  || OE_PC_GLOBALS.NEWLINE || ' IS '  || OE_PC_GLOBALS.NEWLINE;
   -- declare local variables
   l_pkg_body := l_pkg_body || '   l_valid_count NUMBER := 0; '  || OE_PC_GLOBALS.NEWLINE;
   l_pkg_body := l_pkg_body || '   l_set_count   NUMBER := 0; '  || OE_PC_GLOBALS.NEWLINE;

   -- construct the cursor for validating the conditions as well as to count the number of
   -- records in the validated record set
   --------------------------------------------------------------------------------------
   Make_Validation_Cursors (p_entity_id             => p_entity_id
                            ,p_validation_entity_id => p_validation_entity_id
                            ,p_validation_tmplt_id => p_validation_tmplt_id
                            ,p_record_set_id       => p_record_set_id
                            ,p_global_record_name  => p_global_record_name
                            ,x_valid_count_cursor  => l_valid_count_cursor
                            ,x_set_count_cursor    => l_set_count_cursor
                            ,x_validation_stmt     => l_validation_stmt
                            -- Bug 3739681
                            ,x_bind_var_stmt       => l_bind_var_stmt
                            );
   --
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'MAKE_VALIDATION_CURSORS COMPLETE' , 2 ) ;
   END IF;
   --

   l_pkg_body := l_pkg_body || ' ' || OE_PC_GLOBALS.NEWLINE;
   -- Bug 3739681
   IF l_bind_var_stmt IS NOT NULL THEN
     l_pkg_body := l_pkg_body || l_bind_var_stmt  || OE_PC_GLOBALS.NEWLINE;
   END IF;
   IF l_valid_count_cursor IS NOT NULL THEN
     l_pkg_body := l_pkg_body || l_valid_count_cursor  || OE_PC_GLOBALS.NEWLINE;
   END IF;
   l_pkg_body := l_pkg_body || ' '  || OE_PC_GLOBALS.NEWLINE;
   l_pkg_body := l_pkg_body || l_set_count_cursor  || OE_PC_GLOBALS.NEWLINE;
   l_pkg_body := l_pkg_body || ' '  || OE_PC_GLOBALS.NEWLINE;

   l_pkg_body := l_pkg_body || 'BEGIN '  || OE_PC_GLOBALS.NEWLINE;

   -- now add the procedure logic

   -- first let's assume that the validation will be false
   l_pkg_body := l_pkg_body || '   x_result := 0; '  || OE_PC_GLOBALS.NEWLINE;

   -- execute the validation cursor or the validation statement
   IF l_valid_count_cursor IS NOT NULL THEN
     l_pkg_body := l_pkg_body || '   OPEN C_VC; '  || OE_PC_GLOBALS.NEWLINE;
     l_pkg_body := l_pkg_body || '   FETCH C_VC into l_valid_count; '  || OE_PC_GLOBALS.NEWLINE;
     l_pkg_body := l_pkg_body || '   CLOSE C_VC; '  || OE_PC_GLOBALS.NEWLINE;
   ELSIF l_validation_stmt IS NOT NULL THEN
	l_pkg_body := l_pkg_body || l_validation_stmt;
     l_pkg_body := l_pkg_body || '  THEN ' || OE_PC_GLOBALS.NEWLINE;
     l_pkg_body := l_pkg_body || '  l_valid_count := 1; '|| OE_PC_GLOBALS.NEWLINE;
	l_pkg_body := l_pkg_body || '  END IF;' || OE_PC_GLOBALS.NEWLINE;
   END IF;

   l_pkg_body := l_pkg_body || '   If (l_valid_count > 0)  then '  || OE_PC_GLOBALS.NEWLINE;
   if (l_set_count_cursor  is not null) then
      l_pkg_body := l_pkg_body || '      If (p_scope = ' || ''''|| 'ALL' ||'''' || ')  then '  || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '         OPEN C_RSC; '  || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '         FETCH C_RSC into l_set_count; '  || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '         CLOSE C_RSC; ' || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '         If (l_valid_count = l_set_count) then '  || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '            x_result := 1; '  || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '         End If; '  || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '      Else '  || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '         x_result := 1; '  || OE_PC_GLOBALS.NEWLINE;
      l_pkg_body := l_pkg_body || '      End If; '  || OE_PC_GLOBALS.NEWLINE;
   else
      l_pkg_body := l_pkg_body || '      x_result := 1; '  || OE_PC_GLOBALS.NEWLINE;
   end if;
   l_pkg_body := l_pkg_body || '   End If; '  || OE_PC_GLOBALS.NEWLINE;
   l_pkg_body := l_pkg_body || '   Return; '  || OE_PC_GLOBALS.NEWLINE;
   l_pkg_body := l_pkg_body || 'END ' || l_proc_name || ';' || OE_PC_GLOBALS.NEWLINE;

   l_pkg_spec := l_pkg_spec || OE_PC_GLOBALS.NEWLINE || l_pkg_end  || OE_PC_GLOBALS.NEWLINE;
   l_pkg_body := l_pkg_body || OE_PC_GLOBALS.NEWLINE || l_pkg_end  || OE_PC_GLOBALS.NEWLINE;

   -- create the SQL to insert/update a record into OE_PC_VALIDATION_PKGS to timestamp the
   -- generated Package.
   --------------------------------------------------------------------------------------
   Make_Control_Tbl_Sql( p_entity_id               => p_entity_id
                         ,p_validation_entity_id   => p_validation_entity_id
                         ,p_validation_tmplt_id    => p_validation_tmplt_id
                         ,p_record_set_id          => p_record_set_id
                         ,p_pkg_name               => l_pkg_name
                         ,p_proc_name              => l_proc_name
                         ,x_control_tbl_sql        => l_control_tbl_sql);

   x_pkg_spec := l_pkg_spec;
   x_pkg_body := l_pkg_body;
   x_pkg_name := l_pkg_name;
   x_control_tbl_sql := l_control_tbl_sql;
   x_return_status  := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
   x_return_status  := fnd_api.G_RET_STS_ERROR;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXCEPTION IN MAKE_VALIDATION_PKG' ) ;
   END IF;


END Make_Validation_Pkg;
-------------------------------------

PROCEDURE Add_To_Check_On_Insert_Cache
(p_entity_id                  IN NUMBER
,p_responsibility_id          IN NUMBER
,p_application_id             IN NUMBER    --added for bug3631547
)
IS
l_index          PLS_INTEGER;  -- for bug 6473618    NUMBER;

    TYPE T_NUM is TABLE OF NUMBER;
    TYPE T_V1 is TABLE OF VARCHAR2(1);
    TYPE T_V30 is TABLE OF VARCHAR2(30);

    t_constraint_ids T_NUM := T_NUM();
    t_entity_ids T_NUM := T_NUM();
    t_on_operation_actions T_NUM := T_NUM();
    t_column_names T_V30 := T_V30();

    CURSOR C_CHECK_ON_INSERT_OP
    IS
    SELECT
      c.constraint_id, c.entity_id
      ,c.on_operation_action, c.column_name
     FROM  oe_pc_constraints c
     WHERE   c.entity_id     = P_ENTITY_ID
	  AND   c.constrained_operation = OE_PC_GLOBALS.UPDATE_OP
	  AND   c.check_on_insert_flag = 'Y'
          AND   nvl(c.enabled_flag, 'Y') = 'Y'
       AND EXISTS (
	    SELECT 'EXISTS'
	    FROM OE_PC_ASSIGNMENTS A
	    WHERE a.constraint_id = c.constraint_id
              AND ( a.responsibility_id = p_responsibility_id
		    OR a.responsibility_id IS NULL)
              AND ( a.application_id = p_application_id
                    OR a.application_id IS NULL )
	      AND NOT EXISTS (
            	SELECT 'EXISTS'
            	FROM OE_PC_EXCLUSIONS e
            	WHERE e.responsibility_id = p_responsibility_id
            	AND   e.assignment_id     = a.assignment_id
                AND   e.application_id    = p_application_id
            	)
	    )
     ORDER BY c.column_name, c.on_operation_action;
     --
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     --
BEGIN

    l_index := (p_entity_id)*G_MAX_CONSTRAINTS + 1;
    IF G_Check_On_Insert_Cache.EXISTS(l_index) THEN
	  RETURN;
    END IF;

    OPEN c_check_on_insert_op;
    FETCH c_check_on_insert_op BULK COLLECT INTO t_constraint_ids,
                               t_entity_ids,
                               t_on_operation_actions,
                               t_column_names;
    CLOSE c_check_on_insert_op;

    FOR i IN 1..t_constraint_ids.count LOOP
				    IF l_debug_level  > 0 THEN
				        oe_debug_pub.add(  'CHECK ON INSERT-ADDTOCACHE , COLUMN:' ||T_COLUMN_NAMES(i) ) ;
				    END IF;
	  G_Check_On_Insert_Cache(l_index).entity_id := p_entity_id;
	  G_Check_On_Insert_Cache(l_index).column_name := t_column_names(i);
	  G_Check_On_Insert_Cache(l_index).constraint_id := t_constraint_ids(i);
	  G_Check_On_Insert_Cache(l_index).on_operation_action := t_on_operation_actions(i);
	  l_index := l_index + 1;
    END LOOP;

    IF l_index = (p_entity_id)*G_MAX_CONSTRAINTS + 1 THEN
	  G_Check_On_Insert_Cache(l_index).column_name := FND_API.G_MISS_CHAR;
    END IF;

END Add_To_Check_On_Insert_Cache;

FUNCTION Check_On_Insert_Exists
(p_entity_id                  IN NUMBER
,p_responsibility_id          IN NUMBER
,p_application_id             IN NUMBER   --added for bug3631547
)
RETURN BOOLEAN IS
l_index        PLS_INTEGER;  -- for bug 6473618      NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_index := (p_entity_id)*G_MAX_CONSTRAINTS + 1;

    Add_To_Check_On_Insert_Cache(p_entity_id => p_entity_id
				 ,p_responsibility_id => p_responsibility_id
                                 ,p_application_id => p_application_id);

    IF G_Check_On_Insert_Cache(l_index).column_name <> FND_API.G_MISS_CHAR THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Check_On_Insert_Exists'
        );
       END IF;
       RAISE;
END Check_On_Insert_Exists;

PROCEDURE Add_To_ConstraintRuleTbl
( p_constraint_id           IN NUMBER    )
IS

 --Cursors
 CURSOR C_R
 IS SELECT
	  c.application_id,
	  c.entity_short_name,
       c.condition_id,
       c.group_number,
       c.modifier_flag,
       c.validation_application_id,
       c.validation_entity_short_name,
       c.validation_tmplt_short_name,
       c.record_set_short_name,
       c.scope_op,
       c.validation_pkg,
       c.validation_proc,
	  c.validation_tmplt_id,
	  c.record_set_id,
	  c.entity_id,
	  c.validation_entity_id
 FROM  oe_pc_conditions_v c
 WHERE constraint_id = p_constraint_id
   AND nvl(enabled_flag, 'Y') = 'Y'
 ORDER BY c.group_number;

l_index           PLS_INTEGER;  -- for bug 6473618          NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   l_index := (mod(p_constraint_id,100000) * G_MAX_CONDITIONS) + 1; --added mod for bug 3603559

   OPEN C_R;

   LOOP

      FETCH C_R INTO
		  	g_constraintRuleTbl(l_index).application_id,
		  	g_constraintRuleTbl(l_index).entity_short_name,
		  	g_constraintRuleTbl(l_index).condition_id,
		  	g_constraintRuleTbl(l_index).group_number,
		  	g_constraintRuleTbl(l_index).modifier_flag,
		  	g_constraintRuleTbl(l_index).validation_application_id,
		  	g_constraintRuleTbl(l_index).validation_entity_short_name,
		  	g_constraintRuleTbl(l_index).validation_tmplt_short_name,
		  	g_constraintRuleTbl(l_index).record_set_short_name,
		  	g_constraintRuleTbl(l_index).scope_op,
		  	g_constraintRuleTbl(l_index).validation_pkg,
		  	g_constraintRuleTbl(l_index).validation_proc,
		  	g_constraintRuleTbl(l_index).validation_tmplt_id,
		  	g_constraintRuleTbl(l_index).record_set_id,
		  	g_constraintRuleTbl(l_index).entity_id,
			g_constraintRuleTbl(l_index).validation_entity_id;

      IF (C_R%NOTFOUND) THEN
        IF l_index =((mod(p_constraint_id ,100000) * G_MAX_CONDITIONS) + 1) THEN   --added mod for bug 3603559
           g_constraintRuleTbl(l_index).condition_id := -1;
        END IF;
        EXIT;
      END IF;

      l_index := l_index + 1;

    END LOOP;

    CLOSE C_R;

END Add_To_ConstraintRuleTbl;

FUNCTION Get_Cached_Result
 (
    p_validation_tmplt_id                in  number
   ,p_record_set_id                      in  number
   ,p_validation_entity_id               in  number
   ,p_entity_id                          in  number
   ,p_scope_op                           in  varchar2
 )
RETURN NUMBER
IS
l_index              PLS_INTEGER;  -- for bug 6473618    NUMBER;
l_result                 NUMBER := -1;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   l_index := (p_validation_tmplt_id*G_MAX_CONDITIONS) + 1;

   WHILE G_Result_Cache.Exists(l_index) LOOP

       IF G_Result_Cache(l_index).validation_tmplt_id = p_validation_tmplt_id
          AND G_Result_Cache(l_index).record_set_id = p_record_set_id
          AND G_Result_Cache(l_index).validation_entity_id = p_validation_entity_id
          AND G_Result_Cache(l_index).entity_id = p_entity_id
          AND G_Result_Cache(l_index).scope_op = p_scope_op
       THEN
          l_result := G_Result_Cache(l_index).result;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALIDATION TMPLT :'||P_VALIDATION_TMPLT_ID ||' CACHED RESULT :'||L_RESULT , 5 ) ;
          END IF;
          EXIT;
       END IF;

       -- Bug 2312542: Code to increment the index counter was missing earlier.
       -- If result for same validation template is cached multiple times
       -- for different entities e.g. Order Closed template result is cached
       -- for Order Line and Order Sales Credit, then get_cached_result
       -- was going into an infinite loop causing the session to hang.
       l_index := l_index + 1;

   END LOOP;

   RETURN l_result;

END Get_Cached_Result;

PROCEDURE Add_Result_To_Cache
 (
    p_validation_tmplt_id                in  number
   ,p_record_set_id                      in  number
   ,p_validation_entity_id               in  number
   ,p_entity_id                          in  number
   ,p_scope_op                           in  varchar2
   ,p_result                             in  number
 )
IS
l_index           PLS_INTEGER;  -- for bug 6473618       NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   l_index := (p_validation_tmplt_id*G_MAX_CONDITIONS) + 1;

   WHILE G_Result_Cache.Exists(l_index) LOOP
     l_index := l_index + 1;
   END LOOP;

   G_Result_Cache(l_index).validation_tmplt_id := p_validation_tmplt_id;
   G_Result_Cache(l_index).record_set_id := p_record_set_id;
   G_Result_Cache(l_index).validation_entity_id := p_validation_entity_id;
   G_Result_Cache(l_index).entity_id := p_entity_id;
   G_Result_Cache(l_index).scope_op := p_scope_op;
   G_Result_Cache(l_index).result := p_result;

END Add_Result_To_Cache;

-- Bug 1755817: procedure to clear cached results
-- if validation_entity_id is passed, only results with that
-- validation_entity are cleared else entire cache is cleared
--------------------------------------------------------------
PROCEDURE Clear_Cached_Results
--------------------------------------------------------------
 (
   p_validation_entity_id        in number
  )
IS
l_index               BINARY_INTEGER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF p_validation_entity_id IS NULL THEN

      G_Result_Cache.DELETE;

   ELSE

      l_index := G_Result_Cache.FIRST;

      WHILE G_Result_Cache.Exists(l_index) LOOP

        IF G_Result_Cache(l_index).validation_entity_id
           = p_validation_entity_id THEN
           G_Result_Cache.DELETE(l_index);
        END IF;

        l_index := G_Result_Cache.NEXT(l_index);

      END LOOP;

   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Clear_Cached_Results'
        );
       END IF;
       RAISE;
END Clear_Cached_Results;

-------------------------------------
PROCEDURE Validate_Constraint
 (
    p_constraint_id                in  number
   ,p_use_cached_results             in  varchar2
,x_condition_count out nocopy number

,x_valid_condition_group out nocopy number

,x_result out nocopy number

 )
 IS

 l_constraintRuleRec  ConstraintRule_Rec_Type;
 l_dsqlCursor		  integer;
 l_dynamicSqlString	  varchar2(2000);
 l_rule_count	        number;
 l_ConstrainedStatus  number;
 l_dummy              integer;
 i                    number;
 l_tempResult         boolean;
 l_result_01          number;
 l_currGrpNumber      number;
 l_currGrpResult      boolean;
 l_index              PLS_INTEGER;  -- for bug 6473618 number;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CONSTRAINT ID:'||P_CONSTRAINT_ID , 5 ) ;
   END IF;

   l_ConstrainedStatus := OE_PC_GLOBALS.NO;
   l_rule_count := 0;
   i := 0;
   l_currGrpNumber := -1;
   l_currGrpResult := FALSE;

   -----------------------------------------------------
   -- Bug 1755817: USE CACHING TO IMPROVE PERFORMANCE
   -----------------------------------------------------

   l_index := (mod(p_constraint_id ,100000)* G_MAX_CONDITIONS) + 1;

   -- Cache the conditions for this constraint
   IF (NOT g_constraintRuleTbl.Exists(l_index)) THEN
	 Add_To_ConstraintRuleTbl(p_constraint_id);
   END IF;

   -- If there are no conditions associated with this constraint,
   -- return result of YES - constraint valid
   IF g_constraintRuleTbl(l_index).condition_id = -1 THEN
	 GOTO RETURN_VALIDATION_RESULT;
   END IF;

   -- Else loop through the conditions and validate all tthe
   -- constraints
   WHILE g_constraintRuleTbl.Exists(l_index) LOOP

      l_constraintRuleRec := g_constraintRuleTbl(l_index);

      IF (l_currGrpNumber <> l_constraintRuleRec.group_number) THEN

         -- we are entering the new group of conditions..
         -- groups are ORd together, so if the previous group was evaluated
         -- to TRUE (OE_PC_GLOBALS.YES) then no need to evaluvate this group.
         IF (l_currGrpResult = TRUE) THEN
            l_ConstrainedStatus := OE_PC_GLOBALS.YES;
            EXIT;  -- exit the loop
         END IF;

         -- previous group did not evaluvate to TRUE, so lets pursue this new group
         l_currGrpNumber := l_constraintRuleRec.group_number;
         l_currGrpResult := FALSE;
         i := 0;

      END IF;

      -- we have a got a record, increment the count by 1
      l_rule_count := l_rule_count+1;

      -- If validation entity <> constrained entity AND
      -- user has indicated that cached results should be used
      --, then check for the cached result
      -- It is not safe to use cached results if validation_entity =
      -- constrained entity as the entity's record picture may
      -- change during the checks e.g. by defaulting
      IF ( p_use_cached_results = 'Y'
		 AND (l_constraintRuleRec.validation_entity_id
			 <> l_constraintRuleRec.entity_id) ) THEN

	     l_result_01 := Get_Cached_Result
					(p_validation_tmplt_id => l_constraintRuleRec.validation_tmplt_id
					,p_record_set_id => l_constraintRuleRec.record_set_id
					,p_entity_id => l_constraintRuleRec.entity_id
					,p_validation_entity_id => l_constraintRuleRec.validation_entity_id
					,p_scope_op => l_constraintRuleRec.scope_op
					);

          -- if result is not -1, then result was cached!
          IF l_result_01 <> -1 THEN
		   GOTO CHECK_GROUP_RESULT;
          END IF;

      END IF;

      -- Execute the validation package for this condition
      -- pkg.function(p1, p2, ...)
      l_dynamicSqlString := ' begin ';
      l_dynamicSqlString := l_dynamicSqlString || l_constraintRuleRec.validation_pkg ||'.';
      l_dynamicSqlString := l_dynamicSqlString || l_constraintRuleRec.validation_proc;

      -- IN Parameters
      l_dynamicSqlString := l_dynamicSqlString || '( ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_application_id, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_entity_short_name, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_validation_entity_short_name, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_validation_tmplt_short_name, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_record_set_short_name, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_scope, ';

      -- OUT Parameters
      l_dynamicSqlString := l_dynamicSqlString || ':t_result );';
      l_dynamicSqlString := l_dynamicSqlString || ' end; ';

      -- EXECUTE THE DYNAMIC SQL
	 EXECUTE IMMEDIATE l_dynamicSqlString USING IN l_constraintRuleRec.application_id,
                   IN l_constraintRuleRec.entity_short_name,
                   IN l_constraintRuleRec.validation_entity_short_name,
                   IN l_constraintRuleRec.validation_tmplt_short_name,
                   IN l_constraintRuleRec.record_set_short_name,
                   IN l_constraintRuleRec.scope_op,
                   OUT l_result_01;

                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'VALIDATION PKG :'||L_CONSTRAINTRULEREC.VALIDATION_PKG ||' RESULT :'||L_RESULT_01 ) ;
                       END IF;

      IF (p_use_cached_results = 'Y'
		 AND (l_constraintRuleRec.validation_entity_id
			 <> l_constraintRuleRec.entity_id) ) THEN

	     Add_Result_To_Cache
		(p_validation_tmplt_id => l_constraintRuleRec.validation_tmplt_id
		,p_record_set_id => l_constraintRuleRec.record_set_id
		,p_entity_id => l_constraintRuleRec.entity_id
		,p_validation_entity_id => l_constraintRuleRec.validation_entity_id
		,p_scope_op => l_constraintRuleRec.scope_op
		,p_result => l_result_01
		);

      END IF;

      <<CHECK_GROUP_RESULT>>
      IF (l_result_01 = 0) THEN
         l_tempResult := FALSE;
      ELSE
         l_tempResult := TRUE;
      END IF;

      -- apply the modifier on the result
      if(l_constraintRuleRec.modifier_flag = OE_PC_GLOBALS.YES_FLAG) then
         l_tempResult := NOT(l_tempResult);
      end if;

      IF (i = 0) THEN
         l_currGrpResult := l_tempResult;
      ELSE
         l_currGrpResult := l_currGrpResult AND l_tempResult;
      END IF;

      -- increment the index
      i := i+1;
      l_index := l_index + 1;

   END LOOP;  -- end validatate validators

   IF (l_currGrpNumber <> -1 AND l_currGrpResult = TRUE) THEN
       l_ConstrainedStatus := OE_PC_GLOBALS.YES;
   END IF;

   <<RETURN_VALIDATION_RESULT>>
   -- did we validate any constraint rules?. if there is none then the
   -- constraint is valid and we will return YES
   IF (l_rule_count = 0) THEN
      x_condition_count := 0;
      x_valid_condition_group := -1;
      x_result    := OE_PC_GLOBALS.YES;
   ELSE
      x_condition_count := l_rule_count;
      x_valid_condition_group := l_currGrpNumber;
      x_result    := l_ConstrainedStatus;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       x_result := OE_PC_GLOBALS.ERROR;
    	  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Validate_Constraint : '||l_constraintRuleRec.validation_pkg
        );
       END IF;
END Validate_Constraint;
-------------------------------------------

FUNCTION Is_Op_Constrained
 (
   p_responsibility_id             in number
   ,p_application_id               in number   --added for bug3631547
   ,p_operation                    in varchar2
   ,p_entity_id			   in number
   ,p_qualifier_attribute          in varchar2
   ,p_column_name                  in varchar2
   ,p_check_all_cols_constraint    in varchar2
   ,p_is_caller_defaulting         in varchar2
   ,p_use_cached_results             in varchar2
,x_constraint_id out nocopy number

,x_constraining_conditions_grp out nocopy number

,x_on_operation_action out nocopy number

 )
RETURN NUMBER
IS

 -- Local Variables
    l_validation_result   	number;
    l_condition_count     	number;
    l_valid_condition_group   	number;
    l_db_object_name			varchar2(30);

    TYPE T_NUM is TABLE OF NUMBER;
    TYPE T_V1 is TABLE OF VARCHAR2(1);
    TYPE T_V30 is TABLE OF VARCHAR2(30);

    t_constraint_ids T_NUM := T_NUM();
    t_entity_ids T_NUM := T_NUM();
    t_on_operation_actions T_NUM := T_NUM();
    t_column_names T_V30 := T_V30();

 -- Cursor to select all constraints for the CREATE operation
    CURSOR C_CREATE_OP
    IS
    SELECT
      c.constraint_id, c.entity_id
      ,c.on_operation_action, c.column_name
     FROM  oe_pc_constraints c
     WHERE   c.entity_id     = P_ENTITY_ID
     AND     c.constrained_operation = OE_PC_GLOBALS.CREATE_OP
     AND   EXISTS (
	    SELECT 'EXISTS'
	    FROM OE_PC_ASSIGNMENTS A
	    WHERE a.constraint_id = c.constraint_id
              AND ( a.responsibility_id = p_responsibility_id
		    OR a.responsibility_id IS NULL)
              AND ( a.application_id = p_application_id
                    OR a.application_id IS NULL)
	      AND NOT EXISTS (
            	SELECT 'EXISTS'
            	FROM OE_PC_EXCLUSIONS e
            	WHERE e.responsibility_id = p_responsibility_id
                     AND   e.assignment_id  = a.assignment_id
                     AND   e.application_id = p_application_id
            	)
	    )
     AND nvl(c.enabled_flag, 'Y') = 'Y'
     AND ((p_qualifier_attribute IS NULL)
     OR nvl(c.qualifier_attribute, p_qualifier_attribute) = p_qualifier_attribute)
     ORDER BY c.on_operation_action;


 -- Cursor to select all constraints for the UPDATE operation
    CURSOR C_UPDATE_OP
    IS
    SELECT
      c.constraint_id, c.entity_id
      ,c.on_operation_action, c.column_name
     FROM  oe_pc_constraints c
     WHERE   c.entity_id     = P_ENTITY_ID
     AND   c.constrained_operation = OE_PC_GLOBALS.UPDATE_OP
     -- if p_column_name is NULL then check only for constraints with NULL column
     -- name
     -- if check_all_cols_constraint = 'N', then check for constraint with
     -- column_name = p_column_name (do not check for NULL column_name) but
     -- if check_all_cols_constraint = 'Y', then check for constraint with
     -- column_name = p_column_name or NULL column_name.
     AND (   (c.column_name is null
		AND p_column_name is null)
	  OR (p_check_all_cols_constraint = 'N'
		AND c.column_name = p_column_name)
	  OR (p_check_all_cols_constraint = 'Y'
		AND (c.column_name = p_column_name OR c.column_name is null))
	  )
     -- if caller is defaulting then DO NOT CHECK those constraints
     -- that have honored_by_def_flag = 'N'
     AND   decode(honored_by_def_flag,'N',decode(p_is_caller_defaulting,'Y','N','Y'),
                nvl(honored_by_def_flag,'Y')) = 'Y'
     AND   EXISTS (
	    SELECT 'EXISTS'
	    FROM OE_PC_ASSIGNMENTS A
	    WHERE a.constraint_id = c.constraint_id
              AND ( a.responsibility_id = p_responsibility_id
		    OR a.responsibility_id IS NULL)
              AND ( a.application_id =p_application_id    --added for bug3631547
                    OR a.application_id IS NULL )
	      AND NOT EXISTS (
            	SELECT 'EXISTS'
            	FROM OE_PC_EXCLUSIONS e
            	WHERE e.responsibility_id = p_responsibility_id
            	AND   e.assignment_id     = a.assignment_id
                AND   e.application_id    = p_application_id
            	)
	    )
     AND nvl(c.enabled_flag, 'Y') = 'Y'
     AND ((p_qualifier_attribute IS NULL)
     OR nvl(c.qualifier_attribute, p_qualifier_attribute) = p_qualifier_attribute)
     ORDER BY c.on_operation_action;

 -- Cursor to select all constraints for other operations
    CURSOR C_C
    IS
    SELECT DISTINCT
      c.constraint_id, c.entity_id
      ,c.on_operation_action, c.column_name
     FROM  oe_pc_constraints c,
           oe_pc_assignments a
     WHERE (a.responsibility_id = p_responsibility_id OR a.responsibility_id IS NULL)
     AND   a.constraint_id = c.constraint_id
     AND   c.entity_id     = P_ENTITY_ID
     AND   c.constrained_operation = p_operation
     AND   (a.application_id   = p_application_id OR a.application_id IS NULL)  --added for bug3631547
     AND   NOT EXISTS (
            SELECT 'EXISTS'
            FROM OE_PC_EXCLUSIONS e
            WHERE e.responsibility_id = p_responsibility_id
            AND   e.assignment_id     = a.assignment_id
            AND   e.application_id    = p_application_id
            )
     AND nvl(c.enabled_flag, 'Y') = 'Y'
     AND ((p_qualifier_attribute IS NULL)
     OR nvl(c.qualifier_attribute, p_qualifier_attribute) = p_qualifier_attribute)
     ORDER BY c.on_operation_action;

l_column_name		      VARCHAR2(30);
l_index                       PLS_INTEGER;  -- for bug 6473618 NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ENTER OE_PC_CONSTRAINTS_ADMIN_PVT.IS_OP_CONSTRAINED , COLUMN:' || P_COLUMN_NAME , 1 ) ;
                  END IF;

  l_validation_result   := OE_PC_GLOBALS.NO;

  -- IF OPERATION IS CREATE
  IF p_operation = OE_PC_GLOBALS.CREATE_OP THEN

    -- FIRST, check for generic (not column-specific) CREATE constraints

    IF (p_check_all_cols_constraint = 'Y'
	   OR p_column_name is null) THEN

       OPEN c_create_op;
       FETCH c_create_op BULK COLLECT INTO t_constraint_ids,
                               t_entity_ids,
                               t_on_operation_actions,
                               t_column_names;
       CLOSE c_create_op;

       FOR i IN 1..t_constraint_ids.count LOOP
        OE_PC_Constraints_Admin_Pvt.Validate_Constraint (
              p_constraint_id           => t_constraint_ids(i)
              ,p_use_cached_results      => p_use_cached_results
              ,x_condition_count       => l_condition_count
              ,x_valid_condition_group => l_valid_condition_group
              ,x_result                => l_validation_result
              );
       IF (l_condition_count = 0
                OR l_validation_result = OE_PC_GLOBALS.YES) then
		l_column_name			 := t_column_names(i);
          x_constraint_id           := t_constraint_ids(i);
          x_on_operation_action     := t_on_operation_actions(i);
          x_constraining_conditions_grp   := l_valid_condition_group;
                EXIT;
       END IF;
      END LOOP;

    END IF;

    IF p_column_name IS NULL THEN
	  GOTO Return_Validation_Result;
    END IF;


    -- NEXT, If column name is provided, check for update constraints with
    -- check_on_insert_flag = 'Y'

    Add_To_Check_On_Insert_Cache
	   (p_entity_id => p_entity_id
	   ,p_responsibility_id => p_responsibility_id
           ,p_application_id => p_application_id);   --added for bug3631547

    l_index := (p_entity_id)*G_MAX_CONSTRAINTS + 1;

    LOOP

       IF (NOT G_Check_On_Insert_Cache.EXISTS(l_index))
          OR G_Check_On_Insert_Cache(l_index).column_name = FND_API.G_MISS_CHAR
	  OR G_Check_On_Insert_Cache(l_index).column_name > p_column_name
       THEN
		EXIT;
       END IF;

       IF G_Check_On_Insert_Cache(l_index).column_name = p_column_name THEN

         OE_PC_Constraints_Admin_Pvt.Validate_Constraint (
              p_constraint_id
				   => G_Check_On_Insert_Cache(l_index).constraint_id
              ,p_use_cached_results      => p_use_cached_results
              ,x_condition_count       => l_condition_count
              ,x_valid_condition_group => l_valid_condition_group
              ,x_result                => l_validation_result
              );
         IF (l_condition_count = 0
                OR l_validation_result = OE_PC_GLOBALS.YES) then
		l_column_name := G_Check_On_Insert_Cache(l_index).column_name;
          x_constraint_id := G_Check_On_Insert_Cache(l_index).constraint_id;
          x_on_operation_action := G_Check_On_Insert_Cache(l_index).on_operation_action;
          x_constraining_conditions_grp   := l_valid_condition_group;
          EXIT;
         END IF;

       END IF;

       l_index := l_index+1;

    END LOOP;

  -- IF OPERATION IS UPDATE
  ELSIF p_operation = OE_PC_GLOBALS.UPDATE_OP THEN

    OPEN c_update_op;
    FETCH c_update_op BULK COLLECT INTO t_constraint_ids,
                               t_entity_ids,
                               t_on_operation_actions,
                               t_column_names;
    CLOSE c_update_op;

    FOR i IN 1..t_constraint_ids.count LOOP
        OE_PC_Constraints_Admin_Pvt.Validate_Constraint (
              p_constraint_id           => t_constraint_ids(i)
              ,p_use_cached_results      => p_use_cached_results
              ,x_condition_count       => l_condition_count
              ,x_valid_condition_group => l_valid_condition_group
              ,x_result                => l_validation_result
              );
       IF (l_condition_count = 0
                OR l_validation_result = OE_PC_GLOBALS.YES) then
		l_column_name			 := t_column_names(i);
          x_constraint_id           := t_constraint_ids(i);
          x_on_operation_action     := t_on_operation_actions(i);
          x_constraining_conditions_grp   := l_valid_condition_group;
          EXIT;
       END IF;
    END LOOP;

  -- IF OPERATION IS DELETE, CANCEL or SPLIT
  ELSE

       OPEN c_c;
       FETCH c_c BULK COLLECT INTO t_constraint_ids,
                               t_entity_ids,
                               t_on_operation_actions,
                               t_column_names;
       CLOSE c_c;

    FOR i IN 1..t_constraint_ids.count LOOP
        OE_PC_Constraints_Admin_Pvt.Validate_Constraint (
              p_constraint_id           => t_constraint_ids(i)
              ,p_use_cached_results      => p_use_cached_results
              ,x_condition_count       => l_condition_count
              ,x_valid_condition_group => l_valid_condition_group
              ,x_result                => l_validation_result
              );
       IF (l_condition_count = 0
                OR l_validation_result = OE_PC_GLOBALS.YES) then
		l_column_name			 := t_column_names(i);
          x_constraint_id           := t_constraint_ids(i);
          x_on_operation_action     := t_on_operation_actions(i);
          x_constraining_conditions_grp   := l_valid_condition_group;
          EXIT;
       END IF;
    END LOOP;

  END IF;

  <<Return_Validation_Result>>

  -- Add message to the stack if the operation IS constrained!
  IF l_validation_result = OE_PC_GLOBALS.YES THEN

	SELECT database_object_name
	INTO l_db_object_name
	FROM oe_ak_objects_ext
	WHERE entity_id = p_entity_id;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ADD CONSTRAINT MESSAGE' ) ;
        END IF;
	-- l_column_name is the name of the column on the constraint
	-- This maybe NULL if update on all columns is constrained
	-- (even if p_column_name is not null)
	OE_PC_Constraints_Admin_PUB.Add_Constraint_Message
          ( p_application_id       => 660
          , p_database_object_name => l_db_object_name
          , p_column_name          => l_column_name
          , p_operation            => p_operation
          , p_constraint_id        => x_constraint_id
          , p_group_number         => x_constraining_conditions_grp
          , p_on_operation_action  => x_on_operation_action
          );

  END IF;

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'EXIT OE_PC_CONSTRAINTS_ADMIN_PVT.IS_OP_CONSTRAINED , RESULT:' ||L_VALIDATION_RESULT , 1 ) ;
			END IF;
  RETURN l_validation_result;

EXCEPTION
    WHEN OTHERS THEN
  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Is_Op_Constrained'
        );
       END IF;
       RETURN OE_PC_GLOBALS.ERROR;
END Is_Op_Constrained;

END Oe_PC_Constraints_Admin_Pvt;

/
