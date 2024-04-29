--------------------------------------------------------
--  DDL for Package Body BOM_RTG_VAL_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_VAL_TO_ID" AS
/* $Header: BOMRVIDB.pls 120.1 2005/11/16 22:58:12 bbpatel noship $*/
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRVIDB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_RTG_Val_To_Id
--
--  NOTES
--
--  HISTORY
--
--  04-AUG-00   Biao Zhang          Initial Creation
--  07-SEP-00   Masanori Kimizuka   Modified to support ECO for Routing
--
****************************************************************************/
        G_Pkg_Name      VARCHAR2(30) := 'RTG_Val_To_Id';
        g_token_tbl     Error_Handler.Token_Tbl_Type;


        /********************************************************************
        * Function      : Organization
        * Returns       : NUMBER
        * Purpose       : Will convert the value of organization_code to
        *                 organization_id using MTL_PARAMETERS.
        *                 If the conversion fails then the function will return
        *                 a NULL otherwise will return the org_id.
        *                 For an unexpected error function will return a
        *                 missing value.
        *********************************************************************/
        FUNCTION Organization
                 (  p_organization IN VARCHAR2
                  , x_err_text     IN OUT NOCOPY VARCHAR2) RETURN NUMBER
        IS
                l_id                          NUMBER;
                ret_code                      NUMBER;
                l_err_text                    VARCHAR2(2000);
        BEGIN
                SELECT  organization_id
                INTO    l_id
                FROM    mtl_parameters
                WHERE   organization_code = p_organization;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

        END Organization;


        /**********************************************************************
        * Function      : Revised_Item
        * Parameters IN : Revised Item Name
        *                 Organization ID
        * Parameters OUT: Error_Text
        * Returns       : Revised Item Id
        * Purpose       : This function will get the ID for the revised item and
        *                 return the ID. If the revised item is invalid then the
        *                 ID will returned as NULL.
        **********************************************************************/
        FUNCTION Revised_Item(  p_revised_item_num IN VARCHAR2,
                                p_organization_id IN NUMBER,
                                x_err_text IN OUT NOCOPY VARCHAR2 )
        RETURN NUMBER
        IS
                l_id                          NUMBER;
                ret_code                      NUMBER;
                l_err_text                    VARCHAR2(2000);
        BEGIN

             /* Bug 4040340. Using mtl_system_items_b_kfv to get the item id
                ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                        org_id => p_organization_id,
                        flex_code => 'MSTK',
                        flex_name => p_revised_item_num,
                        flex_id => l_id,
                        set_id => -1,
                        err_text => x_err_text);

                IF (ret_code <> 0) THEN
                        RETURN NULL;
                ELSE
                        RETURN l_id;
                END IF;*/

        SELECT  inventory_item_id
                INTO    l_id
                FROM    mtl_system_items_b_kfv
                WHERE   organization_id = p_organization_id
		and     concatenated_segments = p_revised_item_num;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

        END Revised_Item;


        /********************************************************************
        * Function      : Assembly_Item
        * Returns       : Number
        * Parameters IN : Assembly Item Name
        *                 Organization_Id
        * Purpose       : This function will get ID for the assembly item and
        *                 return the ID. If the assembly item is invalid then
        *                 ID will returned as NULL.
        *********************************************************************/
        FUNCTION Assembly_Item
        (  p_assembly_item_name IN VARCHAR2
         , p_organization_id    IN NUMBER
         , x_err_text           IN OUT NOCOPY VARCHAR2) RETURN NUMBER
        IS
        BEGIN
                RETURN Bom_Rtg_Val_To_Id.Revised_Item
                       (  p_revised_item_num    => p_assembly_item_name
                        , p_organization_id     => p_organization_id
                        , x_err_text            => x_err_text
                        );

        END Assembly_Item;

        /*******************************************************************
        * Function      : Common_Assembly_Item_Id
        * Parameters IN : Common_assembly_item_name
        *                 Organization ID
        * Parameters OUT: Error Message
        * Returns       : Component_Item_Id
        * Purpose       : Function will convert the common assembly item name
        *                 to its correspondent  ID and return the value.
        *                 If the component is invalid, then a NULL is returned.
        *********************************************************************/
        FUNCTION COMMON_ASSEMBLY_ITEM_ID
                 ( p_organization_id           IN NUMBER,
                   p_common_assembly_item_name IN VARCHAR2,
                   x_err_text                  IN OUT NOCOPY VARCHAR2)

        RETURN NUMBER
        IS
                l_id                          NUMBER;
                ret_code                      NUMBER;
        BEGIN

                RETURN Bom_Rtg_Val_To_Id.Revised_Item
                       (  p_revised_item_num    => p_common_assembly_item_name
                        , p_organization_id     => p_organization_id
                        , x_err_text            => x_err_text
                        );

        END COMMON_ASSEMBLY_ITEM_ID;

         /********************************************************************
        * Function      : Routing_Sequence_id
        * Returns       : Number
        * Parameters IN : Assemby_Item_Id
        *                 Organization_Id
        *                 Alternate_routing_Code
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 routing sequence_id and return a NULL if an error
        *                 occured or the routing sequence_id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Routing_Sequence_id
                (  p_assembly_item_id           IN  NUMBER
                 , p_organization_id            IN  NUMBER
                 , p_alternate_routing_designator IN VARCHAR2
                 , x_err_text                   IN OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER
        IS
                l_id                          NUMBER;
                l_cfm_flag                    NUMBER;
                l_com_rtg_seq_id              NUMBER;
                ret_code                      NUMBER;
                l_err_text                    VARCHAR2(2000);

        BEGIN
                SELECT  routing_sequence_id
                      , cfm_routing_flag
                      , common_routing_sequence_id
                INTO    l_id, l_cfm_flag, l_com_rtg_seq_id
                FROM    bom_operational_routings
                WHERE   organization_id = p_organization_id
                AND     assembly_item_id = p_assembly_item_id
                AND     NVL(alternate_routing_designator, FND_API.G_MISS_CHAR) =
                            NVL(p_alternate_routing_designator, FND_API.G_MISS_CHAR);

                BOM_Rtg_Globals.Set_CFM_Rtg_Flag(p_cfm_rtg_type => l_cfm_flag) ;
                BOM_Rtg_Globals.Set_Common_Rtg_Seq_id
                     ( p_common_Rtg_seq_id => l_com_rtg_seq_id );

                RETURN l_id;


                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

        END Routing_Sequence_id ;

        /********************************************************************
        * Function      : Common_Routing_Sequence_id
        * Returns       : Number
        * Parameters IN : Common_Assemby_Item_Id
        *                 Organization_Id
        *                 Alternate_routing_Code
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 common routing sequence_id and return a NULL if an
        *                 error occured or the routing sequence_id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Common_Routing_Sequence_id
                (  p_common_assembly_item_id           IN  NUMBER
                 , p_organization_id                   IN  NUMBER
                 , p_alternate_routing_designator      IN VARCHAR2
                 , x_err_text                          IN OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER
        IS
        l_common_rtg_seq_id NUMBER;
        BEGIN
                l_common_rtg_seq_id := Bom_Rtg_Val_To_Id.Routing_Sequence_id
                (  p_assembly_item_id => p_common_assembly_item_id
                 , p_organization_id  => p_organization_id
                 , p_alternate_routing_designator => p_alternate_routing_designator
                 , x_err_text         =>  x_err_text
                 ) ;

                BOM_Rtg_Globals.Set_Common_Rtg_Seq_id
                     ( p_common_Rtg_seq_id => l_common_rtg_seq_id );
                RETURN l_common_rtg_seq_id;
        END Common_Routing_Sequence_id;



        /*************************************************************
        * Function      : RtgAndRevItemSeq
        * Parameters IN : Revised Item Unique Key information
        * Parameters OUT: Routing Sequence ID
        * Returns       : Revised Item Sequence
        * Purpose       : Will use the revised item information to find the bill
        *                 sequence and the revised item sequence.
        * History       : Added p_new_routing_revsion and
        *                 p_from_end_item_number in argument by MK
        *                 on 11/02/00
        * Comment Out to resolve ECO depencency and move to ENGSVIDB.pls
        * by MK on 12/04/00
        *
        FUNCTION  RtgAndRevItemSeq(  p_revised_item_id         IN  NUMBER
                                   , p_item_revision           IN  VARCHAR2
                                   , p_effective_date          IN  DATE
                                   , p_change_notice           IN  VARCHAR2
                                   , p_organization_id         IN  NUMBER
                                   , p_new_routing_revision    IN  VARCHAR2
                                   , p_from_end_item_number    IN  VARCHAR2 := NULL
                                   , x_routing_sequence_id     IN OUT NOCOPY NUMBER
                                   )
        RETURN NUMBER
        IS
                l_Rev_Item_Seq  NUMBER;
        BEGIN
                -- Modified by MK on 11/02/00
                SELECT routing_sequence_id, revised_item_Sequence_id
                INTO x_routing_sequence_id, l_Rev_Item_Seq
                FROM eng_revised_items
                WHERE NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                  = NVL(p_from_end_item_number, FND_API.G_MISS_CHAR)
                  AND NVL(new_routing_revision, FND_API.G_MISS_CHAR) =
                             NVL(p_new_routing_revision, FND_API.G_MISS_CHAR)
                  AND NVL(new_item_revision,FND_API.G_MISS_CHAR)= NVL(p_item_revision,FND_API.G_MISS_CHAR)
                  AND scheduled_date		 = p_effective_date
--                  AND TRUNC(scheduled_date)      = TRUNC(p_effective_date)  -- time
                  AND change_notice              = p_change_notice
                  AND organization_id            = p_organization_id
                  AND revised_item_id            = p_revised_item_id ;

                RETURN l_Rev_Item_Seq;

        EXCEPTION
            WHEN OTHERS THEN
                        x_routing_sequence_id := NULL;
                        RETURN NULL;
        END RtgAndRevItemSeq;

        **************************************************************/

        /********************************************************************
        * Function      : Completion_Locator_id
        * Returns       : Number
        * Parameters IN : Completion_Name
        *                 Organization_Id
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 Completion Locator ID return a NULL if an error
        *                 occured or the completion id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Completion_locator_id
        (  p_completion_location_name IN VARCHAR2
         , p_organization_id IN NUMBER
         , x_err_text           IN OUT NOCOPY VARCHAR2) RETURN NUMBER
        IS
                supply_locator_id       NUMBER;
                ret_code                NUMBER;
                l_err_text              VARCHAR2(240);
        BEGIN
                /* Bug 4040340. Using mtl_item_locations_kfv to get the locator id.
                ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                                org_id => p_organization_id,
                                flex_code => 'MTLL',
                                flex_name => p_completion_location_name,
                                flex_id => supply_locator_id,
                                set_id => -1,
                                err_text => l_err_text);

                IF (ret_code <> 0) THEN
                        RETURN NULL;
                ELSE
                        RETURN supply_locator_id;
                END IF; */

                SELECT inventory_location_id
                INTO   supply_locator_id
                FROM   mtl_item_locations_kfv
                WHERE  organization_id  = p_organization_id
                and    concatenated_segments = p_completion_location_name;

                RETURN supply_locator_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

        END Completion_locator_id;

        /********************************************************************
        * Function      : Line_Id
        * Returns       : Number
        * Parameters IN : line_code
        *                 Organization_Id
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 line id and return a NULL if an error
        *                 occured or the line id could not be obtained.
        ********************************************************************/
        FUNCTION Line_Id
        (  p_line_code                    IN VARCHAR2
         , p_organization_id              IN NUMBER
         , x_err_text                     IN OUT NOCOPY VARCHAR2
        )
        RETURN NUMBER
        IS
                l_id                          NUMBER;
                ret_code                      NUMBER;
                l_err_text                    VARCHAR2(2000);

        BEGIN
                SELECT  line_id
                INTO    l_id
                FROM    wip_lines
                WHERE   organization_id = p_organization_id
                AND     line_code = p_line_code;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;
         END Line_Id;

        /********************************************************************
        * Function      : Standard_Operation_id for ECO BO
        * Returns       : Number
        * Parameters IN : operation_type_code
        *                 standard_operation_code
        *                 Organization_Id
        *                 Line_Id
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 Standard operation id and return a NULL if an error
        *                 occured or the standard operation id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Standard_Operation_Id
        (  p_operation_type          IN NUMBER
         , p_standard_operation_code IN VARCHAR2
         , p_organization_id         IN NUMBER
         , p_rev_item_sequence_id    IN NUMBER
         , x_err_text                IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER
        IS
                l_id                          NUMBER;
                ret_code                      NUMBER;
                l_err_text                    VARCHAR2(2000);

        BEGIN

                SELECT  standard_operation_id
                INTO    l_id
                FROM    bom_standard_operations  bso
                --      , eng_revised_items        eri
                WHERE   NVL(bso.operation_type, 1)
                                        = DECODE(p_operation_type, FND_API.G_MISS_NUM, 1
                                                 , NVL(p_operation_type, 1 ) )
                -- AND     NVL(bso.line_id, FND_API.G_MISS_NUM)
                --                      = NVL(eri.line_id, FND_API.G_MISS_NUM)
                -- AND     eri.revised_item_sequence_id =  p_rev_item_sequence_id
                AND     NVL(bso.line_id, FND_API.G_MISS_NUM ) = FND_API.G_MISS_NUM
                AND     bso.organization_id = p_organization_id
                AND     bso.operation_code = p_standard_operation_code ;


                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;
         END  Standard_Operation_Id;


        /********************************************************************
        * Function      : Standard_Operation_Id
        * Returns       : Number
        * Parameters IN : operation_type_code
        *                 standard_operation_code
        *                 Organization_Id
        *                 Line_Id
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 Standard operation id and return a NULL if an error
        *                 occured or the standard operation id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Standard_Operation_Id
        (  p_operation_type          IN NUMBER
         , p_standard_operation_code IN VARCHAR2
         , p_organization_id         IN NUMBER
         , p_routing_sequence_id     IN NUMBER
         , x_err_text                IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER
        IS
                l_id                          NUMBER;
                ret_code                      NUMBER;
                l_err_text                    VARCHAR2(2000);

        BEGIN

                SELECT  standard_operation_id
                INTO    l_id
                FROM    bom_standard_operations  bso
                      , bom_operational_routings bor
                WHERE   NVL(bso.operation_type,1 )
                               = DECODE(p_operation_type, FND_API.G_MISS_NUM, 1
                                        , NVL(p_operation_type, 1))
                AND     NVL(bso.line_id, FND_API.G_MISS_NUM)
                               = NVL(bor.line_id, FND_API.G_MISS_NUM)
                AND     bor.routing_sequence_id = p_routing_sequence_id
                AND     bso.organization_id = p_organization_id
                AND     bso.operation_code = p_standard_operation_code ;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;
         END  Standard_Operation_Id;

        /********************************************************************
        * Function      : Department id
        * Returns       : Number
        * Parameters IN : department_code
        *                 Organization_Id
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 department id and return a NULL if an error
        *                 occured or the department id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Department_Id
        (  p_department_code IN VARCHAR2
         , p_organization_id IN NUMBER
         , x_err_text           IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER
        IS
        l_id NUMBER;
        BEGIN
                SELECT  department_id
                INTO    l_id
                FROM    bom_departments
                WHERE   organization_id = p_organization_id
                AND     department_code = p_department_code;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;
         END  Department_Id;

        /********************************************************************
        * Function      : Process_Op_Seq_Id
        * Returns       : Number
        * Parameters IN : Process_code
        *                 Process_seq_number
        *                 Alternate_routing_Code
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 process operation id and return a NULL if an error
        *                 occured or the process operation id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Process_Op_Seq_Id
        (  p_process_code       IN  VARCHAR2
         , p_organization_id    IN  NUMBER
         , p_process_seq_number IN  NUMBER
         , p_routing_sequence_id IN  NUMBER
         , x_err_text           IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER
         IS
         l_id NUMBER;
         BEGIN
		IF p_process_code IS NULL THEN -- Added for bug 2758481
			SELECT bos.operation_sequence_id
			INTO l_id
			FROM BOM_OPERATION_SEQUENCES  bos
			   , BOM_OPERATIONAL_ROUTINGS bor
			   , BOM_STANDARD_OPERATIONS  bso
			WHERE bso.organization_id     = p_organization_id
			AND bso.standard_operation_id = bos.standard_operation_id
			AND bos.operation_seq_num     = p_process_seq_number
			AND bos.operation_type        = 2  -- Operation Type : Process
			AND bos.routing_sequence_id   = bor.common_routing_sequence_id
			AND bor.routing_sequence_id   = p_routing_sequence_id  ;
		ELSE
			SELECT  bos.operation_sequence_id
			INTO    l_id
			FROM    BOM_OPERATION_SEQUENCES  bos
			      , BOM_OPERATIONAL_ROUTINGS bor
			      , BOM_STANDARD_OPERATIONS  bso
			WHERE  bso.operation_code        = p_process_code
			AND    bso.organization_id       = p_organization_id
			AND    bso.standard_operation_id = bos.standard_operation_id
			AND    bos.operation_seq_num     = p_process_seq_number
			AND    bos.operation_type        = 2  -- Operation Type : Process
			AND    bos.routing_sequence_id   = bor.common_routing_sequence_id
			AND    bor.routing_sequence_id   = p_routing_sequence_id  ;
		END IF;

                RETURN l_id;

         EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

         END Process_Op_Seq_Id;

        /********************************************************************
        * Function      : Line_Op_Seq_Id
        * Returns       : Number
        * Parameters IN : line_op_code
        *                 line_seq_number
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 line operation sequence id and d return a NULL if
        *                 an error oocured or the routing sequence_id could
        *                 not be obtained.
        ********************************************************************/
       FUNCTION Line_Op_Seq_Id
        (  p_line_code           IN  VARCHAR2
         , p_organization_id     IN  NUMBER
         , p_line_seq_number     IN  NUMBER
         , p_routing_sequence_id IN  NUMBER
         , x_err_text            IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER
        IS
        l_id NUMBER;
        BEGIN

/*
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('In Line Op Seq Id. . .');
    Error_Handler.Write_Debug('Line OP Code '|| p_line_code );
    Error_Handler.Write_Debug('Line OP Seq  ' || to_char(p_line_seq_number ));
    Error_Handler.Write_Debug('Org Id ' || to_char(p_organization_id) );
    Error_Handler.Write_Debug('Rtg Id ' || to_char(p_routing_sequence_id) );
END IF;
*/

		IF p_line_code IS NULL THEN -- Added for bug 2758481
			SELECT bos.operation_sequence_id
			INTO l_id
			FROM BOM_OPERATION_SEQUENCES  bos
			   , BOM_OPERATIONAL_ROUTINGS bor
			   , BOM_STANDARD_OPERATIONS  bso
			WHERE bso.organization_id     = p_organization_id
			AND bso.standard_operation_id = bos.standard_operation_id
			AND bos.operation_seq_num     = p_line_seq_number
			AND bos.operation_type        = 3  -- Operation Type : Line Op
			AND bos.routing_sequence_id   = bor.common_routing_sequence_id
			AND bor.routing_sequence_id   = p_routing_sequence_id  ;
		ELSE
			SELECT  bos.operation_sequence_id
			INTO    l_id
			FROM    BOM_OPERATION_SEQUENCES  bos
			      , BOM_OPERATIONAL_ROUTINGS bor
			      , BOM_STANDARD_OPERATIONS  bso
			WHERE  bso.operation_code	 = p_line_code
			AND    bso.organization_id	 = p_organization_id
			AND    bso.standard_operation_id = bos.standard_operation_id
			AND    bos.operation_seq_num     = p_line_seq_number
			AND    bos.operation_type        = 3 -- Operation Type : Line Op
			AND    bos.routing_sequence_id   = bor.common_routing_sequence_id
			AND    bor.routing_sequence_id   = p_routing_sequence_id  ;
		END IF;

/*
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Line Op Seq Id : '|| to_char(l_id) );
END IF ;
*/
                RETURN l_id;

         EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

         END Line_Op_Seq_Id;



        /**************************************************************************
        * Function      : Old_Operation_Sequence
        * Returns       : NUMBER
        * Purpose       : Using the input parameters the function will retrieve the
        *                 old operation sequence id of the operation and return.
        *                 If the function fails to find a record then it will return
        *                 a NULL value. In case of an unexpected error the function
        *                 will return a missing value.
        ****************************************************************************/
        FUNCTION Old_Operation_Sequence
                    (  p_old_effective_date    IN  DATE
                     , p_old_op_seq_num        IN  NUMBER
                     , p_operation_type        IN  NUMBER
                     , p_routing_sequence_id   IN  NUMBER
                    )

        RETURN NUMBER
        IS
                l_id                          NUMBER;
        BEGIN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
        Error_Handler.Write_Debug('Old Operation: ' || to_char(p_old_op_seq_num));
        Error_Handler.Write_Debug('Routing Sequence: ' || to_char(p_routing_sequence_id));
        Error_Handler.Write_Debug('Old Effective: ' || to_char(p_old_effective_date));
END IF;

                SELECT  operation_sequence_id
                INTO  l_id
                FROM  BOM_OPERATION_SEQUENCES
                WHERE  NVL(operation_type, 1) = DECODE(p_operation_type,
                                                       FND_API.G_MISS_NUM, 1,
                                                       NVL(p_operation_type, 1)
                                                       )
                  AND  routing_sequence_id    = p_routing_sequence_id
                  AND  effectivity_date = p_old_effective_date  -- Changed for bug 2647027
-- /** time **/   AND  TRUNC(effectivity_date) = TRUNC(p_old_effective_date)
                  AND  operation_seq_num      = p_old_op_seq_num;


                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

        END Old_Operation_Sequence;


        /********************************************************************
        * Function      : Setup_Id
        * Returns       : Number
        * Parameters IN : Setup_Type
        *                 Organization_Id
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 setup id  return a NULL if an error
        *                 occured or the setup id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Setup_Id
        (  p_setup_type      IN VARCHAR2
         , p_organization_id IN NUMBER
         , x_err_text        IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER
        IS
        l_id NUMBER;
        BEGIN
                SELECT  setup_id
                INTO    l_id
                FROM    bom_setup_types
                WHERE   organization_id = p_organization_id
                AND     setup_code = p_setup_type ;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

        END  Setup_Id ;


        /********************************************************************
        * Function      : Activity_Id
        * Returns       : Number
        * Parameters IN : Activity
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 activity id  return a NULL if an error
        *                 occured or the activity id could not be
        *                 obtained.
        ********************************************************************/

        FUNCTION Activity_Id
        (  p_activity        IN VARCHAR2
         , p_organization_id IN NUMBER
         , x_err_text        IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER
        IS
        l_id NUMBER;
        BEGIN
                SELECT  activity_id
                INTO    l_id
                FROM    cst_activities
                WHERE   NVL(organization_id, p_organization_id )  = p_organization_id
                AND     activity = p_activity;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

        END  Activity_Id;

        /********************************************************************
        * Function      : Resource_Id
        * Returns       : Number
        * Parameters IN : organization_id
        *                 resource_code
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 resouce id and return a NULL if an error
        *                 occured or the resorce id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Resource_Id
        (  p_resource_code      IN  VARCHAR2
         , p_organization_id    IN  NUMBER
         , x_err_text           IN OUT NOCOPY VARCHAR2
         ) RETURN NUMBER
        IS
          l_id NUMBER;

         BEGIN
                SELECT  resource_id
                INTO    l_id
                FROM    bom_resources
                WHERE  organization_id = p_organization_id
                AND    resource_code   = p_resource_code;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

        END resource_id;

       /********************************************************************
        * Function      : Operation_Sequence_Id
        * Returns       : Number
        * Parameters IN : routing_sequence_id
        *                 operation_type
        *                 operation_seq_num
        *                 effectivity_date
        * Parameters OUT: Error Text
        * Purpose       : Function will use the input parameters to find the
        *                 Operation_Sequecne_Id and return a NULL if an error
        *                 occured or the resorce id could not be
        *                 obtained.
        ********************************************************************/
        FUNCTION Operation_Sequence_Id
        (  p_routing_sequence_id   IN  NUMBER
         , p_operation_type        IN  NUMBER
         , p_operation_seq_num     IN  NUMBER
         , p_effectivity_date      IN  DATE
         , x_err_text              IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER
        IS
           l_id      NUMBER;
           l_bo_id   VARCHAR2(3) ;

        BEGIN
                l_bo_id := BOM_Rtg_Globals.Get_Bo_Identifier ;

                SELECT  operation_sequence_id
                INTO    l_id
                FROM    bom_operation_sequences
                WHERE    ((  l_bo_id = BOM_Rtg_Globals.G_ECO_BO
                             AND implementation_date IS NULL )
                         OR (l_bo_id = BOM_Rtg_Globals.G_RTG_BO
                             AND implementation_date IS NOT NULL )
                          )
-- NVL check in operation type included for bug 3293381
                AND     (( NVL(operation_type, 1) = 1 AND
                           effectivity_date = p_effectivity_date)  -- Changed for bug 2647027
-- /** time **/            TRUNC(effectivity_date) = TRUNC(p_effectivity_date))
                          OR p_operation_type IN (2, 3)
                        )
                AND     NVL(operation_type, 1 )  = DECODE(p_operation_type,
                                                          FND_API.G_MISS_NUM, 1,
                                                          NVL(p_operation_type, 1 ) )
                AND     operation_seq_num = p_operation_seq_num
                AND     routing_sequence_id = p_routing_sequence_id ;

                RETURN l_id;

                EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;

                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;


        END Operation_Sequence_Id;

        /*********************************************************************
        * Procedure     : RTG_Header_UUI_To_UI
        * Returns       : None
        * Parameters IN : Routing header Record
        *                 Routing header Unexposed Record
        * Parameters OUT: Routing header unexposed record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : This procedure will perform all the required
        *                 User unique to Unique index conversions for routing
        *                 header. Any errors will be logged in the Message
        *                 table and a return satus of success or failure will be
        *                 returned to the calling program.
        *********************************************************************/
        PROCEDURE RTG_Header_UUI_To_UI
        (  p_rtg_header_Rec       IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_Rec IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_Return_Status        IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
                l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_rtg_header_unexp_rec  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type;
                l_return_status         VARCHAR2(1);
                l_err_text              VARCHAR2(2000);
--		l_err_text_diff         VARCHAR2(1);

                CURSOR c_Check_Alternate(  p_alt_designator     VARCHAR2,
                                           p_organization_id    NUMBER ) IS
                SELECT 1
                  FROM bom_alternate_designators
                 WHERE alternate_designator_code = p_alt_designator
                   AND organization_id = p_organization_id;

        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_return_status := FND_API.G_RET_STS_SUCCESS;
                l_rtg_header_unexp_rec := p_rtg_header_unexp_rec;


                If Bom_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                     ('Rtg Header UUI-UI Conversion . . ');
                END IF;

                --
                -- Assembly Item name cannot be NULL or missing.
                --
                IF p_rtg_header_rec.assembly_item_name IS NULL OR
                   p_rtg_header_rec.assembly_item_name = FND_API.G_MISS_CHAR
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_RTG_AITEM_NAME_KEYCOL_NULL'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- Assembly item name must be successfully converted to id.
                --

                l_rtg_header_unexp_rec.assembly_item_id :=
                Assembly_Item (  p_assembly_item_name   =>
                                     p_rtg_header_rec.assembly_item_name
                               , p_organization_id       =>
                                     l_rtg_header_unexp_rec.organization_id
                               , x_err_text              => l_err_text
                               );

                IF l_rtg_header_unexp_rec.assembly_item_id IS NULL
                THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_rtg_header_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RTG_AITEM_DOESNOT_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                ELSIF l_err_text IS NOT NULL AND
                  (l_rtg_header_unexp_rec.assembly_item_id IS NULL OR
                   l_rtg_header_unexp_rec.assembly_item_id = FND_API.G_MISS_NUM)
                THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;

                If BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                   ('After converting Assembly Item Id : '
                     || to_char(l_rtg_header_unexp_rec.assembly_item_id)
                     || ' Status ' || l_return_status); END IF;


                IF p_rtg_header_rec.alternate_routing_code IS NOT NULL AND
                   p_rtg_header_rec.alternate_routing_code <> FND_API.G_MISS_CHAR
                THEN
                        l_err_text/*_diff*/ := FND_API.G_RET_STS_ERROR;

                        FOR check_alternate IN
                           c_Check_Alternate
                           ( p_alt_designator  =>
                                    p_rtg_header_rec.alternate_routing_code,
                             p_organization_id =>
                                    l_rtg_header_unexp_rec.organization_id )
                        LOOP
                                l_err_text/*_diff*/ := FND_API.G_RET_STS_SUCCESS;
                        END LOOP;

                        IF l_err_text/*_diff*/ <> FND_API.G_RET_STS_SUCCESS
                        THEN
                          g_token_tbl(1).token_name  :='ALTERNATE_ROUTING_CODE';
                          g_token_tbl(1).token_value :=
                                       p_rtg_header_rec.alternate_routing_code;
                          g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                          g_token_tbl(2).token_value :=
                                       p_rtg_header_rec.organization_code;
                          Error_Handler.Add_Error_Token
                            ( P_Message_Name   => 'BOM_RTG_ALT_DESIGNATOR_INVALID'
                            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , p_token_tbl      => g_token_tbl
                                 );

                            l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                END IF;

                x_return_status := l_return_status;
                x_rtg_header_unexp_rec := l_rtg_header_unexp_rec;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Rtg_Header_UUI_To_UI;


        /*********************************************************************
        * Procedure     : Rtg_Head_Header_VID
        * Returns       : None
        * Parameters IN : RTG Header exposed Record
        *                 RTG  Header Unexposed Record
        * Parameters OUT: RTG Header Unexposed Record
        *                 Return Status
        *                 Message Token Table
        * Purpose       : This is the access procedure which the private API
        *                 will call to perform the RTG Header value to ID
        *                 conversions. If any of the conversions fail then the
        *                 the procedure will return with an error status and
        *                 the messsage token table filled with appropriate
        *                 error message.
        *********************************************************************/
        PROCEDURE Rtg_Header_VID
        (  p_rtg_header_rec        IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_rec  IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_Return_Status         IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
                l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
                l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_err_text              VARCHAR2(2000);
                l_Token_Tbl             Error_Handler.Token_Tbl_Type;
                l_rtg_header_unexp_rec  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
                                        := p_rtg_header_unexp_rec;
        BEGIN

                If BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug('Header VID conversion . . . ');
                END IF;


                IF p_rtg_header_rec.common_assembly_item_name IS NOT NULL AND
                   p_rtg_header_rec.common_assembly_item_name <>
                                                        FND_API.G_MISS_CHAR
                THEN
                        l_rtg_header_unexp_rec.common_assembly_item_id :=
                        Assembly_Item
                        (  p_assembly_item_name => p_rtg_header_rec.common_assembly_item_name
                         , p_organization_id    => l_rtg_header_unexp_rec.organization_id
                         , x_err_text           => l_err_text
                         );

                       IF l_rtg_header_unexp_rec.common_assembly_item_id IS NULL
                       THEN
                                l_token_tbl(1).token_name :=
                                        'COMMON_ASSEMBLY_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                     p_rtg_header_rec.common_assembly_item_name;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                                     'BOM_RTG_COMMON_AITEM_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;

                       ELSIF l_err_text IS NOT NULL AND
                              l_rtg_header_unexp_rec.common_assembly_item_id
                                                IS NULL
                       THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                              'Unexpected Error ' || l_err_text || ' in ' ||
                                               G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );

                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Converted common assembly name . . .');
END IF;

                END IF;


                --
                -- Convert common assembly name information, alternate routing
                -- code and organanization id  into common routing sequence_id
                --
                IF l_rtg_header_unexp_rec.organization_id IS NOT NULL AND
                   l_rtg_header_unexp_rec.organization_id <>FND_API.G_MISS_NUM AND
                   l_rtg_header_unexp_rec.common_assembly_item_id IS NOT NULL AND
                   l_rtg_header_unexp_rec.common_assembly_item_id <> FND_API.G_MISS_NUM
                   -- p_rtg_header_rec.alternate_routing_code IS NOT NULL AND
                   -- p_rtg_header_rec.alternate_routing_code <>FND_API.G_MISS_CHAR
                THEN

                       l_rtg_header_unexp_rec.common_routing_sequence_id :=
                        Routing_Sequence_Id
                        (  p_assembly_item_id   =>
                                l_rtg_header_unexp_rec.common_assembly_item_id
                         , p_organization_id    =>
                                l_rtg_header_unexp_rec.organization_id
                         , p_alternate_routing_designator =>
                                p_rtg_header_rec.alternate_routing_code
                         , x_err_text           => l_err_text
                         );

                        IF l_rtg_header_unexp_rec.common_routing_sequence_id
                           IS NULL
                        THEN
                                --
                                -- Common routing sequence was not found
                                --
                                l_token_tbl.Delete;
                                l_token_tbl(1).token_name :=
                                                'COMMON_ASSEMBLY_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                     p_rtg_header_rec.common_assembly_item_name;
                                l_token_tbl(2).token_name :=
                                                'ALTERNATE_ROUTING_CODE';
                                l_token_tbl(2).token_value :=
                                 p_rtg_header_rec.alternate_routing_code;
                                Error_Handler.Add_Error_Token
                                (  p_message_name       =>
                                        'BOM_RTG_CMN_RTG_SEQ_NOT_FOUND'
                                 , p_token_tbl          => l_token_tbl
                                 , p_mesg_token_tbl     => l_mesg_token_tbl
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                );
                                l_return_status := FND_API.G_RET_STS_ERROR;

                         ELSIF l_err_text IS NOT NULL AND
                              l_rtg_header_unexp_rec.common_routing_sequence_id
                                                IS NULL
                         THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                          END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
     Error_Handler.Write_Debug('Converted common routing sequence id. . .');
END IF ;

                END IF;




                IF p_rtg_header_rec.completion_location_name IS NOT NULL AND
                   p_rtg_header_rec.completion_location_name <>
                                                        FND_API.G_MISS_CHAR
                THEN
                        l_rtg_header_unexp_rec.completion_locator_id :=

                        Completion_locator_id
                        (  p_completion_location_name   =>
                                p_rtg_header_rec.completion_location_name
                         , p_organization_id    =>
                                l_rtg_header_unexp_rec.organization_id
                         , x_err_text           => l_err_text
                         );
                        IF l_rtg_header_unexp_rec.completion_locator_id IS NULL
                        THEN
                                l_token_tbl(1).token_name :=
                                        'ASSEMBLY_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                     p_rtg_header_rec.common_assembly_item_name;
                                l_token_tbl(2).token_name :=
                                        'LOCATION_NAME';
                                l_token_tbl(2).token_value :=
                                     p_rtg_header_rec.completion_location_name;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                               'BOM_RTG_LOCATION_NAME_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                              l_rtg_header_unexp_rec.completion_locator_id
                                                IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y'THEN
      Error_Handler.Write_Debug('Converted completion locator name ...');
END IF;

                END IF;


                IF p_rtg_header_rec.line_code IS NOT NULL AND
                   p_rtg_header_rec.line_code <> FND_API.G_MISS_CHAR
                   --  p_rtg_header_rec.cfm_routing_flag = 1
                THEN
                        l_rtg_header_unexp_rec.line_id :=
                         Line_Id
                        (  p_line_code => p_rtg_header_rec.line_code
                         , p_organization_id    =>
                                l_rtg_header_unexp_rec.organization_id
                         , x_err_text           => l_err_text
                         );
                        IF l_rtg_header_unexp_rec.line_id IS NULL
                        THEN
                                l_token_tbl(1).token_name :=
                                        'LINE_CODE';
                                l_token_tbl(1).token_value :=
                                     p_rtg_header_rec.line_code;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                                     'BOM_RTG_LINE_CODE_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF   l_err_text IS NOT NULL AND
                                l_rtg_header_unexp_rec.line_id
                                                IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                      'Unexpected Error ' || l_err_text
                                          || ' in ' || G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y'THEN
      Error_Handler.Write_Debug('Converted line code ...');
END IF;

                END IF;


                x_return_status := l_return_status;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                  ('Return status of Header VID: ' || l_return_status );
                END IF;

                x_rtg_header_unexp_rec := l_rtg_header_unexp_rec;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Rtg_Header_VID;

        /*********************************************************************
        * Procedure     : Rtg_revision_UUI_To_UI
        * Returns       : None
        * Parameters IN : Routing revision Record
        *                 Routing revision Unexposed Record
        * Parameters OUT: Routing revision unexposed record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : This procedure will perform all the required
        *                 User unique to Unique index conversions for routing
        *                 revision. Any errors will be logged in the Message
        *                 table and a return satus of success or failure will be
        *                 returned to the calling program.
        *********************************************************************/

        PROCEDURE Rtg_Revision_UUI_To_UI
        (  p_rtg_revision_rec     IN   Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_rev_unexp_rec    IN   Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_rtg_rev_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
                l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_rtg_rev_unexp_rec     Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type;
                l_return_status         VARCHAR2(1);
                l_err_text              VARCHAR2(2000);



        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_return_status := FND_API.G_RET_STS_SUCCESS;
                l_rtg_rev_unexp_rec := p_rtg_rev_unexp_rec;


                If BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                     ('Rtg revision UUI-UI Conversion . . ');
                END IF;

        /******************************************************
        --
        -- Verify that the unique key columns are not empty
        --
        ********************************************************/
                --
                -- Assembly Item name cannot be NULL or missing.
                --
                IF p_rtg_revision_rec.assembly_item_name IS NULL OR
                   p_rtg_revision_rec.assembly_item_name = FND_API.G_MISS_CHAR
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_RTG_REV_AITEM_KEYCOL_NULL'
                         , p_mesg_token_tbl => l_mesg_token_tbl
                         , x_mesg_token_tbl => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- Assembly item name must be successfully converted to id.
                --

                l_rtg_rev_unexp_rec.assembly_item_id :=
                Assembly_Item (  p_assembly_item_name   =>
                                     p_rtg_revision_rec.assembly_item_name
                               , p_organization_id       =>
                                     l_rtg_rev_unexp_rec.organization_id
                               , x_err_text              => l_err_text
                               );

                IF l_rtg_rev_unexp_rec.assembly_item_id IS NULL
                THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_rtg_revision_rec.assembly_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_rtg_revision_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RTG_AITEM_DOESNOT_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                ELSIF l_err_text IS NOT NULL AND
                  (l_rtg_rev_unexp_rec.assembly_item_id IS NULL OR
                   l_rtg_rev_unexp_rec.assembly_item_id = FND_API.G_MISS_NUM)
                THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;

                If BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                   ('After converting Assembly Item Id : '
                     || to_char(l_rtg_rev_unexp_rec.assembly_item_id)
                     || ' Status ' || l_return_status); END IF;


                x_return_status := l_return_status;
                x_rtg_rev_unexp_rec := l_rtg_rev_unexp_rec;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Rtg_Revision_UUI_To_UI;


        /*******************************************************************
        * Procedure : Operation_UUI_To_UI used by RTG BO
        * Parameters IN : Operation exposed column record
        *                 Operation unexposed column record
        * Parameters OUT: Operation unexposed column record
        *                 Return Status
        *                 Message Token Table
        * Purpose   :     Convert ECO Operation to Common Operation and
        *                 Call Check_Entity for Common Operation.
        *                 Procedure will convert UUI to UI.
        *******************************************************************/
        PROCEDURE Operation_UUI_To_UI
        (  p_operation_rec       IN   Bom_Rtg_Pub.Operation_Rec_Type
         , p_op_unexp_rec        IN   Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_return_status       IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
                l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
                l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
                l_operation_rec          Bom_Rtg_Pub.Operation_Rec_Type ;

        BEGIN
                -- Convert Routing Operation to Common Operation
                Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
                (  p_rtg_operation_rec      => p_operation_rec
                 , p_rtg_op_unexp_rec       => p_op_unexp_rec
                 , x_com_operation_rec      => l_com_operation_rec
                 , x_com_op_unexp_rec       => l_com_op_unexp_rec
                ) ;


                -- Call Com_Operation_UUI_To_UI
                Bom_Rtg_Val_To_Id.Com_Operation_UUI_To_UI
                (  p_com_operation_rec     => l_com_operation_rec
                 , p_com_op_unexp_rec      => l_com_op_unexp_rec
                 , x_com_op_unexp_rec      => l_com_op_unexp_rec
                 , x_return_status         => x_return_status
                 , x_mesg_token_tbl        => x_mesg_token_tbl
                ) ;

                -- Convert the Common record to Routing Record
                Bom_Rtg_Pub.Convert_ComOp_To_RtgOp
                (  p_com_operation_rec      => l_com_operation_rec
                 , p_com_op_unexp_rec       => l_com_op_unexp_rec
                 , x_rtg_operation_rec      => l_operation_rec
                 , x_rtg_op_unexp_rec       => x_op_unexp_rec
                 ) ;

        END Operation_UUI_To_UI ;


        /*******************************************************************
        * Procedure : Rev_Operation_UUI_To_UI used by ECO BO
        * Parameters IN : Revised Operation exposed column record
        *                 Revised Operation unexposed column record
        * Parameters OUT: Revised Operation unexposed column record
        *                 Return Status
        *                 Message Token Table
        * Purpose   :     Convert ECO Operation to Common Operation and
        *                 Call Check_Entity for Common Operation.
        *                 Procedure will convert UUI to UI.
        *******************************************************************/
        PROCEDURE Rev_Operation_UUI_To_UI
        (  p_rev_operation_rec       IN   Bom_Rtg_Pub.Rev_Operation_Rec_Type
         , p_rev_op_unexp_rec        IN   Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , x_rev_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )


        IS
                l_com_operation_rec          Bom_Rtg_Pub.Com_Operation_Rec_Type ;
                l_com_op_unexp_rec           Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
                l_rev_op_com_operation_rec   Bom_Rtg_Pub.Rev_Operation_Rec_Type ;

        BEGIN
                -- Convert Revised Operation to Common Operation
                Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
                (  p_rev_operation_rec      => p_rev_operation_rec
                 , p_rev_op_unexp_rec       => p_rev_op_unexp_rec
                 , x_com_operation_rec      => l_com_operation_rec
                 , x_com_op_unexp_rec       => l_com_op_unexp_rec
                ) ;


                -- Call Com_Operation_UUI_To_UI
                Bom_Rtg_Val_To_Id.Com_Operation_UUI_To_UI
                (  p_com_operation_rec     => l_com_operation_rec
                 , p_com_op_unexp_rec      => l_com_op_unexp_rec
                 , x_com_op_unexp_rec      => l_com_op_unexp_rec
                 , x_return_status         => x_return_status
                 , x_mesg_token_tbl        => x_mesg_token_tbl
                ) ;

                -- Convert the Common record to Revised Operation record
                Bom_Rtg_Pub.Convert_ComOp_To_EcoOp
                (  p_com_operation_rec      => l_com_operation_rec
                 , p_com_op_unexp_rec       => l_com_op_unexp_rec
                 , x_rev_operation_rec      => l_rev_op_com_operation_rec
                 , x_rev_op_unexp_rec       => x_rev_op_unexp_rec
                 ) ;

        END Rev_Operation_UUI_To_UI ;


        /*********************************************************************
        * Procedure     : Com_Operation_UUI_To_UI
        * Returns       : None
        * Parameters IN : Common Operation exposed Record
        *                 Common Operation Unexposed Record
        * Parameters OUT: Common OPeration Unexposed record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : This procedure will perform all the required
        *                 User unique to Unique index conversions for operation
        *                 record. Any errors will be logged in the Message table
        *                 and a return satus of success or failure will be
        *                 returned to the calling program.
        *********************************************************************/
        PROCEDURE Com_Operation_UUI_To_UI
        (  p_com_operation_rec       IN   Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec        IN   Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_com_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS

                l_Mesg_Token_Tbl           Error_Handler.Mesg_Token_Tbl_Type;
                l_com_op_unexp_rec         Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type;
                l_return_status            VARCHAR2(1);
                l_err_text                 VARCHAR2(2000);
		l_err_text_diff            VARCHAR2(1);

                CURSOR c_Check_Alternate(  p_alt_designator     VARCHAR2,
                                           p_organization_id    NUMBER ) IS
                SELECT 1
                  FROM bom_alternate_designators
                 WHERE alternate_designator_code = p_alt_designator
                   AND organization_id = p_organization_id;

        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_return_status := FND_API.G_RET_STS_SUCCESS;
                l_com_op_unexp_rec := p_com_op_unexp_rec;

                If BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                     ('Operation record UUI-UI Conversion . . ');
                END IF;

                --
                -- Revised Item name cannot be NULL or missing.
                --
                IF p_com_operation_rec.revised_item_name IS NULL OR
                   p_com_operation_rec.revised_item_name = FND_API.G_MISS_CHAR
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_OP_AITEM_KEYCOL_NULL'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- Operation sequence number cannot be NULL or missing.
                --
                IF p_com_operation_rec.operation_sequence_number IS NULL OR
                   p_com_operation_rec.operation_sequence_number = FND_API.G_MISS_NUM
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_OP_SEQNUM_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    );
                    l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- Start effective date cannot be NULL or missing.
                --
                IF ( p_com_operation_rec.start_effective_date IS NULL OR
                     p_com_operation_rec.start_effective_date = FND_API.G_MISS_DATE)
                AND ( p_com_operation_rec.operation_type NOT IN (2, 3)
                      OR   p_com_operation_rec.operation_type IS NULL)
                THEN
                    Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_OP_EFFECTIVITY_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                   );
                   l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

               --
               -- If key columns are NULL, then return.
               --
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                   x_return_status := l_return_status;
                   x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                   x_com_op_unexp_rec := l_com_op_unexp_rec;
                   RETURN ;
               END IF;


               --
               -- Revised item name must be successfully converted to id.
               --
               l_com_op_unexp_rec.revised_item_id :=
               Revised_Item (  p_revised_item_num   =>
                                     p_com_operation_rec.revised_item_name
                             , p_organization_id    =>
                                     l_com_op_unexp_rec.organization_id
                             , x_err_text           => l_err_text
                             );

               IF l_com_op_unexp_rec.revised_item_id IS NULL
               THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_com_operation_rec.revised_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_com_operation_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RTG_AITEM_DOESNOT_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                       x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                       x_com_op_unexp_rec := l_com_op_unexp_rec;
                       x_Return_Status := l_Return_Status;


                ELSIF l_err_text IS NOT NULL AND
                  (l_com_op_unexp_rec.revised_item_id IS NULL OR
                   l_com_op_unexp_rec.revised_item_id = FND_API.G_MISS_NUM)
                THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;



                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                   ('After converting Assembly Item Id : '
                     || to_char(l_com_op_unexp_rec.revised_item_id)
                     || ' Status ' || l_return_status);
                END IF;

                IF p_com_operation_rec.alternate_routing_code IS NOT NULL AND
                   p_com_operation_rec.alternate_routing_code <> FND_API.G_MISS_CHAR
                THEN
                        /*l_err_text_diff*/l_err_text := FND_API.G_RET_STS_ERROR;

                        FOR check_alternate IN
                           c_Check_Alternate
                           ( p_alt_designator  =>
                                    p_com_operation_rec.alternate_routing_code,
                             p_organization_id =>
                                    l_com_op_unexp_rec.organization_id )
                        LOOP
                                /*l_err_text_diff*/l_err_text := FND_API.G_RET_STS_SUCCESS;
                        END LOOP;

                        IF /*l_err_text_diff*/l_err_text <> FND_API.G_RET_STS_SUCCESS
                        THEN
                          g_token_tbl(1).token_name  :='ALTERNATE_ROUTING_CODE';
                          g_token_tbl(1).token_value :=
                                       p_com_operation_rec.alternate_routing_code;
                          g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                          g_token_tbl(2).token_value :=
                                       p_com_operation_rec.organization_code;
                          Error_Handler.Add_Error_Token
                            ( P_Message_Name   => 'BOM_RTG_ALT_DESIGNATOR_INVALID'
                            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , p_token_tbl      => g_token_tbl
                                 );

                           l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;

                END IF;


                /****************************************************************
                --
                -- Using the revised item key information, get the routing_sequence_id
                -- and revised item sequence id
                --
                ****************************************************************/

                IF BOM_Rtg_Globals.Get_Bo_Identifier <> BOM_Rtg_Globals.G_RTG_BO
                THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Processing UUI_UI for operations and retrieving rev item seq id . . . ');
END IF;
                    NULL ;

                    /****************************************************************
                    -- Comment out by MK on 12/04/00 to resolve Eco dependency
                    -- this logic moved to Eng_Val_To_ID package
                    l_com_op_unexp_rec.revised_item_sequence_id :=
                    RtgAndRevItemSeq
                    (  p_revised_item_id   => l_com_op_unexp_rec.revised_item_id
                     , p_item_revision     => p_com_operation_rec.new_revised_item_revision
                     , p_effective_date    => p_com_operation_rec.start_effective_date
                     , p_change_notice     => p_com_operation_rec.eco_name
                     , p_organization_id   => l_com_op_unexp_rec.organization_id
                     , p_new_routing_revision  => p_com_operation_rec.new_routing_revision
                     , p_from_end_item_number  => p_com_operation_rec.from_end_item_unit_number
                     , x_routing_sequence_id => l_com_op_unexp_rec.routing_sequence_id
                    );

                    IF l_com_op_unexp_rec.revised_item_sequence_id IS NULL
                    THEN
                        g_Token_Tbl(1).Token_Name  := 'OP_SEQ_NUMBER';
                        g_Token_Tbl(1).Token_Value := p_com_operation_rec.operation_sequence_number;
                        g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value := p_com_operation_rec.revised_item_name;
                        g_token_tbl(3).token_name  := 'ECO_NAME';
                        g_token_tbl(3).token_value := p_com_operation_rec.eco_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_OP_RIT_SEQUENCE_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );

                        l_Return_Status    := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl   := l_Mesg_Token_Tbl;
                        x_com_op_unexp_rec := l_com_op_unexp_rec;
                        x_Return_Status    := l_Return_Status;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('And this call returned with ' || l_Return_Status); END IF;

                        RETURN;

                    END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Revised Item Sequence Id : ' || to_char(l_com_op_unexp_rec.revised_item_sequence_id))  ;
END IF ;
                    ****************************************************************/

                ELSE

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Processing UUI_UI for operations . . . ');
END IF;
                --
                -- If the calling BO is RTG then get the routing sequence id
                --
                    l_com_op_unexp_rec.routing_sequence_id :=
                    Routing_Sequence_id
                    (  p_assembly_item_id  =>  l_com_op_unexp_rec.revised_item_id
                     , p_organization_id   =>  l_com_op_unexp_rec.organization_id
                     , p_alternate_routing_designator =>
                                     p_com_operation_rec.alternate_routing_code
                     , x_err_text          => l_err_text
                     );

                    IF l_com_op_unexp_rec.routing_sequence_id IS NULL
                    THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_com_operation_rec.revised_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_com_operation_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_OP_RTG_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                       x_Mesg_Token_Tbl   := l_Mesg_Token_Tbl;
                       x_com_op_unexp_rec := l_com_op_unexp_rec;
                       x_Return_Status    := l_Return_Status;

                       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('And this call returned with ' || l_Return_Status); END IF;

                       RETURN;


                    ELSIF l_err_text IS NOT NULL AND
                      (l_com_op_unexp_rec.routing_sequence_id IS NULL OR
                       l_com_op_unexp_rec.routing_sequence_id= FND_API.G_MISS_NUM)
                    THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    END IF;
                END IF ;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                   ('After converting, Routing sequence id is '
                     || to_char(l_com_op_unexp_rec.routing_sequence_id)
                     || ' Status ' || l_return_status);
                END IF;

                x_return_status      := l_return_status;
                x_com_op_unexp_rec   := l_com_op_unexp_rec;
                x_mesg_token_tbl     := l_mesg_token_tbl;

        END Com_Operation_UUI_To_UI;


        /*******************************************************************
        * Procedure : Operation_VID used by RTG BO
        * Parameters IN : Operation exposed column record
        *                 Operation unexposed column record
        * Parameters OUT: Operation unexposed column record
        *                 Return Status
        *                 Message Token Table
        * Purpose   :     Convert ECO Operation to Common Operation and
        *                 Call Check_Entity for Common Operation.
        *                 Procedure will perform the operation record value to ID
        *                 conversions.
        *******************************************************************/
        PROCEDURE Operation_VID
        (  p_operation_rec       IN  Bom_Rtg_Pub.Operation_Rec_Type
         , p_op_unexp_rec        IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_Return_Status       IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )

        IS
                l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
                l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
                l_operation_rec          Bom_Rtg_Pub.Operation_Rec_Type ;

        BEGIN
                -- Convert Routing Operation to Common Operation
                Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
                (  p_rtg_operation_rec      => p_operation_rec
                 , p_rtg_op_unexp_rec       => p_op_unexp_rec
                 , x_com_operation_rec      => l_com_operation_rec
                 , x_com_op_unexp_rec       => l_com_op_unexp_rec
                ) ;


                -- Call Com_Operation_VID
                Bom_Rtg_Val_To_Id.Com_Operation_VID
                (  p_com_operation_rec     => l_com_operation_rec
                 , p_com_op_unexp_rec      => l_com_op_unexp_rec
                 , x_com_op_unexp_rec      => l_com_op_unexp_rec
                 , x_return_status         => x_return_status
                 , x_mesg_token_tbl        => x_mesg_token_tbl
                ) ;

                -- Convert the Common record to Routing Record
                Bom_Rtg_Pub.Convert_ComOp_To_RtgOp
                (  p_com_operation_rec      => l_com_operation_rec
                 , p_com_op_unexp_rec       => l_com_op_unexp_rec
                 , x_rtg_operation_rec      => l_operation_rec
                 , x_rtg_op_unexp_rec       => x_op_unexp_rec
                 ) ;

        END Operation_VID ;


        /*******************************************************************
        * Procedure : Rev_Operation_VID used by ECO BO
        * Parameters IN : Revised Operation exposed column record
        *                 Revised Operation unexposed column record
        * Parameters OUT: Revised Operation unexposed column record
        *                 Return Status
        *                 Message Token Table
        * Purpose   :     Convert ECO Operation to Common Operation and
        *                 Call Check_Entity for Common Operation.
        *                 Procedure will perform the operation record value to ID
        *                 conversions.
        *******************************************************************/
        PROCEDURE Rev_Operation_VID
        (  p_rev_operation_rec       IN   Bom_Rtg_Pub.Rev_Operation_Rec_Type
         , p_rev_op_unexp_rec        IN   Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , x_rev_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )


        IS
                l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
                l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
                l_rev_operation_rec      Bom_Rtg_Pub.Rev_Operation_Rec_Type ;

        BEGIN
                -- Convert Revised Operation to Common Operation
                Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
                (  p_rev_operation_rec      => p_rev_operation_rec
                 , p_rev_op_unexp_rec       => p_rev_op_unexp_rec
                 , x_com_operation_rec      => l_com_operation_rec
                 , x_com_op_unexp_rec       => l_com_op_unexp_rec
                ) ;


                -- Call Com_Operation_VID
                Bom_Rtg_Val_To_Id.Com_Operation_VID
                (  p_com_operation_rec     => l_com_operation_rec
                 , p_com_op_unexp_rec      => l_com_op_unexp_rec
                 , x_com_op_unexp_rec      => l_com_op_unexp_rec
                 , x_return_status         => x_return_status
                 , x_mesg_token_tbl        => x_mesg_token_tbl
                ) ;

                -- Convert the Common record to Revised Operation record
                Bom_Rtg_Pub.Convert_ComOp_To_EcoOp
                (  p_com_operation_rec      => l_com_operation_rec
                 , p_com_op_unexp_rec       => l_com_op_unexp_rec
                 , x_rev_operation_rec      => l_rev_operation_rec
                 , x_rev_op_unexp_rec       => x_rev_op_unexp_rec
                 ) ;

        END Rev_Operation_VID ;


        /*********************************************************************
        * Procedure     : Com_Operation_VID
        * Returns       : None
        * Parameters IN : Common Operation exposed Record
        *                 Common Operation Unexposed Record
        * Parameters OUT: Common Operation Unexposed Record
        *                 Return Status
        *                 Message Token Table
        * Purpose       : This is the access procedure which the private API
        *                 will call to perform the operation record value to ID
        *                 conversions. If any of the conversions fail then
        *                 the procedure will return with an error status and
        *                 the messsage token table filled with appropriate
        *                 error message.
        *********************************************************************/
        PROCEDURE Com_Operation_VID
        (  p_com_operation_rec       IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec        IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_com_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_Return_Status           IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
                l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
                l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_err_text              VARCHAR2(2000);
                l_Token_Tbl             Error_Handler.Token_Tbl_Type;
                l_com_op_unexp_rec      Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
                                                         := p_com_op_unexp_rec;
                l_common_rtg_seq_id     NUMBER;
                l_cfm_flag              NUMBER;
                l_old_op_seq_number     NUMBER;
        BEGIN

                If BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug('Operaton VID conversion . . .');
                END IF;
                --
                -- Convert standard operation code to standard operation id
                --
                IF p_com_operation_rec.standard_operation_code IS NOT NULL AND
                   p_com_operation_rec.standard_operation_code <> FND_API.G_MISS_CHAR
                THEN
                    IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO
                    THEN

                        l_com_op_unexp_rec.Standard_Operation_Id :=
                        Standard_Operation_Id
                         (  p_operation_type           => p_com_operation_rec.operation_type
                          , p_standard_operation_code  => p_com_operation_rec.standard_operation_code
                          , p_organization_id          => l_com_op_unexp_rec.organization_id
                          , p_routing_sequence_id      => l_com_op_unexp_rec.routing_sequence_id
                          , x_err_text                 => l_err_text
                         );

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                          ('Converted standard operation code . . .');
                END IF;

                    ELSE

                        l_com_op_unexp_rec.Standard_Operation_Id :=
                        Standard_Operation_Id
                         (  p_operation_type           => p_com_operation_rec.operation_type
                          , p_standard_operation_code  => p_com_operation_rec.standard_operation_code
                          , p_organization_id          => l_com_op_unexp_rec.organization_id
                          , p_rev_item_sequence_id     => l_com_op_unexp_rec.revised_item_sequence_id
                          , x_err_text                 => l_err_text
                         );

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                          ('Converted standard operation code . . .');
                END IF;

                    END IF ;

                    IF l_com_op_unexp_rec.Standard_Operation_Id  IS NULL
                    THEN
                                l_token_tbl(1).token_name := 'STD_OP_CODE';
                                l_token_tbl(1).token_value :=
                                     p_com_operation_rec.standard_operation_code;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                                   'BOM_OP_STD_OP_CODE_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                    ELSIF l_err_text IS NOT NULL AND
                             l_com_op_unexp_rec.Standard_Operation_Id IS NULL
                    THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                    END IF;
                END IF;


                --
                -- Convert department code to department ID
                --

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                          ('Dept code : . .' || p_com_operation_rec.department_code );
                END IF;


                IF p_com_operation_rec.department_code IS NOT NULL AND
                   p_com_operation_rec.department_code <> FND_API.G_MISS_CHAR
                THEN
                        l_com_op_unexp_rec.department_id :=
                        Department_Id
                         (  p_department_code => p_com_operation_rec.department_code
                          , p_organization_id => l_com_op_unexp_rec.organization_id
                          , x_err_text        => l_err_text
                         );

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                          ('Converted department code . . .');
                END IF;

                        IF l_com_op_unexp_rec.department_id  IS NULL
                        THEN
                                l_token_tbl(1).token_name :='DEPARTMENT_CODE';
                                l_token_tbl(1).token_value :=
                                     p_com_operation_rec.department_code;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>'BOM_OP_DEPT_CODE_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                             l_com_op_unexp_rec.department_id  IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                   'Unexpected Error ' || l_err_text || ' in '
                                     || G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;
                END IF;

                --
                -- If routing is flow routing, convert process code to proces_op
                -- _seq_id
                --
                IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag  IS NULL OR
                   BOM_Rtg_Globals.Get_CFM_Rtg_Flag   = FND_API.G_MISS_NUM
                THEN
                     l_cfm_flag := Bom_Rtg_Validate.Get_Flow_Routing_Flag
                                   (l_com_op_unexp_rec.routing_sequence_id) ;
                     BOM_Rtg_Globals.Set_CFM_Rtg_Flag(p_cfm_rtg_type => l_cfm_flag) ;

                ELSE l_cfm_flag := BOM_Rtg_Globals.Get_CFM_Rtg_Flag ;
                END IF;


                IF l_cfm_flag  = BOM_Rtg_Globals.G_FLOW_RTG
                THEN

                    IF (p_com_operation_rec.process_code IS NOT NULL AND
                        p_com_operation_rec.process_code <> FND_API.G_MISS_CHAR )
                    OR
                       (p_com_operation_rec.process_seq_number IS NOT NULL AND
                        p_com_operation_rec.process_seq_number <> FND_API.G_MISS_NUM )

                    THEN

                       l_com_op_unexp_rec.process_op_seq_id:=
                         Process_Op_Seq_Id
                         (  p_process_code       => p_com_operation_rec.process_code
                         ,  p_process_seq_number =>
                                           p_com_operation_rec.process_seq_number
                         ,  p_organization_id    =>
                                           l_com_op_unexp_rec.organization_id
                         ,  p_routing_sequence_id =>
                                           l_com_op_unexp_rec.routing_sequence_id
                         ,  x_err_text        => l_err_text
                         );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
     ('Converted process code . . .');
END IF;

                        IF l_com_op_unexp_rec.process_op_seq_id  IS NULL
                        THEN
                            IF p_com_operation_rec.process_code
                                                    <> FND_API.G_MISS_CHAR
                            THEN
                                l_token_tbl(1).token_name :='PROCESS_CODE';
                                l_token_tbl(1).token_value :=
                                     p_com_operation_rec.process_code;
                            END IF ;

                            IF  p_com_operation_rec.process_seq_number
                                                    <> FND_API.G_MISS_NUM
                            THEN
                                l_token_tbl(2).token_name :='PROCESS_SEQ_NUM';
                                l_token_tbl(2).token_value :=
                                     p_com_operation_rec.process_seq_number ;
                            END IF ;

                            Error_Handler.Add_Error_Token
                            (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , p_Message_name       =>
                                           'BOM_FLM_OP_PSCODE_SQNM_INVALID'
                             , p_token_tbl          => l_token_tbl
                            );

                            l_return_status := FND_API.G_RET_STS_ERROR;
                            l_token_tbl.delete ;

                        ELSIF l_err_text IS NOT NULL AND
                             l_com_op_unexp_rec.process_op_seq_id IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                   'Unexpected Error ' || l_err_text || ' in '
                                     || G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;
                   END IF ;
                END IF;


                -- If routing is flow routing, convert line operation code to
                -- lin_op_seq_id.
                --
                IF l_cfm_flag  = BOM_Rtg_Globals.G_FLOW_RTG
                THEN
                    IF (p_com_operation_rec.line_op_code IS NOT NULL AND
                        p_com_operation_rec.line_op_code <> FND_API.G_MISS_CHAR )
                    OR
                       (p_com_operation_rec.line_op_seq_number IS NOT NULL AND
                        p_com_operation_rec.line_op_seq_number <>FND_API.G_MISS_NUM )

                    THEN
                        l_com_op_unexp_rec.line_op_seq_id :=
                        Line_Op_Seq_Id
                         (  p_line_code           => p_com_operation_rec.line_op_code
                         ,  p_line_seq_number     =>
                                        p_com_operation_rec.line_op_seq_number
                         ,  p_organization_id     =>
                                        l_com_op_unexp_rec.organization_id
                         ,  p_routing_sequence_id =>
                                        l_com_op_unexp_rec.routing_sequence_id
                         , x_err_text             => l_err_text
                         );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
     ('Converted line op code . . .');
END IF;

                        IF l_com_op_unexp_rec.line_op_seq_id  IS NULL
                        THEN
                            IF p_com_operation_rec.line_op_code
                                                 <> FND_API.G_MISS_CHAR
                            THEN
                                l_token_tbl(1).token_name := 'LINE_OP_CODE';
                                l_token_tbl(1).token_value :=
                                     p_com_operation_rec.line_op_code;
                            END IF ;

                            IF p_com_operation_rec.line_op_seq_number
                                                 <> FND_API.G_MISS_NUM
                            THEN

                                l_token_tbl(2).token_name := 'LINE_OP_SEQ_NUM';
                                l_token_tbl(2).token_value :=
                                     p_com_operation_rec.line_op_seq_number ;
                            END IF ;

                            Error_Handler.Add_Error_Token
                            (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , p_Message_name       =>
                                           'BOM_FLM_OP_LNOPCD_SQNM_INVALID'
                             , p_token_tbl          => l_token_tbl
                             );

                            l_return_status := FND_API.G_RET_STS_ERROR;
                            l_token_tbl.delete ;

                        ELSIF l_err_text IS NOT NULL AND
                             l_com_op_unexp_rec.line_op_seq_id  IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                   'Unexpected Error ' || l_err_text || ' in '
                                     || G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;
                    END IF ;
                END IF;



                --
                -- Using old_operation information, get the old_operation_sequence_id
                --
                IF   BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
                AND  p_com_operation_rec.acd_type IN (2,3) -- Change or Disable
                AND  p_com_operation_rec.old_start_effective_date IS NOT NULL
                AND  p_com_operation_rec.old_start_effective_date <> FND_API.G_MISS_DATE
                    -- p_com_operation_rec.old_operation_sequence_number IS NOT NULL AND
                    -- p_com_operation_rec.old_operation_sequence_number <>
                    -- FND_API.G_MISS_NUM
                THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Executing old operation seq id Val-ID conversion . . .');
    Error_Handler.Write_Debug('Routing Sequence: ' || to_char(l_com_op_unexp_rec.routing_sequence_id));
END IF;

                    IF (p_com_operation_rec.old_operation_sequence_number IS NULL
                       OR p_com_operation_rec.old_operation_sequence_number =
                                                              FND_API.G_MISS_NUM)
                    THEN
                          l_old_op_seq_number :=  p_com_operation_rec.operation_sequence_number ;
                    ELSE
                          l_old_op_seq_number := p_com_operation_rec.old_operation_sequence_number ;
                    END IF ;


                    IF   l_old_op_seq_number <>
                          p_com_operation_rec.operation_sequence_number
                    THEN

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_OP_OLD_SEQ_NUM_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                    END IF ;

                    l_com_op_unexp_rec.old_operation_sequence_id :=
                    Old_Operation_Sequence
                    (  p_old_effective_date    => p_com_operation_rec.old_start_effective_date
                     , p_old_op_seq_num        => l_old_op_seq_number
                                                 -- p_com_operation_rec.old_operation_sequence_number
                     , p_operation_type        => p_com_operation_rec.operation_type
                     , p_routing_sequence_id   => l_com_op_unexp_rec.routing_sequence_id
                    );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug ('Converted Old Operation Seq Id. . .');
END IF;

                    IF l_com_op_unexp_rec.old_operation_sequence_id IS NULL
                    THEN
                        g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value :=
                                p_com_operation_rec.operation_sequence_number ;
                        g_token_tbl(2).token_name  := 'OLD_EFFECTIVITY_DATE';
                        g_token_tbl(2).token_value :=
                                p_com_operation_rec.old_start_effective_date;
                        g_token_tbl(3).token_name  := 'OLD_OP_SEQ_NUMBER';
                        g_token_tbl(3).token_value :=
                             p_com_operation_rec.old_operation_sequence_number;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_OP_OLD_OP_SEQ_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;
                    ELSIF l_com_op_unexp_rec.old_operation_sequence_id = FND_API.G_MISS_NUM
                    THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       =>
                           'Unexpected Error while converting old operation sequence id'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl

                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                    END IF;


                END IF;


                x_return_status := l_return_status;

                IF Bom_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                  ('Return status of operation VID: ' || l_return_status );
                END IF;

                x_com_op_unexp_rec := l_com_op_unexp_rec;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Com_Operation_VID;


        /*********************************************************************
        * Procedure     : Op_Resource_UUI_To_UI
        * Returns       : None
        * Parameters IN : Operation Resource Exposed Record
        *                 Operation Resource Unexposed Record
        * Parameters OUT: Operation Resource unexposed Record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : Convert Routing Op Resource to Revised Op Resource and
        *                 Call Rev_Op_resource_UUI_To_UI for ECO Bo.
        *                 After calling Rev_Op_resource_UUI_To_UI, convert Revised
        *                 Op Resource record back to Routing Op Resource
        *********************************************************************/
        PROCEDURE Op_Resource_UUI_To_UI
        (  p_op_resource_rec     IN   Bom_Rtg_Pub.Op_Resource_Rec_Type
         , p_op_res_unexp_rec    IN   Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_return_status       IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )

        IS
                l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
                l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
                l_op_resource_rec          Bom_Rtg_Pub.Op_Resource_Rec_Type ;

        BEGIN
                -- Convert Routing Operation to ECO Operation
                Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
                (  p_rtg_op_resource_rec      => p_op_resource_rec
                 , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
                 , x_rev_op_resource_rec      => l_rev_op_resource_rec
                 , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                ) ;

                -- Call Rev_Op_Resource_UUI_To_UI
                Bom_Rtg_Val_To_Id.Rev_Op_Resource_UUI_To_UI
                (  p_rev_op_resource_rec      => l_rev_op_resource_rec
                 , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                 , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                 , x_return_status            => x_return_status
                 , x_mesg_token_tbl           => x_mesg_token_tbl
                ) ;

                -- Convert old Eco Opeartion Record back to Routing Operation
                Bom_Rtg_Pub.Convert_EcoRes_To_RtgRes
                (  p_rev_op_resource_rec      => l_rev_op_resource_rec
                 , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                 , x_rtg_op_resource_rec      => l_op_resource_rec
                 , x_rtg_op_res_unexp_rec     => x_op_res_unexp_rec
                 ) ;

        END Op_Resource_UUI_To_UI ;

        /*********************************************************************
        * Procedure     : Rev_Op_Resource_UUI_To_UI
        * Returns       : None
        * Parameters IN : Revised Operation Resource Exposed Record
        *                 Revised Operation Resource Unexposed Record
        * Parameters OUT: Revised Operation Resource Unexposed Record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : This procedure will perform all the required
        *                 User unique to Unique index conversions for
        *                 resource record. Any errors will be logged in the
        *                 Message table and a return satus of success or
        *                 failure will be returned to the calling program.
        *********************************************************************/
        PROCEDURE Rev_Op_Resource_UUI_To_UI
         ( p_rev_op_resource_rec     IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec    IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_rev_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         )



        IS
          l_Mesg_Token_Tbl       Error_Handler.Mesg_Token_Tbl_Type;
          l_rev_op_res_unexp_rec Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
          l_return_status        VARCHAR2(1);
          l_err_text             VARCHAR2(2000);
          l_cfm_flag             NUMBER;
          l_err_text_diff        VARCHAR2(1);

                CURSOR c_Check_Alternate(  p_alt_designator     VARCHAR2,
                                           p_organization_id    NUMBER ) IS
                SELECT 1
                  FROM bom_alternate_designators
                 WHERE alternate_designator_code = p_alt_designator
                   AND organization_id = p_organization_id;

        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_return_status := FND_API.G_RET_STS_SUCCESS;
                l_rev_op_res_unexp_rec := p_rev_op_res_unexp_rec;

                If BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                     ('Operation resource record UUI-UI Conversion . . ');
                END IF;

                --
                -- Assembly Item name cannot be NULL or missing.
                --
                IF p_rev_op_resource_rec.revised_item_name IS NULL OR
                   p_rev_op_resource_rec.revised_item_name = FND_API.G_MISS_CHAR
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_RES_AITEM_KEYCOL_NULL'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- Resource sequence number cannot be NULL or missing.
                --
                IF p_rev_op_resource_rec.resource_sequence_number IS NULL OR
                   p_rev_op_resource_rec.resource_sequence_number = FND_API.G_MISS_NUM
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_RES_SEQNUM_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    );
                    l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- Operation sequence number cannot be NULL or missing.
                --
                IF p_rev_op_resource_rec.operation_sequence_number IS NULL OR
                   p_rev_op_resource_rec.operation_sequence_number =
                                     FND_API.G_MISS_NUM
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_RES_OP_SEQNUM_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    );
                    l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- Start effective date cannot be NULL or missing.
                --
                IF p_rev_op_resource_rec.op_start_effective_date IS NULL OR
                   p_rev_op_resource_rec.op_start_effective_date = FND_API.G_MISS_DATE
                THEN
                    Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_RES_EFF_DATE_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                   );
                   l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

               --
               -- If key columns are NULL, then return.
               --
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                   x_Return_Status := FND_API.G_RET_STS_ERROR;
                   x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                   RETURN;
               END IF;


                --
                -- Assembly item name must be successfully converted to id.
                --

                l_rev_op_res_unexp_rec.revised_item_id :=
                Revised_Item (  p_revised_item_num   =>
                                     p_rev_op_resource_rec.revised_item_name
                               , p_organization_id       =>
                                     l_rev_op_res_unexp_rec.organization_id
                               , x_err_text              => l_err_text
                               );

                IF l_rev_op_res_unexp_rec.revised_item_id IS NULL
                THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_rev_op_resource_rec.revised_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_rev_op_resource_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RTG_AITEM_DOESNOT_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                ELSIF l_err_text IS NOT NULL AND
                  ( l_rev_op_res_unexp_rec.revised_item_id IS NULL OR
                    l_rev_op_res_unexp_rec.revised_item_id = FND_API.G_MISS_NUM)
                THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                   ('After converting Assembly Item Id : '
                     || to_char(l_rev_op_res_unexp_rec.revised_item_id)
                     || ' Status ' || l_return_status);
                END IF;

                IF p_rev_op_resource_rec.alternate_routing_code IS NOT NULL AND
                   p_rev_op_resource_rec.alternate_routing_code <> FND_API.G_MISS_CHAR
                THEN
                        /*l_err_text_diff*/l_err_text := FND_API.G_RET_STS_ERROR;

                        FOR check_alternate IN
                           c_Check_Alternate
                           ( p_alt_designator  =>
                                    p_rev_op_resource_rec.alternate_routing_code,
                             p_organization_id =>
                                    l_rev_op_res_unexp_rec.organization_id )
                        LOOP
                                /*l_err_text_diff*/l_err_text := FND_API.G_RET_STS_SUCCESS;
                        END LOOP;

                        IF /*l_err_text_diff*/l_err_text <> FND_API.G_RET_STS_SUCCESS
                        THEN
                          g_token_tbl(1).token_name  :='ALTERNATE_ROUTING_CODE';
                          g_token_tbl(1).token_value :=
                                       p_rev_op_resource_rec.alternate_routing_code;
                          g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                          g_token_tbl(2).token_value :=
                                       p_rev_op_resource_rec.organization_code;
                          Error_Handler.Add_Error_Token
                            ( P_Message_Name => 'BOM_RTG_ALT_DESIGNATOR_INVALID'
                            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , p_token_tbl      => g_token_tbl
                                 );

                           l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;

                END IF;


                /****************************************************************
                --
                -- Using the revised item key information, get the routing_sequence_id
                -- and revised item sequence id
                --
                ****************************************************************/

                IF BOM_Rtg_Globals.Get_Bo_Identifier <> BOM_Rtg_Globals.G_RTG_BO
                THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Processing UUI_UI for operation resources and retrieving rev item seq id . . . ');
END IF;

                    NULL ;

                    /****************************************************************
                    -- Comment out by MK on 12/04/00 to resolve Eco dependency
                    l_rev_op_res_unexp_rec.revised_item_sequence_id :=
                    RtgAndRevItemSeq
                    (  p_revised_item_id   => l_rev_op_res_unexp_rec.revised_item_id
                     , p_item_revision     => p_rev_op_resource_rec.new_revised_item_revision
                     , p_effective_date    => p_rev_op_resource_rec.op_start_effective_date
                     , p_change_notice     => p_rev_op_resource_rec.eco_name
                     , p_organization_id   => l_rev_op_res_unexp_rec.organization_id
                     , p_new_routing_revision  => p_rev_op_resource_rec.new_routing_revision
                     , p_from_end_item_number  => p_rev_op_resource_rec.from_end_item_unit_number
                     , x_routing_sequence_id => l_rev_op_res_unexp_rec.routing_sequence_id
                    );

                    IF l_rev_op_res_unexp_rec.revised_item_Sequence_id IS NULL
                    THEN
                        g_Token_Tbl(1).Token_Name  := 'RES_SEQ_NUMBER';
                        g_Token_Tbl(1).Token_Value := p_rev_op_resource_rec.resource_sequence_number;
                        g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value := p_rev_op_resource_rec.revised_item_name;
                        g_token_tbl(3).token_name  := 'ECO_NAME';
                        g_token_tbl(3).token_value := p_rev_op_resource_rec.eco_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RES_RIT_SEQUENCE_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );

                        l_Return_Status  := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_rev_op_res_unexp_rec := l_rev_op_res_unexp_rec;
                        x_Return_Status  := l_Return_Status;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('And this call returned with ' || l_Return_Status); END IF;

                        RETURN;

                    END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Revised Item Sequence Id : ' || to_char(l_rev_op_res_unexp_rec.revised_item_sequence_id))  ;
END IF ;

                     ****************************************************************/

                ELSE
                --
                -- If the calling BO is RTG then get the routing sequence id
                --
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Processing UUI_UI for operation resources. . . ');
END IF;
                    l_rev_op_res_unexp_rec.routing_sequence_id :=
                    Routing_Sequence_id
                    ( p_assembly_item_id   => l_rev_op_res_unexp_rec.revised_item_id
                    , p_organization_id    => l_rev_op_res_unexp_rec.organization_id
                    , p_alternate_routing_designator =>
                                     p_rev_op_resource_rec.alternate_routing_code
                     , x_err_text                     => l_err_text
                    );

                    IF l_rev_op_res_unexp_rec.routing_sequence_id IS NULL
                    THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_rev_op_resource_rec.revised_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_rev_op_resource_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RES_RTG_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                   ELSIF l_err_text IS NOT NULL AND
                     (l_rev_op_res_unexp_rec.routing_sequence_id IS NULL OR
                      l_rev_op_res_unexp_rec.routing_sequence_id = FND_API.G_MISS_NUM)
                   THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   END IF;
                END IF ;

                -- Added by MK on 12/04/00
                IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO
                THEN

                     IF BOM_Rtg_Globals.Get_Debug = 'Y'
                     THEN Error_Handler.Write_Debug
                        ('After converting, routing sequence id is '
                          || to_char(l_rev_op_res_unexp_rec.routing_sequence_id )
                          || ' Status ' || l_return_status);
                     END IF;

                     --
                     -- For flow routing, operatoin Type should be set in (1, 2, 3)
                     --
                     IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag IS NULL OR
                        BOM_Rtg_Globals.Get_CFM_Rtg_Flag  = FND_API.G_MISS_NUM
                     THEN
                          l_cfm_flag := Bom_Rtg_Validate.Get_Flow_Routing_Flag(
                                         l_rev_op_res_unexp_rec.routing_sequence_id) ;
                          BOM_Rtg_Globals.Set_CFM_Rtg_Flag(p_cfm_rtg_type => l_cfm_flag) ;
                     ELSE l_cfm_flag := BOM_Rtg_Globals.Get_CFM_Rtg_Flag ;
                     END IF;

                     IF l_cfm_flag  = BOM_Rtg_Globals.G_FLOW_RTG
                     THEN
                        IF p_rev_op_resource_rec.operation_type IS NULL
                        OR p_rev_op_resource_rec.operation_type = FND_API.G_MISS_NUM
                        OR p_rev_op_resource_rec.operation_type NOT IN (1, 2, 3)
                        THEN

                            IF p_rev_op_resource_rec.operation_type <> FND_API.G_MISS_NUM
                            THEN
                                g_token_tbl(1).token_name  := 'OPERATION_TYPE';
                                g_token_tbl(1).token_value :=
                                             p_rev_op_resource_rec.operation_type ;
                            END IF ;

                            Error_Handler.Add_Error_Token
                            (  p_Message_Name       => 'BOM_FLM_RES_OPTYPE_INVALID'
                             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , p_Token_Tbl          => g_Token_Tbl
                            );
                            l_return_status := FND_API.G_RET_STS_ERROR ;
                        END IF ;
                     ELSE
                        IF  p_rev_op_resource_rec.operation_type IS NOT NULL
                        AND p_rev_op_resource_rec.operation_type <> FND_API.G_MISS_NUM
                        AND p_rev_op_resource_rec.operation_type <> 1
                        THEN
                           g_token_tbl(1).token_name  := 'OPERATION_TYPE';
                           g_token_tbl(1).token_value :=
                                            p_rev_op_resource_rec.operation_type;

                           Error_Handler.Add_Error_Token
                           (  p_Message_Name       => 'BOM_STD_RES_OPTYPE_INVALID'
                            , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                            , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                            , p_Token_Tbl          => g_Token_Tbl
                           );
                           l_return_status := FND_API.G_RET_STS_ERROR ;
                        END IF ;

                     END IF;

                    l_rev_op_res_unexp_rec.operation_sequence_id :=
                         Operation_Sequence_id
                           (  p_routing_sequence_id            =>
                                     l_rev_op_res_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                     p_rev_op_resource_rec.operation_type
                            , p_operation_seq_num              =>
                                     p_rev_op_resource_rec.operation_sequence_number
                            , p_effectivity_date =>
                                     p_rev_op_resource_rec.op_start_effective_date
                            , x_err_text                     => l_err_text
                           );

                     IF l_rev_op_res_unexp_rec.operation_sequence_id  IS NULL
                     THEN
                        g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value :=
                                        p_rev_op_resource_rec.operation_sequence_number ;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RES_OP_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                     ELSIF l_err_text IS NOT NULL AND
                       (l_rev_op_res_unexp_rec.operation_sequence_id  IS NULL OR
                        l_rev_op_res_unexp_rec.operation_sequence_id = FND_API.G_MISS_NUM
                        )
                     THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                     END IF;

                     IF BOM_Rtg_Globals.Get_Debug = 'Y'
                     THEN Error_Handler.Write_Debug
                        ('After converting, operation sequence id is '
                          || to_char(l_rev_op_res_unexp_rec.operation_sequence_id )
                          || ' Status ' || l_return_status);
                     END IF;

                END IF ; -- Added by MK on 12/04/00 Rtg BO specific

                x_return_status := l_return_status;
                x_rev_op_res_unexp_rec := l_rev_op_res_unexp_rec;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Rev_Op_Resource_UUI_To_UI;



        /*********************************************************************
        * Procedure     : Op_Resource_VID
        * Returns       : None
        * Parameters IN : Operation resource exposed Record
        *                 Operation resource Unexposed Record
        * Parameters OUT: Operation resource unexposed record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : Convert Routing Op Resource to Revised Op Resource and
        *                 Call Rev_Op_resource_VID for ECO Bo.
        *                 After calling Rev_Op_resource_VID, convert Revised
        *                 Op Resource record back to Routing Op Resource
        *********************************************************************/
        PROCEDURE Op_Resource_VID
        (  p_op_resource_rec     IN   Bom_Rtg_Pub.Op_Resource_Rec_Type
         , p_op_res_unexp_rec    IN   Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_return_status       IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )

        IS
                l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
                l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
                l_op_resource_rec          Bom_Rtg_Pub.Op_Resource_Rec_Type ;

        BEGIN
                -- Convert Routing Operation to ECO Operation
                Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
                (  p_rtg_op_resource_rec      => p_op_resource_rec
                 , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
                 , x_rev_op_resource_rec      => l_rev_op_resource_rec
                 , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                ) ;

                -- Call Rev_Op_resource_UUI_To_UI
                Bom_Rtg_Val_To_Id.Rev_Op_Resource_VID
                (  p_rev_op_resource_rec      => l_rev_op_resource_rec
                 , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                 , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                 , x_return_status            => x_return_status
                 , x_mesg_token_tbl           => x_mesg_token_tbl
                ) ;

                -- Convert old Eco Opeartion Record back to Routing Operation
                Bom_Rtg_Pub.Convert_EcoRes_To_RtgRes
                (  p_rev_op_resource_rec      => l_rev_op_resource_rec
                 , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                 , x_rtg_op_resource_rec      => l_op_resource_rec
                 , x_rtg_op_res_unexp_rec     => x_op_res_unexp_rec
                 ) ;


        END Op_Resource_VID ;


        /*********************************************************************
        * Procedure     : Rev_Op_Resource_VID
        * Returns       : None
        * Parameters IN : Operation resource exposed Record
        *                 Operation resource Unexposed Record
        * Parameters OUT: Operation resoruce Unexposed Record
        *                 Return Status
        *                 Message Token Table
        * Purpose       : This is the access procedure which the private API
        *                 will call to perform the operation record value to ID
        *                 conversions. If any of the conversions fail then the
        *                 the procedure will return with an error status and
        *                 the messsage token table filled with appropriate
        *                 error message.
        *********************************************************************/
        PROCEDURE Rev_Op_Resource_VID
        (  p_rev_op_resource_rec     IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec    IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_rev_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_Return_Status           IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
                l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
                l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_err_text              VARCHAR2(2000);
                l_Token_Tbl             Error_Handler.Token_Tbl_Type;
                l_rev_op_res_unexp_rec  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
                                        := p_rev_op_res_unexp_rec ;
        BEGIN

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug('Resource VID conversion . . .');
                END IF;

                --
                -- Convert resource code to reosurce id
                --
                IF p_rev_op_resource_rec.resource_code IS NOT NULL AND
                    p_rev_op_resource_rec.resource_code  <>
                                                        FND_API.G_MISS_CHAR
                THEN

                        l_rev_op_res_unexp_rec.resource_id :=
                        Resource_Id
                        (  p_resource_code            =>
                                  p_rev_op_resource_rec.resource_code
                         , p_organization_id          =>
                                  l_rev_op_res_unexp_rec.organization_id
                         , x_err_text                 => l_err_text
                        );


                        IF l_rev_op_res_unexp_rec.resource_id IS NULL
                        THEN
                                l_token_tbl(1).token_name := 'RESOURCE_CODE';
                                l_token_tbl(1).token_value :=
                                    p_rev_op_resource_rec.resource_code;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                                   'BOM_RES_RESCODE_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                             l_rev_op_res_unexp_rec.resource_id IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                          ('Converted resource code . . .');
                END IF;

                END IF;


                --
                -- Convert activity to activity id
                --

                IF p_rev_op_resource_rec.activity IS NOT NULL AND
                    p_rev_op_resource_rec.activity <> FND_API.G_MISS_CHAR
                THEN
                        l_rev_op_res_unexp_rec.activity_id :=
                          Activity_Id
                         (  p_activity                 =>
                                  p_rev_op_resource_rec.activity
                          , p_organization_id          =>
                                  l_rev_op_res_unexp_rec.organization_id
                          , x_err_text                 => l_err_text
                         );

                        IF l_rev_op_res_unexp_rec.activity_id IS NULL
                        THEN
                                l_token_tbl(1).token_name := 'ACTIVITY';
                                l_token_tbl(1).token_value :=
                                    p_rev_op_resource_rec.activity;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                             'BOM_RES_ACTIVITY_CODE_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                             l_rev_op_res_unexp_rec.activity_id  IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                  G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                          ('Converted activity. . .');
                END IF;


                END IF;

                --
                -- Convert setup code to setup id
                --
                IF p_rev_op_resource_rec.setup_type IS NOT NULL AND
                   p_rev_op_resource_rec.setup_type <> FND_API.G_MISS_CHAR
                THEN
                        l_rev_op_res_unexp_rec.setup_id :=
                         Setup_Id
                         (  p_setup_type               =>
                                  p_rev_op_resource_rec.setup_type
                          , p_organization_id          =>
                                  l_rev_op_res_unexp_rec.organization_id
                          , x_err_text                 => l_err_text
                         );

                        IF l_rev_op_res_unexp_rec.setup_id IS NULL
                        THEN
                                l_token_tbl(1).token_name  := 'SETUP_CODE';
                                l_token_tbl(1).token_value :=
                                         p_rev_op_resource_rec.setup_type ;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                             'BOM_RES_SETUP_CODE_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                              l_rev_op_res_unexp_rec.setup_id IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                  G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                          ('Converted setup code . . .');
                END IF;

                END IF;


                x_return_status := l_return_status;

                IF Bom_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                  ('Return status of  resource VID: ' || l_return_status );
                END IF;

                x_rev_op_res_unexp_rec := l_rev_op_res_unexp_rec;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Rev_Op_Resource_VID;


        /*********************************************************************
        * Procedure     : Sub_Resource_UUI_To_UI
        * Returns       : None
        * Parameters IN : Substitute resource exposed Record
        *                 Substitute resource Unexposed Record
        * Parameters OUT: Substitute resource unexposed record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : Convert Routing Sub Op Resource to Revised Sub Op
        *                 Resource and Call Rev_Sub_resource_UUI_To_UI for ECO Bo.
        *                 After calling Rev_Sub_resource_UUI_To_UI, convert
        *                 Revised Op Resource record back to Routing Op Resource
        *********************************************************************/
        PROCEDURE Sub_Resource_UUI_To_UI
        (  p_sub_resource_rec       IN   Bom_Rtg_Pub.Sub_Resource_Rec_Type
         , p_sub_res_unexp_rec      IN   Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_sub_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )

        IS
                l_rev_sub_resource_rec      Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type ;
                l_rev_sub_res_unexp_rec     Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;
                l_sub_resource_rec          Bom_Rtg_Pub.Sub_Resource_Rec_Type ;

        BEGIN
                -- Convert Routing Operation to ECO Operation
                Bom_Rtg_Pub.Convert_RtgSubRes_To_EcoSubRes
                (  p_rtg_sub_resource_rec      => p_sub_resource_rec
                 , p_rtg_sub_res_unexp_rec     => p_sub_res_unexp_rec
                 , x_rev_sub_resource_rec      => l_rev_sub_resource_rec
                 , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                ) ;

                -- Call Rev_Sub_Resource_UUI_To_UI
                Bom_Rtg_Val_To_Id.Rev_Sub_Resource_UUI_To_UI
                (  p_rev_sub_resource_rec      => l_rev_sub_resource_rec
                 , p_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                 , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                 , x_return_status             => x_return_status
                 , x_mesg_token_tbl            => x_mesg_token_tbl
                ) ;

                -- Convert Eco Sub Resource Record back to Routing Sub Resource
                Bom_Rtg_Pub.Convert_EcoSubRes_To_RtgSubRes
                (  p_rev_sub_resource_rec      => l_rev_sub_resource_rec
                 , p_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                 , x_rtg_sub_resource_rec      => l_sub_resource_rec
                 , x_rtg_sub_res_unexp_rec     => x_sub_res_unexp_rec
                ) ;


        END Sub_Resource_UUI_To_UI ;



        /*********************************************************************
        * Procedure     : Rev_Sub_Resource_UUI_To_UI
        * Returns       : None
        * Parameters IN : Revised Substitute Resource Exposed Record
        *                 Revised Substitute Resource Unexposed Record
        * Parameters OUT: Revised Substitute Resource unexposed record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : This procedure will perform all the required
        *                 User unique to Unique index conversions for
        *                 substitute resource record. Any errors will be
        *                 logged in the Message table and a return satus of
        *                 success or failure will be returned to the calling
        *                 program.
        *********************************************************************/
        PROCEDURE Rev_Sub_Resource_UUI_To_UI
        (  p_rev_sub_resource_rec       IN   Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec      IN   Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_rev_sub_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_return_status              IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         )
        IS
          l_Mesg_Token_Tbl           Error_Handler.Mesg_Token_Tbl_Type;
          l_rev_sub_res_unexp_rec    Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type;
          l_return_status            VARCHAR2(1);
          l_err_text                 VARCHAR2(2000);
          l_cfm_flag                 NUMBER;
          l_Token_Tbl                Error_Handler.Token_Tbl_Type;
	  l_err_text_diff            VARCHAR2(1);

       CURSOR c_Check_Alternate(  p_alt_designator     VARCHAR2,
                                  p_organization_id    NUMBER ) IS
                SELECT 1
                  FROM bom_alternate_designators
                 WHERE alternate_designator_code = p_alt_designator
                   AND organization_id = p_organization_id;

        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_return_status := FND_API.G_RET_STS_SUCCESS;
                l_rev_sub_res_unexp_rec  :=  p_rev_sub_res_unexp_rec ;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                     ('Substitute resource record UUI-UI Conversion . . ');
                END IF;

                --
                -- Assembly Item name cannot be NULL or missing.
                --
                IF p_rev_sub_resource_rec.revised_item_name IS NULL OR
                   p_rev_sub_resource_rec.revised_item_name = FND_API.G_MISS_CHAR
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_SUB_RES_AITEM_KEYCOL_NULL'
                         , p_mesg_token_tbl => l_mesg_token_tbl
                         , x_mesg_token_tbl => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                /* bug:4714714 - Commented the below check on Alternate routing code as
                   creation/updation of alternate resources should be allowed for alternate routings also.
                --
                -- Alternate routing code should be NULL or missing.
                --
                IF p_rev_sub_resource_rec.alternate_routing_code IS NOT NULL AND
                   p_rev_sub_resource_rec.alternate_routing_code <> FND_API.G_MISS_CHAR
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_SUB_RES_ALTER_CD_NOT_NULL'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    );
                    l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;
                */

                --
                --
                -- Sub resource code cannot be NULL or missing.
                -- Sub resource code should exist in BOM_RESOURCE
                --
                IF p_rev_sub_resource_rec.sub_resource_code IS NULL OR
                   p_rev_sub_resource_rec.sub_resource_code = FND_API.G_MISS_CHAR
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name => 'BOM_SUB_RES_CODE_KEYCOL_NULL'
                         , p_mesg_token_tbl => l_mesg_token_tbl
                         , x_mesg_token_tbl => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;

                END IF;

                --
                --
                -- Schedule sequence number cannot be NULL or missing.
                --
--		IF nvl(BOM_Globals.Get_Caller_Type,'') <> 'MIGRATION' THEN
                IF nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number) IS NULL OR
                   nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number)
                                                    = FND_API.G_MISS_NUM
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_SUB_RES_SCHDNM_KEYCOL_NULL'
                         , p_mesg_token_tbl => l_mesg_token_tbl
                         , x_mesg_token_tbl => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
--		END IF; --migration

                --
                --
                -- Operation sequence number cannot be NULL or missing.
                --
                IF p_rev_sub_resource_rec.operation_sequence_number IS NULL OR
                   p_rev_sub_resource_rec.operation_sequence_number
                                                    = FND_API.G_MISS_NUM
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_SUB_RES_OP_SQNM_KEYCOL_NULL'
                         , p_mesg_token_tbl => l_mesg_token_tbl
                         , x_mesg_token_tbl => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                --
                -- Start effective date  cannot be NULL or missing.
                --
                IF p_rev_sub_resource_rec.op_start_effective_date IS NULL OR
                   p_rev_sub_resource_rec.op_start_effective_date
                                                    = FND_API.G_MISS_DATE
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   =>
                                'BOM_SUB_RES_EFFDT_KEYCOL_NULL'
                         , p_mesg_token_tbl => l_mesg_token_tbl
                         , x_mesg_token_tbl => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                     ('Finish Substitute resource record Key Col check. . ');
                END IF;

               --
               -- If key columns are NULL, then return.
               --
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                   x_Return_Status := FND_API.G_RET_STS_ERROR;
                   x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                   RETURN;
               END IF;

                --
                -- Assembly item name must be successfully converted to id.
                --

                l_rev_sub_res_unexp_rec.revised_item_id :=
                Revised_Item (  p_revised_item_num   =>
                                     p_rev_sub_resource_rec.revised_item_name
                               , p_organization_id       =>
                                     l_rev_sub_res_unexp_rec.organization_id
                               , x_err_text              => l_err_text
                               );

                IF l_rev_sub_res_unexp_rec.revised_item_id IS NULL
                THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_rev_sub_resource_rec.revised_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_rev_sub_resource_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name   => 'BOM_RTG_AITEM_DOESNOT_EXIST'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                ELSIF l_err_text IS NOT NULL AND
                  ( l_rev_sub_res_unexp_rec.revised_item_id IS NULL OR
                    l_rev_sub_res_unexp_rec.revised_item_id = FND_API.G_MISS_NUM)
                THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                   ('After converting Assembly Item Id : '
                     || to_char(l_rev_sub_res_unexp_rec.revised_item_id)
                     || ' Status ' || l_return_status);
                END IF;

                IF p_rev_sub_resource_rec.alternate_routing_code IS NOT NULL AND
                p_rev_sub_resource_rec.alternate_routing_code <> FND_API.G_MISS_CHAR
                THEN
                        /*l_err_text_diff*/l_err_text := FND_API.G_RET_STS_ERROR;

                        FOR check_alternate IN
                           c_Check_Alternate
                           ( p_alt_designator  =>
                                    p_rev_sub_resource_rec.alternate_routing_code,
                             p_organization_id =>
                                    l_rev_sub_res_unexp_rec.organization_id )
                        LOOP
                                /*l_err_text_diff*/l_err_text := FND_API.G_RET_STS_SUCCESS;
                        END LOOP;

                        IF /*l_err_text_diff*/l_err_text <> FND_API.G_RET_STS_SUCCESS
                        THEN
                          g_token_tbl(1).token_name  :='ALTERNATE_ROUTING_CODE';
                          g_token_tbl(1).token_value :=
                                     p_rev_sub_resource_rec.alternate_routing_code;
                          g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                          g_token_tbl(2).token_value :=
                                      p_rev_sub_resource_rec.organization_code;
                          Error_Handler.Add_Error_Token
                            ( P_Message_Name   =>
                                        'BOM_RTG_ALT_DESIGNATOR_INVALID'
                            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , p_token_tbl      => g_token_tbl
                                 );

                           l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;

                END IF;


                /****************************************************************
                --
                -- Using the revised item key information, get the routing_sequence_id
                -- and revised item sequence id
                --
                ****************************************************************/
                IF BOM_Rtg_Globals.Get_Bo_Identifier <> BOM_Rtg_Globals.G_RTG_BO
                THEN
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Processing UUI_UI for sub op resources and retrieving rev item seq id . . . ');
END IF;

                    NULL ;

                    /****************************************************************
                    -- Comment out by MK on 12/04/00 to resolve Eco dependency
                    l_rev_sub_res_unexp_rec.revised_item_sequence_id :=
                    RtgAndRevItemSeq
                    (  p_revised_item_id   => l_rev_sub_res_unexp_rec.revised_item_id
                     , p_item_revision     => p_rev_sub_resource_rec.new_revised_item_revision
                     , p_effective_date    => p_rev_sub_resource_rec.op_start_effective_date
                     , p_change_notice     => p_rev_sub_resource_rec.eco_name
                     , p_organization_id   => l_rev_sub_res_unexp_rec.organization_id
                     , p_new_routing_revision  => p_rev_sub_resource_rec.new_routing_revision
                     , p_from_end_item_number  => p_rev_sub_resource_rec.from_end_item_unit_number
                     , x_routing_sequence_id => l_rev_sub_res_unexp_rec.routing_sequence_id
                    );

                    IF l_rev_sub_res_unexp_rec.revised_item_sequence_id IS NULL
                    THEN
                        g_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                        g_Token_Tbl(1).token_value := p_rev_sub_resource_rec.sub_resource_code ;
                        g_Token_Tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
                        g_Token_Tbl(2).token_value := p_rev_sub_resource_rec.schedule_sequence_number ;
                        g_Token_Tbl(3).Token_Name  := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(3).Token_Value := p_rev_sub_resource_rec.revised_item_name;
                        g_token_tbl(4).token_name  := 'ECO_NAME';
                        g_token_tbl(4).token_value := p_rev_sub_resource_rec.eco_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_SUB_RES_RIT_SEQ_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );

                        l_Return_Status  := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_rev_sub_res_unexp_rec := l_rev_sub_res_unexp_rec;
                        x_Return_Status  := l_Return_Status;

                        IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('And this call returned with ' || l_Return_Status); END IF;

                        RETURN;

                    END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Revised Item Sequence Id : ' || to_char(l_rev_sub_res_unexp_rec.revised_item_sequence_id))  ;
END IF ;
                    ****************************************************************/

                ELSE

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Processing UUI_UI for sub op res . . . ');
END IF;
                --
                -- If the calling BO is RTG then get the routing sequence id
                --


                    l_rev_sub_res_unexp_rec.routing_sequence_id :=
                    Routing_Sequence_id
                           (  p_assembly_item_id             =>
                                     l_rev_sub_res_unexp_rec.revised_item_id
                            , p_organization_id              =>
                                     l_rev_sub_res_unexp_rec.organization_id
                            , p_alternate_routing_designator =>
                                     p_rev_sub_resource_rec.alternate_routing_code
                            , x_err_text                     => l_err_text
                           );

                    IF l_rev_sub_res_unexp_rec.routing_sequence_id IS NULL
                    THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_rev_sub_resource_rec.revised_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_rev_sub_resource_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_SUB_RES_RTG_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                    ELSIF l_err_text IS NOT NULL AND
                      (l_rev_sub_res_unexp_rec.routing_sequence_id IS NULL OR
                       l_rev_sub_res_unexp_rec.routing_sequence_id = FND_API.G_MISS_NUM)
                    THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After converting, routing sequence id is '
                     || to_char(l_rev_sub_res_unexp_rec.routing_sequence_id )
                     || ' Status ' || l_return_status);
