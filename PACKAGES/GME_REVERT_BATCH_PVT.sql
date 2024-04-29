--------------------------------------------------------
--  DDL for Package GME_REVERT_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_REVERT_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVRWBS.pls 120.0 2005/06/17 14:35:42 snene noship $ */

PROCEDURE revert_batch
( p_batch_header_rec     IN GME_BATCH_HEADER%ROWTYPE
, x_batch_header_rec     OUT NOCOPY GME_BATCH_HEADER%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2     );

PROCEDURE revert_line
(p_batch_header_rec    IN GME_BATCH_HEADER%ROWTYPE
,p_material_details_rec IN gme_material_details%ROWTYPE
,p_batch_step_rec       IN gme_batch_steps%ROWTYPE
,x_return_status   OUT NOCOPY VARCHAR2);



END gme_revert_batch_pvt;

 

/
