--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_BUCKETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_BUCKETS_PUB" AS
/* $Header: OKLPBUKB.pls 115.4 2002/12/18 12:14:08 kjinger noship $ */

  PROCEDURE create_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN  bktv_rec_type,
    x_bktv_rec                     OUT NOCOPY bktv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'CREATE_BUCKETS';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_bktv_rec          bktv_rec_type := p_bktv_rec;

	BEGIN
      SAVEPOINT insert_buckets;

      x_return_status    := FND_API.G_RET_STS_SUCCESS;

       -- customer pre-processing



          -- CALL THE MAIN PROCEDURE
	      OKL_PROCESS_BUCKETS_PVT.CREATE_BUCKETS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    									               x_return_status   => x_return_Status,
    										           x_msg_count       => x_msg_count,
    										           x_msg_data        => x_msg_data,
    										   		   p_bktv_rec        => p_bktv_rec,
													   x_bktv_rec        => x_bktv_rec);

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

       -- customer post-processing


  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_buckets;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_buckets;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_BUCKETS_PUB','CREATE_BUCKETS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_buckets;


  PROCEDURE create_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type,
    x_bktv_tbl                     OUT NOCOPY bktv_tbl_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'CREATE_BUCKETS';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_bktv_tbl          bktv_tbl_type := p_bktv_tbl;
      l_overall_status	  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
	BEGIN
      SAVEPOINT insert_buckets;

      x_return_status    := FND_API.G_RET_STS_SUCCESS;

       -- customer pre-processing



		IF l_bktv_tbl.COUNT > 0 THEN
		  FOR i IN l_bktv_tbl.FIRST..l_bktv_tbl.LAST
		  LOOP
            -- Call the main procedure
	        OKL_PROCESS_BUCKETS_PVT.CREATE_BUCKETS(p_api_version     => l_api_version,
                                                   p_init_msg_list   => p_init_msg_list,
    		    					               x_return_status   => x_return_Status,
    									           x_msg_count       => x_msg_count,
    									           x_msg_data        => x_msg_data,
    									   		   p_bktv_rec        => l_bktv_tbl(i),
												   x_bktv_rec        => x_bktv_tbl(i));

            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

		  END LOOP;
  	      -- return overall status
          x_return_status := l_overall_status;
        END IF;

       -- customer post-processing


  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_buckets;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_buckets;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_BUCKETS_PUB','CREATE_BUCKETS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_buckets;


  PROCEDURE update_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN  bktv_rec_type,
    x_bktv_rec                     OUT NOCOPY bktv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'UPDATE_BUCKETS';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_bktv_rec          bktv_rec_type := p_bktv_rec;

	BEGIN
      SAVEPOINT update_buckets;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

              -- CALL THE MAIN PROCEDURE
    	      OKL_PROCESS_BUCKETS_PVT.UPDATE_BUCKETS(p_api_version     => l_api_version,
                                                           p_init_msg_list   => p_init_msg_list,
    		            							       x_return_status   => x_return_Status,
    					            					   x_msg_count       => x_msg_count,
    								            		   x_msg_data        => x_msg_data,
                  										   p_bktv_rec        => p_bktv_rec,
    			            							   x_bktv_rec        => x_bktv_rec);
          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

       -- customer post-processing

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_buckets;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_buckets;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_BUCKETS_PUB','CREATE_BUCKETS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_buckets;


  PROCEDURE update_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type,
    x_bktv_tbl                     OUT NOCOPY bktv_tbl_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'UPDATE_BUCKETS';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_bktv_tbl          bktv_tbl_type := p_bktv_tbl;
      l_overall_status	  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
	BEGIN
      SAVEPOINT update_buckets;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

       IF l_bktv_tbl.COUNT > 0 THEN
	   FOR i IN l_bktv_tbl.FIRST..l_bktv_tbl.LAST
	   LOOP
          -- CALL THE MAIN PROCEDURE
   	      OKL_PROCESS_BUCKETS_PVT.UPDATE_BUCKETS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    	 	          							       x_return_status   => x_return_Status,
    					        					   x_msg_count       => x_msg_count,
    							        			   x_msg_data        => x_msg_data,
               										   p_bktv_rec        => l_bktv_tbl(i),
    		        								   x_bktv_rec        => x_bktv_tbl(i));
          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
       END IF;

       -- customer post-processing

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_buckets;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_buckets;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_BUCKETS_PUB','CREATE_BUCKETS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_buckets;


  PROCEDURE delete_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN  bktv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'DELETE_BUCKETS';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_bktv_rec          bktv_rec_type := p_bktv_rec;

	BEGIN
      SAVEPOINT delete_buckets;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

          -- CALL THE MAIN PROCEDURE
  	      OKL_PROCESS_BUCKETS_PVT.DELETE_BUCKETS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    	          								       x_return_status   => x_return_Status,
    				         						   x_msg_count       => x_msg_count,
    							        			   x_msg_data        => x_msg_data,
    									        	   p_bktv_rec        => p_bktv_rec);
          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

       -- customer post-processing

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_buckets;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_buckets;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_BUCKETS_PUB','CREATE_BUCKETS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_buckets;

  PROCEDURE delete_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type)

  IS

      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'DELETE_BUCKETS';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_bktv_tbl          bktv_tbl_type := p_bktv_tbl;
      l_overall_status	  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  BEGIN
      SAVEPOINT delete_buckets;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

       IF l_bktv_tbl.COUNT > 0 THEN
	   FOR i IN l_bktv_tbl.FIRST..l_bktv_tbl.LAST
	   LOOP
	      -- CALL THE MAIN PROCEDURE
  	      OKL_PROCESS_BUCKETS_PVT.DELETE_BUCKETS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    		         							       x_return_status   => x_return_Status,
    					          					   x_msg_count       => x_msg_count,
    								          		   x_msg_data        => x_msg_data,
            										   p_bktv_rec        => l_bktv_tbl(i));
          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
	   END LOOP;
       -- return overall status
       x_return_status := l_overall_status;
       END IF;

       -- customer post-processing

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_buckets;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_buckets;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_BUCKETS_PUB','CREATE_BUCKETS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_buckets;

END OKL_PROCESS_BUCKETS_PUB;

/
