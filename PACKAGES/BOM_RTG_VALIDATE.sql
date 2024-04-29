--------------------------------------------------------
--  DDL for Package BOM_RTG_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: BOMRVATS.pls 115.3 2002/12/04 03:07:36 lnarveka ship $ */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRVATS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Rtg_Validate
--
--  NOTES
--
--  HISTORY
--
--  02-AUG-2000   Biao Zhang    Initial Creation
--
****************************************************************************/
FUNCTION Alternate_Designator(   p_alternate_routing_code    IN  VARCHAR2
                               , p_organization_id           IN  NUMBER
                                      ) RETURN BOOLEAN;

Function Get_Flow_Routing_Flag( p_routing_sequence_id       IN NUMBER
                              ) RETURN  NUMBER;

FUNCTION  Group_Num_exist_In_Op_Res( p_substitute_group_number     IN  NUMBER
                                   , p_operation_sequence_id       IN  NUMBER
                                      ) RETURN BOOLEAN;

FUNCTION  Sub_Res_Exist_In_Op_Res( p_substitute_resource_code  IN  NUMBER
                                     , p_organization_id       IN  NUMBER
                                      ) RETURN BOOLEAN;

END BOM_Rtg_Validate;



 

/
