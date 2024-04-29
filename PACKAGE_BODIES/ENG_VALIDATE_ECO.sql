--------------------------------------------------------
--  DDL for Package Body ENG_VALIDATE_ECO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VALIDATE_ECO" AS
/* $Header: ENGLECOB.pls 120.5.12010000.4 2011/08/19 09:44:57 gliang ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Validate_Eco';

  PROCEDURE grant_role_guid
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_instance_set_id       IN  NUMBER,
   p_instance_pk1_value    IN  VARCHAR2,
   p_instance_pk2_value    IN  VARCHAR2,
   p_instance_pk3_value    IN  VARCHAR2,
   p_instance_pk4_value    IN  VARCHAR2,
   p_instance_pk5_value    IN  VARCHAR2,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER,
   x_grant_guid            OUT NOCOPY RAW
  )
  IS

  --x_grant_guid         fnd_grants.grant_guid%TYPE;
  l_grantee_type       hz_parties.party_type%TYPE;
  l_instance_type      fnd_grants.instance_type%TYPE;
  l_grantee_key        fnd_grants.grantee_key%TYPE;
  l_dummy              VARCHAR2(1);
  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;
  --Changing NULL to '*NULL*' as FND is upgrading their grants data model
  CURSOR check_fnd_grant_exist (cp_grantee_key       VARCHAR2,
                               cp_grantee_type            VARCHAR2,
                               cp_menu_name               VARCHAR2,
                               cp_object_name             VARCHAR2,
                               cp_instance_type           VARCHAR2,
                               cp_instance_pk1_value      VARCHAR2,
                               cp_instance_pk2_value      VARCHAR2,
                               cp_instance_pk3_value      VARCHAR2,
                               cp_instance_pk4_value      VARCHAR2,
                               cp_instance_pk5_value      VARCHAR2,
                               cp_instance_set_id         NUMBER,
                               cp_start_date              DATE,
                               cp_end_date                DATE) IS

        SELECT 'X'
        FROM fnd_grants grants,
             fnd_objects obj,
             fnd_menus menus
        WHERE grants.grantee_key=cp_grantee_key
        AND  grants.grantee_type=cp_grantee_type
        AND  grants.menu_id=menus.menu_id
        AND  menus.menu_name=cp_menu_name
        AND  grants.object_id = obj.object_id
        AND obj.obj_name=cp_object_name
        AND grants.instance_type=cp_instance_type
        AND ((grants.instance_pk1_value=cp_instance_pk1_value )
            OR((grants.instance_pk1_value = ' *NULL*' ) AND (cp_instance_pk1_value IS NULL)))
        AND ((grants.instance_pk2_value=cp_instance_pk2_value )
            OR((grants.instance_pk2_value = ' *NULL*' ) AND (cp_instance_pk2_value IS NULL)))
        AND ((grants.instance_pk3_value=cp_instance_pk3_value )
            OR((grants.instance_pk3_value = ' *NULL*' ) AND (cp_instance_pk3_value IS NULL)))
        AND ((grants.instance_pk4_value=cp_instance_pk4_value )
            OR((grants.instance_pk4_value =  ' *NULL*' ) AND (cp_instance_pk4_value IS NULL)))
        AND ((grants.instance_pk5_value=cp_instance_pk5_value )
            OR((grants.instance_pk5_value = ' *NULL*' ) AND (cp_instance_pk5_value IS NULL)))
        AND ((grants.instance_set_id=cp_instance_set_id )
            OR((grants.instance_set_id = ' *NULL*' ) AND (cp_instance_set_id IS NULL)))
        AND (((grants.start_date<=cp_start_date )
            AND (( grants.end_date = '*NULL*') OR (cp_start_date <=grants.end_date )))
        OR ((grants.start_date >= cp_start_date )
            AND (( cp_end_date IS NULL)  OR (cp_end_date >=grants.start_date))));

    v_start_date DATE := sysdate;

  BEGIN
       if (p_start_date IS NULL) THEN
         v_start_date := sysdate;
       else
         v_start_date := p_start_date;
       end if;
       IF( p_instance_type <> 'INSTANCE') THEN
          l_instance_type:='SET';
       ELSE
          l_instance_type:=p_instance_type;
       END IF;


       OPEN get_party_type (cp_party_id =>p_party_id);
       FETCH get_party_type INTO l_grantee_type;
       CLOSE get_party_type;
       IF(  p_party_id = -1000) THEN
          l_grantee_type :='GLOBAL';
          l_grantee_key:='HZ_GLOBAL:'||p_party_id;
       ELSIF (l_grantee_type ='PERSON') THEN
          l_grantee_type:='USER';
          l_grantee_key:='HZ_PARTY:'||p_party_id;
       ELSIF (l_grantee_type ='GROUP') THEN
          l_grantee_type:='GROUP';
          l_grantee_key:='HZ_GROUP:'||p_party_id;
       ELSIF (l_grantee_type ='ORGANIZATION') THEN
          l_grantee_type:='COMPANY';
          l_grantee_key:='HZ_COMPANY:'||p_party_id;
       ELSE
           null;
       END IF;

       OPEN check_fnd_grant_exist(cp_grantee_key  => l_grantee_key,
                      cp_grantee_type       => l_grantee_type,
                      cp_menu_name          => p_role_name,
                      cp_object_name        => p_object_name,
                      cp_instance_type      => l_instance_type,
                      cp_instance_pk1_value => p_instance_pk1_value,
                      cp_instance_pk2_value => p_instance_pk2_value,
                      cp_instance_pk3_value => p_instance_pk3_value,
                      cp_instance_pk4_value => p_instance_pk4_value,
                      cp_instance_pk5_value => p_instance_pk5_value,
                      cp_instance_set_id    => p_instance_set_id,
                      cp_start_date         => v_start_date,
                      cp_end_date           => p_end_date);

       FETCH check_fnd_grant_exist INTO l_dummy;
       IF( check_fnd_grant_exist%NOTFOUND) THEN
         fnd_grants_pkg.grant_function(
              p_api_version        => 1.0,
              p_menu_name          => p_role_name ,
              p_object_name        => p_object_name,
              p_instance_type      => l_instance_type,
              p_instance_set_id    => p_instance_set_id,
              p_instance_pk1_value => p_instance_pk1_value,
              p_instance_pk2_value => p_instance_pk2_value,
              p_instance_pk3_value => p_instance_pk3_value,
              p_instance_pk4_value => p_instance_pk4_value,
              p_instance_pk5_value => p_instance_pk5_value,
              p_grantee_type       => l_grantee_type,
              p_grantee_key        => l_grantee_key,
              p_start_date         => v_start_date,
              p_end_date           => p_end_date,
              p_program_name       => null,
              p_program_tag        => null,
              x_grant_guid         => x_grant_guid,
              x_success            => x_return_status,
              x_errorcode          => x_errorcode
          );
        ELSE
          x_return_status:='F';
        END IF;

        CLOSE check_fnd_grant_exist;

  END grant_role_guid;



-- Function Compatible_Change_Order_Type
-- The new change order type must be compatible (or same as) with the old change order type

PROCEDURE Compatible_Change_Order_Type
( p_new_change_order_type_id    IN  NUMBER
, p_change_notice               IN  VARCHAR2
, p_organization_id             IN  NUMBER
, x_change_order_type_same      OUT NOCOPY NUMBER
, x_err_text                    OUT NOCOPY VARCHAR2
)
IS
l_new_assembly_type     NUMBER := 0;
l_assembly_type         NUMBER := 0;
l_err_text              VARCHAR2(2000) := NULL;
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_eng_item_flag         VARCHAR2(1) := 'n';
CURSOR eng_item_cur IS
        SELECT 'y'
        FROM mtl_system_items
        WHERE inventory_item_id =
                (select revised_item_id from eng_revised_items
                 where change_notice = p_change_notice
                 and organization_id = organization_id)
        AND organization_id = p_organization_id
        AND eng_item_flag = 'Y';
BEGIN
  l_assembly_type := ENG_Globals.Get_ECO_Assembly_Type ( p_change_notice => p_change_notice
                                                       , p_organization_id => p_organization_id
                                                       );
  select assembly_type
  into   l_new_assembly_type
  from   eng_change_order_types
  where  change_order_type_id =
                p_new_change_order_type_id;

  IF l_new_assembly_type = l_assembly_type
  THEN
        x_change_order_type_same := 1;
  ELSE
        IF l_new_assembly_type = 1
        THEN
                OPEN eng_item_cur;
                FETCH eng_item_cur into l_eng_item_flag;
                CLOSE eng_item_cur;

                IF l_eng_item_flag = 'y'
                THEN
                        x_change_order_type_same := 0;
                ELSE
                        x_change_order_type_same := 1;
                END IF;
        END IF;
  END IF;

  EXCEPTION

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            l_err_text := G_PKG_NAME || ' : (Compatible_Change_Order_Type) -
                                        Change_Notice ' || substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
        END IF;

        x_change_order_type_same := -1;

END Compatible_Change_Order_Type;

--Procedure Check_Delete

PROCEDURE Check_Delete
( p_eco_rec             IN  ENG_ECO_PUB.Eco_Rec_Type
, p_Unexp_ECO_rec       IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
l_Token_Tbl                   Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl              Error_Handler.Mesg_Token_Tbl_Type;
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

l_ri_exists                     NUMBER := 0;
CURSOR GetRevisedItems IS
        SELECT 'x'
          FROM eng_revised_items
         WHERE change_notice = p_ECO_rec.ECO_Name
           AND organization_id = p_Unexp_ECO_rec.organization_id;
BEGIN

    l_token_tbl(1).token_name := 'ECO_NAME';
    l_token_tbl(1).token_value := p_ECO_Rec.ECO_Name;

    FOR l_ritem_exists IN GetRevisedItems LOOP
        l_ri_exists := 1;
    END LOOP;

    -- ECO cannot be deleted if revised items exist

    IF  p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_DELETE AND
        (l_ri_exists = 1 OR p_unexp_eco_rec.approval_status_type in (2,3,5))
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CANNOT_DELETE'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    x_return_status := l_return_status;

END Check_Delete;


-- Added by MK on 09/01/2000
-- Function: Check if other ECO's unimplemented Rev Comp referencing Op Seq Num
--           exists in this ECO for Cancel
--
FUNCTION  Check_Ref_Rev_Comp_For_ECO
            ( p_eco_name           IN  VARCHAR2
            , p_organization_id    IN  NUMBER
            )

RETURN BOOLEAN

IS
     -- Modified query for performance bug 4251776
     CURSOR l_ref_rev_cmp_csr ( p_eco_name             VARCHAR2
                              , p_organization_id      NUMBER
                              )

     IS
          SELECT 'Rev Comp referencing Seq Num exists'
          FROM    SYS.DUAL
          WHERE   EXISTS (SELECT NULL
                          FROM   ENG_ENGINEERING_CHANGES eec1
                               , ENG_REVISED_ITEMS eri1
                               , ENG_REVISED_ITEMS eri2
                          WHERE  eri1.revised_item_id =  eri2.revised_item_id
                          AND    eri1.organization_id =  eec1.organization_id
                          AND    eri1.change_notice   =  eec1.change_notice
                          AND    eec1.change_notice   <> p_eco_name
                          AND    eec1.organization_id =  p_organization_id
                          AND    eri2.organization_id =  p_organization_id
                          AND    eri2.change_notice   =  p_eco_name
                          AND    EXISTS (SELECT NULL
                                         FROM   BOM_INVENTORY_COMPONENTS bic
                                              , BOM_OPERATION_SEQUENCES  bos
                                         WHERE  bic.implementation_date  IS NULL
                                         AND    bic.operation_seq_num    = bos.operation_seq_num
                                         AND    bic.bill_sequence_id     = eri1.bill_sequence_id
                                         AND    bos.revised_item_sequence_id  =  eri2.revised_item_sequence_id
                                         AND    bos.routing_sequence_id = eri2.routing_sequence_id
                                         )
                         ) ;

       l_ret_status BOOLEAN := TRUE ;

    BEGIN
       FOR l_ref_rev_cmp_rec IN l_ref_rev_cmp_csr
                                ( p_eco_name
                                , p_organization_id
                                )
       LOOP
          l_ret_status  := FALSE ;
       END LOOP;

        -- If the loop does not execute then
        -- return false
          RETURN l_ret_status ;


END Check_Ref_Rev_Comp_For_ECO ;

-- Added by MK on 11/29/2000
-- Function: Check if Org Hierarchy is valid
--
FUNCTION  Val_Org_Hierarchy
            ( p_org_hierarchy      IN  VARCHAR2
            , p_org_id             IN  NUMBER
            )

RETURN BOOLEAN
IS

     CURSOR l_org_hierarchy_csr ( p_org_hierarchy    VARCHAR2
                                --, l_org_name         VARCHAR2
                                 )

     IS


        SELECT 'Valid'
        FROM    SYS.DUAL
        WHERE   EXISTS ( SELECT 'Valid'
                         FROM    per_organization_structures
                         WHERE   inv_orghierarchy_pvt.org_hierarchy_access
                                 (p_org_hierarchy) = 'Y'
                         AND     inv_orghierarchy_pvt.org_hierarchy_level_access
                                 (p_org_hierarchy,p_org_id) = 'Y'
                       ) ;


       l_ret_status BOOLEAN      := FALSE ;
--       l_org_name   VARCHAR2(60) := NULL ;

BEGIN
/*       begin
           SELECT  organization_name INTO l_org_name
           FROM    org_organization_definitions
           WHERE   organization_id = p_org_id  ;
       end  ;
*/

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check if Org Hierarchy is valid in org : ' || p_org_id );
END IF;


       FOR l_org_hierarchy_rec IN l_org_hierarchy_csr
                                ( p_org_hierarchy
                                --, l_org_name
                                )
       LOOP

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Org hierarchy is valid' );
END IF;

          l_ret_status  := TRUE ;
       END LOOP;

       -- If the loop does not execute then
       -- return false
       RETURN l_ret_status ;

