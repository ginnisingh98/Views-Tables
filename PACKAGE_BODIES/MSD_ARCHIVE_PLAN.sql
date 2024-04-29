--------------------------------------------------------
--  DDL for Package Body MSD_ARCHIVE_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_ARCHIVE_PLAN" AS
/* $Header: msdarchb.pls 120.1 2005/11/01 11:43:09 ziahmed noship $ */

PROCEDURE archive_plan(errbuf out NOCOPY varchar2,retcode out NOCOPY varchar2,
                       p_demand_plan_id in number) is
  v_cmd varchar2(4000);
begin
  retcode := '0';

  v_cmd := 'aw attach ODPCODE ro; call pl.archive('''|| p_demand_plan_id||''')';
  msd_common_utilities.DBMS_AW_INTERP_SILENT(v_cmd);

  exception
    when others then
      errbuf := substr(SQLERRM,1,150);
      fnd_file.put_line(fnd_file.log, 'Error in archive process: see batch log for details');
      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
      retcode := '-1';

end archive_plan;


PROCEDURE restore_plan(errbuf out NOCOPY varchar2,retcode out NOCOPY varchar2,
                       p_demand_plan_id in number) is
  v_cmd varchar2(4000);
begin
  retcode := '0';

  v_cmd := 'aw attach ODPCODE ro; call pl.restore('''||p_demand_plan_id||''')';
  msd_common_utilities.DBMS_AW_INTERP_SILENT(v_cmd);

  exception
    when others then
      errbuf := substr(SQLERRM,1,150);
      fnd_file.put_line(fnd_file.log, 'Error in restore process: see batch log for details');
      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
      retcode := '-1';

end restore_plan;

end MSD_ARCHIVE_PLAN;

/
