--------------------------------------------------------
--  DDL for Package IEM_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MIGRATION_PVT" AUTHID CURRENT_USER as
/* $Header: iemvmgrs.pls 120.2 2005/09/16 00:21:37 rtripath noship $*/
Procedure build_migration_queue(x_status out nocopy  varchar2) ;
procedure create_worklist(p_migration_id in number,x_status out nocopy varchar2) ;
procedure start_postprocessing(p_migration_id in number,x_status out nocopy varchar2) ;
PROCEDURE retry_folders(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_folders	IN jtf_number_table,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);
PROCEDURE retry_messages(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_messages	IN jtf_number_table,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);
PROCEDURE Start_worker(ERRBUF   OUT NOCOPY     		VARCHAR2,
            			RETCODE  OUT NOCOPY     		VARCHAR2);
PROCEDURE StartMigration(ERRBUF   OUT NOCOPY     		VARCHAR2,
                       			RETCODE  OUT NOCOPY     		VARCHAR2,
                       			p_hist_date in 	varchar2,
                      			 p_number_of_threads in 		NUMBER);
PROCEDURE StopMigration(ERRBUF   OUT NOCOPY     		VARCHAR2,
                       	RETCODE  OUT NOCOPY     		VARCHAR2);
PROCEDURE iem_logger(l_logmessage in varchar2);
PROCEDURE iem_config(x_Status OUT NOCOPY varchar2);
end IEM_MIGRATION_PVT;

 

/
