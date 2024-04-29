--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPSTYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPSTYPES_PUB" AS
/* $Header: OKLPSPSB.pls 115.6 2004/04/13 11:19:51 rnaik noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PROD_STRM_TYPES_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_psyv_rec			  IN psyv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_psyv_rec			  OUT NOCOPY psyv_rec_type) IS
    l_psyv_rec                        psyv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_no_data_found					  BOOLEAN;
  BEGIN

  	l_psyv_rec := p_psyv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

    okl_setuppstypes_pvt.get_rec(p_psyv_rec      => l_psyv_rec,
								  x_return_status => l_return_status,
								  x_no_data_found => l_no_data_found,
								  x_psyv_rec	  => x_psyv_rec);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  x_no_data_found := FALSE;
	  FND_MESSAGE.set_name(application	=> G_APP_NAME,
	  					   name			=> G_UNEXPECTED_ERROR);
	  x_msg_data := FND_MESSAGE.get;
  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_pstypes
  -- Public wrapper for insert_pstypes process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_pstypes(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
							p_pdtv_rec         IN  pdtv_rec_type,
							p_psyv_rec         IN  psyv_rec_type,
                        	x_psyv_rec         OUT NOCOPY psyv_rec_type
						    ) IS
    l_psyv_rec                        psyv_rec_type;
    l_pdtv_rec                        pdtv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_pstypes';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_pstypes;
    l_psyv_rec := p_psyv_rec;
    l_pdtv_rec := p_pdtv_rec;



	-- call process api to insert psyalues
    okl_setuppstypes_pvt.insert_pstypes(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_psyv_rec      => l_psyv_rec,
                              			  x_psyv_rec      => x_psyv_rec,
										  p_pdtv_rec      => l_pdtv_rec
										  );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_psyv_rec := x_psyv_rec;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_pstypes;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_pstypes;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPSTYPES_PUB','insert_pstypes');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_pstypes;

   ---------------------------------------------------------------------------
  -- PROCEDURE update_pstypes
  -- Public wrapper for update_pstypes process api
  ---------------------------------------------------------------------------
  PROCEDURE update_pstypes(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
							p_pdtv_rec         IN  pdtv_rec_type,
							p_psyv_rec         IN  psyv_rec_type,
                        	x_psyv_rec         OUT NOCOPY psyv_rec_type
						    ) IS
    l_psyv_rec                        psyv_rec_type;
    l_pdtv_rec                        pdtv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_pstypes';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_pstypes;
    l_psyv_rec := p_psyv_rec;
    l_pdtv_rec := p_pdtv_rec;



	-- call process api to update psyalues
    okl_setuppstypes_pvt.update_pstypes(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_psyv_rec      => l_psyv_rec,
                              			  x_psyv_rec      => x_psyv_rec,
										  p_pdtv_rec      => l_pdtv_rec
										  );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_psyv_rec := x_psyv_rec;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_pstypes;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_pstypes;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPSTYPES_PUB','update_pstypes');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_pstypes;


END OKL_SETUPPSTYPES_PUB;

/
