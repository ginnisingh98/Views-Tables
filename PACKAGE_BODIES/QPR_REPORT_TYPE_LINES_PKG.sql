--------------------------------------------------------
--  DDL for Package Body QPR_REPORT_TYPE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_REPORT_TYPE_LINES_PKG" as
/* $Header: qpr_reptyp_linb.pls 120.0.12010000.2 2009/07/02 06:56:10 vinnaray ship $ */
procedure load_row(P_REPORT_TYPE_LINE_ID VARCHAR2,
		   P_REPORT_TYPE_LINE_NAME VARCHAR2,
		   P_ASPECT_RATIO VARCHAR2,
		   P_REPORT_TYPE_LINE_CODE VARCHAR2,
		   P_WIDTH VARCHAR2,
		   P_OWNER VARCHAR2,
		   P_REPORT_OPTIONS VARCHAR2,
		   P_REPORT_OPTIONS_II VARCHAR2,
		   P_REPORT_METADATA VARCHAR2,
		   P_REPORT_METADATA_II VARCHAR2,
		   P_REPORT_METADATA_III VARCHAR2,
		   P_REPORT_METADATA_IV VARCHAR2,
		   P_REPORT_MODIFIERS VARCHAR2,
		   P_REPORT_MODIFIERS_II VARCHAR2) as
