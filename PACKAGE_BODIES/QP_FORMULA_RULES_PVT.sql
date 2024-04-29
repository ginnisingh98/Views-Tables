--------------------------------------------------------
--  DDL for Package Body QP_FORMULA_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_FORMULA_RULES_PVT" AS
/* $Header: QPXPFORB.pls 120.2.12010000.3 2009/05/07 07:41:02 smbalara ship $ */

g_schema                VARCHAR2(30);
g_conc_mode             VARCHAR2(1);
line_number             NUMBER := 0;
segment_ctr             NUMBER := 0;


PROCEDURE Put_Line (Text Varchar2)
IS
BEGIN

   if g_conc_mode is null then

     if nvl(fnd_profile.value('CONC_REQUEST_ID'),0) <> 0 then
          g_conc_mode := 'Y';
     else
          g_conc_mode := 'N';
     end if;

   end if;

   if g_conc_mode = 'Y' then
     FND_FILE.PUT_LINE(FND_FILE.LOG, Text);
   end if;

END Put_Line;

PROCEDURE Init_Applsys_Schema
IS
l_app_info              BOOLEAN;
l_status                        VARCHAR2(30);
l_industry              VARCHAR2(30);
BEGIN

   if g_schema is null then

      l_app_info := FND_INSTALLATION.GET_APP_INFO
            ('FND',l_status, l_industry, g_schema);

   end if;

END;

PROCEDURE New_Line
IS
BEGIN

    line_number := line_number + 1;
    ad_ddl.build_package(' ',line_number);
--       oe_debug_pub.add(' ');

END New_Line;

PROCEDURE Text
(   p_string    IN  VARCHAR2
,   p_level     IN  NUMBER default 1
)
IS
BEGIN

    line_number := line_number + 1;
    ad_ddl.build_package(LPAD(p_string,p_level*2+LENGTH(p_string)),line_number);
--       oe_debug_pub.add(LPAD(p_string,p_level*2+LENGTH(p_string)));
    --dbms_output.put_line(LPAD(p_string,p_level*2+LENGTH(p_string)));

END text;

