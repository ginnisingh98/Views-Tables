--------------------------------------------------------
--  DDL for Package OUTSIDE_PROC_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OUTSIDE_PROC_SV" AUTHID CURRENT_USER AS
/* $Header: POXOPROS.pls 115.5 2002/11/23 03:02:34 sbull ship $*/

/*===========================================================================
  PROCEDURE NAME:     get_entity_default

  DESCRIPTION:        defaults the values for the Job

  PARAMETERS:         x_entity_id
                      x_dest_org_id
                      x_entity_name
                      x_entity_type

  DESIGN REFERENCES:	../POXPOMPO.doc


  ALGORITHM:

  NOTES:
  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       ALOCATEL Last Change on 7/12
===========================================================================*/

PROCEDURE get_entity_defaults (x_entity_id            IN     NUMBER,
                               x_dest_org_id          IN     NUMBER,
                               x_entity_name          IN OUT NOCOPY VARCHAR2,
                               x_entity_type          IN OUT NOCOPY VARCHAR2);

PROCEDURE test_get_entity_defaults (x_entity_id            IN     NUMBER,
                                    x_dest_org_id          IN     NUMBER);



/*===========================================================================
  PROCEDURE NAME:    get_wip_line_defaults

  DESCRIPTION:       Defaults the values for the line

  PARAMETERS:         x_entity_id
                      x_dest_org_id
                      x_entity_name
                      x_entity_type

  DESIGN REFERENCES:	../POXPOMPO.doc


  ALGORITHM:

  NOTES:
  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       ALOCATEL Last Change on 7/12
===========================================================================*/

PROCEDURE get_wip_line_defaults (x_line_id             IN     NUMBER,
                                 x_dest_org_id         IN     NUMBER,
                                 x_wip_line_code       IN OUT NOCOPY VARCHAR2);


PROCEDURE test_get_wip_line_defaults (x_line_id             IN     NUMBER,
                                      x_dest_org_id         IN     NUMBER);


/*===========================================================================
  PROCEDURE NAME:     get_operation_defaults

  DESCRIPTION:        Defaults the values for the Operation

  PARAMETERS:         x_entity_id
                      x_dest_org_id
                      x_entity_name
                      x_entity_type

  DESIGN REFERENCES:	../POXPOMPO.doc


  ALGORITHM:

  NOTES:
  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       ALOCATEL Last Change on 7/12
===========================================================================*/

PROCEDURE get_operation_defaults(x_wip_repetitive_schedule_id  IN  NUMBER,
                          x_wip_operation_seq_num         IN     NUMBER,
                          x_entity_id                     IN     NUMBER,
                          x_dest_org_id                   IN     NUMBER,
                          x_bom_department_code           IN OUT NOCOPY VARCHAR2,
                          x_wip_operation_code            IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:     get_resource_defaults

  DESCRIPTION:        Defaults the values for the Resource

  PARAMETERS:         x_entity_id
                      x_dest_org_id
                      x_entity_name
                      x_entity_type

  DESIGN REFERENCES:	../POXPOMPO.doc


  ALGORITHM:

  NOTES:
  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       ALOCATEL Last Change on 7/12
===========================================================================*/

PROCEDURE get_resource_defaults(x_bom_resource_id        IN     NUMBER,
                          x_dest_org_id                  IN     NUMBER,
                          x_bom_resource_code            IN OUT NOCOPY VARCHAR2,
                          x_bom_resource_unit            IN OUT NOCOPY VARCHAR2,
                          x_bom_cost_element_id          IN OUT NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:     calc_assy_res_qty

  DESCRIPTION:        Defaults the values for the Assembly and Resource
                      quantities

  PARAMETERS:         x_quantity_ordered
                      x_wip_repetitive_schedule_id
                      x_wip_operation_seq_num
                      x_wip_resource_seq_num
                      x_entity_id
                      x_dest_org_id
                      x_usage_rate_or_amount
                      x_assembly_quantity
                      x_resource_quantity

  DESIGN REFERENCES:	../POXPOMPO.doc


  ALGORITHM:

  NOTES:
  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       ALOCATEL Last Change on 7/12
===========================================================================*/

PROCEDURE calc_assy_res_qty(x_outside_op_uom_type         IN     VARCHAR2,
                          x_quantity_ordered              IN     NUMBER,
                          x_wip_repetitive_schedule_id    IN     NUMBER,
                          x_wip_operation_seq_num         IN     NUMBER,
                          x_wip_resource_seq_num          IN     NUMBER,
                          x_entity_id                     IN     NUMBER,
                          x_dest_org_id                   IN     NUMBER,
                          x_usage_rate_or_amount          IN OUT NOCOPY NUMBER,
                          x_assembly_quantity             IN OUT NOCOPY NUMBER,
                          x_resource_quantity             IN OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:   get_unit_type

  DESCRIPTION:      x_op_uom_type_dsp
                    x_op_uom_type

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc


  ALGORITHM:

  NOTES:
  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       ALOCATEL Last Change on 7/12
===========================================================================*/

PROCEDURE get_unit_type (x_op_uom_type_dsp          IN     VARCHAR2,
                         x_op_uom_type              IN OUT NOCOPY VARCHAR2);

PROCEDURE test_get_unit_type (x_op_uom_type_dsp          IN VARCHAR2);

PROCEDURE get_project_task_num(x_project_id    IN     NUMBER,
                               x_task_id       IN     NUMBER,
                               x_project       IN OUT NOCOPY VARCHAR2,
                               x_task          IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  FUNCTION NAME:   prj_id_to_num

  DESCRIPTION:     This function returns project number for the input
                   project_id.  It reads both the PA projects as well as
                   PJM.

  PARAMETERS:      X_project_id  in number

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:           Created for the code fix on bug 1793862

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  SKTIWARI Created on 31-AUG-2001
===========================================================================*/
FUNCTION prj_id_to_num (X_project_id in number) return varchar2;

end outside_proc_sv;

 

/
