--------------------------------------------------------
--  DDL for Package PA_VALUE_MAP_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_VALUE_MAP_DEF_PKG" AUTHID CURRENT_USER as
/* $Header: PAYMDEFS.pls 120.1 2005/08/19 17:23:15 mwasowic noship $ */

--
-- Procedure     : update_row
-- Purpose       : Update a row in PA_VALUE_MAP_DEFINITIONS.
--
--
PROCEDURE update_row
      ( p_value_map_def_id                 IN NUMBER                               ,
        p_record_version_number            IN NUMBER                               ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


END PA_VALUE_MAP_DEF_PKG;

 

/
