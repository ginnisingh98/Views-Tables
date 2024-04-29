--------------------------------------------------------
--  DDL for Package Body IEM_IM_WRAPPERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_IM_WRAPPERS_PVT" as
/* $Header: iemvimwb.pls 115.6 2002/12/03 23:47:55 sboorela shipped $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_IM_WRAPPERS_PVT ';

 FUNCTION GetThemes(p_message_id IN INTEGER, p_part IN INTEGER,
                    p_flags IN INTEGER,p_link IN VARCHAR2,
				p_themes OUT NOCOPY theme_table,
                    p_errtext OUT NOCOPY VARCHAR2) RETURN INTEGER
 IS
 p_theme_str VARCHAR2(32000);
 l_theme_str VARCHAR2(32000);
 l_work_str VARCHAR2(3000);
 p_index NUMBER := 0;
 l_count NUMBER := 1;
 l_bool BOOLEAN := TRUE;
 l_loc_t NUMBER;
 l_loc_s NUMBER;
 l_status NUMBER;

 l_plsql_block VARCHAR2(2000) := 'BEGIN :x := IM_IMT_API.getthemesw'||p_link||'(:a,:b,:c,:d,:e,:f); END;';

BEGIN
 EXECUTE IMMEDIATE l_plsql_block USING OUT l_status, IN p_message_id,IN p_part, IN p_flags,
                   OUT p_theme_str, OUT p_index, OUT p_errtext;

 --DBMS_OUTPUT.PUT_LINE('NUMBER OF THEMES := '||p_index);
 IF (p_index > 0) THEN
    WHILE (l_bool) LOOP
       SELECT INSTR(p_theme_str, '<T>', 1,1) INTO l_loc_t FROM DUAL;
       SELECT SUBSTR(p_theme_str,1, l_loc_t-1) INTO l_work_str FROM DUAL;
	  SELECT INSTR(l_work_str, '<S>', 1, 1) INTO l_loc_s FROM DUAL;
       SELECT SUBSTR(l_work_str,1,l_loc_s-1) INTO p_themes(l_count).THEME FROM DUAL;
       SELECT SUBSTR(l_work_str,l_loc_s+3) INTO p_themes(l_count).WEIGHT FROM DUAL;
       l_count := l_count+1;
	  SELECT SUBSTR(p_theme_str,l_loc_t+3) INTO l_theme_str FROM DUAL;
	  p_theme_str := l_theme_str;
       p_index := p_index-1;

	  IF (p_index < 1) THEN
	    l_bool := FALSE;
	  END IF;
    END LOOP;
 END IF;

 -- Appropriate err_text to be returned
 --     ""      error number to be returned

 return l_status;

EXCEPTION
  WHEN OTHERS THEN
  p_errtext := SUBSTR(p_errtext ||' '||SQLERRM, 1, 254);
  return l_status;
  --	DBMS_OUTPUT.PUT_LINE(SQLERRM);
END getthemes;


FUNCTION gethighlight(p_message_id IN INTEGER, p_part IN INTEGER,
                     p_flags IN INTEGER, p_text_query IN VARCHAR2,
                     p_link IN VARCHAR2,
				 p_highlight_buf OUT NOCOPY highlight_table,
                     p_errtext OUT NOCOPY VARCHAR2) RETURN INTEGER
 IS
 p_highlight_str VARCHAR2(32000);
 l_highlight_str VARCHAR2(32000);
 l_work_str VARCHAR2(3000);
 p_index NUMBER := 0;
 l_count NUMBER := 1;
 l_bool BOOLEAN := TRUE;
 l_loc_t NUMBER;
 l_loc_s NUMBER;
 l_status NUMBER;
 l_plsql_block VARCHAR2(2000) := 'BEGIN :x := IM_IMT_API.gethighlightw'||p_link||'(:a,:b,:c,:d,:e,:f,:g); END;';

BEGIN
 EXECUTE IMMEDIATE l_plsql_block USING OUT l_status, IN p_message_id,IN p_part, IN p_flags,
                   IN p_text_query, OUT p_highlight_str, OUT p_index,
                   OUT p_errtext;

 --DBMS_OUTPUT.PUT_LINE('NUMBER OF THEMES := '||p_index);
 IF (p_index > 0) THEN
    WHILE (l_bool) LOOP
       SELECT INSTR(p_highlight_str, '<T>', 1,1) INTO l_loc_t FROM DUAL;
       SELECT SUBSTR(p_highlight_str,1, l_loc_t-1) INTO l_work_str FROM DUAL;
	  SELECT INSTR(l_work_str, '<S>', 1, 1) INTO l_loc_s FROM DUAL;
       SELECT SUBSTR(l_work_str,1,l_loc_s-1) INTO p_highlight_buf(l_count).offset FROM DUAL;
       SELECT SUBSTR(l_work_str,l_loc_s+3) INTO p_highlight_buf(l_count).length FROM DUAL;
       l_count := l_count+1;
	  SELECT SUBSTR(p_highlight_str,l_loc_t+3) INTO l_highlight_str FROM DUAL;
	  p_highlight_str := l_highlight_str;
       p_index := p_index-1;

	  IF (p_index < 1) THEN
	    l_bool := FALSE;
	  END IF;
    END LOOP;
 END IF;

 -- Appropriate err_text to be returned
 --     ""      error number to be returned

 return l_status;

EXCEPTION
  WHEN OTHERS THEN
  p_errtext := SUBSTR(p_errtext ||' '||SQLERRM, 1, 254);
  return l_status;
	-- DBMS_OUTPUT.PUT_LINE(SQLERRM);
END gethighlight;


FUNCTION getPartlist(p_message_id IN INTEGER,
                     p_link IN VARCHAR2,
				 p_parts OUT NOCOPY att_table ) RETURN INTEGER
 IS
 p_part_str VARCHAR2(32000);
 l_part_str VARCHAR2(32000);
 l_work_str VARCHAR2(3000);
 l_temp_str VARCHAR2(3000);
 p_index NUMBER := 0;
 l_count NUMBER := 1;
 l_bool BOOLEAN := TRUE;
 l_loc_t NUMBER;
 l_loc_s NUMBER;
 l_loc_f NUMBER;
 l_loc_g NUMBER;
 l_loc_h NUMBER;
 l_status NUMBER;
 l_plsql_block VARCHAR2(2000) := 'BEGIN :x := IM_API.getpartlistw'||p_link||'(:a,:b,:c); END;';

BEGIN
 EXECUTE IMMEDIATE l_plsql_block USING OUT l_status, IN p_message_id,OUT
			    p_part_str, OUT p_index;
 IF (p_index > 0) THEN
    WHILE (l_bool) LOOP
       SELECT INSTR(p_part_str, '<T>', 1,1) INTO l_loc_t FROM DUAL;
       SELECT SUBSTR(p_part_str,1, l_loc_t-1) INTO l_work_str FROM DUAL;

	  SELECT SUBSTR(p_part_str,l_loc_t+3) INTO l_part_str FROM DUAL;
	  p_part_str := l_part_str;
	  SELECT INSTR(l_work_str, '<S>', 1, 1) INTO l_loc_s FROM DUAL;
       SELECT SUBSTR(l_work_str,1,l_loc_s-1) INTO p_parts(l_count).part_number FROM DUAL;

       SELECT SUBSTR(l_work_str,l_loc_s+3) INTO l_temp_str FROM DUAL;

       SELECT INSTR(l_temp_str, '<F>', 1, 1) INTO l_loc_f FROM DUAL;
       SELECT SUBSTR(l_temp_str,1,l_loc_f-1) INTO p_parts(l_count).content_type FROM DUAL;

       SELECT SUBSTR(l_temp_str,l_loc_f+3) INTO l_work_str FROM DUAL;


       SELECT INSTR(l_work_str, '<G>', 1, 1) INTO l_loc_g FROM DUAL;
       SELECT SUBSTR(l_work_str,1, l_loc_g-1) INTO p_parts(l_count).is_binary FROM DUAL;


       SELECT SUBSTR(l_work_str,l_loc_g+3) INTO l_temp_str FROM DUAL;

       SELECT INSTR(l_temp_str, '<H>', 1, 1) INTO l_loc_h FROM DUAL;
       SELECT SUBSTR(l_temp_str,1, l_loc_h-1) INTO p_parts(l_count).att_size FROM DUAL;

       SELECT SUBSTR(l_temp_str,l_loc_h+3) INTO p_parts(l_count).att_name FROM DUAL;

       l_count := l_count+1;
       p_index := p_index-1;

	  IF (p_index < 1) THEN
	    l_bool := FALSE;
	  END IF;
    END LOOP;
 END IF;

 -- Appropriate err_text to be returned
 --     ""      error number to be returned
  return l_status;

EXCEPTION
  WHEN OTHERS THEN
  return l_status;
END getpartlist;


FUNCTION getextendedhdrs(p_message_id IN INTEGER,
                     p_link IN VARCHAR2,
				 p_headers OUT NOCOPY header_table ) RETURN INTEGER
 IS
 p_header_str VARCHAR2(32000);
 l_header_str VARCHAR2(32000);
 l_work_str VARCHAR2(3000);
 p_index NUMBER := 0;
 l_count NUMBER := 1;
 l_bool BOOLEAN := TRUE;
 l_loc_t NUMBER;
 l_loc_s NUMBER;
 l_status NUMBER;

 l_plsql_block VARCHAR2(2000) := 'BEGIN :x := IM_API.getextendedhdrsw'||p_link||'(:a,:b,:c); END;';

BEGIN
 EXECUTE IMMEDIATE l_plsql_block USING OUT l_status, IN p_message_id,
                   OUT p_header_str, OUT p_index;

 IF (p_index > 0) THEN
    WHILE (l_bool) LOOP
       SELECT INSTR(p_header_str, '<T>', 1,1) INTO l_loc_t FROM DUAL;
       SELECT SUBSTR(p_header_str,1, l_loc_t-1) INTO l_work_str FROM DUAL;
	  SELECT INSTR(l_work_str, '<S>', 1, 1) INTO l_loc_s FROM DUAL;
       SELECT SUBSTR(l_work_str,1,l_loc_s-1) INTO p_headers(l_count).hdr_name FROM DUAL;
       SELECT SUBSTR(l_work_str,l_loc_s+3) INTO p_headers(l_count).hdr_value FROM DUAL;
       l_count := l_count+1;
	  SELECT SUBSTR(p_header_str,l_loc_t+3) INTO l_header_str FROM DUAL;
	  p_header_str := l_header_str;
       p_index := p_index-1;

	  IF (p_index < 1) THEN
	    l_bool := FALSE;
	  END IF;
    END LOOP;
 END IF;

 -- Appropriate err_text to be returned
 --     ""      error number to be returned

  return l_status;

EXCEPTION
  WHEN OTHERS THEN
  return l_status;
  --	DBMS_OUTPUT.PUT_LINE(SQLERRM);
END getextendedhdrs;

 FUNCTION openfolder(p_folder IN VARCHAR2,
                    p_link IN VARCHAR2,
				p_messages OUT NOCOPY msg_table) RETURN INTEGER
 IS
 p_id_str VARCHAR2(32000);
 l_id_str VARCHAR2(32000);
 p_index NUMBER := 0;
 l_count NUMBER := 1;
 l_bool BOOLEAN := TRUE;
 l_loc_t NUMBER;
 l_status NUMBER;
 l_flag	number:=1;
 l_batchsize	number:=300;

 l_plsql_block VARCHAR2(2000) := 'BEGIN :x := IM_API.openfolderw'||p_link||'(:a,:b,:c,:d,:e); END;';

BEGIN
LOOP
 EXECUTE IMMEDIATE l_plsql_block USING OUT l_status, IN p_folder,
                   OUT p_id_str, OUT p_index,IN l_flag,IN l_batchsize;
 IF (p_index > 0) THEN
    WHILE (l_bool) LOOP
       SELECT INSTR(p_id_str, '<T>', 1,1) INTO l_loc_t FROM DUAL;
       SELECT SUBSTR(p_id_str,1, l_loc_t-1) INTO p_messages(l_count) FROM DUAL;
       l_count := l_count+1;
	  SELECT SUBSTR(p_id_str,l_loc_t+3) INTO l_id_str FROM DUAL;
	  p_id_str := l_id_str;
       p_index := p_index-1;
	  IF (p_index < 1) THEN
	    l_bool := FALSE;
	  END IF;
    END LOOP;
 END IF;
 IF l_flag=1 THEN
	l_flag:=2;
 END IF;
 l_bool:=TRUE;
 EXIT WHEN l_status=2 or l_status=3;
 END LOOP;
 -- Appropriate err_text to be returned
 --     ""      error number to be returned
	If l_status =2 then
		l_status:=0;
	end if;
  return l_status;

EXCEPTION
  WHEN OTHERS THEN
  return l_status;
END openfolder;

FUNCTION openfoldernew(folder IN VARCHAR2,
                        p_link varchar2,
		               message_records OUT NOCOPY msg_record_table,
                      include_sub IN INTEGER default 1,
		               top_n IN INTEGER DEFAULT 0,
		              top_option IN INTEGER DEFAULT 1) RETURN INTEGER is

    l_status number;
    l_index number;
    l_str1 varchar2(32767);
    l_str2 varchar2(32767);
    l_str3 varchar2(32767);
    l_str4 varchar2(32767);
    l_str5 varchar2(32767);
    l_str6 varchar2(32767);
    l_str7 varchar2(32767);
    l_str8 varchar2(32767);
    l_str9 varchar2(32767);
    l_str10 varchar2(32767);
    l_loc number;
    l_current_row varchar2(2000);
    l_rest_rows varchar2(32767);
    i integer;
    l_rest_columns varchar2(2000);
    current_count integer;
    incr_counter integer;
    l_plsql_block VARCHAR2(2000) := 'BEGIN :x := IM_API.openfolderneww'||p_link||'(:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o); END;';


   begin
       -- l_status := openfolderneww(folder, include_sub, top_n, top_option,
        --l_str1, l_str2, l_str3, l_str4, l_str5, l_str6, l_str7, l_str8,
        --l_str9, l_str10, l_index);
           -- dbms_output.put_line('before calling im');

        EXECUTE IMMEDIATE l_plsql_block USING OUT l_status, IN folder, IN include_sub,
        IN top_n, in top_option, out l_str1, out l_str2, out l_str3, out l_str4,out l_str5,
        out l_str6, out l_str7, out l_str8, out l_str9, out l_str10, out l_index;


        current_count := 1;
        incr_counter := 0;
        i:=1;

        while (i <= l_index) loop
            if (current_count = 1) then
                 l_loc :=  instr(l_str1, '<R>', 1,1);
                 if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                    else
                        l_current_row :=substr(l_str1,1,l_loc-1);
                        if (l_loc+3 < length(l_str1)) then
                            l_rest_rows :=substr(l_str1,l_loc+3);

                            l_str1 := l_rest_rows;

                        else l_str1 := 'EOL';
--                             dbms_output.put_line('str1 is empty now..');

                        end if;
                 end if;
            end if;
            if (current_count = 2) then
                 l_loc :=  instr(l_str2, '<R>', 1,1);
                 if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                    else
                     l_current_row :=substr(l_str2,1,l_loc-1);
                        if (l_loc+3 < length(l_str2)) then
                            l_rest_rows :=substr(l_str2,l_loc+3);

                            l_str2 := l_rest_rows;

                        else l_str2 := 'EOL';
                          --   dbms_output.put_line('str2 is empty now..');

                        end if;
                  end if;
            end if;
            if (current_count = 3) then
                 l_loc :=  instr(l_str3, '<R>', 1,1);
                  if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                    else
                        l_current_row :=substr(l_str3,1,l_loc-1);
                        if (l_loc+3 < length(l_str3)) then
                            l_rest_rows :=substr(l_str3,l_loc+3);

                            l_str3 := l_rest_rows;

                        else l_str3 := 'EOL';
                             --dbms_output.put_line('str3 is empty now..');

                        end if;
                 end if;
            end if;
           if (current_count = 4) then
                 l_loc :=  instr(l_str4, '<R>', 1,1);
                 if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                     else
                        l_current_row :=substr(l_str4,1,l_loc-1);
                        if (l_loc+3 < length(l_str4)) then
                            l_rest_rows :=substr(l_str4,l_loc+3);

                            l_str4 := l_rest_rows;

                        else l_str4 := 'EOL';
                         --    dbms_output.put_line('str4 is empty now..');

                        end if;
                 end if;
            end if;
           if (current_count = 5) then
                 l_loc :=  instr(l_str5, '<R>', 1,1);
                 if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                    else
                        l_current_row :=substr(l_str5,1,l_loc-1);
                        if (l_loc+3 < length(l_str5)) then
                            l_rest_rows :=substr(l_str5,l_loc+3);

                            l_str5 := l_rest_rows;

                        else l_str5 := 'EOL';
                        --     dbms_output.put_line('str5 is empty now..');

                        end if;
                 end if;
            end if;
           if (current_count = 6) then
                 l_loc :=  instr(l_str6, '<R>', 1,1);
                 if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                    else
                        l_current_row :=substr(l_str6,1,l_loc-1);
                        if (l_loc+3 < length(l_str6)) then
                            l_rest_rows :=substr(l_str6,l_loc+3);

                            l_str6 := l_rest_rows;

                        else l_str6 := 'EOL';
                            -- dbms_output.put_line('str6 is empty now..');

                        end if;
                 end if;
            end if;
           if (current_count = 7) then
                 l_loc :=  instr(l_str7, '<R>', 1,1);
                 if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                   else
                        l_current_row :=substr(l_str7,1,l_loc-1);
                        if (l_loc+3 < length(l_str7)) then
                            l_rest_rows :=substr(l_str7,l_loc+3);

                            l_str7 := l_rest_rows;

                        else l_str7 := 'EOL';
                            -- dbms_output.put_line('str7 is empty now..');

                        end if;
                 end if;
            end if;
           if (current_count = 8) then
                 l_loc :=  instr(l_str8, '<R>', 1,1);
                 if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                    else
                        l_current_row :=substr(l_str8,1,l_loc-1);
                        if (l_loc+3 < length(l_str8)) then
                            l_rest_rows :=substr(l_str8,l_loc+3);

                            l_str8 := l_rest_rows;

                        else l_str8 := 'EOL';
                           --  dbms_output.put_line('str8 is empty now..');

                        end if;
                 end if;
            end if;
           if (current_count = 9) then
                 l_loc :=  instr(l_str9, '<R>', 1,1);
                 if (l_loc = 0)
                    then
                        incr_counter :=1;
                        i:=i-1;
                    else
                        l_current_row :=substr(l_str9,1,l_loc-1);
                        if (l_loc+3 < length(l_str9)) then
                            l_rest_rows :=substr(l_str9,l_loc+3);

                            l_str9 := l_rest_rows;

                        else l_str9 := 'EOL';
                          --   dbms_output.put_line('str9 is empty now..');

                        end if;
                 end if;
            end if;
           if (current_count = 10) then
                 l_loc :=  instr(l_str10, '<R>', 1,1);
                 if (l_loc > 0) then
                    l_current_row :=substr(l_str10,1,l_loc-1);
                    l_rest_rows :=substr(l_str10,l_loc+3);
                    l_str10 := l_rest_rows;
                 end if;
            end if;

            if (incr_counter = 1)
                then
                    current_count := current_count +1;
                 --   dbms_output.put_line('advance to the next string..');

                    incr_counter := 0;
                else

                    l_loc:=instr(l_current_row,'<C>', 1,1);
                    message_records(i).msg_id:=substr(l_current_row,1,l_loc-1);
                    l_rest_columns:=substr(l_current_row, l_loc+3);
                    l_current_row := l_rest_columns;

                    l_loc:=instr(l_current_row,'<C>', 1,1);
                    message_records(i).smtp_msg_id:=substr(l_current_row,1,l_loc-1);
                    l_rest_columns:=substr(l_current_row, l_loc+3);
                    l_current_row := l_rest_columns;


            l_loc:=instr(l_current_row,'<C>', 1,1);
            message_records(i).sender_name:=substr(l_current_row,1,l_loc-1);
            l_rest_columns:=substr(l_current_row, l_loc+3);
            l_current_row := l_rest_columns;

            l_loc:=instr(l_current_row,'<C>', 1,1);
            message_records(i).received_date:=substr(l_current_row,1,l_loc-1);
            l_rest_columns:=substr(l_current_row, l_loc+3);
            l_current_row := l_rest_columns;

            l_loc:=instr(l_current_row,'<C>', 1,1);
            message_records(i).from_str:=substr(l_current_row,1,l_loc-1);
            l_rest_columns:=substr(l_current_row, l_loc+3);
            l_current_row := l_rest_columns;

            l_loc:=instr(l_current_row,'<C>', 1,1);
            message_records(i).to_str:=substr(l_current_row,1,l_loc-1);
            l_rest_columns:=substr(l_current_row, l_loc+3);
            l_current_row := l_rest_columns;

            l_loc:=instr(l_current_row,'<C>', 1,1);
            message_records(i).priority:=substr(l_current_row,1,l_loc-1);
            l_rest_columns:=substr(l_current_row, l_loc+3);
            l_current_row := l_rest_columns;

             l_loc:=instr(l_current_row,'<C>', 1,1);
            message_records(i).replyto:=substr(l_current_row,1,l_loc-1);
            l_rest_columns:=substr(l_current_row, l_loc+3);
            l_current_row := l_rest_columns;

            l_loc:=instr(l_current_row,'<C>', 1,1);
            message_records(i).folder_path:=substr(l_current_row,1,l_loc-1);
            message_records(i).subject:=substr(l_current_row, l_loc+3);
            end if;


          i:= i+1;
         end loop;
        return l_status;

   end;
END IEM_IM_WRAPPERS_PVT;

/
