--------------------------------------------------------
--  DDL for Package Body OKE_DELIVERABLE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DELIVERABLE_UTILS" AS
/* $Header: OKEDUTLB.pls 120.1 2005/06/24 10:42:44 ausmani noship $ */

--
-- Global Declarations
--

--
-- Private Procedures and Functions
--
--
FUNCTION GET_PARTY ( x_deliverable_id  NUMBER, x_role_code VARCHAR2 ) RETURN NUMBER  IS

  CURSOR PartySite
  ( C_Deliverable_ID  NUMBER
  , C_Role_Code       VARCHAR2 ) IS
    SELECT pr.jtot_object1_code Object_Code
    ,      pr.object1_id1 ID1
    ,      pr.code
    ,      pr.facility
    FROM   okc_k_party_roles_b pr
    ,      oke_k_deliverables_b kd
    ,    ( select cle_id , cle_id_ascendant , level_sequence
           from okc_ancestrys
           union all
           select id , id , 99999 from okc_k_lines_b ) a
    WHERE  kd.deliverable_id = C_Deliverable_ID
    AND    pr.rle_code = C_Role_Code
    AND    pr.dnz_chr_id = kd.k_header_id
    AND    a.cle_id = kd.k_line_id
    AND  ( ( pr.cle_id IS NULL AND a.cle_id = a.cle_id_ascendant )
         OR pr.cle_id = a.cle_id_ascendant )
    ORDER BY DECODE(pr.cle_id , null , 0 , a.level_sequence) DESC;

  BillToRec       PartySite%RowType;


BEGIN

    -- Fetch Contract Parties Information
    --

    OPEN PartySite( x_deliverable_id , x_role_code );
    FETCH PartySite INTO BillToRec;
    CLOSE PartySite;

RETURN (BillToRec.ID1);

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( TO_NUMBER(NULL) );

END GET_PARTY;


FUNCTION GET_TERM_VALUE ( x_deliverable_id  NUMBER, x_term_code VARCHAR2 ) RETURN VARCHAR2 IS

  CURSOR TermValue
  ( C_Deliverable_ID  NUMBER
  , C_Term_Code       VARCHAR2 ) IS
    SELECT kt.term_value_pk1 Code
    ,      OKE_UTILS.Get_Term_Values
           ( kt.term_code , kt.term_value_pk1
           , kt.term_value_pk2 , 'MEANING' ) Name
    FROM   oke_k_terms kt
    ,      oke_k_deliverables_b kd
    ,    ( select cle_id , cle_id_ascendant , level_sequence
           from okc_ancestrys
           union all
           select id , id , 99999 from okc_k_lines_b ) a
    WHERE  kd.deliverable_id = C_Deliverable_ID
    AND    kt.term_code = C_Term_Code
    AND    kt.k_header_id = kd.k_header_id
    AND    a.cle_id = kd.k_line_id
    AND  ( ( kt.k_line_id IS NULL AND a.cle_id = a.cle_id_ascendant )
         OR kt.k_line_id = a.cle_id_ascendant )
    ORDER BY DECODE(kt.k_line_id , null , 0 , a.level_sequence) DESC;

  DiscTermsRec    TermValue%RowType;

BEGIN

    -- Fetch Contract Term Value Information
    --

    OPEN TermValue( x_deliverable_id , x_term_code );
    FETCH TermValue INTO DiscTermsRec;
    CLOSE TermValue;

RETURN (DiscTermsRec.Name);

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;



END GET_TERM_VALUE;

--
-- Modified in 01/13/2003, use ':' instead of '-' for seperator for bug 2741941
--

FUNCTION Get_K_Reference ( P_Deliverable_ID NUMBER, P_Source_Code VARCHAR2 ) RETURN VARCHAR2 IS

  CURSOR C IS
  SELECT Rtrim(Ltrim(H.Contract_Number, ' '), ' ') K_Number
  , Rtrim(Ltrim(L.Line_Number, ' '), ' ') L_Number
  , Rtrim(Ltrim(D.Deliverable_Num, ' '), ' ') D_Number
  FROM okc_k_headers_all_b H
  , okc_k_lines_b L
  , oke_k_deliverables_b D
  WHERE D.Deliverable_ID = P_Deliverable_ID
  AND L.ID = D.K_Line_ID
  AND H.ID = D.K_Header_ID;

  CURSOR C1 IS
  SELECT Rtrim(Ltrim(H.Deliverable_Number, ' '), ' ') D_Number
  , Rtrim(Ltrim(L.Action_Name, ' '), ' ') A_Number
  FROM oke_deliverables_b H
  , oke_deliverable_actions L
  WHERE H.Deliverable_ID = P_Deliverable_ID
  AND H.Deliverable_ID = L.Deliverable_ID
  AND L.Action_Type = 'WSH'
  AND L.Reference2 > 0;

  L_K_Num VARCHAR2(150);
  L_L_Num VARCHAR2(150);
  L_D_Num VARCHAR2(150);
  L_A_NUM VARCHAR2(150);
  L_Length NUMBER;
  L_Allowed_Length CONSTANT NUMBER := 62;
  L_Ref VARCHAR2(62);


BEGIN

  IF P_Source_Code = 'OKE' THEN

    IF P_Deliverable_ID > 0 THEN

      OPEN C;
      FETCH C INTO L_K_Num, L_L_Num, L_D_Num;
      CLOSE C;

      IF L_K_Num IS NULL THEN -- PA record

        OPEN C1;
	FETCH C1 INTO L_D_Num, L_A_Num;
	CLOSE C1;

        L_Length := Length(L_D_Num || ':'||  L_A_Num);
        WHILE L_Length > L_Allowed_Length LOOP

          IF Length(L_A_Num) > 24 THEN

	    L_A_Num := Substr(L_A_Num, 1, 24);

   	  ELSE

            L_D_Num := Substr(L_D_Num, 1, L_Allowed_Length - Length(':'|| L_D_Num));
          END IF;

          L_Length := Length(L_D_Num || ':'|| L_A_Num);

        END LOOP;
        L_Ref := L_D_Num || ':' || L_A_Num;

      ELSE -- OKE record

        L_Length := Length(L_K_Num || ':'|| L_L_Num || ':' || L_D_Num);

        WHILE L_Length > L_Allowed_Length LOOP

          IF Length(L_D_Num) > 6 THEN

	    L_D_Num := Substr(L_D_Num, 1, 6);

          ELSIF Length(L_L_Num) > 6 THEN

            L_L_Num := Substr(L_L_Num, 1, 6);

   	  ELSE

            L_K_Num := Substr(L_K_Num, 1, L_Allowed_Length - Length(':'|| L_L_Num || ':' || L_D_Num));

          END IF;

          L_Length := Length(L_K_Num || ':'|| L_L_Num || ':' || L_D_Num);

          END LOOP;

          L_Ref := L_K_Num || ':' || L_L_Num || ':' || L_D_Num;
      END IF;
    END IF;
  END IF;

  RETURN L_Ref;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END Get_K_Reference;


END OKE_DELIVERABLE_UTILS;

/
