--------------------------------------------------------
--  DDL for Package Body JTF_ACTIVITY_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ACTIVITY_MANAGER" AS
/* $Header: jtfactlb.pls 120.1 2005/07/02 02:30:09 appldev ship $ */

procedure write(
appid IN number, activityname IN varchar2, attrnames IN t_valuetable, valuen IN t_valuetable ) is

v_attrname jtf_act_types_attrs_tl.attribute_name%TYPE;
v_userid jtf_act_activity_logs.jtf_act_activity_logs_user_id%TYPE ;
v_component jtf_act_activity_logs.component%TYPE ;
v_numvalue number;
v_tablename jtf_act_types_b.table_name%TYPE;
v_columns  t_valuetable;
j binary_integer;
i binary_integer;
cid integer;
ignore integer;
activitynameid number;

cursor C is
  SELECT t2.attribute_name, to_number(LTRIM(b.column_name, 'column'))
  from jtf_act_types_tl t1, jtf_act_types_attrs_b b, jtf_act_types_attrs_tl t2
  where t1.activity_name = activityname and t1.language=userenv('LANG')
        and t1.activity_name_id = b.activity_name_id
        and b.attribute_name_id = t2.attribute_name_id and t2.language=userenv('LANG');


cursor C2 is
  SELECT b.table_name
  from jtf_act_types_b b, jtf_act_types_tl tl
  where b.activity_name_id = tl.activity_name_id
        and tl.activity_name = activityname
        and tl.language = userenv('LANG');
begin

  for i in 1..41 loop
   v_columns(i) := null;
  end loop;

  open C;

  loop
   fetch C into v_attrname, v_numvalue;
   Exit when C%NOTFOUND;

   for j in 1..attrnames.LAST loop

    if  lower(v_attrname) = lower(attrnames(j)) then
        v_columns(v_numvalue) := valuen(j);
      exit;
    end if;
   end loop;

  end loop;

  close C;

  for j in 1..attrnames.LAST loop
    if  lower(attrnames(j)) = 'user_id' then
      v_userid := TO_NUMBER(valuen(j));
    elsif  lower(attrnames(j)) = 'component' then
      v_component := valuen(j);
    end if;
  end loop;

  if v_userid is null then
    return;
  end if;

  open c2;

  loop
   fetch C2 into v_tablename;
   Exit when C2%NOTFOUND;

  end loop;
  close c2;

  select activity_name_id into activitynameid from jtf_act_types_tl
  where language = userenv('LANG') and activity_name = activityname;

  cid := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE(cid, 'insert into '|| v_tablename || '(activity_name_id, application_id ,
                jtf_act_activity_logs_user_id, created_by, creation_date, last_updated_by,
                last_update_date, component, column1, column2, column3, column4,column5,
                column6, column7,column8,column9, column10, column11, column12, column13,
                column14,column15, column16, column17,column18,column19, column20, column21,
                column22, column23, column24,column25, column26, column27,column28, column29,
                column30, column31, column32, column33, column34, column35, column36, column37,
                column38, column39, column40)
           values (:activitynameid, :appid, :userid, :userid, sysdate, :userid, sysdate,
           :component, :column1, :column2, :column3, :column4, :column5, :column6, :column7,
           :column8, :column9, :column10, :column11, :column12, :column13, :column14, :column15,
           :column16, :column17, :column18, :column19, :column20, :column21, :column22,
           :column23, :column24, :column25, :column26, :column27, :column28, :column29,
           :column30, :column31, :column32, :column33, :column34, :column35, :column36,
           :column37, :column38, :column39, :column40 )', dbms_sql.v7);

  DBMS_SQL.bind_variable(cid, ':activitynameid', activitynameid);
  DBMS_SQL.bind_variable(cid, ':appid', appid);
  DBMS_SQL.bind_variable(cid, ':userid', v_userid);
  DBMS_SQL.bind_variable(cid, ':component', v_component);
  DBMS_SQL.bind_variable(cid, ':column1', v_columns(1));
  DBMS_SQL.bind_variable(cid, ':column2', v_columns(2));
  DBMS_SQL.bind_variable(cid, ':column3', v_columns(3));
  DBMS_SQL.bind_variable(cid, ':column4', v_columns(4));
  DBMS_SQL.bind_variable(cid, ':column5', v_columns(5));
  DBMS_SQL.bind_variable(cid, ':column6', v_columns(6));
  DBMS_SQL.bind_variable(cid, ':column7', v_columns(7));
  DBMS_SQL.bind_variable(cid, ':column8', v_columns(8));
  DBMS_SQL.bind_variable(cid, ':column9', v_columns(9));
  DBMS_SQL.bind_variable(cid, ':column10', v_columns(10));
  DBMS_SQL.bind_variable(cid, ':column11', v_columns(11));
  DBMS_SQL.bind_variable(cid, ':column12', v_columns(12));
  DBMS_SQL.bind_variable(cid, ':column13', v_columns(13));
  DBMS_SQL.bind_variable(cid, ':column14', v_columns(14));
  DBMS_SQL.bind_variable(cid, ':column15', v_columns(15));
  DBMS_SQL.bind_variable(cid, ':column16', v_columns(16));
  DBMS_SQL.bind_variable(cid, ':column17', v_columns(17));
  DBMS_SQL.bind_variable(cid, ':column18', v_columns(18));
  DBMS_SQL.bind_variable(cid, ':column19', v_columns(19));
  DBMS_SQL.bind_variable(cid, ':column20', v_columns(20));
  DBMS_SQL.bind_variable(cid, ':column21', v_columns(21));
  DBMS_SQL.bind_variable(cid, ':column22', v_columns(22));
  DBMS_SQL.bind_variable(cid, ':column23', v_columns(23));
  DBMS_SQL.bind_variable(cid, ':column24', v_columns(24));
  DBMS_SQL.bind_variable(cid, ':column25', v_columns(25));
  DBMS_SQL.bind_variable(cid, ':column26', v_columns(26));
  DBMS_SQL.bind_variable(cid, ':column27', v_columns(27));
  DBMS_SQL.bind_variable(cid, ':column28', v_columns(28));
  DBMS_SQL.bind_variable(cid, ':column29', v_columns(29));
  DBMS_SQL.bind_variable(cid, ':column30', v_columns(30));
  DBMS_SQL.bind_variable(cid, ':column31', v_columns(31));
  DBMS_SQL.bind_variable(cid, ':column32', v_columns(32));
  DBMS_SQL.bind_variable(cid, ':column33', v_columns(33));
  DBMS_SQL.bind_variable(cid, ':column34', v_columns(34));
  DBMS_SQL.bind_variable(cid, ':column35', v_columns(35));
  DBMS_SQL.bind_variable(cid, ':column36', v_columns(36));
  DBMS_SQL.bind_variable(cid, ':column37', v_columns(37));
  DBMS_SQL.bind_variable(cid, ':column38', v_columns(38));
  DBMS_SQL.bind_variable(cid, ':column39', v_columns(39));
  DBMS_SQL.bind_variable(cid, ':column40', v_columns(40));
  ignore := DBMS_SQL.EXECUTE(cid);
  DBMS_SQL.CLOSE_CURSOR(cid);
  EXCEPTION
   when NO_DATA_FOUND then
        RAISE;
   when others then
 	DBMS_SQL.CLOSE_CURSOR(cid);
	RAISE;

