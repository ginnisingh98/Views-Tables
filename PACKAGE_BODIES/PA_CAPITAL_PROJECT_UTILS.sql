--------------------------------------------------------
--  DDL for Package Body PA_CAPITAL_PROJECT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CAPITAL_PROJECT_UTILS" as
/* $Header: PAXCAUTB.pls 120.1 2007/02/07 13:52:31 anuagraw ship $ */

-----------------------------------------------------------------------------------
--  FUNCTION
--              UnReversed_Assets_Exist
--  PURPOSE
--              Returns 'Y' if there exists asset lines that have not been reversed
--              for the given Asset Id.
--              Returns 'N' if there are no asset lines or all of its asset lines
--              reversed.
--              If 'Y' then in the Capital Projects form we should not allow the asset
--              to be detached from the capital event.
--  In the calling API, If 'Y' then raise error - PA_UNREVERSED_LINES_EXIST
-----------------------------------------------------------------------------------
Function UnReversed_Assets_Exist
           (P_Asset_Id In Number) Return Varchar2 Is

  l_reversed      number := 0;

Begin

  Begin
     --check if asset lines have not been reversed
     Select 1
     Into l_reversed
     From Dual
     where exists (
        SELECT 'X'
          FROM pa_project_asset_lines pal1
         WHERE pal1.project_asset_id = P_Asset_Id
           AND pal1.rev_proj_asset_line_id is null
           AND NOT EXISTS (select null from pa_project_asset_lines pal2
                            where pal2.project_asset_id = P_asset_id
                              and pal2.rev_proj_asset_line_id = pal1.project_asset_line_id));

     RETURN 'Y';
  Exception
     When No_Data_Found Then
       RETURN 'N';
  End;

Exception
  When Others Then
    RAISE;
End UnReversed_Assets_Exist;

-----------------------------------------------------------------------------------
--  FUNCTION
--              UnReversed_Costs_Exist
--  PURPOSE
--              Returns 'Y' if there exists asset line details that have not been reversed
--              for the given EI Id.
--              Returns 'N' if there are no asset line details or all of its asset line
--              details reversed.
--              If 'Y' then in the Capital Projects form we should not allow the EI
--              to be detached from the capital event.
-- In the calling API, If 'Y' then raise error - PA_UNREVERSED_DETAILS_EXIST
-----------------------------------------------------------------------------------
Function UnReversed_Costs_Exist
           (P_Ei_Id In Number) Return Varchar2 Is

  l_reversed      number := 0;

Begin

  Begin
     --check if asset line details have been reversed
     Select 1
       Into l_reversed
       From Dual
     where exists (
        SELECT 'X'
          FROM pa_project_asset_line_details pald
         WHERE pald.expenditure_item_id = P_Ei_Id
           AND  pald.reversed_flag = 'N');

     RETURN 'Y';
  Exception
     When No_Data_Found Then
       RETURN 'N';
  End;

Exception
  When Others Then
    RAISE;

End UnReversed_Costs_Exist;

-----------------------------------------------------------------------------------
--  FUNCTION
--              Reverse_Event
--  PURPOSE
--              Return 'Y' or 'N' depending on the below conditions for reversal
--              is true or not.
--              The conditions are similar to the ones existing in the form currently
--              namely, Do not reverse asset if:
--              1. Not capitalized
--              2. Capitalized but capitalized before previous reversal or not reversed before
--              3. Corresponding FA Asset is not adjustable.
--  In the calling API, if event cannot be reversed then raise the error : PA_REVERSE_EVENT_WARN
-----------------------------------------------------------------------------------
Function Reverse_Event_Allow(P_Project_Id in Number, P_Capital_Event_Id in Number)
         Return Varchar2 Is

   --existing conditions for not allowing reversal for an individual asset
   Cursor C_ReverseAsset Is
   Select 1
   From Dual
   Where Exists (
     Select 1
     From Pa_Project_Assets
     Where Project_Id = P_Project_Id
     And Capital_Event_Id = P_Capital_Event_Id
     And (CAPITALIZED_FLAG = 'N' or
          (trunc(CAPITALIZED_DATE) < trunc(REVERSAL_DATE)
           or
           REVERSAL_DATE is not null )
          or (Fa_Asset_Id is not null and Is_Asset_Adj_Allowed(Fa_Asset_Id,Book_Type_Code) = 0)
         )
   ) ;

   L_Exists Number;

