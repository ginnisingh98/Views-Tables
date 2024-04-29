--------------------------------------------------------
--  DDL for Package IEM_CONCURRENT_MDT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_CONCURRENT_MDT_PVT" AUTHID CURRENT_USER as
/* $Header: iempcons.pls 115.9 2002/12/05 21:12:08 appldev shipped $*/

type email_account_id_pmdt_tbl is table of number index by binary_integer;

PROCEDURE StartProcess(ERRBUF   OUT NOCOPY     VARCHAR2,
                       RETCODE  OUT NOCOPY     VARCHAR2,
                       p_delay_worker_start_time        VARCHAR2,
				   p_schedule_worker_stop_date      VARCHAR2,
                       p_period_to_wake_up  NUMBER,
                       p_number_of_threads  NUMBER,
                       p_number_of_msgs     NUMBER);

/*
PROCEDURE SyncFolder(ERRBUF   OUT NOCOPY     VARCHAR2,
                     RETCODE  OUT NOCOPY     VARCHAR2
                    );
*/
END IEM_CONCURRENT_MDT_PVT;


 

/