END IF;

                END IF ;

                -- Added by MK on 12/04/00
                IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO
                THEN

                    --
                    -- For flow routing, operatoin Type should be set in (1, 2, 3)
                    -- For non flow routing,

                    l_cfm_flag := BOM_Rtg_Globals.Get_CFM_Rtg_Flag ;
                    IF   l_cfm_flag IS NULL OR
                          l_cfm_flag  = FND_API.G_MISS_NUM
                    THEN
                          l_cfm_flag := Bom_Rtg_Validate.Get_Flow_Routing_Flag(
                                 p_routing_sequence_id =>
                                l_rev_sub_res_unexp_rec.routing_sequence_id ) ;
                          BOM_Rtg_Globals.Set_CFM_Rtg_Flag(p_cfm_rtg_type => l_cfm_flag) ;
                    END IF;

                    IF l_cfm_flag  = BOM_Rtg_Globals.G_FLOW_RTG
                    THEN
                        IF p_rev_sub_resource_rec.operation_type IS NULL
                        OR p_rev_sub_resource_rec.operation_type = FND_API.G_MISS_NUM
                        OR p_rev_sub_resource_rec.operation_type NOT IN (1, 2, 3)
                        THEN
                            IF p_rev_sub_resource_rec.operation_type <> FND_API.G_MISS_NUM
                            THEN
                                g_token_tbl(1).token_name  := 'OPERATION_TYPE';
                                g_token_tbl(1).token_value :=
                                             p_rev_sub_resource_rec.operation_type;
                            END IF ;

                            Error_Handler.Add_Error_Token
                            (  p_Message_Name     => 'BOM_SUB_RES_FLM_OP_TYP_INVALID'
                             , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                             , p_Token_Tbl        => g_Token_Tbl
                            );
                            l_return_status := FND_API.G_RET_STS_ERROR ;

                        END IF ;
                    ELSE
                        IF  p_rev_sub_resource_rec.operation_type IS NOT NULL
                        AND p_rev_sub_resource_rec.operation_type <> FND_API.G_MISS_NUM
                        AND p_rev_sub_resource_rec.operation_type <> 1
                        THEN
                           g_token_tbl(1).token_name  := 'OPERATION_TYPE';
                           g_token_tbl(1).token_value :=
                                       p_rev_sub_resource_rec.operation_type;
                           Error_Handler.Add_Error_Token
                           (  p_Message_Name    => 'BOM_SUB_RES_STD_OP_TYP_IGNORED'
                            , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                            , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                            , p_Token_Tbl       => g_Token_Tbl
                           );

                           l_return_status := FND_API.G_RET_STS_ERROR ;
                        END IF ;

                    END IF;

                    --
                    -- convert to operation sequence id
                    --

                    l_rev_sub_res_unexp_rec.operation_sequence_id :=
                         Operation_Sequence_id
                           (  p_routing_sequence_id            =>
                                     l_rev_sub_res_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                     p_rev_sub_resource_rec.operation_type
                            , p_operation_seq_num              =>
                                   p_rev_sub_resource_rec.operation_sequence_number
                            , p_effectivity_date =>
                                     p_rev_sub_resource_rec.op_start_effective_date
                            , x_err_text                     => l_err_text
                           );

                    IF l_rev_sub_res_unexp_rec.operation_sequence_id IS NULL
                    THEN
                        g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value :=
                                        p_rev_sub_resource_rec.operation_sequence_number;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_SUB_RES_OP_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                    ELSIF l_err_text IS NOT NULL AND
                        (
                        l_rev_sub_res_unexp_rec.operation_sequence_id  IS NULL OR
                        l_rev_sub_res_unexp_rec.operation_sequence_id =FND_API.G_MISS_NUM
                        )
                       THEN
                             -- This is an unexpected error.
                             Error_Handler.Add_Error_Token
                             (  p_Message_Name       => NULL
                              , p_Message_Text       => l_err_text || ' in ' ||
                                                        G_PKG_NAME
                              , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                              , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             );
                             l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After converting, op sequence id is '
                     || to_char(l_rev_sub_res_unexp_rec.operation_sequence_id )
                     || ' Status ' || l_return_status);