END Val_Org_Hierarchy ;


--Bug 2921474


FUNCTION Get_Change_Id
( p_change_notice    IN  VARCHAR2
, p_org_id           IN NUMBER
)
RETURN NUMBER
IS
   l_id                          NUMBER;
BEGIN

    SELECT  change_id
    INTO    l_id
    FROM    eng_engineering_changes
    WHERE   change_notice = p_change_notice
      AND organization_id = p_org_id;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
            RETURN  FND_API.G_MISS_NUM;

END Get_Change_Id;













--  Procedure Entity

PROCEDURE Check_Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec                 IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_old_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_old_Unexp_ECO_rec             IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_control_rec                   IN  BOM_BO_PUB.Control_Rec_Type :=
                                        BOM_BO_PUB.G_DEFAULT_CONTROL_REC

)
IS
l_err_text                    VARCHAR2(2000) := NULL;
l_Token_Tbl                   Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl              Error_Handler.Mesg_Token_Tbl_Type;
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy                       VARCHAR2(10) := NULL;
l_process_name                VARCHAR2(30) := NULL;
l_rev_items_scheduled         BOOLEAN := FALSE;
l_change_order_type_same      NUMBER := 0;
l_change_order_access         BOOLEAN := FALSE;
-- requestor_role_id ,assignee_role_id  now not in table ENG_CHANGE_ORDER_TYPES
/* l_requestor_role_id           NUMBER;
   l_assignee_role_id            NUMBER; */
l_requestor_role_name         VARCHAR2(30);
l_assignee_role_name          VARCHAR2(30);
   l_errorcode                NUMBER;
   l_grant_guid               fnd_grants.grant_guid%TYPE;

stmt_num                        NUMBER := 0;

l_ri_exists                     NUMBER := 0;
CURSOR GetRevisedItems IS
        SELECT 'x'
          FROM eng_revised_items
         WHERE change_notice = p_ECO_rec.ECO_Name
           AND organization_id = p_Unexp_ECO_rec.organization_id;

l_ri_sched_exists               NUMBER := 0;
CURSOR GetScheduledRevItems IS
        SELECT 'x'
          FROM eng_revised_items
         WHERE change_notice = p_ECO_rec.ECO_Name
           AND organization_id = p_Unexp_ECO_rec.organization_id
           AND status_type = 4;

CURSOR GetRoleName(p_role_id NUMBER)
IS
        SELECT menu_name FROM fnd_menus
          WHERE menu_id = p_role_id;

--Bug 2921474
l_cl_exists                     NUMBER := 0;
CURSOR GetChangeLines(p_change_id NUMBER) IS
        SELECT 'x'
          FROM eng_change_lines
         WHERE change_id = p_change_id;

l_er_exists                     NUMBER := 0;
CURSOR GetEcoRevisions IS
        SELECT 'x'
          FROM ENG_CHANGE_ORDER_REVISIONS
         WHERE change_notice = p_ECO_rec.ECO_Name
           AND organization_id = p_Unexp_ECO_rec.organization_id;

l_change_id NUMBER := 0;
--End of Bug 2921474

