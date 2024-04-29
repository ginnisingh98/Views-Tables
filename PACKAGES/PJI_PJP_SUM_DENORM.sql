--------------------------------------------------------
--  DDL for Package PJI_PJP_SUM_DENORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PJP_SUM_DENORM" AUTHID CURRENT_USER as
  /* $Header: PJISP03S.pls 120.0 2005/05/29 12:33:28 appldev noship $ */

-- -----------------------------------------------------------------------



-- -----------------------------------------------------------------------

procedure POPULATE_XBS_DENORM(
	p_worker_id		in	number,
	p_denorm_type    	in 	varchar2,
	p_wbs_version_id 	in 	number,
	p_prg_group1     	in 	number,
	p_prg_group2     	in 	number
);

procedure COPY_XBS_DENORM(
	p_worker_id		in	number,
	p_wbs_version_id_from 	in 	number,
    p_wbs_version_id_to 	in 	number,
    p_copy_mode             in varchar2 default null
);
-- -----------------------------------------------------------------------

procedure POPULATE_RBS_DENORM(
	p_worker_id 		in 	number,
	p_denorm_type    	in 	varchar2,
	p_rbs_version_id 	in 	number
);


-- -----------------------------------------------------------------------

procedure POPULATE_RBS_DENORM_UPGRADE(
	p_rbs_version_id	in  	   	number,
	x_return_status  	out nocopy 	varchar2,
	x_msg_count   	 	out nocopy 	number,
	x_msg_data       	out nocopy 	varchar2
);

-- -----------------------------------------------------------------------

procedure prg_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
);

-- -----------------------------------------------------------------------

procedure wbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2,
	p_wbs_version_id	in 	number
);

-- -----------------------------------------------------------------------

procedure prg_denorm_online(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2,
	p_prg_group_id		in 	number,
	p_wbs_version_id 	in 	number
);

-- -----------------------------------------------------------------------

procedure wbs_denorm_online(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2,
	p_wbs_version_id 	in 	number
);

-- -----------------------------------------------------------------------

procedure rbs_denorm(
	p_worker_id 	  	in 	number,
	p_extraction_type 	in 	varchar2,
	p_rbs_version_id  	in 	number
);

-- -----------------------------------------------------------------------

procedure rbs_denorm_online(
	p_worker_id 	  	in 	number,
	p_extraction_type 	in 	varchar2,
	p_rbs_version_id  	in 	number
);

-- -----------------------------------------------------------------------

procedure merge_xbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
);

-- -----------------------------------------------------------------------

procedure merge_rbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
);

-- -----------------------------------------------------------------------

procedure cleanup_xbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
);

-- -----------------------------------------------------------------------

procedure cleanup_rbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
);

-- -----------------------------------------------------------------------

end PJI_PJP_SUM_DENORM;

 

/
