--------------------------------------------------------
--  DDL for Package Body BIV_HS_SR_ARRIVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_HS_SR_ARRIVAL_PKG" AS
/* $Header: bivsratb.pls 115.26 2004/03/05 07:52:40 vganeshk ship $ */


function base_column_label(p_param_str varchar2) return varchar2 is
  l_label     varchar2(100);
  x_viewby   varchar2(100);
 begin
x_viewby:=biv_core_pkg.get_parameter_value(p_param_str,'p_viewby');
execute immediate 'select meaning   from fnd_lookups where lookup_type=''BIV_VIEW_BY''
and  lookup_code=:x_viewby'  into l_label using x_viewby;
return l_label;
end base_column_label;


procedure    Agnt_sr_arrival_time(p_param_str in varchar2)
IS
-- cursor variable
cursor update_tmp_tbl is SELECT ID,SESSION_ID
FROM biv_tmp_sr_arrvl where ID is not null
  and session_id = biv_core_pkg.get_session_id;
-- dbms sql variable
owner_lists  dbms_sql.number_table;
cur pls_integer:=dbms_sql.open_cursor;
cur2 pls_integer:=dbms_sql.open_cursor;
fdbk pls_integer;
v_batchsize  constant integer :=100;
sql_stmt      varchar2(2000);
insert_stmt   varchar2(4000);
-- for loop control variables
n    integer;
i    number;
j    number;
-- time zone variables
l_start_tz    number;
l_end_tz     number;
l_tz_diff    number;
l_return_status varchar2(10);
l_msg_count number;
l_msg_data  varchar2(30);
l_num_rows   integer;
-- array processing variables
type array_type is table of number
index by binary_integer;
a_start array_type;
a_end   array_type;
l_tm_zn array_type;
-- core package variable
x_where_clause varchar2(2000);
x_from_list    varchar2(2000);
l_new_param_str varchar2(200);
l_new_param_str1 varchar2(200);
x_session        number;
l_reached_upto varchar2(100);

l_param_str varchar2(2000);
l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
l_ttl_rec number;
l_ttl_desc fnd_lookups.meaning % type;

begin

x_session:=biv_core_pkg.get_session_id;
biv_core_pkg.clean_dcf_table('BIV_TMP_SR_ARRVL');
biv_core_pkg.g_report_type := 'HS';

l_param_str := p_param_str || biv_core_pkg.g_param_sep || 'P_VIEW_BY=AGRP';

biv_core_pkg.get_report_parameters(l_param_str);
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('param str  :'||l_param_str,'BIV_AGNT_SR_ARRIVAL');
end if;
biv_core_pkg.g_cr_end := trunc(biv_core_pkg.g_cr_end +1);
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Start Date  :'||
                     to_char(biv_core_pkg.g_cr_st,'dd-mon-yyyy hh24:mi:ss'),
                     'BIV_AGNT_SR_ARRIVAL');
   biv_core_pkg.biv_debug('End Date  :'||
                     to_char(biv_core_pkg.g_cr_end,'dd-mon-yyyy hh24:mi:ss'),
                     'BIV_AGNT_SR_ARRIVAL');
end if;
-- Change for Bug 3386946
x_from_list:=' from cs_incidents_b_sec sr, biv_sr_summary srs ';
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_where_clause:=x_where_clause||' and  sr.incident_id=srs.incident_id and sr.owner_group_id is not null ';

--from cs_incidents_all_b sr, biv_sr_summary srs, jtf_rs_groups_denorm adnorm1 where 1 = 1 and adnorm1.parent_group_id = :adnorm1_parent_group_id and
--srs.incident_id=sr.incident_id and srs.arrival_time = :arrival_time and sr.owner_group_id = adnorm1.group_id)



--sql_stmt:='SELECT  sr.owner_group_id  '||x_from_list|| x_where_clause ||' group by sr.owner_group_id';
sql_stmt:='SELECT  adnorm.parent_group_id  '||x_from_list|| x_where_clause ||' group by adnorm.parent_group_id';

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug(sql_stmt,'BIV_AGNT_SR_ARRIVAL');
end if;

insert_stmt:='insert into biv_tmp_sr_arrvl (report_code,session_id,ID,col4,col6,col8,col10,col12,col14,col16,col18,col20,col22,col24,col26,col28,col30,col32,col34,col36,col38,col40,col42,col44,col46,col48,
              col50,col52,col54,col56,col58,col60,col62,col64,col66,col68,col70,col72,col74,col76,col78,col80,col82,col84,col86,col88,col90,col92,col94,col96,col98,col100)
              (select ''BIV_AGNT_SR_ARRIVAL'',:x_session,:in_owner_lists, count(*),count(decode(arrival_time,0,arrival_time)),
              count(decode(arrival_time,0.5,arrival_time)),count(decode(arrival_time,1,arrival_time)),count(decode(arrival_time,1.5,arrival_time)),count(decode(arrival_time,2,arrival_time)),
              count(decode(arrival_time,2.5,arrival_time)),count(decode(arrival_time,3,arrival_time)),count(decode(arrival_time,3.5,arrival_time)),count(decode(arrival_time,4,arrival_time)),
              count(decode(arrival_time,4.5,arrival_time)),count(decode(arrival_time,5,arrival_time)),count(decode(arrival_time,5.5,arrival_time)) ,count(decode(arrival_time,6,arrival_time)),
              count(decode(arrival_time,6.5,arrival_time)),count(decode(arrival_time,7,arrival_time)),count(decode(arrival_time,7.5,arrival_time)),count(decode(arrival_time,8,arrival_time)),
              count(decode(arrival_time,8.5,arrival_time)),count(decode(arrival_time,9,arrival_time)),count(decode(arrival_time,9.5,arrival_time)),count(decode(arrival_time,10,arrival_time)) ,
              count(decode(arrival_time,10.5,arrival_time)),count(decode(arrival_time,11,arrival_time)),count(decode(arrival_time,11.5,arrival_time)),count(decode(arrival_time,12,arrival_time)),
              count(decode(arrival_time,12.5,arrival_time)),count(decode(arrival_time,13,arrival_time)),count(decode(arrival_time,13.5,arrival_time)),count(decode(arrival_time,14,arrival_time)),
              count(decode(arrival_time,14.5,arrival_time)),count(decode(arrival_time,15,arrival_time)),count(decode(arrival_time,15.5,arrival_time)),count(decode(arrival_time,16,arrival_time)),
              count(decode(arrival_time,16.5,arrival_time)),count(decode(arrival_time,17,arrival_time)),count(decode(arrival_time,17.5,arrival_time)),count(decode(arrival_time,18,arrival_time)),
              count(decode(arrival_time,18.5,arrival_time)),count(decode(arrival_time,19,arrival_time)),count(decode(arrival_time,19.5,arrival_time)) ,count(decode(arrival_time,20,arrival_time)),
              count(decode(arrival_time,20.5,arrival_time)),count(decode(arrival_time,21,arrival_time)),count(decode(arrival_time,21.5,arrival_time)),count(decode(arrival_time,22,arrival_time)),
              count(decode(arrival_time,22.5,arrival_time)),count(decode(arrival_time,23,arrival_time)),count(decode(arrival_time,23.5,arrival_time))
              '||x_from_list||x_where_clause||'and   adnorm.parent_group_id=:in_owner_lists)';
              --'||x_from_list||x_where_clause||'and   sr.owner_group_id=:in_owner_lists)';

 --  '||x_where_clause||
 --             where  srs.incident_id=sr.incident_id AND  sr.owner_group_id=:in_owner_lists)';
 --  from biv_sr_summary srs,cs_incidents_all_b sr
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug(insert_stmt,'BIV_AGNT_SR_ARRIVAL');
end if;

