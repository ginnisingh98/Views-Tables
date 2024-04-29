--------------------------------------------------------
--  DDL for Package Body OKE_DEFAULTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DEFAULTING_PKG" AS
/* $Header: OKEVLTDB.pls 120.8.12010000.3 2009/04/27 11:36:00 aveeraba ship $ */

G_MSG_MAX_LIMIT CONSTANT NUMBER := 1950;

FUNCTION isNewMessageWithinLimit(
 	p_existing_message IN VARCHAR2
   ,p_new_token_value  IN VARCHAR2) RETURN BOOLEAN IS

    l_api_name CONSTANT VARCHAR2(30) :='isNewMessageWithinLimit';

 BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,'oke.plsql.'||g_pkg_name||'.'||l_api_name,'100: ENTERED ');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,'oke.plsql.'||g_pkg_name||'.'||l_api_name
                        ,'101: p_existing_message length = '||length(p_existing_message));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,'oke.plsql.'||g_pkg_name||'.'||l_api_name
                        ,'102: p_new_token_value = '||p_new_token_value);
  END IF;

  IF p_existing_message is null THEN
      return TRUE;
  END IF;

  IF length (p_existing_message||','||p_new_token_value) > G_MSG_MAX_LIMIT THEN
	  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,'oke.plsql.'||g_pkg_name||'.'||l_api_name
	                     ,'103: Returning FALSE ');
	  END IF;
	  return FALSE;
  ELSE
	  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,'oke.plsql.'||g_pkg_name||'.'||l_api_name
	                     ,'104: Returning TRUE ');
	  END IF;
	  return TRUE;
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,'oke.plsql.'||g_pkg_name||'.'||l_api_name
                     ,'105: Returning TRUE outside conditions');
  END IF;

  return TRUE;

 END isNewMessageWithinLimit;


  PROCEDURE Default_Deliverables (
    P_Api_Version		IN NUMBER
  , P_Init_Msg_List		IN VARCHAR2
  , P_Update_Yn			IN VARCHAR2
  , P_Header_ID			IN NUMBER
  , P_Line_ID			IN NUMBER
  , X_Return_Status		OUT NOCOPY VARCHAR2
  , X_Msg_Count			OUT NOCOPY NUMBER
  , X_Msg_Data			OUT NOCOPY VARCHAR2
  , X_Counter			OUT NOCOPY NUMBER ) IS

    l_api_version CONSTANT NUMBER := 1;
    l_del_rec		oke_deliverable_pvt.del_rec_type;
    l_del_tbl		oke_deliverable_pvt.del_tbl_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DEFAULT_DELIVERABLES';

    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_buy_or_sell 	VARCHAR2(1);
    l_direction		VARCHAR2(3);

    L_Inventory_Org_ID NUMBER;
    L_Counter NUMBER;
    L_Total_Counter NUMBER;


    CURSOR C IS
    SELECT DECODE(Buy_Or_Sell, 'B', 'IN', 'OUT') Direction
    , Inv_Organization_ID
    FROM okc_k_headers_b
    WHERE ID = P_Header_ID;


  BEGIN



    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_init_msg_list => p_init_msg_list,
			p_api_type      => g_api_type,
			x_return_status => l_return_status);


    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    --
    -- Fetch buy_or_sell to determine defaulted direction for deliverables
    --
    OPEN C;
    FETCH C INTO L_Direction, L_Inventory_Org_ID;
    CLOSE C;




    IF  NVL(P_Update_Yn, 'N') = 'N' THEN  /* New deliverable default */



      IF P_Line_ID > 0 THEN  /* Line Default */


        Create_New_L (P_Initiate_Msg_List => G_False
		, X_Return_Status		=> L_Return_Status
		, X_Msg_Count			=> X_Msg_Count
		, X_Msg_Data			=> X_Msg_Data
		, P_Header_ID			=> P_Header_ID
		, P_Line_ID			=> P_Line_ID
		, P_Direction			=> L_Direction
		, P_Inventory_Org_ID		=> L_Inventory_Org_ID
		, X_Counter			=> X_Counter);



          If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
            raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
            raise OKE_API.G_EXCEPTION_ERROR;
          End If;



        ELSE  /* Header batch defaulting */

	 Create_New ( P_Init_Msg_List 	=> G_False
		, X_Return_Status	=> L_Return_Status
		, X_Msg_Count		=> X_Msg_Count
		, X_Msg_Data		=> X_Msg_Data
		, P_Header_ID		=> P_Header_ID
		, P_Direction		=> L_Direction
		, P_Inventory_Org_ID	=> L_Inventory_Org_ID
		, X_Counter		=> X_Counter);

         If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
           raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	 Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
           raise OKE_API.G_EXCEPTION_ERROR;
         End If;

       END IF;

    ELSE   /* Mixed defaulting and re-defaulting */


      IF P_Line_ID > 0 THEN /* Line re-defaulting */

        Update_Line( P_Init_Msg_List =>  G_False
		, X_Return_Status 		=> L_Return_Status
		, X_Msg_Count			=> X_Msg_Count
		, X_Msg_Data			=> X_Msg_Data
		, P_Header_ID			=> P_Header_ID
		, P_Line_ID			=> P_Line_ID
		, P_Direction			=> L_Direction
		, P_Inventory_Org_ID		=> L_Inventory_Org_ID
		, X_Counter 			=> X_Counter);

          If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
            raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
            raise OKE_API.G_EXCEPTION_ERROR;
          End If;

        ELSE  /* Header batch re-defaulting */

          -- Two step process for both new defaults and re-defaults

          Update_Batch ( P_Init_Msg_List => G_False
		, X_Return_Status 		=> L_Return_Status
		, X_Msg_Count			=> X_Msg_Count
		, X_Msg_Data			=> X_Msg_Data
		, P_Header_ID			=> P_Header_ID
		, P_Direction			=> L_Direction
		, P_Inventory_Org_ID		=> L_Inventory_Org_ID
		, X_Counter			=> L_Counter);

          If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
            raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
            raise OKE_API.G_EXCEPTION_ERROR;
          End If;



	  L_Total_Counter := L_Counter;

	  Create_New ( P_Init_Msg_List 	=> G_False
		, X_Return_Status	=> L_Return_Status
		, X_Msg_Count		=> X_Msg_Count
		, X_Msg_Data		=> X_Msg_Data
		, P_Header_ID		=> P_Header_ID
		, P_Direction		=> L_Direction
		, P_Inventory_Org_ID	=> L_Inventory_Org_ID
		, X_Counter		=> L_Counter);

          If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
            raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
            raise OKE_API.G_EXCEPTION_ERROR;
          End If;

	  L_Total_Counter := L_Total_Counter + L_Counter;

	  X_Counter := L_Total_Counter;

       END IF;

     END IF;

     X_Return_Status := L_Return_Status;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END Default_Deliverables;

  PROCEDURE Get_Org (
    P_Header_ID 		IN NUMBER
  , P_Line_ID 			IN NUMBER
  , X_Ship_To_ID		OUT NOCOPY NUMBER
  , X_Ship_From_ID		OUT NOCOPY NUMBER )IS

    cursor party_csr1(p_id Number,p_code varchar2) is
    select object1_id1, object1_id2, jtot_object1_code
    from okc_k_party_roles_b
    where dnz_chr_id = p_header_id and cle_id = p_id
    and rle_code = p_code;

    cursor party_csr2(p_id Number,p_code varchar2) is
    select object1_id1, object1_id2, jtot_object1_code
    from okc_k_party_roles_b
    where dnz_chr_id = p_header_id and chr_id = p_id
    and rle_code = p_code;

    cursor line_party(p_code Varchar2) is
    select Max(a.level_sequence) from okc_ancestrys a
    where a.cle_id = p_line_id
    and exists(select 'x' from okc_k_party_roles_b b where dnz_chr_id = p_header_id and b.cle_id = a.cle_id_ascendant and b.rle_code = p_code and object1_id1 is not null);

    cursor header_party(p_code Varchar2) is
    select count(*) from okc_k_party_roles_b
    where dnz_chr_id = p_header_id and chr_id = p_header_id
    and rle_code = p_code
    and object1_id1 is not null;

    cursor c is
    select buy_or_sell from okc_k_headers_b
    where id = p_header_id;

    cursor top_line is
    select 'x' from okc_ancestrys
    where cle_id = p_line_id;

    Cursor Inv_C(P_Id Number) Is
    Select 'x'
    From HR_ALL_ORGANIZATION_UNITS hr, MTL_PARAMETERS mp
    Where hr.Organization_Id = P_Id
    And mp.Organization_Id = hr.Organization_Id;


    l_ship_to_id number;
    l_ship_from_id number;
    l_id NUMBER;
    l_id1  varchar2(40);
    l_id2  varchar2(200);
    l_object_code varchar2(30);
    l_level Number;
    l_value Varchar2(1);
    l_found Boolean := TRUE;

    c1info party_csr1%rowtype;
    c2info party_csr2%rowtype;

    l_row_count number;
    l_buy_or_sell varchar2(1);

  BEGIN

    select buy_or_sell into l_buy_or_sell
    from okc_k_headers_b
    where id = p_header_id;

    IF p_line_id is not null then

      SELECT COUNT(*) INTO l_row_count
      FROM OKC_K_PARTY_ROLES_B
      WHERE dnz_chr_id = p_header_id and cle_id = p_line_id
      and rle_code = 'SHIP_FROM'
      and object1_id1 is not null;

      if l_row_count = 1 then

	l_id := p_line_id;

        open party_csr1(l_id,'SHIP_FROM');
	fetch party_csr1 into c1info;
        close party_csr1;

	l_object_code := c1info.jtot_object1_code;
          if l_buy_or_sell = 'B' then
	    if l_object_code = 'OKE_VENDSITE' then
	      l_id1 := c1info.object1_id1;
            end if;
          else
	    if l_object_code = 'OKX_INVENTORY' then
	      -- only inventory_org will be defaulted down to DTS

	      Open Inv_C(c1info.object1_Id1);
       	      Fetch Inv_C Into L_Value;
	      Close Inv_C;

	      if l_value = 'x' then
	        l_id1 := c1info.object1_id1;
	      end if;

            end if;
	  end if;

        elsif l_row_count = 0 then

	  -- if the line is top line, go directly to header, else search parent line

 	  open top_line;
          fetch top_line into l_value;
	  l_found := top_line%found;
	  close top_line;

	  if l_found then

	    open line_party('SHIP_FROM');
	    fetch line_party into l_level;
	    l_found := line_party%found;
	    close line_party;

	  end if;



	  if l_level is not null then

	    -- check parent line default

	    select cle_id_ascendant into l_id
	    from okc_ancestrys
	    where cle_id = p_line_id
	    and level_sequence = l_level;

	    select count(*) into l_row_count
	    from okc_k_party_roles_b
	    where dnz_chr_id = p_header_id and cle_id = l_id
	    and rle_code = 'SHIP_FROM';

	    if l_row_count = 1 then
	      open party_csr1(l_id, 'SHIP_FROM');
	      fetch party_csr1 into c1info;
	      close party_csr1;
	      l_object_code := c1info.jtot_object1_code;


              if l_buy_or_sell = 'B' then
	        if l_object_code = 'OKE_VENDSITE' then
	          l_id1 := c1info.object1_id1;
           	 end if;
              else
	    	if l_object_code = 'OKX_INVENTORY' then
		  Open Inv_C(c1info.object1_id1);
		  Fetch Inv_C Into L_Value;
		  Close Inv_C;

	          if l_value = 'x' then
	            l_id1 := c1info.object1_id1;
	          end if;

                end if;
	      end if;
	  end if;

        else

	    -- check header party for default

	    open header_party('SHIP_FROM');
	    fetch header_party into l_level;
	    l_found := header_party%found;
	    close header_party;

	    if l_level > 0 then

	      if l_level = 1 then
		open party_csr2(p_header_id, 'SHIP_FROM');
	        fetch party_csr2 into c2info;
	        close party_csr2;
		l_object_code := c2info.jtot_object1_code;



                if l_buy_or_sell = 'B' then
	          if l_object_code = 'OKE_VENDSITE' then
	            l_id1 := c2info.object1_id1;
           	  end if;
                else
	    	  if l_object_code = 'OKX_INVENTORY' then
	            -- only inventory_org will be defaulted down to DTS
		    Open Inv_C(c2info.object1_id1);
		    Fetch Inv_C Into L_Value;
		    Close Inv_C;

	            if l_value = 'x' then
	              l_id1 := c2info.object1_id1;
	            end if;

                  end if;
		end if;
	      end if;

	  end if;
	end if;
      end if;
    end if;


    if l_id1 is not null then
       l_ship_from_id := to_number(l_id1);
       l_id1 := null;
    end if;


    select count(*) into l_row_count
    	from okc_k_party_roles_b
    	where dnz_chr_id = p_header_id and cle_id = p_line_id
    	and rle_code = 'SHIP_TO';

      if l_row_count = 1 then

	l_id := p_line_id;

        open party_csr1(l_id,'SHIP_TO');
	fetch party_csr1 into c1info;
        close party_csr1;

	l_object_code := c1info.jtot_object1_code;
          if l_buy_or_sell = 'S' then
	    if l_object_code = 'OKE_SHIPTO' then

	      l_id1 := c1info.object1_id1;
            end if;
          else
	    if l_object_code = 'OKX_INVENTORY' then

	      -- only inventory_org will be defaulted down to DTS

	      Open Inv_C(c1info.object1_id1);
	      Fetch Inv_C Into L_Value;
	      Close Inv_C;

	      if l_value = 'x' then
	        l_id1 := c1info.object1_id1;
	      end if;

            end if;
	  end if;

        elsif l_row_count = 0 then


	  open line_party('SHIP_TO');
	  fetch line_party into l_level;
	  l_found := line_party%found;
	  close line_party;

	  if l_level is not null then


	    -- check parent line default

	    select cle_id_ascendant into l_id
	    from okc_ancestrys
	    where cle_id = p_line_id
	    and level_sequence = l_level;

	    select count(*) into l_row_count
	    from okc_k_party_roles_b
	    where dnz_chr_id = p_header_id and cle_id = l_id
	    and rle_code = 'SHIP_TO';

	    if l_row_count = 1 then
	      open party_csr1(l_id, 'SHIP_TO');
	      fetch party_csr1 into c1info;
	      close party_csr1;
	      l_object_code := c1info.jtot_object1_code;

              if l_buy_or_sell = 'S' then
	        if l_object_code = 'OKE_SHIPTO' then

	          l_id1 := c1info.object1_id1;
           	 end if;
              else
	    	if l_object_code = 'OKX_INVENTORY' then
	         -- only inventory_org will be defaulted down to DTS
		  Open Inv_C(c1info.object1_id1);
		  Fetch Inv_C Into L_Value;
		  Close Inv_C;

	          if l_value = 'x' then
	            l_id1 := c1info.object1_id1;
	          end if;

                end if;
	      end if;
	  end if;

	else


	    -- check header party for default

	    open header_party('SHIP_TO');
	    fetch header_party into l_level;
	    l_found := header_party%found;
	    close header_party;

	    if l_found then

	      if l_level = 1 then
		open party_csr2(p_header_id, 'SHIP_TO');
	        fetch party_csr2 into c2info;
	        close party_csr2;

		l_object_code := c2info.jtot_object1_code;
                if l_buy_or_sell = 'S' then
	          if l_object_code = 'OKE_SHIPTO' then
	            l_id1 := c2info.object1_id1;
           	  end if;
                else
	    	  if l_object_code = 'OKX_INVENTORY' then
	            -- only inventory_org will be defaulted down to DTS
		    Open Inv_C(c2info.object1_id1);
		    Fetch Inv_C Into L_Value;
		    Close Inv_C;

	            if l_value = 'x' then
	              l_id1 := c2info.object1_id1;
	            end if;

                  end if;
		end if;

	    end if;

	  end if;

	end if;

      end if;

      if l_id1 is not null then

        l_ship_to_id := to_number(l_id1);
        l_id1 := null;
      end if;

    x_ship_to_id := l_ship_to_id;
    x_ship_from_id := l_ship_from_id;

  END Get_Org;


  PROCEDURE Verify_Defaults (
    P_Line_ID			IN NUMBER
  , X_Msg_1			OUT NOCOPY VARCHAR2
  , X_Msg_2			OUT NOCOPY VARCHAR2
  , X_Msg_3			OUT NOCOPY VARCHAR2
  , X_Return_Status		OUT NOCOPY VARCHAR2
  , P_Calling_Level	IN VARCHAR2) IS

    L_Count NUMBER;
    L_MDS VARCHAR2(1);
    L_REQ VARCHAR2(1);
    L_WSH VARCHAR2(1);
    L_BIL VARCHAR2(1);
    L_Msg VARCHAR2(2000);
    L_Msg2 VARCHAR2(2000);
    L_Msg3 VARCHAR2(2000);
    L_Return_Status VARCHAR2(1);
    L_Completed VARCHAR2(1);

    CURSOR Exist_C IS
    SELECT Count(*)
    FROM oke_k_deliverables_b
    WHERE K_Line_ID = P_Line_ID
    AND NVL(Defaulted_Flag, 'N') = 'Y';

    CURSOR Qualify_C IS
    SELECT NVL(Create_Demand, 'N')
    , NVL(Ready_To_Procure, 'N')
    , NVL(Available_For_Ship_Flag, 'N')
    , NVL(Ready_To_Bill, 'N')
    , NVL(Completed_Flag, 'N')
    FROM oke_k_deliverables_b
    WHERE K_Line_ID = P_Line_ID
    AND NVL(Defaulted_Flag, 'N') = 'Y';

  BEGIN

    --
    -- Check if deliverable(s) exist for the deliverable, create new or update existing
    -- Return status with value 'N' for new deliverable, 'U' for update deliverable, 'S' for split deliverable
    --

    OPEN Exist_C;
    FETCH Exist_C INTO L_Count;
    CLOSE Exist_C;

    IF L_Count = 0 THEN  /* No existing deliverable, create new */


      FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_CREATE_NEW');
      X_Msg_1 := FND_MESSAGE.Get;

      L_Return_Status := 'N';


    ELSIF L_Count = 1 THEN /* Defaulted previously but not splited */

      -- IF Actions initiated for the deliverable, prompt the user for the updating of other application data
      -- once the deliverable is overiden by the changes.MDS entries will be updated as well.


      OPEN Qualify_C;
      FETCH Qualify_C INTO L_Mds, L_Req, L_Wsh, L_Bil, L_Completed;
      CLOSE Qualify_C;

      IF L_Req = 'Y' THEN

  		IF P_Calling_Level = 'L' THEN
  			FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_REQ');
  		ELSE
  			FND_MESSAGE.Set_Name('OKE', 'OKE_H_DTS_DATA_REQ');
  		END IF;

        L_Msg := FND_MESSAGE.Get;
        L_Msg3 := 'REQ';

      ELSIF L_Wsh = 'Y' THEN

  		IF P_Calling_Level = 'L' THEN
			FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_WSH');
  		ELSE
			FND_MESSAGE.Set_Name('OKE', 'OKE_H_DTS_DATA_WSH');
  		END IF;

        L_Msg := FND_MESSAGE.Get;
        L_Msg3 := 'WSH';

      ELSIF L_Bil = 'Y' THEN

  		IF P_Calling_Level = 'L' THEN
        	FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_BILL');
  		ELSE
		    FND_MESSAGE.Set_Name('OKE', 'OKE_H_DTS_DATA_BILL');
  		END IF;

        L_Msg := FND_MESSAGE.Get;
        L_Msg3 := 'BIL';

      ELSIF L_Completed = 'Y' THEN

  		IF P_Calling_Level = 'L' THEN
        	FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_COMPLETED');
  		ELSE
        	FND_MESSAGE.Set_Name('OKE', 'OKE_H_DTS_DATA_COMPLETED');
  		END IF;

        L_Msg := FND_MESSAGE.Get;
        L_Msg3 := 'COM';

      ELSIF L_Mds = 'Y' THEN

        FND_MESSAGE.Set_Name('OKE', 'OKE_MISS_DATA_MDS');
        L_Msg2 := FND_MESSAGE.Get;

      END IF;

      X_Msg_1 := L_Msg;
      X_Msg_2 := L_Msg2;
      X_Msg_3 := L_Msg3;
      L_Return_Status := 'U';

    ELSE /* Splited deliverable, not qualify for auto-update */


      FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_SPLIT');
      L_Msg := FND_MESSAGE.Get;
      X_Msg_1 := L_Msg;
      X_Msg_3 := 'SPL';
      L_Return_Status := 'S';

    END IF;

    X_Return_Status := L_Return_Status;


  END Verify_Defaults;

  PROCEDURE Convert_Value(P_Header_ID 		NUMBER
		  	, P_Line_ID 		NUMBER
			, P_Direction 		VARCHAR2
			, X_Ship_To_Org_ID 	OUT NOCOPY NUMBER
			, X_Ship_To_ID 		OUT NOCOPY NUMBER
			, X_Ship_From_Org_ID 	OUT NOCOPY NUMBER
			, X_Ship_From_ID 	OUT NOCOPY NUMBER
			, X_Inv_Org_ID 		OUT NOCOPY NUMBER) IS

    L_Ship_To_ID NUMBER;
    L_Ship_From_ID NUMBER;
    L_ID NUMBER;
    L_Buy_Or_Sell VARCHAR2(1);
    L_Status VARCHAR2(1);

    CURSOR C(P_ID NUMBER) IS
    SELECT Cust_Account_ID, status
    FROM oke_cust_site_uses_v
    WHERE ID1 = P_ID;

    CURSOR Buy_Or_Sell ( P_ID NUMBER ) IS
    SELECT Buy_Or_Sell
    FROM OKC_K_HEADERS_B
    WHERE ID = P_ID;

    CURSOR Ven_C ( P_ID NUMBER ) IS
    SELECT Vendor_ID, status
    FROM oke_vendor_sites_v
    WHERE ID1 = P_ID;

    FUNCTION Get_Inv_Loc_Id( P_ID NUMBER ) RETURN NUMBER
     IS
      L_ID NUMBER;
      CURSOR Def_Loc_C IS
       SELECT location_id
        FROM hr_organization_units
        WHERE ORGANIZATION_ID = p_ID;
      CURSOR Inv_Loc_C IS
       SELECT ID1
        FROM okx_locations_v
        WHERE Organization_ID = P_ID AND status='A'
        ORDER BY ID1;
     BEGIN
      OPEN Def_Loc_C;
      FETCH Def_Loc_C INTO L_ID;
      CLOSE Def_Loc_C;
      IF l_ID IS NULL THEN
        OPEN Inv_Loc_C;
        FETCH Inv_Loc_C INTO L_ID;
        CLOSE Inv_Loc_C;
      END IF;
      RETURN L_ID;
    END Get_Inv_Loc_Id;

  BEGIN


    -- Get defaultable ship_to, ship_from from authoring, if org exists, location
    -- will be derived from org, if multiple, first one fits
    -- org can be derived from locations as well


    Get_Org(P_Header_ID, P_Line_ID, L_Ship_To_ID, L_Ship_From_ID);

    -- Party roles defined in Authoring follows the rules:
    -- Except for customer_account and customer sites, rest are org only
    -- Locations derived from the org will be the first location order by id
    -- Will be taken off if new defaulting changes in Authoring
    -- Add to accomemdate changes in Authoring, for buy contract, ship from
    -- is vendor site

    IF L_Ship_To_ID > 0 THEN

      IF P_Direction = 'OUT' THEN

        -- If direction is Out, since RMA is not supported at this moment, so
        -- Ship From will always be Inventory Org, Ship To will always be the customer

        L_ID := NULL;
        OPEN C( L_Ship_To_ID );
        FETCH C INTO L_ID, L_Status;
        CLOSE C;

        X_Ship_To_Org_ID := L_ID;
        IF L_Status <> 'A' THEN
          X_Ship_To_ID := NULL;
         ELSE
          X_Ship_To_ID := L_Ship_To_ID;
        END IF;

      ELSIF P_Direction = 'IN' THEN

      	-- If direction is In, the Ship To will always be the inventory Org

        X_Inv_Org_ID := L_Ship_To_ID;
      	X_Ship_To_Org_ID := L_Ship_To_ID;
        X_Ship_To_ID := Get_Inv_Loc_Id( L_Ship_To_ID );

      END IF;

    END IF;

    IF L_Ship_From_ID > 0 THEN

      IF P_Direction = 'OUT' THEN

       	X_Inv_Org_ID := L_Ship_From_ID;
        X_Ship_From_Org_ID := L_Ship_From_ID;
        X_Ship_From_ID := Get_Inv_Loc_Id( L_Ship_From_ID );

      ELSIF P_Direction = 'IN' THEN

        OPEN Buy_Or_Sell ( P_Header_ID );
        FETCH Buy_Or_Sell INTO L_Buy_Or_Sell;
        CLOSE Buy_Or_Sell;

      	IF L_Buy_Or_Sell = 'B' THEN

          L_ID := NULL;
          OPEN Ven_C( L_Ship_From_ID );
          FETCH Ven_C INTO L_ID, L_Status;
          CLOSE Ven_C;

          X_Ship_From_Org_ID := L_ID;
          IF L_Status <> 'A' THEN
            X_Ship_From_ID := NULL;
           ELSE
            X_Ship_From_ID := L_Ship_From_ID;
          END IF;

        END IF;

      END IF;

    END IF;


  END Convert_Value;

