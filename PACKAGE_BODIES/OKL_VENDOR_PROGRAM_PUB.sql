--------------------------------------------------------
--  DDL for Package Body OKL_VENDOR_PROGRAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VENDOR_PROGRAM_PUB" AS
/*$Header: OKLPPRMB.pls 120.2 2005/10/29 02:14:47 manumanu noship $*/


  ---------------------------------------------------------------------------
  -- PROCEDURE extend_contract
  -- Public wrapper for extend contract process api
  ---------------------------------------------------------------------------

  PROCEDURE create_program(p_api_version             IN               NUMBER,
                          p_init_msg_list            IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          x_return_status            OUT              NOCOPY VARCHAR2,
                          x_msg_count                OUT              NOCOPY NUMBER,
                          x_msg_data                 OUT              NOCOPY VARCHAR2,
                          p_hdr_rec                  IN               program_header_rec_type,
			  p_parent_agreement_number  IN               VARCHAR2 DEFAULT NULL,
                          x_header_rec               OUT NOCOPY              chrv_rec_type,
                          x_k_header_rec             OUT NOCOPY              khrv_rec_type) IS


    l_hdr_rec                     program_header_rec_type;
    l_data                        VARCHAR2(100);
    l_api_name                    CONSTANT VARCHAR2(30)  := 'create_program';
    l_count                       NUMBER ;
    l_return_status               VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_hdr_rec := p_hdr_rec;



	-- call process api to extend contract

    OKL_VENDOR_PROGRAM_PVT.create_program(p_api_version     => p_api_version,
                                          p_init_msg_list   => p_init_msg_list,
              			          x_return_status   => l_return_status,
               			          x_msg_count       => x_msg_count,
                              	          x_msg_data        => x_msg_data,
                              	          p_hdr_rec         => l_hdr_rec,
                                          p_parent_agreement_number => p_parent_agreement_number,
                                          x_header_rec      => x_header_rec,
                                          x_k_header_rec      => x_k_header_rec);


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  		        p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  		        p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_VENDOR_PROGRAM_PUB','create_program');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  		        p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END create_program;


PROCEDURE update_program(p_api_version             IN               NUMBER,
                         p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status           OUT              NOCOPY VARCHAR2,
                         x_msg_count               OUT              NOCOPY NUMBER,
                         x_msg_data                OUT              NOCOPY VARCHAR2,
                         p_hdr_rec                 IN               program_header_rec_type,
			 p_program_id              IN               NUMBER,
                         p_parent_agreement_id     IN               okc_k_headers_v.ID%TYPE DEFAULT NULL
                        ) IS


    l_hdr_rec                     program_header_rec_type;
    l_data                        VARCHAR2(100);
    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_program';
    l_count                       NUMBER ;
    l_return_status               VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_hdr_rec := p_hdr_rec;



	-- call process api to update contract

    OKL_VENDOR_PROGRAM_Pvt.update_program(p_api_version         => p_api_version,
                                          p_init_msg_list       => p_init_msg_list,
              			          x_return_status       => l_return_status,
               			          x_msg_count           => x_msg_count,
                              	          x_msg_data            => x_msg_data,
                              	          p_hdr_rec             => l_hdr_rec,
                                          p_program_id          => p_program_id,
                                          p_parent_agreement_id => p_parent_agreement_id
                                          );


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  				  p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_VENDOR_PROGRAM_PUB','update_program');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  		        p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_program;



  FUNCTION Is_Process_Active(p_chr_id IN NUMBER) RETURN VARCHAR2 Is

	l_wf_name       OKC_PROCESS_DEFS_B.WF_NAME%TYPE;
	l_item_key	OKC_K_PROCESSES.PROCESS_ID%TYPE;
	l_return_code	VARCHAR2(1) := 'N';
	l_end_date	DATE;

	-- cursor for item type and item key
	CURSOR l_pdfv_csr IS
		SELECT pdfv.wf_name, cpsv.process_id
		FROM okc_process_defs_b pdfv,
			okc_k_processes cpsv
		WHERE pdfv.id = cpsv.pdf_id
		  AND cpsv.chr_id = p_chr_id;

	-- cursor to check active process
	CURSOR l_wfitems_csr IS
		SELECT end_date
	 	FROM wf_items
	 	WHERE item_type = l_wf_name
		  AND item_key = l_item_key;
  BEGIN

    -- get item type and item key
    OPEN l_pdfv_csr;
    FETCH l_pdfv_csr INTO l_wf_name, l_item_key;
    IF (l_pdfv_csr%NOTFOUND OR l_wf_name IS NULL or l_item_key IS NULL) Then
       CLOSE l_pdfv_csr;
	  RETURN l_return_code;
    END IF;
    CLOSE l_pdfv_csr;

    -- check whether process is active or not
    OPEN l_wfitems_csr;
    FETCH l_wfitems_csr into l_end_date;
    IF (l_wfitems_csr%NOTFOUND OR l_end_date IS NOT NULL) Then
	  l_return_code := 'N';
    ELSE
	   l_return_code := 'Y';
    END IF;
    CLOSE l_wfitems_csr;

    RETURN l_return_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 RETURN (l_return_code);
  END Is_Process_Active;



END OKL_VENDOR_PROGRAM_PUB;

/