dbms_sql.parse(cur,sql_stmt,dbms_sql.native);
dbms_sql.parse(cur2,insert_stmt,dbms_sql.native);

dbms_sql.define_array(cur,1,owner_lists,v_batchsize,1);

biv_core_pkg.bind_all_variables(cur);
biv_core_pkg.bind_all_variables(cur2);


fdbk:=dbms_sql.execute(cur);

loop
l_num_rows  :=dbms_sql.fetch_rows(cur);
dbms_sql.column_value(cur,1,owner_lists);

if l_num_rows=0 then
exit;
end if;

dbms_sql.bind_array(cur2,':in_owner_lists',owner_lists,1,l_num_rows);
dbms_sql.bind_variable(cur2,':x_session',x_session);


fdbk:=dbms_sql.execute(cur2);
exit when l_num_rows < v_batchsize;

end loop;
dbms_sql.close_cursor(cur);
dbms_sql.close_cursor(cur2);
l_start_tz:=nvl(fnd_profile.value('SERVER_TIMEZONE_ID'),0);

if biv_core_pkg.g_tm_zn is not null then
l_end_tz:=to_number(nvl(biv_core_pkg.g_tm_zn,0));
else
l_end_tz:=nvl(fnd_profile.value('SERVER_TIMEZONE_ID'),0);
end if;

CS_TZ_GET_DETAILS_PVT.GET_LEADTIME(1.0,'T',l_start_tz,l_end_tz,l_tz_diff,l_return_status,l_msg_count,l_msg_data);

n:=nvl(l_tz_diff,0);

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Server Time Zone:'||l_start_tz,
                                                  'BIV_AGNT_SR_ARRIVAL');
   biv_core_pkg.biv_debug('client passed time zone :'||l_end_tz,
                                                  'BIV_AGNT_SR_ARRIVAL');
   biv_core_pkg.biv_debug('time zone  diff :'||l_tz_diff,'BIV_AGNT_SR_ARRIVAL');
   biv_core_pkg.biv_debug('the value of n :'||n,'BIV_AGNT_SR_ARRIVAL');
end if;

for rec in update_tmp_tbl
loop
select col6,col8,col10,col12,col14,col16,col18,col20,
       col22,col24,col26,col28,col30,col32,col34,col36,
       col38,col40,col42,col44,col46,col48,col50,col52,
       col54,col56,col58,col60,col62,col64,col66,col68,
       col70,col72,col74,col76,col78,col80,col82,col84,
       col86,col88,col90,col92,col94,col96,col98,col100
 into  a_start(1),a_start(2),a_start(3),a_start(4),a_start(5),a_start(6),a_start(7),a_start(8),
       a_start(9),a_start(10), a_start(11),a_start(12),a_start(13),a_start(14),a_start(15),a_start(16),
       a_start(17),a_start(18),a_start(19),a_start(20),a_start(21),a_start(22),a_start(23),a_start(24),
       a_start(25),a_start(26),a_start(27),a_start(28),a_start(29),a_start(30),a_start(31),a_start(32),
       a_start(33),a_start(34),a_start(35),a_start(36),a_start(37),a_start(38),a_start(39),a_start(40),
       a_start(41),a_start(42),a_start(43),a_start(44),a_start(45),a_start(46),a_start(47),a_start(48)
 from biv_tmp_sr_arrvl  where ID=rec.ID and  session_id=rec.session_id;


-- array processing logic



if n > 0 then
for i in 1..48 loop
    j:=i+2*n;
  if j > 48 then j:=j-48; end if;
    a_end(j):=a_start(i);

end loop;
end if;

if n < 0 then
for i in REVERSE 1..48 loop
    j:=i+2*n;
  if j <= 0 then j:=j+48; end if;
    a_end(j):=a_start(i);
end loop;
end if;

if n <> 0 then
l_reached_upto := 'Before update due to timezone difference';
update biv_tmp_sr_arrvl
set col6=a_end(1),col8=a_end(2),col10=a_end(3),col12=a_end(4),col14=a_end(5),col16=a_end(6),col18=a_end(7),
         col20=a_end(8),col22=a_end(9),col24=a_end(10),col26=a_end(11),col28=a_end(12),col30=a_end(13),col32=a_end(14),
         col34=a_end(15),col36=a_end(16),col38=a_end(17),col40=a_end(18),col42=a_end(19),col44=a_end(20),col46=a_end(21),
         col48=a_end(22),col50=a_end(23),col52=a_end(24),col54=a_end(25),col56=a_end(26),col58=a_end(27),col60=a_end(28),
         col62=a_end(29),col64=a_end(30),col66=a_end(31),col68=a_end(32),col70=a_end(33),col72=a_end(34),col74=a_end(35),
         col76=a_end(36),col78=a_end(37),col80=a_end(38),col82=a_end(39),col84=a_end(40),col86=a_end(41),col88=a_end(42),
         col90=a_end(43),col92=a_end(44),col94=a_end(45),col96=a_end(46),col98=a_end(47),col100=a_end(48)
         where ID=rec.ID and session_id=rec.session_id      ;
