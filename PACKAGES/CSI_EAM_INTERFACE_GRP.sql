--------------------------------------------------------
--  DDL for Package CSI_EAM_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_EAM_INTERFACE_GRP" AUTHID CURRENT_USER AS
/* $Header: csigeams.pls 120.0 2005/06/17 14:56:34 brmanesh noship $ */

  g_pkg_name                constant varchar2(30) := 'csi_eam_interface_grp';

  PROCEDURE wip_completion(
    p_wip_entity_id   IN  number,
    p_organization_id IN  number,
    x_return_status   OUT nocopy varchar2,
    x_error_message   OUT nocopy varchar2);

  PROCEDURE rebuildable_return(
    p_wip_entity_id   IN  number,
    p_organization_id IN  number,
    p_instance_id     IN  number,
    x_return_status   OUT nocopy varchar2,
    x_error_message   OUT nocopy varchar2);

END csi_eam_interface_grp;

 

/
