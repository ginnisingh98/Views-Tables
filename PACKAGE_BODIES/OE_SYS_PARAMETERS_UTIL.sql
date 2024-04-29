--------------------------------------------------------
--  DDL for Package Body OE_SYS_PARAMETERS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SYS_PARAMETERS_UTIL" AS
/* $Header: OEXUSPMB.pls 120.2 2006/02/22 01:26:19 rmoharan noship $ */

-- Start of comments
-- API name         : Get_Value_from_Table
-- Type             : Public
-- Description      : This api will get the value from the table based on table information and the code
-- Parameters       :
-- IN               : p_table_r  IN fnd_vset.table_r       required
--                     Table information
--                    p_code     IN VARCHAR2               required
--                      Code/id for which value to be retrived
-- OUT                x_value    OUT  VARCHAR2
--                      value for the code
-- End of Comments
   PROCEDURE Get_Value_from_Table(p_table_r  IN fnd_vset.table_r,
                                  p_code     IN VARCHAR2,
  			          x_value    OUT NOCOPY VARCHAR2)
   IS
     l_selectstmt   VARCHAR2(3000) ;
     l_meaning      VARCHAR2(240);
     l_id      VARCHAR2(240);
     l_value        VARCHAR2(240);
     l_cursor_id    INTEGER;
     l_where_clause
         fnd_flex_validation_tables.additional_where_clause%type;
     l_pos1          NUMBER;
     l_where_length  NUMBER;
     l_cols          VARCHAR2(1000);
     l_retval        INTEGER;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   BEGIN
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;
      l_where_clause := p_table_r.where_clause;

      IF instr(upper(l_where_clause),'WHERE ') > 0 then
         --to include the id column name in the query
         l_where_clause:= rtrim(ltrim(l_where_clause));
         l_pos1 := instr(upper(l_where_clause),'WHERE');
         l_where_length :=LENGTHB('WHERE');
         l_where_clause:=
                 substr(l_where_clause,l_pos1+l_where_length);
         IF (p_table_r.id_column_name IS NOT NULL) THEN
            l_where_clause := 'WHERE '||p_table_r.id_column_name
                           ||' = :p1  AND '||l_where_clause;
         ELSE
            l_where_clause := 'WHERE '||p_table_r.value_column_name
                           ||' = :p1  AND '||l_where_clause;
         END IF;
      ELSE
         IF (p_table_r.id_column_name IS NOT NULL) THEN
            l_where_clause := 'WHERE '||p_table_r.id_column_name
                              ||' = :p1 '||l_where_clause;
         ELSE
            l_where_clause := 'WHERE '||p_table_r.value_column_name
                              ||' = :p1 '||l_where_clause;
         END IF;
      END IF;
      l_cols :=p_table_r.value_column_name;

      IF p_table_r.meaning_column_name IS NOT NULL THEN
         l_cols := l_cols||','||p_table_r.meaning_column_name;
      ELSE
         --null;
	 l_cols := l_cols || ', NULL ';
      END IF;

      IF (p_table_r.id_column_name IS NOT NULL) THEN
         IF (p_table_r.id_column_type IN ('D', 'N')) THEN
             l_cols := l_cols || ' , To_char(' ||
                            p_table_r.id_column_name || ')';
         ELSE
             l_cols := l_cols || ' , ' ||
                                p_table_r.id_column_name;
         END IF;
      ELSE
         l_cols := l_cols || ', NULL ';
      END IF;

      l_selectstmt := 'SELECT  '||l_cols||' FROM  '||p_table_r.table_name||' '||l_where_clause;
      DBMS_SQL.PARSE(l_cursor_id,l_selectstmt,DBMS_SQL.NATIVE);

      -- Bind variable
      DBMS_SQL.BIND_VARIABLE(l_cursor_id,':p1',p_code);
      -- Bind the input variables
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id,1,l_value,240);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id,2,l_meaning,240);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id,3,l_id,240);

      l_retval := DBMS_SQL.EXECUTE(l_cursor_id);

      LOOP
         -- Fetch rows in to buffer and check the exit condition from  the loop
         IF( DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0) THEN
            EXIT;
         END IF;

         -- Retrieve the rows from buffer into PLSQL variables
         DBMS_SQL.COLUMN_VALUE(l_cursor_id,1,l_value);
         DBMS_SQL.COLUMN_VALUE(l_cursor_id,2,l_meaning);
         DBMS_SQL.COLUMN_VALUE(l_cursor_id,3,l_id);
         IF l_id IS NOT NULL AND (p_code = l_id) THEN
            --DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
            x_value := l_value;
         ELSIF (p_code = l_value) THEN
            --DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
	    IF l_meaning IS NOT NULL THEN
              x_value := l_meaning;
            ELSE
              x_value := l_value;
	    END IF;
         ELSE
            Null;
           --value does notmatch, continue search
         END IF;

      END LOOP;
      DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
  EXCEPTION
     WHEN OTHERS THEN
        oe_debug_pub.add('Get_value_from_table exception');
        DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

   END Get_Value_from_Table;