end if;
end loop;

l_reached_upto := 'Before update group name';
update biv_tmp_sr_arrvl d
  set col2=(select substr(group_name,1,50)
                    from jtf_rs_groups_vl
                   where group_id =d.ID )  ;

biv_core_pkg.reset_view_by_param;

l_new_param_str := 'BIV_HS_SR_ARRIVAL_PRD' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
if (biv_core_pkg.g_tm_zn is not null) then
  l_new_param_str := l_new_param_str ||
                  'P_TM_ZN' || biv_core_pkg.g_value_sep ||
                  biv_core_pkg.g_tm_zn || biv_core_pkg.g_param_sep;
end if;
l_new_param_str := l_new_param_str ||'P_AGRP' ||biv_core_pkg.g_value_sep ;
          --        'jtfBinId' ||biv_core_pkg.g_value_sep || 'BIV_HS_SR_ARRIVAL_PRD' ||biv_core_pkg.g_param_sep ||
l_new_param_str1 := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||biv_core_pkg.reconstruct_param_str;
-- Change for Bug 2948411
l_new_param_str1 := l_new_param_str1 || 'P_PREVR' || biv_core_pkg.g_value_sep ||
'BIV_HS_SR_ARRIVAL_TM' || biv_core_pkg.g_param_sep;
l_new_param_str1 := l_new_param_str1 ||'P_AGRP' ||biv_core_pkg.g_value_sep ;
-- 'jtfBinId' ||biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' || biv_core_pkg.g_param_sep ||

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('the parameter string constructed for ' ||
                          ' BIV_HS_SR_ARRIVAL_PRD :'||
                          l_new_param_str,'BIV_AGNT_SR_ARRIVAL');
   biv_core_pkg.biv_debug('the parameter string constructed for ' ||
                          ' BIV_SERVICE_REQUEST :'||
                          l_new_param_str1,'BIV_AGNT_SR_ARRIVAL');
end if;

l_reached_upto := 'Before updating hyperlinks';
for i in 1..48 loop
  j := i -1 + n*2;
  if (j>=48) then j := j -48;
  elsif (j<0) then j := j + 48;
  end if;
  l_tm_zn(5+j*2) := (i-1)/2;
  /*
  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('Index:'||to_char(5+j*2)|| ',TM:'||to_char((i-1)/2),
                     'BIV_AGNT_SR_ARRIVAL');
  end if;
  */
end loop;
update biv_tmp_sr_arrvl d
 set col1=l_new_param_str||d.ID||biv_core_pkg.g_param_sep ,
     col3=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep,
     col5=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(5))||biv_core_pkg.g_param_sep,
     col7=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(7))||biv_core_pkg.g_param_sep,
     col9=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(9))||biv_core_pkg.g_param_sep,
     col11=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(11))||biv_core_pkg.g_param_sep,
     col13=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(13))||biv_core_pkg.g_param_sep,
     col15=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(15))||biv_core_pkg.g_param_sep,
     col17=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(17))||biv_core_pkg.g_param_sep,
     col19=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(19))||biv_core_pkg.g_param_sep,
     col21=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(21))||biv_core_pkg.g_param_sep,
     col23=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(23))||biv_core_pkg.g_param_sep,
     col25=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(25))||biv_core_pkg.g_param_sep,
     col27=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(27))||biv_core_pkg.g_param_sep,
     col29=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(29))||biv_core_pkg.g_param_sep,
     col31=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(31))||biv_core_pkg.g_param_sep,
     col33=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(33))||biv_core_pkg.g_param_sep,
     col35=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(35))||biv_core_pkg.g_param_sep,
     col37=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(37))||biv_core_pkg.g_param_sep,
     col39=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(39))||biv_core_pkg.g_param_sep,
     col41=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(41))||biv_core_pkg.g_param_sep,
     col43=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(43))||biv_core_pkg.g_param_sep,
     col45=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(45))||biv_core_pkg.g_param_sep,
     col47=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(47))||biv_core_pkg.g_param_sep,
     col49=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(49))||biv_core_pkg.g_param_sep,
     col51=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(51))||biv_core_pkg.g_param_sep,
     col53=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(53))||biv_core_pkg.g_param_sep,
     col55=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(55))||biv_core_pkg.g_param_sep,
     col57=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(57))||biv_core_pkg.g_param_sep,
     col59=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(59))||biv_core_pkg.g_param_sep,
     col61=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(61))||biv_core_pkg.g_param_sep,
     col63=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(63))||biv_core_pkg.g_param_sep,
     col65=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(65))||biv_core_pkg.g_param_sep,
     col67=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(67))||biv_core_pkg.g_param_sep,
     col69=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(69))||biv_core_pkg.g_param_sep,
     col71=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(71))||biv_core_pkg.g_param_sep,
     col73=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(73))||biv_core_pkg.g_param_sep,
     col75=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(75))||biv_core_pkg.g_param_sep,
     col77=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(77))||biv_core_pkg.g_param_sep,
     col79=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(79))||biv_core_pkg.g_param_sep,
     col81=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(81))||biv_core_pkg.g_param_sep,
     col83=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(83))||biv_core_pkg.g_param_sep,
     col85=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(85))||biv_core_pkg.g_param_sep,
     col87=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(87))||biv_core_pkg.g_param_sep,
     col89=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(89))||biv_core_pkg.g_param_sep,
     col91=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(91))||biv_core_pkg.g_param_sep,
     col93=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(93))||biv_core_pkg.g_param_sep,
     col95=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(95))||biv_core_pkg.g_param_sep,
     col97=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(97))||biv_core_pkg.g_param_sep,
     col99=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(99))||biv_core_pkg.g_param_sep,
     rowno =1,
     creation_date = sysdate,
     last_update_date = sysdate
    ;

--- Adding totoal row
select count(*) into l_ttl_rec
  from biv_tmp_sr_arrvl
 where session_id = x_session
   ;
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('total rec:' || to_char(l_ttl_rec) ||
                          ' display:'||biv_core_pkg.g_disp,
                          'BIV_AGNT_SR_ARRIVAL');
