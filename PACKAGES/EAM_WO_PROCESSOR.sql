--------------------------------------------------------
--  DDL for Package EAM_WO_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: EAMWOPRS.pls 115.4 2002/11/20 22:30:00 aan ship $ */

  G_SUCCESS                       CONSTANT NUMBER := 0;
  G_WARNING                       CONSTANT NUMBER := 1;
  G_ERROR                         CONSTANT NUMBER := 2;


  procedure schedule(
              errbuf       	out NOCOPY varchar2,
              retcode      	out NOCOPY number,
              p_wip_entity_id 	in number,
              p_status_type 	in number,
              p_group_id        in number,
              p_org_id          in number);


END eam_wo_processor;

 

/
