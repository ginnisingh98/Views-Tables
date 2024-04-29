--------------------------------------------------------
--  DDL for Package BIM_LOAD_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_LOAD_FACTS" AUTHID CURRENT_USER AS
/* $Header: bimldfas.pls 120.1 2005/06/14 15:16:36 appldev  $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'BIM_LOAD_FACTS';

PROCEDURE invoke_object
   (ERRBUF	            OUT	 NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER,
    p_object                IN   VARCHAR2  DEFAULT NULL,
    p_mode                  IN   VARCHAR2  DEFAULT NULL,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_end_date              IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER          DEFAULT 8
    );

PROCEDURE recover_object
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE		    OUT  NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER	,
    p_object                IN   VARCHAR2  DEFAULT NULL,
    p_date                  IN   DATE  DEFAULT SYSDATE
    );

END bim_load_facts;

 

/
