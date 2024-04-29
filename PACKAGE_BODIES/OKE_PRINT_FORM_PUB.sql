--------------------------------------------------------
--  DDL for Package Body OKE_PRINT_FORM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_PRINT_FORM_PUB" AS
/* $Header: OKEPPFMB.pls 115.7 2002/11/19 21:22:28 jxtang ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OKE_PRINT_FORM_PUB';

--
-- Private Utility Procedures
--
PROCEDURE Convert_Value_To_ID
( p_header_rec             IN    PFH_Rec_Type
, x_header_rec             OUT NOCOPY   PFH_Rec_Type
, p_line_tbl               IN    PFL_Tbl_Type
, x_line_tbl               OUT NOCOPY   PFL_Tbl_Type
, p_api_name               IN    VARCHAR2
, x_return_status          OUT NOCOPY   VARCHAR2
) IS

cursor kh
( c_contract_number  varchar2
, c_k_type_code      varchar2
, c_buy_or_sell      varchar2
) is
  select k_header_id
  from   oke_k_headers_v
  where  k_number_disp = c_contract_number
  and    k_type_code = c_k_type_code
  and    buy_or_sell = c_buy_or_sell;

cursor kl
( c_header_id    number
, c_line_number  varchar2
) is
  select id
  from   okc_k_lines_b
  where  dnz_chr_id = c_header_id
  and    line_number = c_line_number;

cursor kd
( c_header_id        number
, c_line_id          number
, c_deliverable_num  varchar2
) is
  select deliverable_id
  from   oke_k_deliverables_b
  where  k_header_id = c_header_id
  and    k_line_id = c_line_id
  and    deliverable_num = c_deliverable_num;

cursor sts ( c_status_name  varchar2 ) is
  select lookup_code
  from   fnd_lookup_values_vl
  where  view_application_id = 777
  and    lookup_type = 'PRINT_FORM_STATUS'
  and    meaning = c_status_name;

cursor pfh
( c_header_id        number
, c_print_form_code  varchar2
, c_form_header_num  varchar2
) is
  select form_header_id
  from   oke_k_form_headers
  where  k_header_id = c_header_id
  and    print_form_code = c_print_form_code
  and    form_header_number = c_form_header_num;

i number;

BEGIN

  x_header_rec := p_header_rec;
  x_line_tbl := p_line_tbl;

  --
  -- Converting Contract Header Number to ID
  --
  IF ( x_header_rec.Contract_Header_ID IS NULL
     AND x_header_rec.Contract_Number IS NOT NULL ) THEN
    OPEN kh ( x_header_rec.Contract_Number
            , x_header_rec.K_Type_Code
            , x_header_rec.Buy_Or_Sell );
    FETCH kh INTO x_header_rec.Contract_Header_ID;
    CLOSE kh;
  END IF;

  --
  -- Converting Contract Line Number to ID
  --
  IF ( x_header_rec.Contract_Line_ID IS NULL
     AND x_header_rec.Contract_Line_Number IS NOT NULL ) THEN
    OPEN kl ( x_header_rec.contract_header_id
            , x_header_rec.contract_line_number );
    FETCH kl INTO x_header_rec.Contract_Line_ID;
    CLOSE kl;
  END IF;

  --
  -- Converting Contract Deliverable Number to ID
  --
  IF ( x_header_rec.Deliverable_ID IS NULL
     AND x_header_rec.Deliverable_Number IS NOT NULL ) THEN
    OPEN kd ( x_header_rec.contract_header_id
            , x_header_rec.contract_line_id
            , x_header_rec.deliverable_number );
    FETCH kd INTO x_header_rec.Deliverable_ID;
    CLOSE kd;
  END IF;

  --
  -- Converting Form Status Name to Code
  --
  IF ( x_header_rec.Status_Code IS NULL
     AND x_header_rec.Status_Name IS NOT NULL ) THEN
    OPEN sts ( x_header_rec.status_name );
    FETCH sts INTO x_header_rec.Status_Code;
    CLOSE sts;
  END IF;

  --
  -- Converting Form Header Number to ID if API is UPDATE_PRINT_FORM
  --
  IF ( p_api_name = 'UPDATE_PRINT_FORM' ) THEN
    IF ( x_header_rec.Form_Header_ID IS NULL
      AND x_header_rec.Form_Header_Number IS NOT NULL ) THEN
      OPEN pfh ( x_header_rec.contract_header_id
               , x_header_rec.print_form_code
               , x_header_rec.form_header_number );
      FETCH pfh INTO x_header_rec.Form_Header_ID;
      CLOSE pfh;
    END IF;
  END IF;

  --
  -- Now loop through all lines
  --
  i := p_line_tbl.FIRST;

  LOOP
    --
    -- Converting Contract Header Number to ID
    --
    IF ( x_line_tbl(i).Contract_Header_ID IS NULL
       AND x_line_tbl(i).Contract_Number IS NOT NULL ) THEN
      OPEN kh ( x_line_tbl(i).Contract_Number
              , x_line_tbl(i).K_Type_Code
              , x_line_tbl(i).Buy_Or_Sell );
      FETCH kh INTO x_line_tbl(i).Contract_Header_ID;
      CLOSE kh;
    END IF;

    --
    -- Converting Contract Line Number to ID
    --
    IF ( x_line_tbl(i).Contract_Line_ID IS NULL
       AND x_line_tbl(i).Contract_Line_Number IS NOT NULL ) THEN
      OPEN kl ( x_line_tbl(i).contract_header_id
              , x_line_tbl(i).contract_line_number );
      FETCH kl INTO x_line_tbl(i).Contract_Line_ID;
      CLOSE kl;
    END IF;

    --
    -- Converting Contract Deliverable Number to ID
    --
    IF ( x_line_tbl(i).Deliverable_ID IS NULL
       AND x_line_tbl(i).Deliverable_Number IS NOT NULL ) THEN
      OPEN kd ( x_line_tbl(i).contract_header_id
              , x_line_tbl(i).contract_line_id
              , x_line_tbl(i).deliverable_number );
      FETCH kd INTO x_line_tbl(i).Deliverable_ID;
      CLOSE kd;
    END IF;

    EXIT WHEN ( i = p_line_tbl.LAST );
    i := p_line_tbl.NEXT(i);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
               ( p_pkg_name        => G_PKG_NAME
               , p_procedure_name  => 'CONVERT_VALUE_TO_ID' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Convert_Value_To_ID;


PROCEDURE Validate_Data
( p_header_rec             IN    PFH_Rec_Type
, p_api_name               IN    VARCHAR2
, x_return_status          OUT NOCOPY   VARCHAR2
) IS

cursor kh is
  select count(1)
  from   okc_k_headers_b
  where  id = p_header_rec.contract_header_id;

cursor kl is
  select count(1)
  from   okc_k_lines_b
  where  id = p_header_rec.contract_line_id;

cursor kd is
  select count(1)
  from   oke_k_deliverables_b
  where  deliverable_id = p_header_rec.deliverable_id;

cursor pf is
  select count(1)
  from   oke_print_forms_b
  where  print_form_code = p_header_rec.print_form_code;

cursor kpf is
  select count(1)
  from   oke_k_print_forms
  where  k_header_id = p_header_rec.contract_header_id
  and    print_form_code = p_header_rec.print_form_code;

cursor sts is
  select count(1)
  from   fnd_lookup_values_vl
  where  view_application_id = 777
  and    lookup_type = 'PRINT_FORM_STATUS'
  and    lookup_code = p_header_rec.status_code;

cursor pfhnum is
  select count(1)
  from   oke_k_form_headers
  where  k_header_id = p_header_rec.contract_header_id
  and    print_form_code = p_header_rec.print_form_code
  and    form_header_number = p_header_rec.form_header_number;

cursor pfhid is
  select count(1)
  from   oke_k_form_headers
  where  form_header_id = p_header_rec.form_header_id;

l_row_exists NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Step 4 : validate contract header ID
  --
  IF ( p_header_rec.Contract_Header_ID IS NULL
     AND p_header_rec.Contract_Number IS NULL ) THEN
    --
    -- Make sure either ID or number is provided
    --
    FND_MESSAGE.Set_Name('OKE','OKE_API_MISSING_VALUE');
    FND_MESSAGE.Set_Token('VALUE' , 'CONTRACT_HEADER_ID');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF ( p_header_rec.Contract_Header_ID IS NULL
        AND p_header_rec.Contract_Number IS NOT NULL ) THEN
    --
    -- Check to see if number is valid
    --
    FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
    FND_MESSAGE.Set_Token('VALUE' , 'CONTRACT_NUMBER');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF ( p_header_rec.Contract_Header_ID IS NOT NULL ) THEN
    --
    -- Validate Contract Header ID
    --
    OPEN kh;
    FETCH kh INTO l_row_exists;
    CLOSE kh;
    IF ( l_row_exists = 0 ) THEN
      FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
      FND_MESSAGE.Set_Token('VALUE' , 'CONTRACT_HEADER_ID');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  --
  -- Step 5 : validate contract line ID
  --
  IF ( p_header_rec.Contract_Line_ID IS NULL
        AND p_header_rec.Contract_Line_Number IS NOT NULL ) THEN
    --
    -- Check to see if number is valid
    --
    FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
    FND_MESSAGE.Set_Token('VALUE' , 'CONTRACT_LINE_NUMBER');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF ( p_header_rec.Contract_Line_ID IS NOT NULL ) THEN
    --
    -- Validate Contract Line ID
    --
    OPEN kl;
    FETCH kl INTO l_row_exists;
    CLOSE kl;
    IF ( l_row_exists = 0 ) THEN
      FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
      FND_MESSAGE.Set_Token('VALUE' , 'CONTRACT_LINE_ID');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  --
  -- Step 6 : validate deliverable ID
  --
  IF ( p_header_rec.Deliverable_ID IS NULL
        AND p_header_rec.Deliverable_Number IS NOT NULL ) THEN
    --
    -- Check to see if deliverable number is valid
    --
    FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
    FND_MESSAGE.Set_Token('VALUE' , 'DELIVERABLE_NUMBER');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF ( p_header_rec.Deliverable_ID IS NOT NULL ) THEN
    --
    -- Validate Deliverable ID
    --
    OPEN kd;
    FETCH kd INTO l_row_exists;
    CLOSE kd;
    IF ( l_row_exists = 0 ) THEN
      FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
      FND_MESSAGE.Set_Token('VALUE' , 'DELIVERABLE_ID');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  --
  -- Step 7 : validate status code
  --
  IF ( p_header_rec.Status_Code IS NULL
        AND p_header_rec.Status_Name IS NULL ) THEN
    --
    -- Make sure either Code or Name is provided
    --
    FND_MESSAGE.Set_Name('OKE','OKE_API_MISSING_VALUE');
    FND_MESSAGE.Set_Token('VALUE' , 'STATUS_CODE');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF ( p_header_rec.Status_Code IS NULL
        AND p_header_rec.Status_Name IS NOT NULL ) THEN
    --
    -- Check to see if name is valid
    --
    FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
    FND_MESSAGE.Set_Token('VALUE' , 'STATUS_NAME');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF ( p_header_rec.Status_Code IS NOT NULL ) THEN
    --
    -- Validate Status Code
    --
    OPEN sts;
    FETCH sts INTO l_row_exists;
    CLOSE sts;
    IF ( l_row_exists = 0 ) THEN
      FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
      FND_MESSAGE.Set_Token('VALUE' , 'STATUS_CODE');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  --
  -- Step 8 : API specific validations
  --
  IF ( p_api_name = 'CREATE_PRINT_FORM' ) THEN
    --
    -- Step 1 : validate print form code
    --
    IF ( p_header_rec.Print_Form_Code IS NULL ) THEN
      --
      -- Make sure either Code or Name is provided
      --
      FND_MESSAGE.Set_Name('OKE','OKE_API_MISSING_VALUE');
      FND_MESSAGE.Set_Token('VALUE' , 'PRINT_FORM_CODE');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF ( p_header_rec.Print_Form_Code IS NOT NULL ) THEN
      --
      -- Validate Status Code
      --
      OPEN pf;
      FETCH pf INTO l_row_exists;
      CLOSE pf;
      IF ( l_row_exists = 0 ) THEN
        FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
        FND_MESSAGE.Set_Token('VALUE' , 'PRINT_FORM_CODE');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;

    --
    -- Step 2 : validate form date
    --
    IF ( p_header_rec.Form_Date IS NULL ) THEN
      --
      -- Make sure Form date is provided
      --
      FND_MESSAGE.Set_Name('OKE','OKE_API_MISSING_VALUE');
      FND_MESSAGE.Set_Token('VALUE' , 'FORM_DATE');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    --
    -- Step 3 : validate form number
    --
    IF ( p_header_rec.Form_Header_Number IS NULL ) THEN
      --
      -- Make sure Form Header Number is provided
      --
      FND_MESSAGE.Set_Name('OKE','OKE_API_MISSING_VALUE');
      FND_MESSAGE.Set_Token('VALUE' , 'FORM_DATE');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    ELSE

      OPEN pfhnum;
      FETCH pfhnum INTO l_row_exists;
      CLOSE pfhnum;
      IF ( l_row_exists > 0 ) THEN
        FND_MESSAGE.Set_Name('OKE','OKE_API_DUPLICATE_VALUE');
        FND_MESSAGE.Set_Token('VALUE' , 'FORM_HEADER_NUMBER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;

    --
    -- Step 8 : validate contract print form requirement
    --
    OPEN kpf;
    FETCH kpf INTO l_row_exists;
    CLOSE kpf;
    IF ( l_row_exists = 0 ) THEN
      FND_MESSAGE.Set_Name('OKE','OKE_FORM_INVALID_FOR_CONTRACT');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  ELSIF ( p_api_name = 'UPDATE_PRINT_FORM' ) THEN
    --
    -- Make sure an existing instance is specified
    --
    IF ( p_header_rec.form_header_id IS NULL
       AND p_header_rec.form_header_number IS NULL ) THEN
      FND_MESSAGE.Set_Name('OKE','OKE_API_MISSING_VALUE');
      FND_MESSAGE.Set_Token('VALUE','FORM_HEADER_NUMBER');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF ( p_header_rec.form_header_id IS NULL
       AND p_header_rec.form_header_number IS NOT NULL ) THEN
      FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
      FND_MESSAGE.Set_Token('VALUE','FORM_HEADER_NUMBER');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    ELSE
      OPEN pfhid;
      FETCH pfhid INTO l_row_exists;
      CLOSE pfhid;
      IF ( l_row_exists = 0 ) THEN
        FND_MESSAGE.Set_Name('OKE','OKE_API_INVALID_VALUE');
        FND_MESSAGE.Set_Token('VALUE','FORM_HEADER_ID');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
               ( p_pkg_name        => G_PKG_NAME
               , p_procedure_name  => 'VALIDATE_DATA' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Data;


PROCEDURE Create_Form
( p_header_rec             IN    PFH_Rec_Type
, p_line_tbl               IN    PFL_Tbl_Type
, x_form_header_id         OUT NOCOPY   NUMBER
, x_return_status          OUT NOCOPY   VARCHAR2
) IS

  l_user_id   NUMBER := FND_GLOBAL.user_id;
  l_login_id  NUMBER := FND_GLOBAL.login_id;
  i           NUMBER;

BEGIN

  SELECT oke_k_form_headers_s.nextval
  INTO   x_form_header_id
  FROM   dual;

  INSERT INTO oke_k_form_headers
  ( form_header_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , print_form_code
  , form_header_number
  , form_date
  , status_code
  , k_header_id
  , k_line_id
  , deliverable_id
  , reference1 , reference2 , reference3 , reference4 , reference5
  , text01 , text02 , text03 , text04 , text05
  , text06 , text07 , text08 , text09 , text10
  , text11 , text12 , text13 , text14 , text15
  , text16 , text17 , text18 , text19 , text20
  , text21 , text22 , text23 , text24 , text25
  , text26 , text27 , text28 , text29 , text30
  , text31 , text32 , text33 , text34 , text35
  , text36 , text37 , text38 , text39 , text40
  , text41 , text42 , text43 , text44 , text45
  , text46 , text47 , text48 , text49 , text50
  , number01 , number02 , number03 , number04 , number05
  , number06 , number07 , number08 , number09 , number10
  , number11 , number12 , number13 , number14 , number15
  , number16 , number17 , number18 , number19 , number20
  , number21 , number22 , number23 , number24 , number25
  , number26 , number27 , number28 , number29 , number30
  , number31 , number32 , number33 , number34 , number35
  , number36 , number37 , number38 , number39 , number40
  , number41 , number42 , number43 , number44 , number45
  , number46 , number47 , number48 , number49 , number50
  , date01 , date02 , date03 , date04 , date05
  , date06 , date07 , date08 , date09 , date10
  , date11 , date12 , date13 , date14 , date15
  , date16 , date17 , date18 , date19 , date20
  , date21 , date22 , date23 , date24 , date25
  , date26 , date27 , date28 , date29 , date30
  , date31 , date32 , date33 , date34 , date35
  , date36 , date37 , date38 , date39 , date40
  , date41 , date42 , date43 , date44 , date45
  , date46 , date47 , date48 , date49 , date50 )
  SELECT
    x_form_header_id
  , sysdate
  , l_user_id
  , sysdate
  , l_user_id
  , l_login_id
  , p_header_rec.print_form_code
  , p_header_rec.form_header_number
  , p_header_rec.form_date
  , p_header_rec.status_code
  , p_header_rec.contract_header_id
  , p_header_rec.contract_line_id
  , p_header_rec.deliverable_id
  , p_header_rec.reference1
  , p_header_rec.reference2
  , p_header_rec.reference3
  , p_header_rec.reference4
  , p_header_rec.reference5
  , decode(p_header_rec.text01 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text01)
  , decode(p_header_rec.text02 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text02)
  , decode(p_header_rec.text03 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text03)
  , decode(p_header_rec.text04 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text04)
  , decode(p_header_rec.text05 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text05)
  , decode(p_header_rec.text06 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text06)
  , decode(p_header_rec.text07 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text07)
  , decode(p_header_rec.text08 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text08)
  , decode(p_header_rec.text09 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text09)
  , decode(p_header_rec.text10 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text10)
  , decode(p_header_rec.text11 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text11)
  , decode(p_header_rec.text12 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text12)
  , decode(p_header_rec.text13 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text13)
  , decode(p_header_rec.text14 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text14)
  , decode(p_header_rec.text15 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text15)
  , decode(p_header_rec.text16 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text16)
  , decode(p_header_rec.text17 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text17)
  , decode(p_header_rec.text18 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text18)
  , decode(p_header_rec.text19 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text19)
  , decode(p_header_rec.text20 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text20)
  , decode(p_header_rec.text21 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text21)
  , decode(p_header_rec.text22 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text22)
  , decode(p_header_rec.text23 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text23)
  , decode(p_header_rec.text24 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text24)
  , decode(p_header_rec.text25 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text25)
  , decode(p_header_rec.text26 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text26)
  , decode(p_header_rec.text27 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text27)
  , decode(p_header_rec.text28 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text28)
  , decode(p_header_rec.text29 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text29)
  , decode(p_header_rec.text30 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text30)
  , decode(p_header_rec.text31 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text31)
  , decode(p_header_rec.text32 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text32)
  , decode(p_header_rec.text33 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text33)
  , decode(p_header_rec.text34 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text34)
  , decode(p_header_rec.text35 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text35)
  , decode(p_header_rec.text36 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text36)
  , decode(p_header_rec.text37 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text37)
  , decode(p_header_rec.text38 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text38)
  , decode(p_header_rec.text39 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text39)
  , decode(p_header_rec.text40 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text40)
  , decode(p_header_rec.text41 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text41)
  , decode(p_header_rec.text42 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text42)
  , decode(p_header_rec.text43 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text43)
  , decode(p_header_rec.text44 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text44)
  , decode(p_header_rec.text45 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text45)
  , decode(p_header_rec.text46 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text46)
  , decode(p_header_rec.text47 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text47)
  , decode(p_header_rec.text48 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text48)
  , decode(p_header_rec.text49 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text49)
  , decode(p_header_rec.text50 , FND_API.G_MISS_CHAR , NULL , p_header_rec.text50)
  , decode(p_header_rec.number01 , FND_API.G_MISS_NUM , NULL , p_header_rec.number01)
  , decode(p_header_rec.number02 , FND_API.G_MISS_NUM , NULL , p_header_rec.number02)
  , decode(p_header_rec.number03 , FND_API.G_MISS_NUM , NULL , p_header_rec.number03)
  , decode(p_header_rec.number04 , FND_API.G_MISS_NUM , NULL , p_header_rec.number04)
  , decode(p_header_rec.number05 , FND_API.G_MISS_NUM , NULL , p_header_rec.number05)
  , decode(p_header_rec.number06 , FND_API.G_MISS_NUM , NULL , p_header_rec.number06)
  , decode(p_header_rec.number07 , FND_API.G_MISS_NUM , NULL , p_header_rec.number07)
  , decode(p_header_rec.number08 , FND_API.G_MISS_NUM , NULL , p_header_rec.number08)
  , decode(p_header_rec.number09 , FND_API.G_MISS_NUM , NULL , p_header_rec.number09)
  , decode(p_header_rec.number10 , FND_API.G_MISS_NUM , NULL , p_header_rec.number10)
  , decode(p_header_rec.number11 , FND_API.G_MISS_NUM , NULL , p_header_rec.number11)
  , decode(p_header_rec.number12 , FND_API.G_MISS_NUM , NULL , p_header_rec.number12)
  , decode(p_header_rec.number13 , FND_API.G_MISS_NUM , NULL , p_header_rec.number13)
  , decode(p_header_rec.number14 , FND_API.G_MISS_NUM , NULL , p_header_rec.number14)
  , decode(p_header_rec.number15 , FND_API.G_MISS_NUM , NULL , p_header_rec.number15)
  , decode(p_header_rec.number16 , FND_API.G_MISS_NUM , NULL , p_header_rec.number16)
  , decode(p_header_rec.number17 , FND_API.G_MISS_NUM , NULL , p_header_rec.number17)
  , decode(p_header_rec.number18 , FND_API.G_MISS_NUM , NULL , p_header_rec.number18)
  , decode(p_header_rec.number19 , FND_API.G_MISS_NUM , NULL , p_header_rec.number19)
  , decode(p_header_rec.number20 , FND_API.G_MISS_NUM , NULL , p_header_rec.number20)
  , decode(p_header_rec.number21 , FND_API.G_MISS_NUM , NULL , p_header_rec.number21)
  , decode(p_header_rec.number22 , FND_API.G_MISS_NUM , NULL , p_header_rec.number22)
  , decode(p_header_rec.number23 , FND_API.G_MISS_NUM , NULL , p_header_rec.number23)
  , decode(p_header_rec.number24 , FND_API.G_MISS_NUM , NULL , p_header_rec.number24)
  , decode(p_header_rec.number25 , FND_API.G_MISS_NUM , NULL , p_header_rec.number25)
  , decode(p_header_rec.number26 , FND_API.G_MISS_NUM , NULL , p_header_rec.number26)
  , decode(p_header_rec.number27 , FND_API.G_MISS_NUM , NULL , p_header_rec.number27)
  , decode(p_header_rec.number28 , FND_API.G_MISS_NUM , NULL , p_header_rec.number28)
  , decode(p_header_rec.number29 , FND_API.G_MISS_NUM , NULL , p_header_rec.number29)
  , decode(p_header_rec.number30 , FND_API.G_MISS_NUM , NULL , p_header_rec.number30)
  , decode(p_header_rec.number31 , FND_API.G_MISS_NUM , NULL , p_header_rec.number31)
  , decode(p_header_rec.number32 , FND_API.G_MISS_NUM , NULL , p_header_rec.number32)
  , decode(p_header_rec.number33 , FND_API.G_MISS_NUM , NULL , p_header_rec.number33)
  , decode(p_header_rec.number34 , FND_API.G_MISS_NUM , NULL , p_header_rec.number34)
  , decode(p_header_rec.number35 , FND_API.G_MISS_NUM , NULL , p_header_rec.number35)
  , decode(p_header_rec.number36 , FND_API.G_MISS_NUM , NULL , p_header_rec.number36)
  , decode(p_header_rec.number37 , FND_API.G_MISS_NUM , NULL , p_header_rec.number37)
  , decode(p_header_rec.number38 , FND_API.G_MISS_NUM , NULL , p_header_rec.number38)
  , decode(p_header_rec.number39 , FND_API.G_MISS_NUM , NULL , p_header_rec.number39)
  , decode(p_header_rec.number40 , FND_API.G_MISS_NUM , NULL , p_header_rec.number40)
  , decode(p_header_rec.number41 , FND_API.G_MISS_NUM , NULL , p_header_rec.number41)
  , decode(p_header_rec.number42 , FND_API.G_MISS_NUM , NULL , p_header_rec.number42)
  , decode(p_header_rec.number43 , FND_API.G_MISS_NUM , NULL , p_header_rec.number43)
  , decode(p_header_rec.number44 , FND_API.G_MISS_NUM , NULL , p_header_rec.number44)
  , decode(p_header_rec.number45 , FND_API.G_MISS_NUM , NULL , p_header_rec.number45)
  , decode(p_header_rec.number46 , FND_API.G_MISS_NUM , NULL , p_header_rec.number46)
  , decode(p_header_rec.number47 , FND_API.G_MISS_NUM , NULL , p_header_rec.number47)
  , decode(p_header_rec.number48 , FND_API.G_MISS_NUM , NULL , p_header_rec.number48)
  , decode(p_header_rec.number49 , FND_API.G_MISS_NUM , NULL , p_header_rec.number49)
  , decode(p_header_rec.number50 , FND_API.G_MISS_NUM , NULL , p_header_rec.number50)
  , decode(p_header_rec.date01 , FND_API.G_MISS_DATE , NULL , p_header_rec.date01)
  , decode(p_header_rec.date02 , FND_API.G_MISS_DATE , NULL , p_header_rec.date02)
  , decode(p_header_rec.date03 , FND_API.G_MISS_DATE , NULL , p_header_rec.date03)
  , decode(p_header_rec.date04 , FND_API.G_MISS_DATE , NULL , p_header_rec.date04)
  , decode(p_header_rec.date05 , FND_API.G_MISS_DATE , NULL , p_header_rec.date05)
  , decode(p_header_rec.date06 , FND_API.G_MISS_DATE , NULL , p_header_rec.date06)
  , decode(p_header_rec.date07 , FND_API.G_MISS_DATE , NULL , p_header_rec.date07)
  , decode(p_header_rec.date08 , FND_API.G_MISS_DATE , NULL , p_header_rec.date08)
  , decode(p_header_rec.date09 , FND_API.G_MISS_DATE , NULL , p_header_rec.date09)
  , decode(p_header_rec.date10 , FND_API.G_MISS_DATE , NULL , p_header_rec.date10)
  , decode(p_header_rec.date11 , FND_API.G_MISS_DATE , NULL , p_header_rec.date11)
  , decode(p_header_rec.date12 , FND_API.G_MISS_DATE , NULL , p_header_rec.date12)
  , decode(p_header_rec.date13 , FND_API.G_MISS_DATE , NULL , p_header_rec.date13)
  , decode(p_header_rec.date14 , FND_API.G_MISS_DATE , NULL , p_header_rec.date14)
  , decode(p_header_rec.date15 , FND_API.G_MISS_DATE , NULL , p_header_rec.date15)
  , decode(p_header_rec.date16 , FND_API.G_MISS_DATE , NULL , p_header_rec.date16)
  , decode(p_header_rec.date17 , FND_API.G_MISS_DATE , NULL , p_header_rec.date17)
  , decode(p_header_rec.date18 , FND_API.G_MISS_DATE , NULL , p_header_rec.date18)
  , decode(p_header_rec.date19 , FND_API.G_MISS_DATE , NULL , p_header_rec.date19)
  , decode(p_header_rec.date20 , FND_API.G_MISS_DATE , NULL , p_header_rec.date20)
  , decode(p_header_rec.date21 , FND_API.G_MISS_DATE , NULL , p_header_rec.date21)
  , decode(p_header_rec.date22 , FND_API.G_MISS_DATE , NULL , p_header_rec.date22)
  , decode(p_header_rec.date23 , FND_API.G_MISS_DATE , NULL , p_header_rec.date23)
  , decode(p_header_rec.date24 , FND_API.G_MISS_DATE , NULL , p_header_rec.date24)
  , decode(p_header_rec.date25 , FND_API.G_MISS_DATE , NULL , p_header_rec.date25)
  , decode(p_header_rec.date26 , FND_API.G_MISS_DATE , NULL , p_header_rec.date26)
  , decode(p_header_rec.date27 , FND_API.G_MISS_DATE , NULL , p_header_rec.date27)
  , decode(p_header_rec.date28 , FND_API.G_MISS_DATE , NULL , p_header_rec.date28)
  , decode(p_header_rec.date29 , FND_API.G_MISS_DATE , NULL , p_header_rec.date29)
  , decode(p_header_rec.date30 , FND_API.G_MISS_DATE , NULL , p_header_rec.date30)
  , decode(p_header_rec.date31 , FND_API.G_MISS_DATE , NULL , p_header_rec.date31)
  , decode(p_header_rec.date32 , FND_API.G_MISS_DATE , NULL , p_header_rec.date32)
  , decode(p_header_rec.date33 , FND_API.G_MISS_DATE , NULL , p_header_rec.date33)
  , decode(p_header_rec.date34 , FND_API.G_MISS_DATE , NULL , p_header_rec.date34)
  , decode(p_header_rec.date35 , FND_API.G_MISS_DATE , NULL , p_header_rec.date35)
  , decode(p_header_rec.date36 , FND_API.G_MISS_DATE , NULL , p_header_rec.date36)
  , decode(p_header_rec.date37 , FND_API.G_MISS_DATE , NULL , p_header_rec.date37)
  , decode(p_header_rec.date38 , FND_API.G_MISS_DATE , NULL , p_header_rec.date38)
  , decode(p_header_rec.date39 , FND_API.G_MISS_DATE , NULL , p_header_rec.date39)
  , decode(p_header_rec.date40 , FND_API.G_MISS_DATE , NULL , p_header_rec.date40)
  , decode(p_header_rec.date41 , FND_API.G_MISS_DATE , NULL , p_header_rec.date41)
  , decode(p_header_rec.date42 , FND_API.G_MISS_DATE , NULL , p_header_rec.date42)
  , decode(p_header_rec.date43 , FND_API.G_MISS_DATE , NULL , p_header_rec.date43)
  , decode(p_header_rec.date44 , FND_API.G_MISS_DATE , NULL , p_header_rec.date44)
  , decode(p_header_rec.date45 , FND_API.G_MISS_DATE , NULL , p_header_rec.date45)
  , decode(p_header_rec.date46 , FND_API.G_MISS_DATE , NULL , p_header_rec.date46)
  , decode(p_header_rec.date47 , FND_API.G_MISS_DATE , NULL , p_header_rec.date47)
  , decode(p_header_rec.date48 , FND_API.G_MISS_DATE , NULL , p_header_rec.date48)
  , decode(p_header_rec.date49 , FND_API.G_MISS_DATE , NULL , p_header_rec.date49)
  , decode(p_header_rec.date50 , FND_API.G_MISS_DATE , NULL , p_header_rec.date50)
  FROM dual;

  i := p_line_tbl.FIRST;
  LOOP
    INSERT INTO oke_k_form_lines
    ( form_header_id
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , form_line_number
    , k_header_id
    , k_line_id
    , deliverable_id
    , reference1 , reference2 , reference3 , reference4 , reference5
    , text01 , text02 , text03 , text04 , text05
    , text06 , text07 , text08 , text09 , text10
    , text11 , text12 , text13 , text14 , text15
    , text16 , text17 , text18 , text19 , text20
    , text21 , text22 , text23 , text24 , text25
    , text26 , text27 , text28 , text29 , text30
    , text31 , text32 , text33 , text34 , text35
    , text36 , text37 , text38 , text39 , text40
    , text41 , text42 , text43 , text44 , text45
    , text46 , text47 , text48 , text49 , text50
    , number01 , number02 , number03 , number04 , number05
    , number06 , number07 , number08 , number09 , number10
    , number11 , number12 , number13 , number14 , number15
    , number16 , number17 , number18 , number19 , number20
    , number21 , number22 , number23 , number24 , number25
    , number26 , number27 , number28 , number29 , number30
    , number31 , number32 , number33 , number34 , number35
    , number36 , number37 , number38 , number39 , number40
    , number41 , number42 , number43 , number44 , number45
    , number46 , number47 , number48 , number49 , number50
    , date01 , date02 , date03 , date04 , date05
    , date06 , date07 , date08 , date09 , date10
    , date11 , date12 , date13 , date14 , date15
    , date16 , date17 , date18 , date19 , date20
    , date21 , date22 , date23 , date24 , date25
    , date26 , date27 , date28 , date29 , date30
    , date31 , date32 , date33 , date34 , date35
    , date36 , date37 , date38 , date39 , date40
    , date41 , date42 , date43 , date44 , date45
    , date46 , date47 , date48 , date49 , date50 )
    SELECT
      x_form_header_id
    , sysdate
    , l_user_id
    , sysdate
    , l_user_id
    , l_login_id
    , p_line_tbl(i).form_line_number
    , p_line_tbl(i).contract_header_id
    , p_line_tbl(i).contract_line_id
    , p_line_tbl(i).deliverable_id
    , p_line_tbl(i).reference1
    , p_line_tbl(i).reference2
    , p_line_tbl(i).reference3
    , p_line_tbl(i).reference4
    , p_line_tbl(i).reference5
    , decode(p_line_tbl(i).text01 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text01)
    , decode(p_line_tbl(i).text02 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text02)
    , decode(p_line_tbl(i).text03 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text03)
    , decode(p_line_tbl(i).text04 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text04)
    , decode(p_line_tbl(i).text05 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text05)
    , decode(p_line_tbl(i).text06 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text06)
    , decode(p_line_tbl(i).text07 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text07)
    , decode(p_line_tbl(i).text08 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text08)
    , decode(p_line_tbl(i).text09 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text09)
    , decode(p_line_tbl(i).text10 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text10)
    , decode(p_line_tbl(i).text11 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text11)
    , decode(p_line_tbl(i).text12 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text12)
    , decode(p_line_tbl(i).text13 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text13)
    , decode(p_line_tbl(i).text14 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text14)
    , decode(p_line_tbl(i).text15 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text15)
    , decode(p_line_tbl(i).text16 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text16)
    , decode(p_line_tbl(i).text17 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text17)
    , decode(p_line_tbl(i).text18 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text18)
    , decode(p_line_tbl(i).text19 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text19)
    , decode(p_line_tbl(i).text20 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text20)
    , decode(p_line_tbl(i).text21 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text21)
    , decode(p_line_tbl(i).text22 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text22)
    , decode(p_line_tbl(i).text23 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text23)
    , decode(p_line_tbl(i).text24 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text24)
    , decode(p_line_tbl(i).text25 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text25)
    , decode(p_line_tbl(i).text26 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text26)
    , decode(p_line_tbl(i).text27 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text27)
    , decode(p_line_tbl(i).text28 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text28)
    , decode(p_line_tbl(i).text29 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text29)
    , decode(p_line_tbl(i).text30 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text30)
    , decode(p_line_tbl(i).text31 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text31)
    , decode(p_line_tbl(i).text32 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text32)
    , decode(p_line_tbl(i).text33 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text33)
    , decode(p_line_tbl(i).text34 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text34)
    , decode(p_line_tbl(i).text35 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text35)
    , decode(p_line_tbl(i).text36 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text36)
    , decode(p_line_tbl(i).text37 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text37)
    , decode(p_line_tbl(i).text38 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text38)
    , decode(p_line_tbl(i).text39 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text39)
    , decode(p_line_tbl(i).text40 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text40)
    , decode(p_line_tbl(i).text41 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text41)
    , decode(p_line_tbl(i).text42 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text42)
    , decode(p_line_tbl(i).text43 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text43)
    , decode(p_line_tbl(i).text44 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text44)
    , decode(p_line_tbl(i).text45 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text45)
    , decode(p_line_tbl(i).text46 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text46)
    , decode(p_line_tbl(i).text47 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text47)
    , decode(p_line_tbl(i).text48 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text48)
    , decode(p_line_tbl(i).text49 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text49)
    , decode(p_line_tbl(i).text50 , FND_API.G_MISS_CHAR , NULL , p_line_tbl(i).text50)
    , decode(p_line_tbl(i).number01 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number01)
    , decode(p_line_tbl(i).number02 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number02)
    , decode(p_line_tbl(i).number03 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number03)
    , decode(p_line_tbl(i).number04 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number04)
    , decode(p_line_tbl(i).number05 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number05)
    , decode(p_line_tbl(i).number06 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number06)
    , decode(p_line_tbl(i).number07 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number07)
    , decode(p_line_tbl(i).number08 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number08)
    , decode(p_line_tbl(i).number09 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number09)
    , decode(p_line_tbl(i).number10 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number10)
    , decode(p_line_tbl(i).number11 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number11)
    , decode(p_line_tbl(i).number12 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number12)
    , decode(p_line_tbl(i).number13 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number13)
    , decode(p_line_tbl(i).number14 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number14)
    , decode(p_line_tbl(i).number15 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number15)
    , decode(p_line_tbl(i).number16 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number16)
    , decode(p_line_tbl(i).number17 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number17)
    , decode(p_line_tbl(i).number18 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number18)
    , decode(p_line_tbl(i).number19 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number19)
    , decode(p_line_tbl(i).number20 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number20)
    , decode(p_line_tbl(i).number21 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number21)
    , decode(p_line_tbl(i).number22 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number22)
    , decode(p_line_tbl(i).number23 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number23)
    , decode(p_line_tbl(i).number24 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number24)
    , decode(p_line_tbl(i).number25 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number25)
    , decode(p_line_tbl(i).number26 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number26)
    , decode(p_line_tbl(i).number27 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number27)
    , decode(p_line_tbl(i).number28 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number28)
    , decode(p_line_tbl(i).number29 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number29)
    , decode(p_line_tbl(i).number30 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number30)
    , decode(p_line_tbl(i).number31 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number31)
    , decode(p_line_tbl(i).number32 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number32)
    , decode(p_line_tbl(i).number33 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number33)
    , decode(p_line_tbl(i).number34 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number34)
    , decode(p_line_tbl(i).number35 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number35)
    , decode(p_line_tbl(i).number36 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number36)
    , decode(p_line_tbl(i).number37 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number37)
    , decode(p_line_tbl(i).number38 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number38)
    , decode(p_line_tbl(i).number39 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number39)
    , decode(p_line_tbl(i).number40 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number40)
    , decode(p_line_tbl(i).number41 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number41)
    , decode(p_line_tbl(i).number42 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number42)
    , decode(p_line_tbl(i).number43 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number43)
    , decode(p_line_tbl(i).number44 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number44)
    , decode(p_line_tbl(i).number45 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number45)
    , decode(p_line_tbl(i).number46 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number46)
    , decode(p_line_tbl(i).number47 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number47)
    , decode(p_line_tbl(i).number48 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number48)
    , decode(p_line_tbl(i).number49 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number49)
    , decode(p_line_tbl(i).number50 , FND_API.G_MISS_NUM , NULL , p_line_tbl(i).number50)
    , decode(p_line_tbl(i).date01 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date01)
    , decode(p_line_tbl(i).date02 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date02)
    , decode(p_line_tbl(i).date03 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date03)
    , decode(p_line_tbl(i).date04 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date04)
    , decode(p_line_tbl(i).date05 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date05)
    , decode(p_line_tbl(i).date06 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date06)
    , decode(p_line_tbl(i).date07 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date07)
    , decode(p_line_tbl(i).date08 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date08)
    , decode(p_line_tbl(i).date09 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date09)
    , decode(p_line_tbl(i).date10 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date10)
    , decode(p_line_tbl(i).date11 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date11)
    , decode(p_line_tbl(i).date12 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date12)
    , decode(p_line_tbl(i).date13 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date13)
    , decode(p_line_tbl(i).date14 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date14)
    , decode(p_line_tbl(i).date15 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date15)
    , decode(p_line_tbl(i).date16 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date16)
    , decode(p_line_tbl(i).date17 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date17)
    , decode(p_line_tbl(i).date18 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date18)
    , decode(p_line_tbl(i).date19 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date19)
    , decode(p_line_tbl(i).date20 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date20)
    , decode(p_line_tbl(i).date21 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date21)
    , decode(p_line_tbl(i).date22 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date22)
    , decode(p_line_tbl(i).date23 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date23)
    , decode(p_line_tbl(i).date24 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date24)
    , decode(p_line_tbl(i).date25 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date25)
    , decode(p_line_tbl(i).date26 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date26)
    , decode(p_line_tbl(i).date27 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date27)
    , decode(p_line_tbl(i).date28 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date28)
    , decode(p_line_tbl(i).date29 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date29)
    , decode(p_line_tbl(i).date30 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date30)
    , decode(p_line_tbl(i).date31 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date31)
    , decode(p_line_tbl(i).date32 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date32)
    , decode(p_line_tbl(i).date33 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date33)
    , decode(p_line_tbl(i).date34 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date34)
    , decode(p_line_tbl(i).date35 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date35)
    , decode(p_line_tbl(i).date36 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date36)
    , decode(p_line_tbl(i).date37 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date37)
    , decode(p_line_tbl(i).date38 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date38)
    , decode(p_line_tbl(i).date39 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date39)
    , decode(p_line_tbl(i).date40 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date40)
    , decode(p_line_tbl(i).date41 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date41)
    , decode(p_line_tbl(i).date42 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date42)
    , decode(p_line_tbl(i).date43 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date43)
    , decode(p_line_tbl(i).date44 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date44)
    , decode(p_line_tbl(i).date45 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date45)
    , decode(p_line_tbl(i).date46 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date46)
    , decode(p_line_tbl(i).date47 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date47)
    , decode(p_line_tbl(i).date48 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date48)
    , decode(p_line_tbl(i).date49 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date49)
    , decode(p_line_tbl(i).date50 , FND_API.G_MISS_DATE , NULL , p_line_tbl(i).date50)
    FROM dual;

    EXIT WHEN ( i = p_line_tbl.LAST );
    i := p_line_tbl.NEXT(i);
  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
               ( p_pkg_name        => G_PKG_NAME
               , p_procedure_name  => 'CREATE_FORM' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Form;


PROCEDURE Update_Form
( p_header_rec             IN    PFH_Rec_Type
, p_line_tbl               IN    PFL_Tbl_Type
, x_return_status          OUT NOCOPY   VARCHAR2
) IS

  l_user_id   NUMBER := FND_GLOBAL.user_id;
  l_login_id  NUMBER := FND_GLOBAL.login_id;
  i           NUMBER;

BEGIN

  UPDATE oke_k_form_headers
  SET last_update_date  = sysdate
  ,   last_updated_by   = l_user_id
  ,   last_update_login = l_login_id
  ,   status_code       = p_header_rec.status_code
  ,   k_line_id         = p_header_rec.contract_line_id
  ,   deliverable_id    = p_header_rec.deliverable_id
  ,   text01 = decode(p_header_rec.text01,FND_API.G_MISS_CHAR,text01,p_header_rec.text01)
  ,   text02 = decode(p_header_rec.text02,FND_API.G_MISS_CHAR,text02,p_header_rec.text02)
  ,   text03 = decode(p_header_rec.text03,FND_API.G_MISS_CHAR,text03,p_header_rec.text03)
  ,   text04 = decode(p_header_rec.text04,FND_API.G_MISS_CHAR,text04,p_header_rec.text04)
  ,   text05 = decode(p_header_rec.text05,FND_API.G_MISS_CHAR,text05,p_header_rec.text05)
  ,   text06 = decode(p_header_rec.text06,FND_API.G_MISS_CHAR,text06,p_header_rec.text06)
  ,   text07 = decode(p_header_rec.text07,FND_API.G_MISS_CHAR,text07,p_header_rec.text07)
  ,   text08 = decode(p_header_rec.text08,FND_API.G_MISS_CHAR,text08,p_header_rec.text08)
  ,   text09 = decode(p_header_rec.text09,FND_API.G_MISS_CHAR,text09,p_header_rec.text09)
  ,   text10 = decode(p_header_rec.text10,FND_API.G_MISS_CHAR,text10,p_header_rec.text10)
  ,   text11 = decode(p_header_rec.text11,FND_API.G_MISS_CHAR,text11,p_header_rec.text11)
  ,   text12 = decode(p_header_rec.text12,FND_API.G_MISS_CHAR,text12,p_header_rec.text12)
  ,   text13 = decode(p_header_rec.text13,FND_API.G_MISS_CHAR,text13,p_header_rec.text13)
  ,   text14 = decode(p_header_rec.text14,FND_API.G_MISS_CHAR,text14,p_header_rec.text14)
  ,   text15 = decode(p_header_rec.text15,FND_API.G_MISS_CHAR,text15,p_header_rec.text15)
  ,   text16 = decode(p_header_rec.text16,FND_API.G_MISS_CHAR,text16,p_header_rec.text16)
  ,   text17 = decode(p_header_rec.text17,FND_API.G_MISS_CHAR,text17,p_header_rec.text17)
  ,   text18 = decode(p_header_rec.text18,FND_API.G_MISS_CHAR,text18,p_header_rec.text18)
  ,   text19 = decode(p_header_rec.text19,FND_API.G_MISS_CHAR,text19,p_header_rec.text19)
  ,   text20 = decode(p_header_rec.text20,FND_API.G_MISS_CHAR,text20,p_header_rec.text20)
  ,   text21 = decode(p_header_rec.text21,FND_API.G_MISS_CHAR,text21,p_header_rec.text21)
  ,   text22 = decode(p_header_rec.text22,FND_API.G_MISS_CHAR,text22,p_header_rec.text22)
  ,   text23 = decode(p_header_rec.text23,FND_API.G_MISS_CHAR,text23,p_header_rec.text23)
  ,   text24 = decode(p_header_rec.text24,FND_API.G_MISS_CHAR,text24,p_header_rec.text24)
  ,   text25 = decode(p_header_rec.text25,FND_API.G_MISS_CHAR,text25,p_header_rec.text25)
  ,   text26 = decode(p_header_rec.text26,FND_API.G_MISS_CHAR,text26,p_header_rec.text26)
  ,   text27 = decode(p_header_rec.text27,FND_API.G_MISS_CHAR,text27,p_header_rec.text27)
  ,   text28 = decode(p_header_rec.text28,FND_API.G_MISS_CHAR,text28,p_header_rec.text28)
  ,   text29 = decode(p_header_rec.text29,FND_API.G_MISS_CHAR,text29,p_header_rec.text29)
  ,   text30 = decode(p_header_rec.text30,FND_API.G_MISS_CHAR,text30,p_header_rec.text30)
  ,   text31 = decode(p_header_rec.text31,FND_API.G_MISS_CHAR,text31,p_header_rec.text31)
  ,   text32 = decode(p_header_rec.text32,FND_API.G_MISS_CHAR,text32,p_header_rec.text32)
  ,   text33 = decode(p_header_rec.text33,FND_API.G_MISS_CHAR,text33,p_header_rec.text33)
  ,   text34 = decode(p_header_rec.text34,FND_API.G_MISS_CHAR,text34,p_header_rec.text34)
  ,   text35 = decode(p_header_rec.text35,FND_API.G_MISS_CHAR,text35,p_header_rec.text35)
  ,   text36 = decode(p_header_rec.text36,FND_API.G_MISS_CHAR,text36,p_header_rec.text36)
  ,   text37 = decode(p_header_rec.text37,FND_API.G_MISS_CHAR,text37,p_header_rec.text37)
  ,   text38 = decode(p_header_rec.text38,FND_API.G_MISS_CHAR,text38,p_header_rec.text38)
  ,   text39 = decode(p_header_rec.text39,FND_API.G_MISS_CHAR,text39,p_header_rec.text39)
  ,   text40 = decode(p_header_rec.text40,FND_API.G_MISS_CHAR,text40,p_header_rec.text40)
  ,   text41 = decode(p_header_rec.text41,FND_API.G_MISS_CHAR,text41,p_header_rec.text41)
  ,   text42 = decode(p_header_rec.text42,FND_API.G_MISS_CHAR,text42,p_header_rec.text42)
  ,   text43 = decode(p_header_rec.text43,FND_API.G_MISS_CHAR,text43,p_header_rec.text43)
  ,   text44 = decode(p_header_rec.text44,FND_API.G_MISS_CHAR,text44,p_header_rec.text44)
  ,   text45 = decode(p_header_rec.text45,FND_API.G_MISS_CHAR,text45,p_header_rec.text45)
  ,   text46 = decode(p_header_rec.text46,FND_API.G_MISS_CHAR,text46,p_header_rec.text46)
  ,   text47 = decode(p_header_rec.text47,FND_API.G_MISS_CHAR,text47,p_header_rec.text47)
  ,   text48 = decode(p_header_rec.text48,FND_API.G_MISS_CHAR,text48,p_header_rec.text48)
  ,   text49 = decode(p_header_rec.text49,FND_API.G_MISS_CHAR,text49,p_header_rec.text49)
  ,   text50 = decode(p_header_rec.text50,FND_API.G_MISS_CHAR,text50,p_header_rec.text50)
  ,   number01 = decode(p_header_rec.number01,FND_API.G_MISS_NUM,number01,p_header_rec.number01)
  ,   number02 = decode(p_header_rec.number02,FND_API.G_MISS_NUM,number02,p_header_rec.number02)
  ,   number03 = decode(p_header_rec.number03,FND_API.G_MISS_NUM,number03,p_header_rec.number03)
  ,   number04 = decode(p_header_rec.number04,FND_API.G_MISS_NUM,number04,p_header_rec.number04)
  ,   number05 = decode(p_header_rec.number05,FND_API.G_MISS_NUM,number05,p_header_rec.number05)
  ,   number06 = decode(p_header_rec.number06,FND_API.G_MISS_NUM,number06,p_header_rec.number06)
  ,   number07 = decode(p_header_rec.number07,FND_API.G_MISS_NUM,number07,p_header_rec.number07)
  ,   number08 = decode(p_header_rec.number08,FND_API.G_MISS_NUM,number08,p_header_rec.number08)
  ,   number09 = decode(p_header_rec.number09,FND_API.G_MISS_NUM,number09,p_header_rec.number09)
  ,   number10 = decode(p_header_rec.number10,FND_API.G_MISS_NUM,number10,p_header_rec.number10)
  ,   number11 = decode(p_header_rec.number11,FND_API.G_MISS_NUM,number11,p_header_rec.number11)
  ,   number12 = decode(p_header_rec.number12,FND_API.G_MISS_NUM,number12,p_header_rec.number12)
  ,   number13 = decode(p_header_rec.number13,FND_API.G_MISS_NUM,number13,p_header_rec.number13)
  ,   number14 = decode(p_header_rec.number14,FND_API.G_MISS_NUM,number14,p_header_rec.number14)
  ,   number15 = decode(p_header_rec.number15,FND_API.G_MISS_NUM,number15,p_header_rec.number15)
  ,   number16 = decode(p_header_rec.number16,FND_API.G_MISS_NUM,number16,p_header_rec.number16)
  ,   number17 = decode(p_header_rec.number17,FND_API.G_MISS_NUM,number17,p_header_rec.number17)
  ,   number18 = decode(p_header_rec.number18,FND_API.G_MISS_NUM,number18,p_header_rec.number18)
  ,   number19 = decode(p_header_rec.number19,FND_API.G_MISS_NUM,number19,p_header_rec.number19)
  ,   number20 = decode(p_header_rec.number20,FND_API.G_MISS_NUM,number20,p_header_rec.number20)
  ,   number21 = decode(p_header_rec.number21,FND_API.G_MISS_NUM,number21,p_header_rec.number21)
  ,   number22 = decode(p_header_rec.number22,FND_API.G_MISS_NUM,number22,p_header_rec.number22)
  ,   number23 = decode(p_header_rec.number23,FND_API.G_MISS_NUM,number23,p_header_rec.number23)
  ,   number24 = decode(p_header_rec.number24,FND_API.G_MISS_NUM,number24,p_header_rec.number24)
  ,   number25 = decode(p_header_rec.number25,FND_API.G_MISS_NUM,number25,p_header_rec.number25)
  ,   number26 = decode(p_header_rec.number26,FND_API.G_MISS_NUM,number26,p_header_rec.number26)
  ,   number27 = decode(p_header_rec.number27,FND_API.G_MISS_NUM,number27,p_header_rec.number27)
  ,   number28 = decode(p_header_rec.number28,FND_API.G_MISS_NUM,number28,p_header_rec.number28)
  ,   number29 = decode(p_header_rec.number29,FND_API.G_MISS_NUM,number29,p_header_rec.number29)
  ,   number30 = decode(p_header_rec.number30,FND_API.G_MISS_NUM,number30,p_header_rec.number30)
  ,   number31 = decode(p_header_rec.number31,FND_API.G_MISS_NUM,number31,p_header_rec.number31)
  ,   number32 = decode(p_header_rec.number32,FND_API.G_MISS_NUM,number32,p_header_rec.number32)
  ,   number33 = decode(p_header_rec.number33,FND_API.G_MISS_NUM,number33,p_header_rec.number33)
  ,   number34 = decode(p_header_rec.number34,FND_API.G_MISS_NUM,number34,p_header_rec.number34)
  ,   number35 = decode(p_header_rec.number35,FND_API.G_MISS_NUM,number35,p_header_rec.number35)
  ,   number36 = decode(p_header_rec.number36,FND_API.G_MISS_NUM,number36,p_header_rec.number36)
  ,   number37 = decode(p_header_rec.number37,FND_API.G_MISS_NUM,number37,p_header_rec.number37)
  ,   number38 = decode(p_header_rec.number38,FND_API.G_MISS_NUM,number38,p_header_rec.number38)
  ,   number39 = decode(p_header_rec.number39,FND_API.G_MISS_NUM,number39,p_header_rec.number39)
  ,   number40 = decode(p_header_rec.number40,FND_API.G_MISS_NUM,number40,p_header_rec.number40)
  ,   number41 = decode(p_header_rec.number41,FND_API.G_MISS_NUM,number41,p_header_rec.number41)
  ,   number42 = decode(p_header_rec.number42,FND_API.G_MISS_NUM,number42,p_header_rec.number42)
  ,   number43 = decode(p_header_rec.number43,FND_API.G_MISS_NUM,number43,p_header_rec.number43)
  ,   number44 = decode(p_header_rec.number44,FND_API.G_MISS_NUM,number44,p_header_rec.number44)
  ,   number45 = decode(p_header_rec.number45,FND_API.G_MISS_NUM,number45,p_header_rec.number45)
  ,   number46 = decode(p_header_rec.number46,FND_API.G_MISS_NUM,number46,p_header_rec.number46)
  ,   number47 = decode(p_header_rec.number47,FND_API.G_MISS_NUM,number47,p_header_rec.number47)
  ,   number48 = decode(p_header_rec.number48,FND_API.G_MISS_NUM,number48,p_header_rec.number48)
  ,   number49 = decode(p_header_rec.number49,FND_API.G_MISS_NUM,number49,p_header_rec.number49)
  ,   number50 = decode(p_header_rec.number50,FND_API.G_MISS_NUM,number50,p_header_rec.number50)
  ,   date01 = decode(p_header_rec.date01,FND_API.G_MISS_DATE,date01,p_header_rec.date01)
  ,   date02 = decode(p_header_rec.date02,FND_API.G_MISS_DATE,date02,p_header_rec.date02)
  ,   date03 = decode(p_header_rec.date03,FND_API.G_MISS_DATE,date03,p_header_rec.date03)
  ,   date04 = decode(p_header_rec.date04,FND_API.G_MISS_DATE,date04,p_header_rec.date04)
  ,   date05 = decode(p_header_rec.date05,FND_API.G_MISS_DATE,date05,p_header_rec.date05)
  ,   date06 = decode(p_header_rec.date06,FND_API.G_MISS_DATE,date06,p_header_rec.date06)
  ,   date07 = decode(p_header_rec.date07,FND_API.G_MISS_DATE,date07,p_header_rec.date07)
  ,   date08 = decode(p_header_rec.date08,FND_API.G_MISS_DATE,date08,p_header_rec.date08)
  ,   date09 = decode(p_header_rec.date09,FND_API.G_MISS_DATE,date09,p_header_rec.date09)
  ,   date10 = decode(p_header_rec.date10,FND_API.G_MISS_DATE,date10,p_header_rec.date10)
  ,   date11 = decode(p_header_rec.date11,FND_API.G_MISS_DATE,date11,p_header_rec.date11)
  ,   date12 = decode(p_header_rec.date12,FND_API.G_MISS_DATE,date12,p_header_rec.date12)
  ,   date13 = decode(p_header_rec.date13,FND_API.G_MISS_DATE,date13,p_header_rec.date13)
  ,   date14 = decode(p_header_rec.date14,FND_API.G_MISS_DATE,date14,p_header_rec.date14)
  ,   date15 = decode(p_header_rec.date15,FND_API.G_MISS_DATE,date15,p_header_rec.date15)
  ,   date16 = decode(p_header_rec.date16,FND_API.G_MISS_DATE,date16,p_header_rec.date16)
  ,   date17 = decode(p_header_rec.date17,FND_API.G_MISS_DATE,date17,p_header_rec.date17)
  ,   date18 = decode(p_header_rec.date18,FND_API.G_MISS_DATE,date18,p_header_rec.date18)
  ,   date19 = decode(p_header_rec.date19,FND_API.G_MISS_DATE,date19,p_header_rec.date19)
  ,   date20 = decode(p_header_rec.date20,FND_API.G_MISS_DATE,date20,p_header_rec.date20)
  ,   date21 = decode(p_header_rec.date21,FND_API.G_MISS_DATE,date21,p_header_rec.date21)
  ,   date22 = decode(p_header_rec.date22,FND_API.G_MISS_DATE,date22,p_header_rec.date22)
  ,   date23 = decode(p_header_rec.date23,FND_API.G_MISS_DATE,date23,p_header_rec.date23)
  ,   date24 = decode(p_header_rec.date24,FND_API.G_MISS_DATE,date24,p_header_rec.date24)
  ,   date25 = decode(p_header_rec.date25,FND_API.G_MISS_DATE,date25,p_header_rec.date25)
  ,   date26 = decode(p_header_rec.date26,FND_API.G_MISS_DATE,date26,p_header_rec.date26)
  ,   date27 = decode(p_header_rec.date27,FND_API.G_MISS_DATE,date27,p_header_rec.date27)
  ,   date28 = decode(p_header_rec.date28,FND_API.G_MISS_DATE,date28,p_header_rec.date28)
  ,   date29 = decode(p_header_rec.date29,FND_API.G_MISS_DATE,date29,p_header_rec.date29)
  ,   date30 = decode(p_header_rec.date30,FND_API.G_MISS_DATE,date30,p_header_rec.date30)
  ,   date31 = decode(p_header_rec.date31,FND_API.G_MISS_DATE,date31,p_header_rec.date31)
  ,   date32 = decode(p_header_rec.date32,FND_API.G_MISS_DATE,date32,p_header_rec.date32)
  ,   date33 = decode(p_header_rec.date33,FND_API.G_MISS_DATE,date33,p_header_rec.date33)
  ,   date34 = decode(p_header_rec.date34,FND_API.G_MISS_DATE,date34,p_header_rec.date34)
  ,   date35 = decode(p_header_rec.date35,FND_API.G_MISS_DATE,date35,p_header_rec.date35)
  ,   date36 = decode(p_header_rec.date36,FND_API.G_MISS_DATE,date36,p_header_rec.date36)
  ,   date37 = decode(p_header_rec.date37,FND_API.G_MISS_DATE,date37,p_header_rec.date37)
  ,   date38 = decode(p_header_rec.date38,FND_API.G_MISS_DATE,date38,p_header_rec.date38)
  ,   date39 = decode(p_header_rec.date39,FND_API.G_MISS_DATE,date39,p_header_rec.date39)
  ,   date40 = decode(p_header_rec.date40,FND_API.G_MISS_DATE,date40,p_header_rec.date40)
  ,   date41 = decode(p_header_rec.date41,FND_API.G_MISS_DATE,date41,p_header_rec.date41)
  ,   date42 = decode(p_header_rec.date42,FND_API.G_MISS_DATE,date42,p_header_rec.date42)
  ,   date43 = decode(p_header_rec.date43,FND_API.G_MISS_DATE,date43,p_header_rec.date43)
  ,   date44 = decode(p_header_rec.date44,FND_API.G_MISS_DATE,date44,p_header_rec.date44)
  ,   date45 = decode(p_header_rec.date45,FND_API.G_MISS_DATE,date45,p_header_rec.date45)
  ,   date46 = decode(p_header_rec.date46,FND_API.G_MISS_DATE,date46,p_header_rec.date46)
  ,   date47 = decode(p_header_rec.date47,FND_API.G_MISS_DATE,date47,p_header_rec.date47)
  ,   date48 = decode(p_header_rec.date48,FND_API.G_MISS_DATE,date48,p_header_rec.date48)
  ,   date49 = decode(p_header_rec.date49,FND_API.G_MISS_DATE,date49,p_header_rec.date49)
  ,   date50 = decode(p_header_rec.date50,FND_API.G_MISS_DATE,date50,p_header_rec.date50)
  WHERE form_header_id = p_header_rec.form_header_id;

  i := p_line_tbl.FIRST;
  LOOP

    UPDATE oke_k_form_lines
    SET last_update_date  = sysdate
    ,   last_updated_by   = l_user_id
    ,   last_update_login = l_login_id
    ,   text01 = decode(p_line_tbl(i).text01,FND_API.G_MISS_CHAR,text01,p_line_tbl(i).text01)
    ,   text02 = decode(p_line_tbl(i).text02,FND_API.G_MISS_CHAR,text02,p_line_tbl(i).text02)
    ,   text03 = decode(p_line_tbl(i).text03,FND_API.G_MISS_CHAR,text03,p_line_tbl(i).text03)
    ,   text04 = decode(p_line_tbl(i).text04,FND_API.G_MISS_CHAR,text04,p_line_tbl(i).text04)
    ,   text05 = decode(p_line_tbl(i).text05,FND_API.G_MISS_CHAR,text05,p_line_tbl(i).text05)
    ,   text06 = decode(p_line_tbl(i).text06,FND_API.G_MISS_CHAR,text06,p_line_tbl(i).text06)
    ,   text07 = decode(p_line_tbl(i).text07,FND_API.G_MISS_CHAR,text07,p_line_tbl(i).text07)
    ,   text08 = decode(p_line_tbl(i).text08,FND_API.G_MISS_CHAR,text08,p_line_tbl(i).text08)
    ,   text09 = decode(p_line_tbl(i).text09,FND_API.G_MISS_CHAR,text09,p_line_tbl(i).text09)
    ,   text10 = decode(p_line_tbl(i).text10,FND_API.G_MISS_CHAR,text10,p_line_tbl(i).text10)
    ,   text11 = decode(p_line_tbl(i).text11,FND_API.G_MISS_CHAR,text11,p_line_tbl(i).text11)
    ,   text12 = decode(p_line_tbl(i).text12,FND_API.G_MISS_CHAR,text12,p_line_tbl(i).text12)
    ,   text13 = decode(p_line_tbl(i).text13,FND_API.G_MISS_CHAR,text13,p_line_tbl(i).text13)
    ,   text14 = decode(p_line_tbl(i).text14,FND_API.G_MISS_CHAR,text14,p_line_tbl(i).text14)
    ,   text15 = decode(p_line_tbl(i).text15,FND_API.G_MISS_CHAR,text15,p_line_tbl(i).text15)
    ,   text16 = decode(p_line_tbl(i).text16,FND_API.G_MISS_CHAR,text16,p_line_tbl(i).text16)
    ,   text17 = decode(p_line_tbl(i).text17,FND_API.G_MISS_CHAR,text17,p_line_tbl(i).text17)
    ,   text18 = decode(p_line_tbl(i).text18,FND_API.G_MISS_CHAR,text18,p_line_tbl(i).text18)
    ,   text19 = decode(p_line_tbl(i).text19,FND_API.G_MISS_CHAR,text19,p_line_tbl(i).text19)
    ,   text20 = decode(p_line_tbl(i).text20,FND_API.G_MISS_CHAR,text20,p_line_tbl(i).text20)
    ,   text21 = decode(p_line_tbl(i).text21,FND_API.G_MISS_CHAR,text21,p_line_tbl(i).text21)
    ,   text22 = decode(p_line_tbl(i).text22,FND_API.G_MISS_CHAR,text22,p_line_tbl(i).text22)
    ,   text23 = decode(p_line_tbl(i).text23,FND_API.G_MISS_CHAR,text23,p_line_tbl(i).text23)
    ,   text24 = decode(p_line_tbl(i).text24,FND_API.G_MISS_CHAR,text24,p_line_tbl(i).text24)
    ,   text25 = decode(p_line_tbl(i).text25,FND_API.G_MISS_CHAR,text25,p_line_tbl(i).text25)
    ,   text26 = decode(p_line_tbl(i).text26,FND_API.G_MISS_CHAR,text26,p_line_tbl(i).text26)
    ,   text27 = decode(p_line_tbl(i).text27,FND_API.G_MISS_CHAR,text27,p_line_tbl(i).text27)
    ,   text28 = decode(p_line_tbl(i).text28,FND_API.G_MISS_CHAR,text28,p_line_tbl(i).text28)
    ,   text29 = decode(p_line_tbl(i).text29,FND_API.G_MISS_CHAR,text29,p_line_tbl(i).text29)
    ,   text30 = decode(p_line_tbl(i).text30,FND_API.G_MISS_CHAR,text30,p_line_tbl(i).text30)
    ,   text31 = decode(p_line_tbl(i).text31,FND_API.G_MISS_CHAR,text31,p_line_tbl(i).text31)
    ,   text32 = decode(p_line_tbl(i).text32,FND_API.G_MISS_CHAR,text32,p_line_tbl(i).text32)
    ,   text33 = decode(p_line_tbl(i).text33,FND_API.G_MISS_CHAR,text33,p_line_tbl(i).text33)
    ,   text34 = decode(p_line_tbl(i).text34,FND_API.G_MISS_CHAR,text34,p_line_tbl(i).text34)
    ,   text35 = decode(p_line_tbl(i).text35,FND_API.G_MISS_CHAR,text35,p_line_tbl(i).text35)
    ,   text36 = decode(p_line_tbl(i).text36,FND_API.G_MISS_CHAR,text36,p_line_tbl(i).text36)
    ,   text37 = decode(p_line_tbl(i).text37,FND_API.G_MISS_CHAR,text37,p_line_tbl(i).text37)
    ,   text38 = decode(p_line_tbl(i).text38,FND_API.G_MISS_CHAR,text38,p_line_tbl(i).text38)
    ,   text39 = decode(p_line_tbl(i).text39,FND_API.G_MISS_CHAR,text39,p_line_tbl(i).text39)
    ,   text40 = decode(p_line_tbl(i).text40,FND_API.G_MISS_CHAR,text40,p_line_tbl(i).text40)
    ,   text41 = decode(p_line_tbl(i).text41,FND_API.G_MISS_CHAR,text41,p_line_tbl(i).text41)
    ,   text42 = decode(p_line_tbl(i).text42,FND_API.G_MISS_CHAR,text42,p_line_tbl(i).text42)
    ,   text43 = decode(p_line_tbl(i).text43,FND_API.G_MISS_CHAR,text43,p_line_tbl(i).text43)
    ,   text44 = decode(p_line_tbl(i).text44,FND_API.G_MISS_CHAR,text44,p_line_tbl(i).text44)
    ,   text45 = decode(p_line_tbl(i).text45,FND_API.G_MISS_CHAR,text45,p_line_tbl(i).text45)
    ,   text46 = decode(p_line_tbl(i).text46,FND_API.G_MISS_CHAR,text46,p_line_tbl(i).text46)
    ,   text47 = decode(p_line_tbl(i).text47,FND_API.G_MISS_CHAR,text47,p_line_tbl(i).text47)
    ,   text48 = decode(p_line_tbl(i).text48,FND_API.G_MISS_CHAR,text48,p_line_tbl(i).text48)
    ,   text49 = decode(p_line_tbl(i).text49,FND_API.G_MISS_CHAR,text49,p_line_tbl(i).text49)
    ,   text50 = decode(p_line_tbl(i).text50,FND_API.G_MISS_CHAR,text50,p_line_tbl(i).text50)
    ,   number01 = decode(p_line_tbl(i).number01,FND_API.G_MISS_NUM,number01,p_line_tbl(i).number01)
    ,   number02 = decode(p_line_tbl(i).number02,FND_API.G_MISS_NUM,number02,p_line_tbl(i).number02)
    ,   number03 = decode(p_line_tbl(i).number03,FND_API.G_MISS_NUM,number03,p_line_tbl(i).number03)
    ,   number04 = decode(p_line_tbl(i).number04,FND_API.G_MISS_NUM,number04,p_line_tbl(i).number04)
    ,   number05 = decode(p_line_tbl(i).number05,FND_API.G_MISS_NUM,number05,p_line_tbl(i).number05)
    ,   number06 = decode(p_line_tbl(i).number06,FND_API.G_MISS_NUM,number06,p_line_tbl(i).number06)
    ,   number07 = decode(p_line_tbl(i).number07,FND_API.G_MISS_NUM,number07,p_line_tbl(i).number07)
    ,   number08 = decode(p_line_tbl(i).number08,FND_API.G_MISS_NUM,number08,p_line_tbl(i).number08)
    ,   number09 = decode(p_line_tbl(i).number09,FND_API.G_MISS_NUM,number09,p_line_tbl(i).number09)
    ,   number10 = decode(p_line_tbl(i).number10,FND_API.G_MISS_NUM,number10,p_line_tbl(i).number10)
    ,   number11 = decode(p_line_tbl(i).number11,FND_API.G_MISS_NUM,number11,p_line_tbl(i).number11)
    ,   number12 = decode(p_line_tbl(i).number12,FND_API.G_MISS_NUM,number12,p_line_tbl(i).number12)
    ,   number13 = decode(p_line_tbl(i).number13,FND_API.G_MISS_NUM,number13,p_line_tbl(i).number13)
    ,   number14 = decode(p_line_tbl(i).number14,FND_API.G_MISS_NUM,number14,p_line_tbl(i).number14)
    ,   number15 = decode(p_line_tbl(i).number15,FND_API.G_MISS_NUM,number15,p_line_tbl(i).number15)
    ,   number16 = decode(p_line_tbl(i).number16,FND_API.G_MISS_NUM,number16,p_line_tbl(i).number16)
    ,   number17 = decode(p_line_tbl(i).number17,FND_API.G_MISS_NUM,number17,p_line_tbl(i).number17)
    ,   number18 = decode(p_line_tbl(i).number18,FND_API.G_MISS_NUM,number18,p_line_tbl(i).number18)
    ,   number19 = decode(p_line_tbl(i).number19,FND_API.G_MISS_NUM,number19,p_line_tbl(i).number19)
    ,   number20 = decode(p_line_tbl(i).number20,FND_API.G_MISS_NUM,number20,p_line_tbl(i).number20)
    ,   number21 = decode(p_line_tbl(i).number21,FND_API.G_MISS_NUM,number21,p_line_tbl(i).number21)
    ,   number22 = decode(p_line_tbl(i).number22,FND_API.G_MISS_NUM,number22,p_line_tbl(i).number22)
    ,   number23 = decode(p_line_tbl(i).number23,FND_API.G_MISS_NUM,number23,p_line_tbl(i).number23)
    ,   number24 = decode(p_line_tbl(i).number24,FND_API.G_MISS_NUM,number24,p_line_tbl(i).number24)
    ,   number25 = decode(p_line_tbl(i).number25,FND_API.G_MISS_NUM,number25,p_line_tbl(i).number25)
    ,   number26 = decode(p_line_tbl(i).number26,FND_API.G_MISS_NUM,number26,p_line_tbl(i).number26)
    ,   number27 = decode(p_line_tbl(i).number27,FND_API.G_MISS_NUM,number27,p_line_tbl(i).number27)
    ,   number28 = decode(p_line_tbl(i).number28,FND_API.G_MISS_NUM,number28,p_line_tbl(i).number28)
    ,   number29 = decode(p_line_tbl(i).number29,FND_API.G_MISS_NUM,number29,p_line_tbl(i).number29)
    ,   number30 = decode(p_line_tbl(i).number30,FND_API.G_MISS_NUM,number30,p_line_tbl(i).number30)
    ,   number31 = decode(p_line_tbl(i).number31,FND_API.G_MISS_NUM,number31,p_line_tbl(i).number31)
    ,   number32 = decode(p_line_tbl(i).number32,FND_API.G_MISS_NUM,number32,p_line_tbl(i).number32)
    ,   number33 = decode(p_line_tbl(i).number33,FND_API.G_MISS_NUM,number33,p_line_tbl(i).number33)
    ,   number34 = decode(p_line_tbl(i).number34,FND_API.G_MISS_NUM,number34,p_line_tbl(i).number34)
    ,   number35 = decode(p_line_tbl(i).number35,FND_API.G_MISS_NUM,number35,p_line_tbl(i).number35)
    ,   number36 = decode(p_line_tbl(i).number36,FND_API.G_MISS_NUM,number36,p_line_tbl(i).number36)
    ,   number37 = decode(p_line_tbl(i).number37,FND_API.G_MISS_NUM,number37,p_line_tbl(i).number37)
    ,   number38 = decode(p_line_tbl(i).number38,FND_API.G_MISS_NUM,number38,p_line_tbl(i).number38)
    ,   number39 = decode(p_line_tbl(i).number39,FND_API.G_MISS_NUM,number39,p_line_tbl(i).number39)
    ,   number40 = decode(p_line_tbl(i).number40,FND_API.G_MISS_NUM,number40,p_line_tbl(i).number40)
    ,   number41 = decode(p_line_tbl(i).number41,FND_API.G_MISS_NUM,number41,p_line_tbl(i).number41)
    ,   number42 = decode(p_line_tbl(i).number42,FND_API.G_MISS_NUM,number42,p_line_tbl(i).number42)
    ,   number43 = decode(p_line_tbl(i).number43,FND_API.G_MISS_NUM,number43,p_line_tbl(i).number43)
    ,   number44 = decode(p_line_tbl(i).number44,FND_API.G_MISS_NUM,number44,p_line_tbl(i).number44)
    ,   number45 = decode(p_line_tbl(i).number45,FND_API.G_MISS_NUM,number45,p_line_tbl(i).number45)
    ,   number46 = decode(p_line_tbl(i).number46,FND_API.G_MISS_NUM,number46,p_line_tbl(i).number46)
    ,   number47 = decode(p_line_tbl(i).number47,FND_API.G_MISS_NUM,number47,p_line_tbl(i).number47)
    ,   number48 = decode(p_line_tbl(i).number48,FND_API.G_MISS_NUM,number48,p_line_tbl(i).number48)
    ,   number49 = decode(p_line_tbl(i).number49,FND_API.G_MISS_NUM,number49,p_line_tbl(i).number49)
    ,   number50 = decode(p_line_tbl(i).number50,FND_API.G_MISS_NUM,number50,p_line_tbl(i).number50)
    ,   date01 = decode(p_line_tbl(i).date01,FND_API.G_MISS_DATE,date01,p_line_tbl(i).date01)
    ,   date02 = decode(p_line_tbl(i).date02,FND_API.G_MISS_DATE,date02,p_line_tbl(i).date02)
    ,   date03 = decode(p_line_tbl(i).date03,FND_API.G_MISS_DATE,date03,p_line_tbl(i).date03)
    ,   date04 = decode(p_line_tbl(i).date04,FND_API.G_MISS_DATE,date04,p_line_tbl(i).date04)
    ,   date05 = decode(p_line_tbl(i).date05,FND_API.G_MISS_DATE,date05,p_line_tbl(i).date05)
    ,   date06 = decode(p_line_tbl(i).date06,FND_API.G_MISS_DATE,date06,p_line_tbl(i).date06)
    ,   date07 = decode(p_line_tbl(i).date07,FND_API.G_MISS_DATE,date07,p_line_tbl(i).date07)
    ,   date08 = decode(p_line_tbl(i).date08,FND_API.G_MISS_DATE,date08,p_line_tbl(i).date08)
    ,   date09 = decode(p_line_tbl(i).date09,FND_API.G_MISS_DATE,date09,p_line_tbl(i).date09)
    ,   date10 = decode(p_line_tbl(i).date10,FND_API.G_MISS_DATE,date10,p_line_tbl(i).date10)
    ,   date11 = decode(p_line_tbl(i).date11,FND_API.G_MISS_DATE,date11,p_line_tbl(i).date11)
    ,   date12 = decode(p_line_tbl(i).date12,FND_API.G_MISS_DATE,date12,p_line_tbl(i).date12)
    ,   date13 = decode(p_line_tbl(i).date13,FND_API.G_MISS_DATE,date13,p_line_tbl(i).date13)
    ,   date14 = decode(p_line_tbl(i).date14,FND_API.G_MISS_DATE,date14,p_line_tbl(i).date14)
    ,   date15 = decode(p_line_tbl(i).date15,FND_API.G_MISS_DATE,date15,p_line_tbl(i).date15)
    ,   date16 = decode(p_line_tbl(i).date16,FND_API.G_MISS_DATE,date16,p_line_tbl(i).date16)
    ,   date17 = decode(p_line_tbl(i).date17,FND_API.G_MISS_DATE,date17,p_line_tbl(i).date17)
    ,   date18 = decode(p_line_tbl(i).date18,FND_API.G_MISS_DATE,date18,p_line_tbl(i).date18)
    ,   date19 = decode(p_line_tbl(i).date19,FND_API.G_MISS_DATE,date19,p_line_tbl(i).date19)
    ,   date20 = decode(p_line_tbl(i).date20,FND_API.G_MISS_DATE,date20,p_line_tbl(i).date20)
    ,   date21 = decode(p_line_tbl(i).date21,FND_API.G_MISS_DATE,date21,p_line_tbl(i).date21)
    ,   date22 = decode(p_line_tbl(i).date22,FND_API.G_MISS_DATE,date22,p_line_tbl(i).date22)
    ,   date23 = decode(p_line_tbl(i).date23,FND_API.G_MISS_DATE,date23,p_line_tbl(i).date23)
    ,   date24 = decode(p_line_tbl(i).date24,FND_API.G_MISS_DATE,date24,p_line_tbl(i).date24)
    ,   date25 = decode(p_line_tbl(i).date25,FND_API.G_MISS_DATE,date25,p_line_tbl(i).date25)
    ,   date26 = decode(p_line_tbl(i).date26,FND_API.G_MISS_DATE,date26,p_line_tbl(i).date26)
    ,   date27 = decode(p_line_tbl(i).date27,FND_API.G_MISS_DATE,date27,p_line_tbl(i).date27)
    ,   date28 = decode(p_line_tbl(i).date28,FND_API.G_MISS_DATE,date28,p_line_tbl(i).date28)
    ,   date29 = decode(p_line_tbl(i).date29,FND_API.G_MISS_DATE,date29,p_line_tbl(i).date29)
    ,   date30 = decode(p_line_tbl(i).date30,FND_API.G_MISS_DATE,date30,p_line_tbl(i).date30)
    ,   date31 = decode(p_line_tbl(i).date31,FND_API.G_MISS_DATE,date31,p_line_tbl(i).date31)
    ,   date32 = decode(p_line_tbl(i).date32,FND_API.G_MISS_DATE,date32,p_line_tbl(i).date32)
    ,   date33 = decode(p_line_tbl(i).date33,FND_API.G_MISS_DATE,date33,p_line_tbl(i).date33)
    ,   date34 = decode(p_line_tbl(i).date34,FND_API.G_MISS_DATE,date34,p_line_tbl(i).date34)
    ,   date35 = decode(p_line_tbl(i).date35,FND_API.G_MISS_DATE,date35,p_line_tbl(i).date35)
    ,   date36 = decode(p_line_tbl(i).date36,FND_API.G_MISS_DATE,date36,p_line_tbl(i).date36)
    ,   date37 = decode(p_line_tbl(i).date37,FND_API.G_MISS_DATE,date37,p_line_tbl(i).date37)
    ,   date38 = decode(p_line_tbl(i).date38,FND_API.G_MISS_DATE,date38,p_line_tbl(i).date38)
    ,   date39 = decode(p_line_tbl(i).date39,FND_API.G_MISS_DATE,date39,p_line_tbl(i).date39)
    ,   date40 = decode(p_line_tbl(i).date40,FND_API.G_MISS_DATE,date40,p_line_tbl(i).date40)
    ,   date41 = decode(p_line_tbl(i).date41,FND_API.G_MISS_DATE,date41,p_line_tbl(i).date41)
    ,   date42 = decode(p_line_tbl(i).date42,FND_API.G_MISS_DATE,date42,p_line_tbl(i).date42)
    ,   date43 = decode(p_line_tbl(i).date43,FND_API.G_MISS_DATE,date43,p_line_tbl(i).date43)
    ,   date44 = decode(p_line_tbl(i).date44,FND_API.G_MISS_DATE,date44,p_line_tbl(i).date44)
    ,   date45 = decode(p_line_tbl(i).date45,FND_API.G_MISS_DATE,date45,p_line_tbl(i).date45)
    ,   date46 = decode(p_line_tbl(i).date46,FND_API.G_MISS_DATE,date46,p_line_tbl(i).date46)
    ,   date47 = decode(p_line_tbl(i).date47,FND_API.G_MISS_DATE,date47,p_line_tbl(i).date47)
    ,   date48 = decode(p_line_tbl(i).date48,FND_API.G_MISS_DATE,date48,p_line_tbl(i).date48)
    ,   date49 = decode(p_line_tbl(i).date49,FND_API.G_MISS_DATE,date49,p_line_tbl(i).date49)
    ,   date50 = decode(p_line_tbl(i).date50,FND_API.G_MISS_DATE,date50,p_line_tbl(i).date50)
    WHERE form_header_id = p_header_rec.form_header_id
    AND   form_line_number = p_line_tbl(i).form_line_number;

    EXIT WHEN ( i = p_line_tbl.LAST );
    i := p_line_tbl.NEXT(i);
  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
               ( p_pkg_name        => G_PKG_NAME
               , p_procedure_name  => 'UPDATE_FORM' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Form;

-- --------------------------------------------------------------------

--
-- API Body
--

--
--  API Name      : Create_Print_Form
--  Type          : Public
--  Pre-reqs      : None
--  Function      : Creates a new instances of a print form
--
--  Parameters    :
--  IN            : p_api_version            NUMBER
--                  p_commit                 VARCHAR2
--                  p_init_msg_list          VARCHAR2
--                  p_header_rec             PFH_Rec_Type
--                  p_line_tbl               PFL_Tbl_Type
--  OUT           : x_msg_count              NUMBER
--                  x_msg_data               VARCHAR2
--                  x_return_status          VARCHAR2
--
--  Version       : Current Version - 1.0
--                  Initial Version - 1.0
--
PROCEDURE create_print_form
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2
,  p_init_msg_list          IN    VARCHAR2
,  x_msg_count              OUT NOCOPY   NUMBER
,  x_msg_data               OUT NOCOPY   VARCHAR2
,  x_return_status          OUT NOCOPY   VARCHAR2
,  p_header_rec             IN    PFH_Rec_Type
,  p_line_tbl               IN    PFL_Tbl_Type
,  x_form_header_id         OUT NOCOPY   NUMBER
) IS

l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_PRINT_FORM';
l_api_version   CONSTANT NUMBER       := 1.0;

l_header_rec    PFH_Rec_Type;
l_line_tbl      PFL_Tbl_Type;
l_return_status VARCHAR2(1);

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT create_print_form_pub;

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Set API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Step 1 : Value to ID conversions
  --
  Convert_Value_To_ID( p_header_rec
                     , l_header_rec
                     , p_line_tbl
                     , l_line_tbl
                     , l_api_name
                     , l_return_status );

  --
  -- Step 1.1 : If anything happens, abort API
  --
  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Step 2 : Data Validation
  --
  Validate_Data( l_header_rec
               , l_api_name
               , l_return_status );

  --
  -- Step 2.1 : If anything happens, abort API
  --
  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Step 3 : DML
  --
  create_form( l_header_rec
             , p_line_tbl
             , x_form_header_id
             , l_return_status );

  --
  -- Step 3.1 : If anything happens, abort API
  --
  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Stanard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_print_form_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_print_form_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO create_print_form_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => l_api_name );

    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

END create_print_form;


--
--  API Name      : Update_Print_Form
--  Type          : Public
--  Pre-reqs      : None
--  Function      : Updates an existing instance of a print form
--
--  Parameters    :
--  IN            : p_api_version            NUMBER
--                  p_commit                 VARCHAR2
--                  p_init_msg_list          VARCHAR2
--                  p_header_rec             PFH_Rec_Type
--                  p_line_tbl               PFL_Tbl_Type
--                  x_msg_count              NUMBER
--                  x_msg_data               VARCHAR2
--                  x_return_status          VARCHAR2
--
--  Version       : Current Version - 1.0
--                  Initial Version - 1.0
--
PROCEDURE update_print_form
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2
,  p_init_msg_list          IN    VARCHAR2
,  x_msg_count              OUT NOCOPY   NUMBER
,  x_msg_data               OUT NOCOPY   VARCHAR2
,  x_return_status          OUT NOCOPY   VARCHAR2
,  p_header_rec             IN    PFH_Rec_Type
,  p_line_tbl               IN    PFL_Tbl_Type
) IS

l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_PRINT_FORM';
l_api_version   CONSTANT NUMBER       := 1.0;

l_header_rec    PFH_Rec_Type;
l_line_tbl      PFL_Tbl_Type;
l_return_status VARCHAR2(1);

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT update_print_form_pub;

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Set API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Step 1 : Value to ID conversions
  --
  Convert_Value_To_ID( p_header_rec
                     , l_header_rec
                     , p_line_tbl
                     , l_line_tbl
                     , l_api_name
                     , l_return_status );

  --
  -- Step 1.1 : If anything happens, abort API
  --
  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Step 2 : Data Validation
  --
  Validate_Data( p_header_rec
               , l_api_name
               , l_return_status );

  --
  -- Step 2.1 : If anything happens, abort API
  --
  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Step 3 : DML
  --
  update_form( l_header_rec
             , p_line_tbl
             , l_return_status );

  --
  -- Step 3.1 : If anything happens, abort API
  --
  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Stanard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_print_form_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_print_form_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO update_print_form_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => l_api_name );

    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

END update_print_form;


END oke_print_form_pub;

/
