--------------------------------------------------------
--  DDL for Package PA_PERIOD_MASK_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERIOD_MASK_DETAILS_PKG" AUTHID CURRENT_USER AS
--$Header: PAFPPMDS.pls 120.1 2005/08/19 16:28:17 mwasowic noship $
 PROCEDURE insert_row(
 x_rowid  IN OUT NOCOPY ROWID, --File.Sql.39 bug 4440895
 x_period_mask_id        IN pa_period_mask_details.period_mask_id%type,
 x_num_of_periods        IN pa_period_mask_details.num_of_periods%type,
 x_anchor_period_flag    IN pa_period_mask_details.anchor_period_flag%type,
 x_from_anchor_start     IN pa_period_mask_details.from_anchor_start%type,
 x_from_anchor_end       IN pa_period_mask_details.from_anchor_end%type,
 x_from_anchor_position  IN pa_period_mask_details.from_anchor_position%type,
 x_creation_date         IN pa_period_mask_details.creation_date%type,
 x_created_by            IN pa_period_mask_details.created_by%type,
 x_last_update_login     IN pa_period_mask_details.last_update_login%type,
 x_last_updated_by       IN pa_period_mask_details.last_updated_by%type,
 x_last_update_date      IN pa_period_mask_details.last_update_date%type
);


    -- locks record into PA_PERIOD_MASK_DETAILS table

PROCEDURE lock_row(
          x_period_mask_id IN pa_period_mask_details.period_mask_id%type,
          x_from_anchor_position IN pa_period_mask_details.from_anchor_position%type);

    -- updates record into PA_PERIOD_MASK_DETAILS table

    PROCEDURE update_row(
    x_period_mask_id       IN pa_period_mask_details.period_mask_id%type,
    x_num_of_periods       IN pa_period_mask_details.num_of_periods%type,
    x_anchor_period_flag   IN pa_period_mask_details.anchor_period_flag%type,
    x_from_anchor_start    IN pa_period_mask_details.from_anchor_start%type,
    x_from_anchor_end      IN pa_period_mask_details.from_anchor_end%type,
    x_from_anchor_position IN pa_period_mask_details.from_anchor_position%type,
    x_creation_date         IN pa_period_mask_details.creation_date%type,
    x_created_by            IN pa_period_mask_details.created_by%type,
    x_last_update_login     IN pa_period_mask_details.last_update_login%type,
    x_last_updated_by       IN pa_period_mask_details.last_updated_by%type,
    x_last_update_date      IN pa_period_mask_details.last_update_date%type);

   -- deletes record into PA_PERIOD_MASK_DETAILS table

 PROCEDURE delete_row(
          x_period_mask_id IN pa_period_mask_details.period_mask_id%type,
          x_from_anchor_position IN pa_period_mask_details.from_anchor_position%type);

   -- load records into PA_PERIOD_MASK_DETAILS table


   PROCEDURE load_row(
   x_period_mask_id        IN  pa_period_mask_details.period_mask_id%type,
   x_num_of_periods        IN  pa_period_mask_details.num_of_periods%type,
   x_anchor_period_flag    IN pa_period_mask_details.anchor_period_flag%type,
   x_from_anchor_start     IN pa_period_mask_details.from_anchor_start%type,
   x_from_anchor_end       IN pa_period_mask_details.from_anchor_end%type,
   x_from_anchor_position  IN pa_period_mask_details.from_anchor_position%type,
   x_creation_date         IN pa_period_mask_details.creation_date%type,
   x_created_by            IN pa_period_mask_details.created_by%type,
   x_last_update_login     IN pa_period_mask_details.last_update_login%type,
   x_last_updated_by       IN pa_period_mask_details.last_updated_by%type,
   x_last_update_date      IN pa_period_mask_details.last_update_date%type,
   x_owner                 IN VARCHAR2);


END PA_PERIOD_MASK_DETAILS_PKG;

 

/
