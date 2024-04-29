--------------------------------------------------------
--  DDL for Package Body PAY_NL_XDO_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_XDO_REPORT" AS
/* $Header: paynlxdo.pkb 120.3.12000000.4 2007/11/15 16:17:09 rsahai noship $ */

/*-------------------------------------------------------------------------------
|Name           : WritetoCLOB                                                   |
|Type		: Procedure	        				        |
|Description    : Writes contents of XML file as CLOB                           |
------------------------------------------------------------------------------*/

PROCEDURE WritetoCLOB (p_xfdf_blob out nocopy blob) IS

l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(1000);
l_str9 varchar2(1000);

begin
hr_utility.set_location('Entered Procedure Write to clob ',100);
	l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields> ' ;
	l_str2 := '<field name="';
	l_str3 := '">';
	l_str4 := '<value>' ;
	l_str5 := '</value> </field>' ;
	l_str6 := '</fields> </xfdf>';
	l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
		       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields>
       			 </fields> </xfdf>';
	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
	if vXMLTable.count > 0 then
		dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
        	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        		l_str8 := vXMLTable(ctr_table).TagName;
        		l_str9 := vXMLTable(ctr_table).TagValue;
        		if (l_str9 is not null) then
				dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
			elsif (l_str9 is null and l_str8 is not null) then
				dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
				dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
				dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
				dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
				dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
			else
			null;
			end if;
		END LOOP;
		dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
	else
		dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
	end if;
	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	clob_to_blob(l_xfdf_string,p_xfdf_blob);
	hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;

/*Function to support building of xml file compatible with RTF processor */
PROCEDURE WritetoCLOB_rtf(p_xfdf_blob out nocopy blob) IS

l_xfdf_string clob;
l_str0 varchar2(1000);
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(1000);
l_str9 varchar2(1000);
l_str10 varchar2(1000);
l_concat_str VARCHAR2(32000);
begin
hr_utility.set_location('Entered Procedure Write to clob ',100);
	l_str0 := '<?xml version="1.0" encoding="ISO-8859-1"?>';
	l_str1 := '<fields>' ;
	l_str2 := '<';
	l_str3 := '>';
	l_str4 := '<value>' ;
	l_str5 := '</value> </' ;
	l_str6 := '</fields>';
	l_str7 := '<fields></fields>';
	l_str10 := '</';
	l_concat_str := '';
	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
	if vXMLTable.count > 0 then
		--dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
		l_concat_str := l_concat_str||l_str1;
        	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        		l_str8 := vXMLTable(ctr_table).TagName;
        		l_str9 := vXMLTable(ctr_table).TagValue;

			IF  length(l_concat_str) > 28000 then
		           dbms_lob.writeAppend( l_xfdf_string, length(l_concat_str), l_concat_str);
		           l_concat_str := '';
			END IF;

        		if (substr(l_str8,1,11) = 'G_CONTAINER') then
        		        if (l_str9 is null) then
	        		        --dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
					l_concat_str := l_concat_str||l_str2;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
					l_concat_str := l_concat_str||l_str3;
				else
					if (l_str9 = 'END') then
					    --dbms_lob.writeAppend( l_xfdf_string, length(l_str10), l_str10 );
					    l_concat_str := l_concat_str||l_str10;
	        			    --dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					    l_concat_str := l_concat_str||l_str8;
					    --dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
					    l_concat_str := l_concat_str||l_str3;
					end if;
				end if;
		        else
        			if (l_str9 is not null) then
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
					l_concat_str := l_concat_str||l_str2;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
					l_concat_str := l_concat_str||l_str3;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
					l_concat_str := l_concat_str||l_str4;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
					l_concat_str := l_concat_str||l_str9;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
					l_concat_str := l_concat_str||l_str5;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str3),l_str3);
					l_concat_str := l_concat_str||l_str3;
				elsif (l_str9 is null and l_str8 is not null) then
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
					l_concat_str := l_concat_str||l_str2;
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
					l_concat_str := l_concat_str||l_str3;
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
					l_concat_str := l_concat_str||l_str4;
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
					l_concat_str := l_concat_str||l_str5;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str3),l_str3);
					l_concat_str := l_concat_str||l_str3;
				else
					null;
				end if;
			end if;
		END LOOP;

	       IF length(l_concat_str) > 0 THEN
		       dbms_lob.writeAppend( l_xfdf_string, LENGTH(l_concat_str), l_concat_str);
	       END IF;

		dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
	else
		dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
	end if;
	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	clob_to_blob(l_xfdf_string,p_xfdf_blob);
	hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB_rtf;

