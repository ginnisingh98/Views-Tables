--------------------------------------------------------
--  DDL for Package PO_GML_CONV_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_GML_CONV_MIG" AUTHID CURRENT_USER AS
/* $Header: POXMGGMS.pls 120.1 2005/06/08 13:19:32 pbamb noship $ */
Procedure po_mig_gml_data;

PROCEDURE update_po_shipment;

PROCEDURE migrate_hazard_classes
  (
      p_migration_run_id    IN         NUMBER,
      p_commit              IN         VARCHAR2,
      x_failure_count       OUT NOCOPY NUMBER
  );

 PROCEDURE migrate_un_numbers
  (
      p_migration_run_id    IN         NUMBER,
      p_commit              IN         VARCHAR2,
      x_failure_count       OUT NOCOPY NUMBER
  );


END PO_GML_CONV_MIG;


 

/
