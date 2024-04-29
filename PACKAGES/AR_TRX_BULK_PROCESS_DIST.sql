--------------------------------------------------------
--  DDL for Package AR_TRX_BULK_PROCESS_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_BULK_PROCESS_DIST" AUTHID CURRENT_USER AS
/* $Header: ARINBLDS.pls 120.2 2005/10/30 04:23:35 appldev noship $ */


PROCEDURE INSERT_ROW (
        p_trx_dist_id               IN      NUMBER ,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2);

END AR_TRX_BULK_PROCESS_DIST;

 

/
