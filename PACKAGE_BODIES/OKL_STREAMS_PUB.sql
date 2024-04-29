--------------------------------------------------------
--  DDL for Package Body OKL_STREAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAMS_PUB" AS
/* $Header: OKLPSTMB.pls 120.1 2005/05/30 12:27:21 kthiruva noship $ */



  PROCEDURE create_streams(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_stmv_rec                     IN  stmv_rec_type

    ,p_selv_tbl                     IN  selv_tbl_type

    ,x_stmv_rec                     OUT NOCOPY stmv_rec_type

    ,x_selv_tbl                     OUT NOCOPY selv_tbl_type

    ) IS



    i                               NUMBER;

    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_streams';

    l_stmv_rec                      stmv_rec_type := p_stmv_rec;

    l_return_status                 VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_selv_tbl                      selv_tbl_type := p_selv_tbl;



  BEGIN

    SAVEPOINT create_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    Okl_Streams_Pvt.create_streams(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_stmv_rec      => l_stmv_rec

                        ,p_selv_tbl      => l_selv_tbl

                        ,x_stmv_rec      => x_stmv_rec

                        ,x_selv_tbl      => x_selv_tbl);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_stmv_rec := x_stmv_rec;
	   l_selv_tbl := x_selv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','create_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_streams;


   --Object type procedure for insert(master-table,detail-table)
  PROCEDURE create_streams(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_tbl                     IN stmv_tbl_type
     ,p_selv_tbl                    IN selv_tbl_type
     ,x_stmv_tbl                   OUT NOCOPY stmv_tbl_type
     ,x_selv_tbl                    OUT NOCOPY selv_tbl_type
     ) IS

    i                               NUMBER;

    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_streams';
	l_stmv_tbl                      stmv_tbl_type := p_stmv_tbl;
    l_return_status                 VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_selv_tbl                      selv_tbl_type := p_selv_tbl;


  BEGIN

    SAVEPOINT create_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing






   -- vertical industry-preprocessing




   -- call complex entity API

    Okl_Streams_Pvt.create_streams(

                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => l_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_stmv_tbl      => l_stmv_tbl
                        ,p_selv_tbl      => l_selv_tbl
                        ,x_stmv_tbl      => x_stmv_tbl
                        ,x_selv_tbl      => x_selv_tbl);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_stmv_tbl := x_stmv_tbl;
	   l_selv_tbl := x_selv_tbl;

    -- vertical industry-post-processing





     -- customer post-processing






  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','create_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_streams;

























  PROCEDURE create_streams(

     p_api_version             IN  NUMBER

    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status           OUT NOCOPY VARCHAR2

    ,x_msg_count               OUT NOCOPY NUMBER

    ,x_msg_data                OUT NOCOPY VARCHAR2

    ,p_stmv_rec                IN  stmv_rec_type

    ,x_stmv_rec                OUT NOCOPY stmv_rec_type) IS

    l_return_status            VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                 CONSTANT VARCHAR2(30)  := 'create_streams';

    l_stmv_rec                      stmv_rec_type := p_stmv_rec;



  BEGIN

    SAVEPOINT create_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    Okl_Streams_Pvt.create_streams(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_stmv_rec      => l_stmv_rec

                          ,x_stmv_rec      => x_stmv_rec

                          );



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_stmv_rec := x_stmv_rec;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','create_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_streams;



  PROCEDURE create_streams(

     p_api_version               IN  NUMBER

    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status             OUT NOCOPY VARCHAR2

    ,x_msg_count                 OUT NOCOPY NUMBER

    ,x_msg_data                  OUT NOCOPY VARCHAR2

    ,p_stmv_tbl                  IN  stmv_tbl_type

    ,x_stmv_tbl                  OUT NOCOPY stmv_tbl_type) IS

    l_return_status              VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                   CONSTANT VARCHAR2(30)  := 'create_streams';

    i                            NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_stmv_tbl                      stmv_tbl_type := p_stmv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT create_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_stmv_tbl.COUNT > 0) THEN

      i := l_stmv_tbl.FIRST;

      LOOP

        Okl_Streams_Pub.create_streams(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_stmv_rec      => l_stmv_tbl(i)

                          ,x_stmv_rec      => x_stmv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_stmv_tbl.LAST);

          i := l_stmv_tbl.NEXT(i);
       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_stmv_tbl := x_stmv_tbl;


    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','create_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_streams;


  --Added by kthiruva on 12-May-2005 for streams perf
  --Bug 4346646-Start of Changes

  PROCEDURE create_streams_perf(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_tbl                     IN stmv_tbl_type
     ,p_selv_tbl                    IN selv_tbl_type
     ,x_stmv_tbl                   OUT NOCOPY stmv_tbl_type
     ,x_selv_tbl                    OUT NOCOPY selv_tbl_type
     ) IS

    i                               NUMBER;

    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_streams_perf';
	l_stmv_tbl                      stmv_tbl_type := p_stmv_tbl;
    l_return_status                 VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_selv_tbl                      selv_tbl_type := p_selv_tbl;


  BEGIN

    SAVEPOINT create_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- call complex entity API

    Okl_Streams_Pvt.create_streams_perf(

                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => l_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_stmv_tbl      => l_stmv_tbl
                        ,p_selv_tbl      => l_selv_tbl
                        ,x_stmv_tbl      => x_stmv_tbl
                        ,x_selv_tbl      => x_selv_tbl);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_stmv_tbl := x_stmv_tbl;
	   l_selv_tbl := x_selv_tbl;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','create_streams_perf');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_streams_perf;
  --Bug 4346646-End of Changes

  -- Object type procedure for update

  PROCEDURE update_streams(

    p_api_version           IN  NUMBER,

    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

    x_return_status         OUT NOCOPY VARCHAR2,

    x_msg_count             OUT NOCOPY NUMBER,

    x_msg_data              OUT NOCOPY VARCHAR2,

    p_stmv_rec              IN  stmv_rec_type,

    p_selv_tbl              IN  selv_tbl_type,

    x_stmv_rec              OUT NOCOPY stmv_rec_type,

    x_selv_tbl              OUT NOCOPY selv_tbl_type) IS

    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'update_streams';

    l_stmv_rec                      stmv_rec_type := p_stmv_rec;

    l_selv_tbl                      selv_tbl_type := p_selv_tbl;



  BEGIN

    SAVEPOINT update_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    Okl_Streams_Pvt.update_streams(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => x_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_stmv_rec      => l_stmv_rec

                        ,p_selv_tbl      => l_selv_tbl

                        ,x_stmv_rec      => x_stmv_rec

                        ,x_selv_tbl      => x_selv_tbl

                        );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_stmv_rec := x_stmv_rec;
	   l_selv_tbl := x_selv_tbl;

   -- vertical industry-post processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','update_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_streams;



  PROCEDURE validate_streams(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_stmv_rec              IN  stmv_rec_type

    ,p_selv_tbl              IN  selv_tbl_type) IS



    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'validate_streams';

    l_stmv_rec                      stmv_rec_type := p_stmv_rec;

    l_selv_tbl                      selv_tbl_type := p_selv_tbl;



  BEGIN

    SAVEPOINT validate_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