-- Start of comments
-- API name         : Get_num_date_from_canonical
-- Type             : Public
-- Description      : This api will convert the value based on format type
-- Parameters       :
-- IN               : p_format_type  IN fnd_vset.table_r       required
--                     Format type information
--                    p_value_code     IN VARCHAR2             required
-- End of Comments
   FUNCTION Get_num_date_from_canonical(p_format_type  IN  VARCHAR2,
                                        p_value_code   IN  VARCHAR2)
   RETURN VARCHAR2
   IS
     l_varchar_out varchar2(2000);
     INVALID_DATA_TYPE EXCEPTION;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   BEGIN
      IF p_format_type  = 'N' THEN
         l_varchar_out :=
             to_char(fnd_number.canonical_to_number(p_value_code));
      ELSIF p_format_type = 'X' THEN
         l_varchar_out :=
                 fnd_date.canonical_to_date(p_value_code);
      ELSIF p_format_type = 'Y' THEN
         l_varchar_out :=
                 fnd_date.canonical_to_date(p_value_code);
      ELSIF p_format_type = 'C' THEN
         l_varchar_out := p_value_code;
      ELSE
         l_varchar_out := p_value_code;

      END IF;
      RETURN l_varchar_out;
   EXCEPTION
      When Others Then
         l_varchar_out := p_value_code;
         RETURN l_varchar_out;

   END Get_num_date_from_canonical;

-- Start of comments
-- API name         : Get_Value
-- Type             : Public
-- Description      : This api will get value for the code based on format type and validation type
--                    rerieved from value_set information
-- Parameters       :
-- IN               : p_value_set_id  IN NUMBER       required
--                    p_value_code     IN VARCHAR2    required
-- End of Comments
   FUNCTION Get_Value(p_value_set_id IN NUMBER,
                      p_value_code   IN VARCHAR2)
   RETURN VARCHAR2
   IS
     l_vset_rec    fnd_vset.valueset_r;
     l_format_rec     fnd_vset.valueset_dr;
     l_found       BOOLEAN;
     l_row         NUMBER;
     l_value_rec   fnd_vset.value_dr;
     l_attr_code   VARCHAR2(240);
     l_attr_value  VARCHAR2(240);
     l_value       VARCHAR2(240);
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --

  BEGIN
     fnd_vset.get_valueset(p_value_set_id,l_vset_rec, l_format_rec);
     l_attr_code := get_num_date_from_canonical
                                (l_format_rec.format_type,p_value_code);
     IF l_vset_rec.validation_type = 'I' THEN
        fnd_vset.get_value_init(l_vset_rec, TRUE);
        fnd_vset.get_value(l_vset_rec, l_row, l_found, l_value_rec);

        IF l_format_rec.Has_Id THEN  --id is defined.Hence compare for id
           WHILE(l_Found) LOOP
              -- 4284156
              l_value_rec.id := get_num_date_from_canonical
                                (l_format_rec.format_type,l_value_rec.id);
              IF l_attr_code  = l_value_rec.id  THEN
                 l_attr_value := l_value_rec.value;
                 EXIT;
              END IF;
              FND_VSET.get_value(l_Vset_rec,l_Row,l_Found,l_Value_rec);
           END LOOP;
        ELSE   -- id not defined.Hence compare for value
           WHILE(l_Found) LOOP
             -- bug 4284156
              l_value_rec.value := get_num_date_from_canonical
                                (l_format_rec.format_type,l_value_rec.value);
              IF l_attr_code  = l_value_rec.value  THEN
                 --5048979
                 l_attr_value := l_value_rec.value; -- l_attr_code;
                 EXIT;
              END IF;
              FND_VSET.get_value(l_Vset_rec,l_Row,l_Found,l_Value_rec);
           END LOOP;
        END IF;
        fnd_vset.get_value_end(l_vset_rec);

     ELSIF l_vset_rec.validation_type = 'F' THEN
        Get_value_from_table(l_vset_rec.table_info,
                             l_attr_code,
                             l_value);
        l_attr_value  := l_value;

/*       IF l_Format_rec.Has_Id Then --id is defined.Hence compare for id
          IF  l_attr_code  = l_id  THEN
             l_attr_value  := l_value;
          END IF;
       ELSIF  l_attr_code  = l_value  THEN
          l_attr_value  := l_value;
       END IF;
*/
     ELSE -- if validation type is not F or I or valueset id is null (not defined)
        l_attr_value := l_attr_code;
     END IF;
     RETURN l_attr_value;

   END Get_Value;

END OE_SYS_PARAMETERS_UTIL;

/