/* bug 3820544 new procedure to determine of org needs to be defaulted
   if the item does not exist in the org, we cannot default the org
   RETURNS 'Y' if can default, 'N' if otherwise  */

  Function Check_Org_Items(	L_Inventory_item_id NUMBER,
					L_Inventory_org NUMBER
				) RETURN VARCHAR2 IS

CURSOR check_item IS
   SELECT 'x'
   FROM MTL_SYSTEM_ITEMS
   WHERE inventory_item_id = L_inventory_item_id
   AND organization_id = L_inventory_org;

  L_check VARCHAR2(1) := '?';

  BEGIN
    OPEN check_item;
    FETCH check_item INTO l_check;
    CLOSE check_item;

    IF L_check = 'x' THEN
	RETURN 'Y';
    END IF;
	RETURN 'N';
  END Check_Org_items;



  PROCEDURE Create_New_L (P_Initiate_Msg_List IN VARCHAR2
		, X_Return_Status		OUT NOCOPY VARCHAR2
		, X_Msg_Count			OUT NOCOPY NUMBER
		, X_Msg_Data			OUT NOCOPY VARCHAR2
		, P_Header_ID			IN NUMBER
		, P_Line_ID			IN NUMBER
		, P_Direction			IN VARCHAR2
		, P_Inventory_Org_ID		IN NUMBER
		, X_Counter			OUT NOCOPY NUMBER) IS

    L_Api_Name CONSTANT VARCHAR2(30) := 'Create_New_L';
    L_Api_Version CONSTANT NUMBER := 1;
    L_Return_Status VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
    L_Del_Rec OKE_DELIVERABLE_PVT.Del_Rec_Type;
    X_Del_Rec OKE_DELIVERABLE_PVT.Del_Rec_Type;
    L_Ship_From_Org_ID NUMBER;
    L_Ship_From_Location_ID NUMBER;
    L_Ship_To_Org_ID NUMBER;
    L_Ship_To_Location_ID NUMBER;
    L_Inv_Org_ID NUMBER;