end if;
if (l_ttl_rec > 1 and l_ttl_rec < biv_core_pkg.g_disp) then
  l_ttl_desc := biv_core_pkg.get_lookup_meaning('TOTAL');
  insert into biv_tmp_sr_arrvl (rowno, report_code, col2, col4, col6, col8,
               col10,col12,col14,col16,col18,col20,
               col22,col24,col26,col28,col30,col32,
               col34,col36,col38,col40,col42,col44,
               col46,col48,col50,col52,col54,col56,
               col58,col60,col62,col64,col66,col68,
               col70,col72,col74,col76,col78,col80,
               col82,col84,col86,col88,col90,col92,
               col94,col96,col98,col100,session_id)
   select 2,'BIV_AGNT_SR_ARRIVAL', l_ttl_desc,sum(col4 ),sum(col6 ),sum(col8),
             sum(col10),sum(col12),sum(col14),sum(col16),sum(col18),sum(col20),
             sum(col22),sum(col24),sum(col26),sum(col28),sum(col30),sum(col32),
             sum(col34),sum(col36),sum(col38),sum(col40),sum(col42),sum(col44),
             sum(col46),sum(col48),sum(col50),sum(col52),sum(col54),sum(col56),
             sum(col58),sum(col60),sum(col62),sum(col64),sum(col66),sum(col68),
             sum(col70),sum(col72),sum(col74),sum(col76),sum(col78),sum(col80),
             sum(col82),sum(col84),sum(col86),sum(col88),sum(col90),sum(col92),
             sum(col94),sum(col96),sum(col98),sum(col100),x_session
     from biv_tmp_sr_arrvl
    where rowno = 1
      and session_id = x_session;

l_new_param_str := 'BIV_HS_SR_ARRIVAL_PRD' ||biv_core_pkg.g_param_sep ||
                   biv_core_pkg.reconstruct_param_str ||
                   'P_AGRP_LVL' ||
                   biv_core_pkg.g_value_sep || nvl(biv_core_pkg.g_lvl,1) ||
                   biv_core_pkg.g_param_sep;
if (biv_core_pkg.g_tm_zn is not null) then
  l_new_param_str := l_new_param_str ||
                  'P_TM_ZN' || biv_core_pkg.g_value_sep ||
                  biv_core_pkg.g_tm_zn || biv_core_pkg.g_param_sep;
end if;
l_new_param_str1 := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                    biv_core_pkg.reconstruct_param_str ||
                    'P_AGRP_LVL' ||
                    biv_core_pkg.g_value_sep || nvl(biv_core_pkg.g_lvl,1) ||
                    biv_core_pkg.g_param_sep;
-- Change for Bug 2948411
l_new_param_str1 := l_new_param_str1 || 'P_PREVR' || biv_core_pkg.g_value_sep ||
'BIV_HS_SR_ARRIVAL_TM' || biv_core_pkg.g_param_sep;

update biv_tmp_sr_arrvl d
 set col1=l_new_param_str ,
     col3=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep,
     col5=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(5))||biv_core_pkg.g_param_sep,
     col7=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(7))||biv_core_pkg.g_param_sep,
     col9=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(9))||biv_core_pkg.g_param_sep,
     col11=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(11))||biv_core_pkg.g_param_sep,
     col13=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(13))||biv_core_pkg.g_param_sep,
     col15=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(15))||biv_core_pkg.g_param_sep,
     col17=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(17))||biv_core_pkg.g_param_sep,
     col19=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(19))||biv_core_pkg.g_param_sep,
     col21=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(21))||biv_core_pkg.g_param_sep,
     col23=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(23))||biv_core_pkg.g_param_sep,
     col25=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(25))||biv_core_pkg.g_param_sep,
     col27=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(27))||biv_core_pkg.g_param_sep,
     col29=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(29))||biv_core_pkg.g_param_sep,
     col31=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(31))||biv_core_pkg.g_param_sep,
     col33=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(33))||biv_core_pkg.g_param_sep,
     col35=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(35))||biv_core_pkg.g_param_sep,
     col37=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(37))||biv_core_pkg.g_param_sep,
     col39=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(39))||biv_core_pkg.g_param_sep,
     col41=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(41))||biv_core_pkg.g_param_sep,
     col43=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(43))||biv_core_pkg.g_param_sep,
     col45=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(45))||biv_core_pkg.g_param_sep,
     col47=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(47))||biv_core_pkg.g_param_sep,
     col49=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(49))||biv_core_pkg.g_param_sep,
     col51=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(51))||biv_core_pkg.g_param_sep,
     col53=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(53))||biv_core_pkg.g_param_sep,
     col55=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(55))||biv_core_pkg.g_param_sep,
     col57=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(57))||biv_core_pkg.g_param_sep,
     col59=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(59))||biv_core_pkg.g_param_sep,
     col61=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(61))||biv_core_pkg.g_param_sep,
     col63=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(63))||biv_core_pkg.g_param_sep,
     col65=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(65))||biv_core_pkg.g_param_sep,
     col67=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(67))||biv_core_pkg.g_param_sep,
     col69=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(69))||biv_core_pkg.g_param_sep,
     col71=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(71))||biv_core_pkg.g_param_sep,
     col73=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(73))||biv_core_pkg.g_param_sep,
     col75=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(75))||biv_core_pkg.g_param_sep,
     col77=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(77))||biv_core_pkg.g_param_sep,
     col79=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(79))||biv_core_pkg.g_param_sep,
     col81=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(81))||biv_core_pkg.g_param_sep,
     col83=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(83))||biv_core_pkg.g_param_sep,
     col85=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(85))||biv_core_pkg.g_param_sep,
     col87=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(87))||biv_core_pkg.g_param_sep,
     col89=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(89))||biv_core_pkg.g_param_sep,
     col91=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(91))||biv_core_pkg.g_param_sep,
     col93=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(93))||biv_core_pkg.g_param_sep,
     col95=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(95))||biv_core_pkg.g_param_sep,
     col97=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(97))||biv_core_pkg.g_param_sep,
     col99=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(99))||biv_core_pkg.g_param_sep,
     creation_date = sysdate,
     last_update_date = sysdate
 where rowno = 2