END IF;

                    --
                    -- convert resource code to resource id
                    --
                    IF p_rev_sub_resource_rec.sub_resource_code IS NOT NULL AND
                       p_rev_sub_resource_rec.sub_resource_code  <> FND_API.G_MISS_CHAR
                    THEN
                        l_rev_sub_res_unexp_rec.resource_id :=
                          Resource_Id
                         (  p_resource_code        =>
                                  p_rev_sub_resource_rec.sub_resource_code
                          , p_organization_id          =>
                                  l_rev_sub_res_unexp_rec.organization_id
                          , x_err_text                 => l_err_text
                         );

                        IF l_rev_sub_res_unexp_rec.resource_id  IS NULL
                        THEN
                                l_token_tbl(1).token_name :=
                                        'RESOURCE_CODE';
                                l_token_tbl(1).token_value :=
                                    p_rev_sub_resource_rec.sub_resource_code;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                                   'BOM_SUB_RES_SUB_RES_CD_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                             l_rev_sub_res_unexp_rec.resource_id IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After converting, Resource Id is '
                     || to_char(l_rev_sub_res_unexp_rec.resource_id)
                     || ' Status ' || l_return_status);
END IF;
                    END IF;

                    --
                    -- Set substitute group number
                    --
                    --l_rev_sub_res_unexp_rec.substitute_group_number :=
                    --               p_rev_sub_resource_rec.schedule_sequence_number;

                  IF nvl(Bom_Globals.Get_Caller_Type,'') <> 'MIGRATION' THEN
                    IF not Bom_Rtg_Validate.group_num_exist_In_Op_Res
                                  ( p_substitute_group_number =>
                                    p_rev_sub_resource_rec.substitute_group_number
                                  , p_operation_sequence_id =>
                                    l_rev_sub_res_unexp_rec.operation_sequence_id )
                    THEN
                                l_token_tbl(1).token_name :=
                                        'SUBSTITUTE_GROUP_NUMBER';
                                l_token_tbl(1).token_value :=
                                  p_rev_sub_resource_rec.substitute_group_number ;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                                 'BOM_SUB_RES_RELRES_NOT_FOUND'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;
                  END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After set substitute group num '
                     || to_char(nvl(p_rev_sub_resource_rec.substitute_group_number, l_rev_sub_res_unexp_rec.substitute_group_number))
                     || '  verify it.  Status ' || l_return_status);
