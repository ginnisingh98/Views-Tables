--------------------------------------------------------
--  DDL for Package GMS_SWEEPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_SWEEPER" AUTHID CURRENT_USER AS
-- $Header: gmsfcuas.pls 115.7 2002/11/28 02:27:18 jmuthuku ship $
  PROCEDURE upd_act_enc_bal  (errbuf       OUT NOCOPY VARCHAR2
	                      ,retcode 	   OUT NOCOPY NUMBER  -- Changed datatype to NUMBER for Bug:2464800
                              ,x_packet_id  in number default NULL
		              ,x_mode       in varchar2 DEFAULT 'U'
			      ,x_project_id in number DEFAULT NULL
			      ,x_award_id   in number DEFAULT NULL);
END;

 

/