;
end if;
--- end of total Row addition
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('End of Report','BIV_AGNT_SR_ARRIVAL');
end if;
exception
  when others then
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Error at:'||l_reached_upto ||
                             ',Error:'||substr(sqlerrm,1,200),
                             'BIV_AGNT_SR_ARRIVAL');
   end if;
END;

Procedure    Prd_sr_arrival_time(p_param_str in varchar2)
IS
-- cursor variable
cursor update_tmp_tbl is SELECT ID,SESSION_ID
FROM biv_tmp_sr_ARRVL where session_id = biv_core_pkg.get_session_id
  --ID is not null
;
-- DBMS_SQL variable
cur2 pls_integer:=dbms_sql.open_cursor;
fdbk pls_integer;
insert_stmt    varchar2(4000);
l_owner_id     number;
x_from_list    varchar2(2000);
x_where_clause varchar2(2000);
l_org_id       number;
-- array processing variable
n              integer;
i              number;
j              number;
type array_type is table of number
index by binary_integer;
a_start array_type;
a_end   array_type;
l_tm_zn array_type;
-- time zone variables
l_start_tz      number;
l_end_tz        number;
l_tz_diff       number;
l_return_status  varchar2(10);
l_msg_count      number;
l_msg_data        varchar2(30);
l_num_rows       integer;
x_session        NUMBER;
l_new_param_str1 varchar2(200);
l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
l_ttl_rec number;
l_ttl_desc fnd_lookups.meaning % type;

begin
x_session:=biv_core_pkg.get_session_id;
biv_core_pkg.clean_dcf_table('BIV_TMP_SR_ARRVL');

biv_core_pkg.g_report_type := 'HS';
biv_core_pkg.get_report_parameters(p_param_str);
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Start Date  :'||
                       to_char(biv_core_pkg.g_cr_st,'dd-mon-yyyy hh24:mi:ss'),
                       'BIV_AGNT_SR_ARRIVAL');
   biv_core_pkg.biv_debug('End Date  :'||
                       to_char(biv_core_pkg.g_cr_end,'dd-mon-yyyy hh24:mi:ss'),
                       'BIV_AGNT_SR_ARRIVAL');
end if;
--12/30 grp_owner already coming from reconstruct fn l_owner_id:=to_number(biv_core_pkg.g_agrp(1));
--biv_core_pkg.g_ogrp_cnt :=0;
--biv_core_pkg.g_agrp_cnt :=0;

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Param Str:'||p_param_str,'BIV_PRD_SR_ARRIVAL');
end if;
-- Change for Bug 3386946
x_from_list:=' from  biv_sr_summary srs,cs_incidents_b_sec sr  ';
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_where_clause:=x_where_clause||' and  sr.incident_id=srs.incident_id ';
 /*and  sr.owner_group_id=:l_owner_id */

insert_stmt:='insert into biv_tmp_SR_ARRVL (report_code,SESSION_ID,ID,col4,col6,col8,col10,col12,col14,col16,col18,col20,col22,col24,col26,col28,col30,col32,col34,col36,col38,col40,col42,col44,col46,col48,
              col50,col52,col54,col56,col58,col60,col62,col64,col66,col68,col70,col72,col74,col76,col78,col80,col82,col84,col86,col88,col90,col92,col94,col96,col98,col100)
              (select ''BIV_PRD_SR_ARRIVAL'',:X_SESSION,sr.inventory_item_id, count(*),count(decode(arrival_time,0,arrival_time)),
              count(decode(arrival_time,0.5,arrival_time)),count(decode(arrival_time,1,arrival_time)),count(decode(arrival_time,1.5,arrival_time)),count(decode(arrival_time,2,arrival_time)),
              count(decode(arrival_time,2.5,arrival_time)),count(decode(arrival_time,3,arrival_time)),count(decode(arrival_time,3.5,arrival_time)),count(decode(arrival_time,4,arrival_time)),
              count(decode(arrival_time,4.5,arrival_time)),count(decode(arrival_time,5,arrival_time)),count(decode(arrival_time,5.5,arrival_time)) ,count(decode(arrival_time,6,arrival_time)),
              count(decode(arrival_time,6.5,arrival_time)),count(decode(arrival_time,7,arrival_time)),count(decode(arrival_time,7.5,arrival_time)),count(decode(arrival_time,8,arrival_time)),
              count(decode(arrival_time,8.5,arrival_time)),count(decode(arrival_time,9,arrival_time)),count(decode(arrival_time,9.5,arrival_time)),count(decode(arrival_time,10,arrival_time)) ,
              count(decode(arrival_time,10.5,arrival_time)),count(decode(arrival_time,11,arrival_time)),count(decode(arrival_time,11.5,arrival_time)),count(decode(arrival_time,12,arrival_time)),
              count(decode(arrival_time,12.5,arrival_time)),count(decode(arrival_time,13,arrival_time)),count(decode(arrival_time,13.5,arrival_time)),count(decode(arrival_time,14,arrival_time)),
              count(decode(arrival_time,14.5,arrival_time)),count(decode(arrival_time,15,arrival_time)),count(decode(arrival_time,15.5,arrival_time)),count(decode(arrival_time,16,arrival_time)),
              count(decode(arrival_time,16.5,arrival_time)),count(decode(arrival_time,17,arrival_time)),count(decode(arrival_time,17.5,arrival_time)),count(decode(arrival_time,18,arrival_time)),
              count(decode(arrival_time,18.5,arrival_time)),count(decode(arrival_time,19,arrival_time)),count(decode(arrival_time,19.5,arrival_time)) ,count(decode(arrival_time,20,arrival_time)),
              count(decode(arrival_time,20.5,arrival_time)),count(decode(arrival_time,21,arrival_time)),count(decode(arrival_time,21.5,arrival_time)),count(decode(arrival_time,22,arrival_time)),
              count(decode(arrival_time,22.5,arrival_time)),count(decode(arrival_time,23,arrival_time)),count(decode(arrival_time,23.5,arrival_time))
             '||x_from_list||x_where_clause||' group by sr.inventory_item_id )';

  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug(insert_stmt,'BIV_PRD_SR_ARRIVAL');
  end if;


dbms_sql.parse(cur2,insert_stmt,dbms_sql.native);