/*Function which retruns a CLOB to support building of xml file compatible with RTF processor */
PROCEDURE WritetoCLOB_rtf_1(p_xfdf_blob out nocopy clob) IS

l_xfdf_string clob;
l_str0 varchar2(1000);
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(1000);
l_str9 varchar2(1000);
l_str10 varchar2(1000);
l_concat_str VARCHAR2(32000);
begin
hr_utility.set_location('Entered Procedure Write to clob ',100);
	l_str0 := '<?xml version="1.0" encoding="ISO-8859-1"?>';
	l_str1 := '<fields>' ;
	l_str2 := '<';
	l_str3 := '>';
	l_str4 := '<value>' ;
	l_str5 := '</value> </' ;
	l_str6 := '</fields>';
	l_str7 := '<fields></fields>';
	l_str10 := '</';
	l_concat_str := '';
	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
	if vXMLTable.count > 0 then
		--dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

		--l_concat_str := l_concat_str||l_str2||l_str1;
		--Bug 6630722
		l_concat_str := l_concat_str||l_str1;

        	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        		l_str8 := vXMLTable(ctr_table).TagName;
        		l_str9 := vXMLTable(ctr_table).TagValue;

			IF  length(l_concat_str) > 28000 then
		           dbms_lob.writeAppend( l_xfdf_string, length(l_concat_str), l_concat_str);
		           l_concat_str := '';
			END IF;

        		if (substr(l_str8,1,11) = 'G_CONTAINER') then
        		        if (l_str9 is null) then
	        		        --dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
					l_concat_str := l_concat_str||l_str2;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
					l_concat_str := l_concat_str||l_str3;
				else
					if (l_str9 = 'END') then
					    --dbms_lob.writeAppend( l_xfdf_string, length(l_str10), l_str10 );
					    l_concat_str := l_concat_str||l_str10;
	        			    --dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					    l_concat_str := l_concat_str||l_str8;
					    --dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
					    l_concat_str := l_concat_str||l_str3;
					end if;
				end if;
		        else
        			if (l_str9 is not null) then
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
					l_concat_str := l_concat_str||l_str2;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
					l_concat_str := l_concat_str||l_str3;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
					l_concat_str := l_concat_str||l_str4;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
					l_concat_str := l_concat_str||l_str9;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
					l_concat_str := l_concat_str||l_str5;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str3),l_str3);
					l_concat_str := l_concat_str||l_str3;
				elsif (l_str9 is null and l_str8 is not null) then
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
					l_concat_str := l_concat_str||l_str2;
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
					l_concat_str := l_concat_str||l_str3;
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
					l_concat_str := l_concat_str||l_str4;
					--dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
					l_concat_str := l_concat_str||l_str5;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					l_concat_str := l_concat_str||l_str8;
					--dbms_lob.writeAppend( l_xfdf_string, length(l_str3),l_str3);
					l_concat_str := l_concat_str||l_str3;
				else
					null;
				end if;
			end if;
		END LOOP;

	       IF length(l_concat_str) > 0 THEN
		       dbms_lob.writeAppend( l_xfdf_string, LENGTH(l_concat_str), l_concat_str);
	       END IF;

		dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
	else
		dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
	end if;
	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	p_xfdf_blob := l_xfdf_string;
	hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB_rtf_1;


