--------------------------------------------------------
--  DDL for Package WIP_MATERIAL_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MATERIAL_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: wipmatps.pls 115.5 2002/11/28 19:44:15 rmahidha noship $ */
  PROCEDURE processItem(p_header_id IN  NUMBER,
                        x_err_msg    OUT NOCOPY VARCHAR2,
                        x_return_status   OUT NOCOPY VARCHAR2);
END wip_material_processor;

 

/
