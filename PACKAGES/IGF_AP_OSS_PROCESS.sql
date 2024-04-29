--------------------------------------------------------
--  DDL for Package IGF_AP_OSS_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_OSS_PROCESS" AUTHID CURRENT_USER AS
/* $Header: IGFAP22S.pls 120.1 2005/09/08 14:44:07 appldev noship $ */

PROCEDURE  process_todo ( errbuf               IN OUT NOCOPY VARCHAR2,
                          retcode              IN OUT NOCOPY NUMBER);


END igf_ap_oss_process;

 

/
