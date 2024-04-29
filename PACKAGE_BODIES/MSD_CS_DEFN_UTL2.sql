--------------------------------------------------------
--  DDL for Package Body MSD_CS_DEFN_UTL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CS_DEFN_UTL2" as
/* $Header: msdcsu2b.pls 115.8 2003/11/04 18:40:57 dkang ship $ */


    g_defn_para_list  g_type_defn_para_rec_list;

Procedure build_para_list (
        p_instance        in number,
        p_coll_cond       in varchar2,
        p_pull_cond       in varchar2) is
Begin

    if g_defn_para_list.exists(1) then
        g_defn_para_list.delete;
    end if;

    build_para_list (
        p_instance,
        p_coll_cond ,
        p_pull_cond ,
        g_defn_para_list);
End;


/******************************** Main function *************************/

Procedure build_para_list (
    p_instance        in number,
    p_coll_cond       in varchar2,
    p_pull_cond       in varchar2,
    p_defn_para_list in out NOCOPY g_type_defn_para_rec_list
) is
    l_list    g_type_defn_para_rec_list:=g_type_defn_para_rec_list();
Begin
    g_defn_para_list  := g_type_defn_para_rec_list();
    build_gen_para_list ( p_instance, p_coll_cond, l_list);
    build_gen_para_list ( p_instance, p_pull_cond, l_list);
    p_defn_para_list := l_list;
End;



/**************************************
   Format of Additional Where Clause for CHAR type

   'CHAR:Prompt_Name:ValueSet_Name:Remote_Yes_No:Multi_Yes_NO:
    Default_Column_Name_For_Multi:Default_Value_For_Single'

   CHAR:           Datatype
   Prompt_Name:    Name of message for the prompt
   ValueSet_Name:  Name of ValueSet defined in planning server
   Remote_Yes_No:  Y or N flag for the value set.
                   Y means execute the value set sql stmt in remote database.
                   N means execute the value set sql stmt in the planning server.
   Multi_Yes_No:   Y or N flag to indicate whether this input parameter
                   is for the multiple input para or not
   Default_Column_Name For Multi: Name of column in the source view, which will be
                                  used in sql stmt if none of the multiple input para
                                  was entered in the collection forms.
   Default_Code_For_Single:  Code that user want to default to the feild.
                             This property can only be applied to
                             local value set, remote_yes_no = NO.
                             It will be a code for the value set rather than
                             actual desc.
                             Example of this values are 'Y/N','21' for id...etc
**************************************/

Procedure build_gen_para_list (
    p_instance           in number,
    p_cond               in varchar2,
    p_defn_para_list in out NOCOPY g_type_defn_para_rec_list
) is

    l_list    g_type_defn_para_rec_list:=g_type_defn_para_rec_list();
    /* , null, null, null, null, null, null, null, null */
    start_pos        number;
    end_pos          number;
    para_type        varchar2(10);

    i   number:=0;
    l_ctr   number :=0;
    l_cnt   number;

    l_dblink           varchar2(100) := NULL;
    l_val_col          varchar2(240) := NULL;
    l_id_col           varchar2(240) := NULL;
    l_retcode	       number := 0;
    l_remote_flag     varchar2(3)  := 'N';


