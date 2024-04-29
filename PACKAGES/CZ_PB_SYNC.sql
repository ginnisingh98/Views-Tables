--------------------------------------------------------
--  DDL for Package CZ_PB_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PB_SYNC" AUTHID CURRENT_USER AS
/*	$Header: czpbsyns.pls 115.3 2002/12/18 19:44:05 rheramba ship $	*/

TYPE ref_cursor IS REF CURSOR;
PROCEDURE sync_cloned_tgt_pub_data(p_target_instance IN VARCHAR2,
					    x_run_id OUT NOCOPY NUMBER,
					    x_status OUT NOCOPY VARCHAR2);

PROCEDURE sync_cloned_src_pub_data(p_decomm_flag IN VARCHAR2,
					     x_run_id OUT NOCOPY NUMBER,
					     x_status OUT NOCOPY VARCHAR2);


---------concurrent manager programs
PROCEDURE sync_cloned_tgt_pub_data_cp(Errbuf  IN OUT NOCOPY  VARCHAR2,
				  		  Retcode IN OUT NOCOPY  PLS_INTEGER,
						  p_target_instance IN VARCHAR2);

PROCEDURE sync_cloned_src_pub_data_cp(Errbuf  IN OUT NOCOPY  VARCHAR2,
				  		  Retcode IN OUT NOCOPY  PLS_INTEGER,
						  p_decomm_flag IN VARCHAR2);


END;


 

/