Begin

   Open C_ReverseAsset;
   Fetch C_ReverseAsset into l_Exists;
   If C_ReverseAsset%NOTFOUND Then
      --none of the above conditions met, go ahead and update all assets with reverse_flag = Y
      Return 'Y';
   Else
      --any of the above conditions met, go ahead and ask user to reverse or not
      Return 'N';
   End If;
   Close C_ReverseAsset;

Exception
   When Others Then
        Raise;
End Reverse_Event_Allow;

-----------------------------------------------------------------------------------
--  FUNCTION
--              Reverse_Event_Upd
--  PURPOSE
--              Perform the actual update of setting the reverse_flag to Y
--              And return the number of rows updated
-----------------------------------------------------------------------------------
Function Reverse_Event_Upd(P_Project_Id in Number,
                           P_Capital_Event_Id in Number)
         Return Number Is

Begin

   Update Pa_Project_Assets
   Set    Reverse_Flag = 'Y'
   Where  Project_Id = P_Project_Id
   And    Reverse_Flag = 'N'
   And    Capital_Event_Id = P_Capital_Event_Id;

   Return SQL%ROWCOUNT;

Exception
   When Others Then
        Raise;
End Reverse_Event_Upd;

-----------------------------------------------------------------------------------
--  FUNCTION
--              Is_Asset_Adj_Allowed
--  PURPOSE
--              Given the Fa_Asset_Id/Book_Type_Code, check if the fa_asset_id
--              is adjustable in FA. By calling the fa_mass_add_validate.can_add_to_asset
--              Returns 1 if adjustment allowed
--              Returns 0 if adjustment not allowed
--  In the calling API, FA asset cannot be adjusted then raise the error : PA_FA_ASSET_RETIRED
-----------------------------------------------------------------------------------
Function Is_Asset_Adj_Allowed(P_Fa_Asset_Id in Number,
                              P_Book_Type_Code in Varchar2)
         Return Number Is

    l_Adj_allowed Number;

Begin

    l_Adj_allowed := fa_mass_add_validate.can_add_to_asset(
                          x_asset_id       => P_Fa_Asset_Id,
                          x_book_type_code => P_Book_Type_Code);

    Return l_Adj_allowed;

Exception
    When Others Then
         Raise;

End Is_Asset_Adj_Allowed;

-----------------------------------------------------------------------------------
--  FUNCTION
--              Tag_Number_Exists
--  PURPOSE
--              Check if the tag_number exists in FA or PA
--              This function called from both the Projects/Capital Projects form
--              and AMG
--  In the calling API, If tag number exists then raise the error : PA_ASSET_TAG_EXISTS
-----------------------------------------------------------------------------------
Function Tag_Number_Exists(P_Tag_Number in Varchar2)
         Return Varchar2 Is

  CURSOR c_tag_exists (p_tag_number in varchar2) is
  select 'Y' from dual
  where exists (select tag_number
                   from fa_additions
                where tag_number = p_tag_number)
  or exists (select tag_number
             from pa_project_assets_all
             where tag_number = p_tag_number);

  L_Tag_Exists Varchar2(1) := 'N';

Begin

       OPEN C_TAG_EXISTS(P_TAG_NUMBER);
       FETCH C_TAG_EXISTS INTO L_TAG_EXISTS;
       IF (C_TAG_EXISTS%FOUND) THEN
          Return L_Tag_Exists;
       END IF;
       CLOSE C_TAG_EXISTS;

       Return L_Tag_Exists;

Exception
    When Others Then
         Return 'N';
End Tag_Number_Exists;

