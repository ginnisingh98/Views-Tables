--------------------------------------------------------
--  DDL for Package Body HR_XML_PUB_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_XML_PUB_UTILITY" AS
/* $Header: perxmlpb.pkb 120.0 2006/05/01 05:21 debhatta noship $ */
Procedure  clob_to_blob(p_clob clob
			,p_blob IN OUT NOCOPY blob)
  is
    l_proc    varchar2(100):= 'hr_xml_pub_utility.clob_to_blob';
    l_length_clob number;
    l_offset pls_integer;
    l_varchar_buffer varchar2(32767);
    l_raw_buffer raw(32767);
    l_buffer_len number:= 20000;
    l_chunk_len number;
    l_blob blob;
    g_nls_db_char varchar2(60);

    l_raw_buffer_len pls_integer;
    l_blob_offset    pls_integer := 1;

  begin
        hr_utility.set_location('Entered Procedure clob to blob',120);
        select userenv('LANGUAGE') into g_nls_db_char from dual;
        l_length_clob := dbms_lob.getlength(p_clob);
        l_offset := 1;
        while l_length_clob > 0 loop
                hr_utility.trace('l_length_clob '|| l_length_clob);
                if l_length_clob < l_buffer_len then
                        l_chunk_len := l_length_clob;
                else
                        l_chunk_len := l_buffer_len;
                end if;
                DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
                --l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
                l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char);
                l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char));
                hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
                --dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
                dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
                l_blob_offset := l_blob_offset + l_raw_buffer_len;

                l_offset := l_offset + l_chunk_len;
                l_length_clob := l_length_clob - l_chunk_len;
                hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
        end loop;

        exception
        when others then
          hr_utility.set_location(' Leaving: ' || l_proc, 100);
          raise;
  end;

end HR_XML_PUB_UTILITY;

/
