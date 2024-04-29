--------------------------------------------------------
--  DDL for Package Body OKE_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CONTRACT_PVT" AS
/* $Header: OKEVCCCB.pls 120.1 2005/10/03 12:52:08 ausmani noship $ */


  -- GLOBAL VARIABLES

  G_APP_NAME		 CONSTANT VARCHAR2(3)   :=  OKE_API.G_APP_NAME;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKE_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKE_CONTRACTS_UNEXPECTED_ERROR';

  G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKE_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKE_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKE_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKE_API.G_COL_NAME_TOKEN;
  G_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_TABLE_TOKEN;
  G_EXCEPTION_HALT_VALIDATION exception;

  NO_CONTRACT_FOUND exception;

  G_NO_UPDATE_ALLOWED_EXCEPTION exception;
  G_NO_UPDATE_ALLOWED CONSTANT VARCHAR2(200) := 'OKE_NO_UPDATE_ALLOWED';
  G_EXCEPTION_HALT_PROCESS exception;

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec                     IN  OKE_CHR_PVT.chr_rec_type,
    x_chr_rec                     OUT NOCOPY  OKE_CHR_PVT.chr_rec_type) IS

    l_chr_rec		OKE_CHR_PVT.chr_rec_type := p_chr_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKE_API.G_RET_STS_SUCCESS;



    OKE_CHR_PVT.Insert_Row(
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_chr_rec		=> l_chr_rec,
            x_chr_rec		=> x_chr_rec);

  END create_contract_header;

  FUNCTION Increment_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2 IS

  l_return_status  VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

  BEGIN

    RETURN(l_return_status);

  END;

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl                     IN  OKE_CHR_PVT.chr_tbl_type,
    x_chr_tbl                     OUT NOCOPY  OKE_CHR_PVT.chr_tbl_type) IS

  BEGIN

    OKE_CHR_PVT.Insert_Row(

      p_api_version		=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_chr_tbl		=> p_chr_tbl,
      x_chr_tbl		=> x_chr_tbl);

  END create_contract_header;

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec                      IN OKE_CHR_PVT.chr_rec_type,
    x_chr_rec                      OUT NOCOPY OKE_CHR_PVT.chr_rec_type) IS

  BEGIN

    OKE_CHR_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_chr_rec			=> p_chr_rec,
      x_chr_rec			=> x_chr_rec);


  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_header;

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl                     IN OKE_CHR_PVT.chr_tbl_type,
    x_chr_tbl                     OUT NOCOPY OKE_CHR_PVT.chr_tbl_type) IS

  BEGIN

    OKE_CHR_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_chr_tbl			=> p_chr_tbl,
      x_chr_tbl			=> x_chr_tbl);
  END update_contract_header;

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec                     IN OKE_CHR_PVT.chr_rec_type) IS



  BEGIN

    		OKE_CHR_PVT.delete_row(
	 		p_api_version		=> p_api_version,
	 		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_chr_rec		=> p_chr_rec);
  EXCEPTION

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
  END delete_contract_header;



  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl                     IN OKE_CHR_PVT.chr_tbl_type) IS

  BEGIN
    OKE_CHR_PVT.Delete_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_chr_tbl		=> p_chr_tbl);
  END delete_contract_header;

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec                     IN OKE_CHR_PVT.chr_rec_type) IS

  BEGIN
    OKE_CHR_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_chr_rec		=> p_chr_rec);
  END validate_contract_header;

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl                     IN OKE_CHR_PVT.chr_tbl_type) IS

  BEGIN
    OKE_CHR_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_chr_tbl		=> p_chr_tbl);
  END validate_contract_header;

 PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                     IN  OKE_CLE_PVT.cle_rec_type,
    x_cle_rec                     OUT NOCOPY  OKE_CLE_PVT.cle_rec_type) IS

    l_cle_rec		OKE_CLE_PVT.cle_rec_type := p_cle_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKE_API.G_RET_STS_SUCCESS;



    OKE_CLE_PVT.Insert_Row(
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_cle_rec		=> l_cle_rec,
            x_cle_rec		=> x_cle_rec);

  END create_contract_line;

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                     IN  OKE_CLE_PVT.cle_tbl_type,
    x_cle_tbl                     OUT NOCOPY  OKE_CLE_PVT.cle_tbl_type) IS

  BEGIN

    OKE_CLE_PVT.Insert_Row(

      p_api_version		=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_cle_tbl		=> p_cle_tbl,
      x_cle_tbl		=> x_cle_tbl);

  END create_contract_line;

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                      IN OKE_CLE_PVT.cle_rec_type,
    x_cle_rec                      OUT NOCOPY OKE_CLE_PVT.cle_rec_type) IS

  BEGIN



    OKE_CLE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_cle_rec			=> p_cle_rec,
      x_cle_rec			=> x_cle_rec);


  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_line;

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                     IN OKE_CLE_PVT.cle_tbl_type,
    x_cle_tbl                     OUT NOCOPY OKE_CLE_PVT.cle_tbl_type) IS

  BEGIN
    OKE_CLE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_cle_tbl			=> p_cle_tbl,
      x_cle_tbl			=> x_cle_tbl);
  END update_contract_line;

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                     IN OKE_CLE_PVT.cle_rec_type) IS

    l_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_chr_id	NUMBER;
    l_dummy_val NUMBER;
    CURSOR l_csr IS
    SELECT COUNT(*)
    FROM OKE_K_LINES_V
    WHERE PARENT_LINE_ID = p_cle_rec.K_LINE_ID;

  BEGIN
    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

    -- delete only if there are no detail records
    IF (l_dummy_val = 0) THEN

    		OKE_CLE_PVT.delete_row(
	 		p_api_version		=> p_api_version,
	 		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_cle_rec		=> p_cle_rec);
    ELSE
 	OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					     p_msg_name	=> g_no_parent_record,
					     p_token1		=> g_child_table_token,
					     p_token1_value	=> 'OKE_K_LINES_full_V',
					     p_token2		=> g_parent_table_token,
					     p_token2_value	=> 'OKE_K_LINES_V');
	     -- notify caller of an error
	     x_return_status := OKE_API.G_RET_STS_ERROR;
    End If;

  EXCEPTION
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
  END delete_contract_line;



  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                     IN OKE_CLE_PVT.cle_tbl_type) IS

  BEGIN
    OKE_CLE_PVT.Delete_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_cle_tbl		=> p_cle_tbl);
  END delete_contract_line;

 PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                     IN NUMBER) IS


    l_cle_Id     NUMBER;
    v_Index   Binary_Integer;

    CURSOR Child_Cur1(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   OKc_K_Lines_b
    WHERE  cle_id=P_Parent_Id;

    CURSOR Child_Cur2(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

    CURSOR Child_Cur3(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

    CURSOR Child_Cur4(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

    CURSOR Child_Cur5(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

    n NUMBER:=0;
    l_cle_tbl_in     OKE_CLE_PVT.cle_tbl_type;
    l_cle_tbl_tmp    OKE_CLE_PVT.cle_tbl_type;

    l_api_version	CONSTANT	NUMBER      := 1.0;
    l_init_msg_list	CONSTANT	VARCHAR2(1) := 'T';
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000):=null;
    l_msg_index_out       Number;
    l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Contract_Line';
    e_error               Exception;
    c_clev NUMBER:=1;

    l_lse_Id NUMBER;


    -- PROCEDURE Validate_Line_id

    PROCEDURE Validate_Line_id(

      p_line_id          IN NUMBER,
      x_return_status 	OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
      l_Count   NUMBER;
      CURSOR Cur_Line(P_Line_Id IN NUMBER) IS
      SELECT COUNT(*) FROM OKC_K_LINES_V
      WHERE id=P_Line_Id;
    BEGIN
      IF P_Line_id = OKE_API.G_MISS_NUM OR
         P_Line_Id IS NULL
      THEN


        OKE_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'P_Lin
e_Id');


        l_return_status := OKE_API.G_RET_STS_ERROR;
      END IF;

      OPEN Cur_Line(P_LIne_Id);
      FETCH Cur_Line INTO l_Count;
      CLOSE Cur_Line;
      IF NOT l_Count = 1

      THEN
        OKE_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'P_Line
_Id');


        l_return_status := OKE_API.G_RET_STS_ERROR;
      END IF;
      x_return_status := l_return_status;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller

        OKE_API.set_message(G_APP_NAME,
  			 G_UNEXPECTED_ERROR,
  			 G_SQLCODE_TOKEN,
  			 SQLCODE,
  			 G_SQLERRM_TOKEN,
  			 SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Line_id;
  BEGIN
  x_return_status:=OKE_API.G_RET_STS_SUCCESS;

  Validate_Line_id(p_line_id,l_return_status);
  IF NOT l_Return_Status ='S'
  THEN RETURN;
  END IF;

  l_cle_tbl_tmp(c_clev).K_LINE_ID:=P_Line_Id;
  c_clev:=c_clev+1;
  FOR Child_Rec1 IN Child_Cur1(P_Line_Id)
  LOOP
  l_cle_tbl_tmp(c_clev).K_LINE_ID:=Child_Rec1.ID;
  c_clev:=c_clev+1;
    FOR Child_Rec2 IN Child_Cur2(Child_Rec1.Id)

    LOOP
  	l_cle_tbl_tmp(c_clev).K_LINE_ID:=Child_Rec2.Id;
          c_clev:=c_clev+1;
       FOR Child_Rec3 IN Child_Cur3(Child_Rec2.Id)
       LOOP
  	   l_cle_tbl_tmp(c_clev).K_LINE_ID:=Child_Rec3.Id;
             c_clev:=c_clev+1;
  	 FOR Child_Rec4 IN Child_Cur4(Child_Rec3.Id)
  	 LOOP
  	      l_cle_tbl_tmp(c_clev).K_LINE_ID:=Child_Rec4.Id;
                c_clev:=c_clev+1;
               FOR Child_Rec5 IN Child_Cur5(Child_Rec4.Id)
  	     LOOP
  	  	l_cle_tbl_tmp(c_clev).K_LINE_ID:=Child_Rec5.Id;
             	c_clev:=c_clev+1;
               END LOOP;
  	 END LOOP;
       END LOOP;
    END LOOP;
  END LOOP;
  c_clev:=1;
  FOR v_Index IN REVERSE l_cle_tbl_tmp.FIRST .. l_cle_tbl_tmp.LAST

  LOOP
  l_cle_tbl_in(c_clev).K_LINE_ID:= l_cle_tbl_tmp(v_Index).K_LINE_ID;
  c_clev:=c_Clev+1;
  END LOOP;

-- get objects linked to the line
-- delete check goes here

  IF NOT l_cle_tbl_in.COUNT=0
  THEN
    delete_contract_line(

     	  p_api_version			=> l_api_version,
    	  p_init_msg_list		=> l_init_msg_list,
       	  x_return_status		=> l_return_status,
            x_msg_count			=> l_msg_count,
            x_msg_data			=> l_msg_data,
            p_cle_tbl			=> l_cle_tbl_in);

    IF nvl(l_return_status,'*') <> 'S'
    THEN
     	IF l_msg_count > 0
        THEN

         FOR i in 1..l_msg_count
         LOOP
          fnd_msg_pub.get (p_msg_index     => -1,
                           p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,


                           p_data          => l_msg_data,
                           p_msg_index_out => l_msg_index_out);
         END LOOP;
        END IF;
        RAISE e_Error;

    END IF;
  END IF;

  EXCEPTION
      WHEN e_Error THEN
      	-- notify caller of an error as UNEXPETED error
      	x_msg_count :=l_msg_count;
  	x_msg_data:=l_msg_data;
        x_return_status := OKE_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Contract_Line',
          'OKE_API.G_RET_STS_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OKE_API.G_EXCEPTION_ERROR THEN
  	x_msg_count :=l_msg_count;
  	x_msg_data:=l_msg_data;
        x_return_status := OKE_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Contract_Line',
          'OKE_API.G_RET_STS_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  	x_msg_count :=l_msg_count;
  	x_msg_data:=l_msg_data;
        x_return_status :=OKE_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Contract_Line',
          'OKE_API.G_RET_STS_UNEXP_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
  	x_msg_count :=l_msg_count;
      	OKE_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
      	-- notify caller of an error as UNEXPETED error
      	x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END delete_contract_line;

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                     IN OKE_CLE_PVT.cle_rec_type) IS

  BEGIN
    OKE_CLE_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_cle_rec		=> p_cle_rec);
  END validate_contract_line;

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                     IN OKE_CLE_PVT.cle_tbl_type) IS

  BEGIN
    OKE_CLE_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_cle_tbl		=> p_cle_tbl);
  END validate_contract_line;

 -- deliverable section

    PROCEDURE copy_related_entities (p_line_id NUMBER,
				p_deliverable_id NUMBER,
				x_return_status OUT NOCOPY VARCHAR2) IS



      cursor l_standard_notes_csr (p_id NUMBER) is
      select b.type_code,
	b.attribute_category,
	b.attribute1,
	b.attribute2,
	b.attribute3,
	b.attribute4,
	b.attribute5,
	b.attribute6,
	b.attribute7,
	b.attribute8,
	b.attribute9,
	b.attribute10,
	b.attribute11,
	b.attribute12,
	b.attribute13,
	b.attribute14,
	b.attribute15,
	t.sfwt_flag,
	t.description,
	t.name,
	t.text
      from oke_k_standard_notes_b b, oke_k_standard_notes_tl t
      where k_line_id = p_id;
      l_standard_notes l_standard_notes_csr%ROWTYPE;


      l_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
      l_id NUMBER;
  BEGIN

    for l_standard_notes in l_standard_notes_csr(p_line_id)
    loop
      select oke_k_standard_notes_s.nextval into l_id from dual;
      insert into oke_k_standard_notes_b
      (standard_notes_id,
	creation_date,
	created_by,
	last_update_date,
	last_update_login,
	last_updated_by,
	k_header_id,
	k_line_id,
	deliverable_id,
	type_code,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15)
      values(
	l_id,
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.login_id,
	fnd_global.user_id,
	null,
	null,
	p_deliverable_id,
        l_standard_notes.type_code,
	l_standard_notes.attribute_category,
	l_standard_notes.attribute1,
	l_standard_notes.attribute2,
	l_standard_notes.attribute3,
	l_standard_notes.attribute4,
	l_standard_notes.attribute5,
	l_standard_notes.attribute6,
	l_standard_notes.attribute7,
	l_standard_notes.attribute8,
	l_standard_notes.attribute9,
	l_standard_notes.attribute10,
	l_standard_notes.attribute11,
	l_standard_notes.attribute12,
	l_standard_notes.attribute13,
	l_standard_notes.attribute14,
	l_standard_notes.attribute15);
      end loop;

  end;

 PROCEDURE create_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN  OKE_DELIVERABLE_PVT.del_rec_type,
    x_del_rec                     OUT NOCOPY  OKE_DELIVERABLE_PVT.del_rec_type) IS

    l_del_rec		OKE_DELIVERABLE_PVT.del_rec_type := p_del_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKE_API.G_RET_STS_SUCCESS;



    OKE_DELIVERABLE_PVT.Insert_Row(
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_del_rec		=> l_del_rec,
            x_del_rec		=> x_del_rec);

	    -- copy related entities
           /* copy_related_entities(x_del_rec.k_line_id,
				x_del_rec.deliverable_id,
			        x_return_status);*/

      If x_return_status = OKE_API.G_RET_STS_SUCCESS Then
          OKE_DTS_WORKFLOW.LAUNCH_MAIN_PROCESS(x_del_rec.deliverable_id,'AUTO');
      End If;


  END create_deliverable;

  PROCEDURE create_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN  OKE_DELIVERABLE_PVT.del_tbl_type,
    x_del_tbl                     OUT NOCOPY  OKE_DELIVERABLE_PVT.del_tbl_type) IS

  BEGIN

    OKE_DELIVERABLE_PVT.Insert_Row(

      p_api_version		=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_del_tbl		=> p_del_tbl,
      x_del_tbl		=> x_del_tbl);

  END create_deliverable;

  PROCEDURE update_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                      IN OKE_DELIVERABLE_PVT.del_rec_type,
    x_del_rec                      OUT NOCOPY OKE_DELIVERABLE_PVT.del_rec_type) IS

  BEGIN



    OKE_DELIVERABLE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_del_rec			=> p_del_rec,
      x_del_rec			=> x_del_rec);


  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
  END update_deliverable;

  PROCEDURE update_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN OKE_DELIVERABLE_PVT.del_tbl_type,
    x_del_tbl                     OUT NOCOPY OKE_DELIVERABLE_PVT.del_tbl_type) IS

  BEGIN
    OKE_DELIVERABLE_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_del_tbl			=> p_del_tbl,
      x_del_tbl			=> x_del_tbl);
  END update_deliverable;

  PROCEDURE delete_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN OKE_DELIVERABLE_PVT.del_rec_type) IS

    l_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_chr_id	NUMBER;
    l_dummy_val NUMBER;
    CURSOR l_csr IS
    SELECT COUNT(*)
    FROM OKE_K_DELIVERABLES_VL
    WHERE PARENT_DELIVERABLE_ID = p_del_rec.DELIVERABLE_ID;

  BEGIN
    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

    -- delete only if there are no detail records
    IF (l_dummy_val = 0) THEN

    		OKE_DELIVERABLE_PVT.delete_row(
	 		p_api_version		=> p_api_version,
	 		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_del_rec		=> p_del_rec);
    ELSE
 	OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					     p_msg_name	=> g_no_parent_record,
					     p_token1		=> g_child_table_token,
					     p_token1_value	=> 'OKE_K_LINES_full_V',
					     p_token2		=> g_parent_table_token,
					     p_token2_value	=> 'OKE_K_LINES_V');
	     -- notify caller of an error
	     x_return_status := OKE_API.G_RET_STS_ERROR;
    End If;

  EXCEPTION
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
  END delete_deliverable;



  PROCEDURE delete_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN OKE_DELIVERABLE_PVT.del_tbl_type) IS

  BEGIN
    OKE_DELIVERABLE_PVT.Delete_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_del_tbl		=> p_del_tbl);
  END delete_deliverable;

 PROCEDURE delete_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_deliverable_id                     IN NUMBER) IS


    l_del_Id     NUMBER;
    v_Index   Binary_Integer;

    CURSOR Child_Cur1(P_Parent_Id IN NUMBER)
    IS SELECT DELIVERABLE_ID
    FROM   OKE_K_DELIVERABLES_B
    WHERE  parent_deliverable_id=P_Parent_Id;

    CURSOR Child_Cur2(P_Parent_Id IN NUMBER)
    IS SELECT DELIVERABLE_ID
    FROM   oke_k_deliverables_b
    WHERE  parent_deliverable_id = P_Parent_Id;

    CURSOR Child_Cur3(P_Parent_Id IN NUMBER)
    IS SELECT DELIVERABLE_ID
    FROM   oke_k_deliverables_b
    WHERE parent_deliverable_id = P_Parent_Id ;

    CURSOR Child_Cur4(P_Parent_Id IN NUMBER)
    IS SELECT DELIVERABLE_ID
    FROM   oke_k_deliverables_b
    WHERE  parent_deliverable_id=P_Parent_Id;

    CURSOR Child_Cur5(P_Parent_Id IN NUMBER)
    IS SELECT DELIVERABLE_ID
    FROM   oke_k_deliverables_b
    WHERE  parent_deliverable_id=P_Parent_Id;

    n NUMBER:=0;
    l_del_tbl_in     OKE_DELIVERABLE_PVT.del_tbl_type;
    l_del_tbl_tmp    OKE_DELIVERABLE_PVT.del_tbl_type;

    l_api_version	CONSTANT	NUMBER      := 1.0;
    l_init_msg_list	CONSTANT	VARCHAR2(1) := 'T';
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000):=null;
    l_msg_index_out       Number;
    l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Deliverable';
    e_error               Exception;
    c_delv NUMBER:=1;

    l_lse_Id NUMBER;


    -- PROCEDURE Validate_Deliverable_id

    PROCEDURE Validate_Deliverable_id(

      p_deliverable_id          IN NUMBER,
      x_return_status 	OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
      l_Count   NUMBER;
      CURSOR Cur_Deliverable(P_Deliverable_Id IN NUMBER) IS
      SELECT COUNT(*) FROM oke_k_deliverables_b
      WHERE deliverable_id=P_Deliverable_Id;
    BEGIN
      IF p_deliverable_id = OKE_API.G_MISS_NUM OR
         P_Deliverable_Id IS NULL
      THEN


        OKE_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'P_Deliverable_Id');


        l_return_status := OKE_API.G_RET_STS_ERROR;
      END IF;

      OPEN Cur_Deliverable(P_Deliverable_Id);
      FETCH Cur_Deliverable INTO l_Count;
      CLOSE Cur_Deliverable;
      IF NOT l_Count = 1

      THEN
        OKE_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'P_Line
