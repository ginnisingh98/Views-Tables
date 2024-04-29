--------------------------------------------------------
--  DDL for Package CST_START_IMP_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_START_IMP_PROCESS" AUTHID CURRENT_USER as
/* $Header: CSTSIMPS.pls 115.3 2002/11/11 22:57:13 awwang ship $ */

PROCEDURE Start_process(ERRBUF OUT NOCOPY VARCHAR2,
                        RETCODE OUT NOCOPY NUMBER,
                        i_option IN NUMBER,
                        i_run_option IN NUMBER,
                        i_group_option IN NUMBER,
                        i_group_dummy IN VARCHAR2,
                        i_next_val IN VARCHAR2,
                        i_cost_type IN VARCHAR2,
                        i_del_option IN NUMBER
                        );
END CST_START_IMP_PROCESS;

 

/
