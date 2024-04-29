--------------------------------------------------------
--  DDL for Package Body OUTSIDE_PROC_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OUTSIDE_PROC_SV" AS
/* $Header: POXOPROB.pls 115.6 2003/12/18 18:18:44 jskim ship $*/
/*===========================================================================

   PROCEDURE NAME:	get_entity_defaults()

===========================================================================*/

PROCEDURE get_entity_defaults (x_entity_id            IN     NUMBER,
                               x_dest_org_id          IN     NUMBER,
                               x_entity_name          IN OUT NOCOPY VARCHAR2,
                               x_entity_type          IN OUT NOCOPY VARCHAR2) IS



x_progress VARCHAR2(3) := NULL;


BEGIN

  x_progress := 10;

  SELECT wip_entity_name,
         entity_type
  INTO  x_entity_name,
        x_entity_type
  FROM  wip_entities
  WHERE wip_entity_id   = x_entity_id
  AND   organization_id = x_dest_org_id;

  RETURN;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
    RETURN;

   WHEN OTHERS THEN
      po_message_s.sql_error('get_entity_defaults', x_progress, sqlcode);
   RAISE;

END get_entity_defaults;

/*===========================================================================

  PROCEDURE NAME:	test_get_entity_defaults()

===========================================================================*/

PROCEDURE test_get_entity_defaults (x_entity_id            IN     NUMBER,
                                    x_dest_org_id          IN     NUMBER) IS



x_progress VARCHAR2(3) := NULL;
x_entity_name VARCHAR2(15);
x_entity_type VARCHAR2(15);

BEGIN


  --DBMS_OUTPUT.PUT_LINE('x_entity_id = ' || x_entity_id );
  --DBMS_OUTPUT.PUT_LINE('x_dest_org_id = ' ||  x_dest_org_id );


   outside_proc_sv.get_entity_defaults(x_entity_id,
                    x_dest_org_id, x_entity_name, x_entity_type );



    --DBMS_OUTPUT.PUT_LINE('x_entity_name = ' || x_entity_name);
    --DBMS_OUTPUT.PUT_LINE('x_entity_type = ' || x_entity_type);


    RETURN;

    EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('test_get_entity_defaults', x_progress, sqlcode);
    RAISE;


end test_get_entity_defaults;

/*===========================================================================

   PROCEDURE NAME:	get_wip_line_defaults()

===========================================================================*/

PROCEDURE get_wip_line_defaults (x_line_id            IN     NUMBER,
                               x_dest_org_id          IN     NUMBER,
                               x_wip_line_code        IN OUT NOCOPY VARCHAR2) IS




x_progress VARCHAR2(3) := NULL;


BEGIN

  x_progress := 10;

  SELECT line_code
  INTO   x_wip_line_code
  FROM   wip_lines
  WHERE  line_id         = x_line_id
  AND    organization_id = x_dest_org_id;


  RETURN;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
    RETURN;

   WHEN OTHERS THEN
      po_message_s.sql_error('get_wip_line_defaults', x_progress, sqlcode);
   RAISE;

END get_wip_line_defaults;


/*===========================================================================

  PROCEDURE NAME:	test_get_wip_line_defaults()

===========================================================================*/

PROCEDURE test_get_wip_line_defaults (x_line_id              IN     NUMBER,
                                      x_dest_org_id          IN     NUMBER) IS



x_progress VARCHAR2(3) := NULL;
x_wip_line_code VARCHAR2(15);


BEGIN


  --DBMS_OUTPUT.PUT_LINE('x_line_id = ' || x_line_id );
  --DBMS_OUTPUT.PUT_LINE('x_dest_org_id = ' ||  x_dest_org_id );


   outside_proc_sv.get_wip_line_defaults(x_line_id,
                    x_dest_org_id, x_wip_line_code );



    --DBMS_OUTPUT.PUT_LINE('x_wip_line_code = ' || x_wip_line_code);


    RETURN;

    EXCEPTION
    WHEN OTHERS THEN
    po_message_s.sql_error('test_get_wip_line_defaults', x_progress, sqlcode);
    RAISE;