BEGIN

    l_token_tbl(1).token_name := 'ECO_NAME';
    l_token_tbl(1).token_value := p_ECO_Rec.ECO_Name;

    --  Get Workflow Process name

    stmt_num := 1;
    ENG_GLOBALS.Init_Process_Name
        (   p_change_order_type_id => p_unexp_ECO_rec.change_order_type_id
        ,   p_priority_code => p_ECO_rec.priority_code
        ,   p_organization_id => p_unexp_ECO_rec.organization_id
        );

    l_process_name := ENG_Globals.Get_Process_Name;

    --
    --  Check required attributes.
    --

    --
    --  Entity Validation.
    --

    stmt_num := 5.5;

    FOR l_ritem_exists IN GetRevisedItems LOOP
        l_ri_exists := 1;
    END LOOP;


    --Bug 2921474
   l_change_id := Get_Change_Id(p_ECO_Rec.ECO_Name,p_unexp_ECO_rec.organization_id);

   FOR l_chl_exists IN GetChangeLines(l_change_id) LOOP
        l_cl_exists  := 1;
    END LOOP;


    FOR l_ecori_exists IN GetEcoRevisions LOOP
        l_er_exists := 1;
    END LOOP;

    --End of Bug 2921474


    -- ECO cannot be deleted if revised items/change line/change revision  exist (irrespective of the CO status).

    IF  p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_DELETE AND
       l_ri_exists = 1
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CANNOT_DELETE'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

     --Bug  2921474
    IF  p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_DELETE AND
        l_cl_exists =1
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CANNOT_DELETE_CL'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;


     IF  p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_DELETE AND
      l_er_exists =1
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CANNOT_DELETE_ER'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;


    --End of Bug 2921474

    -- Put in for fix to bug 622498
    -- Creates of records marked Cancelled are not allowed

    IF p_Unexp_ECO_rec.status_type = 5 AND
        p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_CREATE
    THEN
        l_Token_Tbl(2).token_name := 'STATUS_TYPE';
        l_Token_Tbl(2).token_value := p_Unexp_ECO_rec.status_type;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_STAT_MUST_NOT_BE_CNCL'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;


    -- Added by MK on 09/01/2000
    -- Put in to support ECO for Routing
    -- Check if there is no revised operation which is referenced by
    -- un-implemented revised component in other ECO
    --

    IF  p_Unexp_ECO_rec.status_type = 5 AND
        p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE
    THEN

        IF NOT Check_Ref_Rev_Comp_For_ECO( p_eco_name        => p_eco_rec.ECO_Name
                                         , p_organization_id => p_unexp_ECO_rec.organization_id
                                          )
        THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CANNOT_CNCL_FOR_REV_OP'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
            END IF;
        ---Bug 2921534
	l_return_status := FND_API.G_RET_STS_ERROR;
        END IF ;


    END IF;



    --
    --  Validate attribute dependencies here.
    --

    -- Cannot have both a Workflow Process and approval list associated with the ECO

    stmt_num := 9;
--  ERES Begin
/*
    IF  p_Unexp_ECO_rec.approval_list_id IS NOT NULL AND
        l_process_name IS NOT NULL
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_APPROV_LIST_PROCESS_EXISTS'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
*/
-- ERES end

    -- If there is no approval list or process associated, the approval status can only be rejected or approved

    stmt_num := 10;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('process : '|| l_process_name); END IF;
  -- Added following Check as part of Fix to Bug 2815601
  IF BOM_Globals.G_MASS_CHANGE <> 'MASSCHANGE' THEN
    IF  (p_control_rec.caller_type <> 'FORM' AND
        p_Unexp_ECO_rec.approval_list_id IS NULL AND
        l_process_name IS NULL AND
        p_Unexp_ECO_rec.approval_status_type NOT IN (4,5))
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_APP_STATUS_REJ_APPROV'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
    -- Are there any revised items that are scheduled ?

    FOR l_ri_sched IN GetScheduledRevItems LOOP
            l_ri_sched_exists := 1;
    END LOOP;

    -- ECO must be approved first for it or any of its revised items to be scheduled

    IF  p_Unexp_ECO_rec.approval_status_type <> 5 AND
            (p_Unexp_ECO_rec.status_type = 4 OR
            l_ri_sched_exists = 1)
    THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(1).token_name := 'ECO_NAME';
                        l_token_tbl(1).token_value := p_ECO_rec.eco_name;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_MUST_BE_APPROVED'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

--117
    -- Approval list exists

    IF  p_Unexp_ECO_rec.approval_list_id IS NOT NULL
    THEN

        -- Approval status must be Not Submitted for Approval, Ready to Approve,
        -- Approval Requested, Rejected, or Approved

        IF p_Unexp_ECO_rec.approval_status_type NOT IN (1,2,3,4,5)
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'APPROVAL_STATUS_TYPE';
                        l_token_tbl(2).token_value := p_Unexp_ECO_rec.Approval_Status_Type;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_APP_LIST_APP_STAT_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Approval list must not be changed if Approval Requested

        IF p_old_Unexp_ECO_rec.approval_status_type = 3 AND
           (p_ECO_rec.Transaction_Type = ENG_GLOBALS.G_OPR_UPDATE AND
            NVL(p_Unexp_ECO_rec.approval_list_id, 0) <> NVL(p_old_Unexp_ECO_rec.approval_list_id, 0))
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_APP_LIST_MUST_NOT_CHANGE'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Status Type must not be changed if Approval Requested
        -- FROM ENGFMECO.pld (Procedure Initialize_Row)

        IF p_old_Unexp_ECO_rec.approval_status_type = 3 AND
           (p_ECO_rec.Transaction_Type = ENG_GLOBALS.G_OPR_UPDATE AND
            p_Unexp_ECO_rec.status_type <> p_old_Unexp_ECO_rec.status_type)
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_STAT_TYPE_MUST_NOT_CHANGE'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;




    END IF;

    -- Workflow Process exists

    IF  l_process_name IS NOT NULL THEN

        -- Approval status must not be Approval Requested, Rejected, Approved,
        -- or Processing Error

        IF p_control_rec.caller_type <> 'FORM' AND
           (p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_CREATE
            OR
            (p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE AND
             p_Unexp_ECO_rec.approval_status_type <> p_old_Unexp_ECO_rec.approval_status_type))
           AND
           p_Unexp_ECO_rec.approval_status_type IN (2,3,4,5,7)
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'APPROVAL_STATUS_TYPE';
                        l_token_tbl(2).token_value := p_Unexp_ECO_rec.Approval_Status_Type;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_PROC_APP_STAT_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Cannot update status to 'Scheduled'

        IF p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE AND
           p_Unexp_ECO_rec.status_type <> p_old_Unexp_ECO_rec.status_type AND
           p_Unexp_ECO_rec.status_type = 4
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_PROC_CANNOT_SCHEDULE'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Cannot update priority if the ECO or any of its revised items have been scheduled

        IF  p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE AND
            NVL(p_ECO_rec.priority_code, 'NONE') <> NVL(p_old_ECO_rec.priority_code, 'NONE') AND
            (p_old_Unexp_ECO_rec.status_type = 4
             OR l_ri_sched_exists = 1)
        THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                        l_token_tbl(1).token_value := 'ECO_NAME';
                        l_token_tbl(1).token_value := p_eco_rec.eco_name;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('eco name: ' || p_eco_rec.eco_name); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('priority_code: ' || p_Eco_rec.priority_code); END IF;
                        l_Token_Tbl(2).Token_Name := 'PRIORITY_CODE';
                        l_Token_Tbl(2).Token_Value := p_ECO_rec.priority_code;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_REV_ITEMS_SCHED'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
            END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    -- Must not have cancellation details if ECO not cancelled

    IF p_Unexp_ECO_rec.status_type <> 5 AND
       p_ECO_rec.cancellation_comments IS NOT NULL
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CANCL_DETAILS_EXIST'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF  p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE
        AND
        NVL(p_Unexp_ECO_rec.change_order_type_id, 0) <> p_old_Unexp_ECO_rec.change_order_type_id
    THEN


        Compatible_Change_Order_Type
                                ( p_new_change_order_type_id => p_Unexp_ECO_rec.change_order_type_id
                                , p_change_notice => p_ECO_rec.ECO_Name
                                , p_organization_id => p_Unexp_ECO_rec.organization_id
                                , x_change_order_type_same => l_change_order_type_same
                                , x_err_text => x_err_text
                                );
        -- If there is a new change order type, its assembly type must be compatible with
        -- the assembly type of any existing revised items

        IF  l_change_order_type_same = 0
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                (  p_Message_Name => 'ENG_ECO_CANCL_DETAILS_EXIST'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl      => l_Token_Tbl);
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_change_order_type_same = -1
        THEN
                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF;


    END IF;


    /* Added by MK on 11/29/00 Bug #1508078
    -- Entity validation for  hierarchy_flag and organization_hierarchy
    -- If approval_status_type is 5:Approved, these columns are not updatable
    */
    IF  p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE
    -- AND p_ECO_rec.approval_status_type = 5
    AND (   --NVL(p_ECO_rec.hierarchy_flag, 2) <> NVL(p_old_ECO_rec.hierarchy_flag,2) OR
            NVL(p_ECO_rec.organization_hierarchy, FND_API.G_MISS_CHAR) <>
                     NVL(p_old_ECO_rec.organization_hierarchy, FND_API.G_MISS_CHAR)
        )
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            Error_Handler.Add_Error_Token
            ( p_Message_Name => 'ENG_HIERARCHY_MUST_NOT_CHANGE'
            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , p_Token_Tbl => l_Token_Tbl
            );
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;

    END IF ;

    IF  p_ECO_rec.organization_hierarchy IS NOT NULL
    AND (   p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_CREATE
        OR (p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE
            AND  NVL(p_ECO_rec.organization_hierarchy, FND_API.G_MISS_CHAR) <>
                     NVL(p_old_ECO_rec.organization_hierarchy, FND_API.G_MISS_CHAR)
           )
        )
    AND   NOT Val_Org_Hierarchy(  p_org_hierarchy => p_ECO_rec.organization_hierarchy
                                , p_org_id        => p_Unexp_ECO_rec.organization_id )
    THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            Error_Handler.Add_Error_Token
            ( p_Message_Name => 'ENG_ORG_HIERARCHY_INVALID'
            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , p_Token_Tbl => l_Token_Tbl
            );
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;

    END IF ;

    -- Eng Change New Validations for Change Mgmt Type and Assignee

    -- Change Mgmt Type can not be changed thr BO
    IF  (p_ECO_rec.Transaction_Type = ENG_Globals.G_OPR_UPDATE
         AND  NVL(p_Unexp_ECO_rec.Change_Mgmt_Type_Code, FND_API.G_MISS_CHAR) <>
                 NVL(p_old_Unexp_ECO_rec.Change_Mgmt_Type_Code, FND_API.G_MISS_CHAR)
         )
    THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Validation that Change Mgmt Type cannot be chagned . . . ' );
   Error_Handler.Write_Debug('Old Change Mgmt Type: ' || p_old_Unexp_ECO_rec.Change_Mgmt_Type_Code);
   Error_Handler.Write_Debug('New Change Mgmt Type: ' || p_Unexp_ECO_rec.Change_Mgmt_Type_Code);