biv_core_pkg.bind_all_variables(cur2);

--12/30/02 dbms_sql.bind_variable(cur2,':l_owner_id',l_owner_id);
dbms_sql.bind_variable(cur2,':X_SESSION',X_SESSION);
fdbk:=dbms_sql.execute(cur2);

dbms_sql.close_cursor(cur2);

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Update table:','BIV_PRD_SR_ARRIVAL');
end if;
for rec in update_tmp_tbl
loop
select col6,col8,col10,col12,col14,col16,col18,col20,
       col22,col24,col26,col28,col30,col32,col34,col36,
       col38,col40,col42,col44,col46,col48,col50,col52,
       col54,col56,col58,col60,col62,col64,col66,col68,
       col70,col72,col74,col76,col78,col80,col82,col84,
       col86,col88,col90,col92,col94,col96,col98,col100
 into  a_start(1),a_start(2),a_start(3),a_start(4),a_start(5),a_start(6),a_start(7),a_start(8),
       a_start(9),a_start(10), a_start(11),a_start(12),a_start(13),a_start(14),a_start(15),a_start(16),
       a_start(17),a_start(18),a_start(19),a_start(20),a_start(21),a_start(22),a_start(23),a_start(24),
       a_start(25),a_start(26),a_start(27),a_start(28),a_start(29),a_start(30),a_start(31),a_start(32),
       a_start(33),a_start(34),a_start(35),a_start(36),a_start(37),a_start(38),a_start(39),a_start(40),
       a_start(41),a_start(42),a_start(43),a_start(44),a_start(45),a_start(46),a_start(47),a_start(48)
 from biv_tmp_SR_ARRVL  where nvl(ID,0)=nvl(rec.ID,0) and session_id=rec.session_id;


-- array processing logic

l_start_tz:=nvl(fnd_profile.value('SERVER_TIMEZONE_ID'),0);
if biv_core_pkg.g_tm_zn is not null then
l_end_tz:=to_number(nvl(biv_core_pkg.g_tm_zn,0));
else
l_end_tz:=nvl(fnd_profile.value('SERVER_TIMEZONE_ID'),0);
end if;
CS_TZ_GET_DETAILS_PVT.GET_LEADTIME(1.0,'T',l_start_tz,l_end_tz,l_tz_diff,l_return_status,l_msg_count,l_msg_data);
n:=nvl(l_tz_diff,0);
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Time zone diff:' || to_char(n),'BIV_PRD_SR_ARRIVAL');
end if;

if n > 0 then
for i in 1..48 loop
    j:=i+2*n;
  if j > 48 then j:=j-48; end if;
    a_end(j):=a_start(i);
end loop;
end if;

if n < 0 then
for i in REVERSE 1..48 loop
    j:=i+2*n;
  if j <= 0 then j:=j+48; end if;
    a_end(j):=a_start(i);
end loop;
end if;
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Update for Time Zone', 'BIV_PRD_SR_ARRIVAL');
end if;
if n <> 0 then
update biv_tmp_sr_arrvl
set col6=a_end(1),col8=a_end(2),col10=a_end(3),col12=a_end(4),col14=a_end(5),col16=a_end(6),col18=a_end(7),
         col20=a_end(8),col22=a_end(9),col24=a_end(10),col26=a_end(11),col28=a_end(12),col30=a_end(13),
         col32=a_end(14),col34=a_end(15),col36=a_end(16),col38=a_end(17),col40=a_end(18),col42=a_end(19),
         col44=a_end(20),col46=a_end(21),col48=a_end(22),col50=a_end(23),col52=a_end(24),col54=a_end(25),
         col56=a_end(26),col58=a_end(27),col60=a_end(28),col62=a_end(29),col64=a_end(30),col66=a_end(31),
         col68=a_end(32),col70=a_end(33),col72=a_end(34),col74=a_end(35),col76=a_end(36),col78=a_end(37),
         col80=a_end(38),col82=a_end(39),col84=a_end(40),col86=a_end(41),col88=a_end(42),col90=a_end(43),
         col92=a_end(44),col94=a_end(45),col96=a_end(46),col98=a_end(47),col100=a_end(48)
         where nvl(ID,0)=nvl(rec.ID,0)
         and session_id=rec.session_id      ;
end if;

end loop;

l_org_id:=to_number(biv_core_pkg.g_prd_org);

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Update of product desc', 'BIV_PRD_SR_ARRIVAL');
end if;
/*** 12/30/02 replace with biv_core_pkg.update_description
update biv_tmp_sr_arrvl  d
 set col2 = (select substr(description,1,50) from mtl_system_items_vl
                      where inventory_item_id = nvl(d.ID,0)
                        and organization_id = l_org_id);
***/
biv_core_pkg.update_description('P_PRD_ID','id','col2','biv_tmp_sr_arrvl');
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('product desc Updated', 'BIV_PRD_SR_ARRIVAL');
end if;

biv_core_pkg.reset_view_by_param;


l_new_param_str1 := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
l_new_param_str1 := l_new_param_str1 ||
        --'P_AGRP'||biv_core_pkg.g_value_sep||TO_CHAR(L_OWNER_ID)|| biv_core_pkg.g_param_sep||
             'P_PRD_ID' || biv_core_pkg.g_value_sep ;
--'jtfBinId' ||biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('TIME ZONE DIFF:' || to_char(n),'BIV_PRD_SR_ARRIVAL');
   biv_core_pkg.biv_debug('setting time array for links', 'BIV_PRD_SR_ARRIVAL');
end if;
for i in 1..48 loop
  j := i -1 + n*2;
  if (j>=48) then j := j -48;
  elsif (j<0) then j := j + 48;
  end if;
  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('Index:'||to_char(5+j*2)|| ',TM:'||to_char((i-1)/2),
                     'BIV_PRD_SR_ARRIVAL');
  end if;
  l_tm_zn(5+j*2) := (i-1)/2;
