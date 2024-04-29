--------------------------------------------------------
--  DDL for Package Body JAI_PA_SETUP_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PA_SETUP_DEF_PKG" as
/* $Header: jai_pa_setup_def_pkg.plb 120.0.12010000.2 2009/04/24 07:39:00 mbremkum noship $ */

procedure default_pa_setup_org (errbuf               out nocopy varchar2,
                                retcode              out nocopy varchar2,
                                p_org_id             in  number)
is
cursor c_get_pa_count
is
select count(setup_value_id)
from jai_pa_setup_values
where org_id is not null;
l_count number;
begin
fnd_file.put_line(fnd_file.log, 'Updating org_id for existing setup');
open c_get_pa_count;
fetch c_get_pa_count into l_count;
close c_get_pa_count;
if l_count > 0 then
   fnd_file.put_line(fnd_file.log, 'Records exist in jai_pa_setup_values with org_id');
   fnd_file.put_line(fnd_file.log, 'Cannot update. Exiting...');
   return;
else
   update jai_pa_setup_values
   set org_id = p_org_id
   where org_id is null;
   fnd_file.put_line(fnd_file.log, 'Updated existing records with org_id...');
end if;
retcode := 1 ;
errbuf := 'Normal Completion';
exception
  when others then
     rollback;
     retcode := 2 ;
     errbuf := 'Exception - ' || sqlerrm;
end;

end;

/