-----------------------------------------------------------------------------------
--  FUNCTION
--              Allow_AssetType_Change
--  PURPOSE
--              Given From and To Asset Types, this function will return
--              whether the change is allowed ('Y') or not ('N')
--              This function is called from both the Projects/Capital Projects form
--              and AMG
--  In the calling API, If type change not allowed then raise the error : PA_TYPE_CHG_NOTALLOWED
-----------------------------------------------------------------------------------
/* For the given From and To Asset Types, this function will return
   whether the change is allowed ('Y') or not ('N')

   Combinations:
         From       To       Allowed
       -------    ------    ---------
         EST        ASB      Yes
         EST        RET      Perform validations [And make sure dependent fields are enabled/disabled]
         ASB        EST      Perform validations [Note: Its ok to leave the DPIS as is]
         ASB        RET      No                  [Since DPIS need not be Date Retired]
         RET        EST      Perform validations
                             [User could have mistakenly saved the asset as RET,
                              in which case we should allow them to change
                              And make sure dependent fields are enabled/disabled]
         RET        ASB      Perform validations [And make sure dependent fields are enabled/disabled]

   Validations are as follows:
      Do not allow type change if:
         1. Capitalized
         2. Not Capitalized but Asset Lines Exist
         3. If asset is associated with an event (not -1) or null (probable candidate to be associated)

*/
Function Allow_AssetType_Change(P_From_Asset_Type  in Varchar2,
                                P_To_Asset_Type    in Varchar2,
                                P_Project_Asset_Id in Number,
                                P_Capitalized_Flag in Varchar2,
                                P_Capital_Event_Id in Number
                               ) Return Varchar2
Is

   Cursor C_Asset_Lines_Exist(P_Asset_Id in Number) Is
   Select 1
   From Dual
   Where Exists (select project_asset_id
                 from pa_project_asset_lines_all
                 where project_asset_id = P_Asset_Id);

   L_Exists Number;

Begin


   If P_From_Asset_Type = 'AS-BUILT'
      and
      P_To_Asset_Type = 'RETIREMENT_ADJUSTMENT' Then
      Return 'N';
   End If;

   If P_From_Asset_Type = 'ESTIMATED'
        and
      P_To_Asset_Type = 'AS-BUILT'
   Then
      Return 'Y';
   End If;

   If P_Capitalized_Flag = 'Y' Then
      Return 'N';
   Else
      Open C_Asset_Lines_Exist(P_Project_Asset_Id);
      Fetch C_Asset_Lines_Exist INTO L_Exists;
      If (C_Asset_Lines_Exist%FOUND) THEN
          Return 'N';
      End If;
      Close C_Asset_Lines_Exist;

   End If;

   If P_Capital_Event_Id > 0 Then
      Return 'N';
   End If;

   Return 'Y'; --All validations passed

Exception
   When Others Then
        Return 'N';
End Allow_AssetType_Change;

-----------------------------------------------------------------------------------
--  PROCEDURE
--              get_depreciation_expense_ccid
--  PURPOSE
--              This procedure is called when complete asset definition is required
--              to derive/validate the Depreciation Expense CCID.
--              This calls the client extension override API. If overwritten by the extension
--              then validate if the CCID is a valid expense account.
--              If not an expense account then return the original CCID, else return the
--              CCID overwritten/derived in the client extension.
--              In the calling API, If returned CCID is still NULL
--              then raise standard error : PA_CP_COMPLETE_ASSET_DEF
-----------------------------------------------------------------------------------
PROCEDURE get_depreciation_expense_ccid
              (P_project_asset_id        IN  NUMBER,
               P_book_type_code          IN  VARCHAR2,
               P_asset_category_id       IN  NUMBER,
               P_date_placed_in_service  IN  DATE,
               P_Deprn_expense_CCID      IN  NUMBER,
               X_Deprn_expense_CCID      OUT NOCOPY NUMBER,
               X_Error_Message_Code      OUT NOCOPY VARCHAR2
              ) IS

    l_deprn_expense_ccid   NUMBER;

    --Used to determine if the Depreciation Expense CCID is valid for the current COA
    CURSOR  deprn_expense_cur IS
    SELECT  1
    FROM    gl_code_combinations gcc,
            gl_sets_of_books gsob,
            pa_implementations pi
    WHERE   gcc.code_combination_id = l_deprn_expense_ccid
    AND     gcc.chart_of_accounts_id = gsob.chart_of_accounts_id
    AND     gsob.set_of_books_id = pi.set_of_books_id
    AND     gcc.account_type = 'E';

    l_deprn_expense            NUMBER;

