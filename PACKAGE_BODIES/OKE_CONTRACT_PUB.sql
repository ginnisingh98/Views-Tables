--------------------------------------------------------
--  DDL for Package Body OKE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CONTRACT_PUB" AS
/* $Header: OKEPCCCB.pls 120.6 2006/06/07 19:10:52 ifilimon noship $ */

  g_api_type		CONSTANT VARCHAR2(4) := '_PUB';



    --
    -- Private Procedure to get contract number if auto-numbering
    -- option is enabled
    --
    PROCEDURE Assign_Doc_Number
    ( X_K_Type_Code   IN     VARCHAR2
    , X_Buy_Or_Sell   IN     VARCHAR2
    , X_Template_Flag IN     VARCHAR2
    , X_K_Number      IN OUT NOCOPY VARCHAR2
    , X_Return_Status IN OUT NOCOPY VARCHAR2
    ) IS

    l_num_mode   VARCHAR2(30);
    l_num_type   VARCHAR2(30);

    BEGIN
      --
      -- Bypass check for templates
      --
      IF ( X_Template_Flag = 'Y' ) THEN
        X_Return_Status := OKE_API.G_RET_STS_SUCCESS;
        RETURN;
      END IF;

      --
      -- Get Numbering Option from Document Type and Intent
      --
      OKE_NUMBER_SEQUENCES_PKG.Number_Option
      ( X_K_Type_Code
      , X_Buy_Or_Sell
      , 'HEADER'
      , l_num_mode
      , l_num_type );


      IF ( l_num_mode = 'MANUAL' ) THEN
        --
        -- Numbering Mode is MANUAL
        --
        -- Make sure number adheres to Numbering Type
        --
        IF ( l_num_type = 'NUMERIC' AND
             OKE_NUMBER_SEQUENCES_PKG.Value_Is_Numeric(X_K_Number) = 'N' ) THEN
          OKE_API.Set_Message( p_msg_name => 'OKE_NUMSEQ_INVALID_NUMERIC' );
          X_Return_Status := OKE_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

      ELSE
        --
        -- Numbering Mode is AUTOMATIC
        --
        X_K_Number := OKE_NUMBER_SEQUENCES_PKG.Next_Contract_Number
                      ( X_K_Type_Code , X_Buy_Or_Sell );

      END IF;

      X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( p_pkg_name => g_pkg_name
      , p_procedure_name => 'ASSIGN_DOC_NUMER'
      );
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;
    END Assign_Doc_Number;



  PROCEDURE create_contract_header(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_chr_rec		IN  oke_chr_pvt.chr_rec_type,
    p_chrv_rec          IN  okc_contract_pub.chrv_rec_type,
    x_chr_rec		OUT NOCOPY  oke_chr_pvt.chr_rec_type,
    x_chrv_rec          OUT NOCOPY  okc_contract_pub.chrv_rec_type) IS

    l_chr_rec		oke_chr_pvt.chr_rec_type;
    l_chrv_rec		okc_contract_pub.chrv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;




  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    l_chr_rec := p_chr_rec;
    l_chrv_rec := p_chrv_rec;

    --
    -- call procedure in complex API
    --
    -- First Assign Document Number if Numbering Option is Automatic
    --
    Assign_Doc_Number( X_K_Type_Code   => l_chr_rec.k_type_code
                     , X_Buy_Or_Sell   => l_chrv_rec.buy_or_sell
                     , X_Template_Flag => l_chrv_rec.template_yn
                     , X_K_Number      => l_chrv_rec.contract_number
                     , X_Return_Status => X_Return_Status
                     );

    IF X_Return_Status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF X_Return_Status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    --
    -- get default contract number modifier
    --

    If l_chrv_rec.contract_number_modifier is null or l_chrv_rec.contract_number_modifier = OKE_API.G_MISS_CHAR then
      IF l_chr_rec.boa_id is null or l_chr_rec.boa_id =  OKE_API.G_MISS_NUM THEN
        l_chrv_rec.contract_number_modifier
		:= l_chr_rec.k_type_code || '.'|| l_chrv_rec.buy_or_sell || '.';
      ELSE
        l_chrv_rec.contract_number_modifier
		:= l_chr_rec.k_type_code || '.'|| l_chrv_rec.buy_or_sell || '.' || l_chr_rec.boa_id;
      END IF;

    End If;

    --
    -- set okc context before API call
    --

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);
    OKC_CONTRACT_PUB.create_contract_header(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_chrv_rec		=> l_chrv_rec,
	 x_chrv_rec		=> x_chrv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;


    -- get id from OKC record

    l_chr_rec.K_HEADER_ID := x_chrv_rec.ID;

    -- get default contract number modifier
    --l_chrv_rec.contract_number_modifier := l_chr_rec.k_type_code || '.'|| l_chrv_rec.buy_or_sell || '.' || l_chr_rec.boa_id;


    -- call procedure in complex API
    OKE_CONTRACT_PVT.create_contract_header(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_chr_rec		=> l_chr_rec,
      x_chr_rec		=> x_chr_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END create_contract_header;

  PROCEDURE create_contract_header(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_chr_tbl		IN  oke_chr_pvt.chr_tbl_type,
    p_chrv_tbl          IN  okc_contract_pub.chrv_tbl_type,
    x_chr_tbl		OUT NOCOPY  oke_chr_pvt.chr_tbl_type,
    x_chrv_tbl          OUT NOCOPY  okc_contract_pub.chrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_chr_tbl   OKE_CHR_PVT.chr_tbl_type := p_chr_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKE_CONTRACT_PUB.create_contract_header(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
      			p_chr_rec		=> l_chr_tbl(i),
			p_chrv_rec		=> p_chrv_tbl(i),
      			x_chr_rec		=> x_chr_tbl(i),
			x_chrv_rec		=> x_chrv_tbl(i));

		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END create_contract_header;

  PROCEDURE update_contract_header(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_restricted_update	IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_chr_rec		IN oke_chr_pvt.chr_rec_type,
    p_chrv_rec          IN okc_contract_pub.chrv_rec_type,
    x_chr_rec		OUT NOCOPY oke_chr_pvt.chr_rec_type,
    x_chrv_rec          OUT NOCOPY okc_contract_pub.chrv_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    -- call procedure in complex API
    OKC_CONTRACT_PUB.update_contract_header(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_restricted_update	=> p_restricted_update,
	p_chrv_rec		=> p_chrv_rec,
	x_chrv_rec		=> x_chrv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call complex api

    OKE_CONTRACT_PVT.update_contract_header(
      	p_api_version	=> p_api_version,
      	p_init_msg_list	=> p_init_msg_list,
       	x_return_status => x_return_status,
      	x_msg_count     => x_msg_count,
      	x_msg_data      => x_msg_data,
      	p_chr_rec	=> p_chr_rec,
      	x_chr_rec	=> x_chr_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END update_contract_header;

  PROCEDURE update_contract_header(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_restricted_update	IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_chr_tbl		IN  oke_chr_pvt.chr_tbl_type,
    p_chrv_tbl          IN  okc_contract_pub.chrv_tbl_type,
    x_chr_tbl		OUT NOCOPY  oke_chr_pvt.chr_tbl_type,
    x_chrv_tbl          OUT NOCOPY  okc_contract_pub.chrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKE_CONTRACT_PUB.update_contract_header(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
    			p_restricted_update	=> p_restricted_update,
			p_chr_rec		=> p_chr_tbl(i),
			p_chrv_rec		=> p_chrv_tbl(i),
			x_chr_rec		=> x_chr_tbl(i),
			x_chrv_rec		=> x_chrv_tbl(i));


		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END update_contract_header;

  PROCEDURE delete_contract_header(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_chr_rec		IN oke_chr_pvt.chr_rec_type,
    p_chrv_rec          IN okc_contract_pub.chrv_rec_type) IS

    l_chr_rec		oke_chr_pvt.chr_rec_type;
    l_chrv_rec		okc_contract_pub.chrv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_chr_rec := p_chr_rec;
    l_chrv_rec := p_chrv_rec;

    -- call complex api

    OKE_CONTRACT_PVT.delete_contract_header(
      	p_api_version	=> p_api_version,
      	p_init_msg_list	=> p_init_msg_list,
       	x_return_status => x_return_status,
      	x_msg_count     => x_msg_count,
      	x_msg_data      => x_msg_data,
      	p_chr_rec	=> l_chr_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call procedure in complex API
    OKC_CONTRACT_PUB.delete_contract_header(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_chrv_rec	=> l_chrv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END delete_contract_header;

  PROCEDURE delete_contract_header(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_chr_tbl		IN  oke_chr_pvt.chr_tbl_type,
    p_chrv_tbl          IN  okc_contract_pub.chrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP

		-- call complex API

		OKE_CONTRACT_PVT.delete_contract_header(

      			p_api_version	=> p_api_version,
      			p_init_msg_list	=> p_init_msg_list,
       			x_return_status => x_return_status,
      			x_msg_count     => x_msg_count,
      			x_msg_data      => x_msg_data,
      			p_chr_rec	=> p_chr_tbl(i));

		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

		-- call procedure in public API for a record
		OKC_CONTRACT_PUB.delete_contract_header(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_chrv_rec	=> p_chrv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END delete_contract_header;

  PROCEDURE validate_contract_header(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_chr_rec		IN oke_chr_pvt.chr_rec_type,
    p_chrv_rec          IN okc_contract_pub.chrv_rec_type) IS

    l_chr_rec		oke_chr_pvt.chr_rec_type;
    l_chrv_rec		okc_contract_pub.chrv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call BEFORE user hook
    l_chr_rec := p_chr_rec;
    l_chrv_rec := p_chrv_rec;

    -- call procedure in complex API
    OKC_CONTRACT_PUB.validate_contract_header(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_chrv_rec	=> l_chrv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get id for OKE record

    l_chr_rec.K_HEADER_ID := l_chrv_rec.ID;

    -- call complex API
    OKE_CONTRACT_PVT.validate_contract_header(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_chr_rec	=> l_chr_rec);

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END validate_contract_header;

  PROCEDURE validate_contract_header(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_chr_tbl		IN oke_chr_pvt.chr_tbl_type,
    p_chrv_tbl          IN okc_contract_pub.chrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_HEADER';

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_chr_tbl	        oke_chr_pvt.chr_tbl_type := p_chr_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_CONTRACT_PUB.validate_contract_header(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_chrv_rec	=> p_chrv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

		l_chr_tbl(i).K_HEADER_ID := p_chrv_tbl(i).ID;

		--  call complex API
		OKE_CONTRACT_PVT.validate_contract_header(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_chr_rec	=> l_chr_tbl(i));

		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END validate_contract_header;

  PROCEDURE create_contract_line(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_restricted_update	IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_cle_rec		IN  oke_cle_pvt.cle_rec_type,
    p_clev_rec          IN  okc_contract_pub.clev_rec_type,
    x_cle_rec		OUT NOCOPY  oke_cle_pvt.cle_rec_type,
    x_clev_rec          OUT NOCOPY  okc_contract_pub.clev_rec_type) IS

    l_cle_rec		oke_cle_pvt.cle_rec_type;
    l_clev_rec		okc_contract_pub.clev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_LINE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_line_number       VARCHAR2(120);

	l_sts_code	OKC_ASSENTS.STS_CODE%TYPE;
	l_scs_code	OKC_ASSENTS.SCS_CODE%TYPE;
	l_return_value	VARCHAR2(1):='?';

  CURSOR c_assent IS
  SELECT allowed_yn
  FROM OKC_ASSENTS
  WHERE sts_code = l_sts_code
  AND scs_code = l_scs_code
  AND opn_code = 'UPDATE';

  Cursor l_chrv_csr Is
  SELECT sts_code, scs_code
  FROM OKC_K_HEADERS_B
  WHERE id = p_clev_rec.dnz_chr_id;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    l_cle_rec := p_cle_rec;
    l_clev_rec := p_clev_rec;

    -- get original line number

    l_line_number := p_clev_rec.line_number;

    -- call procedure in complex API

    -- removing p_restricted_update and adding circumvent around okc_assent

	Open l_chrv_csr;
	Fetch l_chrv_csr Into l_sts_code, l_scs_code;
	If l_chrv_csr%FOUND Then
	   Close l_chrv_csr;

	   Open C_assent;
	   Fetch C_assent INTO L_return_value;
	   Close C_assent;

	   If (l_return_value in ('N')) Then
            UPDATE OKC_ASSENTS SET ALLOWED_YN = 'Y'
	    WHERE sts_code = l_sts_code
  	    AND scs_code = l_scs_code
  	    AND opn_code = 'UPDATE';
	   End If;
	Else
	   Close l_chrv_csr;
	End If;

    OKC_CONTRACT_PUB.create_contract_line(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
--	p_restricted_update	=> p_restricted_update,
	p_clev_rec	=> l_clev_rec,
	x_clev_rec	=> x_clev_rec);


	If (l_return_value in ('N')) Then
	   UPDATE OKC_ASSENTS SET ALLOWED_YN = l_return_value
	   WHERE sts_code = l_sts_code
  	   AND scs_code = l_scs_code
  	   AND opn_code = 'UPDATE';
	End If;


    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get id from OKC record

    l_cle_rec.K_LINE_ID := x_clev_rec.ID;


    -- update the original line number instead of OKC generated line number

    UPDATE OKC_K_LINES_B
    SET line_number = l_line_number
    WHERE ID = l_cle_rec.K_LINE_ID;

    -- prepare the OUT NOCOPY /* file.sql.39 change */ okc rec to reflact the update
     -- x_clev_rec.line_number := l_line_number;

    -- call procedure in complex API
    OKE_CONTRACT_PVT.create_contract_line(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_cle_rec	=> l_cle_rec,
	x_cle_rec	=> x_cle_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;


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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END create_contract_line;

  PROCEDURE create_contract_line(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_restricted_update	IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_cle_tbl		IN  oke_cle_pvt.cle_tbl_type,
    p_clev_tbl          IN  okc_contract_pub.clev_tbl_type,
    x_cle_tbl		OUT NOCOPY  oke_cle_pvt.cle_tbl_type,
    x_clev_tbl          OUT NOCOPY  okc_contract_pub.clev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_LINE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_cle_tbl           oke_cle_pvt.cle_tbl_type;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKE_CONTRACT_PUB.create_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
    			p_restricted_update	=> p_restricted_update,
      			p_cle_rec		=> p_cle_tbl(i),
			p_clev_rec		=> p_clev_tbl(i),
      			x_cle_rec		=> x_cle_tbl(i),
			x_clev_rec		=> x_clev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END create_contract_line;

  PROCEDURE update_contract_line(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_restricted_update	IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_cle_rec		IN oke_cle_pvt.cle_rec_type,
    p_clev_rec          IN okc_contract_pub.clev_rec_type,
    x_cle_rec		OUT NOCOPY oke_cle_pvt.cle_rec_type,
    x_clev_rec          OUT NOCOPY okc_contract_pub.clev_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list


    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call procedure in complex API
    OKC_CONTRACT_PUB.update_contract_line(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_restricted_update	=> p_restricted_update,
	p_clev_rec		=> p_clev_rec,
	x_clev_rec		=> x_clev_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call complex api

    OKE_CONTRACT_PVT.update_contract_line(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_cle_rec		=> p_cle_rec,
	x_cle_rec		=> x_cle_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END update_contract_line;

  PROCEDURE update_contract_line(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_restricted_update	IN  VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_cle_tbl		IN  oke_cle_pvt.cle_tbl_type,
    p_clev_tbl		IN  okc_contract_pub.clev_tbl_type,
    x_cle_tbl		OUT NOCOPY  oke_cle_pvt.cle_tbl_type,
    x_clev_tbl		OUT NOCOPY  okc_contract_pub.clev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKE_CONTRACT_PUB.update_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list	        => p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
    			p_restricted_update	=> p_restricted_update,
			p_cle_rec		=> p_cle_tbl(i),
			p_clev_rec		=> p_clev_tbl(i),
			x_cle_rec		=> x_cle_tbl(i),
			x_clev_rec		=> x_clev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END update_contract_line;

  PROCEDURE delete_contract_line(

    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_cle_rec		IN  oke_cle_pvt.cle_rec_type,
    p_clev_rec		IN  okc_contract_pub.clev_rec_type) IS

    l_cle_rec		oke_cle_pvt.cle_rec_type;
    l_clev_rec		okc_contract_pub.clev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_cle_rec := p_cle_rec;
    l_clev_rec := p_clev_rec;

    -- call complex api

    OKE_CONTRACT_PVT.delete_contract_line(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_cle_rec	=> l_cle_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call procedure in complex API
    OKC_CONTRACT_PUB.delete_contract_line(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_clev_rec	=> l_clev_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END delete_contract_line;

  PROCEDURE delete_contract_line(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_cle_tbl		IN  oke_cle_pvt.cle_tbl_type,
    p_clev_tbl		IN  okc_contract_pub.clev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP

		-- call complex API

		OKE_CONTRACT_PVT.delete_contract_line(

			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_cle_rec	=> p_cle_tbl(i));

		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

		-- call procedure in public API for a record
		OKC_CONTRACT_PUB.delete_contract_line(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_clev_rec	=> p_clev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END delete_contract_line;

  PROCEDURE delete_contract_line(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_line_id		IN  NUMBER) IS
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';

  BEGIN

    OKE_CONTRACT_PVT.delete_contract_line(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_line_id	=> p_line_id);

    OKC_CONTRACT_PVT.delete_contract_line(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_line_id	=> p_line_id);

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END delete_contract_line;

  PROCEDURE validate_contract_line(

    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_cle_rec		IN  oke_cle_pvt.cle_rec_type,
    p_clev_rec		IN  okc_contract_pub.clev_rec_type) IS

    l_cle_rec		oke_cle_pvt.cle_rec_type;
    l_clev_rec		okc_contract_pub.clev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_LINE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call BEFORE user hook
    l_cle_rec := p_cle_rec;
    l_clev_rec := p_clev_rec;

    -- call procedure in complex API
    OKC_CONTRACT_PUB.validate_contract_line(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_clev_rec	=> l_clev_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get id for OKE record

    l_cle_rec.K_LINE_ID := l_clev_rec.ID;

    -- call complex API
    OKE_CONTRACT_PVT.validate_contract_line(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_cle_rec	=> l_cle_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END validate_contract_line;

  PROCEDURE validate_contract_line(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_cle_tbl		IN  oke_cle_pvt.cle_tbl_type,
    p_clev_tbl		IN  okc_contract_pub.clev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_LINE';

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_cle_tbl       oke_cle_pvt.cle_tbl_type := p_cle_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_CONTRACT_PUB.validate_contract_line(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_clev_rec	=> p_clev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

		l_cle_tbl(i).K_LINE_ID := p_clev_tbl(i).ID;

		--  call complex API
		OKE_CONTRACT_PVT.validate_contract_line(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_cle_rec	=> p_cle_tbl(i));

		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
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

  END validate_contract_line;

  -----------------------------------------------------------------------------
  -- deliverable section
  -----------------------------------------------------------------------------
  PROCEDURE create_deliverable(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_del_rec		IN  oke_deliverable_pvt.del_rec_type,

    x_del_rec		OUT NOCOPY  oke_deliverable_pvt.del_rec_type) IS

    l_del_rec		oke_deliverable_pvt.del_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_DELIVERABLE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_line_number       VARCHAR2(120);
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    l_del_rec := p_del_rec;

    -- call procedure in complex API
    OKE_CONTRACT_PVT.create_deliverable(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_del_rec	=> l_del_rec,
	x_del_rec	=> x_del_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END create_deliverable;

  PROCEDURE create_deliverable(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_del_tbl		IN  oke_deliverable_pvt.del_tbl_type,
    x_del_tbl		OUT NOCOPY  oke_deliverable_pvt.del_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_DELIVERABLE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_del_tbl           oke_deliverable_pvt.del_tbl_type;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_del_tbl.COUNT > 0) Then
	   i := p_del_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKE_CONTRACT_PUB.create_deliverable(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
      			p_del_rec	=> p_del_tbl(i),
      			x_del_rec	=> x_del_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_del_tbl.LAST);
		i := p_del_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END create_deliverable;

  PROCEDURE update_deliverable(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec			   IN oke_deliverable_pvt.del_rec_type,
    x_del_rec			   OUT NOCOPY oke_deliverable_pvt.del_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_DELIVERABLE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call complex api

    OKE_CONTRACT_PVT.update_deliverable(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_del_rec	=> p_del_rec,
	x_del_rec	=> x_del_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END update_deliverable;

  PROCEDURE update_deliverable(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_del_tbl		IN  oke_deliverable_pvt.del_tbl_type,
    x_del_tbl		OUT NOCOPY oke_deliverable_pvt.del_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_del_tbl.COUNT > 0) Then
	   i := p_del_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKE_CONTRACT_PUB.update_deliverable(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data,
			p_del_rec	=> p_del_tbl(i),
			x_del_rec	=> x_del_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_del_tbl.LAST);
		i := p_del_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END update_deliverable;

  PROCEDURE delete_deliverable(

    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_del_rec		IN  oke_deliverable_pvt.del_rec_type) IS

    l_del_rec		oke_deliverable_pvt.del_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_DELIVERABLE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_del_rec := p_del_rec;

    -- call procedure in complex API
    OKE_CONTRACT_PVT.delete_deliverable(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_del_rec	=> l_del_rec);

    -- check return status
    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END delete_deliverable;

  PROCEDURE delete_deliverable(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_del_tbl		IN  oke_deliverable_pvt.del_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    If (p_del_tbl.COUNT > 0) Then
	   i := p_del_tbl.FIRST;
	   LOOP

		-- call procedure in public API for a record
		OKE_CONTRACT_PUB.delete_deliverable(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_del_rec	=> p_del_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_del_tbl.LAST);
		i := p_del_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END delete_deliverable;

  PROCEDURE delete_deliverable(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_deliverable_id	IN  NUMBER) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_DELIVERABLE';
  BEGIN

    OKE_CONTRACT_PVT.delete_deliverable(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_deliverable_id	=> p_deliverable_id);

  EXCEPTION
    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(

			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END delete_deliverable;

  PROCEDURE validate_deliverable(

    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_del_rec		IN  oke_deliverable_pvt.del_rec_type) IS

    l_del_rec		oke_deliverable_pvt.del_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_DELIVERABLE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_del_rec := p_del_rec;

    -- call complex API
    OKE_CONTRACT_PVT.validate_deliverable(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_del_rec	=> l_del_rec);

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END validate_deliverable;

  PROCEDURE validate_deliverable(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_del_tbl		IN  oke_deliverable_pvt.del_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_DELIVERABLE';

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_del_tbl       oke_deliverable_pvt.del_tbl_type := p_del_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    If (p_del_tbl.COUNT > 0) Then
	   i := p_del_tbl.FIRST;
	   LOOP

		--  call complex API
		OKE_CONTRACT_PVT.validate_deliverable(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_del_rec	=> p_del_tbl(i));

		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_del_tbl.LAST);
		i := p_del_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END validate_deliverable;

  PROCEDURE lock_deliverable(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_del_rec		IN  oke_deliverable_pvt.del_rec_type) IS

    l_del_rec		oke_deliverable_pvt.del_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_DELIVERABLE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call BEFORE user hook
    l_del_rec := p_del_rec;

    -- call procedure in complex API
    OKE_CONTRACT_PVT.lock_deliverable(
	p_api_version	=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	p_del_rec	=> l_del_rec);

    -- check return status
    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END lock_deliverable;

  PROCEDURE lock_deliverable(
    p_api_version	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    p_del_tbl		IN  oke_deliverable_pvt.del_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_DELIVERABLE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    If (p_del_tbl.COUNT > 0) Then
	   i := p_del_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKE_CONTRACT_PVT.lock_deliverable(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_del_rec	=> p_del_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_del_tbl.LAST);
		i := p_del_tbl.NEXT(i);
	   END LOOP;
	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

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

  END lock_deliverable;

  PROCEDURE default_deliverable (
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_header_id			IN  NUMBER,
    p_first_default_flag	IN  VARCHAR2,
    x_del_tbl			OUT NOCOPY oke_deliverable_pvt.del_tbl_type) IS

    l_api_version CONSTANT NUMBER := 1;
    l_del_tbl		oke_deliverable_pvt.del_tbl_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DEFAULT_DELIVERABLE';

    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_buy_or_sell 	VARCHAR2(1);
    l_direction		VARCHAR2(3);
    l_org_id 		Number;

    cursor l_default_csr(p_id number) is
    select buy_or_sell from okc_k_headers_b
    where id = p_id;

    cursor l_csr(p_id NUMBER) is
    select l.k_line_id,
	l.line_number,
	l.project_id,
	l.inventory_item_id,
	l.line_description,
	l.delivery_date,
	l.status_code,
	l.start_date,
	l.end_date,
	k.priority_code,
	h.currency_code,
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
    and not exists (select 'x' from okc_k_lines_b s where s.cle_id = l.k_line_id)
    and exists (select 'x' from okc_assents a
		where a.opn_code = 'CREATE_DELV'
		and a.sts_code = l.status_code
	 	and a.scs_code = 'PROJECT'
		and a.allowed_yn = 'Y');

    cursor l_csr2(p_id NUMBER) is
    select l.k_line_id,
	l.line_number,
	l.project_id,
	l.inventory_item_id,
	l.line_description,
	l.delivery_date,
	l.status_code,
	l.start_date,
	l.end_date,
	k.priority_code,
	h.currency_code,
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
    and not exists (select 'x' from okc_k_lines_b s where s.cle_id = l.k_line_id)
    and not exists (select 'x' from oke_k_deliverables_b where k_line_id = l.k_line_id)
    and exists (select 'x' from okc_assents a
		where a.opn_code = 'CREATE_DELV'
		and a.sts_code = l.status_code
	 	and a.scs_code = 'PROJECT'
		and a.allowed_yn = 'Y');

    cursor item_csr(p_id number) is
    select object1_id2
    from okc_k_items_v
    where cle_id = p_id;

    cursor cust_csr(p_id Number) is
    select cust_account_id from oke_cust_site_uses_v
    where id1 = p_id;




    l_csr_rec l_csr%ROWTYPE;
    l_csr2_rec l_csr2%ROWTYPE;
    l_id number;
    i NUMBER;
    l_inventory_org_id NUMBER;
    l_ship_to_id number;
    l_ship_from_id number;

  PROCEDURE get_org(p_header_id number,
		p_line_id number,
		x_ship_to_id OUT NOCOPY NUMBER,
		x_ship_from_id OUT NOCOPY NUMBER) IS

    cursor party_csr1(p_id Number,p_code varchar2) is
    select object1_id1, object1_id2, jtot_object1_code
    from okc_k_party_roles_b
    where dnz_chr_id = p_header_id and cle_id = p_id
    and rle_code = p_code;

    cursor party_csr2(p_id Number,p_code varchar2) is
    select object1_id1, object1_id2, jtot_object1_code
    from okc_k_party_roles_b
    where dnz_chr_id = p_id and chr_id = p_id
    and rle_code = p_code;

    cursor line_party(p_code Varchar2) is
    select Max(a.level_sequence) from okc_ancestrys a
    where a.cle_id = p_line_id
    and exists(select 'x' from okc_k_party_roles_b b where b.cle_id = a.cle_id_ascendant and b.rle_code = p_code and object1_id1 is not null);

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
	    if l_object_code = 'OKX_VENDOR' then
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
	        if l_object_code = 'OKX_VENDOR' then
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
	          if l_object_code = 'OKX_VENDOR' then
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

  END;


  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    i := 1;

    -- default deliverable direction based on buy_or_sell
    open l_default_csr(p_header_id);
    fetch l_default_csr into l_buy_or_sell;
    close l_default_csr;

    if l_buy_or_sell = 'B' then
      l_direction := 'IN';
    else
      l_direction := 'OUT';
    end if;

     -- get inventory_org_id from header
     SELECT INV_ORGANIZATION_ID INTO l_inventory_org_id
     FROM OKC_K_HEADERS_B
     WHERE ID = P_HEADER_ID;
    IF p_first_default_flag = 'Y' then

    for l_csr_rec in l_csr(p_header_id)
	loop
	  -- get ship_from, ship_to from line/header
	  get_org(p_header_id, l_csr_rec.k_line_id, l_ship_to_id, l_ship_from_id);


	  if l_direction = 'IN' then

            l_del_tbl(i).ship_to_org_id := l_ship_to_id;

	  else
	    if l_buy_or_sell = 'S' then
	      l_del_tbl(i).ship_to_location_id := l_ship_to_id;
	      open cust_csr(l_ship_to_id);
	      fetch cust_csr into l_org_id;
	      close cust_csr;

	      l_del_tbl(i).ship_to_org_id := l_org_id;
	    else
	      l_del_tbl(i).ship_to_org_id := l_ship_to_id;
	    end if;


	  end if;
	  l_del_tbl(i).ship_from_org_id := l_ship_from_id;

	  --
	  -- default inventory org id if ship_to/ship_from org exists, bug # 1743406
	  --

          if l_direction = 'IN' then
	    if l_del_tbl(i).ship_to_org_id is not null and l_del_tbl(i).ship_to_org_id <> oke_api.g_miss_num then
	      l_del_tbl(i).inventory_org_id := l_del_tbl(i).ship_to_org_id;
	    else
	      l_del_tbl(i).inventory_org_id := l_inventory_org_id;
	    end if;
	  else
	    if l_del_tbl(i).ship_from_org_id is not null and l_del_tbl(i).ship_from_org_id <> oke_api.g_miss_num then
	      l_del_tbl(i).inventory_org_id := l_del_tbl(i).ship_from_org_id;
	    else
	      l_del_tbl(i).inventory_org_id := l_inventory_org_id;
	    end if;
	  end if;

	  -- l_del_tbl(i).inventory_org_id := l_inventory_org_id;
 	  l_del_tbl(i).k_line_id := l_csr_rec.k_line_id;

	  l_del_tbl(i).defaulted_flag := 'Y';
	  l_del_tbl(i).direction := l_direction;
	  l_del_tbl(i).k_header_id := p_header_id;
	  l_del_tbl(i).deliverable_num := l_csr_rec.line_number;
	  l_del_tbl(i).project_id := l_csr_rec.project_id;
          l_del_tbl(i).item_id := l_csr_rec.inventory_item_id;
	  l_del_tbl(i).description := l_csr_rec.line_description;
          l_del_tbl(i).delivery_date := l_csr_rec.delivery_date;
     	  l_del_tbl(i).status_code := l_csr_rec.status_code;
   	  l_del_tbl(i).start_date := l_csr_rec.start_date;
	  l_del_tbl(i).end_date := l_csr_rec.end_date;
	  l_del_tbl(i).priority_code := l_csr_rec.priority_code;
	  l_del_tbl(i).currency_code := l_csr_rec.currency_code;
	  l_del_tbl(i).unit_price := l_csr_rec.unit_price;
	  l_del_tbl(i).uom_code := l_csr_rec.uom_code;
	  l_del_tbl(i).quantity := l_csr_rec.line_quantity;
	  l_del_tbl(i).country_of_origin_code := l_csr_rec.country_of_origin_code;

	  l_del_tbl(i).subcontracted_flag := l_csr_rec.subcontracted_flag;
	  l_del_tbl(i).billable_flag := l_csr_rec.billable_flag;
	  l_del_tbl(i).drop_shipped_flag := l_csr_rec.drop_shipped_flag;
	  l_del_tbl(i).completed_flag := l_csr_rec.completed_flag;
	  l_del_tbl(i).shippable_flag := l_csr_rec.shippable_flag;
	  l_del_tbl(i).cfe_req_flag := l_csr_rec.cfe_flag;
	  l_del_tbl(i).inspection_req_flag := l_csr_rec.inspection_req_flag;
	  l_del_tbl(i).interim_rpt_req_flag := l_csr_rec.interim_rpt_req_flag;
	  l_del_tbl(i).customer_approval_req_flag := l_csr_rec.customer_approval_req_flag;
    	  l_del_tbl(i).as_of_date := l_csr_rec.as_of_date;
 	  l_del_tbl(i).date_of_first_submission := l_csr_rec.date_of_first_submission;
	  l_del_tbl(i).frequency := l_csr_rec.frequency;
	  l_del_tbl(i).data_item_subtitle := l_csr_rec.data_item_subtitle;
	  l_del_tbl(i).total_num_of_copies := l_csr_rec.copies_required;
	  l_del_tbl(i).cdrl_category := l_csr_rec.cdrl_category;
	  l_del_tbl(i).data_item_name := l_csr_rec.data_item_name;
	  l_del_tbl(i).export_flag := l_csr_rec.export_flag;
/*	  if l_del_tbl(i).item_id is not null then
	    open item_csr(l_csr_rec.k_line_id);
	    fetch item_csr into l_id;
	    close item_csr;
            l_del_tbl(i).inventory_org_id := l_id;
          end if; */


	  i := i + 1;

   	end loop;

   ELSE
    for l_csr2_rec in l_csr2(p_header_id)
	loop
	  -- get ship_from, ship_to from line/header
	  get_org(p_header_id, l_csr2_rec.k_line_id, l_ship_to_id, l_ship_from_id);

	  if l_direction = 'IN' then

            l_del_tbl(i).ship_to_org_id := l_ship_to_id;

	  else
	    if l_buy_or_sell = 'S' then
	      l_del_tbl(i).ship_to_location_id := l_ship_to_id;
	      open cust_csr(l_ship_to_id);
	      fetch cust_csr into l_org_id;
	      close cust_csr;
	      l_del_tbl(i).ship_to_org_id := l_org_id;
	    else
	      l_del_tbl(i).ship_to_org_id := l_ship_to_id;
	    end if;
	  end if;

	  l_del_tbl(i).ship_from_org_id := l_ship_from_id;

	  --
	  -- default inventory org id if ship_to/ship_from org exists, bug # 1743406
	  --
          if l_direction = 'IN' then
	    if l_del_tbl(i).ship_to_org_id is not null and l_del_tbl(i).ship_to_org_id <> oke_api.g_miss_num then
	      l_del_tbl(i).inventory_org_id := l_del_tbl(i).ship_to_org_id;
	    else
	      l_del_tbl(i).inventory_org_id := l_inventory_org_id;
	    end if;
	  else
	    if l_del_tbl(i).ship_from_org_id is not null and l_del_tbl(i).ship_from_org_id <> oke_api.g_miss_num then

	      l_del_tbl(i).inventory_org_id := l_del_tbl(i).ship_from_org_id;
	    else

	      l_del_tbl(i).inventory_org_id := l_inventory_org_id;
	    end if;
	  end if;

	  -- l_del_tbl(i).inventory_org_id := l_inventory_org_id;
 	  l_del_tbl(i).k_line_id := l_csr2_rec.k_line_id;

	  l_del_tbl(i).defaulted_flag := 'Y';
	  l_del_tbl(i).direction := l_direction;
	  l_del_tbl(i).k_header_id := p_header_id;
	  l_del_tbl(i).deliverable_num := l_csr2_rec.line_number;
	  l_del_tbl(i).project_id := l_csr2_rec.project_id;
          l_del_tbl(i).item_id := l_csr2_rec.inventory_item_id;
	  l_del_tbl(i).description := l_csr2_rec.line_description;
          l_del_tbl(i).delivery_date := l_csr2_rec.delivery_date;
     	  l_del_tbl(i).status_code := l_csr2_rec.status_code;
   	  l_del_tbl(i).start_date := l_csr2_rec.start_date;
	  l_del_tbl(i).end_date := l_csr2_rec.end_date;
	  l_del_tbl(i).priority_code := l_csr2_rec.priority_code;
	  l_del_tbl(i).currency_code := l_csr2_rec.currency_code;
	  l_del_tbl(i).unit_price := l_csr2_rec.unit_price;
	  l_del_tbl(i).uom_code := l_csr2_rec.uom_code;
	  l_del_tbl(i).quantity := l_csr2_rec.line_quantity;
	  l_del_tbl(i).country_of_origin_code := l_csr2_rec.country_of_origin_code;
	  l_del_tbl(i).subcontracted_flag := l_csr2_rec.subcontracted_flag;
	  l_del_tbl(i).billable_flag := l_csr2_rec.billable_flag;
	  l_del_tbl(i).drop_shipped_flag := l_csr2_rec.drop_shipped_flag;
	  l_del_tbl(i).completed_flag := l_csr2_rec.completed_flag;
	  l_del_tbl(i).shippable_flag := l_csr2_rec.shippable_flag;
	  l_del_tbl(i).cfe_req_flag := l_csr2_rec.cfe_flag;
	  l_del_tbl(i).inspection_req_flag := l_csr2_rec.inspection_req_flag;
	  l_del_tbl(i).interim_rpt_req_flag := l_csr2_rec.interim_rpt_req_flag;
	  l_del_tbl(i).customer_approval_req_flag := l_csr2_rec.customer_approval_req_flag;
    	  l_del_tbl(i).as_of_date := l_csr2_rec.as_of_date;
 	  l_del_tbl(i).date_of_first_submission := l_csr2_rec.date_of_first_submission;
	  l_del_tbl(i).frequency := l_csr2_rec.frequency;
	  l_del_tbl(i).data_item_subtitle := l_csr2_rec.data_item_subtitle;
	  l_del_tbl(i).total_num_of_copies := l_csr2_rec.copies_required;
	  l_del_tbl(i).cdrl_category := l_csr2_rec.cdrl_category;
	  l_del_tbl(i).data_item_name := l_csr2_rec.data_item_name;
	  l_del_tbl(i).export_flag := l_csr2_rec.export_flag;
/*	  if l_del_tbl(i).item_id is not null then
	    open item_csr(l_csr_rec.k_line_id);
	    fetch item_csr into l_id;
	    close item_csr;
            l_del_tbl(i).inventory_org_id := l_id;
          end if; */

	  i := i + 1;

   	end loop;
     END IF;



    -- insert into deliverable table
     If (l_del_tbl.COUNT > 0) Then

	-- call procedure in public API for a record
	OKE_CONTRACT_PUB.create_deliverable(
		p_api_version	=> p_api_version,
		p_init_msg_list	=> p_init_msg_list,
		x_return_status => x_return_status,
		x_msg_count     => x_msg_count,
		x_msg_data      => x_msg_data,
      		p_del_tbl	=> l_del_tbl,
      		x_del_tbl	=> x_del_tbl);

      If (x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
        raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKE_API.G_RET_STS_ERROR) then
        raise OKE_API.G_EXCEPTION_ERROR;
      End If;

      -- copy related entities to the deliverable
      commit;

    end if;
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
  end default_deliverable;

PROCEDURE Check_Delete_Contract(
	p_api_version       IN NUMBER,
	p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER,
	x_return_code	    OUT NOCOPY VARCHAR2) IS

        l_api_name	  CONSTANT VARCHAR2(30) := 'CHECK_DELETE_CONTRACT';
   	l_api_version	  CONSTANT NUMBER	  := 1.0;
   	l_return_status	  VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
	l_check           VARCHAR2(1);


	CURSOR check_opns IS
	SELECT 'X' FROM OKC_ASSENTS
	WHERE OPN_CODE ='DELETE'
	AND STS_CODE =
	(SELECT STS_CODE FROM OKC_K_HEADERS_B WHERE ID = P_CHR_ID)
	AND SCS_CODE = 'PROJECT'
	AND ALLOWED_YN = 'Y';

	CURSOR check_boa IS
	SELECT 'x'
	FROM OKE_K_HEADERS
	WHERE K_HEADER_ID = p_chr_id
	AND K_TYPE_CODE IN (SELECT K_TYPE_CODE FROM OKE_K_TYPES_B WHERE TYPE_CLASS_CODE='BOA')
	  AND K_HEADER_ID IN (SELECT BOA_ID FROM OKE_K_HEADERS);

	CURSOR check_sts IS
	SELECT 'x'
	FROM OKC_STATUSES_B ST, OKC_K_HEADERS_B KH
	WHERE KH.ID = p_chr_id
	AND ST.CODE = KH.STS_CODE
	AND ST.STE_CODE not in ( 'ENTERED','CANCELLED');

	CURSOR check_po IS
	SELECT 'x'
	FROM OKE_K_DELIVERABLES_B DV
	WHERE PO_REF_1 IS NOT NULL
	AND DV.K_HEADER_ID = p_chr_id;

	CURSOR check_mps IS
	SELECT 'x'
	FROM OKE_K_DELIVERABLES_B DV
	WHERE MPS_TRANSACTION_ID IS NOT NULL
	AND DV.K_HEADER_ID = p_chr_id;

	CURSOR check_wsh IS
	SELECT 'x'
	FROM OKE_K_DELIVERABLES_B DV
	WHERE SHIPPING_REQUEST_ID IS NOT NULL
	AND DV.K_HEADER_ID = p_chr_id;

	CURSOR check_funding IS
	SELECT 'x'
	FROM OKE_K_FUND_ALLOCATIONS FA, OKE_K_FUNDING_SOURCES FS
	WHERE FA.PA_FLAG = 'Y'
	AND FA.FUNDING_SOURCE_ID = FS.FUNDING_SOURCE_ID
	AND FS.OBJECT_ID = p_chr_id;



  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;
        l_check := '?';
	OPEN check_sts;
	FETCH check_sts INTO l_check;
	CLOSE check_sts;

	IF l_check = 'x' THEN
          X_Return_Status := OKE_API.G_RET_STS_ERROR;
 	  x_return_code := 'STS';
       	  raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	l_check := '?';
	OPEN check_opns;
	FETCH check_opns INTO l_check;
	CLOSE check_opns;

	IF l_check = '?' THEN
          X_Return_Status := OKE_API.G_RET_STS_ERROR;
	  x_return_code := 'OPN';
    	  raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	l_check := '?';
	OPEN check_boa;
	FETCH check_boa INTO l_check;
	CLOSE check_boa;

	IF l_check = 'x' THEN
          X_Return_Status := OKE_API.G_RET_STS_ERROR;
	  x_return_code := 'BOA';
	  raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	l_check := '?';
	OPEN check_po;
	FETCH check_po INTO l_check;
	CLOSE check_po;

	IF l_check = 'x' THEN
          X_Return_Status := OKE_API.G_RET_STS_ERROR;
 	  x_return_code := 'PO';
	  raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	l_check := '?';
	OPEN check_mps;
	FETCH check_mps INTO l_check;
	CLOSE check_mps;

	IF l_check = 'x' THEN
             X_Return_Status := OKE_API.G_RET_STS_ERROR;
             x_return_code := 'PLAN';
 	     raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	l_check := '?';
	OPEN check_wsh;
	FETCH check_wsh INTO l_check;
	CLOSE check_wsh;
	IF l_check = 'x' THEN
          X_Return_Status := OKE_API.G_RET_STS_ERROR;
	  x_return_code := 'SHIP';
	  raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	l_check := '?';
	OPEN check_funding;
	FETCH check_funding INTO l_check;
	CLOSE check_funding;

	IF l_check = 'x' THEN
        X_Return_Status := OKE_API.G_RET_STS_ERROR;
	    x_return_code := 'FUND';
  	    raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

       If OKC_CONTRACT_PVT.Is_Process_Active(p_chr_id)='Y' then
           X_Return_Status := OKE_API.G_RET_STS_ERROR;
           x_return_code := 'WFA';
	   raise OKE_API.G_EXCEPTION_ERROR;
       end if;
        x_return_status := l_return_status;

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

  END Check_Delete_Contract;





	PROCEDURE delete_contract (
	p_api_version       IN NUMBER,
	p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count        OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2,
	p_chr_id	        IN  NUMBER,
	p_pre_deletion_check_yn    IN VARCHAR2  DEFAULT 'Y') IS


    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_status VARCHAR2(1);
    l_check VARCHAR2(1);
    i number;

    l_return_code VARCHAR2(30);

	l_note_tbl	 	oke_note_pvt.note_tbl_type;
	l_form_tbl		oke_form_pvt.form_tbl_type;
	l_term_tbl		oke_term_pvt.term_tbl_type;
	l_article_rec		okc_k_article_pub.catv_rec_type;

	l_contact_tbl		okc_contract_party_pub.ctcv_tbl_type;
	l_party_tbl		okc_contract_party_pub.cplv_tbl_type;
        l_deliverable_tbl	OKE_DELIVERABLE_PVT.del_tbl_type;


	l_item_tbl 		OKC_CONTRACT_ITEM_PUB.cimv_tbl_type;
	l_item_out_tbl		OKC_CONTRACT_ITEM_PUB.cimv_tbl_type;

	l_cle_tbl               OKE_CLE_PVT.cle_tbl_type;
        l_chr_rec               OKE_CHR_PVT.chr_rec_type;
	l_clev_tbl		OKC_CONTRACT_PVT.clev_tbl_type;
	l_chrv_rec		OKC_CONTRACT_PVT.chrv_rec_type;


	l_doc_id 	NUMBER;
	l_doc_type	VARCHAR2(30);

	cursor c_cle is
	select id from okc_k_lines_b
	where dnz_chr_id = p_chr_id;

	cursor c_item is
	select id
	from okc_k_items
	where dnz_chr_id = p_chr_id;

	cursor c_note is
	select standard_notes_id from oke_k_standard_notes_b
	where k_header_id = p_chr_id;


	cursor c_form is
	select print_form_code,k_header_id,k_line_id
	from oke_k_print_forms
	where k_header_id = p_chr_id;

	cursor c_article is
	select id,object_version_number from okc_k_articles_b
	where dnz_chr_id = p_chr_id;

	cursor c_term is
	select term_code,k_header_id,k_line_id, term_value_pk1, term_value_pk2
	from oke_k_terms
	where k_header_id = p_chr_id;

	cursor c_contact is
	select id from okc_contacts
	where dnz_chr_id = p_chr_id;

	cursor c_party is
	select id from okc_k_party_roles_b
	where dnz_chr_id = p_chr_id;

	cursor c_alloc is
	select fund_allocation_id
	from oke_k_fund_allocations
	where object_id = p_chr_id;


	cursor c_fund is
	select funding_source_id
	from oke_k_funding_sources
	where object_id = p_chr_id;

	cursor c_source is
	select funding_source_id
	from oke_k_funding_sources
	where object_id = p_chr_id
	and object_type = 'OKE_K_HEADER';

	cursor c_del is
	select deliverable_id
	from oke_k_deliverables_b
	where k_header_id = p_chr_id;


  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    IF p_pre_deletion_check_yn = 'Y' THEN
	Check_Delete_Contract(
	p_api_version => l_api_version,
	p_init_msg_list => p_init_msg_list,
	x_return_status  =>   l_check,
	x_msg_count      =>   x_msg_count,
	x_msg_data       =>   x_msg_data,
	p_chr_id    =>      p_chr_id,
	x_return_code => l_return_code );

     If (l_check = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_check = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;

    END IF;


    i:=1;
    for c in c_note
    loop
  	l_note_tbl(i).standard_notes_id := c.standard_notes_id;
	i:= i+1;
    end loop;
	OKE_STANDARD_NOTES_PUB.delete_standard_note(
	    p_api_version           => l_api_version,
	    p_init_msg_list         => OKE_API.G_FALSE,
	    x_return_status         => l_status,
	    x_msg_count             => x_msg_count,
	    x_msg_data              => x_msg_data,
	    p_note_tbl		    => l_note_tbl);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;



    i:=1;
    for c in c_form
    loop
  	l_form_tbl(i).print_form_code := c.print_form_code;
  	l_form_tbl(i).k_header_id := c.k_header_id;
  	l_form_tbl(i).k_line_id := c.k_line_id;
	i:= i+1;
    end loop;

	  OKE_K_PRINT_FORMS_PUB.delete_print_form(
	    p_api_version                => l_api_version,
	    p_init_msg_list              => OKE_API.G_FALSE,
	    x_return_status              => l_status,
	    x_msg_count                  => x_msg_count,
	    x_msg_data                   => x_msg_data,
	    p_form_tbl			 => l_form_tbl);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;




OKC_TERMS_UTIL_GRP.Get_contract_document_type_id(
	    p_api_version                 => 1,
	    p_init_msg_list               => FND_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	    p_chr_id			  => p_chr_id,
	    x_doc_id			  => l_doc_id,
	    x_doc_type			  => l_doc_type);


     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;


OKC_TERMS_UTIL_GRP.delete_doc(
	    p_api_version                 => 1,
	    p_init_msg_list               => FND_API.G_FALSE,
	    p_commit			  => FND_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_data                    => x_msg_data,
	    x_msg_count                   => x_msg_count,
	    p_validate_commit		  => FND_API.G_FALSE,
	    p_validation_string		  => NULL,
	    p_doc_type			  => l_doc_type,
	    p_doc_id			  => l_doc_id);




     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;




    i:=1;
    for c in c_term
    loop
      l_term_tbl(i).term_code := c.term_code;
      l_term_tbl(i).k_header_id := c.k_header_id;
      l_term_tbl(i).k_line_id := c.k_line_id;
      l_term_tbl(i).term_value_pk1 := c.term_value_pk1;
      l_term_tbl(i).term_value_pk2 := c.term_value_pk2;
      i:= i+1;
    end loop;

	  OKE_TERMS_PUB.delete_term(
	    p_api_version                => l_api_version,
	    p_init_msg_list              => OKE_API.G_FALSE,
	    x_return_status              => l_status,
	    x_msg_count                  => x_msg_count,
	    x_msg_data                   => x_msg_data,
	    p_term_tbl			 => l_term_tbl);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;




    i:=1;
    for c in c_contact
    loop
  	l_contact_tbl(i).id := c.id;
	i:= i+1;
    end loop;

	OKC_CONTRACT_PARTY_PUB.delete_contact(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKC_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	    p_ctcv_tbl		          => l_contact_tbl);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;




    i:=1;
    for c in c_party
    loop
  	l_party_tbl(i).id := c.id;
	i:= i+1;
    end loop;

	OKC_CONTRACT_PARTY_PUB.delete_k_party_role(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKC_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	    p_cplv_tbl		          => l_party_tbl);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;




	OKE_CONTRACT_PVT.delete_minor_entities (
		p_header_id		=> p_chr_id,
		x_return_status 	=> l_status);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;





    for c in c_alloc

    loop
	OKE_FUNDING_PUB.delete_allocation (
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKE_API.G_FALSE,
	    p_commit			  => OKE_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	 p_fund_allocation_id 		  => c.fund_allocation_id  );

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;


    end loop;


    for c in c_fund
    loop
	OKE_FUNDING_PUB.delete_funding(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKE_API.G_FALSE,
	    p_commit			  => OKE_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	 p_funding_source_id		  => c.funding_source_id);




     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;


    end loop;


   i := 1;
   for c in c_del
   loop
     l_deliverable_tbl(i).deliverable_id := c.deliverable_id;
     i:= i+1;
   end loop;

	OKE_DELIVERABLE_PVT.delete_row(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKE_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	    p_del_tbl                     => l_deliverable_tbl);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;



   i:= 1;
   for c in c_item
   loop
	l_item_tbl(i).id := c.id;
	i:=i+1;
   end loop;

	OKC_CONTRACT_ITEM_PUB.delete_contract_item(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKC_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	 p_cimv_tbl			  => l_item_tbl);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;





   i:=1;
   for c in c_cle
   loop
	l_cle_tbl(i).k_line_id := c.id;
	l_clev_tbl(i).id := c.id;
	i:= i+1;
   end loop;


	OKE_CLE_PVT.delete_row(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKE_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	    p_cle_tbl                     => l_cle_tbl);


     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;



	OKC_CONTRACT_PVT.delete_contract_line(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKC_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	    p_clev_tbl	         	  => l_clev_tbl);

     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;



     l_chr_rec.k_header_id := p_chr_id;
     l_chrv_rec.id := p_chr_id;


	OKE_CHR_PVT.delete_row(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKE_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	  p_chr_rec   			  => l_chr_rec);

    If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;



	OKE_CONTRACT_PVT.delete_version_records (
		p_api_version   => l_api_version,
		p_header_id	=> p_chr_id,
		x_return_status => l_status,
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);



     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;


	OKC_CONTRACT_PVT.delete_contract_header(
	    p_api_version                 => l_api_version,
	    p_init_msg_list               => OKC_API.G_FALSE,
	    x_return_status               => l_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	    p_chrv_rec		          => l_chrv_rec);



     If (l_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (l_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
     End If;




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

  END Delete_Contract;





END OKE_CONTRACT_PUB;

/
