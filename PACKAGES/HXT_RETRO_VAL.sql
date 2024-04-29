--------------------------------------------------------
--  DDL for Package HXT_RETRO_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_RETRO_VAL" AUTHID CURRENT_USER AS
/* $Header: hxtrval.pkh 120.2 2007/01/05 18:14:44 nissharm noship $ */

PROCEDURE Val_Retro_Timecard (p_batch_id IN NUMBER,
                     p_tim_id IN NUMBER,
                     p_valid_retcode IN OUT NOCOPY NUMBER,
		     p_merge_flag	IN		VARCHAR2 DEFAULT '0',
		     p_merge_batches   OUT NOCOPY      HXT_BATCH_PROCESS.MERGE_BATCHES_TYPE_TABLE);

PROCEDURE Mark_Rows_Complete(p_batch_id IN NUMBER);
END HXT_RETRO_VAL;

/