--bug 8466686 added code to find if an item is inventory item or not
    CURSOR inv_item_yn(p_id number) IS
  SELECT o.INVENTORY_ITEM_FLAG
  FROM oke_system_items_v o,oke_k_lines_v b WHERE
  b.k_line_id = p_id
  and  o.ID1 = b.inventory_item_id ;

l_inv_item_yn VARCHAR2(1);

--bug 8466686 end

    cursor new_l_c(p_id NUMBER) is
    select l.k_line_id,
	l.line_number,
	l.project_id,
	l.inventory_item_id,
        SUBSTR(l.line_description, 1, 240) line_description,
	l.delivery_date,
	l.status_code,
	l.start_date,
	l.end_date,
	k.priority_code,
	h.currency_code,
        DECODE(h.buy_or_sell, 'B', 'IN', 'OUT') Direction,
	l.unit_price,
	l.uom_code,
	l.line_quantity,
	k.country_of_origin_code,
	l.subcontracted_flag,
	l.billable_flag,
	l.drop_shipped_flag,
--	l.completed_flag,
	l.shippable_flag,
	l.cfe_flag,
	l.inspection_req_flag,
	l.interim_rpt_req_flag,
	l.customer_approval_req_flag,
    	l.as_of_date,
 	l.date_of_first_submission,
	l.frequency,
	l.data_item_subtitle,
	l.copies_required,
	l.cdrl_category,
	l.data_item_name,
	l.export_flag
    from oke_k_lines_v l, okc_k_headers_b h, oke_k_headers k
    where h.id = l.header_id
    and l.k_line_id = p_id
    and h.id = k.k_header_id;

    New_L_Rec New_L_C%ROWTYPE;

  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_init_msg_list => p_initiate_msg_list,
			p_api_type      => g_api_type,
			x_return_status => l_return_status);


    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OPEN New_L_C(P_Line_ID);
    FETCH New_L_C INTO New_L_Rec;
    CLOSE New_L_C;

