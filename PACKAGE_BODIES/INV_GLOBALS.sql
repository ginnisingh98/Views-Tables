--------------------------------------------------------
--  DDL for Package Body INV_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_GLOBALS" AS
/* $Header: INVSGLBB.pls 120.1 2005/05/31 04:59:27 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Globals';


--  Procedure Get_Entities_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  entity constants.
--
--  DO NOT REMOVE

PROCEDURE Get_Entities_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_entity_tbl.DELETE;

--  START GEN entities
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'ALL';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'TROHDR';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'TROLIN';
--  END GEN entities

END Get_Entities_Tbl;

Function Is_Issue_Xfr_Transaction
(p_transaction_action_id In Number) Return Boolean
Is
Begin
	If p_transaction_action_id in (INV_GLOBALS.G_Action_Issue,
       	                               INV_GLOBALS.G_Action_Subxfr,
				       INV_GLOBALS.G_Action_Planxfr,
       	       		               INV_GLOBALS.G_Action_Stgxfr,
       	       		               INV_GLOBALS.G_Action_Orgxfr,
       	       		               INV_GLOBALS.G_Action_IntransitShipment,
       	       		               INV_GLOBALS.G_Action_AssyReturn,
       	       		               INV_GLOBALS.g_action_negcompreturn,
				       INV_GLOBALS.G_Action_ownxfr)
       then
 	Return TRUE;
       Else
 	Return False;
       End If;
End;

--  Initialize control record.
FUNCTION Init_Control_Rec
(   p_operation                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
)RETURN Control_Rec_Type
IS
l_control_rec                 Control_Rec_Type;
BEGIN

    IF p_control_rec.controlled_operation THEN

        RETURN p_control_rec;

    ELSIF p_operation = G_OPR_NONE OR p_operation IS NULL THEN

        l_control_rec.default_attributes:=  FALSE;
        l_control_rec.change_attributes :=  FALSE;
        l_control_rec.validate_entity	:=  FALSE;
        l_control_rec.write_to_DB	:=  FALSE;
        l_control_rec.process		:=  p_control_rec.process;
        l_control_rec.process_entity	:=  p_control_rec.process_entity;
        l_control_rec.request_category	:=  p_control_rec.request_category;
        l_control_rec.request_name	:=  p_control_rec.request_name;
        l_control_rec.clear_api_cache	:=  p_control_rec.clear_api_cache;
        l_control_rec.clear_api_requests:=  p_control_rec.clear_api_requests;

    ELSIF p_operation = G_OPR_CREATE THEN

        l_control_rec.default_attributes:=   TRUE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity  :=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   p_control_rec.process_entity;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_operation = G_OPR_UPDATE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   TRUE;
        l_control_rec.validate_entity	:=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   p_control_rec.process_entity;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_operation = G_OPR_DELETE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity	  :=   TRUE;
        l_control_rec.write_to_DB	  :=   TRUE;
        l_control_rec.process		  :=   TRUE;
        l_control_rec.process_entity	  :=   p_control_rec.process_entity;
        l_control_rec.clear_api_cache	  :=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSE

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Init_Control_Rec'
            ,   'Invalid operation'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    RETURN l_control_rec;

END Init_Control_Rec;

--  Function Equal
--  Number comparison.

FUNCTION Equal
(   p_attribute1                    IN  NUMBER
,   p_attribute2                    IN  NUMBER
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;

--  Varchar2 comparison.

FUNCTION Equal
(   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;

--  Date comparison.

FUNCTION Equal
(   p_attribute1                    IN  DATE
,   p_attribute2                    IN  DATE
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;

PROCEDURE Set_Org_Id
(  p_org_id	In NUMBER
)
IS
BEGIN
	INV_GLOBALS.G_ORG_ID := p_org_id;

END Set_Org_Id;


PROCEDURE set_pjm_org_id(organization_id IN NUMBER)
IS
BEGIN
   -- Setting the profile to the Passed organization
   fnd_profile.put('MFG_ORGANIZATION_ID',organization_id);
END set_pjm_org_id;


FUNCTION NO_NEG_Allowed(p_restrict_flag  IN  Number,
                        p_neg_flag       IN  Number,
                        p_action         IN  Number)
return boolean IS
begin
     if (p_restrict_flag = 2 or p_restrict_flag IS NULL) then
       if (p_neg_flag = 2) THEN
         if (p_action = 1 OR p_action = 2 or p_action = 3 or
             p_action = 21 or p_action = 30 or p_action = 32) then
             Return TRUE;
         else
             Return FALSE;
         end if;
       else
         Return FALSE;
       end if;
     else
       Return TRUE;
     end if;
end No_Neg_Allowed;

Function Locator_Control
(  x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_org_control	In  NUMBER,
   p_sub_control	In  NUMBER,
   p_item_control	In  NUMBER,
   p_Item_Loc_restrict	In  NUMBER,
   p_Org_Neg_allowed	In  NUMBER,
   p_Action	        In  NUMBER
) Return Number
IS

l_locator_control number;
l_invalid_loc_control_exc exception;

BEGIN

    if (p_org_control = 1) then
       l_locator_control := 1;
    elsif (p_org_control = 2) then
       l_locator_control := 2;
    elsif (p_org_control = 3) then
       l_locator_control := 3 ;
       if no_neg_allowed(p_Item_Loc_restrict,p_Org_neg_Allowed,p_action)
       then
         l_locator_control := 2;
       end if;
    elsif (p_org_control = 4) then
      if (p_sub_control = 1) then
         l_locator_control := 1;
      elsif (p_sub_control = 2) then
         l_locator_control := 2;
      elsif (p_sub_control = 3) then
         l_locator_control := 3;
         if no_neg_allowed(p_Item_Loc_restrict,p_Org_neg_Allowed,p_action)
         then
           l_locator_control := 2;
         end if;
      elsif (p_sub_control = 5) then
        if (p_item_control = 1) then
           l_locator_control := 1;
        elsif (p_item_control = 2) then
           l_locator_control := 2;
        elsif (p_item_control = 3) then
           l_locator_control := 3;
           if no_neg_allowed(p_Item_Loc_restrict,p_Org_neg_Allowed,p_action)
           then
             l_locator_control := 2;
           end if;
        elsif (p_item_control IS NULL) then
           l_locator_control := p_sub_control;
        else
          raise l_invalid_loc_control_exc;
        end if;
      else
          raise l_invalid_loc_control_exc;
      end if;
    else
          raise l_invalid_loc_control_exc;
    end if;

    return l_locator_control;

    exception
      when l_invalid_loc_control_exc then
        fnd_message.set_name('INV','INV_INVALID_LOC_CONTROL');
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error ;
        l_locator_control := -1 ;
        return l_locator_control ;

      when fnd_api.g_exc_error then
        x_return_status := fnd_api.g_ret_sts_error ;
        l_locator_control := -1 ;
        return l_locator_control ;

      when fnd_api.g_exc_unexpected_error then
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        l_locator_control := -1 ;
        return l_locator_control ;

      when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        if (fnd_msg_pub.check_msg_level(
            fnd_msg_pub.g_msg_lvl_unexp_error)) then
            fnd_msg_pub.add_exc_msg(g_pkg_name, 'Locator_Control');
        end if;

        l_locator_control := -1 ;
        return l_locator_control ;

END Locator_Control;

PROCEDURE GET_COA_LEDGER_ID
    (X_return_status         OUT   NOCOPY VARCHAR2,
     X_msg_data              OUT   NOCOPY VARCHAR2,
     P_Account_Info_Context  IN    VARCHAR2,
     P_ENTITY_CONTEXT        IN    VARCHAR2,
     P_Org_Id                IN    NUMBER,
     X_ACCOUNT_INFO1         OUT   NOCOPY NUMBER,
     X_ACCOUNT_INFO3         OUT   NOCOPY NUMBER,
     X_COA_ID                OUT   NOCOPY NUMBER
    ) IS
    l_msg_data        VARCHAR2(2000);
    l_legal_entity_id NUMBER;
BEGIN
  IF P_ACCOUNT_INFO_CONTEXT NOT IN ('SOB','COA','BOTH') THEN
        --
        -- Exiting with Error Message if the Info Context is not Passed properly
        --
        X_return_status := 'E';
  ELSIF P_ACCOUNT_INFO_CONTEXT = 'SOB' THEN
      --
      -- Get the Org_Information1 and Org_Information3 that stores LedgerID
      -- for Inventory Organization and Operating Unit(depends on value
      -- of P_ENTITY_CONTEXT) respectively.
      --
      BEGIN
          SELECT to_number(org_information1), to_number(org_information3)
            INTO X_ACCOUNT_INFO1, X_ACCOUNT_INFO3
          FROM   hr_organization_information
          WHERE  organization_id = P_Org_Id
            AND  org_information_context = P_ENTITY_CONTEXT;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             X_return_status := 'E';
      END;
  ELSIF P_ACCOUNT_INFO_CONTEXT IN ('COA','BOTH') THEN
      BEGIN
      --
      -- Get the Org_Information1 and Org_Information3 that stores LedgerID
      -- for Inventory Organization and Operating Unit(depends on value
      -- of P_ENTITY_CONTEXT) respectively. Additionally also get chart_of_accounts.
      --
          SELECT to_number(HOI.org_information1), to_number(HOI.org_information3), gsob.chart_of_accounts_id
            INTO X_ACCOUNT_INFO1, X_ACCOUNT_INFO3, X_COA_ID
          FROM   gl_sets_of_books gsob,
                 hr_organization_information HOI
          WHERE  HOI.organization_id = P_Org_Id
            AND  HOI.org_information_context = P_ENTITY_CONTEXT
            AND  gsob.set_of_books_id = DECODE(P_ENTITY_CONTEXT,
                                                  'Operating Unit Information',to_number(HOI.org_information3),
                                                  to_number(HOI.org_information1));
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             X_return_status := 'E';
      END;
   END IF;
END GET_COA_LEDGER_ID;

PROCEDURE GET_LEDGER_INFO
    (X_return_status         OUT   NOCOPY VARCHAR2,
     X_msg_data              OUT   NOCOPY VARCHAR2,
     P_Context_Type          IN    VARCHAR2,
     P_Org_Id                IN    NUMBER,
     X_SOB_ID                OUT   NOCOPY NUMBER,
     X_COA_ID                OUT   NOCOPY NUMBER,
     P_Account_Info_Context  IN    VARCHAR2 DEFAULT 'SOB'
    ) IS
    l_legal_entity_id NUMBER;
    l_Account_Info1   NUMBER;
    l_Account_Info3   NUMBER;
    l_COA_Id          NUMBER;

BEGIN
    IF (p_context_type NOT IN ('Legal Entity Accounting',
                               'Operating Unit Information',
                               'Accounting Information')) THEN

        --
        -- Exiting with Error Message if the Info Context is not Passed properly
        --
        X_return_status := 'E';
    ELSE
        --
        -- Call to the Private Procedure to the Accounting Information
        -- and Chart of Accounts
        --
        GET_COA_LEDGER_ID(
                  X_return_status         => X_return_status,
                  X_msg_data              => X_msg_data,
                  P_Account_Info_Context  => P_Account_Info_Context,
                  P_ENTITY_CONTEXT        => P_Context_Type,
                  P_Org_Id                => P_Org_Id,
                  X_ACCOUNT_INFO1         => l_Account_Info1,
                  X_ACCOUNT_INFO3         => l_Account_Info3,
                  X_COA_ID                => l_COA_Id);
        IF NVL(X_return_status,'S') = 'S' THEN
          IF p_context_type IN ('Legal Entity Accounting',
                                'Accounting Information') THEN
            --
            -- Return l_Account_Info1 as SOB_ID if context is Legal Entity or Inventory Organization
            --
            X_SOB_ID := l_Account_Info1;
            X_COA_ID := l_COA_Id;
          ELSE
            --
            -- Return l_Account_Info3 as SOB_ID if context is Operating Unit
            --
            X_SOB_ID := l_Account_Info3;
            X_COA_ID := l_COA_Id;
          END IF;
        END IF;
    END IF;
END GET_LEDGER_INFO;

END INV_Globals;

/