end write;

procedure write(appid IN number, activityname varchar2, attrnames IN v_valuearray, valuen IN v_valuearray)

is
	i binary_integer;
	outv_names t_valuetable;
	outv_valuen t_valuetable;

begin

	for i IN 1..attrnames.COUNT loop
		outv_names(i) := attrnames(i);
		outv_valuen(i) := valuen(i);
	end loop;

	write (appid, activityname, outv_names, outv_valuen);

end write;

procedure write(
 app_id IN number,
 activity_name IN varchar2,
 userid number,
 component  varchar2,
 num_attributes number,
 attribute1 varchar2 default null,
 value1 varchar2 default null,
 attribute2 varchar2 default null,
 value2 varchar2 default null,
 attribute3 varchar2 default null,
 value3 varchar2 default null,
 attribute4 varchar2 default null,
 value4 varchar2 default null,
 attribute5 varchar2 default null,
 value5 varchar2 default null,
 attribute6 varchar2 default null,
 value6 varchar2 default null,
 attribute7 varchar2 default null,
 value7 varchar2 default null,
 attribute8 varchar2 default null,
 value8 varchar2 default null,
 attribute9 varchar2 default null,
 value9 varchar2 default null,
 attribute10 varchar2 default null,
 value10 varchar2 default null,
 attribute11 varchar2 default null,
 value11 varchar2 default null,
 attribute12 varchar2 default null,
 value12 varchar2 default null,
 attribute13 varchar2 default null,
 value13 varchar2 default null,
 attribute14 varchar2 default null,
 value14 varchar2 default null,
 attribute15 varchar2 default null,
 value15 varchar2 default null,
 attribute16 varchar2 default null,
 value16 varchar2 default null,
 attribute17 varchar2 default null,
 value17 varchar2 default null,
 attribute18 varchar2 default null,
 value18 varchar2 default null,
 attribute19 varchar2 default null,
 value19 varchar2 default null,
 attribute20 varchar2 default null,
 value20 varchar2 default null,
 attribute21 varchar2 default null,
 value21 varchar2 default null,
 attribute22 varchar2 default null,
 value22 varchar2 default null,
 attribute23 varchar2 default null,
 value23 varchar2 default null,
 attribute24 varchar2 default null,
 value24 varchar2 default null,
 attribute25 varchar2 default null,
 value25 varchar2 default null,
 attribute26 varchar2 default null,
 value26 varchar2 default null,
 attribute27 varchar2 default null,
 value27 varchar2 default null,
 attribute28 varchar2 default null,
 value28 varchar2 default null,
 attribute29 varchar2 default null,
 value29 varchar2 default null,
 attribute30 varchar2 default null,
 value30 varchar2 default null,
 attribute31 varchar2 default null,
 value31 varchar2 default null,
 attribute32 varchar2 default null,
 value32 varchar2 default null,
 attribute33 varchar2 default null,
 value33 varchar2 default null,
 attribute34 varchar2 default null,
 value34 varchar2 default null,
 attribute35 varchar2 default null,
 value35 varchar2 default null,
 attribute36 varchar2 default null,
 value36 varchar2 default null,
 attribute37 varchar2 default null,
 value37 varchar2 default null,
 attribute38 varchar2 default null,
 value38 varchar2 default null,
 attribute39 varchar2 default null,
 value39 varchar2 default null,
 attribute40 varchar2 default null,
 value40 varchar2 default null)

