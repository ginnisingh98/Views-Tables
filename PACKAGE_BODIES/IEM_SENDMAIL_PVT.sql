--------------------------------------------------------
--  DDL for Package Body IEM_SENDMAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SENDMAIL_PVT" as
/* $Header: iemvsomb.pls 120.4 2007/11/07 20:26:58 kgscott noship $*/

	PROCEDURE 	IEM_CHK_TEMPLATE(
				 p_template_id in number,
				 x_status	 OUT NOCOPY varchar2)  IS
	l_file_id		number;
	cursor c1 is select lookup_code,meaning
	from fnd_lookups
	where enabled_flag = 'Y'
	AND NVL(start_date_active, SYSDATE) <= SYSDATE
	AND NVL(end_date_active,SYSDATE) >= SYSDATE
	AND lookup_type ='IEM_MERGE_FIELDS'
	ANd lookup_code like 'ACK%';
	v_rawbuf RAW(2400);
	v_done BOOLEAN := false;
	v_flag INTEGER;
	v_bfile bfile;
	v_amt INTEGER;
	v_data	BLOB;
	v_offset INTEGER := 1;
	l_buff	varchar2(2400);
	c_buflen CONSTANT INTEGER := 2400;
	l_index		number;
	l_string1		varchar2(100);
	l_string2		varchar2(100);
	l_ffind	number:=0;
	l_sfind	number:=0;
	l_ffind1	number:=0;
	l_sfind1	number:=0;
	l_occur		number:=1;
	l_match		number;
  TYPE t_mergeTbl is table of varchar2(100)
   INDEX BY BINARY_INTEGER;
   l_mergetbl	t_mergeTbl;
   l_mindex		number;
   l_tval			varchar2(10):='CHR';
   l_val1			varchar2(10):='((?';
   l_val2			varchar2(10):='?))';
BEGIN
	x_status:='S';
l_val1:=l_tval||'(171)';

l_val2:=l_tval||'(187)';
	SELECT fl.file_id
	INTO l_file_id
	FROM jtf_amv_items_tl b ,jtf_amv_attachments a ,fnd_lobs fl
	WHERE b.item_id = a.attachment_used_by_id
	and a.attachment_used_by='ITEM'
	AND a.file_id = fl.file_id
	AND b.item_id=p_template_id
	AND b.language=USERENV('LANG')
	and rownum=1;
-- Store all the merge fields present in  the templates
	select file_data into v_data
	from fnd_lobs
	where file_id=l_file_id;
		l_occur:=1;
	 l_mergetbl.delete;		--To store all the merge fields
	 l_mindex:=1;		--Index to store all the merge
 LOOP
   v_amt := c_buflen;
   dbms_lob.read(v_data, v_amt, v_offset, v_rawbuf);
   v_offset := v_offset + v_amt;
	 l_buff:=utl_raw.cast_to_VARCHAR2(v_rawbuf);
	 l_string1:=l_val1;
	 l_string2:=l_val2;
	 /*
	execute immediate 'select '||l_val1||' from dual ' into l_string1;
	execute immediate 'select '||l_val2||' from dual ' into l_string2;
	*/
 LOOP
	 l_ffind:=instr(l_buff,'((?',1,l_occur);
	 l_sfind:=instr(l_buff,'?))',1,l_occur);
	 l_ffind1:=instr(l_buff,'((*',1,l_occur);
	 l_sfind1:=instr(l_buff,'*))',1,l_occur);
	 IF (l_ffind>0) and (l_sfind>0) THEN
	  l_mergetbl(l_mindex):=substr(l_buff,l_ffind+1,l_sfind-l_ffind-1);
	  l_mindex:=l_mindex+1;
	  l_occur:=l_occur+1;
      END IF;

	 IF (l_ffind1>0) and (l_sfind1>0) THEN
	  l_mergetbl(l_mindex):=substr(l_buff,l_ffind1+3,l_sfind1-l_ffind1-3);
	  l_mindex:=l_mindex+1;
	  l_occur:=l_occur+1;
      END IF;
   EXIT WHEN (l_ffind=0 OR l_sfind=0)AND (l_ffind1=0 OR l_sfind1=0);
 END LOOP;
EXIT WHEN v_amt < c_buflen;
END LOOP;
--Check all the merge field with the standard merge fields.
IF l_mergetbl.count>0 THEN	-- Template Contain Merge Fields
FOR i in l_mergetbl.FIRST..l_mergetbl.LAST LOOP
		l_match:=0;
	FOR v1 in c1 LOOP
		if trim(l_mergetbl(i))=trim(v1.lookup_code) THEN
			l_match:=l_match+1;
		end if;
	END LOOP;
	EXIT when l_match=0;
END LOOP;
	IF l_match=0 THEN
		x_status:='E';
	END IF;
ELSE				-- Template Contain No merge Fields
		x_status:='S';
END IF;
EXCEPTION WHEN OTHERS THEN
	x_status:='E';
END IEM_CHK_TEMPLATE;
	PROCEDURE 	IEM_SENDMAIL(
				p_user in varchar2,
				 p_domain in varchar2,
				 p_password in varchar2,
				 p_replyto in varchar2,
				 p_file_id in number,
				 p_subject in varchar2,
				 p_tostr	 in varchar2,
				 p_fromstr in varchar2,
				 p_encrypt_tbl in email_encrypt_tbl,
				 x_status	 OUT NOCOPY varchar2,
				 x_return_text OUT NOCOPY varchar2
			)

			IS

begin
x_status:='S';
end IEM_SENDMAIL ;
end;

/