end test_get_wip_line_defaults;


/*===========================================================================

   PROCEDURE NAME:	get_operation_defaults()

===========================================================================*/

PROCEDURE get_operation_defaults(x_wip_repetitive_schedule_id  IN  NUMBER,
                          x_wip_operation_seq_num         IN     NUMBER,
                          x_entity_id                     IN     NUMBER,
                          x_dest_org_id                   IN     NUMBER,
                          x_bom_department_code           IN OUT NOCOPY VARCHAR2,
                          x_wip_operation_code            IN OUT NOCOPY VARCHAR2) IS



x_progress VARCHAR2(3) := NULL;


BEGIN

  x_progress := 10;


/* Bug 655523
   Modified the following SQL for performance improvements
*/

        IF x_wip_repetitive_schedule_id is NULL THEN

                SELECT department_code, operation_code
                INTO   x_bom_department_code, x_wip_operation_code
                FROM   wip_osp_operations_val_v
                WHERE  organization_id = x_dest_org_id
                AND    operation_seq_num = x_wip_operation_seq_num
                AND    wip_entity_id = x_entity_id
                AND    x_wip_repetitive_schedule_id is null;


       ELSE

                SELECT department_code, operation_code
                INTO   x_bom_department_code, x_wip_operation_code
                FROM   wip_osp_operations_val_v
                WHERE  organization_id = x_dest_org_id
                AND    operation_seq_num = x_wip_operation_seq_num
                AND    wip_entity_id = x_entity_id
                AND    x_wip_repetitive_schedule_id is not null
                AND    repetitive_schedule_id = x_wip_repetitive_schedule_id;


       END IF;


  RETURN;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
    RETURN;

   WHEN OTHERS THEN
      po_message_s.sql_error('get_operation_defaults', x_progress, sqlcode);
   RAISE;

END get_operation_defaults;


/*===========================================================================

   PROCEDURE NAME:	get_resource_defaults()

===========================================================================*/

PROCEDURE get_resource_defaults(x_bom_resource_id        IN     NUMBER,
                          x_dest_org_id                  IN     NUMBER,
                          x_bom_resource_code            IN OUT NOCOPY VARCHAR2,
                          x_bom_resource_unit            IN OUT NOCOPY VARCHAR2,
                          x_bom_cost_element_id          IN OUT NOCOPY NUMBER) IS


x_progress VARCHAR2(3) := NULL;


BEGIN

  x_progress := 10;

  SELECT resource_code,
         unit_of_measure,
         cost_element_id
  INTO  x_bom_resource_code,
        x_bom_resource_unit,
        x_bom_cost_element_id
  FROM  bom_resources
  WHERE resource_id       = x_bom_resource_id
  AND   organization_id   = x_dest_org_id;


  RETURN;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
    RETURN;

   WHEN OTHERS THEN
      po_message_s.sql_error('get_resource_defaults', x_progress, sqlcode);
   RAISE;

END get_resource_defaults;



/*===========================================================================

   PROCEDURE NAME:	calc_assy_res_qty()

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
                          x_resource_quantity             IN OUT NOCOPY NUMBER) IS


x_progress VARCHAR2(3) := NULL;


BEGIN

  x_progress := 10;

SELECT usage_rate_or_amount,
       decode(x_outside_op_uom_type,
              'ASSEMBLY',x_quantity_ordered,
              'RESOURCE',x_quantity_ordered /
                          decode(wor.usage_rate_or_amount,
                                   0,x_quantity_ordered,
                                     wor.usage_rate_or_amount)
              ),
       decode(x_outside_op_uom_type,
              'ASSEMBLY', x_quantity_ordered
                                        * wor.usage_rate_or_amount,
              'RESOURCE', x_quantity_ordered)
INTO x_usage_rate_or_amount,
     x_assembly_quantity,
     x_resource_quantity
FROM wip_operation_resources wor
WHERE wor.wip_entity_id       = x_entity_id
AND  nvl(wor.repetitive_schedule_id,-1) =
                    nvl(x_wip_repetitive_schedule_id,-1)
AND wor.operation_seq_num = x_wip_operation_seq_num
AND wor.resource_seq_num  = x_wip_resource_seq_num
AND wor.organization_id   = x_dest_org_id;


  RETURN;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
   RETURN;

   WHEN OTHERS THEN
      po_message_s.sql_error('calc_assy_res_qty', x_progress, sqlcode);
   RAISE;

END calc_assy_res_qty;

/*===========================================================================

   PROCEDURE NAME:	get_unit_type()

===========================================================================*/