END IF;

                END IF; -- Added by MK on 12/04/00 BOM_Rtg_Globals.G_RTG_BO specific

                x_return_status := l_return_status;
                x_rev_sub_res_unexp_rec := l_rev_sub_res_unexp_rec;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Rev_Sub_Resource_UUI_To_UI;


        /*********************************************************************
        * Procedure     : Sub_resource_VID
        * Returns       : None
        * Parameters IN : Substitute resource exposed Record
        *                 Substitute resource Unexposed Record
        * Parameters OUT: Substitute resoruce Unexposed Record
        *                 Return Status
        *                 Message Token Table
        * Purpose       : Convert Routing Sub Op Resource to Revised Sub Op
        *                 Resource and Call Rev_Sub_resource_VID for ECO Bo.
        *                 After calling Rev_Sub_resource_VID, convert
        *                 Revised Sub Op Resource record back to Routing Sub Op Resource
        *********************************************************************/
        PROCEDURE Sub_Resource_VID
        (  p_sub_resource_rec       IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
         , p_sub_res_unexp_rec      IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_sub_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_Return_Status          IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )

        IS
                l_rev_sub_resource_rec      Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type ;
                l_rev_sub_res_unexp_rec     Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;
                l_sub_resource_rec          Bom_Rtg_Pub.Sub_Resource_Rec_Type ;

        BEGIN
                -- Convert Routing Operation to ECO Operation
                Bom_Rtg_Pub.Convert_RtgSubRes_To_EcoSubRes
                (  p_rtg_sub_resource_rec      => p_sub_resource_rec
                 , p_rtg_sub_res_unexp_rec     => p_sub_res_unexp_rec
                 , x_rev_sub_resource_rec      => l_rev_sub_resource_rec
                 , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                ) ;

                -- Call Rev_Sub_resource_UUI_To_UI
                Bom_Rtg_Val_To_Id.Rev_Sub_resource_VID
                (  p_rev_sub_resource_rec      => l_rev_sub_resource_rec
                 , p_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                 , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                 , x_return_status             => x_return_status
                 , x_mesg_token_tbl            => x_mesg_token_tbl
                ) ;

                -- Convert Eco Sub Resource Record back to Routing Sub Resource
                Bom_Rtg_Pub.Convert_EcoSubRes_To_RtgSubRes
                (  p_rev_sub_resource_rec      => l_rev_sub_resource_rec
                 , p_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                 , x_rtg_sub_resource_rec      => l_sub_resource_rec
                 , x_rtg_sub_res_unexp_rec     => x_sub_res_unexp_rec
                ) ;


        END Sub_Resource_VID ;


        /*********************************************************************
        * Procedure     : Rev_Sub_resource_VID
        * Returns       : None
        * Parameters IN : Rev Substitute resource exposed Record
        *                 Rev Substitute resource Unexposed Record
        * Parameters OUT: Rev Substitute resoruce Unexposed Record
        *                 Return Status
        *                 Message Token Table
        * Purpose       : This is the access procedure which the private API
        *                 will call to perform the substitute resource record
        *                 value to ID conversions. If any of the conversions
        *                 fail then the the procedure will return with an error
        *                 status and the messsage token table filled with
        *                 appropriate error message.
        *********************************************************************/
        PROCEDURE Rev_Sub_Resource_VID
        (  p_rev_sub_resource_rec       IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec      IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_rev_sub_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_Return_Status              IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
                l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
                l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_err_text              VARCHAR2(2000);
                l_Token_Tbl             Error_Handler.Token_Tbl_Type;
                l_rev_sub_res_unexp_rec Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
                                        := p_rev_sub_res_unexp_rec ;
        BEGIN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Substitute resource VID conversion . . .');
END IF;

                --
                -- Convert activity to activity id
                --

                IF p_rev_sub_resource_rec.activity IS NOT NULL AND
                   p_rev_sub_resource_rec.activity <> FND_API.G_MISS_CHAR
                THEN

                        l_rev_sub_res_unexp_rec.activity_id :=
                         Activity_Id
                         (  p_activity                 =>
                                  p_rev_sub_resource_rec.activity
                          , p_organization_id          =>
                                  l_rev_sub_res_unexp_rec.organization_id
                          , x_err_text                 => l_err_text
                         );

                        IF l_rev_sub_res_unexp_rec.activity_id IS NULL
                        THEN
                                l_token_tbl(1).token_name :=  'ACTIVITY';
                                l_token_tbl(1).token_value :=
                                    p_rev_sub_resource_rec.activity;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                             'BOM_SUB_RES_ACT_CD_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                             l_rev_sub_res_unexp_rec.activity_id  IS NULL
                        THEN
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                  G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Converted activity id. '|| to_char(l_rev_sub_res_unexp_rec.activity_id) );
END IF;

                END IF;


                --
                -- Convert new resource code to new reosurce id
                --
                IF p_rev_sub_resource_rec.new_sub_resource_code IS NOT NULL AND
                   p_rev_sub_resource_rec.new_sub_resource_code <>
                                                        FND_API.G_MISS_CHAR
                THEN

                        l_rev_sub_res_unexp_rec.new_resource_id :=
                        Resource_Id
                        (  p_resource_code            =>
                                 p_rev_sub_resource_rec.new_sub_resource_code
                         , p_organization_id          =>
                                 l_rev_sub_res_unexp_rec.organization_id
                         , x_err_text                 => l_err_text
                        );


                        IF l_rev_sub_res_unexp_rec.new_resource_id IS NULL
                        THEN
                                l_token_tbl(1).token_name := 'RESOURCE_CODE';
                                l_token_tbl(1).token_value :=
                                    p_rev_sub_resource_rec.new_sub_resource_code ;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                                   'BOM_SUB_RES_SUB_RES_CD_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                              l_rev_sub_res_unexp_rec.new_resource_id IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Converted new sub resource id. ' || to_char(l_rev_sub_res_unexp_rec.new_resource_id) ) ;
