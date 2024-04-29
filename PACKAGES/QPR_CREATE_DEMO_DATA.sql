--------------------------------------------------------
--  DDL for Package QPR_CREATE_DEMO_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_CREATE_DEMO_DATA" AUTHID CURRENT_USER AS
/* $Header: QPRDEMOS.pls 120.2 2008/06/02 12:19:55 kdhabali ship $ */
/* Public Procedures */

procedure insert_data(errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id 	in 	number,
			p_instance_type in	number);

END QPR_CREATE_DEMO_DATA ;

/
