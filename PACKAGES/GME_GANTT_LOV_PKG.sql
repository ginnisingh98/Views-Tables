--------------------------------------------------------
--  DDL for Package GME_GANTT_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_GANTT_LOV_PKG" AUTHID CURRENT_USER AS
/* $Header: GMEGNTLS.pls 120.2 2005/06/10 13:57:03 appldev  $  */
   TYPE batchlovdetailrectype IS RECORD (
      batch_id          NUMBER (10)
     ,batch_no          VARCHAR2 (32)
     ,organization_id   NUMBER (10)
     ,batch_status      NUMBER (5)
     ,concatenated_segments VARCHAR2 (2000)
     ,description        VARCHAR2 (2000)
   );

   TYPE batchlovdetailtabletype IS TABLE OF batchlovdetailrectype
      INDEX BY BINARY_INTEGER;

   /**
    * Select the appropriate batches and send them one by one to the gantt
    */
   PROCEDURE select_batches_lov (
      p_input_field         IN              VARCHAR2
     ,p_current_start_row   IN              INTEGER
     ,p_num_row_to_get      IN              INTEGER
     ,p_pending_status      IN              VARCHAR2
     ,p_released_status     IN              VARCHAR2
     ,p_certified_status    IN              VARCHAR2
     ,p_organization_id     IN              INTEGER
     ,p_batch_type          IN              INTEGER
     ,p_fpo_type            IN              INTEGER
     ,p_from_date           IN              DATE
     ,p_to_date             IN              DATE
     ,x_total_rows          OUT NOCOPY      NUMBER
     ,x_batch_lov_tbl       OUT NOCOPY      batchlovdetailtabletype);

   TYPE itemlovdetailrectype IS RECORD (
      inventory_item_id      NUMBER (10)
     ,concatenated_segments  VARCHAR2 (2000)
     ,description   VARCHAR2 (2000)
   );

   TYPE itemlovdetailtabletype IS TABLE OF itemlovdetailrectype
      INDEX BY BINARY_INTEGER;

   PROCEDURE select_items_lov (
      p_input_field         IN              VARCHAR2
     ,p_current_start_row   IN              INTEGER
     ,p_num_row_to_get      IN              INTEGER
     ,p_line_type           IN              INTEGER
     ,p_organization_id     IN              INTEGER
     ,x_total_rows          OUT NOCOPY      NUMBER
     ,x_item_lov_tbl        OUT NOCOPY      itemlovdetailtabletype);

   TYPE resourcelovdetailrectype IS RECORD (
      resources       VARCHAR2 (32)
     ,resource_desc   VARCHAR2 (70)
   );

   TYPE resourcelovdetailtabletype IS TABLE OF resourcelovdetailrectype
      INDEX BY BINARY_INTEGER;

   /**
    * Select the appropriate resources and send them one by one to the gantt
    */
   PROCEDURE select_resources_lov (
      p_input_field         IN              VARCHAR2
     ,p_current_start_row   IN              INTEGER
     ,p_num_row_to_get      IN              INTEGER
     ,p_organization_id     IN              INTEGER
     ,x_total_rows          OUT NOCOPY      NUMBER
     ,x_rsrc_lov_tbl        OUT NOCOPY      resourcelovdetailtabletype);

   TYPE orgnlovdetailrectype IS RECORD (
      organization_code   VARCHAR2 (3)
     ,organization_name   VARCHAR2 (240)
   );

   TYPE orgnlovdetailtabletype IS TABLE OF orgnlovdetailrectype
      INDEX BY BINARY_INTEGER;

   /**
    * Select the vaild organizations for the current operator
    */
   PROCEDURE select_organizations_lov (
      p_input_field         IN              VARCHAR2
     ,p_current_start_row   IN              INTEGER
     ,p_num_row_to_get      IN              INTEGER
     ,p_user_id             IN              NUMBER
     ,x_total_rows          OUT NOCOPY      NUMBER
     ,x_orgn_lov_tbl        OUT NOCOPY      orgnlovdetailtabletype);
END;

 

/
