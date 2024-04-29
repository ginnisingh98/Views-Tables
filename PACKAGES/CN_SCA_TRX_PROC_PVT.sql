--------------------------------------------------------
--  DDL for Package CN_SCA_TRX_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_TRX_PROC_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvstrps.pls 120.4 2006/03/30 21:10:45 vensrini noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   cn_sca_trx_proc_pub
-- Purpose
--   Procedures TO populate transactions from CN_COMM_LINES_API into SCA interface tables and
--   transfer results back to CN_COMM_LINES_API from SCA output tables after credit allocation

-- History
--   06/02/03   Mike Ting 	Created

-- Name:
--   populate_results
-- Purpose:
--   This procedure initiates the population of data from the API table into SCA interface tables.

PROCEDURE debugmsg(msg VARCHAR2);

PROCEDURE Conc_Submit(x_conc_program		VARCHAR2
		       ,x_parent_proc_audit_id  NUMBER
		       ,x_process	            VARCHAR2
		       ,x_physical_batch_id 	NUMBER
               ,x_start_date            DATE
		       ,x_end_date              DATE
		       ,x_request_id 	 IN OUT NOCOPY NUMBER);


PROCEDURE conc_dispatch(x_parent_proc_audit_id NUMBER,
			  x_start_date           DATE,
			  x_end_date             DATE,
			  x_logical_batch_id     NUMBER,
              x_process                VARCHAR2);


--+ Procedure Name
--+   Assign
--+ Purpose : Split the logical batch into smaller physical batches
--+           populate the physical_batch_id in cn_process_batches

PROCEDURE ASSIGN(p_logical_batch_id NUMBER,
		 p_start_date	DATE,
		 p_end_date	DATE,
		 batch_type		VARCHAR2,
		 p_org_id  NUMBER, -- updated by vensrini
		 x_size    OUT NOCOPY  NUMBER);


PROCEDURE create_trx (
            p_start_date    DATE,
            p_end_date      DATE,
            p_physical_batch_id     NUMBER);

PROCEDURE negate_trx (
            p_start_date    DATE,
            p_end_date      DATE,
            p_physical_batch_id     NUMBER);

PROCEDURE check_adjusted (
            p_start_date    DATE,
            p_end_date      DATE,
            p_physical_batch_id     NUMBER);

PROCEDURE check_api_adjusted (
            p_start_date    DATE,
            p_end_date      DATE,
            p_physical_batch_id     NUMBER);

PROCEDURE populate_results (
                errbuf         OUT 	NOCOPY VARCHAR2,
                retcode        OUT 	NOCOPY NUMBER,
                pp_start_date    	VARCHAR2,
                pp_end_date      	VARCHAR2,
		p_org_id	IN	VARCHAR2);

PROCEDURE populate_data (
                errbuf         		OUT NOCOPY VARCHAR2,
                retcode        		OUT NOCOPY NUMBER,
                pp_start_date    	VARCHAR2,
                pp_end_date      	VARCHAR2,
                p_checkbox_value    	VARCHAR2);

PROCEDURE call_populate_data (
        p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
        p_commit	        IN      VARCHAR2 	:= FND_API.G_FALSE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_checkbox_value        IN      VARCHAR2,
        x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_process_audit_id      OUT NOCOPY     NUMBER);


PROCEDURE call_populate_results (
        p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
        p_commit	        IN      VARCHAR2 	:= FND_API.G_FALSE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_org_id	        IN      NUMBER,
        x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_process_audit_id      OUT NOCOPY     NUMBER);

PROCEDURE sca_batch_runner(
            errbuf       OUT NOCOPY     VARCHAR2
		   ,retcode      OUT NOCOPY     NUMBER
		   ,p_parent_proc_audit_id      NUMBER
		   ,p_process  	              VARCHAR2
		   ,p_physical_batch_id 	NUMBER
		   ,p_start_date                DATE     := NULL
		   ,p_end_date                  DATE     := NULL
		   ,p_org_id		IN	NUMBER);


END cn_sca_trx_proc_pvt;

 

/
