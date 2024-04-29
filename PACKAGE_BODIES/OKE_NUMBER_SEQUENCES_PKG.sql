--------------------------------------------------------
--  DDL for Package Body OKE_NUMBER_SEQUENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_NUMBER_SEQUENCES_PKG" AS
/* $Header: OKENMSQB.pls 120.1 2005/08/29 13:16:43 ausmani noship $ */

--
-- Global Variables for Line Number generation
--
G_LnHdrID      NUMBER        := NULL;
G_LnPLnID      NUMBER        := NULL;
G_LnStartNum   NUMBER        := NULL;
G_LnIncr       NUMBER        := NULL;
G_LnWidth      NUMBER        := NULL;
G_LastDBLnNum  VARCHAR2(150) := NULL;
G_NextLnNum    NUMBER        := NULL;
G_PrntLnNum    VARCHAR2(150) := NULL;

--
-- Global Variables for Deliverable Number generation
--
G_DlvHdrID     NUMBER        := NULL;
G_DlvLnID      NUMBER        := NULL;
G_DlvStartNum  NUMBER        := NULL;
G_DlvIncr      NUMBER        := NULL;
G_DlvWidth     NUMBER        := NULL;
G_LastDBDlvNum VARCHAR2(150) := NULL;
G_NextDlvNum   NUMBER        := NULL;


--
--  Name          : Number_Option
--  Pre-reqs      : None
--  Function      : This function returns the numbering option given
--                  the contract type and intent.
--
--
--  Parameters    :
--  IN            : X_K_TYPE_CODE      VARCHAR2
--                  X_BUY_OR_SELL      VARCHAR2
--                     B - Buy
--                     S - Sell
--                  X_OBJECT_NAME      VARCHAR2
--                     HEADER - Document Header
--                     CHGREQ - Change Request
--  OUT           : X_Num_Mode         VARCHAR2
--                     MANUAL    - Manual
--                     AUTOMATIC - Automatic
--                  X_Manual_Num_Type  VARCHAR2
--                     NUMERIC      - Numeric
--                     ALPHANUMERIC - Alphanumeric
--
--  Returns       : None
--

PROCEDURE Number_Option
( X_K_Type_Code      IN  VARCHAR2
, X_Buy_Or_Sell      IN  VARCHAR2
, X_Object_Name      IN  VARCHAR2
, X_Num_Mode         OUT NOCOPY VARCHAR2
, X_Manual_Num_Type  OUT NOCOPY VARCHAR2
) IS

BEGIN

  SELECT DECODE( X_Object_Name
               , 'HEADER' , Contract_Num_Mode
               , 'CHGREQ' , ChgReq_Num_Mode )
  ,      DECODE( X_Object_Name
               , 'HEADER' , Manual_Contract_Num_Type
               , 'CHGREQ' , Manual_ChgReq_Num_Type )
  INTO   X_Num_Mode
  ,      X_Manual_Num_Type
  FROM   oke_number_options
  WHERE  K_Type_Code = X_K_Type_Code
  AND    Buy_Or_Sell = X_Buy_Or_Sell;

EXCEPTION
  WHEN OTHERS THEN
    X_Num_Mode        := 'MANUAL';
    X_Manual_Num_Type := 'ALPHANUMERIC';

END Number_Option;


--
--  Name          : Value_Is_Numeric
--  Pre-reqs      : None
--  Function      : This function tests whether a give string is
--                  numeric or not.
--
--
--  Parameters    :
--  IN            : X_VALUE      VARCHAR2
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Value_Is_Numeric
( X_Value            IN  VARCHAR2
) RETURN VARCHAR2 IS

Dummy NUMBER;

BEGIN

  Dummy := TO_NUMBER( X_Value );
  RETURN( 'Y' );

EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN( 'N' );
  WHEN OTHERS THEN
    RETURN( NULL );

END Value_Is_Numeric;


--
--  Name          : Next_Contract_Number
--  Pre-reqs      : None
--  Function      : This function returns the next number based on
--                  numbering option
--
--
--  Parameters    :
--  IN            : X_K_TYPE_CODE      VARCHAR2
--                  X_BUY_OR_SELL      VARCHAR2
--                     B - Buy
--                     S - Sell
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Next_Contract_Number
( X_K_Type_Code      IN  VARCHAR2
, X_Buy_Or_Sell      IN  VARCHAR2
) RETURN VARCHAR2 IS

  CURSOR c IS
    SELECT Contract_Num_Mode       Num_Mode
    ,      Next_Contract_Num       Next_Num
    ,      Contract_Num_Width      Width
    FROM   oke_number_options
    WHERE  K_Type_Code = X_K_Type_Code
    AND    Buy_Or_Sell = X_Buy_Or_Sell
    FOR UPDATE OF Next_Contract_Num;

  crec c%rowtype;
  Return_Value VARCHAR2(120) := NULL;