-- call complex entity API

    Okl_Streams_Pvt.validate_streams(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_stmv_rec      => l_stmv_rec

                          ,p_selv_tbl      => l_selv_tbl

                          );



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','validate_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_streams;



  PROCEDURE lock_streams(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_stmv_rec              IN  stmv_rec_type) IS

    l_return_status          VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_streams';





  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_streams;


    Okl_Streams_Pvt.lock_streams(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_stmv_rec      => p_stmv_rec

                        );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','lock_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_streams;



  PROCEDURE lock_streams(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_stmv_tbl              IN  stmv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_streams';

    i                        NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;



  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_streams;

    IF (p_stmv_tbl.COUNT > 0) THEN

      i := p_stmv_tbl.FIRST;

      LOOP

        Okl_Streams_Pub.lock_streams(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_stmv_rec      => p_stmv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = p_stmv_tbl.LAST);

          i := p_stmv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAM_TYPE_PUB','lock_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_streams;



  PROCEDURE update_streams(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_stmv_rec                   IN  stmv_rec_type

    ,x_stmv_rec                   OUT NOCOPY stmv_rec_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_streams';

    l_stmv_rec                      stmv_rec_type := p_stmv_rec;

  BEGIN

    SAVEPOINT update_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    Okl_Streams_Pvt.update_streams(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_stmv_rec      => l_stmv_rec

                          ,x_stmv_rec      => x_stmv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_stmv_rec := x_stmv_rec;

    -- vertical industry-post-processing






    -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','update_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_streams;



  PROCEDURE update_streams(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_stmv_tbl                   IN  stmv_tbl_type

    ,x_stmv_tbl                   OUT NOCOPY stmv_tbl_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_streams';

    i                             NUMBER;

	l_overall_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_stmv_tbl					  stmv_tbl_type := p_stmv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT update_streams;

   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_stmv_tbl.COUNT > 0) THEN

      i := l_stmv_tbl.FIRST;

      LOOP

        update_streams(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_stmv_rec      => l_stmv_tbl(i)

                          ,x_stmv_rec      => x_stmv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_stmv_tbl.LAST);

          i := l_stmv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_stmv_tbl := x_stmv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','update_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END update_streams;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_streams(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_stmv_rec              IN  stmv_rec_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_streams';

    l_stmv_rec                      stmv_rec_type := p_stmv_rec;



  BEGIN

    SAVEPOINT delete_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    Okl_Streams_Pvt.delete_streams(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_stmv_rec      => l_stmv_rec

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
      ROLLBACK TO delete_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','delete_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_streams;



  PROCEDURE delete_streams(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_stmv_tbl              IN  stmv_tbl_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_streams';

    l_overall_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_stmv_tbl					  stmv_tbl_type := p_stmv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT delete_streams;

   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_stmv_tbl.COUNT > 0) THEN

      i := l_stmv_tbl.FIRST;

      LOOP

        delete_streams(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_stmv_rec      => l_stmv_tbl(i)

                            );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

         EXIT WHEN (i = l_stmv_tbl.LAST);

         i := l_stmv_tbl.NEXT(i);

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
      ROLLBACK TO delete_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','delete_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END delete_streams;



  PROCEDURE validate_streams(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_stmv_rec                   IN  stmv_rec_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'validate_streams';

    l_stmv_rec                      stmv_rec_type := p_stmv_rec;



  BEGIN

    SAVEPOINT validate_streams;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    Okl_Streams_Pvt.validate_streams(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_stmv_rec      => l_stmv_rec

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
      ROLLBACK TO validate_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','validate_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_streams;



  PROCEDURE validate_streams(

      p_api_version               IN  NUMBER,

      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

      x_return_status             OUT NOCOPY VARCHAR2,

      x_msg_count                 OUT NOCOPY NUMBER,

      x_msg_data                  OUT NOCOPY VARCHAR2,

      p_stmv_tbl                  IN  stmv_tbl_type) IS

      l_return_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

      l_api_name                  CONSTANT VARCHAR2(30)  := 'validate_streams';

      i                           NUMBER;

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_stmv_tbl					  stmv_tbl_type := p_stmv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT validate_streams;

   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_stmv_tbl.COUNT > 0) THEN

      i := l_stmv_tbl.FIRST;

      LOOP

        validate_streams(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_stmv_rec      => l_stmv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_stmv_tbl.LAST);

          i := l_stmv_tbl.NEXT(i);

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
      ROLLBACK TO validate_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','validate_streams');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END validate_streams;



  PROCEDURE create_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_rec                       IN  selv_rec_type

    ,x_selv_rec                       OUT NOCOPY selv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_stream_elements';

    l_selv_rec                      selv_rec_type := p_selv_rec;

  BEGIN

    SAVEPOINT create_stream_elements;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API





    Okl_Streams_Pvt.create_stream_elements(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_selv_rec      => l_selv_rec

                          ,x_selv_rec      => x_selv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_selv_rec := x_selv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','create_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_stream_elements;



  PROCEDURE create_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_tbl                       IN  selv_tbl_type

    ,x_selv_tbl                       OUT NOCOPY selv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_stream_elements';

    i                                 NUMBER;

    l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_selv_tbl                      selv_tbl_type := p_selv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT create_stream_elements;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_selv_tbl.COUNT > 0) THEN

      i := l_selv_tbl.FIRST;

      LOOP

        create_stream_elements(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_selv_rec      => l_selv_tbl(i)

                          ,x_selv_rec      => x_selv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_selv_tbl.LAST);

          i := l_selv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_selv_tbl := x_selv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','create_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END create_stream_elements;



  PROCEDURE lock_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_rec                       IN  selv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'lock_stream_elements';

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_stream_elements;

    Okl_Streams_Pvt.lock_stream_elements(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_selv_rec      => p_selv_rec

                          );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','lock_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_stream_elements;



  PROCEDURE lock_stream_elements(

     p_api_version                   IN  NUMBER

    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                 OUT NOCOPY VARCHAR2

    ,x_msg_count                     OUT NOCOPY NUMBER

    ,x_msg_data                      OUT NOCOPY VARCHAR2

    ,p_selv_tbl                      IN  selv_tbl_type) IS

    l_return_status                  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                       CONSTANT VARCHAR2(30)  := 'lock_stream_elements';

    i                                NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_stream_elements;

    IF (p_selv_tbl.COUNT > 0) THEN

      i := p_selv_tbl.FIRST;

      LOOP

        lock_stream_elements(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_selv_rec      => p_selv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = p_selv_tbl.LAST);

          i := p_selv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','lock_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_stream_elements;



  PROCEDURE update_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_rec                       IN  selv_rec_type

    ,x_selv_rec                       OUT NOCOPY selv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_stream_elements';

    l_selv_rec                      selv_rec_type := p_selv_rec;

  BEGIN

    SAVEPOINT update_stream_elements;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    Okl_Streams_Pvt.update_stream_elements(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_selv_rec      => l_selv_rec

                          ,x_selv_rec      => x_selv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_selv_rec := x_selv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','update_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_stream_elements;



  PROCEDURE update_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_tbl                       IN  selv_tbl_type

    ,x_selv_tbl                       OUT NOCOPY selv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_stream_elements';

    i                                 NUMBER;

    l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_selv_tbl                      selv_tbl_type := p_selv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT update_stream_elements;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_selv_tbl.COUNT > 0) THEN

      i := l_selv_tbl.FIRST;

      LOOP

        update_stream_elements(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_selv_rec      => l_selv_tbl(i)

                          ,x_selv_rec      => x_selv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_selv_tbl.LAST);

          i := l_selv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_selv_tbl := x_selv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','update_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END update_stream_elements;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_rec                       IN  selv_rec_type) IS

    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_stream_elements';

    l_selv_rec                      selv_rec_type := p_selv_rec;

  BEGIN

    SAVEPOINT delete_stream_elements;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    Okl_Streams_Pvt.delete_stream_elements(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_selv_rec      => l_selv_rec);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','delete_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_stream_elements;



  PROCEDURE delete_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_tbl                       IN  selv_tbl_type) IS



    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_stream_elements';

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_selv_tbl                      selv_tbl_type := p_selv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT delete_stream_elements;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_selv_tbl.COUNT > 0) THEN

      i := l_selv_tbl.FIRST;

      LOOP

        delete_stream_elements(

                                  p_api_version   => p_api_version

                                 ,p_init_msg_list => p_init_msg_list

                                 ,x_return_status => l_return_status

                                 ,x_msg_count     => x_msg_count

                                 ,x_msg_data      => x_msg_data

                                 ,p_selv_rec      => l_selv_tbl(i));
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_selv_tbl.LAST);

          i := l_selv_tbl.NEXT(i);

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
      ROLLBACK TO delete_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','delete_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_stream_elements;



  PROCEDURE validate_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_rec                       IN  selv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_stream_elements';

    l_selv_rec                      selv_rec_type := p_selv_rec;

  BEGIN

    SAVEPOINT validate_stream_elements;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    Okl_Streams_Pvt.validate_stream_elements(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_selv_rec      => l_selv_rec

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
      ROLLBACK TO validate_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','validate_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_stream_elements;



  PROCEDURE validate_stream_elements(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_selv_tbl                       IN  selv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_stream_elements';

    i                                 NUMBER;

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_selv_tbl                      selv_tbl_type := p_selv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT validate_stream_elements;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_selv_tbl.COUNT > 0) THEN

      i := l_selv_tbl.FIRST;

      LOOP

        validate_stream_elements(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_selv_rec      => l_selv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_selv_tbl.LAST);

          i := l_selv_tbl.NEXT(i);

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
      ROLLBACK TO validate_stream_elements;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_stream_elements;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAMS_PUB','validate_stream_elements');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_stream_elements;



END Okl_Streams_Pub;

/