/*Converts CLOB data to BLOB*/


/*-------------------------------------------------------------------------------
|Name           : clob_to_blob                                                  |
|Type		: Procedure	        				        |
|Description    : Converts XMLfile currently a CLOB to a BLOB                   |
------------------------------------------------------------------------------*/


PROCEDURE  clob_to_blob(p_clob CLOB
	              	   ,p_blob IN OUT NOCOPY BLOB) IS
    l_length_clob NUMBER;
    l_offset integer;
    l_varchar_buffer VARCHAR2(10666);
    l_raw_buffer RAW(32000);
    l_buffer_len NUMBER;
    l_chunk_len NUMBER;
    l_blob BLOB;
    l_db_nls_lang  VARCHAR2(200);
    --
    l_raw_buffer_len pls_integer;
    l_blob_offset pls_integer := 1;
    --
  begin
  	hr_utility.set_location('Entered Procedure clob to blob',120);
    l_db_nls_lang := userenv('LANGUAGE');
  	l_length_clob := dbms_lob.getlength(p_clob);
    l_buffer_len := 10666;
	l_offset := 1;
    l_blob_offset := 1;
	WHILE l_length_clob > 0 LOOP

		IF l_length_clob < l_buffer_len THEN
			l_chunk_len := l_length_clob;
		ELSE
                        l_chunk_len := l_buffer_len;
		END IF;
		DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
        l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',l_db_nls_lang);
        l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',l_db_nls_lang));
        dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
        --
        l_blob_offset := l_blob_offset + l_raw_buffer_len;
        l_offset := l_offset + l_chunk_len;
        l_length_clob := l_length_clob - l_chunk_len;
	END LOOP;
	hr_utility.set_location('Finished Procedure clob to blob ',130);
  END;


/*Returns template file as a BLOB*/


/*-------------------------------------------------------------------------------
|Name           : fetch_pdf_blob                                                |
|Type		: Procedure	        				        |
|Description    : fetches template file as a BLOB                               |
------------------------------------------------------------------------------*/

Procedure fetch_pdf_blob(p_year varchar2,p_template_id number,p_pdf_blob OUT NOCOPY BLOB) IS

BEGIN

	Select file_data Into p_pdf_blob
	From fnd_lobs
	Where file_id = (select file_id from per_gb_xdo_templates
			 where file_id=p_template_id and
			 fnd_date.canonical_to_date(p_year) between EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE);
	EXCEPTION
        	when no_data_found then
              	null;
END fetch_pdf_blob;




/*-------------------------------------------------------------------------------
|Name           : WritetoXML                                                    |
|Type		: Procedure	        				        |
|Description    : Procedure to write the xml to a file. Used for debugging      |
|		  purposes                                                      |
------------------------------------------------------------------------------*/


PROCEDURE WritetoXML (
        p_request_id in number,
        p_output_fname out nocopy varchar2)
IS
        p_l_fp UTL_FILE.FILE_TYPE;
        l_audit_log_dir varchar2(500) := '/sqlcom/outbound';
        l_file_name varchar2(50);
        l_check_flag number;