end loop;
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Update of hyper links', 'BIV_PRD_SR_ARRIVAL');
end if;
update biv_tmp_sr_arrvl d
 set col3=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep,
     col5=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(5))||biv_core_pkg.g_param_sep,
     col7=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(7))||biv_core_pkg.g_param_sep,
     col9=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(9))||biv_core_pkg.g_param_sep,
     col11=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(11))||biv_core_pkg.g_param_sep,
     col13=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(13))||biv_core_pkg.g_param_sep,
     col15=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(15))||biv_core_pkg.g_param_sep,
     col17=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(17))||biv_core_pkg.g_param_sep,
     col19=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(19))||biv_core_pkg.g_param_sep,
     col21=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(21))||biv_core_pkg.g_param_sep,
     col23=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(23))||biv_core_pkg.g_param_sep,
     col25=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(25))||biv_core_pkg.g_param_sep,
     col27=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(27))||biv_core_pkg.g_param_sep,
     col29=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(29))||biv_core_pkg.g_param_sep,
     col31=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(31))||biv_core_pkg.g_param_sep,
     col33=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(33))||biv_core_pkg.g_param_sep,
     col35=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(35))||biv_core_pkg.g_param_sep,
     col37=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(37))||biv_core_pkg.g_param_sep,
     col39=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(39))||biv_core_pkg.g_param_sep,
     col41=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(41))||biv_core_pkg.g_param_sep,
     col43=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(43))||biv_core_pkg.g_param_sep,
     col45=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(45))||biv_core_pkg.g_param_sep,
     col47=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(47))||biv_core_pkg.g_param_sep,
     col49=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(49))||biv_core_pkg.g_param_sep,
     col51=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(51))||biv_core_pkg.g_param_sep,
     col53=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(53))||biv_core_pkg.g_param_sep,
     col55=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(55))||biv_core_pkg.g_param_sep,
     col57=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(57))||biv_core_pkg.g_param_sep,
     col59=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(59))||biv_core_pkg.g_param_sep,
     col61=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(61))||biv_core_pkg.g_param_sep,
     col63=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(63))||biv_core_pkg.g_param_sep,
     col65=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(65))||biv_core_pkg.g_param_sep,
     col67=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(67))||biv_core_pkg.g_param_sep,
     col69=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(69))||biv_core_pkg.g_param_sep,
     col71=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(71))||biv_core_pkg.g_param_sep,
     col73=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(73))||biv_core_pkg.g_param_sep,
     col75=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(75))||biv_core_pkg.g_param_sep,
     col77=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(77))||biv_core_pkg.g_param_sep,
     col79=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(79))||biv_core_pkg.g_param_sep,
     col81=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(81))||biv_core_pkg.g_param_sep,
     col83=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(83))||biv_core_pkg.g_param_sep,
     col85=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(85))||biv_core_pkg.g_param_sep,
     col87=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(87))||biv_core_pkg.g_param_sep,
     col89=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(89))||biv_core_pkg.g_param_sep,
     col91=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(91))||biv_core_pkg.g_param_sep,
     col93=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(93))||biv_core_pkg.g_param_sep,
     col95=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(95))||biv_core_pkg.g_param_sep,
     col97=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(97))||biv_core_pkg.g_param_sep,
     col99=l_new_param_str1||nvl(to_char(d.ID),biv_core_pkg.g_null)||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(99))||biv_core_pkg.g_param_sep,
     rowno =1,
     creation_date = sysdate,
     last_update_date = sysdate;

/****************** replace with the code above 7/25/02
update biv_tmp_sr_arrvl d
 set col3=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep,
     col5=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'0'||biv_core_pkg.g_param_sep,
     col7=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'0.5'||biv_core_pkg.g_param_sep,
     col9=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'1'||biv_core_pkg.g_param_sep,
     col11=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'1.5'||biv_core_pkg.g_param_sep,
     col13=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'2'||biv_core_pkg.g_param_sep,
     col15=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'2.5'||biv_core_pkg.g_param_sep,
     col17=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'3'||biv_core_pkg.g_param_sep,
     col19=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'3.5'||biv_core_pkg.g_param_sep,
     col21=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'4'||biv_core_pkg.g_param_sep,
     col23=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'4.5'||biv_core_pkg.g_param_sep,
     col25=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'5'||biv_core_pkg.g_param_sep,
     col27=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'5.5'||biv_core_pkg.g_param_sep,
     col29=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'6'||biv_core_pkg.g_param_sep,
     col31=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'6.5'||biv_core_pkg.g_param_sep,
     col33=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'7'||biv_core_pkg.g_param_sep,
     col35=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'7.5'||biv_core_pkg.g_param_sep,
     col37=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'8'||biv_core_pkg.g_param_sep,
     col39=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'8.5'||biv_core_pkg.g_param_sep,
     col41=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'9'||biv_core_pkg.g_param_sep,
     col43=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'9.5'||biv_core_pkg.g_param_sep,
     col45=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'10'||biv_core_pkg.g_param_sep,
     col47=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'10.5'||biv_core_pkg.g_param_sep,
     col49=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'11'||biv_core_pkg.g_param_sep,
     col51=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'11.5'||biv_core_pkg.g_param_sep,
     col53=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'12'||biv_core_pkg.g_param_sep,
     col55=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'12.5'||biv_core_pkg.g_param_sep,
     col57=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'13'||biv_core_pkg.g_param_sep,
     col59=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'13.5'||biv_core_pkg.g_param_sep,
     col61=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'14'||biv_core_pkg.g_param_sep,
     col63=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'14.5'||biv_core_pkg.g_param_sep,
     col65=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'15'||biv_core_pkg.g_param_sep,
     col67=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'15.5'||biv_core_pkg.g_param_sep,
     col69=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'16'||biv_core_pkg.g_param_sep,
     col71=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'16.5'||biv_core_pkg.g_param_sep,
     col73=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'17'||biv_core_pkg.g_param_sep,
     col75=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'17.5'||biv_core_pkg.g_param_sep,
     col77=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'18'||biv_core_pkg.g_param_sep,
     col79=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'18.5'||biv_core_pkg.g_param_sep,
     col81=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'19'||biv_core_pkg.g_param_sep,
     col83=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'19.5'||biv_core_pkg.g_param_sep,
     col85=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'20'||biv_core_pkg.g_param_sep,
     col87=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'20.5'||biv_core_pkg.g_param_sep,
     col89=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'21'||biv_core_pkg.g_param_sep,
     col91=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'21.5'||biv_core_pkg.g_param_sep,
     col93=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'22'||biv_core_pkg.g_param_sep,
     col95=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'22.5'||biv_core_pkg.g_param_sep,
     col97=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'23'||biv_core_pkg.g_param_sep,
     col99=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||'23.5'||biv_core_pkg.g_param_sep;

**********************/

