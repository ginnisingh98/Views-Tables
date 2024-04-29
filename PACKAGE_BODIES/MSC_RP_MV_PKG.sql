--------------------------------------------------------
--  DDL for Package Body MSC_RP_MV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_RP_MV_PKG" AS
/* $Header: MSCRPMVB.pls 120.0.12010000.1 2010/03/17 22:32:57 hulu noship $ */




procedure log(p_message varchar2)  is
t timestamp;
begin
        select systimestamp into t from dual;
        fnd_file.put_line(fnd_file.log, to_char(t, 'YYYY-MM-DD HH24:MI:SS')||':
'||p_message);
end;




procedure refresh_one_mv(p_name varchar2) is
begin
     dbms_mview.refresh(p_name);
end refresh_one_mv;

procedure refresh_rp_mvs(errbuf out nocopy varchar2, retcode out nocopy
varchar2) is
l_rp_table_list object_names := object_names(
       'MSC_RP_CATEGORY_MV'
);
l_name varchar2(50);

p_return_status number;
p_error_message varchar2(2000);
begin
     for i in 1..l_rp_table_list.count loop
       l_name := l_rp_table_list(i);
       log('Refreshing MV : '||l_name||' starts');
       refresh_one_mv(l_name);
       log('Refreshing MV : '||l_name||' ends');
    end loop;


    exception
       when others then
         retcode := 1;
         errbuf := 'Error while Refreshing MV :'||l_name||': '||sqlerrm;
     log(errbuf);
end refresh_rp_mvs;



 procedure refresh_rp_mvs  is
        errbuf varchar2(1000) := '';
        retcode number := 0;
 begin
        refresh_rp_mvs(errbuf, retcode);
 end refresh_rp_mvs;



END msc_rp_mv_pkg;

/
