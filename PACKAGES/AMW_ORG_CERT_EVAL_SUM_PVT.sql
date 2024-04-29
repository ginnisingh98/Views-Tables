--------------------------------------------------------
--  DDL for Package AMW_ORG_CERT_EVAL_SUM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_ORG_CERT_EVAL_SUM_PVT" AUTHID CURRENT_USER AS
/* $Header: amwocerts.pls 120.0 2005/05/31 23:00:58 appldev noship $ */

PROCEDURE populate_org_cert_summary
(
	x_errbuf 		    OUT      NOCOPY VARCHAR2,
	x_retcode		    OUT      NOCOPY NUMBER,
	p_certification_id     	    IN       NUMBER

);

PROCEDURE populate_org_cert_sum_spec
(
	p_certification_id 	IN 	NUMBER
);

PROCEDURE populate_summary
(
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_org_id 		        IN 	 NUMBER,
    p_certification_id 	        IN 	 NUMBER,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
);


END AMW_ORG_CERT_EVAL_SUM_PVT;


 

/