_Id');


        l_return_status := OKE_API.G_RET_STS_ERROR;
      END IF;
      x_return_status := l_return_status;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller

        OKE_API.set_message(G_APP_NAME,
  			 G_UNEXPECTED_ERROR,
  			 G_SQLCODE_TOKEN,
  			 SQLCODE,
  			 G_SQLERRM_TOKEN,
  			 SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Deliverable_id;
  BEGIN
  x_return_status:=OKE_API.G_RET_STS_SUCCESS;

  Validate_Deliverable_id(p_deliverable_id,l_return_status);
  IF NOT l_Return_Status ='S'
  THEN RETURN;
  END IF;

  l_del_tbl_tmp(c_delv).DELIVERABLE_ID:=P_Deliverable_Id;
  c_delv:=c_delv+1;
  FOR Child_Rec1 IN Child_Cur1(P_Deliverable_Id)
  LOOP
  l_del_tbl_tmp(c_delv).DELIVERABLE_ID:=Child_Rec1.DELIVERABLE_ID;
  c_delv:=c_delv+1;
    FOR Child_Rec2 IN Child_Cur2(Child_Rec1.deliverable_id)

    LOOP
  	l_del_tbl_tmp(c_delv).DELIVERABLE_ID:=Child_Rec2.deliverable_id;
          c_delv:=c_delv+1;
       FOR Child_Rec3 IN Child_Cur3(Child_Rec2.deliverable_id)
       LOOP
  	   l_del_tbl_tmp(c_delv).DELIVERABLE_ID:=Child_Rec3.deliverable_id;
             c_delv:=c_delv+1;
  	 FOR Child_Rec4 IN Child_Cur4(Child_Rec3.deliverable_id)
  	 LOOP
  	      l_del_tbl_tmp(c_delv).DELIVERABLE_ID:=Child_Rec4.deliverable_id;
                c_delv:=c_delv+1;
               FOR Child_Rec5 IN Child_Cur5(Child_Rec4.deliverable_id)
  	     LOOP
  	  	l_del_tbl_tmp(c_delv).DELIVERABLE_ID:=Child_Rec5.deliverable_id;
             	c_delv:=c_delv+1;
               END LOOP;
  	 END LOOP;
       END LOOP;
    END LOOP;
  END LOOP;
  c_delv:=1;
  FOR v_Index IN REVERSE l_del_tbl_tmp.FIRST .. l_del_tbl_tmp.LAST

  LOOP
  l_del_tbl_in(c_delv).DELIVERABLE_ID:= l_del_tbl_tmp(v_Index).DELIVERABLE_ID;
  c_delv:=c_Delv+1;
  END LOOP;

-- get objects linked to the line
-- delete check goes here

  IF NOT l_del_tbl_in.COUNT=0
  THEN
    delete_deliverable(

     	  p_api_version			=> l_api_version,
    	  p_init_msg_list		=> l_init_msg_list,
       	  x_return_status		=> l_return_status,
            x_msg_count			=> l_msg_count,
            x_msg_data			=> l_msg_data,
            p_del_tbl			=> l_del_tbl_in);

    IF nvl(l_return_status,'*') <> 'S'
    THEN
     	IF l_msg_count > 0
        THEN

         FOR i in 1..l_msg_count
         LOOP
          fnd_msg_pub.get (p_msg_index     => -1,
                           p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,
                           p_data          => l_msg_data,
                           p_msg_index_out => l_msg_index_out);
         END LOOP;
        END IF;
        RAISE e_Error;

    END IF;
  END IF;

  EXCEPTION
      WHEN e_Error THEN
      	-- notify caller of an error as UNEXPETED error
      	x_msg_count :=l_msg_count;
  	x_msg_data:=l_msg_data;
        x_return_status := OKE_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Deliverable',
          'OKE_API.G_RET_STS_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OKE_API.G_EXCEPTION_ERROR THEN
  	x_msg_count :=l_msg_count;
  	x_msg_data:=l_msg_data;
        x_return_status := OKE_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Deliverable',
          'OKE_API.G_RET_STS_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  	x_msg_count :=l_msg_count;
  	x_msg_data:=l_msg_data;
        x_return_status :=OKE_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Deliverable',
          'OKE_API.G_RET_STS_UNEXP_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
  	x_msg_count :=l_msg_count;
      	OKE_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
      	-- notify caller of an error as UNEXPETED error
      	x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END delete_deliverable;

  PROCEDURE validate_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN OKE_DELIVERABLE_PVT.del_rec_type) IS

  BEGIN
    OKE_DELIVERABLE_PVT.Validate_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_del_rec		=> p_del_rec);
  END validate_deliverable;

  PROCEDURE validate_deliverable(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_del_tbl           IN OKE_DELIVERABLE_PVT.del_tbl_type) IS

  BEGIN
    OKE_DELIVERABLE_PVT.Validate_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_del_tbl		=> p_del_tbl);
  END validate_deliverable;

  PROCEDURE lock_deliverable(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_del_rec           IN OKE_DELIVERABLE_PVT.del_rec_type) IS

  BEGIN
    OKE_DELIVERABLE_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_del_rec		=> p_del_rec);
  END lock_deliverable;

  PROCEDURE lock_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN OKE_DELIVERABLE_PVT.del_tbl_type) IS

  BEGIN
    OKE_DELIVERABLE_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_del_tbl		=> p_del_tbl);
  END lock_deliverable;


  PROCEDURE delete_minor_entities (
	p_header_id	IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS

 cursor project_parties is
 select project_party_id
 from pa_project_parties
 where object_type='OKE_K_HEADERS'
 and resource_type_id=101
 and object_id = p_header_id;

  BEGIN
  	for c in project_parties
	loop
	  pa_project_parties_pkg.delete_row
		(x_project_id => null,
		 x_project_party_id => c.project_party_id,
		 x_record_version_number => null);
	end loop;


	delete from oke_k_user_attributes
	where k_header_id = p_header_id;

	delete from oke_chg_logs
	where chg_request_id in
	(select chg_request_id
	from oke_chg_requests
	where k_header_id = p_header_id);





	delete from oke_chg_requests
	where k_header_id = p_header_id;

	delete from oke_k_holds
	where k_header_id = p_header_id;




	delete from oke_k_communications
	where k_header_id = p_header_id;


	delete from oke_dependencies
	where deliverable_id in
	 	 (select deliverable_id
	       from oke_k_deliverables_b
	where k_header_id = p_header_id);


	delete  from oke_k_billing_methods
	where k_header_id = p_header_id;

	delete from oke_k_related_entities
	where k_header_id=p_header_id;

	delete from oke_k_related_entities
	where related_entity_id = p_header_id;

	delete from oke_k_fifo_logs
	where k_header_id = p_header_id;

	delete from okc_k_grpings
	where included_chr_id = p_header_id;

	 delete from oke_k_billing_events
	 where k_header_id= p_header_id;


    x_return_status := OKE_API.G_RET_STS_SUCCESS;


  EXCEPTION
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

  END delete_minor_entities;

  PROCEDURE delete_version_records (
	p_api_version   IN VARCHAR2,
	p_header_id	IN NUMBER,
	x_return_status OUT NOCOPY  varchar2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2) IS

  l_return_status VARCHAR2(1);
  l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Version_Records';
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;

  BEGIN

delete from OKE_K_HEADERS_H
where k_header_id = p_header_id;

delete from OKE_K_LINES_H
where k_line_id in
	(select id from okc_k_lines_bh
	 where dnz_chr_id = p_header_id);

delete from OKE_K_DELIVERABLES_TLH
where deliverable_id in
	(select deliverable_id from OKE_K_DELIVERABLES_BH
	 where k_header_id = p_header_id);

delete from OKE_K_DELIVERABLES_BH
where k_header_id = p_header_id;

delete from OKE_K_FUNDING_SOURCES_H
where object_id = p_header_id and object_type = 'OKE_K_HEADER';

delete from OKE_K_FUND_ALLOCATIONS_H
where object_id = p_header_id;

delete from OKE_K_TERMS_H
where k_header_id = p_header_id;

delete from OKE_K_BILLING_METHODS_H
where k_header_id = p_header_id;

delete from OKE_K_STANDARD_NOTES_TLH
where standard_notes_id in(
	select standard_notes_id
	from oke_k_standard_notes_bh
	where k_header_id = p_header_id);

delete from OKE_K_STANDARD_NOTES_BH
where k_header_id = p_header_id;



delete from OKE_K_USER_ATTRIBUTES_H
where k_header_id = p_header_id;

delete from OKE_K_VERS_NUMBERS_H
where k_header_id = p_header_id;

dbms_output.put_line('before erase saved version'||l_return_status);

OKC_VERSION_PVT.delete_version
  (p_chr_id => p_header_id,
   p_major_version => 0,
   p_minor_version => 0,
   p_called_from => 'RESTORE_VERSION');


dbms_output.put_line('after erase saved version'||l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

dbms_output.put_line('erase saved version succcess');


     x_return_status := OKE_API.G_RET_STS_SUCCESS;


  EXCEPTION
    when OTHERS then

dbms_output.put_line('exception in del ver');
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

  END delete_version_records;





END OKE_CONTRACT_PVT;


/
