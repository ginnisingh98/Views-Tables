--------------------------------------------------------
--  DDL for Package IEM_CONCURRENT_NEXT_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_CONCURRENT_NEXT_GEN_PVT" AUTHID CURRENT_USER as
/* $Header: iemngcss.pls 120.0 2005/06/02 14:05:56 appldev noship $*/

type email_account_id_pmdt_tbl is table of number index by binary_integer;

PROCEDURE StartProcess(ERRBUF   OUT NOCOPY     VARCHAR2,
                       RETCODE  OUT NOCOPY     VARCHAR2,
                       p_delay_worker_start_time   VARCHAR2,
                       p_schedule_worker_stop_date      VARCHAR2,
                       p_period_to_wake_up  NUMBER,
                       p_number_of_threads  NUMBER,
                       p_number_of_msgs     NUMBER);

END IEM_CONCURRENT_NEXT_GEN_PVT;


 

/
