--------------------------------------------------------
--  DDL for Package CZ_CX_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_CX_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: czvcxus.pls 115.0 2003/08/13 15:07:23 qmao ship $  */

-- Transform old functional companions to configurator extension rule recs.
-- Returns return_status 1 if the conversion process is successful, 0 otherwise.
-- Note: this proc does not create event bindings for the newly transformed cx
-- rules.
PROCEDURE convert_fc_by_model(p_model_id IN NUMBER
                             ,p_deep_migration_flag IN VARCHAR2
                             ,x_num_fc_processed OUT NOCOPY NUMBER
                             ,x_return_status OUT NOCOPY VARCHAR2
                             ,x_msg_data  OUT NOCOPY VARCHAR2
                             );

END cz_cx_util_pvt;

 

/