BEGIN

  OPEN c;
  FETCH c INTO crec;
  CLOSE c;

  IF crec.Num_Mode = 'AUTOMATIC' THEN

    IF ( crec.Width IS NULL ) THEN
      --
      -- Number width is not specified; zero padding not required
      --
      Return_Value := TO_CHAR(crec.Next_Num);
    ELSE
      Return_Value := lpad(crec.Next_Num , crec.Width , '0');
    END IF;

    UPDATE oke_number_options
    SET    Next_Contract_Num = Next_Contract_Num +
                                  Contract_Num_Increment
    ,      Last_Update_Date  = sysdate
    ,      Last_Updated_By   = FND_GLOBAL.User_ID
    WHERE  K_Type_Code = X_K_Type_Code
    AND    Buy_Or_Sell = X_Buy_Or_Sell;

  END IF;

  RETURN ( Return_Value );

END Next_Contract_Number;


--
--  Name          : Next_ChgReq_Number
--  Pre-reqs      : None
--  Function      : This function returns the next change request
--                  number based on numbering option
--
--
--  Parameters    :
--  IN            : X_CHG_TYPE_CODE    VARCHAR2
--                  X_K_HEADER_ID      NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Next_ChgReq_Number
( X_Chg_Type_Code    IN  VARCHAR2
, X_K_Header_ID      IN  NUMBER
) RETURN VARCHAR2 IS

  CURSOR o IS
    SELECT ChgReq_Num_Mode       Num_Mode
    ,      ChgReq_Num_Increment  Incr
    ,      ChgReq_Num_Width      Width
    FROM   oke_number_options    O
    ,      oke_k_headers         EH
    ,      okc_k_headers_b       CH
    WHERE  O.K_Type_Code  = EH.K_Type_Code
    AND    O.Buy_Or_Sell  = CH.Buy_Or_Sell
    AND    CH.ID          = EH.K_Header_ID
    AND    EH.K_Header_ID = X_K_Header_ID;

  CURSOR c IS
    SELECT Chg_Request_Num
    FROM   oke_chg_requests cr
    WHERE  K_Header_ID = X_K_Header_ID
    AND    ltrim(Chg_Request_Num,'0') = (
      SELECT TO_CHAR(MAX(TO_NUMBER(Chg_Request_Num)))
      FROM   oke_chg_requests
      WHERE  K_Header_ID = cr.K_Header_ID
      AND    OKE_NUMBER_SEQUENCES_PKG.Value_Is_Numeric
                  (Chg_Request_Num) = 'Y'
    )
    FOR UPDATE OF Chg_Request_Num;

  orec          o%rowtype;
  crec          c%rowtype;
  Return_Value  VARCHAR2(30) := NULL;

BEGIN

  OPEN o;
  FETCH o INTO orec;
  CLOSE o;

  IF orec.Num_Mode = 'AUTOMATIC' THEN

    OPEN c;
    FETCH c INTO crec;
    CLOSE c;

    IF ( orec.Width IS NULL ) THEN
      --
      -- Number width is not specified; zero padding not required
      --
      Return_Value := TO_CHAR( nvl(crec.Chg_Request_Num , 0) + orec.Incr );
    ELSE
      Return_Value := lpad( TO_CHAR( nvl(crec.Chg_Request_Num , 0) +
                                     orec.Incr ) , orec.Width , '0');
    END IF;

  END IF;

  RETURN ( Return_Value );

END Next_ChgReq_Number;

