--------------------------------------------------------
--  DDL for Package Body ENG_ECO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ECO_PUB" AS
/* $Header: ENGBECOB.pls 120.1.12010000.4 2013/07/03 07:47:18 evwang ship $ */



--  Global constant holding the package name
--  HISTORY
--
--  L1:  25-AUG-00   Biao Zhang        ECO enhancement
--       12-AUT-02   Masanori Kimizuka Eng Change Enhancement
--                                     Added Does_ChangeLine_Have_Same_ECO
--                                     Added Does_People_Have_Same_ECO
--                                     Added Process_Eco with New Entities
--       11-DEC-02   Bruno Bontempi    Taken away people processing


G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Eco_PUB';


-- Function Does_Rev_Have_Same_ECO

FUNCTION Does_Rev_Have_Same_ECO
( p_eco_revision_tbl        IN ENG_ECO_PUB.Eco_Revision_Tbl_Type
, p_change_notice       IN VARCHAR2
, p_organization_code       IN VARCHAR2
) RETURN BOOLEAN
IS
table_index     NUMBER;
record_count        NUMBER;
BEGIN
    record_count := p_eco_revision_tbl.COUNT;

    FOR table_index IN 1..record_count
    LOOP
    IF NVL(p_eco_revision_tbl(table_index).ECO_name, FND_API.G_MISS_CHAR) <>
        NVL(p_change_notice, FND_API.G_MISS_CHAR)
       OR
       NVL(p_eco_revision_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
        NVL(p_organization_code, FND_API.G_MISS_CHAR)
    THEN
       RETURN FALSE;
    END IF;
    END LOOP;

    RETURN TRUE;
END Does_Rev_Have_Same_ECO;

-- Function Does_Item_Have_Same_ECO

FUNCTION Does_Item_Have_Same_ECO
( p_revised_item_tbl        IN ENG_ECO_PUB.Revised_Item_Tbl_Type
, p_change_notice       IN VARCHAR2
, p_organization_code       IN VARCHAR2
) RETURN BOOLEAN
IS
table_index     NUMBER;
record_count        NUMBER;
BEGIN
    record_count := p_revised_item_tbl.COUNT;

    FOR table_index IN 1..record_count
    LOOP
    IF NVL(p_revised_item_tbl(table_index).ECO_name, FND_API.G_MISS_CHAR) <>
        NVL(p_change_notice, FND_API.G_MISS_CHAR)
       OR
       NVL(p_revised_item_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
        NVL(p_organization_code, FND_API.G_MISS_CHAR)
    THEN
       RETURN FALSE;
    END IF;
    END LOOP;

    RETURN TRUE;
END Does_Item_Have_Same_ECO;

-- Function Does_Comp_Have_Same_ECO

FUNCTION Does_Comp_Have_Same_ECO
( p_rev_component_tbl       IN BOM_BO_PUB.Rev_Component_Tbl_Type
, p_change_notice       IN VARCHAR2
, p_organization_code       IN VARCHAR2
) RETURN BOOLEAN
IS
table_index     NUMBER;
record_count        NUMBER;
BEGIN
    record_count := p_rev_component_tbl.COUNT;

    FOR table_index IN 1..record_count
    LOOP
    IF NVL(p_rev_component_tbl(table_index).ECO_name, FND_API.G_MISS_CHAR) <>
        NVL(p_change_notice, FND_API.G_MISS_CHAR)
       OR
       NVL(p_rev_component_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
        NVL(p_organization_code, FND_API.G_MISS_CHAR)
    THEN
       RETURN FALSE;
    END IF;
    END LOOP;

    RETURN TRUE;
END Does_Comp_Have_Same_ECO;

-- Function Does_Desg_Have_Same_ECO

FUNCTION Does_Desg_Have_Same_ECO
( p_ref_designator_tbl      IN BOM_BO_PUB.Ref_Designator_Tbl_Type
, p_change_notice       IN VARCHAR2
, p_organization_code       IN VARCHAR2
) RETURN BOOLEAN
IS
table_index     NUMBER;
record_count        NUMBER;
BEGIN
    record_count := p_ref_designator_tbl.COUNT;

    FOR table_index IN 1..record_count
    LOOP
    IF NVL(p_ref_designator_tbl(table_index).ECO_name, FND_API.G_MISS_CHAR) <>
        NVL(p_change_notice, FND_API.G_MISS_CHAR)
       OR
       NVL(p_ref_designator_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
            NVL(p_organization_code, FND_API.G_MISS_CHAR)
    THEN
       RETURN FALSE;
    END IF;
    END LOOP;

    RETURN TRUE;
END Does_Desg_Have_Same_ECO;

-- Function Does_SComp_Have_Same_ECO

FUNCTION Does_SComp_Have_Same_ECO
( p_sub_component_tbl       IN BOM_BO_PUB.Sub_Component_Tbl_Type
, p_change_notice       IN VARCHAR2
, p_organization_code       IN VARCHAR2
) RETURN BOOLEAN
IS
table_index     NUMBER;
record_count        NUMBER;
BEGIN
    record_count := p_sub_component_tbl.COUNT;

    FOR table_index IN 1..record_count
    LOOP
    IF NVL(p_sub_component_tbl(table_index).ECO_name, FND_API.G_MISS_CHAR) <>
        NVL(p_change_notice, FND_API.G_MISS_CHAR)
       OR
       NVL(p_sub_component_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
            NVL(p_organization_code, FND_API.G_MISS_CHAR)
    THEN
       RETURN FALSE;
    END IF;
    END LOOP;

    RETURN TRUE;
END Does_SComp_Have_Same_ECO;

-- L1 The following is added for ECO enhancement
        /********************************************************************
        * Function      : Does_Op_Have_Same_ECO
        * Parameters IN : Revised Operation exposed column record
        *                 change_notice
        *                 Organization Name
        * Parameters OUT: N/A
        * Purpose       : This function is to check all the records have the            *                 same change_notice and same organization.
        *********************************************************************/
        FUNCTION Does_Op_Have_Same_ECO
        ( p_rev_operation_tbl   IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type
        , p_change_notice       IN VARCHAR2
        , p_organization_code   IN VARCHAR2
        ) RETURN BOOLEAN
        IS
                table_index     NUMBER;
                record_count        NUMBER;
        BEGIN
                record_count := p_rev_operation_tbl.COUNT;

                FOR table_index IN 1..record_count
                LOOP
                  IF NVL(p_rev_operation_tbl(table_index).ECO_name,                                    FND_API.G_MISS_CHAR) <>
                              NVL(p_change_notice, FND_API.G_MISS_CHAR)
                     OR
                     NVL(p_rev_operation_tbl(table_index).organization_code,
                           FND_API.G_MISS_CHAR) <>
                              NVL(p_organization_code, FND_API.G_MISS_CHAR)

                  THEN
                    RETURN FALSE;
                  END IF;
                END LOOP;

                RETURN TRUE;
        END Does_Op_Have_Same_ECO;

        /********************************************************************
        * Function      : Does_Res_Have_Same_ECO
        * Parameters IN : Operation resource exposed column record
        *                 change_notice
        *                 Organization Name
        * Parameters OUT: N/A
        * Purpose       : This function is to check all the records have the            *                 same change_notice and same organization.
        *********************************************************************/
        FUNCTION Does_Res_Have_Same_ECO
        ( p_rev_op_resource_tbl IN Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
        , p_change_notice       IN VARCHAR2
        , p_organization_code   IN VARCHAR2
        ) RETURN BOOLEAN
        IS
                table_index         NUMBER;
                record_count        NUMBER;
        BEGIN
                record_count := p_rev_op_resource_tbl.COUNT;

                FOR table_index IN 1..record_count
                LOOP
                  IF NVL(p_rev_op_resource_tbl(table_index).ECO_name,
                           FND_API.G_MISS_CHAR) <>
                           NVL(p_change_notice, FND_API.G_MISS_CHAR)
                           OR
                     NVL(p_rev_op_resource_tbl(table_index).organization_code,
                           FND_API.G_MISS_CHAR) <>
                           NVL(p_organization_code, FND_API.G_MISS_CHAR)
                  THEN
                     RETURN FALSE;
                  END IF;
                END LOOP;

                RETURN TRUE;
       END Does_Res_Have_Same_ECO;

        /********************************************************************
        * Function      : Does_SubRes_Have_Same_ECO
        * Parameters IN : Operation Sub resource exposed column record
        *                 change_notice
        *                 Organization Name
        * Parameters OUT: N/A
        * Purpose       : This function is to check all the records have the            *                 same change_notice and same organization.
        *********************************************************************/
        FUNCTION Does_SubRes_Have_Same_ECO
        ( p_rev_sub_resource_tbl     IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
        , p_change_notice       IN VARCHAR2
        , p_organization_code   IN VARCHAR2
        ) RETURN BOOLEAN
        IS
                table_index     NUMBER;
                record_count    NUMBER;
        BEGIN
                record_count := p_rev_sub_resource_tbl .COUNT;

                FOR table_index IN 1..record_count
                LOOP
                  IF NVL(p_rev_sub_resource_tbl(table_index).ECO_name,
                           FND_API.G_MISS_CHAR) <>
                           NVL(p_change_notice, FND_API.G_MISS_CHAR)
                           OR
                     NVL(p_rev_sub_resource_tbl(table_index).organization_code,                            FND_API.G_MISS_CHAR) <>
                           NVL(p_organization_code, FND_API.G_MISS_CHAR)
                  THEN
                   RETURN FALSE;
                 END IF;
                END LOOP;

                RETURN TRUE;
        END Does_SubRes_Have_Same_ECO;

--L1 The above is added for ECO enhancement


/********************************************************************
* Function      : Does_ChangeLine_Have_Same_ECO
* Parameters IN : Change Line exposed column record
*                 change_notice
*                 Organization Name
* Parameters OUT: N/A
* Purpose       : This function is to check all the records have the
*                 same change_notice and same organization.
*********************************************************************/
FUNCTION Does_ChangeLine_Have_Same_ECO
( p_change_line_tbl     IN  ENG_ECO_PUB.Change_Line_Tbl_Type
, p_change_notice       IN VARCHAR2
, p_organization_code   IN VARCHAR2
) RETURN BOOLEAN
IS
     table_index     NUMBER;
     record_count    NUMBER;
BEGIN
     record_count := p_change_line_tbl.COUNT;

     FOR table_index IN 1..record_count
     LOOP
         IF NVL(p_change_line_tbl(table_index).ECO_name ,FND_API.G_MISS_CHAR) <>
            NVL(p_change_notice, FND_API.G_MISS_CHAR)
         OR
            NVL(p_change_line_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
            NVL(p_organization_code, FND_API.G_MISS_CHAR)
         THEN
                    RETURN FALSE;
         END IF;
     END LOOP;

     RETURN TRUE;
END Does_ChangeLine_Have_Same_ECO ;


-- Function Check_Records_In_Same_ECO

FUNCTION Check_Records_In_Same_ECO
( p_ECO_rec                 IN ENG_ECO_PUB.Eco_Rec_Type
, p_eco_revision_tbl        IN ENG_ECO_PUB.Eco_Revision_Tbl_Type
, p_revised_item_tbl        IN ENG_ECO_PUB.Revised_Item_Tbl_Type
, p_rev_component_tbl       IN BOM_BO_PUB.Rev_Component_Tbl_Type
, p_ref_designator_tbl      IN BOM_BO_PUB.Ref_Designator_Tbl_Type
, p_sub_component_tbl       IN BOM_BO_PUB.Sub_Component_Tbl_Type
, p_rev_operation_tbl       IN Bom_Rtg_Pub.Rev_Operation_Tbl_Type
, p_rev_op_resource_tbl     IN Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
, p_rev_sub_resource_tbl    IN Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
, p_change_line_tbl         IN ENG_ECO_PUB.Change_Line_Tbl_Type -- Eng Change
, x_change_notice       OUT NOCOPY VARCHAR2
, x_organization_code       OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
record_count        NUMBER;
l_organization_code     VARCHAR2(3);
l_change_notice     VARCHAR2(10);
BEGIN
    IF (p_ECO_rec.ECO_name IS NOT NULL AND
        p_ECO_rec.ECO_name <> FND_API.G_MISS_CHAR)
       OR
       (p_ECO_rec.organization_code IS NOT NULL AND
        p_ECO_rec.organization_code <> FND_API.G_MISS_CHAR)
    THEN
        l_change_notice := p_ECO_rec.ECO_name;
        l_organization_code := p_ECO_rec.organization_code;
        x_change_notice := p_ECO_rec.ECO_name;
        x_organization_code := p_ECO_rec.organization_code;

        IF NOT Does_Rev_Have_Same_ECO
                ( p_eco_revision_tbl => p_eco_revision_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;


        -- Eng Change
        IF NOT Does_ChangeLine_Have_Same_ECO
                ( p_change_line_tbl   => p_change_line_tbl
                , p_change_notice     => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Item_Have_Same_ECO
                ( p_revised_item_tbl => p_revised_item_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Comp_Have_Same_ECO
                ( p_rev_component_tbl => p_rev_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Desg_Have_Same_ECO
                ( p_ref_designator_tbl => p_ref_designator_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SComp_Have_Same_ECO
                ( p_sub_component_tbl => p_sub_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

-- L1: The following is added for ECO enhancement
       IF NOT Does_Op_Have_Same_ECO
                ( p_rev_operation_tbl =>p_rev_operation_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Res_Have_Same_ECO
                ( p_rev_op_resource_tbl => p_rev_op_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SubRes_Have_Same_ECO
                ( p_rev_sub_resource_tbl => p_rev_sub_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;
-- L1: The above is added for ECO enhancement


        RETURN TRUE;
    END IF;

    record_count := p_eco_revision_tbl.COUNT;
    IF record_count <> 0
    THEN
        l_change_notice := p_eco_revision_tbl(1).ECO_name;
        l_organization_code := p_eco_revision_tbl(1).organization_code;
        x_change_notice := p_eco_revision_tbl(1).ECO_name;
        x_organization_code := p_eco_revision_tbl(1).organization_code;

        IF record_count > 1
        THEN
            IF NOT Does_Rev_Have_Same_ECO
                ( p_eco_revision_tbl => p_eco_revision_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
            THEN
           RETURN FALSE;
            END IF;
        END IF;

        IF NOT Does_Item_Have_Same_ECO
                ( p_revised_item_tbl => p_revised_item_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;


        -- Eng Change
        IF NOT Does_ChangeLine_Have_Same_ECO
                ( p_change_line_tbl   => p_change_line_tbl
                , p_change_notice     => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Comp_Have_Same_ECO
                ( p_rev_component_tbl => p_rev_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Desg_Have_Same_ECO
                ( p_ref_designator_tbl => p_ref_designator_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SComp_Have_Same_ECO
                ( p_sub_component_tbl => p_sub_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

-- L1: The following is added for ECO enhancement
       IF NOT Does_Op_Have_Same_ECO
                ( p_rev_operation_tbl =>p_rev_operation_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Res_Have_Same_ECO
                ( p_rev_op_resource_tbl => p_rev_op_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SubRes_Have_Same_ECO
                ( p_rev_sub_resource_tbl => p_rev_sub_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;
-- L1: The above is added for ECO enhancement

        RETURN TRUE;
    END IF;

    record_count := p_change_line_tbl.COUNT;
    IF record_count <> 0
    THEN
        l_change_notice := p_change_line_tbl(1).ECO_name;
        l_organization_code := p_change_line_tbl(1).organization_code;
        x_change_notice := p_change_line_tbl(1).ECO_name;
        x_organization_code := p_change_line_tbl(1).organization_code;

        IF record_count > 1
        THEN
            IF NOT Does_ChangeLine_Have_Same_ECO
                ( p_change_line_tbl => p_change_line_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
            THEN
           RETURN FALSE;
            END IF;
        END IF;

        IF NOT Does_Item_Have_Same_ECO
                ( p_revised_item_tbl => p_revised_item_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Comp_Have_Same_ECO
                ( p_rev_component_tbl => p_rev_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Desg_Have_Same_ECO
                ( p_ref_designator_tbl => p_ref_designator_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SComp_Have_Same_ECO
                ( p_sub_component_tbl => p_sub_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

       IF NOT Does_Op_Have_Same_ECO
                ( p_rev_operation_tbl =>p_rev_operation_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Res_Have_Same_ECO
                ( p_rev_op_resource_tbl => p_rev_op_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SubRes_Have_Same_ECO
                ( p_rev_sub_resource_tbl => p_rev_sub_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        RETURN TRUE;
    END IF;


    record_count := p_revised_item_tbl.COUNT;
    IF record_count <> 0
    THEN
        l_change_notice := p_revised_item_tbl(1).ECO_name;
        l_organization_code := p_revised_item_tbl(1).organization_code;
        x_change_notice := p_revised_item_tbl(1).ECO_name;
        x_organization_code := p_revised_item_tbl(1).organization_code;

        IF record_count > 1
        THEN
            IF NOT Does_Item_Have_Same_ECO
                ( p_revised_item_tbl => p_revised_item_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
            THEN
           RETURN FALSE;
            END IF;
        END IF;

        IF NOT Does_Comp_Have_Same_ECO
                ( p_rev_component_tbl => p_rev_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Desg_Have_Same_ECO
                ( p_ref_designator_tbl => p_ref_designator_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SComp_Have_Same_ECO
                ( p_sub_component_tbl => p_sub_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

-- L1: The following is added for ECO enhancement
       IF NOT Does_Op_Have_Same_ECO
                ( p_rev_operation_tbl =>p_rev_operation_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_Res_Have_Same_ECO
                ( p_rev_op_resource_tbl => p_rev_op_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SubRes_Have_Same_ECO
                ( p_rev_sub_resource_tbl => p_rev_sub_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;
-- L1: The above is added for ECO enhancement

        RETURN TRUE;
    END IF;

    record_count := p_rev_component_tbl.COUNT;
    IF record_count <> 0
    THEN
        l_change_notice := p_rev_component_tbl(1).ECO_name;
        l_organization_code := p_rev_component_tbl(1).organization_code;
        x_change_notice := p_rev_component_tbl(1).ECO_name;
        x_organization_code := p_rev_component_tbl(1).organization_code;

        IF record_count > 1
        THEN
        IF NOT Does_Comp_Have_Same_ECO
                ( p_rev_component_tbl => p_rev_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
            END IF;
        END IF;

        IF NOT Does_Desg_Have_Same_ECO
                ( p_ref_designator_tbl => p_ref_designator_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SComp_Have_Same_ECO
                ( p_sub_component_tbl => p_sub_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        RETURN TRUE;
    END IF;

    record_count := p_ref_designator_tbl.COUNT;
    IF record_count <> 0
    THEN
        l_change_notice := p_ref_designator_tbl(1).ECO_name;
        l_organization_code := p_ref_designator_tbl(1).organization_code;
        x_change_notice := p_ref_designator_tbl(1).ECO_name;
        x_organization_code := p_ref_designator_tbl(1).organization_code;

        IF record_count > 1
        THEN
            IF NOT Does_Desg_Have_Same_ECO
                ( p_ref_designator_tbl => p_ref_designator_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
            THEN
           RETURN FALSE;
            END IF;
        END IF;

        IF NOT Does_SComp_Have_Same_ECO
                ( p_sub_component_tbl => p_sub_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        RETURN TRUE;
    END IF;

    IF p_sub_component_tbl.COUNT <> 0
    THEN
        l_change_notice := p_sub_component_tbl(1).ECO_name;
        l_organization_code := p_sub_component_tbl(1).organization_code;
        x_change_notice := p_sub_component_tbl(1).ECO_name;
        x_organization_code := p_sub_component_tbl(1).organization_code;

        IF record_count > 1
        THEN
            IF NOT Does_SComp_Have_Same_ECO
                ( p_sub_component_tbl => p_sub_component_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
            THEN
           RETURN FALSE;
            END IF;
        END IF;

        RETURN TRUE;
    END IF;


-- L1: The following is added for ECO enhancement
    record_count := p_rev_operation_tbl.COUNT;
    IF record_count <> 0
    THEN
        l_change_notice := p_rev_operation_tbl(1).ECO_name;
        l_organization_code := p_rev_operation_tbl(1).organization_code;
        x_change_notice := p_rev_operation_tbl(1).ECO_name;
        x_organization_code := p_rev_operation_tbl(1).organization_code;

        IF record_count > 1
        THEN
           IF NOT Does_Op_Have_Same_ECO
                ( p_rev_operation_tbl =>p_rev_operation_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
           THEN
             RETURN FALSE;
           END IF;
        END IF;

        IF NOT Does_Res_Have_Same_ECO
                ( p_rev_op_resource_tbl => p_rev_op_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;

        IF NOT Does_SubRes_Have_Same_ECO
                ( p_rev_sub_resource_tbl => p_rev_sub_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
        THEN
           RETURN FALSE;
        END IF;
      END IF;

    record_count := p_rev_op_resource_tbl.COUNT;
    IF record_count <> 0
    THEN
        l_change_notice := p_rev_op_resource_tbl(1).ECO_name;
        l_organization_code := p_rev_op_resource_tbl(1).organization_code;
        x_change_notice := p_rev_op_resource_tbl(1).ECO_name;
        x_organization_code := p_rev_op_resource_tbl(1).organization_code;

        IF record_count > 1
        THEN
          IF NOT Does_Res_Have_Same_ECO
                ( p_rev_op_resource_tbl => p_rev_op_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
          THEN
            RETURN FALSE;
          END IF;
        END IF;
      END IF;

    record_count := p_rev_sub_resource_tbl.COUNT;
    IF record_count <> 0
    THEN
        l_change_notice := p_rev_sub_resource_tbl(1).ECO_name;
        l_organization_code := p_rev_sub_resource_tbl(1).organization_code;
        x_change_notice := p_rev_sub_resource_tbl(1).ECO_name;
        x_organization_code := p_rev_sub_resource_tbl(1).organization_code;

        IF record_count > 1
        THEN
          IF NOT Does_SubRes_Have_Same_ECO
                ( p_rev_sub_resource_tbl => p_rev_sub_resource_tbl
                , p_change_notice => l_change_notice
                , p_organization_code => l_organization_code
                )
          THEN
           RETURN FALSE;
          END IF;
       END IF;
    END IF;


-- END IF;

-- L1: The above is added for ECO enhancement
    --
    -- If nothing to process then return TRUE.
    --
    RETURN TRUE;

END Check_Records_In_Same_ECO;

--Added for bug 5862743
-- Whenever a change number is required, lock the row, get the values, update the row
-- and commit the transaction. A new transaction is started here as we need to keep the lock
-- for as short duration as possible...
FUNCTION GET_NEXT_CHANGE_NUMBER(p_type_id NUMBER) RETURN eng_engineering_changes.CHANGE_NOTICE%TYPE
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_change_number		eng_engineering_changes.CHANGE_NOTICE%TYPE := NULL;
BEGIN
   	select alpha_prefix||next_available_number
		INTO l_change_number
		from eng_auto_number_ecn
		where change_type_id = p_type_id FOR UPDATE OF next_available_number;

		update eng_auto_number_ecn
		set next_available_number = next_available_number+1
		-- 14148324, add the two column value
		, last_updated_by  = FND_GLOBAL.user_id
		, last_update_date = sysdate
		where change_type_id = p_type_id;

    COMMIT;

     RETURN l_change_number;
END;



  /********************************************************************
  * API Type      : Local APIs
  * API Name	  : Autogen_Change_Number
  * Purpose       : This API is used to generate the change number based
  on the auto_numbering method.
  a) Sequence generated   b) Inherited from parent  c) User Entered
  *********************************************************************/

FUNCTION Autogen_Change_Number
( P_CHANGE_MGMT_TYPE_NAME	IN VARCHAR2,
  P_CHANGE_ORDER_TYPE		IN VARCHAR2)
RETURN VARCHAR2 IS

  l_type_id			NUMBER;
  l_auto_number_method		eng_change_order_types.AUTO_NUMBERING_METHOD%TYPE;
  l_change_number		eng_engineering_changes.CHANGE_NOTICE%TYPE := NULL;

  -- Added for Bug 3542172

  l_change_type_name		eng_change_order_types_tl.type_name%TYPE := NULL;

  /* Cursor to fetch the change type name for change order based seeded category */
  CURSOR c_change_order_cat_type IS
  SELECT ecotv_in.type_name
  FROM eng_change_order_types_vl ecotv_in
  WHERE ecotv_in.change_mgmt_type_code = 'CHANGE_ORDER'
  AND ecotv_in.type_classification='CATEGORY';

  -- End changes for Bug 3542172

  CURSOR c_change_type_detail(
	cp_change_type_name IN eng_change_order_types_tl.type_name%TYPE)
  IS
  SELECT ecotv1.change_order_type_id change_mgmt_type_id,
	ecotv2.change_order_type_id,
	ecotv2.auto_numbering_method,
	ecotv1.auto_numbering_method change_mgmt_method
  FROM eng_change_order_types_vl  ecotv1, eng_change_order_types_vl ecotv2
  WHERE ecotv1.type_name  = cp_change_type_name
  AND ecotv1.TYPE_CLASSIFICATION= 'CATEGORY'
  AND ecotv1.change_mgmt_type_code = ecotv2.change_mgmt_type_code
  AND ecotv2.type_name = p_CHANGE_ORDER_TYPE
  AND ecotv2.TYPE_CLASSIFICATION = 'HEADER';

BEGIN
	-- Added for Bug 3542172: Defaulting type_name if P_CHANGE_MGMT_TYPE_NAME is null

	l_change_type_name := P_CHANGE_MGMT_TYPE_NAME;

	IF l_change_type_name IS NULL
	THEN
		OPEN c_change_order_cat_type;
		FETCH c_change_order_cat_type INTO l_change_type_name;
		CLOSE c_change_order_cat_type;
	END IF;

	-- End changes for Bug 3542172

	FOR CTD IN c_change_type_detail(l_change_type_name)
	LOOP
		IF (CTD.auto_numbering_method = 'INH_PAR')
		THEN
			l_type_id := CTD.change_mgmt_type_id;
			l_auto_number_method := CTD.change_mgmt_method;
		ELSE
			l_type_id := CTD.change_order_type_id;
			l_auto_number_method := CTD.auto_numbering_method;
		END IF;

		IF (l_auto_number_method = 'USR_ENT')
		THEN
			return null;
		ELSIF (l_auto_number_method = 'SEQ_GEN')
		THEN

			l_change_number := GET_NEXT_CHANGE_NUMBER(l_type_id); --bug 5862743

			/*
			commented for bug 5862743, moved logic to GET_NEXT_CHANGE_NUMBER
			select alpha_prefix||next_available_number
			INTO l_change_number
			from eng_auto_number_ecn
			where change_type_id = l_type_id;

			update eng_auto_number_ecn
			set next_available_number = next_available_number+1
			where change_type_id = l_type_id;
			*/
		END IF;
	END LOOP;
	return l_change_number;
EXCEPTION
WHEN OTHERS THEN
	IF (c_change_order_cat_type%ISOPEN)
	THEN
		CLOSE c_change_order_cat_type;
	END IF;
	return l_change_number;
END Autogen_Change_Number;


  /********************************************************************
  * API Type      : Local APIs
  * API Name	  : Populate_Bo_Tables
  * Purpose       : This API is used to populate the autogenerated change
  number for PLM records if it is null in the BO tables as it is required
  field.
  *********************************************************************/

PROCEDURE Populate_Bo_Tables
( p_ECO_rec                 IN OUT NOCOPY ENG_ECO_PUB.Eco_Rec_Type
, p_eco_revision_tbl        IN OUT NOCOPY ENG_ECO_PUB.Eco_Revision_Tbl_Type
, p_revised_item_tbl        IN OUT NOCOPY ENG_ECO_PUB.Revised_Item_Tbl_Type
, p_rev_component_tbl       IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
, p_ref_designator_tbl      IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
, p_sub_component_tbl       IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
, p_rev_operation_tbl       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type
, p_rev_op_resource_tbl     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
, p_rev_sub_resource_tbl    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
, p_change_line_tbl         IN OUT NOCOPY ENG_ECO_PUB.Change_Line_Tbl_Type )
IS
record_count	NUMBER;
BEGIN
	-- Populate ECO revision change number
	record_count := p_eco_revision_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_eco_revision_tbl(table_index).ECO_name IS NULL
		    AND p_eco_revision_tbl(table_index).transaction_type = 'CREATE')
		THEN
			p_eco_revision_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
	-- Populate revised item change number
	record_count := p_revised_item_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_revised_item_tbl(table_index).ECO_name IS NULL
		    AND UPPER(p_revised_item_tbl(table_index).transaction_type) = 'CREATE')
		THEN
			p_revised_item_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
	-- Populate Revised components change number
	record_count := p_rev_component_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_rev_component_tbl(table_index).ECO_name IS NULL
		    AND UPPER(p_rev_component_tbl(table_index).transaction_type) = 'CREATE')
		THEN
			p_rev_component_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
	-- Populate reference designators change number
	record_count := p_ref_designator_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_ref_designator_tbl(table_index).ECO_name IS NULL
		    AND UPPER(p_ref_designator_tbl(table_index).transaction_type) = 'CREATE')
		THEN
			p_ref_designator_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
	-- Populate substitute components change number
	record_count := p_sub_component_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_sub_component_tbl(table_index).ECO_name IS NULL
		    AND UPPER(p_sub_component_tbl(table_index).transaction_type) = 'CREATE')
		THEN
			p_sub_component_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
	-- populate revised operations change number
	record_count := p_rev_operation_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_rev_operation_tbl(table_index).ECO_name IS NULL
		    AND UPPER(p_rev_operation_tbl(table_index).transaction_type) = 'CREATE')
		THEN
			p_rev_operation_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
	-- populate revised operation resources change number
	record_count := p_rev_op_resource_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_rev_op_resource_tbl(table_index).ECO_name IS NULL
		    AND UPPER(p_rev_op_resource_tbl(table_index).transaction_type) = 'CREATE')
		THEN
			p_rev_op_resource_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
	-- populate revised resources change number
	record_count := p_rev_sub_resource_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_rev_sub_resource_tbl(table_index).ECO_name IS NULL
		    AND UPPER(p_rev_sub_resource_tbl(table_index).transaction_type) = 'CREATE')
		THEN
			p_rev_sub_resource_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
	-- populate change lines' change number
	record_count := p_change_line_tbl.COUNT;
	FOR table_index IN 1..record_count
	LOOP
		IF (p_change_line_tbl(table_index).ECO_name IS NULL
		    AND UPPER(p_change_line_tbl(table_index).transaction_type) = 'CREATE')
		THEN
			p_change_line_tbl(table_index).ECO_name := p_eco_rec.eco_name;
		END IF;
	END LOOP;
END Populate_Bo_Tables;


PROCEDURE Process_Eco
(   p_api_version_number        IN  NUMBER  := 1.0
,   p_init_msg_list             IN  BOOLEAN := FALSE
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_msg_count                 OUT NOCOPY NUMBER
,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
,   p_ECO_rec                   IN  Eco_Rec_Type :=
                                    G_MISS_ECO_REC
,   p_eco_revision_tbl          IN  Eco_Revision_Tbl_Type :=
                                    G_MISS_ECO_REVISION_TBL
,   p_revised_item_tbl          IN  Revised_Item_Tbl_Type :=
                                    G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl         IN  Bom_Bo_Pub.Rev_Component_Tbl_Type :=
                                    G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl        IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type :=
                                    G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl         IN  Bom_Bo_Pub.Sub_Component_Tbl_Type :=
                                    G_MISS_SUB_COMPONENT_TBL
,   p_rev_operation_tbl         IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type:=    --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL    --L1
,   p_rev_op_resource_tbl       IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type:=  --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL  --L1
,   p_rev_sub_resource_tbl      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type:= --L1
                                    Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL --L1
,   x_ECO_rec                   IN OUT NOCOPY Eco_Rec_Type
,   x_eco_revision_tbl          IN OUT NOCOPY Eco_Revision_Tbl_Type
,   x_revised_item_tbl          IN OUT NOCOPY Revised_Item_Tbl_Type
,   x_rev_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
,   x_ref_designator_tbl        IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
,   x_sub_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type
,   x_rev_operation_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type    --L1--
,   x_rev_op_resource_tbl       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type  --L1--
,   x_rev_sub_resource_tbl      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type --L1--
,   p_debug                     IN  VARCHAR2 := 'N'
,   p_output_dir                IN  VARCHAR2 := NULL
,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
,   p_skip_nir_expl             IN  VARCHAR2 DEFAULT FND_API.G_FALSE  -- bug 15831337: skip nir explosion flag
)
IS

l_change_line_tbl       Change_Line_Tbl_Type;

BEGIN


    -- Call New Eng BO Process Eco for Eng Change Mgmt Enhancement
    Process_Eco
    (   p_api_version_number        => p_api_version_number
    ,   p_init_msg_list             => p_init_msg_list
    ,   x_return_status             => x_return_status
    ,   x_msg_count                 => x_msg_count
    ,   p_bo_identifier             => p_bo_identifier
    ,   p_ECO_rec                   => p_ECO_rec
    ,   p_eco_revision_tbl          => p_eco_revision_tbl
    ,   p_change_line_tbl           => l_change_line_tbl -- Eng Change
    ,   p_revised_item_tbl          => p_revised_item_tbl
    ,   p_rev_component_tbl         => p_rev_component_tbl
    ,   p_ref_designator_tbl        => p_ref_designator_tbl
    ,   p_sub_component_tbl         => p_sub_component_tbl
    ,   p_rev_operation_tbl         => p_rev_operation_tbl
    ,   p_rev_op_resource_tbl       => p_rev_op_resource_tbl
    ,   p_rev_sub_resource_tbl      => p_rev_sub_resource_tbl
    ,   x_ECO_rec                   => x_ECO_rec
    ,   x_eco_revision_tbl          => x_eco_revision_tbl
    ,   x_change_line_tbl           => l_change_line_tbl  -- Eng Change
    ,   x_revised_item_tbl          => x_revised_item_tbl
    ,   x_rev_component_tbl         => x_rev_component_tbl
    ,   x_ref_designator_tbl        => x_ref_designator_tbl
    ,   x_sub_component_tbl         => x_sub_component_tbl
    ,   x_rev_operation_tbl         => x_rev_operation_tbl
    ,   x_rev_op_resource_tbl       => x_rev_op_resource_tbl
    ,   x_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
    ,   p_debug                     => p_debug
    ,   p_output_dir                => p_output_dir
    ,   p_skip_nir_expl             => p_skip_nir_expl  -- bug 15831337: skip nir explosion flag
    ) ;

END Process_Eco;


PROCEDURE Process_Eco
(   p_api_version_number        IN  NUMBER  := 1.0
,   p_init_msg_list             IN  BOOLEAN := FALSE
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_msg_count                 OUT NOCOPY NUMBER
,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
,   p_ECO_rec                   IN  Eco_Rec_Type :=
                                    G_MISS_ECO_REC
,   p_eco_revision_tbl          IN  Eco_Revision_Tbl_Type :=
                                    G_MISS_ECO_REVISION_TBL
,   p_change_line_tbl           IN  Change_Line_Tbl_Type :=   -- Eng Change
                                    G_MISS_CHANGE_LINE_TBL
,   p_revised_item_tbl          IN  Revised_Item_Tbl_Type :=
                                    G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl         IN  Bom_Bo_Pub.Rev_Component_Tbl_Type :=
                                    G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl        IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type :=
                                    G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl         IN  Bom_Bo_Pub.Sub_Component_Tbl_Type :=
                                    G_MISS_SUB_COMPONENT_TBL
,   p_rev_operation_tbl         IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type:=    --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL    --L1
,   p_rev_op_resource_tbl       IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type:=  --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL  --L1
,   p_rev_sub_resource_tbl      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type:= --L1
                                    Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL --L1
,   x_ECO_rec                   IN OUT NOCOPY Eco_Rec_Type
,   x_eco_revision_tbl          IN OUT NOCOPY Eco_Revision_Tbl_Type
,   x_change_line_tbl           IN OUT NOCOPY Change_Line_Tbl_Type           -- Eng Change
,   x_revised_item_tbl          IN OUT NOCOPY Revised_Item_Tbl_Type
,   x_rev_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
,   x_ref_designator_tbl        IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
,   x_sub_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type
,   x_rev_operation_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type    --L1--
,   x_rev_op_resource_tbl       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type  --L1--
,   x_rev_sub_resource_tbl      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type --L1--
,   p_debug                     IN  VARCHAR2 := 'N'
,   p_output_dir                IN  VARCHAR2 := NULL
,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
,   p_skip_nir_expl             IN  VARCHAR2 DEFAULT FND_API.G_FALSE  -- bug 15831337: skip nir explosion flag
)
IS
G_EXC_SEV_QUIT_OBJECT       EXCEPTION;
G_EXC_UNEXP_SKIP_OBJECT     EXCEPTION;

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_err_text              VARCHAR2(2000);
l_return_status         VARCHAR2(1);

l_change_notice         VARCHAR2(10);
l_organization_code     VARCHAR2(3);
l_organization_id       NUMBER;

l_ECO_rec               Eco_Rec_Type;
l_eco_revision_tbl      Eco_Revision_Tbl_Type;
l_revised_item_tbl      Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type;     -- L1--
l_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;   -- L1--
l_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;  -- L1--

-- Eng Change
l_change_line_tbl       Change_Line_Tbl_Type;
l_disable_revision       NUMBER; --BUG 3034642

l_p_ECO_rec               Eco_Rec_Type;
l_p_eco_revision_tbl      Eco_Revision_Tbl_Type;
l_p_revised_item_tbl      Revised_Item_Tbl_Type;
l_p_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_p_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_p_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_p_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type;     -- L1--
l_p_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;   -- L1--
l_p_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;  -- L1--
l_p_change_line_tbl       Change_Line_Tbl_Type;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_p_ECO_rec		     :=  p_eco_rec;
    l_p_eco_revision_tbl     :=  p_eco_revision_tbl;
    l_p_revised_item_tbl     :=  p_revised_item_tbl;
    l_p_rev_component_tbl    :=  p_rev_component_tbl;
    l_p_ref_designator_tbl   :=  p_ref_designator_tbl;
    l_p_sub_component_tbl    :=  p_sub_component_tbl;
    l_p_rev_operation_tbl    :=  p_rev_operation_tbl;
    l_p_rev_op_resource_tbl  :=  p_rev_op_resource_tbl;
    l_p_rev_sub_resource_tbl :=  p_rev_sub_resource_tbl;
    l_p_change_line_tbl      :=  p_change_line_tbl;


    --dbms_output.enable(1000000);

    IF p_debug = 'Y'
    THEN
        BOM_Globals.Set_Debug(p_debug);
        BOM_Rtg_Globals.Set_Debug(p_debug) ; -- Added by MK on 11/08/00

        Error_Handler.Open_Debug_Session
        (  p_debug_filename     => p_debug_filename
         , p_output_dir         => p_output_dir
         , x_return_status      => l_return_status
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_mesg_token_tbl
         );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                BOM_Globals.Set_Debug('N');
                BOM_Rtg_Globals.Set_Debug('N'); -- Added by MK on 11/08/00
        END IF;
    END IF;
    --
    -- Set Business Object Idenfier in the System Information record.
    --
    Eng_Globals.Set_Bo_Identifier(p_bo_identifier       => p_bo_identifier);
    Bom_Globals.Set_Bo_Identifier(p_bo_identifier => p_bo_identifier); --bug 13619324

    IF p_init_msg_list
    THEN
        Error_Handler.Initialize;
    END IF;


    -- Bug 3357450
    -- For PLM changes , if change_notice is null then generate the number using auto_numbering_methos set for the type.
    IF (NVL (l_p_ECO_rec.plm_or_erp_change, 'PLM') = 'PLM'
        AND l_p_ECO_rec.Eco_Name IS NULL
	AND UPPER(l_p_ECO_rec.transaction_type) = 'CREATE')
    THEN
	--Generate the change_notice
	l_p_ECO_rec.Eco_Name := Autogen_Change_Number(l_p_ECO_rec.Change_Management_Type, l_p_ECO_rec.Change_Type_Code);
	--For PLM change_name is mandatory
	IF (l_p_ECO_rec.Change_Name IS NULL OR l_p_ECO_rec.change_name = FND_API.G_MISS_CHAR)
	THEN
		l_p_ECO_rec.Change_Name := l_p_ECO_rec.Eco_Name;
	END IF;
	-- Populate the other BO tables if eco_name is not null
	IF (l_p_ECO_rec.Eco_Name IS NOT NULL)
	THEN
	    Populate_Bo_tables
            ( p_ECO_rec			=> l_p_ECO_rec
            , p_eco_revision_tbl	=> l_p_eco_revision_tbl
            , p_revised_item_tbl	=> l_p_revised_item_tbl
            , p_rev_component_tbl	=> l_p_rev_component_tbl
            , p_ref_designator_tbl	=> l_p_ref_designator_tbl
            , p_sub_component_tbl	=> l_p_sub_component_tbl
            , p_rev_operation_tbl	=> l_p_rev_operation_tbl      -- L1--
            , p_rev_op_resource_tbl	=> l_p_rev_op_resource_tbl    -- L1--
            , p_rev_sub_resource_tbl	=> l_p_rev_sub_resource_tbl   -- L1--
            , p_change_line_tbl		=> l_p_change_line_tbl        -- Eng Change
	    );
	END IF;
    END IF;
    -- End Changes for bug 3357450


    IF NOT Check_Records_In_Same_ECO
            ( p_ECO_rec => l_p_ECO_rec
            , p_eco_revision_tbl => l_p_eco_revision_tbl
            , p_revised_item_tbl => l_p_revised_item_tbl
            , p_rev_component_tbl => l_p_rev_component_tbl
            , p_ref_designator_tbl => l_p_ref_designator_tbl
            , p_sub_component_tbl => l_p_sub_component_tbl
            , p_rev_operation_tbl => l_p_rev_operation_tbl        -- L1--
            , p_rev_op_resource_tbl => l_p_rev_op_resource_tbl    -- L1--
            , p_rev_sub_resource_tbl=> l_p_rev_sub_resource_tbl   -- L1--
            , p_change_line_tbl => l_p_change_line_tbl            -- Eng Change
            , x_change_notice => l_change_notice
            , x_organization_code => l_organization_code
            )
    THEN
        l_other_message := 'ENG_MUST_BE_IN_SAME_ECO';
        RAISE G_EXC_SEV_QUIT_OBJECT;
    END IF;

    IF (l_change_notice IS NULL OR
        l_change_notice = FND_API.G_MISS_CHAR)
       OR
       (l_organization_code IS NULL OR
        l_organization_code = FND_API.G_MISS_CHAR)
    THEN
        l_other_message := 'ENG_CHG_NOT_ORG_MISSING';
        RAISE G_EXC_SEV_QUIT_OBJECT;
    END IF;

    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('organization_code: ' || l_organization_code); END IF;
        l_organization_id :=
        ENG_Val_To_Id.Organization
        ( p_organization => l_organization_code
        , x_err_text => l_err_text
        );

    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('organization_id: ' || to_char(l_organization_id)); END IF;
    IF l_organization_id IS NULL
    THEN
        l_other_message := 'ENG_ORG_INVALID';
        l_token_tbl(1).token_name := 'ORG_CODE';
        l_token_tbl(1).token_value := l_organization_code;
        RAISE G_EXC_SEV_QUIT_OBJECT;

    ELSIF l_organization_id = FND_API.G_MISS_NUM
    THEN
        l_other_message := 'ENG_UNEXP_ORG_INVALID';
        RAISE G_EXC_UNEXP_SKIP_OBJECT;
    END IF;

    -- Now using the set functions. Changed by RC 06/23/99
    --    ENG_GLOBALS.system_information.org_id := l_organization_id;
    --
    Eng_Globals.Set_Org_Id( p_org_id    => l_organization_id);


        --------------------------------------
        -- Call Private API
        --------------------------------------
        ENG_ECO_PVT.Process_Eco
        (   p_api_version_number     => p_api_version_number
        ,   x_return_status          => l_return_status
        ,   x_msg_count              => x_msg_count
        ,   p_ECO_rec                => l_p_ECO_rec
        ,   p_eco_revision_tbl       => l_p_eco_revision_tbl
        ,   p_change_line_tbl        => l_p_change_line_tbl -- Eng Change
        ,   p_revised_item_tbl       => l_p_revised_item_tbl
        ,   p_rev_component_tbl      => l_p_rev_component_tbl
        ,   p_ref_designator_tbl     => l_p_ref_designator_tbl
        ,   p_sub_component_tbl      => l_p_sub_component_tbl
        ,   p_rev_operation_tbl      => l_p_rev_operation_tbl    --L1
        ,   p_rev_op_resource_tbl    => l_p_rev_op_resource_tbl  --L1
        ,   p_rev_sub_resource_tbl   => l_p_rev_sub_resource_tbl --L1
        ,   x_ECO_rec                => x_ECO_rec
        ,   x_eco_revision_tbl       => x_eco_revision_tbl
        ,   x_change_line_tbl        => x_change_line_tbl  -- Eng Change
        ,   x_revised_item_tbl       => x_revised_item_tbl
        ,   x_rev_component_tbl      => x_rev_component_tbl
        ,   x_ref_designator_tbl     => x_ref_designator_tbl
        ,   x_sub_component_tbl      => x_sub_component_tbl
        ,   x_rev_operation_tbl      => x_rev_operation_tbl    --L1
        ,   x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
        ,   x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
	      ,   x_disable_revision       => l_disable_revision  --BUG 3034642
	      ,   p_skip_nir_expl          => p_skip_nir_expl  -- bug 15831337: skip nir explosion flag
        );

        /* Now using the set function. Changed by RC 06/23/99
        ENG_GLOBALS.system_information.org_id := NULL;
        ENG_GLOBALS.system_information.ECO_Name := NULL;
        */

        Eng_Globals.Set_Org_Id( p_org_id        => NULL);
        Eng_Globals.Set_Eco_Name( p_eco_name    => NULL);

        IF l_return_status <> 'S'
        THEN
                -- Call Error Handler

                l_token_tbl(1).token_name := 'ECO_NAME';
                l_token_tbl(1).token_value := l_change_notice;
                l_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                l_token_tbl(2).token_value := l_organization_code;

                Eco_Error_Handler.Log_Error
                ( p_error_status => l_return_status
                , p_error_scope => Error_Handler.G_SCOPE_ALL
                , p_error_level => Error_Handler.G_BO_LEVEL
                , p_other_message => 'ENG_ERROR_BUSINESS_OBJECT'
                , p_other_status => l_return_status
                , p_other_token_tbl => l_token_tbl
                , x_eco_rec => l_eco_rec
                , x_eco_revision_tbl  => l_eco_revision_tbl
                , x_change_line_tbl   => l_change_line_tbl -- Eng Change
                , x_revised_item_tbl  => l_revised_item_tbl
                , x_rev_component_tbl => l_rev_component_tbl
                , x_ref_designator_tbl=> l_ref_designator_tbl
                , x_sub_component_tbl => l_sub_component_tbl
                , x_rev_operation_tbl => l_rev_operation_tbl         --L1
                , x_rev_op_resource_tbl    => l_rev_op_resource_tbl  --L1
                , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl --L1
                );
        END IF;

        x_return_status := l_return_status;
        x_msg_count := Error_Handler.Get_Message_Count;

        IF Bom_Globals.Get_Debug = 'Y'
        THEN
                Error_Handler.Close_Debug_Session;
        END IF;

    EXCEPTION
        WHEN G_EXC_SEV_QUIT_OBJECT THEN

        -- Call Error Handler

        Eco_Error_Handler.Log_Error
                        ( p_eco_rec => p_eco_rec
                        , p_eco_revision_tbl   => p_eco_revision_tbl
                        , p_change_line_tbl    => p_change_line_tbl -- Eng Change
                        , p_revised_item_tbl   => p_revised_item_tbl
                        , p_rev_component_tbl  => p_rev_component_tbl
                        , p_ref_designator_tbl => p_ref_designator_tbl
                        , p_sub_component_tbl  => p_sub_component_tbl
                        , p_rev_operation_tbl  => p_rev_operation_tbl      --L1
                        , p_rev_op_resource_tbl  => p_rev_op_resource_tbl  --L1
                        , p_rev_sub_resource_tbl => p_rev_sub_resource_tbl --L1
                        , p_error_status => Error_Handler.G_STATUS_ERROR
                        , p_error_scope  => Error_Handler.G_SCOPE_ALL
                        , p_error_level  => Error_Handler.G_BO_LEVEL
                        , p_other_message => l_other_message
                        , p_other_status=> Error_Handler.G_STATUS_ERROR
                        , p_other_token_tbl => l_token_tbl
                        , x_eco_rec => x_eco_rec
                        , x_eco_revision_tbl   => l_eco_revision_tbl
                        , x_change_line_tbl   => l_change_line_tbl -- Eng Change
                        , x_revised_item_tbl   => l_revised_item_tbl
                        , x_rev_component_tbl  => l_rev_component_tbl
                        , x_ref_designator_tbl => l_ref_designator_tbl
                        , x_sub_component_tbl  => l_sub_component_tbl
                        , x_rev_operation_tbl  => l_rev_operation_tbl      --L1
                        , x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
                        , x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
                );

        x_return_status := Error_Handler.G_STATUS_ERROR;
        x_msg_count := Error_Handler.Get_Message_Count;

        IF Bom_Globals.Get_Debug = 'Y'
        THEN
                Error_Handler.Close_Debug_Session;
        END IF;

        WHEN G_EXC_UNEXP_SKIP_OBJECT THEN

        -- Call Error Handler

        Eco_Error_Handler.Log_Error
                        ( p_eco_rec => p_eco_rec
                        , p_eco_revision_tbl => p_eco_revision_tbl
                        , p_change_line_tbl    => p_change_line_tbl -- Eng Change
                        , p_revised_item_tbl => p_revised_item_tbl
                        , p_rev_component_tbl => p_rev_component_tbl
                        , p_sub_component_tbl  => p_sub_component_tbl
                        , p_ref_designator_tbl => p_ref_designator_tbl
                        , p_rev_operation_tbl  => p_rev_operation_tbl      --L1
                        , p_rev_op_resource_tbl  => p_rev_op_resource_tbl  --L1
                        , p_rev_sub_resource_tbl => p_rev_sub_resource_tbl --L1
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_error_status => Error_Handler.G_STATUS_UNEXPECTED
                        , p_error_level => Error_Handler.G_BO_LEVEL
                        , p_other_status => Error_Handler.G_STATUS_NOT_PICKED
                        , p_other_message => l_other_message
                        , p_other_token_tbl => l_token_tbl
                        , x_eco_rec => l_eco_rec
                        , x_eco_revision_tbl => l_eco_revision_tbl
                        , x_change_line_tbl   => l_change_line_tbl -- Eng Change
                        , x_revised_item_tbl => l_revised_item_tbl
                        , x_rev_component_tbl =>l_rev_component_tbl
                        , x_ref_designator_tbl => l_ref_designator_tbl
                        , x_sub_component_tbl  => l_sub_component_tbl
                        , x_rev_operation_tbl  => l_rev_operation_tbl      --L1
                        , x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
                        , x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
                        );

       x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
       x_msg_count := Error_Handler.Get_Message_Count;
        IF Bom_Globals.Get_Debug = 'Y'
        THEN
                Error_Handler.Close_Debug_Session;
        END IF;


END Process_Eco;

/*
 Commented out since not required in this version of the product
 By AS 11/11/98

PROCEDURE Lock_Eco
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  Eco_Rec_Type :=
                                        G_MISS_ECO_REC
,   p_eco_revision_tbl              IN  Eco_Revision_Tbl_Type :=
                                        G_MISS_ECO_REVISION_TBL
,   p_revised_item_tbl              IN  Revised_Item_Tbl_Type :=
                                        G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl             IN  Rev_Component_Tbl_Type :=
                                        G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl            IN  Ref_Designator_Tbl_Type :=
                                        G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl             IN  Sub_Component_Tbl_Type :=
                                        G_MISS_SUB_COMPONENT_TBL
,   x_ECO_rec                       OUT NOCOPY Eco_Rec_Type
,   x_eco_revision_tbl              OUT NOCOPY Eco_Revision_Tbl_Type
,   x_revised_item_tbl              OUT NOCOPY Revised_Item_Tbl_Type
,   x_rev_component_tbl             OUT NOCOPY Rev_Component_Tbl_Type
,   x_ref_designator_tbl            OUT NOCOPY Ref_Designator_Tbl_Type
,   x_sub_component_tbl             OUT NOCOPY Sub_Component_Tbl_Type
,   x_err_text                      OUT NOCOPY VARCHAR2
)
IS
BEGIN
    NULL;
END Lock_Eco;
*/

/*----------------------------------------
  -- Location changed to Error Handler

PROCEDURE Add_Error_Token(
                                p_message_name      IN  VARCHAR2
              , p_message_text      IN  VARCHAR2
              , x_Mesg_Token_tbl    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
              , p_Mesg_Token_Tbl    IN  Error_Handler.Mesg_Token_Tbl_Type
              , p_token_tbl         IN  Error_Handler.Token_Tbl_Type
                          )
IS
        l_Index         NUMBER;
        l_TableCount    NUMBER;
        l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type ;
BEGIN
        ----------------------------------------------------------------------
    -- This procedure can be called from the individual entity validation
        -- procedures to fill up the err_token_tbl that will be passed to the
        -- Log_Error procedure to create a token substituted and translated
        -- list of messages.
        -----------------------------------------------------------------------
        l_Mesg_Token_Tbl := p_Mesg_Token_Tbl;
        l_Index := 0;
        l_TableCount := l_Mesg_token_tbl.COUNT;

        IF p_token_tbl.COUNT = 0 AND
           p_message_name IS NOT NULL
        THEN
                l_Mesg_token_tbl(l_TableCount + 1).message_name := p_message_name;
        ELSIF p_token_tbl.COUNT <> 0 AND
              p_message_name IS NOT NULL
        THEN
                FOR l_Index IN 1..p_token_tbl.COUNT LOOP
                        l_TableCount := l_TableCount + 1;
                        l_Mesg_token_tbl(l_TableCount).message_name := p_message_name;
                        l_Mesg_token_tbl(l_TableCount).token_value
                                := p_token_tbl(l_Index).token_value;
                        l_Mesg_token_tbl(l_TableCount).translate
                                := p_token_tbl(l_Index).translate;
                END LOOP;
        ELSIF p_message_name IS NULL AND
                  p_message_text IS NOT NULL THEN
                  l_Mesg_token_tbl(l_TableCount + 1).message_text := p_message_text;
        END IF;

        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
END;
*/

END ENG_Eco_PUB;

/
