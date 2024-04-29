--------------------------------------------------------
--  DDL for Package Body ECE_FLATFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_FLATFILE_PVT" AS
-- $Header: ECVFILEB.pls 120.3 2005/10/04 02:19:41 arsriniv ship $

   debug_mode_on_select BOOLEAN        := FALSE;
   debug_mode_on_write  BOOLEAN        := FALSE;
   pos_not_found        EXCEPTION;
   g_msg                VARCHAR2(2000) := NULL;

---	PROCEDURE select_clause.
---	Creation	Feb. 14, 1995
---
---	Procedure select_clause builds a Select clause and a From
---	clause and a Where clause at run time for the dynamic SQL call.

---	It looks at all the data columns for the EC transaction,
---	based on stored info, sort the columns in ascending order
---	of which should be written in the output file first, then
---	store them in a PL/SQL table.
---
---	It then builds a character string of the select clause
---	based on these stored columns and returns it.  This select
---	clause had already add the TO_CHAR function to convert
---	data to character type.

---	It also returns the number and position of columns stored,
---	and width of each column.  Furthmore, it returns the From
---	and Where clauses of the select statement.

   PROCEDURE get_tran_attributes(p_transaction_type IN VARCHAR2) IS
      n_record_count          NUMBER   := 0;

      CURSOR c_tran_attribute IS
         SELECT   key_column_name
         FROM     ece_interface_tables
         WHERE    transaction_type = p_transaction_type AND
                  key_column_name IS NOT NULL
         ORDER BY output_level;

      BEGIN
         t_tran_attribute_tbl.DELETE;

         FOR r_key_column_rec IN c_tran_attribute LOOP
            n_record_count := n_record_count + 1;
            t_tran_attribute_tbl(n_record_count).key_column_name := r_key_column_rec.key_column_name;
         END LOOP;

         IF n_record_count = 0 THEN
            NULL;
         END IF;

      END get_tran_attributes;

   PROCEDURE print_attributes IS
      n_index  NUMBER;

      BEGIN
         FOR n_index IN 1..t_tran_attribute_tbl.COUNT LOOP
		if t_tran_attribute_tbl(n_index).value is not null
		then
            		ec_debug.pl(0,'EC','ECE_ERROR_DOCUMENT',
				'KEY_COLUMN_NAME',
				t_tran_attribute_tbl(n_index).key_column_name,
				'DOCUMENT_NUMBER',
				t_tran_attribute_tbl(n_index).value);
		end if;
         END LOOP;

      END print_attributes;

   PROCEDURE select_clause(
      cTransaction_Type       IN    VARCHAR2,
      cCommunication_Method   IN    VARCHAR2,
      cInterface_Table        IN    VARCHAR2,
      cExt_Table              OUT NOCOPY   VARCHAR2,
      p_Interface_tbl         OUT NOCOPY  interface_tbl_type,
      p_common_key_name       OUT NOCOPY  VARCHAR2,
      cSelect_string          OUT NOCOPY  VARCHAR2,
      cFrom_string            OUT NOCOPY  VARCHAR2,
      cWhere_string           OUT NOCOPY  VARCHAR2,
      p_output_level          IN    VARCHAR2 DEFAULT NULL,
      cMapCode                IN    VARCHAR2 DEFAULT NULL) IS

      xProgress               VARCHAR2(30);
      cOutput_path            VARCHAR2(120);

      cSelect_stmt            VARCHAR2(32000)   := 'SELECT ';
      cFrom_stmt              VARCHAR2(32000)   := ' FROM ';
      cWhere_stmt             VARCHAR2(32000)   := ' WHERE ';

      cTo_Char                VARCHAR2(20)      := 'TO_CHAR(';
      cDate                   VARCHAR2(40)      := ',''YYYYMMDD HH24MISS'')';
      cWord1                  VARCHAR2(20)      := ' ';
      cWord2                  VARCHAR2(40)      := ' ';
      cExtension_Table        VARCHAR2(50);
      cTable_Name             VARCHAR2(50);
      cColumn_Name            VARCHAR2(50);

      iColumn_count           INTEGER := 0;
      iMap_ID                 INTEGER;

      CURSOR c1(cMap_ID INTEGER) IS
         SELECT   eit.interface_table_name      table_name,
                  eit.extension_Table_Name      ext_table_name,
                  eic.interface_column_name     column_name,
                  eic.column_name               ext_column_name,
                  eic.record_number             record_number,
                  eic.position                  position,
                  eic.width                     new_width,
                  eic.record_layout_code,
                  eic.record_layout_qualifier,
                  eic.interface_column_id       int_col_id,
                  eic.width                     width,
                  eic.data_type                 col_type
         FROM     ece_interface_columns         eic,
                  ece_interface_tables          eit
         WHERE    eit.transaction_type          = cTransaction_Type AND
                  eit.interface_table_name      = cInterface_Table AND
                  eit.output_level              = NVL(p_output_level,eit.output_level) AND
                  eit.interface_table_id        = eic.interface_table_id AND
                  eit.map_id                    = cMap_ID AND
                 (eic.interface_column_name     IS NOT NULL OR
                  eic.column_name               IS NOT NULL)
         ORDER BY eic.record_number,
                  eic.position;

         BEGIN
	   if EC_DEBUG.G_debug_level >= 2 then
            ec_debug.push('ECE_FLATFILE_PVT.SELECT_CLAUSE');
	   end if;

            IF cMapCode IS NULL THEN
               SELECT   map_id INTO iMap_ID
               FROM     ece_mappings
               WHERE    map_code = 'EC_' || cTransaction_type || '_FF';
            ELSE
               SELECT   map_id INTO iMap_ID
               FROM     ece_mappings
               WHERE    map_code = cMapCode;
            END IF;
            if EC_DEBUG.G_debug_level = 3 then
		ec_debug.pl(3,'iMap_ID',iMap_ID);
            end if;
            xProgress := 'FILEB-10-1020';
            FOR c1_rec IN c1(iMap_ID) LOOP
               -- **************************************
               -- store data in PL/SQL tables
               -- These tables will be returned to the main program
               -- **************************************
               xProgress := 'FILEB-10-1030';
               iColumn_count := iColumn_count + 1;
               xProgress := 'FILEB-10-1040';
               p_Interface_tbl(iColumn_count).interface_column_id        := c1_rec.Int_col_id;
               xProgress := 'FILEB-10-1050';
               p_Interface_tbl(iColumn_count).interface_table_name       := c1_rec.Table_Name;
               xProgress := 'FILEB-10-1060';
               p_Interface_tbl(iColumn_count).interface_column_name      := c1_rec.Column_Name;
               xProgress := 'FILEB-10-1070';
               p_Interface_tbl(iColumn_count).Record_num       := c1_rec.Record_Number;
               xProgress := 'FILEB-10-1080';
               p_Interface_tbl(iColumn_count).Position         := c1_rec.Position;
               xProgress := 'FILEB-10-1090';
               p_Interface_tbl(iColumn_count).data_length      := NVL(c1_rec.New_width, c1_rec.Width);
               xProgress := 'FILEB-10-1100';
               p_Interface_tbl(iColumn_count).layout_code      := c1_rec.Record_layout_code;
               xProgress := 'FILEB-10-1110';
               p_Interface_tbl(iColumn_count).record_qualifier := c1_rec.record_layout_qualifier;
        if EC_DEBUG.G_debug_level = 3 then
	      ec_debug.pl(3,
			iColumn_count||' '||
			p_Interface_tbl(iColumn_count).interface_column_id||' '||
			p_Interface_tbl(iColumn_count).interface_table_name||' '||
			p_Interface_tbl(iColumn_count).interface_column_name||' '||
			p_Interface_tbl(iColumn_count).Record_Num||' '||
			p_Interface_tbl(iColumn_count).Position||' '||
			p_Interface_tbl(iColumn_count).data_length||' '||
			p_Interface_tbl(iColumn_count).layout_code||' '||
			p_Interface_tbl(iColumn_count).record_qualifier
			);
         end if;
               -- **************************************
               -- apply appropriate data conversion
               -- **************************************
               xProgress := 'FILEB-10-1120';
               IF 'DATE' = c1_rec.Col_Type THEN
                  xProgress := 'FILEB-10-1130';
                  cWord1 := cTO_CHAR;
                  xProgress := 'FILEB-10-1140';
                  cWord2 := cDATE;
                  xProgress := 'FILEB-10-1150';
               ELSIF 'NUMBER' = c1_rec.Col_Type THEN
                  xProgress := 'FILEB-10-1160';
                  cWord1 := cTO_CHAR;
                  cWord2 := ')';
               ELSE
                  xProgress := 'FILEB-10-1170';
                  cWord1 := NULL;
                  cWord2 := NULL;
               END IF;

               -- build SELECT statement
               IF c1_rec.Column_Name IS NOT NULL THEN
                  cTable_Name := c1_rec.Table_Name;
                  cColumn_Name := c1_rec.Column_Name;
               ELSIF c1_rec.Ext_Column_Name IS NOT NULL THEN
                  cTable_Name := c1_rec.Ext_Table_Name;
                  cColumn_Name := c1_rec.Ext_Column_Name;
               ELSE
                  cTable_Name := NULL;
                  cColumn_Name := NULL;
               END IF;

               xProgress := 'FILEB-10-1180';
               IF ((cTable_Name IS NOT NULL) AND (cColumn_Name IS NOT NULL)) THEN
                  cSelect_stmt :=  cSelect_stmt || ' ' || cWord1 || cTable_Name || '.' ||
          			cColumn_Name || cWord2 || ',';
               END IF;
            END LOOP;

            xProgress := 'FILEB-10-1190';
            SELECT   eit.extension_table_name,			-- select extension table name
                     eit.key_column_name
            INTO	   cExtension_Table,
                     p_common_key_name
            FROM	   ece_interface_tables eit
            WHERE    eit.transaction_type     = cTransaction_Type AND
                     eit.interface_table_name = cInterface_Table AND
                     eit.map_id               = iMap_ID AND
                     eit.output_level	       = NVL(p_output_level,eit.output_level);

            -- *************************************
            -- build FROM, WHERE statements
            -- *************************************
            xProgress := 'FILEB-10-1200';
            cFrom_stmt  := cFrom_stmt  || cInterface_Table || ', '|| cExtension_Table;

            xProgress := 'FILEB-10-1210';
            cWhere_stmt := cWhere_stmt || cInterface_Table || '.' || 'TRANSACTION_RECORD_ID' ||
            ' = ' || cExtension_table || '.'|| 'TRANSACTION_RECORD_ID(+)';

            xProgress := 'FILEB-10-1220';
            cSelect_string := RTRIM(cSelect_stmt, ',');
            if EC_DEBUG.G_debug_level = 3 then
            ec_debug.pl(3,'Select statement : ',cSelect_string);
            end if;
            xProgress := 'FILEB-10-1230';
            cFrom_string	  := cFrom_stmt;
            if EC_DEBUG.G_debug_level = 3 then
            ec_debug.pl(3,'From statement : ',cFrom_string);
            end if;
            xProgress := 'FILEB-10-1240';
            cWhere_string  := cWhere_stmt;
            if EC_DEBUG.G_debug_level = 3 then
            ec_debug.pl(3,'Where statement : ',cWhere_string);
            end if;
            xProgress := 'FILEB-10-1250';
            cExt_Table 	  := cExtension_Table;
            if EC_DEBUG.G_debug_level = 3 then
            ec_debug.pl(3,'cExt_Table : ',cExt_Table);
            end if;

	if EC_DEBUG.G_debug_level >= 2 then
            ec_debug.pop('ECE_FLATFILE_PVT.SELECT_CLAUSE');
	end if;

         EXCEPTION
            WHEN OTHERS THEN
               ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_FLATFILE_PVT.SELECT_CLAUSE');
               ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
               ec_debug.pl(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
               ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
               app_exception.raise_exception;

         END select_clause;

         ---PROCEDURE write_to_ece_output
         ---Creation	Feb. 15, 1995
         ---This report procedure writes data to the ECE_OUTPUT table.
         ---It put the appropriate record id at the beginning of each record
         ---lines of data.  The entire record line of data is inserted into the
         ---TEXT column in the table.
         ---
         ---It expects a PL/SQL table of output data (in ASC order)!!!

      PROCEDURE write_to_ece_output(
         cTransaction_Type       IN VARCHAR2,
         cCommunication_Method   IN VARCHAR2,
         cInterface_Table        IN VARCHAR2,
         p_Interface_tbl         IN Interface_tbl_type,
         iOutput_width           IN INTEGER,
         iRun_id                 IN INTEGER,
         p_common_key            IN VARCHAR2) IS

         xProgress               VARCHAR2(30);
         cOutput_path            VARCHAR2(120);
         iLine_pos               INTEGER;
         iData_count             INTEGER          := p_Interface_tbl.COUNT;
         iStart_num              INTEGER;
         iRow_num                INTEGER;
         cInsert_stmt            VARCHAR2(32000);
         l_common_key            VARCHAR2(255)    := p_common_key;
         l_count                 NUMBER;

         BEGIN
	if EC_DEBUG.G_debug_level >= 2 then
            ec_debug.push('ECE_FLATFILE_PVT.WRITE_TO_ECE_OUTPUT');
	end if;
            xProgress := 'FILEB-WR-1020';
            FOR i IN 1..iData_count LOOP
               xProgress := 'FILEB-WR-1030';
               l_count := i;

               xProgress := 'FILEB-WR-1040';
               IF p_Interface_tbl(i).Record_num IS NOT NULL AND
                  p_Interface_tbl(i).position IS NOT NULL AND
                  p_Interface_tbl(i).data_length IS NOT NULL THEN
                  xProgress := 'FILEB-WR-1050';
                  iRow_num := i;
                  if EC_DEBUG.G_debug_level >= 3 then
                  ec_debug.pl(3,'iRow_num : ',iRow_num);
                  end if;
                  xProgress := 'FILEB-WR-1060';

                  cInsert_stmt := cInsert_stmt || substr(rpad(nvl(p_Interface_tbl(i).value,' '),
                                  TO_CHAR(p_Interface_tbl(i).data_length),' '),1,
                                  p_Interface_tbl(i).data_length);

                  -- ******************************************************
                  -- the following two lines is for testing/debug purpose
                  -- ******************************************************
                  -- cInsert_stmt := cInsert_stmt || rpad(substrb(p_Interface_tbl(i).interface_column_name,1,p_Interface_tbl(i).data_length-2)||
                  -- substrb(TO_CHAR(p_Interface_tbl(i).data_length),1,2), TO_CHAR(p_Interface_tbl(i).data_length),' ');
               END IF;

               xProgress := 'FILEB-WR-1070';
               IF i < iData_count THEN
                  xProgress := 'FILEB-WR-1080';
                  IF p_Interface_tbl(i).Record_num <> p_Interface_tbl(i+1).Record_num THEN
                     xProgress := 'FILEB-WR-1090';
                     cInsert_stmt := l_common_key || LPAD(NVL(p_Interface_tbl(iRow_num).Record_num,0),4,'0') ||
                                                     RPAD(NVL(p_Interface_tbl(iRow_num).layout_code,' '),2) ||
                                                     RPAD(NVL(p_Interface_tbl(iRow_num).record_qualifier,' '),3) || cInsert_stmt;

                     xProgress := 'FILEB-WR-1100';
                     INSERT INTO ece_output(run_id,line_id,text) VALUES
                        (iRun_id,ece_output_lines_s.NEXTVAL,SUBSTR(cInsert_stmt,1,iOutput_width));

                        xProgress := 'FILEB-WR-1110';
                        cInsert_stmt := NULL;
                        -- cInsert_stmt := '*' || TO_CHAR(p_Interface_tbl(i).Record_num);
                  END IF;
               ELSE
                  xProgress := 'FILEB-WR-1120';
                 /* Bug# 2108977 :- Added the following codition to prevent NULL records from causing
                                    erros */

                 IF iRow_num IS NOT NULL THEN
                  cInsert_stmt := l_common_key || LPAD(NVL(p_Interface_tbl(iRow_num).Record_num,0),4,'0') ||
                                                  RPAD(NVL(p_Interface_tbl(iRow_num).layout_code,' '),2) ||
                                                  RPAD(NVL(p_Interface_tbl(iRow_num).record_qualifier,' '),3) || cInsert_stmt;

                  xProgress := 'FILEB-WR-1130';
                  INSERT INTO ece_output(run_id,line_id,text) VALUES
                     (iRun_id,ece_output_lines_s.NEXTVAL,SUBSTR(cInsert_stmt,1,iOutput_width));
                 END IF;
               END IF;
            END LOOP;

	if EC_DEBUG.G_debug_level >= 2 then
            ec_debug.pop('ECE_FLATFILE_PVT.WRITE_TO_ECE_OUTPUT');
	end if;

         EXCEPTION
            WHEN OTHERS THEN
               ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_FLATFILE_PVT.WRITE_TO_ECE_OUTPUT');
               ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
               ec_debug.pl(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
               ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

               ec_debug.pl(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME', 'to_char(l_count)');
               ec_debug.pl(0,'EC','ECE_PLSQL_VALUE','COLUMN_NAME', 'p_interface_tbl(l_count).value');
               ec_debug.pl(0,'EC','ECE_PLSQL_DATA_TYPE','COLUMN_NAME', 'p_interface_tbl(l_count).data_type');
               ec_debug.pl(0,'EC','ECE_PLSQL_COLUMN_NAME','COLUMN_NAME', 'p_interface_tbl(l_count).base_column');
               app_exception.raise_exception;

         END write_to_ece_output;

PROCEDURE Find_pos(
		p_Interface_tbl		IN Interface_tbl_type,
		cSearch_text		IN VARCHAR2,
		nPos			IN OUT NOCOPY NUMBER)

IS
	cIn_string	VARCHAR2(1000)	:= UPPER(cSearch_text);
   nColumn_count  NUMBER      := p_Interface_tbl.Count;
	b_found		BOOLEAN 	:= FALSE;
	POS_NOT_FOUND	EXCEPTION;
        cOutput_path	VARCHAR2(120);
BEGIN

	if EC_DEBUG.G_debug_level >= 2 then
         EC_DEBUG.PUSH('ECE_FLATFILE_PVT.Find_pos');
         EC_DEBUG.PL(3, 'Search text : ', cSearch_text);
         EC_DEBUG.PL(3, 'nColumn_count : ', nColumn_count);
         end if;
     For k in 1..nColumn_count loop
	if UPPER(p_Interface_tbl(k).interface_column_name) = cIn_string then
	  nPos := k;
          if EC_DEBUG.G_debug_level >= 3 then
            EC_DEBUG.PL(3, 'Position : ', nColumn_count);
          end if;
	  b_found := TRUE;
	  exit;
	end if;
     end loop;

     if NOT b_found then
       Raise POS_NOT_FOUND;
     end if;
if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.POP('ECE_FLATFILE_PVT.Find_pos');
end if;
EXCEPTION
  WHEN POS_NOT_FOUND THEN
      EC_DEBUG.PL(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME', 'cIn_string');
      app_exception.raise_exception;

  WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_FLATFILE_PVT.FIND_POS');
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
         app_exception.raise_exception;
END Find_pos;
/*
PROCEDURE match_data_loc_id(
		p_Interface_tbl		IN Interface_tbl_type,
		p_data_loc_id		IN NUMBER,
		p_Pos			OUT NOCOPY NUMBER)

IS

BEGIN
  EC_DEBUG.PUSH('ECE_FLATFILE_PVT.match_data_loc_id');
        if EC_DEBUG.G_debug_level >= 3 then
        EC_DEBUG.PL(3, 'Data loc id : ', p_data_loc_id);
        EC_DEBUG.PL(3, 'Loop count : ', p_Interface_tbl.count);
        end if;
	For k in 1..p_Interface_tbl.count
        loop
		if p_Interface_tbl(k).data_loc_id = p_data_loc_id
		then
			p_Pos := k;
                        if EC_DEBUG.G_debug_level >= 3 then
                        EC_DEBUG.PL(3, 'Position : ', p_Pos);
                        end if;
			exit;
		end if;
	end loop;
  EC_DEBUG.POP('ECE_FLATFILE_PVT.match_data_loc_id');
END match_data_loc_id;

-- *******************************************
*/
PROCEDURE match_interface_column_id(
		p_Interface_tbl		IN Interface_tbl_type,
		p_Interface_column_id	IN NUMBER,
		p_Pos			OUT NOCOPY NUMBER)

IS

BEGIN
	if EC_DEBUG.G_debug_level >= 2 then
 	 EC_DEBUG.PUSH('ECE_FLATFILE_PVT.match_interface_column_id');
        EC_DEBUG.PL(3, 'Interface_column_id : ', p_Interface_column_id);
        EC_DEBUG.PL(3, 'Loop count : ', p_Interface_tbl.count);
        end if;
	For k in 1..p_Interface_tbl.count
        loop
		if p_Interface_tbl(k).interface_column_id = p_Interface_column_id
		then
			p_Pos := k;
                        if EC_DEBUG.G_debug_level >= 3 then
                        EC_DEBUG.PL(3, 'Position : ', p_Pos);
                        end if;
			exit;
		end if;
	end loop;
if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.POP('ECE_FLATFILE_PVT.match_interface_column_id');
end if;
END match_interface_column_id;

-- *******************************************
FUNCTION match_conversion_group_id(
		p_gateway_tbl		IN Interface_tbl_type,
		p_conversion_id		IN NUMBER,
		p_sequence_num		IN NUMBER,
		p_pos			OUT NOCOPY NUMBER)
return BOOLEAN
IS
   xProgress    varchar2(30);
   b_found	BOOLEAN := FALSE;
   nCount	NUMBER;
   POS_NOT_FOUND EXCEPTION;
   cOutput_path VARCHAR2(120);

BEGIN
	xProgress := 'FILEB-MA-1000';
     if EC_DEBUG.G_debug_level >= 2 then
        EC_DEBUG.PUSH('ECE_FLATFILE_PVT.match_conversion_group_id');

        EC_DEBUG.PL(3, 'Conversion id : ', p_conversion_id);
        EC_DEBUG.PL(3, 'Seq num : ', p_sequence_num);
        EC_DEBUG.PL(3, 'Loop count : ', p_gateway_tbl.count);
    end if;
	For k in 1..p_gateway_tbl.count
        loop
                xProgress := 'FILEB-MA-1010';
		nCount := k;
		if p_gateway_tbl(k).conversion_group_id = p_conversion_id
		   and p_gateway_tbl(k).conversion_seq = p_sequence_num
		then
                        xProgress := 'FILEB-MA-1020';
			p_pos := k;
                        if EC_DEBUG.G_debug_level >= 2 then
                        EC_DEBUG.PL(3, 'Position : ', p_pos);
			EC_DEBUG.POP('ECE_FLATFILE_PVT.match_conversion_group_id');
                        end if;
			b_found := TRUE;
			return b_found;
		end if;
	end loop;
        xProgress := 'FILEB-MA-1030';
  IF NOT b_found THEN
    RAISE POS_NOT_FOUND;
  END IF;
if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.POP('ECE_FLATFILE_PVT.match_conversion_group_id');
end if;
EXCEPTION
  WHEN POS_NOT_FOUND THEN
     EC_DEBUG.PL(0,'EC','ECE_CONVERSION_ID_NOT_FOUND','CONVERSION_ID', 'p_conversion_id', 'SEQUENCE', 'p_sequence_num');
      app_exception.raise_exception;

  WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','xProgress');
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
         app_exception.raise_exception;

END match_conversion_group_id;

-- *******************************************
FUNCTION match_xref_conv_seq(
		p_gateway_tbl		IN Interface_tbl_type,
		p_conversion_group	IN NUMBER,
		p_sequence_num		IN NUMBER,
		p_Pos			OUT NOCOPY NUMBER)
return BOOLEAN
IS
   b_found	BOOLEAN := FALSE;

BEGIN
      if EC_DEBUG.G_debug_level >= 2 then
	EC_DEBUG.PUSH('ECE_FLATFILE_PVT.match_xref_conv_seq');
        EC_DEBUG.PL(3, 'Conversion group : ', p_conversion_group);
        EC_DEBUG.PL(3, 'Seq num : ', p_sequence_num);
        EC_DEBUG.PL(3, 'Loop count : ', p_gateway_tbl.count);
        end if;
	For k in 1..p_gateway_tbl.count
        loop
		if p_gateway_tbl(k).conversion_group_id = p_conversion_group
		   and p_gateway_tbl(k).conversion_seq = p_sequence_num
		then
			p_Pos := k;
                      if EC_DEBUG.G_debug_level >= 3 then
                        EC_DEBUG.PL(3, 'Position : ', p_Pos);
                      end if;
		b_found := TRUE;
			exit;
		end if;
	end loop;
if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.POP('ECE_FLATFILE_PVT.match_xref_conv_seq');
end if;
   return b_found;

END match_xref_conv_seq;

-- *******************************************
FUNCTION match_xref_conv_seq(
		p_level			IN NUMBER,
		p_conversion_group	IN NUMBER,
		p_sequence_num		IN NUMBER,
		p_Pos			OUT NOCOPY NUMBER)
return BOOLEAN
IS
   b_found	BOOLEAN := FALSE;
   hash_value   pls_integer;
   hash_string  varchar2(3200);
   tbl_pos      pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PUSH('ECE_FLATFILE_PVT.match_xref_conv_seq');
EC_DEBUG.PL(3, 'p_level group : ', p_level);
EC_DEBUG.PL(3, 'Conversion group : ', p_conversion_group);
EC_DEBUG.PL(3, 'Seq num : ', p_sequence_num);
ec_debug.pl(3, 'file_start_pos',ec_utils.g_ext_levels(p_level).file_start_pos);
ec_debug.pl(3, 'file_end_pos',ec_utils.g_ext_levels(p_level).file_end_pos);
end if;

   /*
    Bug 2112028 -Reverting this fix back to 115.16 as the change done in 1853627 causes
 		 the Generic Outbound process to fail

    Bug 2340691 - The fix made in 1853627 was again added to improve the Performance. This fix
		  is for Inbound programs only. The Outbound programs use the previous logic.
   */

/* if ec_utils.g_direction = 'I'      --bug 3133379
then */
	/* Bug 2617428
	For k in ec_utils.g_ext_levels(p_level).file_start_pos..ec_utils.g_ext_levels(p_level).file_end_pos
        loop
		if ec_utils.g_file_tbl(k).external_level = p_level
		then
			if ec_utils.g_file_tbl(k).conversion_group_id = p_conversion_group
		   	and ec_utils.g_file_tbl(k).conversion_sequence = p_sequence_num
			then
				p_Pos := k;
				b_found := TRUE;
				exit;
			end if;
		end if;
	end loop;
	*/
	-- Bug 2617428, 2791195
	 hash_string :=to_char(p_conversion_group)||'-'||
		       to_char(p_level)||'-'||
		       to_char(p_sequence_num);
         hash_value := dbms_utility.get_hash_value(hash_string,1,8192);
         if ec_utils.g_code_conv_pos_tbl_1.exists(hash_value) then
           if ec_utils.g_code_conv_pos_tbl_1(hash_value).occr = 1 then
                p_Pos := ec_utils.g_code_conv_pos_tbl_1(hash_value).value;
                b_found := TRUE;
           else
                tbl_pos :=  ec_utils.g_code_conv_pos_tbl_1(hash_value).start_pos;
                while tbl_pos<=ec_utils.g_code_conv_pos_tbl_2.LAST
                loop
                      if ec_utils.g_code_conv_pos_tbl_2(tbl_pos) = hash_value then
                        if upper(ec_utils.g_file_tbl(tbl_pos).conversion_group_id) = p_conversion_group
                         and ec_utils.g_file_tbl(tbl_pos).conversion_sequence=p_sequence_num then
                                p_Pos := tbl_pos;
                                b_found := TRUE;
                                exit;
                         end if;
                      end if;
                      tbl_pos:=ec_utils.g_code_conv_pos_tbl_2.NEXT(tbl_pos);
                end loop;
           end if;
         end if;
/* else               --Bug 3133379
	For k in 1..ec_utils.g_file_tbl.count
        loop
		if ec_utils.g_file_tbl(k).external_level = p_level
		then
			if ec_utils.g_file_tbl(k).conversion_group_id = p_conversion_group
		   	and ec_utils.g_file_tbl(k).conversion_sequence = p_sequence_num
			then
				p_Pos := k;
				b_found := TRUE;
				exit;
			end if;
		end if;
	end loop;
end if;
 */

if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'p_Pos', p_Pos);
EC_DEBUG.PL(3, 'b_found', b_found);
EC_DEBUG.POP('ECE_FLATFILE_PVT.match_xref_conv_seq');
end if;
return b_found;

END match_xref_conv_seq;

-- ***********************************
--  This function calculates the number
--  of data in a record, excluding the
--  common key
--
--  algorithm:
--  match the record num in the interface
--  table
--  and return the number of matches
-- ***********************************

FUNCTION match_record_num(
		p_gateway_tbl		IN Interface_tbl_type,
		p_Record_num		IN NUMBER,
		p_Pos			OUT NOCOPY NUMBER,
		p_total_unit		OUT NOCOPY NUMBER)
return BOOLEAN
IS
	b_match_found	BOOLEAN := FALSE;
 	l_total_unit	NUMBER := 0;
        cOutput_path	varchar2(120);
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
	EC_DEBUG.PUSH('ECE_FLATFILE_PVT.match_record_num');
        EC_DEBUG.PL(3, 'Record num : ', p_Record_num);
        EC_DEBUG.PL(3, 'Loop count : ', p_gateway_tbl.count);
  end if;
	For k in 1..p_gateway_tbl.count
        loop
		if p_gateway_tbl(k).Record_num = p_Record_num
		and (not b_match_found)
                then
			p_Pos := k;
                        if EC_DEBUG.G_debug_level >= 3 then
                        EC_DEBUG.PL(3, 'Position : ', p_Pos);
                        end if;
			l_total_unit := l_total_unit + 1;
			b_match_found := TRUE;

		elsif p_gateway_tbl(k).Record_num = p_Record_num
		then
			l_total_unit := l_total_unit + 1;

		elsif b_match_found
		and p_gateway_tbl(k).Record_num <> p_Record_num
		then
			--  this elsif is for performance reason
			--  a match found already and now on to a
			--  new record num, break.

			exit;
		end if;
	end loop;

	p_total_unit := l_total_unit;
        if EC_DEBUG.G_debug_level >= 2 then
        EC_DEBUG.PL(3, 'Total records found : ', p_total_unit);
  	EC_DEBUG.POP('ECE_FLATFILE_PVT.match_record_num');
	end if;
        return b_match_found;
EXCEPTION
   when others
   then
         EC_DEBUG.PL(0,'EC','ECE_RECORD_NUM_NOT_FOUND','RECORD_NUM','to_char(p_Record_num)');
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	 app_exception.raise_exception;
END match_record_num;

   PROCEDURE init_table(
      cTransaction_Type IN    VARCHAR2,
      cInt_tbl_name     IN    VARCHAR2,
      cOutput_level     IN    VARCHAR2,
      bKey_exist        IN    BOOLEAN,
      cInterface_tbl    OUT NOCOPY  ece_flatfile_pvt.Interface_tbl_type,
      cKey_tbl          IN OUT NOCOPY   ece_flatfile_pvt.Interface_tbl_type,
      cMapCode          IN    VARCHAR2 DEFAULT NULL) IS

      CURSOR c_source_data(cMap_ID INTEGER) IS
         SELECT   eic.conversion_group_id,
                  eic.conversion_sequence,
                  eit.interface_table_name,
                  eic.interface_column_name,
                  eic.base_table_name,
                  eic.base_column_name,
                  eic.xref_category_id,
                  eic.xref_key1_source_column,
                  eic.xref_key2_source_column,
                  eic.xref_key3_source_column,
                  eic.xref_key4_source_column,
                  eic.xref_key5_source_column,
                  eic.data_type,
                  eic.width                        data_length,
		  eic.record_number,      -- bug 2823215
		  eic.position,
		  eic.record_layout_code,
		  eic.record_layout_qualifier,
		  eic.column_name               ext_column_name
         FROM     ece_interface_columns            eic,
                  ece_interface_tables             eit
         WHERE    eit.transaction_type       = cTransaction_type AND
                  eit.interface_table_name   = cInt_tbl_name AND
                  eic.interface_table_id     = eit.interface_table_id AND
                  eit.output_level           = NVL(cOutput_level,eit.output_level) AND
                  eit.map_id                 = cMap_ID
         ORDER BY  eic.record_number,
                  eic.position;
         --   d_dummy_date			DATE;
         i_count        INTEGER := 0;
         iKey_count     INTEGER := ckey_tbl.count;
         iMap_ID        INTEGER;
         cOutput_path   VARCHAR2(120);

         BEGIN
	   if EC_DEBUG.G_debug_level >= 2 then
            ec_debug.push('ECE_FLATFILE_PVT.INIT_TABLE');
	   end if;
            IF cMapCode IS NULL THEN
               SELECT   map_id INTO iMap_ID
               FROM     ece_mappings
               WHERE    map_code = 'EC_' || cTransaction_type || '_FF';
            ELSE
               SELECT   map_id INTO iMap_ID
               FROM     ece_mappings
               WHERE    map_code = cMapCode;
            END IF;
                if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,'iMap_ID',iMap_ID);
                end if;

            FOR c_rec IN c_source_data(iMap_ID) LOOP
               i_count := i_count + 1;
               cInterface_tbl(i_count).conversion_group_id      	:= c_rec.conversion_group_id;
               cInterface_tbl(i_count).conversion_seq      	:= c_rec.conversion_sequence;
               cInterface_tbl(i_count).interface_table_name      := c_rec.interface_table_name;
               cInterface_tbl(i_count).interface_column_name     := c_rec.interface_column_name;
               cInterface_tbl(i_count).base_table_name  	  	:= c_rec.base_table_name;
               cInterface_tbl(i_count).base_column_name 	  	:= c_rec.base_column_name;
               cInterface_tbl(i_count).xref_category_id 	  	:= c_rec.xref_category_id;
               cInterface_tbl(i_count).xref_key1_source_column 	:= c_rec.xref_key1_source_column;
               cInterface_tbl(i_count).xref_key2_source_column 	:= c_rec.xref_key2_source_column;
               cInterface_tbl(i_count).xref_key3_source_column 	:= c_rec.xref_key3_source_column;
               cInterface_tbl(i_count).xref_key4_source_column 	:= c_rec.xref_key4_source_column;
               cInterface_tbl(i_count).xref_key5_source_column 	:= c_rec.xref_key5_source_column;
               cInterface_tbl(i_count).data_type        	  	:= c_rec.data_type;
               cInterface_tbl(i_count).data_length      	  	:= c_rec.data_length;
	       cInterface_tbl(i_count).record_num               := c_rec.record_number;
	       cInterface_tbl(i_count).position                 := c_rec.position;
	       cInterface_tbl(i_count).layout_code              := c_rec.record_layout_code;
	       cInterface_tbl(i_count).record_qualifier         := c_rec.record_layout_qualifier;
	       cInterface_tbl(i_count).ext_column_name          := c_rec.ext_column_name;   -- bug 2823215
               if EC_DEBUG.G_debug_level = 3 then
		ec_debug.pl(3,
			i_count||' '||
			cInterface_tbl(i_count).interface_table_name||' '||
			cInterface_tbl(i_count).interface_column_name||' '||
			cInterface_tbl(i_count).base_table_name||' '||
			cInterface_tbl(i_count).base_column_name||' '||
			cInterface_tbl(i_count).data_type||' '||
			cInterface_tbl(i_count).data_length||' '||
			cInterface_tbl(i_count).conversion_group_id||' '||
			cInterface_tbl(i_count).conversion_seq||' '||
			cInterface_tbl(i_count).xref_category_id||' '||
			cInterface_tbl(i_count).xref_key1_source_column||' '||
			cInterface_tbl(i_count).xref_key2_source_column||' '||
			cInterface_tbl(i_count).xref_key3_source_column||' '||
			cInterface_tbl(i_count).xref_key4_source_column||' '||
			cInterface_tbl(i_count).xref_key5_source_column
			);
              end if;
               IF bKey_exist THEN
                  iKey_count := iKey_count + 1;
                  ckey_tbl(iKey_count).conversion_group_id	:= c_rec.conversion_group_id;
                  ckey_tbl(iKey_count).conversion_seq      	:= c_rec.conversion_sequence;
                  ckey_tbl(iKey_count).interface_table_name	:= c_rec.interface_table_name;
                  ckey_tbl(iKey_count).interface_column_name	:= c_rec.interface_column_name;
                  ckey_tbl(iKey_count).base_table_name		:= c_rec.base_table_name;
                  ckey_tbl(iKey_count).base_column_name		:= c_rec.base_column_name;
                  ckey_tbl(iKey_count).xref_category_id		:= c_rec.xref_category_id;
        ckey_tbl(iKey_count).xref_key1_source_column    := c_rec.xref_key1_source_column;
        ckey_tbl(iKey_count).xref_key2_source_column    := c_rec.xref_key2_source_column;
        ckey_tbl(iKey_count).xref_key3_source_column    := c_rec.xref_key3_source_column;
        ckey_tbl(iKey_count).xref_key4_source_column    := c_rec.xref_key4_source_column;
        ckey_tbl(iKey_count).xref_key5_source_column    := c_rec.xref_key5_source_column;
        ckey_tbl(iKey_count).data_type                  := c_rec.data_type;
        ckey_tbl(iKey_count).data_length                := c_rec.data_length;
                  ckey_tbl(iKey_count).record_num            := c_rec.record_number;
	          ckey_tbl(iKey_count).position                 := c_rec.position;
	          ckey_tbl(iKey_count).layout_code              := c_rec.record_layout_code;
	          ckey_tbl(iKey_count).record_qualifier         := c_rec.record_layout_qualifier;
	          ckey_tbl(iKey_count).ext_column_name          := c_rec.ext_column_name;    --bug 2823215




               if EC_DEBUG.G_debug_level = 3 then
		ec_debug.pl(3,
			iKey_count||' '||
			ckey_tbl(iKey_count).interface_table_name||' '||
			ckey_tbl(iKey_count).interface_column_name||' '||
			ckey_tbl(iKey_count).base_table_name||' '||
			ckey_tbl(iKey_count).base_column_name||' '||
			ckey_tbl(iKey_count).xref_category_id||' '||
			ckey_tbl(iKey_count).conversion_group_id||' '||
			ckey_tbl(iKey_count).conversion_seq
			);
              end if;
               END IF;

            END LOOP;

	if EC_DEBUG.G_debug_level >= 2 then
            ec_debug.pop('ECE_FLATFILE_PVT.INIT_TABLE');
	end if;

         EXCEPTION
            WHEN OTHERS THEN
               ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_FLATFILE_PVT.init_table');
               ec_debug.pl(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
               ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
               ec_debug.pl(0,'EC','ECE_PLSQL_TABLE_NAME','TABLE_NAME', 'cInterface_tbl(i_count).base_table_name');
               ec_debug.pl(0,'EC','ECE_PLSQL_COLUMN_NAME','COLUMN_NAME', 'cInterface_tbl(i_count).base_column_name');
               app_exception.raise_exception;

         END init_table;

PROCEDURE ADD_TO_WHERE_CLAUSE (cString   IN OUT NOCOPY VARCHAR2,
			       cAdd	 IN     VARCHAR2) IS
BEGIN
  if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.PUSH('ECE_FLATFILE_PVT.ADD_TO_WHERE_CLAUSE');
  EC_DEBUG.PL(3, 'Add string : ', cAdd);
  end if;

  cString := cString || ' AND '|| cAdd;

  if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.PL(3, 'String : ', cString);
  EC_DEBUG.POP('ECE_FLATFILE_PVT.ADD_TO_WHERE_CLAUSE');
  end if;
END ADD_TO_WHERE_CLAUSE;

PROCEDURE ADD_TO_FROM_CLAUSE (cString IN OUT NOCOPY  VARCHAR2,
			      cAdd    IN     VARCHAR2) IS
BEGIN
  if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.PUSH('ECE_FLATFILE_PVT.ADD_TO_FROM_CLAUSE');
  EC_DEBUG.PL(3, 'Add string : ', cAdd);
  end if;
  cString := cString || cAdd || ', ';
  if EC_DEBUG.G_debug_level >= 3 then
  EC_DEBUG.PL(3, 'String : ', cString);
  EC_DEBUG.POP('ECE_FLATFILE_PVT.ADD_TO_FROM_CLAUSE');
  end if;
END ADD_TO_FROM_CLAUSE;

PROCEDURE DEFINE_INTERFACE_COLUMN_TYPE  (
	c 		IN INTEGER,
	cCol		IN VARCHAR2,
	iCol_size 	IN INTEGER,
	p_tbl		IN ece_flatfile_pvt.Interface_tbl_type)
IS
BEGIN
   if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PUSH('ECE_FLATFILE_PVT.DEFINE_INTERFACE_COLUMN_TYPE');
   EC_DEBUG.PL(3, 'Column value: ', c);
   EC_DEBUG.PL(3, 'Column : ', cCol);
   EC_DEBUG.PL(3, 'Column size: ', iCol_size);
   EC_DEBUG.PL(3, 'Table loop count : ', p_tbl.count);
   end if;

   For k IN 1..p_tbl.count loop
        dbms_sql.define_column(c, k, cCol, iCol_size);
   End Loop;

  if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.POP('ECE_FLATFILE_PVT.DEFINE_INTERFACE_COLUMN_TYPE');
  end if;
EXCEPTION
  when others then
    app_exception.raise_exception;
END DEFINE_INTERFACE_COLUMN_TYPE;

PROCEDURE ASSIGN_COLUMN_VALUE_TO_TBL (
	c		IN INTEGER,
	p_tbl		IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type)
IS
BEGIN
      EC_DEBUG.PUSH('ECE_FLATFILE_PVT.ASSIGN_COLUMN_VALUE_TO_TBL');
      if EC_DEBUG.G_debug_level >= 3 then
      EC_DEBUG.PL(3, 'Column value: ', c);
      EC_DEBUG.PL(3, 'Table loop count : ', p_tbl.count);
      end if;
      for k in 1..p_tbl.count loop
         dbms_sql.column_value(c, k, p_tbl(k).value);
      end loop;

  EC_DEBUG.POP('ECE_FLATFILE_PVT.ASSIGN_COLUMN_VALUE_TO_TBL');
EXCEPTION
  when others then
    app_exception.raise_exception;
END ASSIGN_COLUMN_VALUE_TO_TBL;

PROCEDURE ASSIGN_COLUMN_VALUE_TO_TBL (
	c		IN INTEGER,
	iCount		IN INTEGER,
	p_tbl		IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
	p_key_tbl	IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type)
IS
BEGIN
     if EC_DEBUG.G_debug_level >= 2 then
      EC_DEBUG.PUSH('ECE_FLATFILE_PVT.ASSIGN_COLUMN_VALUE_TO_TBL');
      EC_DEBUG.PL(3, 'Column : ', c);
      EC_DEBUG.PL(3, 'iCount : ', iCount);
      EC_DEBUG.PL(3, 'Table loop count : ', p_tbl.count);
      end if;
      for k in 1..p_tbl.count loop
         dbms_sql.column_value(c, k, p_tbl(k).value);
	 dbms_sql.column_value(c, k, p_key_tbl(k+iCount).value);
      end loop;

if EC_DEBUG.G_debug_level >= 2 then
  EC_DEBUG.POP('ECE_FLATFILE_PVT.ASSIGN_COLUMN_VALUE_TO_TBL');
end if;
EXCEPTION
  when others then
    app_exception.raise_exception;
END ASSIGN_COLUMN_VALUE_TO_TBL;

FUNCTION POS_OF (pInterface_tbl 	ece_flatfile_pvt.Interface_tbl_type,
		 cCol_name		VARCHAR2)
RETURN NUMBER
IS
  l_Row_count	NUMBER 		:= pInterface_tbl.count;
  b_found	BOOLEAN 	:= FALSE;
  pos_not_found	EXCEPTION;
  cOutput_path  VARCHAR2(120);
BEGIN
    if EC_DEBUG.G_debug_level >= 2 then
      EC_DEBUG.PUSH('ECE_FLATFILE_PVT.POS_OF');
      EC_DEBUG.PL(3, 'Row_count : ', l_Row_count);
      end if;
      For k in 1..l_Row_count loop
         if UPPER(nvl(pInterface_tbl(k).interface_column_name, 'NULL')) = UPPER(cCol_name) then
 		b_found := TRUE;
                if EC_DEBUG.G_debug_level >= 2 then
                EC_DEBUG.PL(3, 'Position : ', k);
      		EC_DEBUG.POP('ECE_FLATFILE_PVT.POS_OF');
		end if;
		return(k);
                exit;
	 end if;
      end loop;

      if not b_found
      then
         raise pos_not_found;
      end if;

  if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.POP('ECE_FLATFILE_PVT.POS_OF');
  end if;
EXCEPTION
  WHEN pos_not_found THEN
         fnd_message.set_name('EC','ECE_PLSQL_POS_NOT_FOUND');
         fnd_message.set_token('COLUMN_NAME', upper(cCol_name));
    raise;
  WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_FLATFILE_PVT.POS_OF');
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
         app_exception.raise_exception;

END POS_OF;

END ECE_FLATFILE_PVT;

/