--
--  Name          : Next_Line_Number
--  Pre-reqs      : None
--  Function      : This function returns the next line
--                  number based on numbering option
--
--
--  Parameters    :
--  IN            : X_K_HEADER_ID      NUMBER
--                  X_PARENT_LINE_ID   NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Next_Line_Number
( X_K_Header_ID      IN  NUMBER
, X_Parent_Line_ID   IN  NUMBER
) RETURN VARCHAR2 IS

  CURSOR LnNumOpt IS
    SELECT ONO.Line_Num_Start_Number
    ,      ONO.Line_Num_Increment
    ,      ONO.Line_Num_Width
    FROM   oke_number_options ONO
    ,      oke_k_headers      EH
    ,      okc_k_headers_b    CH
    WHERE  EH.k_header_id = X_K_Header_ID
    AND    CH.id = EH.k_header_id
    AND    ONO.k_type_code = EH.k_type_code
    AND    ONO.buy_or_sell = CH.buy_or_sell;

  CURSOR SLnNumOpt IS
    SELECT ONO.SubLine_Num_Start_Number
    ,      ONO.SubLine_Num_Increment
    ,      ONO.SubLine_Num_Width
    FROM   oke_number_options ONO
    ,      oke_k_headers      EH
    ,      okc_k_headers_b    CH
    WHERE  EH.k_header_id = X_K_Header_ID
    AND    CH.id = EH.k_header_id
    AND    ONO.k_type_code = EH.k_type_code
    AND    ONO.buy_or_sell = CH.buy_or_sell;

  CURSOR PrntLnNum IS
    SELECT Line_Number
    FROM   okc_k_lines_b d
    WHERE  ID = X_Parent_Line_ID;

  CURSOR LineNum IS
    SELECT Line_Number
    FROM   okc_k_lines_b d
    WHERE  Dnz_Chr_ID = X_K_Header_ID
    AND    NVL(CLe_ID,-1) = NVL(X_Parent_Line_ID,-1)
    AND    ltrim(Line_Number,'0') = (
      SELECT TO_CHAR(MAX(TO_NUMBER(Line_Number)))
      FROM   okc_k_lines_b
      WHERE  Dnz_Chr_ID = d.Dnz_Chr_ID
      AND    NVL(CLe_ID,-1) = NVL(X_Parent_Line_ID,-1)
      AND    OKE_NUMBER_SEQUENCES_PKG.Value_Is_Numeric
                  (Line_Number) = 'Y'
    )
    FOR UPDATE OF Line_Number;

  DBNum        VARCHAR2(150) := NULL;

  FUNCTION NextNumDisp RETURN VARCHAR2 IS

  Prefix VARCHAR2(150);

  BEGIN
    IF ( G_PrntLnNum IS NOT NULL ) THEN
      Prefix := G_PrntLnNum || '.' ;
    ELSE
      Prefix := '';
    END IF;

    IF ( length(to_char(G_NextLnNum)) < G_LnWidth ) THEN
      RETURN( Prefix || lpad( TO_CHAR( G_NextLnNum ) , G_LnWidth , '0' ) );
    ELSE
      RETURN( Prefix || G_NextLnNum );
    END IF;
  END NextNumDisp;

BEGIN



  --
  -- Check to see if cached information is still up to date
  --
  IF (  G_LnHdrID IS NULL
     OR G_LnHdrID <> X_K_Header_ID
     OR nvl(G_LnPLnID,-1) <> nvl(X_Parent_Line_ID,-1) ) THEN
    --
    -- Contract Header is new or different from cached info
    --
    G_LnHdrID := X_K_Header_ID;
    G_LnPLnID := X_Parent_Line_ID;


    IF ( X_Parent_Line_ID IS NULL ) THEN
      --
      -- Desired number is for top line, fetch numbering options for
      -- top lines
      --

      OPEN LnNumOpt;
      FETCH LnNumOpt INTO G_LnStartNum
                        , G_LnIncr
                        , G_LnWidth;
      CLOSE LnNumOpt;

      G_PrntLnNum := NULL;

    ELSE
      --
      -- Desired number is for subline, fetch numbering options for
      -- sublines
      --
      OPEN SLnNumOpt;
      FETCH SLnNumOpt INTO G_LnStartNum
                         , G_LnIncr
                         , G_LnWidth;
      CLOSE SLnNumOpt;

      --
      -- Fetch parent line number for prefixing
      --
      OPEN PrntLnNum;
      FETCH PrntLnNum INTO G_PrntLnNum;
      CLOSE PrntLnNum;

    END IF;



  END IF;

  --
  -- Get Last saved Line Num for the desired contract
  --
  OPEN LineNum;
  FETCH LineNum INTO DBNum;
  IF ( LineNum%NOTFOUND ) THEN
    CLOSE LineNum;
    DBNum := NULL;
  ELSE
    CLOSE LineNum;
  END IF;



  IF ( G_LastDBLnNum = DBNum ) THEN
    --
    -- There is no saved line since last read
    --
    IF ( G_NextLnNum IS NOT NULL ) THEN
      G_NextLnNum := G_NextLnNum + G_LnIncr;
    END IF;



  ELSIF ( G_LastDBDlvNum IS NULL AND DBNum IS NULL ) THEN
    --
    -- This is a special case of the previous case; if there are
    -- no child lines in the system, we do not need to worry
    -- about existing number not numeric
    --
    IF ( G_NextLnNum IS NOT NULL ) THEN
      G_NextLnNum := G_NextLnNum + G_LnIncr;
    ELSE
      G_NextLnNum := G_LnIncr;
    END IF;



  ELSE
    --
    -- Cache information not available or out-of-sync with DB
    --
    G_LastDBLnNum := DBNum;

    IF ( Value_Is_Numeric( G_LastDBLnNum ) = 'Y' ) THEN
      G_NextLnNum := NVL( G_LastDBLnNum , 0 ) + G_LnIncr;
    ELSE
      G_NextLnNum := NULL;
    END IF;



  END IF;



  RETURN ( NextNumDisp );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( sqlerrm );
