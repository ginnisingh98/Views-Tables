--------------------------------------------------------
--  DDL for Package BIM_PERIODIC_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_PERIODIC_FACTS" AUTHID CURRENT_USER AS
/* $Header: bimrlfas.pls 115.3 2003/10/22 08:30:24 kpadiyar ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'BIM_PERIODIC_FACTS';

PROCEDURE invoke_object
   (ERRBUF	            OUT	 NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER,
    p_object                IN   VARCHAR2  DEFAULT NULL,
    p_end_dt                IN   VARCHAR2  DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
    p_full_refresh          IN   VARCHAR2  DEFAULT 'N'
    );

END bim_periodic_facts;

 

/
