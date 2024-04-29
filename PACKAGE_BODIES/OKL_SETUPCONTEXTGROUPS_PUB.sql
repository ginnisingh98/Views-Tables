--------------------------------------------------------
--  DDL for Package Body OKL_SETUPCONTEXTGROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPCONTEXTGROUPS_PUB" AS
/* $Header: OKLPSCGB.pls 115.4 2004/04/13 11:04:42 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_CONTEXT_GROUPS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_cgrv_rec			  IN cgrv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_cgrv_rec			  OUT NOCOPY cgrv_rec_type) IS
    l_cgrv_rec                        cgrv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
	l_no_data_found					  BOOLEAN;
  BEGIN

  	l_cgrv_rec := p_cgrv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

    okl_setupcontextgroups_pvt.get_rec(p_cgrv_rec      => l_cgrv_rec,
								       x_return_status => l_return_status,
								  	   x_no_data_found => l_no_data_found,
								  	   x_cgrv_rec	   => x_cgrv_rec);

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
  -- PROCEDURE insert_contextgroups
  -- Public wrapper for insert_contextgroups process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_contextgroups(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
                        		 p_cgrv_rec         IN  cgrv_rec_type,
                        		 x_cgrv_rec         OUT NOCOPY cgrv_rec_type) IS
    l_cgrv_rec                        cgrv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_contextgroups';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_contextgroups;
    l_cgrv_rec := p_cgrv_rec;



	-- call process api to insert context groups
    okl_setupcontextgroups_pvt.insert_contextgroups(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_cgrv_rec      => l_cgrv_rec,
                              			  			x_cgrv_rec      => x_cgrv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_cgrv_rec := x_cgrv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_contextgroups;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_contextgroups;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPCONTEXTGROUPS_PUB','insert_contextgroups');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_contextgroups;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_contextgroups
  -- Public wrapper for update_contextgroups process api
  ---------------------------------------------------------------------------
  PROCEDURE update_contextgroups(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
                        		 p_cgrv_rec         IN  cgrv_rec_type,
                        		 x_cgrv_rec         OUT NOCOPY cgrv_rec_type) IS
    l_cgrv_rec                        cgrv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_contextgroups';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_contextgroups;
    l_cgrv_rec := p_cgrv_rec;



	-- call process api to update context groups
    okl_setupcontextgroups_pvt.update_contextgroups(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_cgrv_rec      => l_cgrv_rec,
                              			  			x_cgrv_rec      => x_cgrv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_cgrv_rec := x_cgrv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_contextgroups;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_contextgroups;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPCONTEXTGROUPS_PUB','update_contextgroups');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_contextgroups;

END OKL_SETUPCONTEXTGROUPS_PUB;

/