BEGIN

      l_deprn_expense_ccid := PA_CLIENT_EXTN_DEPRN_EXP_OVR.DEPRN_EXPENSE_ACCT_OVERRIDE
                                  (p_project_asset_id        => p_project_asset_id,
                                   p_book_type_code          => p_book_type_code,
                                   p_asset_category_id       => p_asset_category_id,
                                   p_date_placed_in_service  => p_date_placed_in_service,
                                   p_deprn_expense_acct_ccid => p_deprn_expense_ccid);

      IF NVL(p_deprn_expense_ccid,-999) <> NVL(l_deprn_expense_ccid,-999) THEN

         --Return NULL if the client extension has returned a NULL CCID
         IF l_deprn_expense_ccid IS NULL THEN
            X_Deprn_expense_CCID := l_deprn_expense_ccid;
            RETURN;
         END IF;

         --Validate the new ccid against the current Set of Books
         OPEN deprn_expense_cur;
         FETCH deprn_expense_cur INTO l_deprn_expense;

         IF deprn_expense_cur%NOTFOUND THEN
            --Value returned by client extension is invalid, return original CCID
            x_deprn_expense_ccid := p_deprn_expense_ccid;
         ELSE
            --Value is valid, return new CCID
            x_deprn_expense_ccid := l_deprn_expense_ccid;
         END IF;

         CLOSE deprn_expense_cur;

      ELSE

         x_deprn_expense_ccid := p_deprn_expense_ccid;

      END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_error_message_code := SQLCODE;
      RAISE;
END get_depreciation_expense_ccid;

-----------------------------------------------------------------------------------
--  FUNCTION
--              Can_Delete_Event
--  PURPOSE
--              This function checks for the given project and capital event
--              if there exists any event assets or event costs
-----------------------------------------------------------------------------------

FUNCTION Can_Delete_Event(P_Project_Id in NUMBER,
                          P_Capital_Event_Id in NUMBER) RETURN VARCHAR2 Is

    l_Exist Varchar2(1) := 'N';

    Cursor EventAssetExist Is
    Select 'Y'
      From Dual
     Where Exists (Select 1 From Pa_Project_Assets_All
                    Where ProjecT_Id       = P_Project_Id
                      And Capital_Event_Id = P_Capital_Event_Id);

    Cursor EventCostExist Is
    Select 'Y'
      From Dual
     Where Exists (Select 1 From Pa_Expenditure_Items_All
                    Where ProjecT_Id       = P_Project_Id
                      And Capital_Event_Id = P_Capital_Event_Id);

Begin

    Open EventAssetExist;
    Fetch EventAssetExist Into l_Exist;
    Close EventAssetExist;

    If l_Exist = 'N' Then
       Open EventCostExist;
       Fetch EventCostExist Into l_Exist;
       Close EventCostExist;
    End If;

    If l_Exist = 'Y' Then
       Return 'N';
    Else
       Return 'Y';
    End If;

Exception
    When Others Then
       Return 'N';
End Can_Delete_Event;

Function IsValidExpCCID(P_CCID    IN NUMBER) RETURN VARCHAR2
Is
        l_Found         BOOLEAN         := FALSE;
        X_CCID_VALID    VARCHAR2(1);
  Begin
        -- Check if there are any records in the pl/sql table.
        If G_CCID_Tab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');

            Begin
                X_CCID_VALID := G_CCID_Tab(P_CCID);
                l_Found := TRUE;
                --Dbms_Output.Put_Line('l_found TRUE');
            Exception
                When No_Data_Found Then
                        l_Found := FALSE;
                When Others Then
                        Raise;
            End;

        End If;

        If Not l_Found Then
                --Dbms_Output.Put_Line('l_found FALSE');

                If G_CCID_Tab.COUNT > 199 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_CCID_Tab.Delete;
                End If;

              Begin
                --Dbms_Output.Put_Line('select');
                SELECT  'Y'
                INTO    X_CCID_VALID
                FROM    gl_code_combinations gcc,
                        gl_sets_of_books gsob,
                        pa_implementations pi
                WHERE   gcc.code_combination_id = p_ccid
                AND     gcc.chart_of_accounts_id = gsob.chart_of_accounts_id
                AND     gsob.set_of_books_id = pi.set_of_books_id
                AND     gcc.account_type = 'E';

                G_CCID_Tab(P_CCID) := X_CCID_VALID;
                --Dbms_Output.Put_Line('after select');
              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     X_CCID_VALID := 'N';
                     G_CCID_Tab(P_CCID) := 'N';
              End;

        End If;

        Return X_CCID_VALID;

  Exception
        When Others Then
                Raise;

End IsValidExpCCID;

END PA_CAPITAL_PROJECT_UTILS;

/
