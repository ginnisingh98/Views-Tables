--------------------------------------------------------
--  DDL for Package HXT_RETRO_MIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_RETRO_MIX" AUTHID CURRENT_USER AS
/* $Header: hxtrmix.pkh 120.0.12010000.3 2010/04/13 12:03:45 asrajago ship $ */
--


-- Bug 8888777
-- Added global variables for IV processing.
g_IV_upgrade    VARCHAR2(30);
g_IV_format     VARCHAR2(50);
g_XIV_TABLE  HXT_OTC_RETRIEVAL_INTERFACE.IV_TABLE;



PROCEDURE retro_sum_to_mix (p_batch_id IN NUMBER,
                      p_tim_id IN NUMBER,
 		      p_sum_retcode OUT NOCOPY NUMBER,
                      p_err_buf OUT NOCOPY VARCHAR2);

-- Bug 9494444
-- Added new procedure to snap details for the dashboard.
PROCEDURE snap_retrieval_details(p_batch_id   IN NUMBER,
                                 p_tim_id     IN NUMBER);
--
END hxt_retro_mix;

/
