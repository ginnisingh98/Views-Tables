--------------------------------------------------------
--  DDL for Package EAM_SKILL_INSTANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SKILL_INSTANCE" AUTHID CURRENT_USER AS
/* $Header: EAMSKILS.pls 115.6 2002/11/20 22:31:42 aan ship $ */


  /**
   * This procedure is used to assign an instance to the resource
   */
  procedure insert_instance(p_wip_entity_id     in number,
                            p_operation_seq_num in number,
                            p_resource_seq_num  in number,
                            p_organization_id   in number,
                            p_user_id           in number,
                            p_instance_id       in number,
                            p_start_date        in date,
                            p_completion_date   in date,
                            p_assigned_units_updated out NOCOPY number);


  /**
   * This function is used to check the duplicate instance assignment
   */
  function is_duplicate_instance(p_wip_entity_id      in number,
                                  p_operation_seq_num in number,
                                  p_resource_seq_num  in number,
                                  p_organization_id   in number,
                                  p_instance_id       in number) return boolean;

  /**
   * This procedure is used to check the number of assigned units and
   * increment it if necessary
   */
  procedure check_assigned_units(p_wip_entity_id      in number,
                                  p_operation_seq_num in number,
                                  p_resource_seq_num  in number,
                                  p_organization_id   in number,
                                  p_assigned_changed  out NOCOPY number);

  /**
   * This procedure is used to firm the work order after assigning an instance
   * to the work order
   */
  procedure firm_work_order(p_wip_entity_id     in number,
                            p_organization_id   in number);

  /**
   * This procedure is used to remove an assigned instance from
   * the resource
   */
  procedure remove_instance(p_wip_entity_id     in number,
                            p_operation_seq_num in number,
                            p_resource_seq_num  in number,
                            p_instance_id       in number);


END EAM_SKILL_INSTANCE;

 

/