END IF;

                END IF;

                --
                -- Convert setup code to setup id
                --
                IF p_rev_sub_resource_rec.setup_type IS NOT NULL AND
                   p_rev_sub_resource_rec.setup_type <> FND_API.G_MISS_CHAR
                THEN
                        l_rev_sub_res_unexp_rec.setup_id :=
                         Setup_Id
                         (  p_setup_type               =>
                                  p_rev_sub_resource_rec.setup_type
                          , p_organization_id          =>
                                  l_rev_sub_res_unexp_rec.organization_id
                          , x_err_text                 => l_err_text
                         );

                        IF l_rev_sub_res_unexp_rec.setup_id IS NULL
                        THEN
                                l_token_tbl(1).token_name  := 'SETUP_CODE';
                                l_token_tbl(1).token_value :=
                                         p_rev_sub_resource_rec.setup_type ;
                                Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                             'BOM_SUB_RES_SETUP_CODE_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_err_text IS NOT NULL AND
                              l_rev_sub_res_unexp_rec.setup_id IS NULL
                        THEN
                                 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text       =>
                                'Unexpected Error ' || l_err_text || ' in ' ||
                                  G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
                        END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug ('Converted setup code . . .');
END IF;

                END IF;


                x_return_status := l_return_status;
                x_rev_sub_res_unexp_rec := l_rev_sub_res_unexp_rec;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Rev_Sub_Resource_VID;


       -- Network
        /*********************************************************************
        * Procedure     : OP_Network_UUI_To_UI
        * Returns       : None
        * Parameters IN : Operation Network exposed exposed Record
        *                 Operation Network Unexposed Record
        * Parameters OUT: Operation Network unexposed record
        *                 Message Token Table
        *                 Return Status
        * Purpose       : This procedure will perform all the required
        *                 User unique to Unique index conversions for
        *                 operation network record. Any errors will be
        *                 logged in the Message table and a return satus of
        *                 success or failure will be returned to the calling
        *                 program.
        *********************************************************************/
        PROCEDURE OP_Network_UUI_To_UI
        ( p_op_network_rec         IN   Bom_Rtg_Pub.Op_Network_Rec_Type
        , p_op_network_unexp_rec   IN   Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , x_op_network_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , x_return_status          IN OUT NOCOPY VARCHAR2
        , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
          l_Mesg_Token_Tbl       Error_Handler.Mesg_Token_Tbl_Type;
          l_op_network_unexp_rec Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type;
          l_return_status        VARCHAR2(1);
          l_err_text             VARCHAR2(2000);
          l_cfm_flag             NUMBER;
	  l_err_text_diff        VARCHAR2(1);

                CURSOR c_Check_Alternate(  p_alt_designator     VARCHAR2,
                                           p_organization_id    NUMBER ) IS
                SELECT 1
                  FROM bom_alternate_designators
                 WHERE alternate_designator_code = p_alt_designator
                   AND organization_id = p_organization_id;

/***BEGIN 1838261***/
	  x_temp_op_rec		 BOM_RTG_Globals.Temp_Op_Rec_Type;
/***END 1838261***/
	l_temp_op_rec_tbl_test   BOM_RTG_Globals.Temp_Op_Rec_Tbl_Type;--for testing by Dev
        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_return_status := FND_API.G_RET_STS_SUCCESS;
                l_op_network_unexp_rec := p_op_network_unexp_rec;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                     ('Operation network record UUI-UI Conversion . . ');
                END IF;

                --
                -- Assembly Item name cannot be NULL or missing.
                --
                IF p_op_network_rec.assembly_item_name IS NULL OR
                   p_op_network_rec.assembly_item_name = FND_API.G_MISS_CHAR
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_OP_NWK_AITEM_KEYCOL_NULL'
                         , p_mesg_token_tbl => l_mesg_token_tbl
                         , x_mesg_token_tbl => l_mesg_token_tbl
                         );

                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

		--
                -- From operation sequence number cannot be NULL or missing.
                --
                IF p_op_network_rec.from_op_seq_number IS NULL OR
                   p_op_network_rec.from_op_seq_number
                                                    = FND_API.G_MISS_NUM
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_OP_NWK_SEQNUM_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    );
                    l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- To operation sequence number cannot be NULL or missing.
                --
                IF p_op_network_rec.to_op_seq_number IS NULL OR
                   p_op_network_rec.to_op_seq_number
                                             = FND_API.G_MISS_NUM
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_OP_NWK_SEQNUM_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    );
                    l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- From start effective date cannot be NULL or missing.
                --
                IF ( p_op_network_rec.from_start_effective_date IS NULL OR
                     p_op_network_rec.from_start_effective_date
                                                    = FND_API.G_MISS_DATE)
                AND ( NVL(p_op_network_rec.operation_type,1) = 1
                      OR p_op_network_rec.operation_type = FND_API.G_MISS_NUM )
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name     => 'BOM_OP_NWK_EFFDT_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                    );
                    l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

                --
                -- To start effective date cannot be NULL or missing.
                --
                IF ( p_op_network_rec.to_start_effective_date IS NULL OR
                     p_op_network_rec.to_start_effective_date
                                                   = FND_API.G_MISS_DATE)
                AND ( NVL(p_op_network_rec.operation_type,1) = 1
                      OR p_op_network_rec.operation_type = FND_API.G_MISS_NUM )
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_Message_Name     => 'BOM_OP_NWK_EFFDT_KEYCOL_NULL'
                    , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                    );
                    l_Return_Status := FND_API.G_RET_STS_ERROR;
                END IF;

               --
               -- If key columns are NULL, then return.
               --

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                   x_Return_Status := FND_API.G_RET_STS_ERROR;
                   x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                   RETURN;
               END IF;


                --
                -- Assembly item name must be successfully converted to id.
                --

                l_op_network_unexp_rec.assembly_item_id :=
                Assembly_Item (  p_assembly_item_name   =>
                                     p_op_network_rec.assembly_item_name
                               , p_organization_id       =>
                                     l_op_network_unexp_rec.organization_id
                               , x_err_text              => l_err_text
                               );

                IF l_op_network_unexp_rec.assembly_item_id IS NULL
                THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_op_network_rec.assembly_item_name;
                        g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                        g_token_tbl(2).token_value :=
                                        p_op_network_rec.organization_code;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name    => 'BOM_RTG_AITEM_DOESNOT EXIST'
                         , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                         , p_Token_Tbl       => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                ELSIF l_err_text IS NOT NULL AND
                  ( l_op_network_unexp_rec.assembly_item_id IS NULL OR
                    l_op_network_unexp_rec.assembly_item_id = FND_API.G_MISS_NUM
                    )
                  THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                   ('After converting Assembly Item Id : '
                     || to_char(l_op_network_unexp_rec.assembly_item_id)
                     || ' Status ' || l_return_status);
                END IF;

                IF p_op_network_rec.alternate_routing_code IS NOT NULL AND
                   p_op_network_rec.alternate_routing_code <> FND_API.G_MISS_CHAR
                THEN
                        /*l_err_text_diff*/l_err_text := FND_API.G_RET_STS_ERROR;

                        FOR check_alternate IN
                           c_Check_Alternate
                           ( p_alt_designator  =>
                                    p_op_network_rec.alternate_routing_code,
                             p_organization_id =>
                                    l_op_network_unexp_rec.organization_id )
                        LOOP
                                /*l_err_text_diff*/l_err_text := FND_API.G_RET_STS_SUCCESS;
                        END LOOP;

                        IF /*l_err_text_diff*/l_err_text <> FND_API.G_RET_STS_SUCCESS
                        THEN
                          g_token_tbl(1).token_name  :='ALTERNATE_ROUTING_CODE';
                          g_token_tbl(1).token_value :=
                                       p_op_network_rec.alternate_routing_code;
                          g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                          g_token_tbl(2).token_value :=
                                       p_op_network_rec.organization_code;
                          Error_Handler.Add_Error_Token
                            ( P_Message_Name   =>
                                       'BOM_RTG_ALT_DESIGNATOR_INVALID'
                            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                            , p_token_tbl      => g_token_tbl
                                 );

                           l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;

                END IF;

                l_op_network_unexp_rec.routing_sequence_id :=
                           Routing_Sequence_id
                           (  p_assembly_item_id             =>
                                     l_op_network_unexp_rec.assembly_item_id
                            , p_organization_id              =>
                                     l_op_network_unexp_rec.organization_id
                            , p_alternate_routing_designator =>
                                     p_op_network_rec.alternate_routing_code
                            , x_err_text                     => l_err_text
                           );

                IF l_op_network_unexp_rec.routing_sequence_id IS NULL
                THEN
                        g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        g_token_tbl(1).token_value :=
                                        p_op_network_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_OP_NWK_RTG_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                ELSIF l_err_text IS NOT NULL AND
                  (l_op_network_unexp_rec.routing_sequence_id IS NULL OR
                   l_op_network_unexp_rec.routing_sequence_id
                                                      = FND_API.G_MISS_NUM)
                THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;

                IF BOM_Rtg_Globals.Get_Debug = 'Y'
                THEN Error_Handler.Write_Debug
                   ('After converting, routing sequence id is '
                     || to_char(l_op_network_unexp_rec.routing_sequence_id )
                     || ' Status ' || l_return_status);
                END IF;

                --
                -- For operation network, CFM flag should be in (1, 3)
                --

                IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag  IS NULL OR
                   BOM_Rtg_Globals.Get_CFM_Rtg_Flag = FND_API.G_MISS_NUM
                THEN
                     l_cfm_flag := Bom_Rtg_Validate.Get_Flow_Routing_Flag(
                                   l_op_network_unexp_rec.routing_sequence_id) ;
                     BOM_Rtg_Globals.Set_CFM_Rtg_Flag(p_cfm_rtg_type => l_cfm_flag) ;

                ELSE  l_cfm_flag := BOM_Rtg_Globals.Get_CFM_Rtg_Flag ;
                END IF;

                /*
                -- For  eAM enhancement, following cfm routing flag validation
                -- is moved to BOM_Validate_Op_Network.Check_Access procedure
                IF  l_cfm_flag  <> BOM_Rtg_Globals.G_FLOW_RTG
                AND l_cfm_flag  <> BOM_Rtg_Globals.G_LOT_RTG
                THEN
                     g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                     g_token_tbl(1).token_value :=
                                          p_op_network_rec.assembly_item_name;
                     Error_Handler.Add_Error_Token
                     (  p_Message_Name       => 'BOM_OP_NWK_RTG_INVALID'
                      , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                      , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                      , p_Token_Tbl          => g_Token_Tbl
                     );
                     l_return_status := FND_API.G_RET_STS_ERROR ;
                END IF ;
                */

                --
                -- For flow routing, operatoin Type should be set in (2, 3)
                --

                IF l_cfm_flag  = BOM_Rtg_Globals.G_FLOW_RTG
                THEN
                   IF p_op_network_rec.operation_type IS NULL
                   OR p_op_network_rec.operation_type = FND_API.G_MISS_NUM
                   OR p_op_network_rec.operation_type NOT IN (2, 3)
                   THEN
                       IF  p_op_network_rec.operation_type <>  FND_API.G_MISS_NUM
                       THEN
                           g_token_tbl(1).token_name  := 'OPERATION_TYPE';
                           g_token_tbl(1).token_value :=
                                             p_op_network_rec.operation_type;
                       END IF ;

                       Error_Handler.Add_Error_Token
                       (  p_Message_Name       => 'BOM_FLM_OP_NWK_TYPE_INVALID'
                        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_Token_Tbl          => g_Token_Tbl
                       );
                       l_return_status := FND_API.G_RET_STS_ERROR ;

                   END IF ;

                ELSIF l_cfm_flag  = BOM_Rtg_Globals.G_LOT_RTG
                OR    l_cfm_flag  = BOM_Rtg_Globals.G_STD_RTG
                THEN
                   IF  p_op_network_rec.operation_type IS NOT NULL
                   AND p_op_network_rec.operation_type <> FND_API.G_MISS_NUM
                   AND p_op_network_rec.operation_type <> 1
                   THEN
                      g_token_tbl(1).token_name  := 'OPERATION_TYPE';
                      g_token_tbl(1).token_value :=
                                       p_op_network_rec.operation_type;
                      Error_Handler.Add_Error_Token
                      (  p_Message_Name       => 'BOM_OP_NWK_OP_TYPE_IGNORED'
                       , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , p_Token_Tbl          => g_Token_Tbl
                      );
                      l_return_status := FND_API.G_RET_STS_ERROR ;
                   END IF ;

                END IF;

               --
               -- If error in CFM routing check, then return.
               --

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                   x_Return_Status := FND_API.G_RET_STS_ERROR;
                   x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                   RETURN;
               END IF;


               --
               -- Get From_operation_sequence_id
               --
