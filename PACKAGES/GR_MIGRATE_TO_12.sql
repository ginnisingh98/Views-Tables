--------------------------------------------------------
--  DDL for Package GR_MIGRATE_TO_12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_MIGRATE_TO_12" AUTHID CURRENT_USER AS
/* $Header: GRMIG12S.pls 120.0.12010000.1 2008/07/30 07:14:38 appldev ship $ */


  FUNCTION get_inventory_item_id
  (
     -- Organization id to use to retrieve the value
     p_organization_id        IN          NUMBER,
     -- Item_code to use to retrieve the value
     p_item_code              IN          VARCHAR2,
     -- Returns the status of the procedure
     x_return_status          OUT NOCOPY  VARCHAR2 ,
     -- Returns message data
     x_msg_data               OUT NOCOPY  VARCHAR2
  )
  RETURN  NUMBER;


  FUNCTION get_hazard_class_id
  (
      -- Item code to retrieve Hazard class id for
      p_item_code             IN          VARCHAR2,
      -- Returns the status of the procedure
      x_return_status         OUT NOCOPY  VARCHAR2 ,
      -- Returns message data
      x_msg_data              OUT NOCOPY VARCHAR2
  )
  RETURN  NUMBER;


  FUNCTION get_un_number_id
  (
      -- Item code to retrieve UN Number id for
      p_item_code             IN         VARCHAR2,
      -- Returns the status of the procedure
      x_return_status         OUT NOCOPY VARCHAR2 ,
      -- Returns message data
      x_msg_data              OUT NOCOPY VARCHAR2
  )
  RETURN  NUMBER;


  PROCEDURE create_item_mig_records
  (
      -- Migration run id to be used for writing message to the message log
      p_migration_run_id    IN         NUMBER,
      -- Indicates if commit should be issued after logical unit is migrated
      p_commit              IN         VARCHAR2,
      -- Returns the number of failures that occurred during migration
      x_failure_count       OUT NOCOPY NUMBER
  );


  PROCEDURE migrate_regulatory_items
  (
      -- Migration run id to be used for writing message to the message log
      p_migration_run_id    IN         NUMBER,
      -- Indicates if commit should be issued after logical unit is migrated
      p_commit              IN         VARCHAR2,
      -- Returns the number of failures that occurred during migration
      x_failure_count       OUT NOCOPY NUMBER
  );


  PROCEDURE migrate_standalone_formulas
  (
      -- Migration run id to be used for writing message to the message log
      p_migration_run_id    IN         NUMBER,
      -- Indicates if commit should be issued after logical unit is migrated
      p_commit              IN         VARCHAR2,
      -- Returns the number of failures that occurred during migration
      x_failure_count       OUT NOCOPY NUMBER
  );


  PROCEDURE update_dispatch_history
  (
      -- Migration run id to be used for writing message to the message log
      p_migration_run_id    IN         NUMBER,
      -- Indicates if commit should be issued after logical unit is migrated
      p_commit              IN         VARCHAR2,
      -- Returns the number of failures that occurred during migration
      x_failure_count       OUT NOCOPY NUMBER
  );

END GR_MIGRATE_TO_12;


/
