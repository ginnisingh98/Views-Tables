--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_ACC_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_ACC_GROUP_PUB" AS
/* $Header: OKLPAGGB.pls 115.4 2002/12/18 12:09:38 kjinger noship $ */


  PROCEDURE create_acc_group(p_api_version      IN  NUMBER
                            ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                            ,x_return_status    OUT NOCOPY VARCHAR2
                            ,x_msg_count        OUT NOCOPY NUMBER
                            ,x_msg_data         OUT NOCOPY VARCHAR2
                            ,p_agcv_rec         IN  agcv_rec_type
                            ,p_agbv_tbl         IN  agbv_tbl_type
                            ,x_agcv_rec         OUT NOCOPY agcv_rec_type
                            ,x_agbv_tbl         OUT NOCOPY agbv_tbl_type )

   IS

    i                               NUMBER;
    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_acc_ccid';
    l_agcv_rec                      agcv_rec_type := p_agcv_rec;
    l_return_status                 VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_agbv_tbl                      agbv_tbl_type := p_agbv_tbl;


  BEGIN

    SAVEPOINT create_acc_group;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing





   -- vertical industry-preprocessing





   -- call complex entity API



    okl_process_acc_group_pvt.create_acc_group(p_api_version   => p_api_version
                                      ,p_init_msg_list => p_init_msg_list
                                      ,x_return_status => l_return_status
                                      ,x_msg_count     => x_msg_count
                                      ,x_msg_data      => x_msg_data
                                      ,p_agcv_rec      => l_agcv_rec
                                      ,p_agbv_tbl      => l_agbv_tbl
                                      ,x_agcv_rec      => x_agcv_rec
                                      ,x_agbv_tbl      => x_agbv_tbl);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


       l_agcv_rec := x_agcv_rec;
       l_agbv_tbl := x_agbv_tbl;

    -- vertical industry-post-processing





     -- customer post-processing






  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acc_group;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acc_group;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','create_acc_group');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_acc_group;



  PROCEDURE create_acc_ccid(p_api_version             IN  NUMBER
                           ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status           OUT NOCOPY VARCHAR2
                           ,x_msg_count               OUT NOCOPY NUMBER
                           ,x_msg_data                OUT NOCOPY VARCHAR2
                           ,p_agcv_rec                IN  agcv_rec_type
                           ,x_agcv_rec                OUT NOCOPY agcv_rec_type) IS

    l_return_status            VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_api_name                 CONSTANT VARCHAR2(30)  := 'create_acc_ccid';
    l_agcv_rec                 agcv_rec_type := p_agcv_rec;



  BEGIN

    SAVEPOINT create_acc_ccid;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;


   -- customer pre-processing





   -- vertical industry-preprocessing






   -- call complex entity API

    okl_process_acc_group_pvt.create_acc_ccid(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agcv_rec      => l_agcv_rec
                          ,x_agcv_rec      => x_agcv_rec);



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_agcv_rec := x_agcv_rec;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acc_ccid;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acc_ccid;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','create_acc_ccid');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_acc_ccid;



  PROCEDURE create_acc_ccid(p_api_version               IN  NUMBER
                           ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status             OUT NOCOPY VARCHAR2
                           ,x_msg_count                 OUT NOCOPY NUMBER
                           ,x_msg_data                  OUT NOCOPY VARCHAR2
                           ,p_agcv_tbl                  IN  agcv_tbl_type
                           ,x_agcv_tbl                  OUT NOCOPY agcv_tbl_type) IS


    l_return_status              VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_api_name                   CONSTANT VARCHAR2(30)  := 'create_acc_ccid';
    i                            NUMBER;

    l_overall_status		 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_agcv_tbl                   agcv_tbl_type := p_agcv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT create_acc_ccid;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_agcv_tbl.COUNT > 0) THEN

      i := l_agcv_tbl.FIRST;

      LOOP

        OKL_PROCESS_ACC_GROUP_PUB.create_acc_ccid(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agcv_rec      => l_agcv_tbl(i)
                          ,x_agcv_rec      => x_agcv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_agcv_tbl.LAST);

          i := l_agcv_tbl.NEXT(i);
       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_agcv_tbl := x_agcv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing




  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acc_ccid;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acc_ccid;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','create_acc_ccid');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_acc_ccid;



  -- Object type procedure for update

  PROCEDURE update_acc_group(p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agcv_rec              IN  agcv_rec_type,
    p_agbv_tbl              IN  agbv_tbl_type,
    x_agcv_rec              OUT NOCOPY agcv_rec_type,
    x_agbv_tbl              OUT NOCOPY agbv_tbl_type) IS

    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_name              CONSTANT VARCHAR2(30)  := 'update_acc_ccid';
    l_agcv_rec              agcv_rec_type := p_agcv_rec;
    l_agbv_tbl              agbv_tbl_type := p_agbv_tbl;



  BEGIN

    SAVEPOINT update_acc_group;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing





   -- call complex entity API



    okl_process_acc_group_pvt.update_acc_group(p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_agcv_rec      => l_agcv_rec
                        ,p_agbv_tbl      => l_agbv_tbl
                        ,x_agcv_rec      => x_agcv_rec
                        ,x_agbv_tbl      => x_agbv_tbl);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       l_agcv_rec := x_agcv_rec;
       l_agbv_tbl := x_agbv_tbl;

   -- vertical industry-post processing





   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acc_group;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acc_group;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','update_acc_ccid');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acc_group;





  PROCEDURE update_acc_ccid(p_api_version                IN  NUMBER
                           ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status              OUT NOCOPY VARCHAR2
                           ,x_msg_count                  OUT NOCOPY NUMBER
                           ,x_msg_data                   OUT NOCOPY VARCHAR2
                           ,p_agcv_rec                   IN  agcv_rec_type
                           ,x_agcv_rec                   OUT NOCOPY agcv_rec_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_acc_ccid';
    l_agcv_rec                      agcv_rec_type := p_agcv_rec;

  BEGIN

    SAVEPOINT update_acc_ccid;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;


   -- customer pre-processing






   -- vertical industry-preprocessing





   -- call complex entity API

    okl_process_acc_group_pvt.update_acc_ccid(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agcv_rec      => l_agcv_rec
                          ,x_agcv_rec      => x_agcv_rec
                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       l_agcv_rec := x_agcv_rec;

    -- vertical industry-post-processing





    -- customer post-processing




  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acc_ccid;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acc_ccid;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','update_acc_ccid');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acc_ccid;



  PROCEDURE update_acc_ccid(p_api_version              IN  NUMBER
                           ,p_init_msg_list            IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status            OUT NOCOPY VARCHAR2
                           ,x_msg_count                OUT NOCOPY NUMBER
                           ,x_msg_data                 OUT NOCOPY VARCHAR2
                           ,p_agcv_tbl                 IN  agcv_tbl_type
                           ,x_agcv_tbl                 OUT NOCOPY agcv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30)  := 'update_acc_ccid';
    i                        NUMBER;

    l_overall_status	     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_agcv_tbl		     agcv_tbl_type := p_agcv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT update_acc_ccid;

   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_agcv_tbl.COUNT > 0) THEN

      i := l_agcv_tbl.FIRST;

      LOOP

        update_acc_ccid(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_agcv_rec      => l_agcv_tbl(i)

                          ,x_agcv_rec      => x_agcv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_agcv_tbl.LAST);

          i := l_agcv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_agcv_tbl := x_agcv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acc_ccid;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acc_ccid;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','update_acc_ccid');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END update_acc_ccid;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_acc_ccid(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_agcv_rec              IN  agcv_rec_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_acc_ccid';

    l_agcv_rec                      agcv_rec_type := p_agcv_rec;



  BEGIN

    SAVEPOINT delete_acc_ccid;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_process_acc_group_pvt.delete_acc_ccid(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_agcv_rec      => l_agcv_rec

                          );



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



    -- vertical industry-post-processing






    -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_acc_ccid;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acc_ccid;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','delete_acc_ccid');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_acc_ccid;



  PROCEDURE delete_acc_ccid(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_agcv_tbl              IN  agcv_tbl_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_acc_ccid';

    l_overall_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_agcv_tbl					  agcv_tbl_type := p_agcv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT delete_acc_ccid;

   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_agcv_tbl.COUNT > 0) THEN

      i := l_agcv_tbl.FIRST;

      LOOP

        delete_acc_ccid(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_agcv_rec      => l_agcv_tbl(i)

                            );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;

         EXIT WHEN (i = l_agcv_tbl.LAST);

         i := l_agcv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

      END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_acc_ccid;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acc_ccid;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','delete_acc_ccid');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END delete_acc_ccid;




  PROCEDURE create_acc_bal(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_agbv_rec                       IN  agbv_rec_type

    ,x_agbv_rec                       OUT NOCOPY agbv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_acc_bal';

    l_agbv_rec                      agbv_rec_type := p_agbv_rec;

  BEGIN

    SAVEPOINT create_acc_bal;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API





    okl_process_acc_group_pvt.create_acc_bal(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_agbv_rec      => l_agbv_rec

                          ,x_agbv_rec      => x_agbv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_agbv_rec := x_agbv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acc_bal;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acc_bal;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','create_acc_bal');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_acc_bal;



  PROCEDURE create_acc_bal(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_agbv_tbl                       IN  agbv_tbl_type

    ,x_agbv_tbl                       OUT NOCOPY agbv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_acc_bal';

    i                                 NUMBER;

    l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_agbv_tbl                      agbv_tbl_type := p_agbv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT create_acc_bal;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_agbv_tbl.COUNT > 0) THEN

      i := l_agbv_tbl.FIRST;

      LOOP

        create_acc_bal(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_agbv_rec      => l_agbv_tbl(i)

                          ,x_agbv_rec      => x_agbv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_agbv_tbl.LAST);

          i := l_agbv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_agbv_tbl := x_agbv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acc_bal;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acc_bal;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','create_acc_bal');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END create_acc_bal;




  PROCEDURE update_acc_bal(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_agbv_rec                       IN  agbv_rec_type

    ,x_agbv_rec                       OUT NOCOPY agbv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acc_bal';

    l_agbv_rec                      agbv_rec_type := p_agbv_rec;

  BEGIN

    SAVEPOINT update_acc_bal;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_process_acc_group_pvt.update_acc_bal(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_agbv_rec      => l_agbv_rec

                          ,x_agbv_rec      => x_agbv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_agbv_rec := x_agbv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acc_bal;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acc_bal;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','update_acc_bal');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acc_bal;



  PROCEDURE update_acc_bal(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_agbv_tbl                       IN  agbv_tbl_type

    ,x_agbv_tbl                       OUT NOCOPY agbv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acc_bal';

    i                                 NUMBER;

    l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_agbv_tbl                      agbv_tbl_type := p_agbv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT update_acc_bal;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_agbv_tbl.COUNT > 0) THEN

      i := l_agbv_tbl.FIRST;

      LOOP

        update_acc_bal(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_agbv_rec      => l_agbv_tbl(i)

                          ,x_agbv_rec      => x_agbv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_agbv_tbl.LAST);

          i := l_agbv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_agbv_tbl := x_agbv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acc_bal;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acc_bal;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','update_acc_bal');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END update_acc_bal;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_acc_bal(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_agbv_rec                       IN  agbv_rec_type) IS

    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_acc_bal';

    l_agbv_rec                      agbv_rec_type := p_agbv_rec;

  BEGIN

    SAVEPOINT delete_acc_bal;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_process_acc_group_pvt.delete_acc_bal(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_agbv_rec      => l_agbv_rec);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_acc_bal;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acc_bal;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','delete_acc_bal');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_acc_bal;



  PROCEDURE delete_acc_bal(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_agbv_tbl                       IN  agbv_tbl_type) IS



    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_acc_bal';

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_agbv_tbl                      agbv_tbl_type := p_agbv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT delete_acc_bal;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_agbv_tbl.COUNT > 0) THEN

      i := l_agbv_tbl.FIRST;

      LOOP

        delete_acc_bal(

                                  p_api_version   => p_api_version

                                 ,p_init_msg_list => p_init_msg_list

                                 ,x_return_status => l_return_status

                                 ,x_msg_count     => x_msg_count

                                 ,x_msg_data      => x_msg_data

                                 ,p_agbv_rec      => l_agbv_tbl(i));
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_agbv_tbl.LAST);

          i := l_agbv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_acc_bal;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acc_bal;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_ACC_GROUP_PUB','delete_acc_bal');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_acc_bal;




END OKL_PROCESS_ACC_GROUP_PUB;


/