END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            Error_Handler.Add_Error_Token
            ( p_Message_Name => 'ENG_CHANGE_MGMT_MUST_NOT_UPD'
            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , p_Token_Tbl => l_Token_Tbl
            );
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;

    END IF ;

/* commented as assignee_role_id ,requestor_role_id  don't exist in ENG_CHANGE_ORDER_TYPES table
       IF p_ECO_rec.transaction_type = Eng_Globals.G_OPR_CREATE
        THEN

            IF p_Unexp_ECO_Rec.Requestor_Id IS NULL AND p_Unexp_ECO_Rec.Assignee_Id IS NULL
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name => 'ENG_CHANGE_BOTH_RESP_NULL'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl => l_Token_Tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            SELECT requestor_role_id, assignee_role_id
            INTO l_requestor_role_id, l_assignee_role_id
            FROM eng_change_order_types
            WHERE change_order_type_id = p_Unexp_ECO_Rec.change_order_type_id;

            IF l_requestor_role_id IS NOT NULL
            THEN
                OPEN GetRoleName (p_role_id => l_requestor_role_id);
                FETCH GetRoleName INTO l_requestor_role_name;
                CLOSE GetRoleName;

                -- assign requestor grant
                grant_role_guid
                ( p_api_version => 1.0
                 ,p_role_name => l_requestor_role_name
                 ,p_object_name => 'ENG_CHANGE'
                 ,p_instance_type => 'INSTANCE'
                 ,p_instance_set_id => NULL
                 ,p_instance_pk1_value => to_char(p_Unexp_ECO_Rec.change_id)
                 ,p_instance_pk2_value => NULL
                 ,p_instance_pk3_value => NULL
                 ,p_instance_pk4_value => NULL
                 ,p_instance_pk5_value => NULL
                 ,p_party_id => p_Unexp_ECO_Rec.Requestor_Id
                 ,p_start_date => sysdate
                 ,p_end_date => NULL
                 ,x_return_status => l_return_status
                 ,x_errorcode => l_errorcode
                 ,x_grant_guid => l_grant_guid
                );

                IF l_return_status = FND_API.G_TRUE
                    OR l_return_status = FND_API.G_FALSE
                THEN
                    l_return_status := FND_API.G_RET_STS_SUCCESS;
                ELSE
                    Error_Handler.Add_Error_Token
                    ( p_Message_Name => 'ENG_CHANGE_REQUESTOR_GRANT'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl => l_Token_Tbl
                    );
                END IF;
            END IF;

            IF l_assignee_role_id IS NOT NULL
            THEN
                OPEN GetRoleName (p_role_id => l_assignee_role_id);
                FETCH GetRoleName INTO l_assignee_role_name;
                CLOSE GetRoleName;

                -- assign assignee grant
                grant_role_guid
                ( p_api_version => 1.0
                 ,p_role_name => l_assignee_role_name
                 ,p_object_name => 'ENG_CHANGE'
                 ,p_instance_type => 'INSTANCE'
                 ,p_instance_set_id => NULL
                 ,p_instance_pk1_value => to_char(p_Unexp_ECO_Rec.change_id)
                 ,p_instance_pk2_value => NULL
                 ,p_instance_pk3_value => NULL
                 ,p_instance_pk4_value => NULL
                 ,p_instance_pk5_value => NULL
                 ,p_party_id => p_Unexp_ECO_Rec.Assignee_Id
                 ,p_start_date => sysdate
                 ,p_end_date => NULL
                 ,x_return_status => l_return_status
                 ,x_errorcode => l_errorcode
                 ,x_grant_guid => l_grant_guid
                );

                IF l_return_status = FND_API.G_TRUE
                    OR l_return_status = FND_API.G_FALSE
                THEN
                    l_return_status := FND_API.G_RET_STS_SUCCESS;
                ELSE
                    Error_Handler.Add_Error_Token
                    ( p_Message_Name => 'ENG_CHANGE_ASSIGNEE_GRANT'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl => l_Token_Tbl
                    );
                END IF;
            END IF;
        END IF;
*/
    --  Done validating entity

    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    x_return_status := l_return_status;

EXCEPTION

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            l_err_text := G_PKG_NAME || ' : (Entity Validation) ' || substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
        END IF;

END Check_Entity;

--  Procedure Check_Attributes

PROCEDURE Check_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec                 IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_old_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_old_Unexp_ECO_rec             IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_change_line_tbl               IN ENG_Eco_PUB.Change_Line_Tbl_Type ----Bug 2908248
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type --Bug 2908248
)
IS
l_err_text               VARCHAR2(2000) := '';
l_Token_Tbl              Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
l_disable_date           DATE;
 ----Bug 2908248
l_change_line_rec        Eng_Eco_Pub.Change_Line_Rec_Type ;
l_revised_item_rec           ENG_Eco_PUB.Revised_Item_Rec_Type ;
l_change_id              NUMBER :=0;

l_cl_cico_count          NUMBER :=0;  --count of cancelled/implemented/completed chnage lines
l_cl_count               NUMBER :=0;
l_cl_up_count            NUMBER :=0;
l_up_ch                  NUMBER :=0;
l_rev_item_cnt		 NUMBER :=0; --count of implemented revised items


l_up_cr                  NUMBER :=0;
l_er_cico_count          NUMBER :=0;   --count of cancelled/implemented/completed revisd items

l_er_count               NUMBER :=0;
l_er_up_count            NUMBER :=0;



CURSOR lines_for_eco( p_change_id  NUMBER) IS
     SELECT status_code ,sequence_number , name
       FROM eng_change_lines_vl
      WHERE eng_change_lines_vl.change_id = p_change_id
            and sequence_number<> -1;

CURSOR revised_items_for_eco( p_change_id  NUMBER) IS
     SELECT STATUS_TYPE ,scheduled_date
       FROM eng_revised_items
      WHERE eng_revised_items.change_id = p_change_id;



----Bug 2908248



--11.5.10

cursor GetValidStatusCodes(p_change_order_type_id NUMBER) IS
        SELECT status_code
        FROM eng_lifecycle_statuses
	where ENTITY_NAME='CHANGE_TYPE'
	and entity_id1 = p_change_order_type_id;



cursor GetValidPriorities(p_change_order_type_id NUMBER) IS
        SELECT priority_code
        FROM eng_change_type_priorities
	where change_type_id = p_change_order_type_id;


cursor GetValidReasons(p_change_order_type_id NUMBER) IS
        SELECT reason_code
        FROM eng_change_type_reasons
	where change_type_id = p_change_order_type_id;



l_valid_status NUMBER;
l_valid_priority NUMBER;
l_valid_reason NUMBER;
l_base_change_mgmt_type_code ENG_CHANGE_ORDER_TYPES.base_change_mgmt_type_code%TYPE;

