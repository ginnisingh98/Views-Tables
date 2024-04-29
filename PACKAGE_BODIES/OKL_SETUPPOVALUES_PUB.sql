--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPOVALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPOVALUES_PUB" AS
/* $Header: OKLPSDVB.pls 115.5 2004/04/13 11:05:13 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: okl_pdt_opt_vals_v
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_povv_rec			  IN povv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_povv_rec			  OUT NOCOPY povv_rec_type) IS
    l_povv_rec                        povv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_no_data_found					  BOOLEAN;
  BEGIN

  	l_povv_rec := p_povv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

    okl_SETUPPOVALUES_pvt.get_rec(p_povv_rec      => l_povv_rec,
								  x_return_status => l_return_status,
								  x_no_data_found => l_no_data_found,
								  x_povv_rec	  => x_povv_rec);

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
  -- PROCEDURE insert_povalues
  -- Public wrapper for insert_povalues process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_povalues(p_api_version        IN  NUMBER,
  						    p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
							x_return_status      OUT NOCOPY VARCHAR2,
							x_msg_count          OUT NOCOPY NUMBER,
							x_msg_data           OUT NOCOPY VARCHAR2,
							p_pdtv_rec           IN  pdtv_rec_type,
							p_optv_rec           IN  optv_rec_type,
							p_povv_rec           IN  povv_rec_type,
							x_povv_rec           OUT NOCOPY povv_rec_type
							) IS
    l_povv_rec                        povv_rec_type;
	l_pdtv_rec                        pdtv_rec_type;
	l_optv_rec                        optv_rec_type;

	l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_povalues';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_povalues;
    l_povv_rec := p_povv_rec;
    l_pdtv_rec := p_pdtv_rec;
    l_optv_rec := p_optv_rec;



	-- call process api to insert Product Option Values
    okl_SETUPPOVALUES_pvt.insert_povalues(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_povv_rec      => l_povv_rec,
                              			  x_povv_rec      => x_povv_rec,
			  							  p_pdtv_rec      => l_pdtv_rec,
										  p_optv_rec      => l_optv_rec
										  );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_povv_rec := x_povv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_povalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_povalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPOVALUES_PUB','insert_povalues');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_povalues;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_povalues
  -- Public wrapper for delete_povalues process api
  ---------------------------------------------------------------------------
  PROCEDURE delete_povalues(p_api_version      IN NUMBER,
						    p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
							x_return_status    OUT NOCOPY VARCHAR2,
							x_msg_count        OUT NOCOPY NUMBER,
							x_msg_data         OUT NOCOPY VARCHAR2,
							p_pdtv_rec           IN  pdtv_rec_type,
							p_optv_rec           IN  optv_rec_type,
							P_povv_tbl         IN povv_tbl_type) IS
    l_povv_tbl                        povv_tbl_type;
	l_pdtv_rec                        pdtv_rec_type;
	l_optv_rec                        optv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_povalues';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_delete_povalues;
    l_povv_tbl := p_povv_tbl;
    l_pdtv_rec := p_pdtv_rec;
    l_optv_rec := p_optv_rec;



	-- call process api to delete_povalues
    okl_SETUPPOVALUES_pvt.delete_povalues(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
  									      p_pdtv_rec      => l_pdtv_rec,
										  p_optv_rec      => l_optv_rec,
                              			  p_povv_tbl      => l_povv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_delete_povalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_delete_povalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPOVALUES_PUB','delete_povalues');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END delete_povalues;

END OKL_SETUPPOVALUES_PUB;

/