--bug 8466686
OPEN inv_item_yn(P_Line_ID);
    FETCH inv_item_yn INTO l_inv_item_yn;
    CLOSE inv_item_yn;
--bug 8466686 end

    Convert_Value(P_Header_ID
	, P_Line_ID
	, P_Direction
	, L_Ship_To_Org_ID
	, L_Ship_To_Location_ID
	, L_Ship_From_Org_ID
	, L_Ship_From_Location_ID
	, L_Inv_Org_ID);

    IF new_l_rec.inventory_item_id is not null THEN  -- need to check inventory
      IF P_Direction = 'IN' THEN  -- need to check ship to location
        IF Check_Org_Items(new_l_rec.inventory_item_id,l_ship_to_org_id) = 'N' THEN
  	    	L_ship_to_org_id := NULL;
          L_ship_to_location_id := NULL;
        END IF;
       ELSIF P_Direction = 'OUT' THEN  -- need to check ship from location
        IF Check_Org_Items(new_l_rec.inventory_item_id,l_ship_from_org_id) = 'N' THEN
          L_ship_from_org_id := NULL;
          L_ship_from_location_id := NULL;
        END IF;
      END IF;
    END IF;

	IF L_Inv_Org_ID IS NULL THEN

	  L_Inv_Org_ID := P_Inventory_Org_ID;

	END IF;

      L_DEL_REC.k_line_id 			:= P_Line_ID;
      L_DEL_REC.defaulted_flag 		:= 'Y';
	L_DEL_REC.direction 			:= P_Direction;
	L_DEL_REC.k_header_id 			:= P_Header_ID;
      L_DEL_REC.Inventory_Org_ID		:= L_Inv_Org_ID;
      L_DEL_REC.Ship_To_Org_ID		:= L_Ship_To_Org_ID;
   	L_DEL_REC.Ship_To_Location_ID		:= L_Ship_To_Location_ID;
	L_DEL_REC.Ship_From_Org_ID		:= L_Ship_From_Org_ID;
 	L_DEL_REC.Ship_From_Location_ID		:= L_Ship_From_Location_ID;
	L_DEL_REC.deliverable_num 		:= NULL;  /* Use numbering package to generate new number */
	L_DEL_REC.project_id 			:= NEW_L_REC.project_id;
      L_DEL_REC.item_id 			:= NEW_L_REC.inventory_item_id;
	L_DEL_REC.description 			:= NEW_L_REC.line_description;
      L_DEL_REC.delivery_date 		:= NEW_L_REC.delivery_date;
     	L_DEL_REC.status_code 			:= NEW_L_REC.status_code;
   	L_DEL_REC.start_date 			:= NEW_L_REC.start_date;
	L_DEL_REC.end_date 			:= NEW_L_REC.end_date;
	L_DEL_REC.priority_code 		:= NEW_L_REC.priority_code;
	L_DEL_REC.currency_code 		:= NEW_L_REC.currency_code;
	L_DEL_REC.unit_price 			:= NEW_L_REC.unit_price;
	L_DEL_REC.uom_code 			:= NEW_L_REC.uom_code;
	L_DEL_REC.quantity 			:= NEW_L_REC.line_quantity;
	L_DEL_REC.country_of_origin_code 	:= NEW_L_REC.country_of_origin_code;
	L_DEL_REC.subcontracted_flag 		:= NEW_L_REC.subcontracted_flag;
	L_DEL_REC.billable_flag 		:= NEW_L_REC.billable_flag;
	L_DEL_REC.drop_shipped_flag 		:= NEW_L_REC.drop_shipped_flag;