BEGIN
/*Msg in the temorary table*/
--insert into tstmsg values('Entered the procedure WritetoXML.');
        -----------------------------------------------------------------------------
        -- Writing into XML File
        -----------------------------------------------------------------------------
        -- Assigning the File name.
        l_file_name :=  to_char(p_request_id) || '.xml';
        -- Getting the Util file directory name.mostly it'll be /sqlcom/outbound )
        BEGIN


                SELECT value
                INTO l_audit_log_dir
                FROM v$parameter
                WHERE LOWER(name) = 'utl_file_dir';
                -- Check whether more than one util file directory is found
                IF INSTR(l_audit_log_dir,',') > 0 THEN
                   l_audit_log_dir := substr(l_audit_log_dir,1,instr(l_audit_log_dir,',')-1);
                END IF;
        EXCEPTION
                when no_data_found then
              null;
        END;
        -- Find out whether the OS is MS or Unix based
        -- If it's greater than 0, it's unix based environment
        IF INSTR(l_audit_log_dir,'/') > 0 THEN
                p_output_fname := l_audit_log_dir || '/' || l_file_name;
        ELSE
        p_output_fname := l_audit_log_dir || '\' || l_file_name;
        END IF;
        -- getting Agency name
        p_l_fp := utl_file.fopen(l_audit_log_dir,l_file_name,'A');
        utl_file.put_line(p_l_fp,'<?xml version="1.0" encoding="UTF-8"?>');
        utl_file.put_line(p_l_fp,'<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">');
        -- Writing from and to dates
        utl_file.put_line(p_l_fp,'<fields>');
        -- Write the header fields to XML File.
        --WriteXMLvalues(p_l_fp,'P0_from_date',to_char(p_from_date,'dd') || ' ' || trim(to_char(p_from_date,'Month')) || ' ' || to_char(p_from_date,'yyyy') );
        --WriteXMLvalues(p_l_fp,'P0_to_date',to_char(p_to_date,'dd') || ' ' ||to_char(p_to_date,'Month') || ' ' || to_char(p_to_date,'yyyy') );
        -- Loop through PL/SQL Table and write the values into the XML File.
        -- Need to try FORALL instead of FOR
        IF vXMLTable.count >0 then

        FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP


                WriteXMLvalues(p_l_fp,vXMLTable(ctr_table).TagName,vXMLTable(ctr_table).TagValue);
        END LOOP;
        END IF;
        -- Write the end tag and close the XML File.
        utl_file.put_line(p_l_fp,'</fields>');
        utl_file.put_line(p_l_fp,'</xfdf>');
        utl_file.fclose(p_l_fp);
/*Msg in the temorary table*/
--insert into tstmsg values('Leaving the procedure WritetoXML.');
END WritetoXML;


/*-------------------------------------------------------------------------------
|Name           : WriteXMLvalues                                                |
|Type		: Procedure	        				        |
|Description    : Procedure to write the xml values. Used for debugging         |
------------------------------------------------------------------------------*/


PROCEDURE WriteXMLvalues( p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2) IS
BEGIN
        -- Writing XML Tag and values to XML File
--      utl_file.put_line(p_l_fp,'<' || p_tagname || '>' || p_value || '</' || p_tagname || '>'  );
        -- New Format XFDF
        utl_file.put_line(p_l_fp,'<field name="' || p_tagname || '">');
        utl_file.put_line(p_l_fp,'<value>' || p_value || '</value>'  );
        utl_file.put_line(p_l_fp,'</field>');
END WriteXMLvalues;

/*-------------------------------------------------------------------------------
|Name           : WritetoXML_rtf                                                |
|Type		: Procedure	        				        |
|Description    : Procedure to write the xml to a file. Used for debugging      |
|		  purposes                                                      |
------------------------------------------------------------------------------*/


/*Function to support building of xml file compatible with RTF processor */
PROCEDURE WritetoXML_rtf (
        p_request_id in number,
        p_output_fname out nocopy varchar2)
IS
        p_l_fp UTL_FILE.FILE_TYPE;
        l_audit_log_dir varchar2(500) := '/sqlcom/outbound';
        l_file_name varchar2(50);
        l_check_flag number;
	l_concat_str VARCHAR2(32000);