--	       BOM_RTG_Globals.Set_Temp_Op_Tbl(l_temp_op_rec_tbl_test);--for testing by Dev

               l_op_network_unexp_rec.from_op_seq_id :=
                    Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  p_op_network_rec.from_op_seq_number
                            , p_effectivity_date            =>
                                  p_op_network_rec.from_start_effective_date
                            , x_err_text                    => l_err_text
                           );
/***BEGIN 1838261***/

	       IF l_op_network_unexp_rec.from_op_seq_id   IS NULL THEN

	       IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_Lot_Rtg THEN

	          IF BOM_RTG_Globals.Get_Temp_Op_Rec1(p_op_network_rec.from_op_seq_number,  p_op_network_rec.from_start_effective_date, x_temp_op_rec) THEN

                     l_op_network_unexp_rec.from_op_seq_id :=
                        Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  x_temp_op_rec.new_op_seq_num
                            , p_effectivity_date            =>
                                  x_temp_op_rec.new_start_eff_date
                            , x_err_text                    => l_err_text
                           );
		  END IF;
		ELSE
		IF BOM_RTG_Globals.Get_Temp_Op_Rec(p_op_network_rec.from_op_seq_number, x_temp_op_rec) THEN
                     l_op_network_unexp_rec.from_op_seq_id :=
                        Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  x_temp_op_rec.new_op_seq_num
                            , p_effectivity_date            =>
                                  x_temp_op_rec.new_start_eff_date
                            , x_err_text                    => l_err_text
                           );
		  END IF;
              END IF;
	       END IF;