--	L_DEL_REC.completed_flag 		:= NEW_L_REC.completed_flag;
	L_DEL_REC.shippable_flag 		:= NEW_L_REC.shippable_flag;
	L_DEL_REC.cfe_req_flag 			:= NEW_L_REC.cfe_flag;
	L_DEL_REC.inspection_req_flag 		:= NEW_L_REC.inspection_req_flag;
	L_DEL_REC.interim_rpt_req_flag 		:= NEW_L_REC.interim_rpt_req_flag;
	L_DEL_REC.customer_approval_req_flag 	:= NEW_L_REC.customer_approval_req_flag;
    	L_DEL_REC.as_of_date 			:= NEW_L_REC.as_of_date;
 	L_DEL_REC.date_of_first_submission 	:= NEW_L_REC.date_of_first_submission;
	L_DEL_REC.frequency 			:= NEW_L_REC.frequency;
	L_DEL_REC.data_item_subtitle 		:= NEW_L_REC.data_item_subtitle;
	L_DEL_REC.total_num_of_copies 		:= NEW_L_REC.copies_required;
	L_DEL_REC.cdrl_category 		:= NEW_L_REC.cdrl_category;
	L_DEL_REC.data_item_name 		:= NEW_L_REC.data_item_name;
	L_DEL_REC.export_flag 			:= NEW_L_REC.export_flag;

        -- default destination type code if for inbound deliverable

        IF P_Direction = 'IN' THEN
--bug 8466686 added code to verify if item is an inventory_item or not
--IF L_DEL_REC.Item_ID IS NOT NULL THEN

	  IF l_inv_item_yn = 'Y' THEN

	    L_DEL_REC.Destination_Type_Code := 'INVENTORY';

    ELSE

      L_DEL_REC.Destination_Type_Code := 'EXPENSE';

--end of bug 8466686

	 END IF;

	END IF;

	-- Create new deliverable

	OKE_CONTRACT_PUB.create_deliverable(
		p_api_version	=> l_api_version,
		p_init_msg_list	=> p_initiate_msg_list,
		x_return_status => l_return_status,
		x_msg_count     => x_msg_count,
		x_msg_data      => x_msg_data,
      		p_del_rec	=> l_del_rec,
      		x_del_rec	=> x_del_rec);


        If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
          raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
          raise OKE_API.G_EXCEPTION_ERROR;
        End If;

	X_Counter := 1;
        X_Return_Status := L_Return_Status;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        g_api_type
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        g_api_type
      );
    WHEN OTHERS THEN

      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        g_api_type
      );

  END Create_New_L;

  PROCEDURE Create_New ( P_Init_Msg_List VARCHAR2
		, X_Return_Status 		OUT NOCOPY VARCHAR2
		, X_Msg_Count			OUT NOCOPY NUMBER
		, X_Msg_Data			OUT NOCOPY VARCHAR2
		, P_Header_ID			IN  NUMBER
		, P_Direction			IN  VARCHAR2
		, P_Inventory_Org_ID		IN  NUMBER
		, X_Counter			OUT NOCOPY NUMBER) IS

    L_Api_Name CONSTANT VARCHAR2(30) := 'Create_New_L';
    L_Api_Verson CONSTANT NUMBER := 1;
    L_Return_Status VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
    X_Del_Rec OKE_DELIVERABLE_PVT.Del_Rec_Type;
    L_Del_Rec OKE_DELIVERABLE_PVT.Del_Rec_Type;
    L_Del_Tbl OKE_DELIVERABLE_PVT.Del_Tbl_Type;
    X_Del_Tbl OKE_DELIVERABLE_PVT.Del_Tbl_Type;
    L_Counter NUMBER;

    cursor new_c(p_id NUMBER) is
    select l.k_line_id,
	l.line_number,
	l.project_id,
	l.inventory_item_id,
	substr(l.line_description, 1, 240) line_description,
	l.delivery_date,
	l.status_code,
	l.start_date,
	l.end_date,
	k.priority_code,
	h.currency_code,
        DECODE(h.buy_or_sell, 'B', 'IN', 'OUT') Direction,
	l.unit_price,
	l.uom_code,
	l.line_quantity,
	k.country_of_origin_code,
	l.subcontracted_flag,
	l.billable_flag,
	l.drop_shipped_flag,
	l.completed_flag,
	l.shippable_flag,
	l.cfe_flag,
	l.inspection_req_flag,
	l.interim_rpt_req_flag,
	l.customer_approval_req_flag,
    	l.as_of_date,
 	l.date_of_first_submission,
	l.frequency,
	l.data_item_subtitle,
	l.copies_required,
	l.cdrl_category,
	l.data_item_name,
	l.export_flag
    from oke_k_lines_v l, okc_k_headers_b h, oke_k_headers k
    where h.id = p_id
    and l.header_id = p_id
    and h.id = k.k_header_id
    and not exists (select 'x' from oke_k_deliverables_b where k_line_id = l.k_line_id and nvl(defaulted_flag, 'N') = 'Y')
    and not exists (select 'x' from okc_k_lines_b s where s.cle_id = l.k_line_id)
    and exists (select 'x' from okc_assents a
		where a.opn_code = 'CREATE_DELV'
		and a.sts_code = l.status_code
	 	and a.scs_code = 'PROJECT'
		and a.allowed_yn = 'Y');


  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_init_msg_list => p_init_msg_list,
			p_api_type      => g_api_type,
			x_return_status => l_return_status);

    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    L_Counter := 0;

    FOR New_C_Rec IN New_C(P_Header_ID) LOOP


      Create_New_L (P_Initiate_Msg_List 	=> G_False
		, X_Return_Status		=> L_Return_Status
		, X_Msg_Count			=> X_Msg_Count
		, X_Msg_Data		        => X_Msg_Data
		, P_Header_ID			=> P_Header_ID
		, P_Line_ID			=> NEW_C_REC.K_Line_ID
		, P_Direction			=> P_Direction
		, P_Inventory_Org_ID		=> P_Inventory_Org_ID
		, X_Counter			=> X_Counter);

        IF L_Return_Status <> OKE_API.G_Ret_Sts_Success THEN
	  IF L_Return_Status  <> OKE_API.G_Ret_Sts_Unexp_Error THEN
	    L_Return_Status := X_Return_Status;
          END IF;
        END IF;

        L_Counter := L_Counter + 1;

      END LOOP;

      X_Return_Status := L_Return_Status;
      X_Counter := L_Counter;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);


  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        g_api_type
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        g_api_type
      );
    WHEN OTHERS THEN

      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        g_api_type
      );

  END Create_New;

  PROCEDURE Update_Line( P_Init_Msg_List VARCHAR2
		, X_Return_Status 		OUT NOCOPY VARCHAR2
		, X_Msg_Count			OUT NOCOPY NUMBER
		, X_Msg_Data			OUT NOCOPY VARCHAR2
		, P_Header_ID			IN  NUMBER
		, P_Line_ID			IN  NUMBER
		, P_Direction			IN  VARCHAR2
		, P_Inventory_Org_ID		IN  NUMBER
		, X_Counter			OUT NOCOPY NUMBER) IS

    L_Api_Name CONSTANT VARCHAR2(30) := 'Update_Line';
    L_Api_Version CONSTANT NUMBER := 1;
    L_Return_Status VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
    L_Del_Rec OKE_DELIVERABLE_PVT.Del_Rec_Type;
    L_Del_Tbl OKE_DELIVERABLE_PVT.Del_Tbl_Type;
    X_Del_Rec OKE_DELIVERABLE_PVT.Del_Rec_Type;
    X_Del_Tbl OKE_DELIVERABLE_PVT.Del_Tbl_Type;
    L_Counter NUMBER;
    L_Direction VARCHAR2(30);
    L_Ship_From_Org_ID NUMBER;
    L_Ship_From_Location_ID NUMBER;
    L_Ship_To_Org_ID NUMBER;
    L_Ship_To_Location_ID NUMBER;
    L_Inv_Org_ID NUMBER;
    L_MDS_ID NUMBER;
    L_Out_ID NUMBER;


    CURSOR Update_L_C ( P_ID NUMBER ) IS
    SELECT l.line_number,
	l.project_id,
	l.inventory_item_id,
        SUBSTR(l.line_description, 1, 240) line_description,
	l.delivery_date,
	l.status_code,
	l.start_date,
	l.end_date,
	k.priority_code,
	h.currency_code,
        DECODE(h.buy_or_sell, 'B', 'IN', 'OUT') Direction,
	l.unit_price,
	l.uom_code,
	l.line_quantity,
	k.country_of_origin_code,
	l.subcontracted_flag,
	l.billable_flag,
	l.drop_shipped_flag,
