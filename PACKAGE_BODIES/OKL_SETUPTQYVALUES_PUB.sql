--------------------------------------------------------
--  DDL for Package Body OKL_SETUPTQYVALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPTQYVALUES_PUB" AS
/* $Header: OKLPSEVB.pls 115.5 2004/04/13 11:05:24 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_FORMULAE_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_ptvv_rec			  IN ptvv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_ptvv_rec			  OUT NOCOPY ptvv_rec_type) IS
    l_ptvv_rec                        ptvv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_no_data_found					  BOOLEAN;
  BEGIN

  	l_ptvv_rec := p_ptvv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

    OKL_SETUPTQYVALUES_PVT.get_rec(p_ptvv_rec      => l_ptvv_rec,
								  x_return_status => l_return_status,
								  x_no_data_found => l_no_data_found,
								  x_ptvv_rec	  => x_ptvv_rec);

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
  -- PROCEDURE insert_tqyvalues
  -- Public wrapper for insert_tqyvalues process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_tqyvalues(p_api_version                  IN  NUMBER,
  		                    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
						    x_return_status                OUT NOCOPY VARCHAR2,
							x_msg_count                    OUT NOCOPY NUMBER,
							x_msg_data                     OUT NOCOPY VARCHAR2,
							p_ptqv_rec                     IN  ptqv_rec_type,
							p_ptvv_rec                     IN  ptvv_rec_type,
							x_ptvv_rec                     OUT NOCOPY ptvv_rec_type
							) IS
    l_ptvv_rec                        ptvv_rec_type;
    l_ptqv_rec                        ptqv_rec_type;
	l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_tqyvalues';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_tqyvalues;
    l_ptvv_rec := p_ptvv_rec;
	l_ptqv_rec := p_ptqv_rec;



	-- call process api to insert formulae
    okl_setuptqyvalues_pvt.insert_tqyvalues(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
  									      p_ptqv_rec      => l_ptqv_rec,
										  p_ptvv_rec      => l_ptvv_rec,
										  x_ptvv_rec      => x_ptvv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_ptvv_rec := x_ptvv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_tqyvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_tqyvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPTQYVALUES_PUB','insert_tqyvalues');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_tqyvalues;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_tqyvalues
  -- Public wrapper for update_tqyvalues process api
  ---------------------------------------------------------------------------
  PROCEDURE update_tqyvalues(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
							p_ptqv_rec         IN  ptqv_rec_type,
                        	p_ptvv_rec         IN  ptvv_rec_type,
                        	x_ptvv_rec         OUT NOCOPY ptvv_rec_type) IS
    l_ptvv_rec                        ptvv_rec_type;
    l_ptqv_rec                        ptqv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_tqyvalues';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_tqyvalues;
    l_ptvv_rec := p_ptvv_rec;
    l_ptqv_rec := p_ptqv_rec;



	-- call process api to update formulae
    okl_setuptqyvalues_pvt.update_tqyvalues(p_api_version  => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
 									      p_ptqv_rec      => l_ptqv_rec,
                              			  p_ptvv_rec      => l_ptvv_rec,
                              			  x_ptvv_rec      => x_ptvv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_ptvv_rec := x_ptvv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_tqyvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_tqyvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPTQYVALUES_PUB','update_tqyvalues');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_tqyvalues;

END OKL_SETUPTQYVALUES_PUB;

/
