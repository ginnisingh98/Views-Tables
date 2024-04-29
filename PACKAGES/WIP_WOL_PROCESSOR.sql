--------------------------------------------------------
--  DDL for Package WIP_WOL_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WOL_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: wipwolps.pls 115.5 2002/11/29 14:22:27 rmahidha noship $ */

  PROCEDURE completeAssyItem(p_header_id IN  NUMBER,
                            x_err_msg    OUT NOCOPY VARCHAR2,
                            x_return_status   OUT NOCOPY VARCHAR2);
END wip_wol_processor;

 

/