/*l_met_clob1 clob;
l_met_clob2 clob;
l_met_clob3 clob;
l_met_clob4 clob;
l_met_insert_clob clob;
l_opt_clob1 clob;
l_opt_clob2 clob;
l_opt_insert_clob clob;
l_mod_clob1 clob;
l_mod_clob2 clob;
l_mod_insert_clob clob;
l_user_id NUMBER;*/
begin
null; /*
l_user_id := FND_LOAD_UTIL.OWNER_ID(P_OWNER);
dbms_lob.createtemporary(l_met_clob1,true);
dbms_lob.open(l_met_clob1,dbms_lob.lob_readwrite);

dbms_lob.createtemporary(l_met_clob2,true);
dbms_lob.open(l_met_clob2,dbms_lob.lob_readwrite);

dbms_lob.createtemporary(l_met_clob3,true);
dbms_lob.open(l_met_clob3,dbms_lob.lob_readwrite);

dbms_lob.createtemporary(l_met_clob4,true);
dbms_lob.open(l_met_clob4,dbms_lob.lob_readwrite);

--dbms_lob.createtemporary(l_met_insert_clob,true);
--dbms_lob.open(l_met_insert_clob,dbms_lob.lob_readwrite);

dbms_lob.createtemporary(l_opt_clob1,true);
dbms_lob.open(l_opt_clob1,dbms_lob.lob_readwrite);

dbms_lob.createtemporary(l_opt_clob2,true);
dbms_lob.open(l_opt_clob2,dbms_lob.lob_readwrite);

--dbms_lob.createtemporary(l_opt_insert_clob,true);
--dbms_lob.open(l_opt_insert_clob,dbms_lob.lob_readwrite);

dbms_lob.createtemporary(l_mod_clob1,true);
dbms_lob.open(l_mod_clob1,dbms_lob.lob_readwrite);

dbms_lob.createtemporary(l_mod_clob2,true);
dbms_lob.open(l_mod_clob2,dbms_lob.lob_readwrite);

--dbms_lob.createtemporary(l_mod_insert_clob,true);
--dbms_lob.open(l_mod_insert_clob,dbms_lob.lob_readwrite);

l_met_insert_clob := null;
l_opt_insert_clob := null;
l_mod_insert_clob := null;

if ( P_REPORT_METADATA <> fnd_load_util.null_value ) then --is not null ) then
dbms_lob.createtemporary(l_met_insert_clob,true);
dbms_lob.open(l_met_insert_clob,dbms_lob.lob_readwrite);

   dbms_lob.write(l_met_clob1,length(P_REPORT_METADATA),1,P_REPORT_METADATA);
   l_met_insert_clob := l_met_clob1;
end if;

if ( P_REPORT_METADATA_II <> fnd_load_util.null_value) then --is not null ) then
   dbms_lob.write(l_met_clob2,length(P_REPORT_METADATA_II),1,P_REPORT_METADATA_II);
   dbms_lob.append(l_met_insert_clob,l_met_clob2);
end if;

if ( P_REPORT_METADATA_III <> fnd_load_util.null_value) then  --is not null ) then
   dbms_lob.write(l_met_clob3,length(P_REPORT_METADATA_III),1,P_REPORT_METADATA_III);
   dbms_lob.append(l_met_insert_clob,l_met_clob3);
end if;

if ( P_REPORT_METADATA_IV <> fnd_load_util.null_value) then --is not null ) then
   dbms_lob.write(l_met_clob4,length(P_REPORT_METADATA_IV),1,P_REPORT_METADATA_IV);
   dbms_lob.append(l_met_insert_clob,l_met_clob4);
end if;

if ( P_REPORT_OPTIONS <> fnd_load_util.null_value) then --is not null ) then
dbms_lob.createtemporary(l_opt_insert_clob,true);
dbms_lob.open(l_opt_insert_clob,dbms_lob.lob_readwrite);

   dbms_lob.write(l_opt_clob1,length(P_REPORT_OPTIONS),1,P_REPORT_OPTIONS);
   l_opt_insert_clob := l_opt_clob1;
end if;

if ( P_REPORT_OPTIONS_II <> fnd_load_util.null_value) then --is not null ) then
   dbms_lob.write(l_opt_clob2,length(P_REPORT_OPTIONS_II),1,P_REPORT_OPTIONS_II);
   dbms_lob.append(l_opt_insert_clob,l_opt_clob2);
end if;

if ( P_REPORT_MODIFIERS <> fnd_load_util.null_value) then --is not null ) then
dbms_lob.createtemporary(l_mod_insert_clob,true);
dbms_lob.open(l_mod_insert_clob,dbms_lob.lob_readwrite);

   dbms_lob.write(l_mod_clob1,length(P_REPORT_MODIFIERS),1,P_REPORT_MODIFIERS);
   l_mod_insert_clob := l_mod_clob1;
end if;

if ( P_REPORT_MODIFIERS_II <> fnd_load_util.null_value) then --is not null ) then
   dbms_lob.write(l_mod_clob2,length(P_REPORT_MODIFIERS_II),1,P_REPORT_MODIFIERS_II);
   dbms_lob.append(l_mod_insert_clob,l_mod_clob2);
end if;

           update qpr_report_type_lines
              set
    	        report_type_line_name = P_REPORT_TYPE_LINE_NAME,
		report_metadata = l_met_insert_clob,
		report_modifiers = l_mod_insert_clob,
                report_options = l_opt_insert_clob,
		aspect_ratio = to_number(P_ASPECT_RATIO),
		report_type_line_code = P_REPORT_TYPE_LINE_CODE,
		width = to_number(P_WIDTH),
              last_update_date =sysdate,
              last_updated_by = l_user_id,
              last_update_login = 0
           where report_type_line_id = to_number(P_REPORT_TYPE_LINE_ID);

           if SQL%NOTFOUND then
             insert into qpr_report_type_lines
               (REPORT_TYPE_LINE_ID,
                REPORT_TYPE_LINE_NAME,
		REPORT_TYPE_LINE_CODE,
		ASPECT_RATIO,
		WIDTH,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
		REPORT_OPTIONS,
		REPORT_METADATA,
		REPORT_MODIFIERS
		)
            values
                (to_number(P_REPORT_TYPE_LINE_ID),
                P_REPORT_TYPE_LINE_NAME,
		P_REPORT_TYPE_LINE_CODE,
		to_number(P_ASPECT_RATIO),
		to_number(P_WIDTH),
                sysdate,
                l_user_id,
                sysdate,
                l_user_id,
                0,
		l_opt_insert_clob,
                l_met_insert_clob,
                l_mod_insert_clob
		);
	    end if;
  dbms_lob.close(l_met_clob1);
  dbms_lob.close(l_met_clob2);
  dbms_lob.close(l_met_clob3);
  dbms_lob.close(l_met_clob4);
  dbms_lob.close(l_met_insert_clob);
  dbms_lob.close(l_opt_clob1);
  dbms_lob.close(l_opt_clob2);
  dbms_lob.close(l_opt_insert_clob);
  dbms_lob.close(l_mod_clob1);
  dbms_lob.close(l_mod_clob2);
  dbms_lob.close(l_mod_insert_clob);
*/
  EXCEPTION
     WHEN OTHERS then
	NULL;
end load_row;
end QPR_REPORT_TYPE_LINES_PKG;

/
