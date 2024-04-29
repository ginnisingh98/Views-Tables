--------------------------------------------------------
--  DDL for Package AMW_PROCESS_CERT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROCESS_CERT_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: amwpcess.pls 120.0.12000000.1 2007/01/16 20:40:05 appldev ship $ */

PROCEDURE UPDATE_SUMMARY_TABLE
(p_process_id 		IN 	NUMBER,
 p_org_id 		IN 	NUMBER,
 p_certification_id 	IN 	NUMBER
);

PROCEDURE POPULATE_SUMMARY
(p_certification_id 	IN 	NUMBER
);

PROCEDURE POPULATE_ALL_CERT_SUMMARY
(x_errbuf 		OUT 	NOCOPY VARCHAR2,
 x_retcode 		OUT 	NOCOPY NUMBER,
 p_certification_id     IN    	NUMBER
);

PROCEDURE  POPULATE_CERT_GENERAL_SUM
(p_certification_id     IN    	NUMBER,
 p_start_date		IN  	DATE
);


PROCEDURE POPULATE_ALL_CERT_GENERAL_SUM
(errbuf       		OUT NOCOPY      VARCHAR2,
 retcode      		OUT NOCOPY      NUMBER,
 p_certification_id	IN	 	NUMBER
);

PROCEDURE Populate_Proc_Cert_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
);

PROCEDURE Populate_Proccert_Findings
(x_errbuf 		OUT 	NOCOPY VARCHAR2,
 x_retcode 		OUT 	NOCOPY NUMBER,
 p_certification_id     IN    	NUMBER
);

END  AMW_PROCESS_CERT_SUMMARY;

 

/
