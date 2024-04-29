--------------------------------------------------------
--  DDL for Package Body MSD_DEM_SSL_RS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_SSL_RS" as
/* $Header: msddemrunrsb.pls 120.0.12010000.5 2010/03/24 07:35:50 sjagathe ship $ */

procedure run_rs(errbuf             out nocopy varchar2,
                 retcode             out nocopy number,
								 instance number,
					  		 auto_run number,
								 file_seperator varchar,
								 control_path varchar2,
								 data_path varchar2,
								 file_name varchar2)

is

l_success boolean := false;
l_submit_failed exception;

l_req_id number;

begin

		l_success := fnd_submit.set_request_set('MSD','MSDDEMRSCSBHFFV3');

		if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMLD','SATGE10', instance, 1440, file_seperator, control_path, data_path, 3, null,
    																			null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
    																			null, null, null, null, null, null, null, null, null, null, file_name, auto_run);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMSDP','STAGE20', instance);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMCMB','STAGE30', instance, 1);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE35', 'EQ_BIIO_CTO_DATA', instance, 1);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE40', 'EQ_BIIO_CTO_BASE_MODEL', instance, 1);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE40', 'EQ_BIIO_CTO_LEVEL', instance, 1);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE40', 'EQ_SALES_TMPL_ITEM_OPTIONS', instance, 1);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE40', 'EQ_BIIO_CTO_DATA_EPP', instance, 1);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE40', 'EQ_BIIO_CTO_CHILD', instance, 1); --bug#9466697 nallkuma
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMCLT','STAGE50', instance, 2);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMCLT','STAGE50', instance, 1);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE50', 'EQ_SALES_TMPL_ITEM', instance, 2);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE50', 'EQ_BIIO_CTO_POPULATION', instance, 1);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE50', 'EQ_BIIO_CTO_POPULATION_SITE', instance, 1); --bug#9466697 nallkuma
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE50', 'EQ_BIIO_CTO_POPULATION_SC', instance, 1); --bug#9466697 nallkuma
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMPST','STAGE50', 'EQ_BIIO_CTO_POPULATION_DC', instance, 1); --bug#9466697 nallkuma
    if not l_success then
      raise l_submit_failed;
    end if;

    l_success := fnd_submit.submit_program('MSD','MSDDEMARD','STAGE60', auto_run);
    if not l_success then
      raise l_submit_failed;
    end if;

    l_req_id := fnd_submit.submit_set(NULL,FALSE);

    commit;

    retcode := 0;

		exception
				when l_submit_failed then
					 errbuf  := 'Launching Request Set failed';
           msd_dem_common_utilities.log_message(errbuf);
           msd_dem_common_utilities.log_debug(errbuf);
           retcode := -1;
        when others then
        	 errbuf  := substr(SQLERRM,1,150);
           msd_dem_common_utilities.log_message(errbuf);
           msd_dem_common_utilities.log_debug(errbuf);
           retcode := -1;

end;

end msd_dem_ssl_rs;


/