BEGIN

    l_token_tbl(1).token_name := 'ECO_NAME';
    l_token_tbl(1).token_value := p_ECO_rec.ECO_Name;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate ECO attributes

    IF p_Unexp_ECO_rec.Approval_Status_Type = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                        ( p_Message_Name => 'ENG_APPROVAL_STAT_TYPE_NULL'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl => l_Token_Tbl
                        );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;

    IF  p_Unexp_ECO_rec.approval_status_type IS NOT NULL AND
        (   p_Unexp_ECO_rec.approval_status_type <>
            p_old_Unexp_ECO_rec.approval_status_type OR
            p_old_Unexp_ECO_rec.approval_status_type IS NULL )
    THEN

        IF NOT ENG_Validate.Approval_Status_Type
                ( p_Unexp_ECO_rec.approval_status_type
                , x_err_text => l_err_text
                ) OR
           p_Unexp_ECO_rec.approval_status_type = 6
        THEN
                IF l_err_text = ''
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'APPROVAL_STATUS_TYPE';
                        l_token_tbl(2).token_value := p_Unexp_ECO_Rec.Approval_Status_Type;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_APPROVAL_STAT_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                END IF;
    END IF;

    IF  p_Unexp_ECO_rec.responsible_org_id IS NOT NULL AND
        ( p_Unexp_ECO_rec.responsible_org_id <>
          p_old_Unexp_ECO_rec.responsible_org_id OR
          p_old_Unexp_ECO_rec.responsible_org_id IS NULL )
    THEN

        IF NOT ENG_Validate.Responsible_Org
                ( p_responsible_org_id => p_Unexp_ECO_rec.responsible_org_id
                , p_current_org_id     => p_Unexp_ECO_rec.organization_id
                , x_err_text => l_err_text
                )
        THEN
                IF l_err_text = ''
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'ECO_DEPARTMENT';
                        l_token_tbl(2).token_value := p_ECO_Rec.ECO_Department_Name;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_RESP_ORG_DISABLED'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;
    END IF;

    IF p_Unexp_ECO_Rec.Status_Type = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                        ( p_Message_Name => 'ENG_ECO_STAT_TYPE_MISSING'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl => l_Token_Tbl
                        );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;

    IF  p_Unexp_ECO_rec.status_type IS NOT NULL AND
        (   p_Unexp_ECO_rec.status_type <>
            p_old_Unexp_ECO_rec.status_type OR
            p_old_Unexp_ECO_rec.status_type IS NULL )
    THEN

        IF NOT ENG_Validate.Status_Type
                ( p_status_type => p_Unexp_ECO_rec.status_type
                , x_err_text => l_err_text
                )
        THEN
                IF l_err_text = ''
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'STATUS_TYPE';
                        l_token_tbl(2).token_value := p_Unexp_ECO_Rec.Status_Type;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_STATUS_TYPE_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
       	  END IF;

        -- Cannot create ECOs that are not OPEN through open interface
        -- Also since now you can create a scheduled ECO an OR condition is
        -- now added to the code.

         -- Schedule /Open/Completed is allowed in create  mode

        -- Bug : 5282713      Added p_ECO_rec.Base_Change_Management_Type = 'CHANGE_ORDER' condition
        -- Change objects other than change order and change order based can be created in any phase other than Open also.
        -- So we need to check the base change management type code for change order before checking this validation

        -- Get the base change mgmt type code
        SELECT base_change_mgmt_type_code into l_base_change_mgmt_type_code from eng_change_order_types where change_order_type_id = p_Unexp_ECO_rec.Change_Order_Type_Id;

        IF p_ECO_rec.transaction_type = 'CREATE' and l_base_change_mgmt_type_code = 'CHANGE_ORDER' and
           ((nvl(p_ECO_rec.plm_or_erp_change,'PLM') = 'ERP' AND p_Unexp_ECO_rec.status_type <> 1 AND p_Unexp_ECO_rec.status_type <> 4 AND p_Unexp_ECO_rec.status_type <> 7
              AND p_Unexp_ECO_rec.status_type <> 11)
            OR (nvl(p_ECO_rec.plm_or_erp_change,'PLM') = 'PLM' AND p_Unexp_ECO_rec.status_type NOT IN (0,1,4,7,11)))
                            -- bug#12791511, eed the ability to create eco in released status(7) in ebs via the agile pip
        THEN
                l_token_tbl(1).token_name := 'STATUS_TYPE';
                l_token_tbl(1).token_value := p_Unexp_ECO_Rec.Status_Type;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CREATE_STAT_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

     --Bug 2908248
     --Cancel /Schedule /Open/Completed is allowed in update mode

    IF p_ECO_rec.transaction_type = 'UPDATE' and
           ( p_Unexp_ECO_rec.status_type <> 1 AND p_Unexp_ECO_rec.status_type <> 4 AND p_Unexp_ECO_rec.status_type <> 11
	   and p_Unexp_ECO_rec.status_type <> 5 and
          p_Unexp_ECO_rec.status_type <> 7    --- Added for Bug 3108743
           and p_Unexp_ECO_rec.status_type <> 2 )   --- Added for Bug 8823124
        THEN
                l_token_tbl(1).token_name := 'STATUS_TYPE';
                l_token_tbl(1).token_value := p_Unexp_ECO_Rec.Status_Type;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CREATE_STAT_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

   --Bug 2908248

   --When trying to cancel/complete a ECO check if all lines/revised items are completed/cancelled/implemented
    l_change_id := Get_Change_Id(p_ECO_rec.eco_name, p_Unexp_ECO_rec.Organization_Id);
    IF( p_Unexp_ECO_rec.status_type = 11   OR   p_Unexp_ECO_rec.status_type = 5  ) then
      IF p_change_line_tbl.Count <> 0   THEN
             --both for create and update
        FOR I IN 1..p_change_line_tbl.count LOOP
          l_change_line_rec := p_change_line_tbl(I);
	      if
	        ( (UPPER(l_change_line_rec.status_name) = UPPER('Completed') or UPPER(l_change_line_rec.status_name) = UPPER('Cancelled') )
	        and l_change_line_rec.eco_name = p_ECO_rec.ECO_Name
		and upper(l_change_line_rec.transaction_type) = 'UPDATE'
		)
                then
               l_cl_cico_count     :=l_cl_cico_count    +1;
             end if;
       END LOOP;
     END IF;

     --check for implemented revised items: bug:5414834
     for rec in revised_items_for_eco(l_change_id)
     loop
        if(rec.status_type = 6) then
	   l_rev_item_cnt       :=l_rev_item_cnt      +1; -- no of implemented revised items
        end if;
     end loop;

   --check for revised items :
    IF p_revised_item_tbl.count <> 0   THEN
     --both for create and update
        FOR I IN 1..p_revised_item_tbl.count LOOP
          l_revised_item_rec := p_revised_item_tbl(I);
	      if
	        ( (l_revised_item_rec.status_type = 6)
	        and l_revised_item_rec.eco_name = p_ECO_rec.ECO_Name
		)
                then
                      l_er_cico_count       :=l_er_cico_count      +1;
              end if;
       END LOOP;
     END IF;

      -- variables required for lines validation
      l_cl_count :=0;
      l_cl_up_count :=0;

      --variables required for revised items
       l_er_count               :=0;
       l_er_up_count            :=0;

    if (UPPER(p_ECO_rec.transaction_type) = 'UPDATE') then

       l_change_id := Get_Change_Id(p_ECO_rec.eco_name, p_Unexp_ECO_rec.Organization_Id);

	--checking for lines.
	 for lines_for_eco_rec in lines_for_eco(l_change_id) loop
	   l_cl_count := l_cl_count+1;
	   l_up_ch :=0;
           IF p_change_line_tbl.Count <> 0   THEN
            FOR I IN 1..p_change_line_tbl.count LOOP
              l_change_line_rec := p_change_line_tbl(I);
	      if l_change_line_rec.sequence_number = lines_for_eco_rec.sequence_number
	         and
                 l_change_line_rec.name = lines_for_eco_rec.name
              then
               l_up_ch  :=1; --we need not check in eng_change_lines as it being updated now
	      end if;
           END LOOP;
	   END IF;    --p_change_line_tbl.Count <> 0
	   if(
	         ((l_up_ch = 0) AND (lines_for_eco_rec.status_code = 5))

	            OR
        	   ((l_up_ch = 0) AND(lines_for_eco_rec.status_code = 11) )

		   		    OR
        	   ((l_up_ch  = 0) AND(lines_for_eco_rec.status_code = 6) )

               )then
                  l_cl_up_count :=l_cl_up_count+1;
           elsif  l_up_ch =1 then
	           l_cl_count:=l_cl_count -1;
           end if;

         end loop;
         l_er_count             :=0;
         l_er_up_count            :=0;

	 --checking for revised items

          for revised_items_for_eco_rec in revised_items_for_eco(l_change_id) loop
	   l_er_count := l_er_count+1;
	   l_up_cr  :=0;
           IF p_revised_item_tbl.Count <> 0   THEN
            FOR I IN 1..p_revised_item_tbl.Count LOOP
              l_revised_item_rec  := p_revised_item_tbl(I);
	      if l_revised_item_rec .Start_Effective_Date = revised_items_for_eco_rec.scheduled_date
	         then
               l_up_cr   :=1; --we need not check in eng_change_lines as it being updated now
	      end if;
           END LOOP;
	   END IF;    --p_change_line_tbl.Count <> 0

	   if(
	         ((l_up_cr  = 0) AND (revised_items_for_eco_rec.status_type = 5))

	            OR
        	   ((l_up_cr  = 0) AND(revised_items_for_eco_rec.status_type = 11) )
		    OR
        	   ((l_up_cr  = 0) AND(revised_items_for_eco_rec.status_type = 6) )


               )then
                  l_er_up_count :=l_er_up_count+1;
           elsif  l_up_cr =1 then
	           l_er_count:=l_er_count -1;
           end if;

         end loop;
     end if; --UPPER(p_ECO_rec.transaction_type) = 'UPDATE'

   --Fix for bug:5414834
   --if(l_cl_cico_count    <>  p_change_line_tbl.Count   or l_cl_count   <> l_cl_up_count or
   -- or  l_er_count   <>  l_er_up_count

   -- check for implemented revised items
   if (l_rev_item_cnt > 0 or l_er_cico_count >0)then
       l_token_tbl(1).token_name := 'STATUS_NAME';
                l_token_tbl(1).token_value := p_Unexp_ECO_Rec.Status_Type;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_CREATE_STAT_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    end if;

  END IF; --p_Unexp_ECO_rec.status_type = 11

 --End of Bug 2908248

        -- Cannot implement ECOs through open interface

        IF p_Unexp_ECO_rec.status_type = 6
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_ECO_STAT_CANNOT_BE_IMPL'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

    END IF;

    IF  p_ECO_rec.priority_code IS NOT NULL AND
        (   p_ECO_rec.priority_code <>
            p_old_ECO_rec.priority_code OR
            p_old_ECO_rec.priority_code IS NULL )
    THEN
        IF NOT ENG_Validate.Priority
                ( p_priority_code => p_ECO_rec.priority_code
                , p_organization_id => p_Unexp_ECO_rec.organization_id
                , x_disable_date => l_disable_date
                , x_err_text => l_err_text
                )
        THEN
                IF l_err_text = ''
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'PRIORITY_CODE';
                        l_token_tbl(2).token_value := p_ECO_Rec.Priority_Code;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_PRIORITY_CODE_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

        IF NVL(l_disable_date, SYSDATE + 1) <= SYSDATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'PRIORITY_CODE';
                        l_token_tbl(2).token_value := p_ECO_Rec.Priority_Code;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_PRIORITY_CODE_DISABLED'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;
IF p_ECO_rec.plm_or_erp_change ='PLM' then

l_valid_priority :=0;

for valid_prio_for_eco_type in GetValidPriorities(p_Unexp_ECO_rec.change_order_type_id) loop
if valid_prio_for_eco_type.priority_code  = p_ECO_rec.priority_code then
   l_valid_priority := 1;
end if;
end loop;
if l_valid_priority = 0 then
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'PRIORITY_CODE';
                        l_token_tbl(2).token_value := p_ECO_Rec.Priority_Code;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_PRIORITY_CODE_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

 end if;
END IF;

-- Commented out the following as this validation is not required for 11.5.10
/*
--Bug 2950311
       ELSIF  (p_ECO_rec.priority_code IS  NULL
          AND   p_ECO_rec.Assignee IS NOT NULL) THEN


	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value := p_ECO_Rec.Eco_Name;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_PRIORITY_CODE_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
*/
    END IF;

    IF  p_ECO_rec.reason_code IS NOT NULL AND
        (   p_ECO_rec.reason_code <>
            p_old_ECO_rec.reason_code OR
            p_old_ECO_rec.reason_code IS NULL )
    THEN
        IF NOT ENG_Validate.Reason
                ( p_reason_code => p_ECO_rec.reason_code
                , p_organization_id => p_Unexp_ECO_rec.organization_id
                , x_disable_date => l_disable_date
                , x_err_text => l_err_text
                )
        THEN
                IF l_err_text = ''
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'REASON_CODE';
                        l_token_tbl(2).token_value := p_ECO_Rec.Reason_Code;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_REASON_CODE_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;
        IF NVL(l_disable_date, SYSDATE + 1) <= SYSDATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'REASON_CODE';
                        l_token_tbl(2).token_value := p_ECO_Rec.Reason_Code;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_REASON_CODE_DISABLED'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;
--11.5.10
IF p_ECO_rec.plm_or_erp_change ='PLM' then

l_valid_reason :=0;

for valid_rea_for_eco_type in GetValidReasons(p_Unexp_ECO_rec.change_order_type_id) loop
if valid_rea_for_eco_type.Reason_Code  = p_ECO_Rec.Reason_Code then
   l_valid_reason :=1;
end if;
end loop;
             if l_valid_reason = 0 then

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'REASON_CODE';
                        l_token_tbl(2).token_value := p_ECO_Rec.Reason_Code;
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_REASON_CODE_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

 end if;
 --11.5.10
END IF;


    END IF;

    /* Added by MK on 11/29/00 Bug #1508078
    -- Attribute validation for hierarchy_flag and organization_hierarchy
    --
    */


    /*  User may not set null in Update,
    --  because hierarchy_flag does not exist interface table,
    --  Hence following logic is commented out.
    --  Set 2:No to hierarchy_flag in Entity Defaulting
    --  when hierarchy_flag = FND_API.G_MISS_NUM
    --
    IF p_ECO_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE
    THEN
        IF p_ECO_rec.hierarchy_flag = FND_API.G_MISS_NUM
        THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name   => 'ENG_HIERARCHY_FLAG_MISSING'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl      => l_Token_Tbl
                );
             END IF;
             x_return_status  := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        END IF ;
    END IF ;

    IF   NVL(p_ECO_rec.hierarchy_flag,2 ) NOT IN (1, 2 )
    AND  p_ECO_rec.hierarchy_flag <> FND_API.G_MISS_NUM
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name   => 'ENG_HIERARCHY_FLAG_INVALID'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl      => l_Token_Tbl
                );
             END IF;
             x_return_status  := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;
    */



    -- Eng Change
    IF   NVL(p_ECO_rec.internal_use_only,1 ) NOT IN (1, 2 )
    AND  p_ECO_rec.internal_use_only <> FND_API.G_MISS_NUM
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name   => 'ENG_INTL_USE_ONLY_FLAG_INVALID'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl      => l_Token_Tbl
                );
             END IF;
             x_return_status  := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;

    IF   p_ECO_rec.need_by_date < SYSDATE
    AND  p_ECO_rec.need_by_date <> FND_API.G_MISS_DATE
    AND  p_ECO_rec.need_by_date IS NOT NULL
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name   => 'ENG_NEED_BY_DATE_LESS_CURR'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl      => l_Token_Tbl
                );
             END IF;
             x_return_status  := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;

    IF   p_ECO_rec.effort < 0
    AND  p_ECO_rec.effort <> FND_API.G_MISS_NUM
    AND  p_ECO_rec.effort IS NOT NULL
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name   => 'ENG_EFFORT_LESS_ZERO'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl      => l_Token_Tbl
                );
             END IF;
             x_return_status  := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;


    --  These calls are temporarily commented out