/***END 1838261***/

	       IF l_op_network_unexp_rec.from_op_seq_id   IS NULL
               THEN
                        g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value :=
                                        p_op_network_rec.from_op_seq_number;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name     => 'BOM_OP_NWK_FROM_OP_NOT_FOUND'
                         , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                         , p_Token_Tbl        => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
               ELSIF l_err_text IS NOT NULL AND
                  (l_op_network_unexp_rec.from_op_seq_id IS NULL OR
                  l_op_network_unexp_rec.from_op_seq_id
                                                        = FND_API.G_MISS_NUM )
               THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               END IF;

               IF BOM_Rtg_Globals.Get_Debug = 'Y'
               THEN Error_Handler.Write_Debug
                   ('After converting, From Op Seq Id is '
                     || to_char(l_op_network_unexp_rec.from_op_seq_id)
                     || ' Status ' || l_return_status);
               END IF;

               --
               -- Get To_operation_sequence_id
               --
               l_op_network_unexp_rec.to_op_seq_id :=
                    Operation_Sequence_Id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  p_op_network_rec.to_op_seq_number
                            , p_effectivity_date            =>
                                  p_op_network_rec.to_start_effective_date
                            , x_err_text                    => l_err_text
                           );

/***BEGIN 1838261***/

	       IF l_op_network_unexp_rec.to_op_seq_id   IS NULL THEN
		 IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_Lot_Rtg THEN
	          IF BOM_RTG_Globals.Get_Temp_Op_Rec1(p_op_network_rec.to_op_seq_number,  p_op_network_rec.to_start_effective_date, x_temp_op_rec) THEN
		    l_op_network_unexp_rec.to_op_seq_id :=
                        Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  x_temp_op_rec.new_op_seq_num
                            , p_effectivity_date            =>
                                  x_temp_op_rec.new_start_eff_date
                            , x_err_text                    => l_err_text
                           );
		  END IF;
		ELSE
		IF BOM_RTG_Globals.Get_Temp_Op_Rec(p_op_network_rec.to_op_seq_number, x_temp_op_rec) THEN
                     l_op_network_unexp_rec.to_op_seq_id :=
                        Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  x_temp_op_rec.new_op_seq_num
                            , p_effectivity_date            =>
                                  x_temp_op_rec.new_start_eff_date
                            , x_err_text                    => l_err_text
                           );
		  END IF;
              END IF;
	       END IF;