--	l.completed_flag,
	l.shippable_flag,
	l.cfe_flag,
	l.inspection_req_flag,
	l.interim_rpt_req_flag,
	l.customer_approval_req_flag,
    	l.as_of_date,
 	l.date_of_first_submission,
	l.frequency,
	l.data_item_subtitle,
	l.copies_required,
	l.cdrl_category,
	l.data_item_name,
	l.export_flag
    from oke_k_lines_v l, okc_k_headers_b h, oke_k_headers k
    where l.k_line_id = p_id
    and h.id = l.header_id
    and k.k_header_id = l.header_id;

    CURSOR C IS
    SELECT Deliverable_ID, Mps_Transaction_ID
    FROM oke_k_deliverables_b
    WHERE K_Line_ID = P_Line_ID
    AND NVL(Defaulted_Flag, 'N') = 'Y';

    Update_L_Rec Update_L_C%ROWTYPE;

  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_init_msg_list => p_init_msg_list,
			p_api_type      => g_api_type,
			x_return_status => l_return_status);


        OPEN Update_L_C(P_Line_ID);
        FETCH Update_L_C INTO Update_L_Rec;
        CLOSE Update_L_C;

	Convert_Value(P_Header_ID
		, P_Line_ID
		, P_Direction
		, L_Ship_To_Org_ID
		, L_Ship_To_Location_ID
		, L_Ship_From_Org_ID
		, L_Ship_From_Location_ID
		, L_Inv_Org_ID);

    IF Update_L_Rec.inventory_item_id is not null THEN  -- need to check inventory
      IF P_Direction = 'IN' THEN  -- need to check ship to location
        IF Check_Org_Items(update_l_rec.inventory_item_id,l_ship_to_org_id) = 'N' THEN
  	    	L_ship_to_org_id := NULL;
          L_ship_to_location_id := NULL;
        END IF;
       ELSIF P_Direction = 'OUT' THEN  -- need to check ship from location
        IF Check_Org_Items(update_l_rec.inventory_item_id,l_ship_from_org_id) = 'N' THEN
          L_ship_from_org_id := NULL;
          L_ship_from_location_id := NULL;
        END IF;
      END IF;
    END IF;

	IF L_Inv_Org_ID IS NULL THEN

	  L_Inv_Org_ID := P_Inventory_Org_ID;

	END IF;

	-- Get deliverable_ID, assume that splited/newly created deliverale
        -- have been filtered out by batch process/line update

        OPEN C;
        FETCH C INTO L_DEL_REC.deliverable_ID, L_MDS_ID;
        CLOSE C;

      	  L_DEL_REC.defaulted_flag 		:= 'Y';
	  L_DEL_REC.direction 			:= P_Direction;
	  L_DEL_REC.k_header_id 		:= P_Header_ID;
          L_DEL_REC.Inventory_Org_ID		:= L_Inv_Org_ID;
          L_DEL_REC.Ship_To_Org_ID		:= L_Ship_To_Org_ID;
   	  L_DEL_REC.Ship_To_Location_ID		:= L_Ship_To_location_ID;
	  L_DEL_REC.Ship_From_Org_ID		:= L_Ship_From_Org_ID;
 	  L_DEL_REC.Ship_From_Location_ID	:= L_Ship_From_location_ID;
	  L_DEL_REC.project_id 			:= UPDATE_L_REC.project_id;
          L_DEL_REC.item_id 			:= UPDATE_L_REC.inventory_item_id;
          L_DEL_REC.description                 := UPDATE_L_REC.line_description;
          L_DEL_REC.delivery_date 		:= UPDATE_L_REC.delivery_date;
     	  L_DEL_REC.status_code 		:= UPDATE_L_REC.status_code;
   	  L_DEL_REC.start_date 			:= UPDATE_L_REC.start_date;
	  L_DEL_REC.end_date 			:= UPDATE_L_REC.end_date;
	  L_DEL_REC.priority_code 		:= UPDATE_L_REC.priority_code;
	  L_DEL_REC.currency_code 		:= UPDATE_L_REC.currency_code;
	  L_DEL_REC.unit_price 			:= UPDATE_L_REC.unit_price;
	  L_DEL_REC.uom_code 			:= UPDATE_L_REC.uom_code;
	  L_DEL_REC.quantity 			:= UPDATE_L_REC.line_quantity;
	  L_DEL_REC.country_of_origin_code 	:= UPDATE_L_REC.country_of_origin_code;
	  L_DEL_REC.subcontracted_flag 		:= UPDATE_L_REC.subcontracted_flag;
	  L_DEL_REC.billable_flag 		:= UPDATE_L_REC.billable_flag;
	  L_DEL_REC.drop_shipped_flag 		:= UPDATE_L_REC.drop_shipped_flag;