is

i binary_integer;

inv_names  t_valuetable;
inv_valuen t_valuetable;

outv_names  t_valuetable;
outv_valuen t_valuetable;

begin

inv_names(1) := attribute1;
inv_names(2) := attribute2;
inv_names(3) := attribute3;
inv_names(4) := attribute4;
inv_names(5) := attribute5;
inv_names(6) := attribute6;
inv_names(7) := attribute7;
inv_names(8) := attribute8;
inv_names(9) := attribute9;
inv_names(10) := attribute10;
inv_names(11) := attribute11;
inv_names(12) := attribute12;
inv_names(13) := attribute13;
inv_names(14) := attribute14;
inv_names(15) := attribute15;
inv_names(16) := attribute16;
inv_names(17) := attribute17;
inv_names(18) := attribute18;
inv_names(19) := attribute19;
inv_names(20) := attribute20;
inv_names(21) := attribute21;
inv_names(22) := attribute22;
inv_names(23) := attribute23;
inv_names(24) := attribute24;
inv_names(25) := attribute25;
inv_names(26) := attribute26;
inv_names(27) := attribute27;
inv_names(28) := attribute28;
inv_names(29) := attribute29;
inv_names(30) := attribute30;
inv_names(31) := attribute31;
inv_names(32) := attribute32;
inv_names(33) := attribute33;
inv_names(34) := attribute34;
inv_names(35) := attribute35;
inv_names(36) := attribute36;
inv_names(37) := attribute37;
inv_names(38) := attribute38;
inv_names(39) := attribute39;
inv_names(40) := attribute40;

inv_valuen(1) := value1;
inv_valuen(2) := value2;
inv_valuen(3) := value3;
inv_valuen(4) := value4;
inv_valuen(5) := value5;
inv_valuen(6) := value6;
inv_valuen(7) := value7;
inv_valuen(8) := value8;
inv_valuen(9) := value9;
inv_valuen(10) := value10;
inv_valuen(11) := value11;
inv_valuen(12) := value12;
inv_valuen(13) := value13;
inv_valuen(14) := value14;
inv_valuen(15) := value15;
inv_valuen(16) := value16;
inv_valuen(17) := value17;
inv_valuen(18) := value18;
inv_valuen(19) := value39;
inv_valuen(20) := value20;
inv_valuen(21) := value21;
inv_valuen(22) := value22;
inv_valuen(23) := value23;
inv_valuen(24) := value24;
inv_valuen(25) := value25;
inv_valuen(26) := value26;
inv_valuen(27) := value27;
inv_valuen(28) := value28;
inv_valuen(29) := value29;
inv_valuen(30) := value30;
inv_valuen(31) := value31;
inv_valuen(32) := value32;
inv_valuen(33) := value33;
inv_valuen(34) := value34;
inv_valuen(35) := value35;
inv_valuen(36) := value36;
inv_valuen(37) := value37;
inv_valuen(38) := value38;
inv_valuen(39) := value39;
inv_valuen(40) := value40;


for i in 1..num_attributes loop
 outv_names(i) := inv_names(i);
 outv_valuen(i) := inv_valuen(i);
end loop;

i := num_attributes + 1;

outv_names(i) := 'user_id';
outv_valuen(i) := TO_CHAR(userid);
i := i+1;

outv_names(i) := 'component';
outv_valuen(i) := component;

write (app_id, activity_name, outv_names, outv_valuen);

end write;

procedure run is
v_PK NUMBER;
v_NameID NUMBER;
v_AttrID NUMBER;
v_ATTR VARCHAR2(50);
begin

write(10, 'Customer_DisputeBill2', 10, 'jtf', '3', 'billid', 'debby', 'billerid', 'li', 'accountid', '12434' );

--DBMS_OUTPUT.ENABLE(1000000);
--DBMS_OUTPUT.PUT_LINE('This is the output' );
--DBMS_OUTPUT.PUT_LINE('Value of primary key is: ' || v_PK);
--DBMS_OUTPUT.PUT_LINE('Value of name id  is: ' || v_NameID);
end run;

end jtf_activity_manager;

/
