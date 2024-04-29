--------------------------------------------------------
--  DDL for Package IEM_CONCURRENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_CONCURRENT_PVT" AUTHID CURRENT_USER as
/* $Header: iemvcons.pls 115.5 2002/12/22 01:19:48 sboorela shipped $*/

type email_account_id_tbl is table of number index by binary_integer;

PROCEDURE StartProcess(ERRBUF   OUT NOCOPY     VARCHAR2,
                       RETCODE  OUT  NOCOPY    VARCHAR2,
                       p_period_to_wake_up  NUMBER,
                       p_number_of_threads  NUMBER,
                       p_number_of_msgs     NUMBER,
                       p_schedule_retry	    VARCHAR2,
                       p_hour		    NUMBER,
                       p_minutes	    NUMBER);


PROCEDURE SyncFolder(ERRBUF   OUT   NOCOPY   VARCHAR2,
                     RETCODE  OUT    NOCOPY  VARCHAR2
                    );

END IEM_CONCURRENT_PVT;


 

/