/*
    IF  (p_ECO_rec.attribute7 IS NOT NULL AND
        (   p_ECO_rec.attribute7 <>
            p_old_ECO_rec.attribute7 OR
            p_old_ECO_rec.attribute7 IS NULL ))
    OR  (p_ECO_rec.attribute8 IS NOT NULL AND
        (   p_ECO_rec.attribute8 <>
            p_old_ECO_rec.attribute8 OR
            p_old_ECO_rec.attribute8 IS NULL ))
    OR  (p_ECO_rec.attribute9 IS NOT NULL AND
        (   p_ECO_rec.attribute9 <>
            p_old_ECO_rec.attribute9 OR
            p_old_ECO_rec.attribute9 IS NULL ))
    OR  (p_ECO_rec.attribute10 IS NOT NULL AND
        (   p_ECO_rec.attribute10 <>
            p_old_ECO_rec.attribute10 OR
            p_old_ECO_rec.attribute10 IS NULL ))
    OR  (p_ECO_rec.attribute11 IS NOT NULL AND
        (   p_ECO_rec.attribute11 <>
            p_old_ECO_rec.attribute11 OR
            p_old_ECO_rec.attribute11 IS NULL ))
    OR  (p_ECO_rec.attribute12 IS NOT NULL AND
        (   p_ECO_rec.attribute12 <>
            p_old_ECO_rec.attribute12 OR
            p_old_ECO_rec.attribute12 IS NULL ))
    OR  (p_ECO_rec.attribute13 IS NOT NULL AND
        (   p_ECO_rec.attribute13 <>
            p_old_ECO_rec.attribute13 OR
            p_old_ECO_rec.attribute13 IS NULL ))
    OR  (p_ECO_rec.attribute14 IS NOT NULL AND
        (   p_ECO_rec.attribute14 <>
            p_old_ECO_rec.attribute14 OR
            p_old_ECO_rec.attribute14 IS NULL ))
    OR  (p_ECO_rec.attribute15 IS NOT NULL AND
        (   p_ECO_rec.attribute15 <>
            p_old_ECO_rec.attribute15 OR
            p_old_ECO_rec.attribute15 IS NULL ))
    OR  (p_ECO_rec.attribute_category IS NOT NULL AND
        (   p_ECO_rec.attribute_category <>
            p_old_ECO_rec.attribute_category OR
            p_old_ECO_rec.attribute_category IS NULL ))
    OR  (p_ECO_rec.attribute1 IS NOT NULL AND
        (   p_ECO_rec.attribute1 <>
            p_old_ECO_rec.attribute1 OR
            p_old_ECO_rec.attribute1 IS NULL ))
    OR  (p_ECO_rec.attribute2 IS NOT NULL AND
        (   p_ECO_rec.attribute2 <>
            p_old_ECO_rec.attribute2 OR
            p_old_ECO_rec.attribute2 IS NULL ))
    OR  (p_ECO_rec.attribute3 IS NOT NULL AND
        (   p_ECO_rec.attribute3 <>
            p_old_ECO_rec.attribute3 OR
            p_old_ECO_rec.attribute3 IS NULL ))
    OR  (p_ECO_rec.attribute4 IS NOT NULL AND
        (   p_ECO_rec.attribute4 <>
            p_old_ECO_rec.attribute4 OR
            p_old_ECO_rec.attribute4 IS NULL ))
    OR  (p_ECO_rec.attribute5 IS NOT NULL AND
        (   p_ECO_rec.attribute5 <>
            p_old_ECO_rec.attribute5 OR
            p_old_ECO_rec.attribute5 IS NULL ))
    OR  (p_ECO_rec.attribute6 IS NOT NULL AND
        (   p_ECO_rec.attribute6 <>
            p_old_ECO_rec.attribute6 OR
            p_old_ECO_rec.attribute6 IS NULL ))
    THEN

        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_ECO_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_ECO_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_ECO_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_ECO_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_ECO_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_ECO_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_ECO_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_ECO_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_ECO_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE_CATEGORY'
        ,   column_value                  => p_ECO_rec.attribute_category
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_ECO_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_ECO_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_ECO_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_ECO_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_ECO_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_ECO_rec.attribute6
        );

        --  Validate descriptive flexfield.

        IF NOT ENG_Validate.Desc_Flex( 'ECO' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;
*/

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_err_text := l_err_text;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                                );
        END IF;
