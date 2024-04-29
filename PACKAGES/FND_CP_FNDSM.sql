--------------------------------------------------------
--  DDL for Package FND_CP_FNDSM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_FNDSM" AUTHID DEFINER as
/* $Header: AFCPFSMS.pls 120.1 2005/07/02 04:01:14 appldev ship $ */

procedure mark_shutdown_fndsm( node IN varchar2 );
procedure mark_killed_fndsm( node IN varchar2 );
procedure shutdown_all_fndsm;
/* 2849672- Add IN parameter twotask, so that the process row for each
   FNDSM will have db_instance populated.  */
procedure register_fndsm_fcp( cpid  IN number,
	                  node  IN varchar2,
			  ospid IN number,
			  logfile IN varchar2,
		          mgrusrid IN number,
                          twotask IN varchar2);
procedure register_fndsm_fcq( node IN varchar2 );
procedure register_fndim_fcq( node IN varchar2 );
procedure register_oamgcs_fcq( node IN varchar2,
				Oracle_home IN varchar2 DEFAULT null,
				interval IN number DEFAULT 300000);
procedure register_fndsm_db(ospid IN number,
			    cpid  IN number,
	                 instance IN varchar2 );
procedure insert_service_fcp( cmpid IN number,
			      qapid IN number,
				qid IN number,
			   mgrusrid IN number,
			    mgrtype IN varchar2,
			       node IN varchar2);
end;

 

/