PROCEDURE get_unit_type (x_op_uom_type_dsp          IN     VARCHAR2,
                         x_op_uom_type      IN OUT NOCOPY VARCHAR2) IS



x_progress VARCHAR2(3) := NULL;


BEGIN

  x_progress := 10;

  SELECT displayed_field
  INTO   x_op_uom_type
  FROM   po_lookup_codes
  WHERE  lookup_type  = 'OUTSIDE OPERATION UOM TYPE'
  AND    lookup_code  = x_op_uom_type_dsp;

  RETURN;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
    RETURN;

   WHEN OTHERS THEN
      po_message_s.sql_error('get_unit_type', x_progress, sqlcode);
   RAISE;

END get_unit_type;


/*===========================================================================

  PROCEDURE NAME:	test_get_unit_type()

===========================================================================*/

PROCEDURE test_get_unit_type (x_op_uom_type_dsp      IN     VARCHAR2) IS




x_progress VARCHAR2(3) := NULL;
x_op_uom_type VARCHAR2(15);


BEGIN


   --DBMS_OUTPUT.PUT_LINE('x_op_uom_type_dsp = ' || x_op_uom_type_dsp );


   outside_proc_sv.get_unit_type(x_op_uom_type_dsp, x_op_uom_type );



    --DBMS_OUTPUT.PUT_LINE('x_op_uom_type = ' || x_op_uom_type);


    RETURN;

    EXCEPTION
    WHEN OTHERS THEN
    po_message_s.sql_error('test_get_unit_type', x_progress, sqlcode);
    RAISE;


end test_get_unit_type;


procedure get_project_task_num(x_project_id    IN     NUMBER,
                               x_task_id       IN     NUMBER,
                               x_project       IN OUT NOCOPY VARCHAR2,
                               x_task          IN OUT NOCOPY VARCHAR2) is
x_progress varchar2(3);
BEGIN

    x_progress := '020';
   if x_project_id is not null then
       select project_number
       into x_project
       from pjm_projects_all_ou_v           --< Bug 3265539 >
       where project_id = x_project_id;
    end if;

     x_progress := '030';
     if x_task_id is not null then
      select task_number
      into x_task
      from pa_tasks                         --< Bug 3265539 >
      where task_id = x_task_id and
      project_id = x_project_id;
     end if;

    x_progress := '040';

 EXCEPTION
    WHEN OTHERS THEN
    po_message_s.sql_error('get_project_task_num', x_progress, sqlcode);
END;


/*===========================================================================

  FUNCTION NAME:       prj_id_to_num()

===========================================================================*/

FUNCTION prj_id_to_num (X_project_id    IN    NUMBER) RETURN VARCHAR2 IS


   L_project_num           varchar2(30);

   cursor C1 is

      select segment1
      from   pa_projects_all
      where  project_id = X_project_id
      union
      select project_number
      from   pjm_seiban_numbers
      where  project_id = X_project_id;

BEGIN

   if X_project_id is null then
      return null;
   end if;

   open C1;
   fetch C1 into L_project_num;
   close C1;

   return L_project_num;

END prj_id_to_num;


END outside_proc_sv;


/
