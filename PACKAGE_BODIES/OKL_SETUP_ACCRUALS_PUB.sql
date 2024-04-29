--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_ACCRUALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_ACCRUALS_PUB" AS
/* $Header: OKLPARUB.pls 115.3 2002/12/18 12:12:06 kjinger noship $ */

  PROCEDURE create_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN  agnv_rec_type,
    x_agnv_rec                     OUT NOCOPY agnv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'create_accrual_rules';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_agnv_rec          agnv_rec_type := p_agnv_rec;

	BEGIN
      SAVEPOINT create_accrual_rules;

      x_return_status    := FND_API.G_RET_STS_SUCCESS;

       -- customer pre-processing



          -- CALL THE MAIN PROCEDURE
	      OKL_SETUP_ACCRUALS_PVT.create_accrual_rules(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    									               x_return_status   => x_return_status,
    										           x_msg_count       => x_msg_count,
    										           x_msg_data        => x_msg_data,
    										   		   p_agnv_rec        => p_agnv_rec,
													   x_agnv_rec        => x_agnv_rec);

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

       -- customer post-processing


  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_accrual_rules;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_accrual_rules;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      ROLLBACK TO create_accrual_rules;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUP_ACCRUALS_PUB','create_accrual_rules');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_accrual_rules;


  PROCEDURE create_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'create_accrual_rules';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_agnv_tbl          agnv_tbl_type := p_agnv_tbl;
      l_overall_status	  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
	BEGIN
      SAVEPOINT create_accrual_rules;

      x_return_status    := FND_API.G_RET_STS_SUCCESS;

       -- customer pre-processing



		IF l_agnv_tbl.COUNT > 0 THEN
		  FOR i IN l_agnv_tbl.FIRST..l_agnv_tbl.LAST
		  LOOP
            -- Call the main procedure
	        OKL_SETUP_ACCRUALS_PVT.create_accrual_rules(p_api_version     => l_api_version,
                                                   p_init_msg_list   => p_init_msg_list,
    		    					               x_return_status   => x_return_status,
    									           x_msg_count       => x_msg_count,
    									           x_msg_data        => x_msg_data,
    									   		   p_agnv_rec        => l_agnv_tbl(i),
												   x_agnv_rec        => x_agnv_tbl(i));

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
      ROLLBACK TO create_accrual_rules;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_accrual_rules;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      ROLLBACK TO create_accrual_rules;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUP_ACCRUALS_PUB','create_accrual_rules');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_accrual_rules;


  PROCEDURE update_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN  agnv_rec_type,
    x_agnv_rec                     OUT NOCOPY agnv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'update_accrual_rules';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_agnv_rec          agnv_rec_type := p_agnv_rec;

	BEGIN
      SAVEPOINT update_accrual_rules;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

              -- CALL THE MAIN PROCEDURE
    	      OKL_SETUP_ACCRUALS_PVT.update_accrual_rules(p_api_version     => l_api_version,
                                                           p_init_msg_list   => p_init_msg_list,
    		            							       x_return_status   => x_return_Status,
    					            					   x_msg_count       => x_msg_count,
    								            		   x_msg_data        => x_msg_data,
                  										   p_agnv_rec        => p_agnv_rec,
    			            							   x_agnv_rec        => x_agnv_rec);
          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

       -- customer post-processing

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_accrual_rules;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_accrual_rules;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
        ROLLBACK TO update_accrual_rules;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUP_ACCRUALS_PUB','update_accrual_rules');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_accrual_rules;


  PROCEDURE update_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'update_accrual_rules';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_agnv_tbl          agnv_tbl_type := p_agnv_tbl;
      l_overall_status	  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
	BEGIN
      SAVEPOINT update_accrual_rules;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

       IF l_agnv_tbl.COUNT > 0 THEN
	   FOR i IN l_agnv_tbl.FIRST..l_agnv_tbl.LAST
	   LOOP
          -- CALL THE MAIN PROCEDURE
   	      OKL_SETUP_ACCRUALS_PVT.update_accrual_rules(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    	 	          							       x_return_status   => x_return_Status,
    					        					   x_msg_count       => x_msg_count,
    							        			   x_msg_data        => x_msg_data,
               										   p_agnv_rec        => l_agnv_tbl(i),
    		        								   x_agnv_rec        => x_agnv_tbl(i));
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
      ROLLBACK TO update_accrual_rules;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_accrual_rules;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      ROLLBACK TO update_accrual_rules;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUP_ACCRUALS_PUB','update_accrual_rules');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_accrual_rules;


  PROCEDURE delete_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN  agnv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'delete_accrual_rules';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_agnv_rec          agnv_rec_type := p_agnv_rec;

	BEGIN
      SAVEPOINT delete_accrual_rules;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

          -- CALL THE MAIN PROCEDURE
  	      OKL_SETUP_ACCRUALS_PVT.delete_accrual_rules(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    	          								       x_return_status   => x_return_Status,
    				         						   x_msg_count       => x_msg_count,
    							        			   x_msg_data        => x_msg_data,
    									        	   p_agnv_rec        => p_agnv_rec);
          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

       -- customer post-processing

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_accrual_rules;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_accrual_rules;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      ROLLBACK TO delete_accrual_rules;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUP_ACCRUALS_PUB','delete_accrual_rules');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_accrual_rules;

  PROCEDURE delete_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type)

  IS

      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'delete_accrual_rules';
      l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_agnv_tbl          agnv_tbl_type := p_agnv_tbl;
      l_overall_status	  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  BEGIN
      SAVEPOINT delete_accrual_rules;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

       IF l_agnv_tbl.COUNT > 0 THEN
	   FOR i IN l_agnv_tbl.FIRST..l_agnv_tbl.LAST
	   LOOP
	      -- CALL THE MAIN PROCEDURE
  	      OKL_SETUP_ACCRUALS_PVT.delete_accrual_rules(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    		         							       x_return_status   => x_return_Status,
    					          					   x_msg_count       => x_msg_count,
    								          		   x_msg_data        => x_msg_data,
            										   p_agnv_rec        => l_agnv_tbl(i));
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
      ROLLBACK TO delete_accrual_rules;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_accrual_rules;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      ROLLBACK TO delete_accrual_rules;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUP_ACCRUALS_PUB','delete_accrual_rules');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_accrual_rules;

END OKL_SETUP_ACCRUALS_PUB;

/
