--------------------------------------------------------
--  DDL for Package BIM_FIRST_LOAD_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_FIRST_LOAD_FACTS" AUTHID CURRENT_USER AS
/* $Header: bimfdfas.pls 115.3 2003/10/22 08:31:54 kpadiyar ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'BIM_LOAD_FACTS';

PROCEDURE invoke_object
   (ERRBUF	            OUT	 NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER,
    p_object                IN   VARCHAR2  DEFAULT NULL,
   --  p_mode                  IN   VARCHAR2  DEFAULT NULL,
    p_start_dt              IN   VARCHAR2  DEFAULT NULL,
    p_end_dt                IN   VARCHAR2  DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8
    );

PROCEDURE recover_object
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE		    OUT  NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER	,
    p_object                IN   VARCHAR2  DEFAULT NULL,
    p_date                  IN   DATE  DEFAULT SYSDATE
    );

END bim_first_load_facts;

 

/