Begin
    if p_cond is null then
        return;
    end if;

    while TRUE
    loop
        l_ctr := l_ctr + 1;
        start_pos := instr(p_cond, '&&', 1, l_ctr);
        if start_pos = 0 then
            exit;
        end if;

        para_type := substr(p_cond, start_pos + 2, 7);
        end_pos   := instr(p_cond, '''', start_pos);
        l_list.extend;

--   'CHAR:Prompt_Name:ValueSet_Name:Remote_Yes_No:Multi_Yes_NO:Default_Column_Name_For_Multi:code'

        IF substr(upper(para_type), 1, 5) = 'CHAR:' then /* Character type */
            l_list(l_ctr).para_type := 'CHAR';
            l_list(l_ctr).para_name := msd_cs_defn_utl2.get_char_property(p_cond, start_pos, end_pos, 1);
            l_list(l_ctr).vs_name   := msd_cs_defn_utl2.get_char_property(p_cond, start_pos, end_pos, 2);
            l_remote_flag := msd_cs_defn_utl2.get_char_property(p_cond, start_pos, end_pos, 3);
            l_list(l_ctr).multi_input_flag :=
                      nvl(upper(msd_cs_defn_utl2.get_char_property(p_cond, start_pos, end_pos, 4)), 'N');
            /* remote dblink flag is set to Y */
            IF (upper(l_remote_flag) = 'Y' and p_instance is not NULL) THEN
               msd_common_utilities.get_db_link(p_instance, l_dblink, l_retcode);
               l_list(l_ctr).sql_stmt :=
                               genereate_sql_from_vs(l_list(l_ctr).vs_name,
                                                     l_dblink, l_val_col,l_id_col);
            ELSE
               l_list(l_ctr).sql_stmt :=
                               genereate_sql_from_vs(l_list(l_ctr).vs_name, null,
                                                     l_val_col, l_id_col);
            END IF;

            l_list(l_ctr).default_code := msd_cs_defn_utl2.get_char_property(p_cond, start_pos, end_pos, 6);
            IF l_list(l_ctr).default_code IS NOT NULL THEN
               l_list(l_ctr).default_val :=  get_default_value(l_val_col,
                                                               l_id_col,
                                                               l_list(l_ctr).sql_stmt,
                                                               l_list(l_ctr).default_code);
               /* If default value comes out to be null then make code null as well */
               IF l_list(l_ctr).default_val is NULL THEN
                  l_list(l_ctr).default_code := NULL;
               END IF;
            END IF;
        elsif substr(upper(para_type), 1, 7) = 'NUMBER:' then -- Number type
            l_list(l_ctr).para_type := 'NUMBER';
            l_list(l_ctr).para_name := substr(p_cond, start_pos+9, ((end_pos) - (start_pos+9))) ;
        elsif substr(upper(para_type), 1, 5) = 'DATE:' then /* Date type */
            l_list(l_ctr).para_type := 'DATE';
            l_list(l_ctr).para_name := substr(p_cond, start_pos+7, ((end_pos) - (start_pos+7))) ;
        END IF;

    end loop;

    IF l_list.exists(1) THEN
       if l_list(1).para_name is not null then
           /* Append parameters to return (IO) parameter */
           l_cnt   := p_defn_para_list.count;
           for j in 1.. l_list.count loop
              p_defn_para_list.extend;
              l_cnt := l_cnt + 1;
              p_defn_para_list(l_cnt) := l_list(j);
              fnd_message.set_name('MSD', l_list(j).para_name);
              p_defn_para_list(l_cnt).message := fnd_message.get;
           end loop;
       end if;
    END IF;

End;


/**********************************************************************
  Function to return char property in additional where clause
************************************************************************/
-- 'CHAR:Prompt_Name:ValueSet_Name:Remote_Yes_No:Multi_Yes_NO:Default_Column_Name_For_Multi'

Function get_char_property( p_cond varchar2,
                            p_start_pos number,
                            p_end_pos   number,
                            p_index number) return varchar2 IS

l_output varchar(1000);
l_para_start_pos  NUMBER;
l_para_end_pos    NUMBER;

BEGIN

   IF (p_index is null OR p_index <= 0) THEN
      return null;
   END IF;

   l_para_start_pos := instr(p_cond, ':', p_start_pos, p_index);
   IF (l_para_start_pos = 0 or l_para_start_pos >= p_end_pos ) THEN
      l_para_start_pos := 0;
   END IF;

   l_para_end_pos   := instr(p_cond, ':', p_start_pos, p_index + 1);
   IF (l_para_end_pos = 0 or l_para_end_pos >= p_end_pos ) THEN
      l_para_end_pos := p_end_pos;
   END IF;

   IF l_para_start_pos = 0 THEN
      l_output := NULL;

   ELSE
      l_output := substr(p_cond, l_para_start_pos + 1,
                         l_para_end_pos - (l_para_start_pos + 1) );
   END IF;

   return l_output;

END get_char_property;


/*************************  Function generate sql from value set ****************/
Function genereate_sql_from_vs( p_vs_name IN  varchar2,
                                p_dblink  IN  varchar2,
                                p_val_col IN OUT nocopy varchar2,
                                p_id_col  IN OUT nocopy varchar2) return varchar2 IS

CURSOR c_vs_id IS
SELECT flex_value_set_id
FROM fnd_flex_value_sets where upper(flex_value_set_name) = upper(p_vs_name);

CURSOR c_sql(p_vs_id NUMBER) IS
SELECT application_table_name,
       value_column_name, id_column_name,
       additional_where_clause
FROM fnd_flex_validation_tables
WHERE flex_value_set_id = p_vs_id;

l_vs_id             NUMBER;
l_table_name        VARCHAR2(40);
l_value_col         VARCHAR2(40);
l_id_col            VARCHAR2(40);
l_where_clause      VARCHAR2(2000);

l_sql_stmt          VARCHAR2(2000);

BEGIN
   OPEN c_vs_id;
   FETCH c_vs_id INTO l_vs_id;
   CLOSE c_vs_id;

   IF (l_vs_id IS NOT NULL) THEN
       OPEN c_sql(l_vs_id);
       FETCH c_sql INTO l_table_name,
                        l_value_col,
                        l_id_col,
                        l_where_clause;
       CLOSE c_sql;


       l_sql_stmt := 'SELECT ' ||
                     l_value_col || ', '||
                     l_id_col || ' ' ||
                     'FROM ' || l_table_name || p_dblink || ' ' ||
                     l_where_clause;
   END IF;

   p_val_col := l_value_col;
   p_id_col  := l_id_col;

   return l_sql_stmt;
END;


/*************************  Function to return num count in array ****************/
Function counts return number is
Begin
    return g_defn_para_list.count;
End;

/*************************  Function get Default Value from Defaul code ****************/
Function  get_default_value(p_val_col   IN varchar2,
                            p_id_col    IN varchar2,
                            p_sql_stmt  IN varchar2,
                            p_default_code IN varchar2) return varchar2 IS

TYPE cur_type is ref cursor;

c_val   cur_type;

l_sql_stmt   varchar2(2000);
l_default_val  varchar2(240) := NULL;

BEGIN

   IF (p_default_code IS NOT NULL and
       p_sql_stmt IS NOT NULL and
       p_val_col IS NOT NULL) THEN
      l_sql_stmt := ' SELECT ' || p_val_col ||
                    ' FROM (' || p_sql_stmt || ')' ||
                    ' WHERE ' || p_id_col || ' = :p_default_code';

      OPEN  c_val FOR l_sql_stmt USING p_default_code;
      FETCH c_val INTO l_default_val;
      CLOSE c_val;
   END IF;

   return l_default_val;

END Get_Default_Value;


/*************************  Function get a record from arry ****************/
Procedure get_rec (
    p_index         in  number,
    p_message       in out NOCOPY varchar2,
    p_type          in out NOCOPY varchar2,
    p_sql_stmt      IN OUT NOCOPY varchar2,
    p_multi_flag    in out NOCOPY varchar2,
    p_default_code  in out NOCOPY varchar2,
    p_default_val   in out NOCOPY varchar2) is
Begin
    if g_defn_para_list.exists(p_index) then
        if g_defn_para_list(p_index).message is not null then
            p_message := g_defn_para_list(p_index).message;
        else
            p_message := g_defn_para_list(p_index).para_name;
        end if;
        p_type        := g_defn_para_list(p_index).para_type;
        p_sql_stmt    := g_defn_para_list(p_index).sql_stmt;
        p_multi_flag  := g_defn_para_list(p_index).MULTI_INPUT_FLAG;
        p_default_val := g_defn_para_list(p_index).default_val;
        p_default_code:= g_defn_para_list(p_index).default_code;
    else
 --       p_message  := g_defn_para_list(p_index).para_name;
        p_message := null;
    end if;
End;

End;

/