END Next_Line_Number;

--
--  Name          : Next_Deliverable_Number
--  Pre-reqs      : None
--  Function      : This function returns the next deliverable
--                  number based on numbering option
--
--
--  Parameters    :
--  IN            : X_K_HEADER_ID      NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Next_Deliverable_Number
( X_K_Header_ID      IN  NUMBER
, X_K_Line_ID        IN  NUMBER
) RETURN VARCHAR2 IS

  CURSOR NumOpt IS
    SELECT ONO.Delv_Num_Start_Number
    ,      ONO.Delv_Num_Increment
    ,      ONO.Delv_Num_Width
    FROM   oke_number_options ONO
    ,      oke_k_headers      EH
    ,      okc_k_headers_b    CH
    WHERE  EH.k_header_id = X_K_Header_ID
    AND    CH.id = EH.k_header_id
    AND    ONO.k_type_code = EH.k_type_code
    AND    ONO.buy_or_sell = CH.buy_or_sell;

  CURSOR DlvNum IS
    SELECT Deliverable_Num
    FROM   oke_k_deliverables_b d
    WHERE  K_Header_ID = X_K_Header_ID
    AND    K_Line_ID = X_K_Line_ID
    AND    ltrim(Deliverable_Num,'0') = (
      SELECT to_char(max(to_number(Deliverable_Num)))
      FROM   oke_k_deliverables_b
      WHERE  K_Header_ID = d.K_Header_ID
      AND    K_Line_ID = d.K_Line_ID
      AND    OKE_NUMBER_SEQUENCES_PKG.Value_Is_Numeric
                  (Deliverable_Num) = 'Y'
    )
    FOR UPDATE OF Deliverable_Num;

  DBNum        VARCHAR2(150) := NULL;

FUNCTION NextNumDisp RETURN VARCHAR2 IS
BEGIN
  IF ( length(to_char(G_NextDlvNum)) < G_DlvWidth ) THEN
    RETURN( lpad( TO_CHAR( G_NextDlvNum ) , G_DlvWidth , '0' ) );
  ELSE
    RETURN( G_NextDlvNum );
  END IF;
END NextNumDisp;

BEGIN



  --
  -- Check to see if cached information is still up to date
  --
  IF (  G_DlvHdrID IS NULL
     OR G_DlvHdrID <> X_K_Header_ID
     OR G_DlvLnID <> X_K_Line_ID ) THEN
    --
    -- Contract Header is new or different from cached info
    --
    G_DlvHdrID := X_K_Header_ID;
    G_DlvLnID  := X_K_Line_ID;



    OPEN NumOpt;
    FETCH NumOpt INTO G_DlvStartNum
                    , G_DlvIncr
                    , G_DlvWidth;
    CLOSE NumOpt;



  END IF;

  --
  -- Get Last saved Deliverable Num for the desired contract
  --
  OPEN DlvNum;
  FETCH DlvNum INTO DBNum;
  IF ( DlvNum%NOTFOUND ) THEN
    CLOSE DlvNum;
    DBNum := NULL;
  ELSE
    CLOSE DlvNum;
  END IF;


  IF ( G_LastDBDlvNum = DBNum ) THEN
    --
    -- There is no saved deliverable since last read
    --
    IF ( G_NextDlvNum IS NOT NULL ) THEN
      G_NextDlvNum := G_NextDlvNum + G_DlvIncr;
    END IF;



  ELSIF ( G_LastDBDlvNum IS NULL AND DBNum IS NULL ) THEN
    --
    -- This is a special case of the previous case; if there are
    -- no deliverables in the system, we do not need to worry
    -- about existing number not numeric
    --
    IF ( G_NextDlvNum IS NOT NULL ) THEN
      G_NextDlvNum := G_NextDlvNum + G_DlvIncr;
    ELSE
      G_NextDlvNum := G_DlvIncr;
    END IF;



  ELSE
    --
    -- Cache information not available or out-of-sync with DB
    --
    G_LastDBDlvNum := DBNum;

    IF ( Value_Is_Numeric( G_LastDBDlvNum ) = 'Y' ) THEN
      G_NextDlvNum := NVL( G_LastDBDlvNum , 0 ) + G_DlvIncr;
    ELSE
      G_NextDlvNum := NULL;
    END IF;



  END IF;



  RETURN ( NextNumDisp );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( sqlerrm );
END Next_Deliverable_Number;

END OKE_NUMBER_SEQUENCES_PKG;

/