END Check_Attributes;

-- Procedure Check_Required

PROCEDURE Conditionally_Required
(   x_return_status                OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl               OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ECO_rec                      IN  ENG_ECO_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec                IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_old_ECO_rec                  IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_old_Unexp_ECO_rec            IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
)
IS
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_err_text              VARCHAR2(2000) := NULL;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_token_tbl(1).token_name := 'ECO_NAME';
    l_token_tbl(1).token_value := p_ECO_Rec.ECO_Name;

    -- responsible_org_id must not be null if profile option is set to yes


    -- Bug : 2516871
    -- If this function is called from MCO then, the below filter condition for
    -- validating the ENG:MANDATORY_ECO_DEPT should not be executed.

    IF (Bom_globals.Get_Caller_Type = BOM_GLOBALS.G_MASS_CHANGE) THEN
       NULL ;
    ELSE

       IF (FND_PROFILE.DEFINED('ENG:MANDATORY_ECO_DEPT') AND
           FND_PROFILE.VALUE('ENG:MANDATORY_ECO_DEPT') = '1')
          AND p_Unexp_ECO_rec.responsible_org_id IS NULL
       THEN
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_RESP_ORG_MISSING'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF ;

    /* Added by MK on 11/29/00 Bug #1508078
    -- Conditionally required validation for hierarchy_flag and organization_hierarchy
    --
    IF  p_ECO_rec.hierarchy_flag = 1 AND
        NVL(p_ECO_rec.organization_hierarchy, FND_API.G_MISS_CHAR)
                                            = FND_API.G_MISS_CHAR
    THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name => 'ENG_ORG_HIERARCHY_MISSING'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                , p_Token_Tbl => l_Token_Tbl
                );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    */


EXCEPTION

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            l_err_text := G_PKG_NAME || ' : (Conditionally Required Fields Check) ' || substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                                );
        END IF;

END Conditionally_Required;

/***************************************************************************
* Procedure     : Check_Existence
* Parameters IN : ECO Name
*                 Organization Id
* Parameters OUT: Old Eco exposed column record
*                 Old ECO unexposed column record
* Purpose       : Check Existence will verify that the ECO record does not
*                 already exist for creates and it does exist when the user
*                 is performing an Update or Delete.
*                 If Update or Delete the procedure will also return the old
*                 database record.
*****************************************************************************/
PROCEDURE Check_Existence
(  p_change_notice      IN  VARCHAR2
 , p_organization_id    IN  NUMBER
 , p_organization_code  IN  VARCHAR2
 , p_calling_entity     IN  VARCHAR2
 , p_transaction_type   IN  VARCHAR2
 , x_eco_rec            OUT NOCOPY Eng_Eco_Pub.Eco_Rec_Type
 , x_eco_unexp_rec      OUT NOCOPY Eng_Eco_Pub.Eco_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
)
IS
        l_Mesg_token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status         VARCHAR2(1);
        l_err_text              VARCHAR2(2000);
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
BEGIN
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        l_token_tbl(1).token_name  := 'ECO_NAME';
        l_token_tbl(1).token_value := p_change_notice;
        l_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
        l_token_tbl(2).token_value := p_organization_code;

        Eng_Eco_Util.Query_Row
        (  p_change_notice      => p_change_notice
         , p_organization_id    => p_organization_id
         , x_ECO_rec            => x_eco_rec
         , x_ECO_Unexp_Rec      => x_eco_unexp_rec
         , x_return_status      => l_return_status
         , x_err_text           => l_err_text
        );

        IF l_return_status = Eng_Globals.G_RECORD_FOUND AND
           p_calling_entity = 'ECO' AND
           p_transaction_type = Eng_Globals.G_OPR_CREATE
        THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_ECO_ALREADY_EXISTS'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );
/* Commenting the following Code for Bug 3127841 as per Mani's suggestion
        ELSIF l_return_status = Eng_Globals.G_RECORD_FOUND AND
              p_transaction_type = Eng_Globals.G_OPR_UPDATE AND
              x_eco_unexp_rec.approval_status_type in (3, 5)  -- approved or approval requested
        THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_ECO_CANNOT_UPDATE'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );
*/
        ELSIF l_return_status = Eng_Globals.G_RECORD_NOT_FOUND AND
              p_calling_entity = 'ECO' AND
              p_transaction_type IN
              ( Eng_Globals.G_OPR_UPDATE, Eng_Globals.G_OPR_DELETE)
        THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_ECO_DOES_NOT_EXIST'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );

        ELSIF l_return_status = Eng_Globals.G_RECORD_NOT_FOUND AND
              p_calling_entity = 'CHILD'
        THEN
                l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => NULL
                 , p_Message_Text       => l_err_text
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                );
        ELSE
                l_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;

END Check_Existence;


/****************************************************************************
* Function      : Check_Workflow_Process
* Pramaters IN  : Change_Order_Type_Id
*                 Priority Code
*                 Organization_ID
*                  Assignee_ID
*                  Change_ID
* Returns       : TRUE if the ECO has a Workflow process associated with it.
*                 Otherwise returns a False.
* Purpose       : Checks if there is worflow process for the ECO.
*****************************************************************************/
FUNCTION Check_Workflow_Process
(  p_change_order_type_id       IN NUMBER
 , p_priority_code              IN VARCHAR2
 , p_organization_id            IN NUMBER
 , p_assignee_id                 IN  NUMBER
 , p_change_id                  IN NUMBER
) RETURN BOOLEAN
IS
        CURSOR c_CheckProcess IS
        SELECT process_name
          FROM eng_change_type_processes
         WHERE change_order_type_id = p_change_order_type_id
           AND NVL(eng_change_priority_code,'X') = NVL(p_priority_code, 'X');
	  -- Bug 2921534 ,processes are no more organization specific ,thus commenting out the below where condition
         --  AND organization_id = p_organization_id;

         ---While bulkloading PLM records we will have to look at route_id
        CURSOR c_CheckProcess_PLM(p_change_id NUMBER) IS
        SELECT route_id
          FROM eng_engineering_changes
         WHERE change_id = p_change_id ;

 l_route_id NUMBER;

BEGIN

        if ( p_assignee_id is null)
	then
	   FOR Process IN c_CheckProcess
           LOOP
                RETURN TRUE;
           END LOOP;
        else
	      OPEN c_CheckProcess_PLM(p_change_id);
              FETCH c_CheckProcess_PLM INTO l_route_id;
	      CLOSE c_CheckProcess_PLM;
           if(l_route_id is not null) then
	      RETURN TRUE;
            else
               RETURN FALSE;
            end if;
        end if;

        RETURN FALSE;

END Check_Workflow_Process;