PROCEDURE Formula_Text
(   p_string    IN  VARCHAR2
)
IS
TYPE T_FORMULA_TAB_TYPE IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
l_formula_tab T_FORMULA_TAB_TYPE;
l_formula varchar2(32000) := p_string;
l_length number;
l_start number:=1;
i integer := 0;
j integer := 1;
BEGIN
  l_length := length(l_formula);
  select replace(l_formula,'''','''''') into l_formula from dual;--6726052,7249280 smbalara
  while (l_length > 200)
  loop
     i := i + 1;
     l_formula_tab(i) := substr(l_formula,l_start,200);
     l_start := l_start + 200;
     l_length := l_length - 200;
  end loop;
  i := i + 1;
  l_formula_tab(i) := substr(l_formula,l_start,200);

  Text('''''',1);
  while (j <= i)
  loop
    Text(' || ''' || l_formula_tab(j) || '''',2);
    j := j + 1;
  end loop;

END Formula_Text;

PROCEDURE Comment
(   p_comment       IN  VARCHAR2
,   p_level         IN  NUMBER default 1
)
IS
BEGIN

    Text('--  '||p_comment,p_level);

END Comment;

PROCEDURE Break_Text(p_string  IN  VARCHAR2, p_level     IN  NUMBER default 1)
IS

  l_value_string varchar2(32000) := p_string;
  l_temp1 varchar2(32000);
  l_temp2 varchar2(32000);

  lp_position number := 0;
  rp_position number := 0;
  c_position number := 0;
  s_position number := 0;
  p number := 0;

begin

  while length(l_value_string) > 200 loop

      lp_position := 0;
      rp_position := 0;
      c_position := 0;
      s_position := 0;
      p := 0;

      lp_position := instr(l_value_string,'(');
      rp_position := instr(l_value_string,')');
      c_position := instr(l_value_string,',');
      s_position := instr(l_value_string,' ');

      if (lp_position > 0) and (p = 0) then
         p := lp_position;
      elsif (c_position > 0) and (p = 0) then
         p:= c_position;
      elsif (s_position > 0) and (p = 0) then
         p:= s_position;
      elsif (rp_position > 0) and (p = 0) then
         p:= rp_position;
      end if;

      if (lp_position > 0) and (lp_position <= 200)  then
         l_temp1 := substr(l_value_string,1,lp_position);
         l_temp2 := substr(l_value_string,lp_position+1);
         l_value_string := l_temp2;
         Text(l_temp1 , p_level);
      elsif (c_position > 0) and (c_position <= 200) then
         l_temp1 := substr(l_value_string,1,c_position);
         l_temp2 := substr(l_value_string,c_position+1);
         l_value_string := l_temp2;
         Text(l_temp1 , p_level);
      elsif (s_position > 0) and (s_position <= 200) then
         l_temp1 := substr(l_value_string,1,s_position);
         l_temp2 := substr(l_value_string,s_position+1);
         l_value_string := l_temp2;
         Text(l_temp1 , p_level);
      elsif (rp_position > 0) and (rp_position <= 200) then
         l_temp1 := substr(l_value_string,1,rp_position);
         l_temp2 := substr(l_value_string,rp_position+1);
         l_value_string := l_temp2;
         Text(l_temp1 , p_level);
      else
         l_temp1 := substr(l_value_string,1,p);
         l_temp2 := substr(l_value_string,p+1);
         l_value_string := l_temp2;
         Text(l_temp1 , p_level);
      end if;
  end loop;

  if length(l_value_string) > 0 then
     Text(l_value_string || ';' , p_level);
  end if;
END Break_Text;


PROCEDURE Pkg_End
(   p_pkg_name  IN  VARCHAR2
,   p_pkg_type  IN  VARCHAR2
)
IS

l_is_pkg_body                   VARCHAR2(30);
n                               NUMBER := 0;
l_pkg_name                      VARCHAR2(30);
l_new_pkg_name  CONSTANT        VARCHAR2(30) := 'QP_BUILD_FORMULA_RULES';
v_segment_id                    number;
v_count                         BINARY_INTEGER := 1;
CURSOR errors IS
        select line, text
        from user_errors
        where name = upper(l_pkg_name)
          and type = decode(p_pkg_type,'SPEC','PACKAGE',
                                        'BODY','PACKAGE BODY');
BEGIN

    --  end statement.
    Text('END '||p_pkg_name||';',0);

    --  Show errors.
    IF p_pkg_type = 'BODY' THEN
        l_is_pkg_body := 'TRUE';
    ELSE
        l_is_pkg_body := 'FALSE';
    END IF;

    PUT_LINE( 'Call AD_DDL to create '||p_pkg_type||' of package '||p_pkg_name);
    oe_debug_pub.add('Call AD_DDL to create '||p_pkg_type||' of package '||p_pkg_name);


    ad_ddl.create_package(applsys_schema              => g_schema
                         ,application_short_name      => 'QP'
                         ,package_name                => p_pkg_name
                         ,is_package_body             => l_is_pkg_body
                         ,lb                          => 1
                         ,ub                          => line_number);

    -- if there were any errors when creating this package, print out
    -- the errors in the log file
    l_pkg_name := p_pkg_name;
    FOR error IN errors LOOP
         if n= 0 then
           PUT_LINE('ERROR in creating PACKAGE '||p_pkg_type||' :'||p_pkg_name);
            oe_debug_pub.add('ERROR in creating PACKAGE '||p_pkg_type||' :'||p_pkg_name);
        end if;
           PUT_LINE('LINE :'||error.line||' '||substr(error.text,1,200));
           oe_debug_pub.add('LINE :'||error.line||' '||substr(error.text,1,200));
           n := 1;
    END LOOP;

    -- if there was an error in compiling the package, raise
    -- an error
    if  n > 0 then
          RAISE FND_API.G_EXC_ERROR;
    end if;


    IF n = 0 THEN
       --no errors in the QP_BUILD_FORMULA_RULES_TMP
       --now go ahead generate the package
       --as QP_BUILD_FORMULA_RULES

       PUT_LINE('PACKAGE '||p_pkg_type||' Name to :' ||l_pkg_name||' compiled successfully ');

       oe_debug_pub.add('PACKAGE '||p_pkg_type||' Name to :' || l_pkg_name||' compiled successfully ');

       PUT_LINE('Now create PACKAGE '||p_pkg_type||' : ' ||l_new_pkg_name);

       oe_debug_pub.add('Now create PACKAGE '||p_pkg_type||' : ' ||l_new_pkg_name);

       IF instr(ad_ddl.glprogtext(1),p_pkg_name) > 0 THEN

          ad_ddl.glprogtext(1) := REPLACE(ad_ddl.glprogtext(1)
                                         ,p_pkg_name
                                         ,l_new_pkg_name);

          PUT_LINE('First change : ' ||ad_ddl.glprogtext(1));

          oe_debug_pub.add('First change : ' ||ad_ddl.glprogtext(1));

          ad_ddl.glprogtext(line_number) := REPLACE(ad_ddl.glprogtext(line_number)
                                                   ,p_pkg_name
                                                   ,l_new_pkg_name);

          PUT_LINE('Second change : ' ||' '||ad_ddl.glprogtext(line_number));

          oe_debug_pub.add('Second change : ' ||' '||ad_ddl.glprogtext(line_number));

          PUT_LINE('Trying to create PACKAGE '||p_pkg_type ||' :'||l_new_pkg_name);

          oe_debug_pub.add('Trying to create PACKAGE '||p_pkg_type ||' :'||l_new_pkg_name);

          ad_ddl.create_package(applsys_schema         => g_schema
                               ,application_short_name => 'QP'
                               ,package_name           => l_new_pkg_name
                               ,is_package_body        => l_is_pkg_body
                               ,lb                     => 1
                               ,ub                     => line_number);

          l_pkg_name := l_new_pkg_name;

          -- if there were any errors
          -- when creating this package, print out
          -- the errors in the log file
          FOR error IN errors LOOP
              if n = 0 then
                 PUT_LINE('ERROR in creating PACKAGE ' ||p_pkg_type||' :'||l_pkg_name);

                 oe_debug_pub.add('ERROR in creating PACKAGE ' ||p_pkg_type||' :'||l_pkg_name);

               end if;
               PUT_LINE('LINE :'||error.line||' ' ||substr(error.text,1,200));

               oe_debug_pub.add('LINE :'||error.line||' ' ||substr(error.text,1,200));
               n := 1;
          END LOOP;

          -- if there was an error in compiling the package, raise
          -- an error

          if  n > 0 then
              RAISE FND_API.G_EXC_ERROR;
          end if;

          PUT_LINE('Generated PACKAGE '||p_pkg_type ||' :'||l_new_pkg_name ||' Successfully');

          oe_debug_pub.add('Generated PACKAGE '||p_pkg_type ||' :'||l_new_pkg_name ||' Successfully');

       ELSE
          null;
       END IF;--instr
    END IF;--n=0

    exception
    when FND_API.G_EXC_ERROR then
        raise FND_API.G_EXC_ERROR;
    when others THEN
         raise_application_error(-20000,SQLERRM||' '||ad_ddl.error_buf);
--      PUT_LINE('Iam into exception' ||ad_ddl.error_buf);
--        RAISE FND_API.G_EXC_ERROR;

END Pkg_End;

-- Generates the Package Header for the package SPEC and BODY
PROCEDURE Pkg_Header
(   p_pkg_name  IN  VARCHAR2
,   p_pkg_type  IN  VARCHAR2
)
IS
header_string           VARCHAR2(200);
BEGIN

    -- Initialize line number
    line_number := 0;

--      Define package.

    IF p_pkg_type = 'BODY' THEN
        Text ('CREATE or REPLACE PACKAGE BODY '||
                p_pkg_name|| ' AS',0);
    ELSE
        Text ('CREATE or REPLACE PACKAGE '||
                p_pkg_name|| ' AUTHID CURRENT_USER AS',0);
    END IF;

    --  $Header clause.
    header_string := 'Header: QPXVBSFB.pls 115.0 '||sysdate||' 11:11:11 appldev ship ';
        Text('/* $'||header_string||'$ */',0);
        New_Line;

    --  Copyright section.

    Comment ( '',0 );
    Comment (
        'Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA',0);
    Comment ( 'All rights reserved.',0);
    Comment ( '',0);
    Comment ( 'FILENAME',0);
    Comment ( '',0);
    Comment ( '    '||p_pkg_name,0);
    Comment ( '',0);
    Comment ( 'DESCRIPTION',0);
    Comment ( '',0);
    Comment ( '    '||INITCAP(p_pkg_type)||' of package '
                ||p_pkg_name,0);
    Comment ( '',0);
    Comment ('NOTES',0);
    Comment ( '',0);
    Comment ('HISTORY',0);
    Comment ( '',0);
    Comment ( TO_CHAR(SYSDATE)||' Created',0);
    Comment ( '',0);
    New_Line;

    --  Global constant holding package name.

    IF p_pkg_type = 'BODY' THEN
        Comment ( 'Global constant holding the package name',0);
        --Text (RPAD('G_PKG_NAME',30)||'CONSTANT '||
        --            'VARCHAR2(30) := '''||p_pkg_name||''';',0);
        New_Line;
    END IF;

END Pkg_Header;


PROCEDURE FORMULAS
(err_buff                out NOCOPY /* file.sql.39 change */ VARCHAR2,
 retcode                 out NOCOPY /* file.sql.39 change */ NUMBER)
IS

  CURSOR price_formulas_cur
  IS
    SELECT distinct formula
    FROM   qp_price_formulas_b
    WHERE NVL(end_date_active,SYSDATE) >= SYSDATE;  --Added for 5713302 to discard expired formulas

l_price_formula_id       NUMBER := NULL;
l_result                 NUMBER;

l_formula_string         VARCHAR2(32000) := '';
l_formula                VARCHAR2(32000) := '';
l_number                 VARCHAR2(32000) := '';
l_component_string       VARCHAR2(32000) := '';
l_temp_component_string  VARCHAR2(32000) := '';
l_using_clause           VARCHAR2(32000) := '';
l_new_formula            VARCHAR2(32000) := '';
l_temp_new_formula       VARCHAR2(32000) := '';
l_select_stmt            VARCHAR2(32000) := '';
l_expression             VARCHAR2(32000) := '';
l_temp_formula           VARCHAR2(32000) := '';
l_category               VARCHAR2(30) := '';
l_char                   VARCHAR2(1) := '';
ctr                      number:=0;  -- modified by rassharm 5713302
l_formula_String_f       varchar2(32000):=' ';  -- modified by rassharm 5713302

BEGIN

        oe_debug_pub.add('##### Begin Build Formulas #####');

        Init_Applsys_Schema;

--      Writing out the body




        Pkg_Header('QP_BUILD_FORMULA_RULES_TMP', 'BODY');
        New_Line;
        Text('PROCEDURE Get_Formula_Values',0);
        Text('(    p_Formula                      IN VARCHAR2',0);
        Text(',    p_Operand_Tbl                  IN QP_FORMULA_RULES_PVT.t_Operand_Tbl_Type',0);
        Text(',    p_procedure_type               IN VARCHAR2',0);  --sfiresto
        Text(',    x_formula_value                OUT NOCOPY /* file.sql.39 change */ NUMBER',0);
        Text(',    x_return_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2',0);
        Text(')',0);
        Text('IS',0);

    -- modified by rassharm 5713302 --6726052,7249280 smbalara
   --   New_line;
   --   Text('l_oper   QP_FORMULA_RULES_PVT.t_Operand_Tbl_Type; ',0);
   -- end


        New_line;
        Text('BEGIN',0);
        Text('BEGIN',1);
        Text('NULL;',2);
        New_Line;


  FOR l_rec IN price_formulas_cur
  LOOP

     l_formula_string := '';
     l_formula := '';
     l_char := '';
     l_number := '';
     l_component_string := '';
     l_temp_component_string := '';
     l_new_formula := '';
     l_temp_new_formula := '';
     l_using_clause := '';
     l_select_stmt := '';

     l_formula := l_rec.formula;
     --dbms_output.put_line('l_formula - ' || substr(l_formula,1,220));

     FOR i IN 1..LENGTH(l_formula)
     LOOP

       l_char := SUBSTR(l_formula, i, 1);

       IF (l_char = '0') OR (l_char = '1') OR (l_char = '2') OR (l_char = '3') OR
          (l_char = '4') OR (l_char = '5') OR (l_char = '6') OR (l_char = '7') OR
          (l_char = '8') OR (l_char = '9')
       THEN
         --If retrieved character is a digit
         l_number := l_number || l_char;

         IF i = LENGTH(l_formula) THEN
           BEGIN
             l_component_string :=  'p_Operand_Tbl(' || l_number || ')' ;
             l_temp_component_string :=  ':p_Operand_Tbl' || l_number;
             l_using_clause :=  l_using_clause || l_component_string || ',';
           EXCEPTION
             WHEN OTHERS THEN
               l_component_string :=  '';
               l_temp_component_string :=  '';
           END;

         -- modidied by rassharm 5713302
          /*IF instr(l_formula_String_f,'l_oper('||l_number||')')=0  THEN
             Text('l_oper('||l_number||'):=TO_NUMBER(TO_CHAR('||l_component_string ||'));', 0);
             l_Formula_String_f:= l_Formula_String_f||'l_oper('||l_number||')';
         END IF;
         l_new_formula:=l_new_formula||'l_oper('||l_number||')';
         NEW_LINE;
         l_temp_new_formula := l_temp_new_formula || 'TO_NUMBER(' ||'TO_CHAR(' || l_temp_component_string || '))';
         */

	--6726052,7249280 smbalara uncommenting changes
           l_new_formula := l_new_formula || 'TO_NUMBER(' ||
           'TO_CHAR(' || l_component_string || '))';
           l_temp_new_formula := l_temp_new_formula || 'TO_NUMBER(' ||
           'TO_CHAR(' || l_temp_component_string || '))';

          if nvl(l_number,-1)>ctr then--6726052,7249280 smbalara check this
            ctr:=l_number;
          end if;
           l_number := '';
         END IF;

       ELSE -- If character is not a number

         IF l_number IS NOT NULL THEN
            -- Convert number to step_number and append the component value of
            -- that step_number to new_formula
            BEGIN
              l_component_string :=  'p_Operand_Tbl(' || l_number || ')' ;
              l_temp_component_string :=  ':p_Operand_Tbl' || l_number;
              l_using_clause :=  l_using_clause || l_component_string || ',';
            EXCEPTION
              WHEN OTHERS THEN
                l_component_string :=  '';
                l_temp_component_string :=  '';
            END;
             -- modidied by rassharm 5713302
          /*  IF instr(l_formula_String_f,'l_oper('||l_number||')')=0  THEN
             Text('l_oper('||l_number||'):=TO_NUMBER(TO_CHAR('||l_component_string ||'));', 0);
              l_Formula_String_f:= l_Formula_String_f||'l_oper('||l_number||')';
            END IF;
            l_new_formula:=l_new_formula||'l_oper('||l_number||')';
            NEW_LINE;
            l_temp_new_formula := l_temp_new_formula || 'TO_NUMBER(' ||'TO_CHAR(' || l_temp_component_string || '))';
           */
--smbalara uncommenting
            l_new_formula := l_new_formula || 'TO_NUMBER(' ||
                     'TO_CHAR(' || l_component_string || '))';
            l_temp_new_formula := l_temp_new_formula || 'TO_NUMBER(' ||
                     'TO_CHAR(' || l_temp_component_string || '))';

            if nvl(l_number,-1)>ctr then
            ctr:=l_number;
            end if;

            l_number := '';
         END IF;

         l_new_formula := l_new_formula || l_char;
         l_temp_new_formula := l_temp_new_formula || l_char;

       END IF;  -- If character is a number or not

     END LOOP; -- Loop through every character in the Formula String

     --dbms_output.put_line('l_new_formula - ' || substr(l_new_formula,1,220));
     l_temp_formula := substr(l_using_clause,length(l_using_clause),1);
     if (l_temp_formula = ',') then
        l_temp_formula := substr(l_using_clause,1, length(l_using_clause) - 1);
        l_using_clause := l_temp_formula;
     end if;
     --dbms_output.put_line('l_temp_new_form - ' || substr(l_temp_new_formula,1,220));
     --dbms_output.put_line('l_using_clause - ' || substr(l_using_clause,1,220));

     l_temp_formula := ltrim(rtrim(l_new_formula));
     l_new_formula := l_temp_formula;
     l_temp_formula := ltrim(rtrim(l_temp_new_formula));
     l_temp_new_formula := l_temp_formula;
     l_temp_new_formula := REPLACE(l_temp_new_formula,'''','''''');--smbalara 8348005
     Begin
        -- modified by rassharm changed l_expression replacing p_operand_tbl to l_oper for immediate execution 5713302
--        l_expression := 'declare l_res number; TYPE t_Operand_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; l_oper t_Operand_Tbl_Type; begin l_res := ' || l_new_formula || '; end;';
	l_expression := 'declare l_res number; TYPE t_Operand_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; p_Operand_Tbl t_Operand_Tbl_Type; begin l_res := ' || l_new_formula || '; end;';
        --dbms_output.put_line('Exp is - ' || substr(l_expression,1,220));
       execute immediate l_expression;
       l_category := 'EXPRESSION';
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_category := 'EXPRESSION';
       WHEN OTHERS THEN
       Begin
         -- modified by rassharm changed l_expression replacing p_operand_tbl to l_oper for immediate execution 5713302
         --l_expression := 'declare l_res number; TYPE t_Operand_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; l_oper t_Operand_Tbl_Type; begin Select ' || l_new_formula || ' into l_res from dual; end;';
	 l_expression := 'declare l_res number; TYPE t_Operand_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; p_Operand_Tbl t_Operand_Tbl_Type; begin Select ' || l_new_formula || ' into l_res from dual; end;';
        --dbms_output.put_line('Exp is - ' || substr(l_expression,1,220));
        Text(' dbms_output.put_line('''||  l_expression||''');',3);
         execute immediate l_expression;
         l_category := 'PLSQL';
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_category := 'PLSQL';
         WHEN OTHERS THEN
         Begin
           l_category := 'SQL';
         End;
       End;
     END;

     --dbms_output.put_line('Category - ' || l_category || ' Formula_Id - ' || l_price_formula_id);

     Text('IF p_Formula = ',2);
     Formula_Text(l_formula);
     Text(' THEN', 2);
     Text('IF p_procedure_type != ''S'' THEN', 3); --sfiresto
     New_Line;
     IF l_category = 'EXPRESSION' THEN
        --Break_Text('oe_debug_pub.add(''Formula - ' || l_new_formula || ''')',4);
        Break_Text('x_formula_value := ' || l_new_formula, 4);
        Text('x_return_status := ''S''' || ';',4);
        --dbms_output.put_line('IN EXPRESSION ');
     ELSIF l_category = 'PLSQL' THEN
        --Break_Text('oe_debug_pub.add(''Formula - ' || l_new_formula || ''')',4);
        l_select_stmt := 'SELECT '|| l_new_formula || ' INTO x_formula_value FROM DUAL';
        Break_Text(l_select_stmt, 4);
        Text('x_return_status := ''S''' || ';',4);
        --dbms_output.put_line('IN PLSQL ');
     ELSIF l_category = 'SQL' THEN
        --Break_Text('oe_debug_pub.add(''Formula - ' || l_new_formula || ''')',4);
	--select replace(l_temp_new_formula,'''','''''') into l_temp_new_formula from dual;--6726052,7249280 smbalara:commented for 8348005
        l_select_stmt := 'EXECUTE IMMEDIATE '' SELECT '|| l_temp_new_formula || ' FROM DUAL '' INTO x_formula_value using ' || l_using_clause;
        Break_Text(l_select_stmt, 4);
        Text('x_return_status := ''S''' || ';',4);
        --dbms_output.put_line('IN SQL ');
     END IF;
     Text('ELSE', 3);                              --sfiresto
     Text('x_return_status := ''T''' || ';', 4);   --sfiresto
     Text('END IF' || ';',3);                      --sfiresto
     Text('RETURN' || ';',3);                      --sfiresto
     Text('END IF' || ';',2);
     New_Line;

     l_category := '';

  END LOOP;

  Text('x_return_status := ''F''' || ';',2); --sfiresto
  New_Line;
  Text('EXCEPTION',1);
  Text('WHEN OTHERS THEN',2);
  Text('x_return_status := ''E''' || ';',3);
  Text('oe_debug_pub.add(''Error in QP_BUILD_FORMULA_RULES_TMP -''||sqlerrm)'||';');
  Text('END' || ';',1);
  Text('END Get_Formula_Values;',0);
  New_Line;

  Pkg_End('QP_BUILD_FORMULA_RULES_TMP', 'BODY');

  FND_MESSAGE.SET_NAME('QP','QP_BUILD_FORMULAS_SUCCESS');
  err_buff := FND_MESSAGE.GET;
  PUT_LINE(err_buff);
  retcode := 0;
  oe_debug_pub.add('##### ' || err_buff || ' #####');
  oe_debug_pub.add('##### End Build Formulas #####');

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
          FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_SOURCING_ERROR');
          FND_MESSAGE.SET_TOKEN('PACKAGE_TYPE','BODY');
          FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','QP_BUILD_FORMULA_RULES');
          FND_MESSAGE.SET_TOKEN('ERRMSG',substr(SQLERRM,1,150));
          err_buff := FND_MESSAGE.GET;
          PUT_LINE(err_buff);
          retcode := 2;
          oe_debug_pub.add('##### ' || err_buff || ' #####');
          oe_debug_pub.add('##### End Build Formulas #####');

  WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_SOURCING_ERROR');
          FND_MESSAGE.SET_TOKEN('PACKAGE_TYPE','BODY');
          FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','QP_BUILD_FORMULA_RULES');
          FND_MESSAGE.SET_TOKEN('ERRMSG',substr(SQLERRM,1,150));
          err_buff := FND_MESSAGE.GET;
          PUT_LINE(err_buff);
          retcode := 2;
          oe_debug_pub.add('##### ' || err_buff || ' #####');
          oe_debug_pub.add('##### End Build Formulas #####');

END FORMULAS;

END QP_FORMULA_RULES_PVT;

/
