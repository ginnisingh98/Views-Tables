--------------------------------------------------------
--  DDL for Package Body PA_PJC_CWK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PJC_CWK_UTILS" AS
-- $Header: PACWKUTB.pls 120.1.12010000.2 2008/08/21 11:36:28 vbkumar ship $

--Function is_rate_based_line
--This function is wrapper around the PO API PO_PA_INTEGRATION_GRP.is_rate_based_line

Function is_rate_based_line (P_Po_Line_Id         In Number ,
                             P_Po_Distribution_Id In Number) Return Varchar2
Is
--   L_PoRateBased BOOLEAN;
     L_IsRb        Varchar2(1) := 'N';
     l_Found  BOOLEAN     := FALSE;
     L_Po_Line_Id  Number;

Begin

   IF p_po_line_id is null and
	/* Bug 4227213 p_po_distribution_id is null THEN */
	nvl(p_po_distribution_id ,0) = 0 THEN
      RETURN 'N';
   END IF;

  If P_Po_Line_Id is null Then
     Begin
        If G_PoLineIdTab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');
            Begin
                L_Po_Line_Id := G_PoLineIdTab(P_Po_Distribution_Id);
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

                If G_PoLineIdTab.COUNT > 999 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_PoLineIdTab.Delete;
                End If;
              Begin
                --Dbms_Output.Put_Line('select');

                Select Po_Line_Id
                Into   L_Po_Line_Id
                From   Po_Distributions_All
                Where  Po_Distribution_id = P_Po_Distribution_Id;

                G_PoLineIdTab(P_Po_Distribution_Id) := L_Po_Line_Id;
                --Dbms_Output.Put_Line('after select');

              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     L_Po_Line_Id := NULL;
                     G_PoLineIdTab(P_Po_Distribution_Id) := NULL;
              End;
        End If;
     End;

  Else
     L_Po_Line_Id := P_Po_Line_Id;
  End If;

 /* Added for bug 7331897 */
	IF l_Po_line_Id is null then
		  RETURN 'N';
    END IF;
 /* Ends Added for bug 7331897 */

     Begin
        If G_IsRbLineTab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');
            Begin
                L_IsRb := G_IsRbLineTab(l_Po_line_Id);
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

                If G_IsRbLineTab.COUNT > 999 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_IsRbLineTab.Delete;
                End If;
              Begin
                --Dbms_Output.Put_Line('select');
                If PO_PA_INTEGRATION_GRP.is_rate_based_line(L_PO_Line_Id, P_Po_Distribution_Id) Then
                   L_IsRb := 'Y';
                Else
                   L_IsRb := 'N';
                End If;

                G_IsRbLineTab(l_Po_Line_Id) := L_IsRb;
                --Dbms_Output.Put_Line('after select');

              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     L_IsRb:= 'N';
                     G_IsRbLineTab(P_Po_Line_Id) := 'N';
              End;
        End If;
     End;

     Return L_IsRb;

Exception
   When Others Then
        Raise;
End is_rate_based_line;


--Function Exists_Prj_Cwk_RbTC(P_Org_Id IN NUMBER)
--Called from the Project Implementations form when the value for XFACE_CWK_TIMECARDS_FLAG is changed from Y to N or vice versa
--Returns 'Y' if there exists project related rate based POs for any of the projects in the given P_Org_Id. Else return 'N'.

Function Exists_Prj_Cwk_RbTC(P_Org_Id IN NUMBER) RETURN Varchar2
Is

   L_Exists Varchar2(1) := 'N';
   l_Found  BOOLEAN     := FALSE;

Begin

        If G_ExCwkRbTCOrgIdTab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');
            Begin
                L_Exists := G_ExCwkRbTCOrgIdTab(P_Org_Id);
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

                If G_ExCwkRbTCOrgIdTab.COUNT > 999 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_ExCwkRbTCOrgIdTab.Delete;
                End If;
              Begin
                --Dbms_Output.Put_Line('select');

                Select 'Y'
                Into   L_Exists
                From   Dual
                Where  Exists (Select 1
                               From Pa_Projects_All P,
                                    Po_Distributions_All Po
                               Where nvl(P.Org_Id, -99) = nvl(P_Org_Id, -99)
                                 And P.Project_Id = Po.Project_Id
                                 And PA_PJC_CWK_UTILS.is_rate_based_line (
                                        Po.Po_Line_Id,
                                        Po.Po_Distribution_Id) = 'Y'
                              );

                G_ExCwkRbTCOrgIdTab(P_Org_Id) := L_Exists;
                --Dbms_Output.Put_Line('after select');

              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     L_Exists := 'N';
                     G_ExCwkRbTCOrgIdTab(P_Org_Id) := 'N';
              End;

        End If;

        Return L_Exists;

Exception
    When Others Then
         Raise;

End Exists_Prj_Cwk_RbTC;

--Function Is_Cwk_TC_Xface_Allowed(P_Project_Id IN NUMBER)
--This function identifies for the given project OU if CWK timecard interface is allowed or not
--If enabled then costs must be interfaced as labor costs for CWK
--If disabled costs must be interfaced as supplier costs for CWK

Function Is_Cwk_TC_Xface_Allowed(P_Project_Id IN NUMBER) RETURN Varchar2
Is

   L_Allowed       Varchar2(1) := 'N';
   l_Found         BOOLEAN     := FALSE;

Begin

        If G_CwkTCXfaceAllowedTab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');
            Begin
                L_Allowed := G_CwkTCXfaceAllowedTab(P_Project_Id);
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

                If G_CwkTCXfaceAllowedTab.COUNT > 999 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_CwkTCXfaceAllowedTab.Delete;
                End If;
              Begin
                --Dbms_Output.Put_Line('select');

                Select I.Xface_Cwk_Timecards_Flag
                Into   L_Allowed
                From   Pa_Projects_All P,
                       Pa_Implementations_All I
                Where  P.Project_Id = P_Project_Id
                AND    p.org_id = i.org_id; -- bug 5365269
                -- And    nvl(P.Org_Id, -99) = nvl(I.Org_Id, -99); -- bug 5365269

                G_CwkTCXfaceAllowedTab(P_Project_Id) := L_Allowed;
                --Dbms_Output.Put_Line('after select');

              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     L_Allowed := 'N';
                     G_CwkTCXfaceAllowedTab(P_Project_Id) := 'N';
              End;

        End If;

        Return L_Allowed;
Exception
   When Others Then
        Raise;
End Is_Cwk_TC_Xface_Allowed;


END PA_PJC_CWK_UTILS;

/
