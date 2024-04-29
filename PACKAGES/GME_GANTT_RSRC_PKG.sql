--------------------------------------------------------
--  DDL for Package GME_GANTT_RSRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_GANTT_RSRC_PKG" AUTHID CURRENT_USER AS
/* $Header: GMEGNTRS.pls 120.3 2005/06/10 13:57:25 appldev  $  */
   TYPE plantresourcedetailtabletype IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   /**
    * Select the available resources for the current organization and send them one by
    * one to the gantt
    */
   PROCEDURE get_available_plant_resources (
      p_organization_id   IN              NUMBER
     ,x_nb_resources      OUT NOCOPY      NUMBER
     ,x_plant_rsrc_tbl    OUT NOCOPY      plantresourcedetailtabletype);

   TYPE reschbatchdetailtabletype IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   /**
    * Fetch pending and WIP batches that consume the selected resource at the selected time.
    */
   PROCEDURE get_reschedule_batch_list (
      p_organization_id   IN              NUMBER
     ,p_resource          IN              VARCHAR2
     ,p_from_date         IN              DATE
     ,p_to_date           IN              DATE
     ,x_nb_batches        OUT NOCOPY      NUMBER
     ,x_resch_batch_tbl   OUT NOCOPY      reschbatchdetailtabletype);

   TYPE resourcecoderectype IS RECORD (
      resources   VARCHAR2 (32)
   );

   TYPE resourcecodetabletype IS TABLE OF resourcecoderectype
      INDEX BY BINARY_INTEGER;

   TYPE resourceloadtabletype IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   TYPE batchid IS TABLE OF gme_batch_header.batch_id%TYPE;

   TYPE batchno IS TABLE OF gme_batch_header.batch_no%TYPE;

   TYPE batchtype IS TABLE OF gme_batch_header.batch_type%TYPE;

   TYPE batchstatus IS TABLE OF gme_batch_header.batch_status%TYPE;

   TYPE batchdate IS TABLE OF gme_batch_header.plan_start_date%TYPE;

   TYPE enforcestepdep IS TABLE OF gme_batch_header.enforce_step_dependency%TYPE;

   TYPE resdate IS TABLE OF gme_resource_txns_summary.start_date%TYPE;

   TYPE rescount IS TABLE OF NUMBER;

   TYPE rescode IS TABLE OF cr_rsrc_mst.resources%TYPE;

   TYPE resdesc IS TABLE OF cr_rsrc_mst.resource_desc%TYPE;

   /**
    * Retrieve the resource load data (qty available and scheduled usage)
    *
    * 25FEB02  Eddie Oumerretane
    *          Bug # 1919745 Implemented the new resource load summary
    *          table GME_BATCH_STEP_RSRC_SUMMARY. Now resource load data
    *          is retrieved from this new table, replacing the
    *          GME_BATCH_STEP_RESOURCES table.
    * 10OCT02  Eddie Oumerretane.
    *          Bug # 2565952 Replaced table GME_BATCH_STEP_RSRC_SUMMARY
    *          with GME_RESOURCE_TXNS_SUMMARY table.
    */
   PROCEDURE fetch_resource_load (
      p_resource_code       IN OUT NOCOPY   VARCHAR2
     ,p_organization_id     IN              NUMBER
     ,p_from_date           IN              DATE
     ,p_to_date             IN              DATE
     ,x_resource_desc       OUT NOCOPY      VARCHAR2
     ,x_resource_uom        OUT NOCOPY      VARCHAR2
     ,x_nb_load_interval    OUT NOCOPY      NUMBER
     ,x_nb_avail_interval   OUT NOCOPY      NUMBER
     ,x_rsrc_avail_tbl      OUT NOCOPY      resourceloadtabletype
     ,x_rsrc_load_tbl       OUT NOCOPY      resourceloadtabletype);
END;

 

/