-- added on 12/30/02 for total row
--- Adding totoal row
select count(*) into l_ttl_rec
  from biv_tmp_sr_arrvl
 where session_id = x_session
   ;
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('total rec:' || to_char(l_ttl_rec) ||
                          ' display:'||biv_core_pkg.g_disp,
                          'BIV_AGNT_SR_ARRIVAL');
end if;
if (l_ttl_rec > 1 ) then
  l_ttl_desc := biv_core_pkg.get_lookup_meaning('TOTAL');
  insert into biv_tmp_sr_arrvl (rowno, report_code, col2, col4, col6, col8,
               col10,col12,col14,col16,col18,col20,
               col22,col24,col26,col28,col30,col32,
               col34,col36,col38,col40,col42,col44,
               col46,col48,col50,col52,col54,col56,
               col58,col60,col62,col64,col66,col68,
               col70,col72,col74,col76,col78,col80,
               col82,col84,col86,col88,col90,col92,
               col94,col96,col98,col100,session_id)
   select 2,'BIV_AGNT_SR_ARRIVAL', l_ttl_desc,sum(col4 ),sum(col6 ),sum(col8),
             sum(col10),sum(col12),sum(col14),sum(col16),sum(col18),sum(col20),
             sum(col22),sum(col24),sum(col26),sum(col28),sum(col30),sum(col32),
             sum(col34),sum(col36),sum(col38),sum(col40),sum(col42),sum(col44),
             sum(col46),sum(col48),sum(col50),sum(col52),sum(col54),sum(col56),
             sum(col58),sum(col60),sum(col62),sum(col64),sum(col66),sum(col68),
             sum(col70),sum(col72),sum(col74),sum(col76),sum(col78),sum(col80),
             sum(col82),sum(col84),sum(col86),sum(col88),sum(col90),sum(col92),
             sum(col94),sum(col96),sum(col98),sum(col100),x_session
     from biv_tmp_sr_arrvl
    where rowno = 1
      and session_id = x_session;

l_new_param_str1 := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                    biv_core_pkg.reconstruct_param_str ||
                    'P_AGRP_LVL' ||
                    biv_core_pkg.g_value_sep || nvl(biv_core_pkg.g_lvl,1) ||
                    biv_core_pkg.g_param_sep;

update biv_tmp_sr_arrvl d
 set
     col3=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep,
     col5=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(5))||biv_core_pkg.g_param_sep,
     col7=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(7))||biv_core_pkg.g_param_sep,
     col9=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(9))||biv_core_pkg.g_param_sep,
     col11=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(11))||biv_core_pkg.g_param_sep,
     col13=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(13))||biv_core_pkg.g_param_sep,
     col15=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(15))||biv_core_pkg.g_param_sep,
     col17=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(17))||biv_core_pkg.g_param_sep,
     col19=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(19))||biv_core_pkg.g_param_sep,
     col21=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(21))||biv_core_pkg.g_param_sep,
     col23=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(23))||biv_core_pkg.g_param_sep,
     col25=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(25))||biv_core_pkg.g_param_sep,
     col27=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(27))||biv_core_pkg.g_param_sep,
     col29=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(29))||biv_core_pkg.g_param_sep,
     col31=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(31))||biv_core_pkg.g_param_sep,
     col33=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(33))||biv_core_pkg.g_param_sep,
     col35=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(35))||biv_core_pkg.g_param_sep,
     col37=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(37))||biv_core_pkg.g_param_sep,
     col39=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(39))||biv_core_pkg.g_param_sep,
     col41=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(41))||biv_core_pkg.g_param_sep,
     col43=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(43))||biv_core_pkg.g_param_sep,
     col45=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(45))||biv_core_pkg.g_param_sep,
     col47=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(47))||biv_core_pkg.g_param_sep,
     col49=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(49))||biv_core_pkg.g_param_sep,
     col51=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(51))||biv_core_pkg.g_param_sep,
     col53=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(53))||biv_core_pkg.g_param_sep,
     col55=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(55))||biv_core_pkg.g_param_sep,
     col57=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(57))||biv_core_pkg.g_param_sep,
     col59=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(59))||biv_core_pkg.g_param_sep,
     col61=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(61))||biv_core_pkg.g_param_sep,
     col63=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(63))||biv_core_pkg.g_param_sep,
     col65=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(65))||biv_core_pkg.g_param_sep,
     col67=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(67))||biv_core_pkg.g_param_sep,
     col69=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(69))||biv_core_pkg.g_param_sep,
     col71=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(71))||biv_core_pkg.g_param_sep,
     col73=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(73))||biv_core_pkg.g_param_sep,
     col75=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(75))||biv_core_pkg.g_param_sep,
     col77=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(77))||biv_core_pkg.g_param_sep,
     col79=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(79))||biv_core_pkg.g_param_sep,
     col81=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(81))||biv_core_pkg.g_param_sep,
     col83=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(83))||biv_core_pkg.g_param_sep,
     col85=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(85))||biv_core_pkg.g_param_sep,
     col87=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(87))||biv_core_pkg.g_param_sep,
     col89=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(89))||biv_core_pkg.g_param_sep,
     col91=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(91))||biv_core_pkg.g_param_sep,
     col93=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(93))||biv_core_pkg.g_param_sep,
     col95=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(95))||biv_core_pkg.g_param_sep,
     col97=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(97))||biv_core_pkg.g_param_sep,
     col99=l_new_param_str1||d.ID||biv_core_pkg.g_param_sep||'P_ARVL_TM'||biv_core_pkg.g_value_sep||to_char(l_tm_zn(99))||biv_core_pkg.g_param_sep,
     creation_date = sysdate,
     last_update_date = sysdate
 where rowno = 2
;
end if;
--- end of total Row addition
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('End of Report','BIV_AGNT_SR_ARRIVAL');
end if;
exception
  when others then
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Error:'||substr(sqlerrm,1,200),
                           'BIV_AGNT_SR_ARRIVAL');
   end if;
END;
  -- Enter further code below as specified in the Package spec.
END;

/