BEGIN
/*Msg in the temorary table*/
--insert into tstmsg values('Entered the procedure WritetoXML.');
        -----------------------------------------------------------------------------
        -- Writing into XML File
        -----------------------------------------------------------------------------
        -- Assigning the File name.
        l_file_name :=  to_char(p_request_id) || '.xml';
        -- Getting the Util file directory name.mostly it'll be /sqlcom/outbound )
        BEGIN


                SELECT value
                INTO l_audit_log_dir
                FROM v$parameter
                WHERE LOWER(name) = 'utl_file_dir';
                -- Check whether more than one util file directory is found
                IF INSTR(l_audit_log_dir,',') > 0 THEN
                   l_audit_log_dir := substr(l_audit_log_dir,1,instr(l_audit_log_dir,',')-1);
                END IF;
        EXCEPTION
                when no_data_found then
              null;
        END;
        -- Find out whether the OS is MS or Unix based
        -- If it's greater than 0, it's unix based environment
        IF INSTR(l_audit_log_dir,'/') > 0 THEN
                p_output_fname := l_audit_log_dir || '/' || l_file_name;
        ELSE
        p_output_fname := l_audit_log_dir || '\' || l_file_name;
        END IF;
        -- getting Agency name
        p_l_fp := utl_file.fopen(l_audit_log_dir,l_file_name,'A',32000);
        -- Writing from and to dates
	l_concat_str := '<?xml version="1.0" encoding="ISO-8859-1"?>';
	l_concat_str := l_concat_str||'<fields>';
        --utl_file.put_line(p_l_fp,'<fields>');
        -- Write the header fields to XML File.
        --WriteXMLvalues(p_l_fp,'P0_from_date',to_char(p_from_date,'dd') || ' ' || trim(to_char(p_from_date,'Month')) || ' ' || to_char(p_from_date,'yyyy') );
        --WriteXMLvalues(p_l_fp,'P0_to_date',to_char(p_to_date,'dd') || ' ' ||to_char(p_to_date,'Month') || ' ' || to_char(p_to_date,'yyyy') );
        -- Loop through PL/SQL Table and write the values into the XML File.
        -- Need to try FORALL instead of FOR
        IF vXMLTable.count >0 then

        FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP

		IF length(l_concat_str) > 28000 THEN

			utl_file.put_line(p_l_fp,l_concat_str);
			l_concat_str := '';

		END IF;

		IF substr(vXMLTable(ctr_table).TagName,1,11)='G_CONTAINER' THEN

			IF vXMLTable(ctr_table).TagValue is null THEN
				l_concat_str := l_concat_str||'<'||vXMLTable(ctr_table).TagName||'>';
			ELSIF vXMLTable(ctr_table).TagValue='END' THEN
				l_concat_str := l_concat_str||'</'||vXMLTable(ctr_table).TagName||'>';
			END IF;

		ELSE

			l_concat_str := l_concat_str||'<'||vXMLTable(ctr_table).TagName||'>';
			l_concat_str := l_concat_str||'<value>'||vXMLTable(ctr_table).TagValue||'</value>';
			l_concat_str := l_concat_str||'</'||vXMLTable(ctr_table).TagName||'>';

		END IF;
                --WriteXMLvalues_rtf(p_l_fp,vXMLTable(ctr_table).TagName,vXMLTable(ctr_table).TagValue);
        END LOOP;
        END IF;
       IF length(l_concat_str) > 0 THEN
		utl_file.put_line(p_l_fp,l_concat_str);
       END IF;
        -- Write the end tag and close the XML File.
        utl_file.put_line(p_l_fp,'</fields>');
        utl_file.fclose(p_l_fp);
/*Msg in the temorary table*/
--insert into tstmsg values('Leaving the procedure WritetoXML.');
END WritetoXML_rtf;

/*Function to support building of xml file compatible with RTF processor */
PROCEDURE WriteXMLvalues_rtf( p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2) IS
BEGIN
        -- Writing XML Tag and values to XML File
--      utl_file.put_line(p_l_fp,'<' || p_tagname || '>' || p_value || '</' || p_tagname || '>'  );
        -- New Format XFDF
        utl_file.put_line(p_l_fp,'<' || p_tagname || '>');
        utl_file.put_line(p_l_fp,'<value>' || p_value || '</value>'  );
        utl_file.put_line(p_l_fp,'</' || p_tagname || '>');
END WriteXMLvalues_rtf;



END PAY_NL_XDO_REPORT;

/