/***END 1838261***/

	       IF l_op_network_unexp_rec.to_op_seq_id   IS NULL
               THEN
                        g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value :=
                                        p_op_network_rec.to_op_seq_number;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_OP_NWK_TO_OP_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;

               ELSIF l_err_text IS NOT NULL AND
                  (l_op_network_unexp_rec.to_op_seq_id IS NULL OR
                  l_op_network_unexp_rec.to_op_seq_id
                                                        = FND_API.G_MISS_NUM )
                  THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               END IF;

               IF BOM_Rtg_Globals.Get_Debug = 'Y'
               THEN Error_Handler.Write_Debug
                   ('After converting, To Op Seq Id is '
                     || to_char(l_op_network_unexp_rec.to_op_seq_id)
                     || ' Status ' || l_return_status);
               END IF;

               --
               -- Get new_from_operation_sequence_id
               --
               IF ( p_op_network_rec.new_from_op_seq_number IS NOT NULL AND
                    p_op_network_rec.new_from_op_seq_number <> FND_API.G_MISS_NUM )
               OR ( p_op_network_rec.new_from_start_effective_date IS NOT NULL AND
                    p_op_network_rec.new_from_start_effective_date <> FND_API.G_MISS_DATE )
               THEN

                    l_op_network_unexp_rec.new_from_op_seq_id :=
                            Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  p_op_network_rec.new_from_op_seq_number
                            , p_effectivity_date            =>
                                  p_op_network_rec.new_from_start_effective_date
                            , x_err_text                    => l_err_text
                           );

/***BEGIN 1838261***/
	       IF l_op_network_unexp_rec.new_from_op_seq_id   IS NULL THEN
	          IF BOM_RTG_Globals.Get_Temp_Op_Rec(p_op_network_rec.new_from_op_seq_number, x_temp_op_rec) THEN
                    l_op_network_unexp_rec.new_from_op_seq_id :=
                            Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  x_temp_op_rec.new_op_seq_num
                            , p_effectivity_date            =>
                                  x_temp_op_rec.new_start_eff_date
                            , x_err_text                    => l_err_text
                           );
		  END IF;
	       END IF;
/***END 1838261***/
                    IF l_op_network_unexp_rec.new_from_op_seq_id IS NULL
                    THEN
			g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value :=
                                        p_op_network_rec.new_from_op_seq_number;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name     => 'BOM_OP_NWK_FROM_OP_NOT_FOUND'
                         , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                         , p_Token_Tbl        => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;

                    ELSIF l_err_text IS NOT NULL AND
                         (l_op_network_unexp_rec.new_from_op_seq_id IS NULL OR
                          l_op_network_unexp_rec.new_from_op_seq_id
                                                        = FND_API.G_MISS_NUM )
                    THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    END IF;

                    IF BOM_Rtg_Globals.Get_Debug = 'Y'
                    THEN Error_Handler.Write_Debug
                       ('After converting, New From Op Seq Id is '
                        || to_char(l_op_network_unexp_rec.new_from_op_seq_id)
                        || ' Status ' || l_return_status);
                    END IF;

               END IF ; -- new_from_op_seq_id

               --
               -- Get new_to_operation_sequence_id
               --
               IF ( p_op_network_rec.new_to_op_seq_number IS NOT NULL AND
                    p_op_network_rec.new_to_op_seq_number <> FND_API.G_MISS_NUM )
               OR ( p_op_network_rec.new_to_start_effective_date IS NOT NULL AND
                    p_op_network_rec.new_to_start_effective_date <> FND_API.G_MISS_DATE )
               THEN

                    l_op_network_unexp_rec.new_to_op_seq_id :=
                            Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  p_op_network_rec.new_to_op_seq_number
                            , p_effectivity_date            =>
                                  p_op_network_rec.new_to_start_effective_date
                            , x_err_text                    => l_err_text
                           );

/***BEGIN 1838261***/
	       IF l_op_network_unexp_rec.new_to_op_seq_id   IS NULL THEN
	          IF BOM_RTG_Globals.Get_Temp_Op_Rec(p_op_network_rec.new_to_op_seq_number, x_temp_op_rec) THEN
                    l_op_network_unexp_rec.new_to_op_seq_id :=
                            Operation_Sequence_id
                           (  p_routing_sequence_id         =>
                                  l_op_network_unexp_rec.routing_sequence_id
                            , p_operation_type              =>
                                  p_op_network_rec.operation_type
                            , p_operation_seq_num           =>
                                  x_temp_op_rec.new_op_seq_num
                            , p_effectivity_date            =>
                                  x_temp_op_rec.new_start_eff_date
                            , x_err_text                    => l_err_text
                           );
		  END IF;
	       END IF;
/***END 1838261***/
                    IF l_op_network_unexp_rec.new_to_op_seq_id IS NULL
                    THEN
                        g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value :=
                                        p_op_network_rec.new_to_op_seq_number;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name     => 'BOM_OP_NWK_TO_OP_NOT_FOUND'
                         , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                         , p_Token_Tbl        => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;

                    ELSIF l_err_text IS NOT NULL AND
                         (l_op_network_unexp_rec.new_to_op_seq_id IS NULL OR
                          l_op_network_unexp_rec.new_to_op_seq_id
                                                        = FND_API.G_MISS_NUM )
                    THEN

                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    END IF;

                    IF BOM_Rtg_Globals.Get_Debug = 'Y'
                    THEN Error_Handler.Write_Debug
                       ('After converting, New To Op Seq Id is '
                        || to_char(l_op_network_unexp_rec.new_to_op_seq_id)
                        || ' Status ' || l_return_status);
                    END IF;

               END IF ; -- to_from_op_seq_id


               x_return_status := l_return_status;
               x_op_network_unexp_rec := l_op_network_unexp_rec;
               x_mesg_token_tbl := l_mesg_token_tbl;

        END OP_Network_UUI_To_UI;



END BOM_Rtg_Val_To_Id;

/
