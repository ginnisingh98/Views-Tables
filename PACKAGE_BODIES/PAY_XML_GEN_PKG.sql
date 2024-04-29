--------------------------------------------------------
--  DDL for Package Body PAY_XML_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_XML_GEN_PKG" AS
/* $Header: pyxmlgen.pkb 120.0.12000000.2 2007/05/23 12:38:19 pgongada noship $ */

Procedure exec_report_map_function (
p_func_name in varchar2,
p_parameters in varchar2,
p_tempfile_name in varchar2,
p_xml_data out nocopy CLOB
) is

l_exec_stmt               VARCHAR2(32000);
l_xml_data CLOB;
l_final_xml_data CLOB;
l_start_pos INTEGER;
l_end_pos INTEGER;
l_charset fnd_lookup_values.tag%TYPE;
l_header varchar2(500);
l_len INTEGER;

CURSOR c_dbnlscharset IS
SELECT tag charset
FROM fnd_lookup_values
WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
      AND lookup_code = SUBSTR(USERENV('LANGUAGE'), INSTR(USERENV('LANGUAGE'), '.') + 1)
      AND language = 'US';

Begin

    l_exec_stmt := 'BEGIN '
                   || p_func_name || ' ( '
                   ||  p_parameters
				   || ' p_template_name => '''
                   ||  p_tempfile_name || ''', '
                   || ' p_xml => :1'
                   || ' ); END; ';

 EXECUTE IMMEDIATE l_exec_stmt USING out l_xml_data;

dbms_lob.createtemporary(l_final_xml_data,false,dbms_lob.session);
dbms_lob.open(l_final_xml_data,dbms_lob.lob_readwrite);


l_start_pos := dbms_lob.instr( l_xml_data, '<?');
l_end_pos := dbms_lob.instr( l_xml_data, '?>');

IF l_start_pos -1 > 0 THEN
dbms_lob.copy(l_final_xml_data,l_xml_data,l_start_pos -1, 1,1);
END IF;
l_charset := null;

OPEN c_dbnlscharset;
FETCH c_dbnlscharset into l_charset;
CLOSE c_dbnlscharset;


l_header :='<?xml version="1.0"?>';

dbms_lob.writeappend(l_final_xml_data,length(l_header),l_header);
l_len := dbms_lob.getlength(l_final_xml_data);

-- Bug # 5967599
-- Added the below condition to handle the data if it doesn't contain
-- XML header.
if (l_end_pos <> 0) then
	dbms_lob.copy(l_final_xml_data,l_xml_data, dbms_lob.getlength(l_xml_data)-l_end_pos,l_len+1, l_end_pos+2);
else
	dbms_lob.copy(l_final_xml_data,l_xml_data, dbms_lob.getlength(l_xml_data)-l_end_pos,l_len+1, l_end_pos+1);
end if;
dbms_lob.close(l_xml_data);
p_xml_data := l_final_xml_data;


End exec_report_map_function;


/* BLOB version of exec_report_map_function */

Procedure exec_report_map_function (
p_func_name in varchar2,
p_parameters in varchar2,
p_tempfile_name in varchar2,
p_xml_data out nocopy BLOB
) is

l_exec_stmt               VARCHAR2(32000);
l_xml_data BLOB;
l_final_xml_data BLOB;
l_start_pos INTEGER;
l_end_pos INTEGER;
l_charset fnd_lookup_values.tag%TYPE;
l_header varchar2(500);
l_len INTEGER;

CURSOR c_dbnlscharset IS
SELECT tag charset
FROM fnd_lookup_values
WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
      AND lookup_code = SUBSTR(USERENV('LANGUAGE'), INSTR(USERENV('LANGUAGE'), '.') + 1)
      AND language = 'US';

Begin

    l_exec_stmt := 'BEGIN '
                   || p_func_name || ' ( '
                   ||  p_parameters
				   || ' p_template_name => '''
                   ||  p_tempfile_name || ''', '
                   || ' p_xml => :1'
                   || ' ); END; ';

 EXECUTE IMMEDIATE l_exec_stmt USING out l_xml_data;

/*dbms_lob.createtemporary(l_final_xml_data,false,dbms_lob.session);
dbms_lob.open(l_final_xml_data,dbms_lob.lob_readwrite);


l_start_pos := dbms_lob.instr( l_xml_data, '<?');
l_end_pos := dbms_lob.instr( l_xml_data, '?>');

IF l_start_pos -1 > 0 THEN
dbms_lob.copy(l_final_xml_data,l_xml_data,l_start_pos -1, 1,1);
END IF;
l_charset := null;

OPEN c_dbnlscharset;
FETCH c_dbnlscharset into l_charset;
CLOSE c_dbnlscharset;


l_header :='<?xml version="1.0"?>';

dbms_lob.writeappend(l_final_xml_data,length(l_header),l_header);
l_len := dbms_lob.getlength(l_final_xml_data);

dbms_lob.copy(l_final_xml_data,l_xml_data, dbms_lob.getlength(l_xml_data)-l_end_pos,l_len+1, l_end_pos+2);
dbms_lob.close(l_xml_data);*/
p_xml_data := l_xml_data;


End exec_report_map_function;


END PAY_XML_GEN_PKG;

/
