--------------------------------------------------------
--  DDL for Package Body BOM_RTG_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_VALIDATE" AS
/* $Header: BOMRVATB.pls 115.4 2003/02/13 12:18:44 djebar ship $ */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRVATB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Rtg_Validate
--
--  NOTES
--
--  HISTORY
--  02-AUG-2000 Biao Zhang      Initial Creation
--
--
****************************************************************************/
        G_PKG_NAME      CONSTANT VARCHAR2(30) := 'Rtg_Validate';

        /********************************************************************
        * Function      : Alternate_Designator
        * Returns       : Boolean
        * Parameters IN : Alternate_bom_code
        *                 Organization_id
        * Parameters OUT: None
        * Purpose       : Function will verify if the alternate bom
        *                 designator exits. If it does then the function wil
        *                 return a TRUE otherwise a FALSE.
        *********************************************************************/
 FUNCTION Alternate_Designator(   p_alternate_routing_code    IN  VARCHAR2
                                , p_organization_id           IN  NUMBER
                                      ) RETURN BOOLEAN
 IS
   l_dummy NUMBER;

 BEGIN
                SELECT 1
                  INTO l_dummy
                  FROM bom_alternate_designators
                 WHERE alternate_designator_code = p_alternate_routing_code
                   AND organization_id          = p_organization_id;

                RETURN TRUE;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN FALSE;

 END Alternate_Designator;



        /********************************************************************
        * Function      : Get_Flow_Routing_Flag
        * Parameters IN : Routing_Sequence_ID
        * Parameters OUT: None
        * Purpose       : Function will select flow routing flag
        *                 If it does then the function will
        *                 return 1, 2, 3, otherwise return 0.
        *********************************************************************/

 FUNCTION Get_Flow_Routing_Flag( p_routing_sequence_id       IN NUMBER
                              ) RETURN  NUMBER
 IS
   l_dummy NUMBER;

 BEGIN
                SELECT nvl(cfm_routing_flag,2)
                INTO l_dummy
                FROM bom_operational_routings
                WHERE routing_sequence_id = p_routing_sequence_id;

                BOM_Rtg_Globals.Set_CFM_Rtg_Flag(l_dummy);

                RETURN l_dummy;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN 0;

 END Get_Flow_Routing_Flag;

        /********************************************************************
        * Function      : Exist_In_Op_Resour
        * Parameters IN : substitute_group_number
        *                 operation_sequence_id
        * Parameters OUT: None
        * Purpose       : Function will test if particular
        *                 Operation Resource has sub group number
        *********************************************************************/

FUNCTION  Group_Num_exist_In_Op_Res( p_substitute_group_number     IN  NUMBER
                                   , p_operation_sequence_id       IN  NUMBER
                                      )
           RETURN BOOLEAN
 IS
 l_dummy NUMBER;
 BEGIN
           SELECT 1 into l_dummy
           FROM  DUAL
           WHERE EXISTS (
           SELECT 1
           FROM bom_operation_resources
           WHERE operation_sequence_id = p_operation_sequence_id
           AND   substitute_group_num = p_substitute_group_number);

           RETURN TRUE;

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
           RETURN FALSE;

 END Group_num_exist_In_Op_Res;


FUNCTION  Sub_Res_Exist_In_Op_Res( p_substitute_resource_code  IN  NUMBER
                                 , p_organization_id           IN  NUMBER
                                      ) RETURN BOOLEAN
 IS
 l_dummy NUMBER;
  BEGIN

           SELECT 1 into l_dummy
           FROM  DUAL
           WHERE EXISTS (
           SELECT 1
           FROM bom_resources
           WHERE organization_id = p_organization_id
           AND   resource_code = p_substitute_resource_code);

           RETURN TRUE;

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
           RETURN FALSE;

 END  Sub_Res_Exist_In_Op_Res;


END  BOM_Rtg_Validate;

/