--	  L_DEL_REC.completed_flag 		:= UPDATE_L_REC.completed_flag;
	  L_DEL_REC.shippable_flag 		:= UPDATE_L_REC.shippable_flag;
	  L_DEL_REC.cfe_req_flag 		:= UPDATE_L_REC.cfe_flag;
	  L_DEL_REC.inspection_req_flag 	:= UPDATE_L_REC.inspection_req_flag;
	  L_DEL_REC.interim_rpt_req_flag 	:= UPDATE_L_REC.interim_rpt_req_flag;
	  L_DEL_REC.customer_approval_req_flag 	:= UPDATE_L_REC.customer_approval_req_flag;
    	  L_DEL_REC.as_of_date 			:= UPDATE_L_REC.as_of_date;
 	  L_DEL_REC.date_of_first_submission 	:= UPDATE_L_REC.date_of_first_submission;
	  L_DEL_REC.frequency 			:= UPDATE_L_REC.frequency;
	  L_DEL_REC.data_item_subtitle 		:= UPDATE_L_REC.data_item_subtitle;
	  L_DEL_REC.total_num_of_copies 	:= UPDATE_L_REC.copies_required;
	  L_DEL_REC.cdrl_category 		:= UPDATE_L_REC.cdrl_category;
	  L_DEL_REC.data_item_name 		:= UPDATE_L_REC.data_item_name;
	  L_DEL_REC.export_flag 		:= UPDATE_L_REC.export_flag;



	  -- Update deliverable

	  OKE_CONTRACT_PUB.update_deliverable(
		p_api_version	=> l_api_version,
		p_init_msg_list	=> p_init_msg_list,
		x_return_status => l_return_status,
		x_msg_count     => x_msg_count,
		x_msg_data      => x_msg_data,
      		p_del_rec	=> l_del_rec,
      		x_del_rec	=> x_del_rec);


          If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
            raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
            raise OKE_API.G_EXCEPTION_ERROR;
          End If;

	  -- If planning is initiated, update MDS as well

	  /*

          IF L_MDS_ID > 0 THEN

	    OKE_DTS_INTEGRATION_PKG.Create_MDS_Entry (
			P_Deliverable_ID 	=> L_DEL_REC.Deliverable_ID
			, X_Out_ID		=> L_Out_ID
			, X_Return_Status 	=> L_Return_Status);

	  END IF;

          If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
            raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	  Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
            raise OKE_API.G_EXCEPTION_ERROR;
          End If;  */

    X_Return_Status := L_Return_Status;
    X_Counter := 1;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END Update_Line;

  PROCEDURE Update_Batch ( P_Init_Msg_List VARCHAR2
		, X_Return_Status 		OUT NOCOPY VARCHAR2
		, X_Msg_Count			OUT NOCOPY NUMBER
		, X_Msg_Data			OUT NOCOPY VARCHAR2
		, P_Header_ID			IN  NUMBER
		, P_Direction			IN  VARCHAR2
		, P_Inventory_Org_ID		IN  NUMBER
		, X_Counter			OUT NOCOPY NUMBER) IS

    L_Api_Name CONSTANT VARCHAR2(30) := 'Update_Batch';
    L_Api_Verson CONSTANT NUMBER := 1;
    L_Return_Status VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
    L_Del_Rec OKE_DELIVERABLE_PVT.Del_Rec_Type;
    L_Del_Tbl OKE_DELIVERABLE_PVT.Del_Tbl_Type;
    X_Del_Rec OKE_DELIVERABLE_PVT.Del_Rec_Type;
    X_Del_Tbl OKE_DELIVERABLE_PVT.Del_Tbl_Type;
    L_Counter NUMBER;
    L_Deliverable_ID NUMBER;
    L_Msg_Data VARCHAR2(2000);
    L_Msg_Count NUMBER;
    L_Count NUMBER;
    L_Msg1 VARCHAR2(2000);
    L_Msg2 VARCHAR2(2000);
    L_Msg3 VARCHAR2(2000);
    L_Mps_F VARCHAR2(2000);
    L_Mps_S VARCHAR2(2000);

    -- Message related variables

    L_Token1 VARCHAR2(150);
    L_Token1_Value LONG;
    L_Token2 VARCHAR2(150);
    L_Token2_Value LONG;
    L_Token3 VARCHAR2(150);
    L_Token3_Value LONG;
    L_Token4 VARCHAR2(150);
    L_Token4_Value LONG;
    L_Token5 VARCHAR2(150);
    L_Token5_Value LONG;
    L_Token6 VARCHAR2(150);
    L_Token6_Value LONG;
    L_Token7 VARCHAR2(150);
    L_Token7_Value LONG;
    L_Used_Token NUMBER;
    L_Next_Token VARCHAR2(150);
    L_Final_Msg LONG;
    L_Token_Value VARCHAR2(2000);

    CURSOR Update_C ( P_ID NUMBER ) IS
    SELECT l.k_line_id, b.deliverable_ID, l.line_number
    from oke_k_lines_v l, oke_k_deliverables_b b
    where b.k_header_id = p_id
    and b.k_line_id = l.k_line_id
    and nvl(l.scheduled_delv_default, 'N') = 'Y'
    and nvl(defaulted_flag, 'N') = 'Y'
    GROUP BY l.k_line_id, b.deliverable_ID, l.line_number
    HAVING count(*)=1;

  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_init_msg_list => p_init_msg_list,
			p_api_type      => g_api_type,
			x_return_status => l_return_status);

    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    L_Counter := 0;

    FOR Update_Rec IN Update_C(P_Header_ID) LOOP

      Verify_Defaults (
	    P_Line_ID			=> UPDATE_REC.K_Line_ID
	  , X_Msg_1			=> L_Msg1
	  , X_Msg_2			=> L_Msg2
	  , X_Msg_3			=> L_Msg3
	  , X_Return_Status		=> L_Return_Status
	  , P_Calling_Level => 'H');

      IF L_Msg1 IS NULL AND L_Return_Status = 'U' THEN

      Update_Line(
    	P_Init_Msg_List 		=> G_False
  	, X_Return_Status 		=> L_Return_Status
  	, X_Msg_Count			=> X_Msg_Count
  	, X_Msg_Data			=> X_Msg_Data
  	, P_Header_ID			=> P_Header_ID
  	, P_Line_ID			=> Update_Rec.K_Line_ID
  	, P_Direction			=> P_Direction
  	, P_Inventory_Org_ID		=> P_Inventory_Org_ID
  	, X_Counter			=> X_Counter);

        IF L_Return_Status <> OKE_API.G_Ret_Sts_Success THEN
	  IF L_Return_Status  <> OKE_API.G_Ret_Sts_Unexp_Error THEN
	    L_Return_Status := X_Return_Status;
          END IF;
        ELSE
	  UPDATE oke_k_lines
          SET Scheduled_Delv_Default = 'N'
          WHERE K_Line_ID = Update_Rec.K_Line_ID;
        END IF;

        -- Check mds records

        IF Check_Mps_Valid ( Update_Rec.K_Line_ID, L_Mps_S, L_Mps_F ) THEN

          OKE_DTS_ACTION_PKG.Initiate_Actions( P_Action => 'PLAN'
				, P_Action_Level	=> 3
		  		, P_Header_ID  		=> P_Header_ID
		  		, P_Line_ID    		=> Update_Rec.K_Line_ID
				, P_Deliverable_ID 	=> Update_Rec.Deliverable_ID
				, X_Return_Status	=> L_Return_Status
				, X_Msg_Data		=> L_Msg_Data
				, X_Msg_Count		=> L_Msg_Count );

        ELSE

		    UPDATE oke_k_deliverables_b
		    SET Create_Demand = 'N'
		    WHERE Deliverable_ID = Update_Rec.Deliverable_ID;

	END IF;

        IF L_Mps_S IS NOT NULL THEN

	  FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_MDS_SUCCESS');
	  L_Token6 := FND_MESSAGE.Get;
	  IF L_Token6_Value IS NULL THEN
	    L_Token6_Value := UPDATE_REC.Line_Number;
	  ELSE
	    IF isNewMessageWithinLimit (
                p_existing_message => L_Token6||L_Token6_Value
               ,p_new_token_value  => UPDATE_REC.Line_Number) THEN
    	    L_Token6_Value := L_Token6_Value || ', ' || UPDATE_REC.Line_Number;
        END IF;
	  END IF;

        END IF;

        IF L_Mps_F IS NOT NULL THEN

	  FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_MDS_FAILURE');
	  L_Token7 := FND_MESSAGE.Get;
	  IF L_Token7_Value IS NULL THEN
	    L_Token7_Value := UPDATE_REC.Line_Number;
	  ELSE
		IF isNewMessageWithinLimit (
				p_existing_message => L_Token7||L_Token7_Value
			   ,p_new_token_value  => UPDATE_REC.Line_Number) THEN
		   L_Token7_Value := L_Token7_Value || ', ' || UPDATE_REC.Line_Number;
		END IF;

	  END IF;

        END IF;


        ELSE  -- Previous if condition after verify defaults

       	  IF l_msg3 = 'SPL' THEN
	    L_Token1 := l_msg1;
	    IF L_Token1_Value IS NULL THEN
	      L_Token1_Value := UPDATE_REC.Line_Number;
	    ELSE
    	    IF isNewMessageWithinLimit (
                    p_existing_message => L_Token1||L_Token1_Value
                   ,p_new_token_value  => UPDATE_REC.Line_Number) THEN
	            L_Token1_Value := L_Token1_Value || ', ' ||  UPDATE_REC.Line_Number;
            END IF;
	    END IF;

	  ELSIF l_msg3 = 'WSH' THEN
	    L_Token2 := l_msg1;
	    IF L_Token2_Value IS NULL THEN
	      L_Token2_Value := UPDATE_REC.Line_Number;
	    ELSE
    	    IF isNewMessageWithinLimit (
                    p_existing_message => L_Token2||L_Token2_Value
                   ,p_new_token_value  => UPDATE_REC.Line_Number) THEN
    	      L_Token2_Value := L_Token2_Value || ', ' ||  UPDATE_REC.Line_Number ;
            END IF;
	    END IF;

	  ELSIF l_msg3 = 'REQ' THEN


	    L_Token3 := l_msg1;
	    IF L_Token3_Value IS NULL THEN
	      L_Token3_Value := UPDATE_REC.Line_Number;
	    ELSE
    	    IF isNewMessageWithinLimit (
                    p_existing_message => L_Token3||L_Token3_Value
                   ,p_new_token_value  => UPDATE_REC.Line_Number) THEN
		      L_Token3_Value := L_Token3_Value || ', ' ||  UPDATE_REC.Line_Number ;
            END IF;

	    END IF;

	  ELSIF l_msg3 = 'BIL' THEN
	    L_Token4 := l_msg1;
	    IF L_Token4_Value IS NULL THEN
	      L_Token4_Value := UPDATE_REC.Line_Number;
	    ELSE
    	    IF isNewMessageWithinLimit (
                    p_existing_message => L_Token4||L_Token4_Value
                   ,p_new_token_value  => UPDATE_REC.Line_Number) THEN
    	      L_Token4_Value := L_Token4_Value || ', ' ||  UPDATE_REC.Line_Number ;
            END IF;

	    END IF;

	  ELSIF l_msg3 = 'COM' THEN
	    L_Token5 := l_msg1;
	    IF L_Token5_Value IS NULL THEN
	      L_Token5_Value := UPDATE_REC.Line_Number;
	    ELSE
    	    IF isNewMessageWithinLimit (
                    p_existing_message => L_Token5||L_Token5_Value
                   ,p_new_token_value  => UPDATE_REC.Line_Number) THEN
    	      L_Token5_Value := L_Token5_Value || ', ' ||  UPDATE_REC.Line_Number ;
            END IF;

	    END IF;

	  END IF;

        END IF;

	L_Counter := L_Counter + 1;

      END LOOP;

      -- Sort messages and put on the message stack

      IF L_Token1 IS NOT NULL OR L_Token2 IS NOT NULL OR L_Token3 IS NOT NULL OR L_Token4 IS NOT NULL
        OR L_Token5 IS NOT NULL OR L_Token6 IS NOT NULL OR L_Token7 IS NOT NULL THEN

        IF L_Token1 IS NOT NULL THEN

    	  FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_SPLIT');
          FND_MESSAGE.Set_Token('TOKEN_VALUE_1', L_Token1_Value);
          FND_MSG_PUB.Add;
        END IF;
        IF L_Token2 IS NOT NULL THEN
            FND_MESSAGE.Set_Name('OKE', 'OKE_H_DTS_DATA_WSH');
            FND_MESSAGE.Set_Token('TOKEN_VALUE_1', L_Token2_Value);
            FND_MSG_PUB.Add;
        END IF;
        IF L_Token3 IS NOT NULL THEN
            FND_MESSAGE.Set_Name('OKE', 'OKE_H_DTS_DATA_REQ');
        	FND_MESSAGE.Set_Token('TOKEN_VALUE_1', L_Token3_Value);
            FND_MSG_PUB.Add;
        END IF;
        IF L_Token4 IS NOT NULL THEN
            FND_MESSAGE.Set_Name('OKE', 'OKE_H_DTS_DATA_BILL');
      	    FND_MESSAGE.Set_Token('TOKEN_VALUE_1', L_Token4_Value);
            FND_MSG_PUB.Add;
        END IF;

        IF L_Token5 IS NOT NULL THEN
            FND_MESSAGE.Set_Name('OKE', 'OKE_H_DTS_DATA_COMPLETED');
            FND_MESSAGE.Set_Token('TOKEN_VALUE_1', L_Token5_Value);
            FND_MSG_PUB.Add;
        END IF;
        IF L_Token6 IS NOT NULL THEN
            FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_MDS_SUCCESS');
            FND_MESSAGE.Set_Token('TOKEN_VALUE_1', L_Token6_Value);
            FND_MSG_PUB.Add;
        END IF;
        IF L_Token7 IS NOT NULL THEN
            FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_MDS_FAILURE');
            FND_MESSAGE.Set_Token('TOKEN_VALUE_1', L_Token7_Value);
            FND_MSG_PUB.Add;
        END IF;
      END IF;
      X_Return_Status := L_Return_Status;
      X_Counter := L_Counter;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        g_api_type
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        g_api_type
      );
    WHEN OTHERS THEN

      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        g_api_type
      );

  END Update_Batch;

  FUNCTION Check_Mps_Valid ( P_Line_ID NUMBER, X_Mps_S OUT NOCOPY VARCHAR2, X_Mps_F OUT NOCOPY VARCHAR2 )RETURN BOOLEAN IS

    L_ID NUMBER;
    L_Mds_ID NUMBER;
    L_Msg VARCHAR2(2000);
    L_Value VARCHAR2(1000);
    L_Direction VARCHAR2(20);
    L_Header_ID NUMBER;
    L_Inventory_Org_ID NUMBER;
    L_Ship_From_Org_ID NUMBER;
    L_Ship_To_Org_ID NUMBER;
    L_Ship_From_ID NUMBER;
    L_Ship_To_ID NUMBER;
    L_Item_ID NUMBER;
    L_Demand VARCHAR2(1);
    L_Quantity NUMBER;
    L_Line_Number VARCHAR2(150);
    L_Total_Msg LONG;
    L_Next_Token VARCHAR2(150);

    CURSOR C IS
    SELECT Mps_Transaction_ID, Deliverable_ID, Create_Demand
    FROM OKE_K_DELIVERABLES_B
    WHERE K_Line_ID = P_Line_ID
     AND NVL(Defaulted_Flag, 'N') = 'Y'
    AND NVL(Create_Demand, 'N') = 'Y';

    CURSOR Verify_C IS
    SELECT DECODE(H.Buy_Or_Sell, 'B', 'IN', 'OUT')
    , L.Header_ID
    , L.Inventory_Item_ID
    , L.Line_Quantity
    , L.Line_Number
    FROM okc_k_headers_b H, oke_k_lines_v L
    WHERE H.ID = L.Header_ID
    AND L.K_Line_ID = P_Line_ID;

    CURSOR Item_C IS
    SELECT 'X'
    FROM oke_system_items_v
    WHERE ID1 = L_Item_ID
    AND ID2 = L_Inventory_Org_ID;


  BEGIN

    OPEN C;
    FETCH C INTO L_Mds_ID, L_ID, L_Demand;
    CLOSE C;

    IF L_Demand = 'Y' THEN

        OPEN Verify_C;
        FETCH Verify_C INTO L_Direction, L_Header_ID, L_Item_ID, L_Quantity, L_Line_Number;
        CLOSE Verify_C;


        OKE_DEFAULTING_PKG.Convert_Value(L_Header_ID
				, P_Line_ID
				, L_Direction
				, L_Ship_To_Org_ID
				, L_Ship_To_ID
				, L_Ship_From_Org_ID
				, L_Ship_From_ID
				, L_Inventory_Org_ID);


      IF L_Item_ID IS NULL THEN

	fnd_message.set_name('OKE', 'OKE_DTS_DATA_ITEM');
	l_msg := fnd_message.get;

      ELSIF L_Ship_From_ID IS NULL THEN

	fnd_message.set_name('OKE', 'OKE_DTS_DATA_FROM_LOCATION');
	l_msg := fnd_message.get;

      ELSIF L_Ship_To_ID IS NULL THEN

	fnd_message.set_name('OKE', 'OKE_DTS_DATA_TO_LOCATION');
	l_msg := fnd_message.get;

      ELSIF L_Quantity IS NULL THEN

	fnd_message.set_name('OKE', 'OKE_DTS_DATA_QTY');
	l_msg := fnd_message.get;

      ELSIF L_Item_ID IS NOT NULL THEN

	IF L_Inventory_Org_ID > 0 THEN

	  OPEN Item_C;
	  FETCH Item_C INTO L_Value;
	  CLOSE Item_C;

	  IF L_Value <> 'X' OR L_Value IS NULL THEN

	    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_DATA_INVALID_ITEM_ORG');
            L_Msg := FND_MESSAGE.Get;

	  END IF;

	END IF;

      END IF;

      IF L_Msg IS NOT NULL THEN

--        OKE_API.Set_Message('OKE', 'OKE_KAUWB_MDS_NOT_VALID', 'TOKEN1', L_Line_Number, 'TOKEN2', L_Msg);

--         FND_MESSAGE.Set_Name('OKE','OKE_KAUWB_MDS_NOT_VALID');
--	FND_MESSAGE.Set_Token('TOKEN1', L_Line_Number);
-- 	FND_MESSAGE.Set_Token('TOKEN2', L_Msg);
	X_MPS_F := L_Msg;

        RETURN FALSE;

      ELSE

--	OKE_API.Set_Message('OKE', 'OKE_KAUWB_MDS_UPDATED', 'TOKEN1', L_Line_Number);

--	FND_MESSAGE.Set_Name('OKE', 'OKE_KAUWB_MDS_UPDATED');
--      X_Mps_S := FND_MESSAGE.Get;
	X_Mps_S := 'S';

        RETURN TRUE;

      END IF;

    ELSE


      RETURN TRUE;

    END IF;

  EXCEPTION

    WHEN OTHERS THEN

      RETURN FALSE;

  END Check_MPS_Valid;


END;


/