/****************************************************************************
* Procedure     : Check_Access
* Parameters IN : ECO Primary Key
* Parameters OUT: Mesg Token Tbl
*                 Return Status
* Purpose       : Procedure will verify if the user has access to the current
*                 ECO byt checking that the eco is not canceled or implemented
*                 or it does not have a workflow process.
*                 Th procedure will also check if the user has access to the
*                 Change order type.
****************************************************************************/
PROCEDURE Check_Access
(  p_change_notice      IN  VARCHAR2
 , p_organization_id    IN  NUMBER
 , p_change_type_code   IN  VARCHAR2 := NULL
 , p_change_order_type_id IN NUMBER := NULL
 , p_Mesg_Token_Tbl     IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                Error_Handler.G_MISS_MESG_TOKEN_TBL
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
 , p_check_scheduled_status IN BOOLEAN DEFAULT TRUE -- Added for Enhancement 5470261
 , p_status_check_required IN BOOLEAN DEFAULT TRUE -- Added for enhancement 5414834
)
IS
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type :=
                                p_Mesg_Token_Tbl;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        l_return_status         VARCHAR2(1);
        l_ProcessExists            BOOLEAN;
        l_WorkflowInprogressExists  BOOLEAN; -- bug no 3591968 by Rashmi
	l_Wkfl                      NUMBER; -- bug no 3591968 by Rashmi
	l_change_order_assembly_Type NUMBER;
        l_change_order_type_id  NUMBER := NULL;
	--added status_code in select stmt for validation
        CURSOR c_CheckECO IS
        SELECT status_type, priority_code, change_order_type_id,status_code --bug no 3591968 by Rashmi
               ,approval_status_type,assignee_id ,change_id --PLM records we will only have to look for processes based on change_type_id
	       , nvl(plm_or_erp_change, 'PLM') plm_or_erp_change
          FROM eng_engineering_changes
         WHERE change_notice = p_change_notice
           AND organization_id = p_organization_id;
        --bug no 3591968 by Rashmi
	/*CURSOR c_CheckProcessInProgress(cp_change_id NUMBER,cp_status_code NUMBER) IS
	select status_code
	from eng_lifecycle_statuses
	where  entity_id1 = cp_change_id
	       and status_code =cp_status_code
	       and entity_name ='ENG_CHANGE'
	       and active_flag='Y'
	       and change_wf_route_id is not null
	       and workflow_status = 'IN_PROGRESS';*/
        -- Bug 4033479
        CURSOR c_lifecycle_status(cp_change_id NUMBER,cp_status_code NUMBER) IS
        select els.status_code, els.workflow_status, els.change_wf_route_id,
               ecs.status_type orig_status_type, els.CHANGE_EDITABLE_FLAG ,
               ecs.status_name
        from eng_lifecycle_statuses els, eng_change_statuses_vl ecs
        where els.ENTITY_NAME = 'ENG_CHANGE'
          and els.ENTITY_ID1 = cp_change_id
          and els.STATUS_CODE = cp_STATUS_CODE
          and els.active_flag = 'Y'
          and els.STATUS_CODE = ecs.STATUS_CODE;

        l_cls_rec c_lifecycle_status%ROWTYPE;
        l_update_allowed BOOLEAN;
        l_status_name eng_change_statuses_tl.status_name%TYPE;
BEGIN

	l_return_status := FND_API.G_RET_STS_SUCCESS;
	l_change_order_type_id := NULL;

        l_Token_Tbl(1).token_name  := 'ECO_NAME';
        l_Token_Tbl(1).token_value := p_change_notice;
        --
        -- Check that the ECO is not Implemented or Cancelled.
        --
        IF Eng_Globals.Is_Eco_Impl IS NULL AND
           Eng_Globals.Is_Eco_Cancl IS NULL AND
           Eng_Globals.Is_WKFL_Process IS NULL AND
           Eng_Globals.Is_ECO_Access IS NULL
        THEN
                FOR ECO IN c_CheckECO
                LOOP
                        IF p_change_order_type_id IS NULL
                        THEN
                                l_change_order_type_id :=
                                        eco.change_order_type_id;
                        END IF;

                        IF ECO.status_type = 6
                        THEN
                                Eng_Globals.Set_Eco_Impl
                                ( p_eco_impl    => TRUE);
                        ELSIF ECO.status_type = 5
                        THEN
                                Eng_Globals.Set_Eco_Cancl
                                ( p_eco_cancl   => TRUE);
                        ELSIF ECO.status_type NOT IN (5,6)
                        THEN
                                Eng_Globals.Set_Eco_Impl
                                ( p_eco_impl    => FALSE);
                                Eng_Globals.Set_Eco_Cancl
                                ( p_eco_cancl   => FALSE);

                                --
                                -- Check if the ECO has a process
                                --
                                l_ProcessExists :=
                                Check_Workflow_Process
                                (  p_change_order_type_id       =>
                                        ECO.change_order_type_id
                                 , p_priority_code              =>
                                        ECO.priority_code
                                 , p_organization_id            =>
                                        p_organization_id
                                 , p_assignee_id                =>
				        ECO.assignee_id
                                 ,p_change_id                  =>
				        ECO.change_id
                                 );

                                IF l_ProcessExists AND
                                   ECO.approval_status_type = 3
                                THEN
                                   Eng_Globals.Set_WKFL_Process
                                   ( p_wkfl_process     => TRUE);
                                ELSE
                                   Eng_Globals.Set_WKFL_Process
                                   ( p_wkfl_process     => FALSE);
                                END IF;


		        END IF;
                        -- Check if ECO is not in progress --bug no 3591968 by Rashmi
                        l_WorkflowInprogressExists  := FALSE ;
                        /*OPEN c_CheckProcessInProgress
                        (cp_change_id => ECO.change_id
                        ,cp_status_code => ECO.status_code );
                        FETCH c_CheckProcessInProgress INTO l_Wkfl ;
                        CLOSE c_CheckProcessInProgress;
                        if( l_Wkfl is not null) then
                         l_WorkflowInprogressExists  := TRUE ;
                        else
                         l_WorkflowInprogressExists  := FALSE ;
                        end if;*/
                        l_update_allowed := TRUE;
                        IF(ECO.plm_or_erp_change = 'PLM')
                        THEN
                            OPEN c_lifecycle_status (cp_change_id   => ECO.change_id
                                                    ,cp_status_code => ECO.status_code );
                            FETCH c_lifecycle_status INTO l_cls_rec ;
                            IF (l_cls_rec.change_wf_route_id is not NULL
                                AND l_cls_rec.workflow_status = 'IN_PROGRESS'
                                AND l_cls_rec.CHANGE_EDITABLE_FLAG <> 'Y')
                            THEN
                                l_WorkflowInprogressExists  := TRUE ;
                            END IF;
                            -- Added for enhancement 5414834
                            IF(p_status_check_required)
			    THEN
				 -- Added for Bug 4033479
				IF (ECO.status_type IN (2, 4, 7, 8, 9,11)
                                    OR (ECO.status_type = 10 AND l_cls_rec.orig_status_type <> 1))
                                THEN
                                -- Added for Enhancement 5470261
				-- If status type is 4<- Scheduled, then check if the p_check_scheduled_status flag is true
				-- Only if the p_check_scheduled_status is true, set the flag to throw the error
				    if(ECO.status_type <> 4 OR p_check_scheduled_status = TRUE) THEN
	                                l_update_allowed := FALSE;
		                        l_status_name := l_cls_rec.status_name;
				     END if;
				-- Code changes for Enhancement 5470261 ends
                                END IF;
                            END IF;
                            CLOSE c_lifecycle_status;
                        END IF;
                END LOOP;
        END IF;

        IF l_change_order_type_id IS NULL
        THEN
                l_change_order_type_id := p_change_order_type_id;
        END IF;

        /****************************************************
        --
        -- Check if user has access to type of ECO. If the
        -- ECO's change order type is Engineering and the
        -- Profile value Eng:Engineering Change Order Type
        -- Access is NO, then the user cannot access this
        -- ECO.
        --
        *****************************************************/
        IF Eng_Globals.Is_ECO_Access IS NULL
        THEN
                SELECT assembly_type
                INTO l_change_order_assembly_Type
                FROM eng_change_order_types
                WHERE change_order_type_id =
                l_change_order_type_id;

                IF l_change_order_assembly_type = 2 /* ENG */
                AND
                Fnd_Profile.Value
                        ('ENG:ENG_ITEM_ECN_ACCESS')
                        = 2
                THEN
                       --
                       -- User does not have access.
                       --
                       Eng_Globals.Set_Eco_Access
                       ( p_eco_access   => FALSE);
                ELSE
                       Eng_Globals.Set_Eco_Access
                       ( p_eco_access   => TRUE);
                END IF;
        END IF;

        IF NVL(Eng_Globals.Is_Eco_Impl, FALSE) = TRUE
        THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_ECO_IMPLEMENTED'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
        ELSIF NVL(Eng_Globals.Is_Eco_Cancl, FALSE) = TRUE
        THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_ECO_CANCELLED'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
        ELSIF NVL(Eng_Globals.Is_WKFL_Process, FALSE) = TRUE
        THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_ECO_WKFL_EXISTS'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
        ELSIF NVL(Eng_Globals.Is_Eco_Access, TRUE) = FALSE
        THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                l_token_tbl(2).token_name  := 'CHANGE_TYPE_CODE';
                l_token_tbl(2).token_value := p_change_type_code;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_ECO_ACCESS_DENIED'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
        END IF;
	--Check if Workflow is in progress
        IF  l_WorkflowInprogressExists  = TRUE
        THEN
	       l_return_status := FND_API.G_RET_STS_ERROR;
               Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_ECO_WKFL_INPROGRESS'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
        -- Added for Bug 4033479
        ELSIF nvl(l_update_allowed, TRUE) = FALSE
        THEN
               l_Token_Tbl(2).token_name  := 'STATUS_NAME';
               l_Token_Tbl(2).token_value := l_status_name;
               l_return_status := FND_API.G_RET_STS_ERROR;
               Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_CHGUPD_NOTALLOWED'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
        END IF;
        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;

END Check_Access;

END ENG_Validate_Eco;

/
