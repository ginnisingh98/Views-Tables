--------------------------------------------------------
--  DDL for Package GME_REVERT_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_REVERT_STEP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVRWSS.pls 120.0 2005/06/17 14:36:07 snene noship $ */

PROCEDURE revert_step
(p_batch_step_rec      	IN  GME_BATCH_STEPS%ROWTYPE
 ,p_batch_header_rec     IN  GME_BATCH_HEADER%ROWTYPE
 ,x_batch_step_rec      	OUT NOCOPY GME_BATCH_STEPS%ROWTYPE
 ,x_return_status        OUT NOCOPY VARCHAR2);


END gme_revert_step_pvt;

 

/
