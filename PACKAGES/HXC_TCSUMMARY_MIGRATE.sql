--------------------------------------------------------
--  DDL for Package HXC_TCSUMMARY_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TCSUMMARY_MIGRATE" AUTHID CURRENT_USER as
/* $Header: hxcsummig.pkh 120.1 2005/06/28 23:44:37 dragarwa noship $ */


procedure run_migration;

procedure run_tc_migration (
                   errbuf  out NOCOPY varchar2,
		   retcode out NOCOPY number,
		   p_business_group_id in number default null,
		   p_start_date in varchar2 default null,
		   p_end_date in varchar2 default null,
		   p_stop_time in varchar2 default null,
                   p_batch_size in number default 500,
                   p_num_workers in number
 		   ,p_migration_type in varchar2);

procedure run_tc_migration_worker( errbuf  out NOCOPY varchar2,
		                   retcode out NOCOPY number,
			           p_parent_req_id in number,
				   p_stop_time in varchar2 default null
		 		  ,p_migration_type in varchar2);

PROCEDURE populate_details(p_business_group_id in number default null
                            ,p_start_date        in date
                            ,p_end_date          in date
                            ,p_process_end_time  in date default null
                            ,p_detail_count      out NOCOPY number);

end hxc_tcsummary_migrate;

 

/
