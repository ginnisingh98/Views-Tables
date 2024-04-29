--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOVDTEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOVDTEMPLATES_PUB" AS
/* $Header: OKLPSVTB.pls 115.4 2004/04/13 11:22:45 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_OVD_RUL_TMLS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_ovtv_rec			  IN ovtv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_ovtv_rec			  OUT NOCOPY ovtv_rec_type) IS
    l_ovtv_rec                        ovtv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
	l_no_data_found					  BOOLEAN;
  BEGIN

  	l_ovtv_rec := p_ovtv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

    okl_setupovdtemplates_pvt.get_rec(p_ovtv_rec      => l_ovtv_rec,
								      x_return_status => l_return_status,
								      x_no_data_found => l_no_data_found,
								      x_ovtv_rec	  => x_ovtv_rec);

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
  -- PROCEDURE insert_ovdtemplates
  -- Public wrapper for insert_ovdtemplates process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_ovdtemplates(p_api_version      IN  NUMBER,
                                p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	    x_return_status    OUT NOCOPY VARCHAR2,
                        	    x_msg_count        OUT NOCOPY NUMBER,
                        	    x_msg_data         OUT NOCOPY VARCHAR2,
							    p_optv_rec		   IN  optv_rec_type,
                                p_ovev_rec         IN  ovev_rec_type,
                                p_ovdv_rec         IN  ovdv_rec_type,
                        	    p_ovtv_rec         IN  ovtv_rec_type,
                        	    x_ovtv_rec         OUT NOCOPY ovtv_rec_type) IS
	l_optv_rec						  optv_rec_type;
	l_ovev_rec						  ovev_rec_type;
    l_ovdv_rec                        ovdv_rec_type;
    l_ovtv_rec                        ovtv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_ovdtemplates';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_ovdtemplates;

    l_optv_rec := p_optv_rec;
    l_ovev_rec := p_ovev_rec;
    l_ovdv_rec := p_ovdv_rec;
    l_ovtv_rec := p_ovtv_rec;



	-- call process api to insert formula operands
    okl_setupovdtemplates_pvt.insert_ovdtemplates(p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                              			          x_return_status => l_return_status,
                              			          x_msg_count     => x_msg_count,
                              			          x_msg_data      => x_msg_data,
                              			          p_optv_rec      => l_optv_rec,
                                                  p_ovev_rec      => l_ovev_rec,
                                                  p_ovdv_rec      => l_ovdv_rec,
                              			          p_ovtv_rec      => l_ovtv_rec,
                              			          x_ovtv_rec      => x_ovtv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_ovtv_rec := x_ovtv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_ovdtemplates;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_ovdtemplates;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPOVDTEMPLATES_PUB','insert_ovdtemplates');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_ovdtemplates;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_ovdtemplates
  -- Public wrapper for delete_ovdtemplates process api
  ---------------------------------------------------------------------------
  PROCEDURE delete_ovdtemplates(p_api_version      IN  NUMBER,
                                p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	    x_return_status    OUT NOCOPY VARCHAR2,
                        	    x_msg_count        OUT NOCOPY NUMBER,
                        	    x_msg_data         OUT NOCOPY VARCHAR2,
  							    p_optv_rec		   IN  optv_rec_type,
                                p_ovev_rec         IN  ovev_rec_type,
                                p_ovdv_rec         IN  ovdv_rec_type,
                      		    p_ovtv_tbl         IN  ovtv_tbl_type) IS
	l_optv_rec						  optv_rec_type;
    l_ovev_rec                        ovev_rec_type;
    l_ovdv_rec                        ovdv_rec_type;
    l_ovtv_tbl                        ovtv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_ovdtemplates';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_delete_ovdtemplates;

    l_optv_rec := p_optv_rec;
    l_ovev_rec := p_ovev_rec;
    l_ovdv_rec := p_ovdv_rec;
    l_ovtv_tbl := p_ovtv_tbl;



	-- call process api to delete formula operands
    okl_setupovdtemplates_pvt.delete_ovdtemplates(p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                              			  	      x_return_status => l_return_status,
                               			  	      x_msg_count     => x_msg_count,
                               			  	      x_msg_data      => x_msg_data,
                              			  	      p_optv_rec      => l_optv_rec,
                                                  p_ovev_rec      => l_ovev_rec,
                                                  p_ovdv_rec      => l_ovdv_rec,
                              			  	      p_ovtv_tbl      => l_ovtv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_delete_ovdtemplates;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_delete_ovdtemplates;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPOVDTEMPLATES_PUB','delete_ovdtemplates');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END delete_ovdtemplates;

END OKL_SETUPOVDTEMPLATES_PUB;

/
