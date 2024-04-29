--------------------------------------------------------
--  DDL for Package Body XDO_DGF_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_DGF_RULE_PKG" AS
/* $Header: XDODGFRLB.pls 120.2 2008/01/22 18:40:28 bgkim noship $ */
   g_current_runtime_level           NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
   g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
   g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
   g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
   g_error_buffer                    VARCHAR2(100);


 -- procedure definitions
 PROCEDURE evaluate_rules(p_rule_table IN OUT NOCOPY XDO_DGF_RPT_PKG.RULE_TABLE_TYPE)
 IS
  type arg_table_type is table of varchar2(4000) index by binary_integer;
  i                   integer;
  l_arg_table         arg_table_type;
  l_statement         varchar2(32000);
  l_cur_handler       integer;
  k                   integer;
  l_return_char       varchar2(4000);
  l_ret               number;
 BEGIN
   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'xdo_dgf_rule_pkg.evaluate_rules',
                     'start:p_rule_table.count = ' || p_rule_table.count );
   END IF;
   i:= p_rule_table.first;
   LOOP

     IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'xdo_dgf_rule_pkg.evaluate_rules',
                       p_rule_table(i).rule_variable || ' ' ||
                       p_rule_table(i).rule_operator || ' ' ||
                       p_rule_table(i).rule_values);
     END IF;

     IF   p_rule_table(i).rule_type IN ('F','P') THEN

          p_rule_table(i).return_value := eval_simple_rule(
                                                    p_rule_table(i).rule_variable,
                                                    p_rule_table(i).rule_operator,
                                                    p_rule_table(i).rule_values,
                                                    p_rule_table(i).rule_values_datatype);
     ELSIF p_rule_table(i).rule_type = 'D' THEN

       IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                         'xdo_dgf_rule_pkg.evaluate_rules',
                         'rule_type=''D''');
       END IF;

       l_arg_table(1) := p_rule_table(i).arg01;
       l_arg_table(2) := p_rule_table(i).arg02;
       l_arg_table(3) := p_rule_table(i).arg03;
       l_arg_table(4) := p_rule_table(i).arg04;
       l_arg_table(5) := p_rule_table(i).arg05;
       l_arg_table(6) := p_rule_table(i).arg06;
       l_arg_table(7) := p_rule_table(i).arg07;
       l_arg_table(8) := p_rule_table(i).arg08;
       l_arg_table(9) := p_rule_table(i).arg09;
       l_arg_table(10) := p_rule_table(i).arg10;
       l_statement := 'begin :1 := ' || p_rule_table(i).db_function;

       IF p_rule_table(i).arg_number > 0 THEN

         IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                           'xdo_dgf_rule_pkg.evaluate_rules',
                           'arg_number > 0');
         END IF;

         l_statement := l_statement || '(';
         -- for k in 2..(p_rule_table(i).arg_number + 1)
         k := 2;
         LOOP
           l_statement := l_statement || ':' || k;
           EXIT WHEN k = p_rule_table(i).arg_number + 1;
           k := k + 1;
           l_statement := l_statement || ',';
         END LOOP;
         l_statement := l_statement || ')';
       END IF;
       l_statement := l_statement || '; end;';

       IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                           'xdo_dgf_rule_pkg.evaluate_rules',
                           'before open cursor: l_statement = '
                           || l_statement);
       END IF;

       l_cur_handler := dbms_sql.open_cursor;
       dbms_sql.parse(l_cur_handler,l_statement,2);
       FOR j IN 2..(p_rule_table(i).arg_number + 1)
       LOOP
         dbms_sql.bind_variable(l_cur_handler,j ||'',l_arg_table(j-1));
       END LOOP;
       dbms_sql.bind_variable(l_cur_handler,'1', l_return_char, 2000);
       l_ret := dbms_sql.execute(l_cur_handler);
       dbms_sql.variable_value(l_cur_handler,'1', l_return_char);
       dbms_sql.close_cursor(l_cur_handler);

       IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                           'xdo_dgf_rule_pkg.evaluate_rules',
                           'Cursor closed. l_return_char = ' || l_return_char);
       END IF;

       p_rule_table(i).return_value := eval_simple_rule(l_return_char,
                                                        p_rule_table(i).rule_operator,
                                                        p_rule_table(i).rule_values,
                                                        p_rule_table(i).rule_values_datatype);

    END IF; -- ELSIF p_rule_table(i).rule_type = 'D' THEN
   EXIT WHEN i = p_rule_table.last;
   i := p_rule_table.next(i);
   END LOOP;

   IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                           'xdo_dgf_rule_pkg.evaluate_rules',
                           'END: p_rule_table.count = ' || p_rule_table.count);
   END IF;

 END;


 FUNCTION eval_simple_rule(p_rule_var             IN varchar2,
                           p_rule_operator        IN varchar2,
                           p_rule_values          IN varchar2,
                           p_rule_values_datatype IN varchar2)

 RETURN boolean
 IS
   l_return_value          boolean        := false;
   l_list_value            varchar2(4000) := p_rule_values;
   l_single_value          varchar2(4000);
   l_separator_index       integer;
   l_rule_var              number; -- for the p_rule_values_datatype = 'N'

 BEGIN
   CASE p_rule_operator
   WHEN '=' THEN
     IF p_rule_values_datatype = 'C'  THEN
        l_return_value := p_rule_var = p_rule_values;
     ELSIF p_rule_values_datatype = 'N' THEN
        l_return_value := to_number(p_rule_var) = to_number(p_rule_values);
     END IF;
   WHEN 'LIKE' THEN
     l_return_value := p_rule_var LIKE p_rule_values;
   WHEN 'IN'   THEN
     IF p_rule_values_datatype = 'C' THEN
       LOOP
         l_separator_index := instr(l_list_value, fnd_global.local_chr(10));
         IF l_separator_index = 0 THEN
            l_return_value := p_rule_var = l_list_value;
         ELSE l_return_value := p_rule_var =
                rtrim(substr(l_list_value,1,l_separator_index - 1 ), fnd_global.local_chr(13));
              l_list_value := substr(l_list_value,l_separator_index + 1);
         END IF;
         EXIT WHEN l_separator_index = 0 or l_return_value;
       END LOOP;
     ELSIF p_rule_values_datatype = 'N' THEN
        l_rule_var := to_number(p_rule_var);
        LOOP
          l_separator_index := instr(l_list_value, fnd_global.local_chr(10));
          IF l_separator_index = 0  THEN
             l_return_value := l_rule_var = to_number(l_list_value);
          ELSE l_return_value := l_rule_var =
               to_number(rtrim(substr(l_list_value,1,l_separator_index - 1 ),fnd_global.local_chr(13)));
               l_list_value := substr(l_list_value,l_separator_index + 1);
          END IF;
          EXIT WHEN l_separator_index = 0 or l_return_value;
        END LOOP;
     END IF;
   WHEN '<' THEN
     IF p_rule_values_datatype = 'N' THEN
        l_return_value := to_number(p_rule_var) < to_number(p_rule_values);
     ELSIF p_rule_values_datatype = 'C' THEN
        l_return_value := p_rule_var < p_rule_values;
     END IF;
   WHEN '<=' THEN
     IF p_rule_values_datatype = 'N' THEN
        l_return_value := to_number(p_rule_var) <= to_number(p_rule_values);
     ELSIF p_rule_values_datatype = 'C' THEN
        l_return_value := p_rule_var <= p_rule_values;
     END IF;
   WHEN '>'  THEN
      IF p_rule_values_datatype = 'N' THEN
        l_return_value := to_number(p_rule_var) > to_number(p_rule_values);
      ELSIF p_rule_values_datatype = 'C' THEN
        l_return_value := p_rule_var > p_rule_values;
      END IF;
   WHEN '>=' THEN
      IF p_rule_values_datatype = 'N' THEN
        l_return_value := to_number(p_rule_var) >= to_number(p_rule_values);
      ELSIF p_rule_values_datatype = 'C' THEN
        l_return_value := p_rule_var >= p_rule_values;
      END IF;
   WHEN '<>' THEN
     IF p_rule_values_datatype = 'C' THEN
       l_return_value := p_rule_var <> p_rule_values;
     ELSIF p_rule_values_datatype = 'N' THEN
       l_return_value := to_number(p_rule_var) <> to_number(p_rule_values);
     END IF;
   END CASE;

   RETURN l_return_value;
 END;

 FUNCTION evaluate_rules(p_rule_table IN XDO_DGF_RPT_PKG.RULE_TABLE_TYPE)
 RETURN XDO_DGF_RPT_PKG.RULE_TABLE_TYPE
 IS
  l_rule_table XDO_DGF_RPT_PKG.RULE_TABLE_TYPE;
 BEGIN
   l_rule_table := p_rule_table;
   evaluate_rules(l_rule_table);
   RETURN l_rule_table;
 END;
END xdo_dgf_rule_pkg;

/
