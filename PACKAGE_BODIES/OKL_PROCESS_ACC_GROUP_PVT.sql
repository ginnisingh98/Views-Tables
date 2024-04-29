--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_ACC_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_ACC_GROUP_PVT" AS
/* $Header: OKLRAGGB.pls 120.2 2005/10/30 03:37:54 appldev noship $ */


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

BEGIN

    okl_acc_group_pub.create_acc_group(p_api_version   => p_api_version
                                      ,p_init_msg_list => p_init_msg_list
                                      ,x_return_status => x_return_status
                                      ,x_msg_count     => x_msg_count
                                      ,x_msg_data      => x_msg_data
                                      ,p_agcv_rec      => p_agcv_rec
                                      ,p_agbv_tbl      => p_agbv_tbl
                                      ,x_agcv_rec      => x_agcv_rec
                                      ,x_agbv_tbl      => x_agbv_tbl);


END create_acc_group;




PROCEDURE create_acc_ccid(p_api_version             IN  NUMBER
                         ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                         ,x_return_status           OUT NOCOPY VARCHAR2
                         ,x_msg_count               OUT NOCOPY NUMBER
                         ,x_msg_data                OUT NOCOPY VARCHAR2
                         ,p_agcv_rec                IN  agcv_rec_type
                         ,x_agcv_rec                OUT NOCOPY agcv_rec_type) IS


BEGIN

    okl_acc_group_pub.create_acc_ccid(p_api_version   => p_api_version
                                     ,p_init_msg_list => p_init_msg_list
                                     ,x_return_status => x_return_status
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,p_agcv_rec      => p_agcv_rec
                                     ,x_agcv_rec      => x_agcv_rec);



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

  l_overall_status	       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_agcv_tbl                   agcv_tbl_type := p_agcv_tbl;


BEGIN


   IF (l_agcv_tbl.COUNT > 0) THEN

      i := l_agcv_tbl.FIRST;

      LOOP

           okl_process_Acc_group_pvt.create_acc_ccid(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => l_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_agcv_rec      => l_agcv_tbl(i)
                                                    ,x_agcv_rec      => x_agcv_tbl(i));

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_agcv_tbl.LAST);

          i := l_agcv_tbl.NEXT(i);

      END LOOP;

      l_return_status := l_overall_status;

   END IF;

  END create_acc_ccid;



PROCEDURE update_acc_group(p_api_version           IN  NUMBER,
                           p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status         OUT NOCOPY VARCHAR2,
                           x_msg_count             OUT NOCOPY NUMBER,
                           x_msg_data              OUT NOCOPY VARCHAR2,
                           p_agcv_rec              IN  agcv_rec_type,
                           p_agbv_tbl              IN  agbv_tbl_type,
                           x_agcv_rec              OUT NOCOPY agcv_rec_type,
                           x_agbv_tbl              OUT NOCOPY agbv_tbl_type) IS


  BEGIN


    okl_acc_group_pub.update_acc_group(p_api_version   => p_api_version
                                      ,p_init_msg_list => p_init_msg_list
                                      ,x_return_status => x_return_status
                                      ,x_msg_count     => x_msg_count
                                      ,x_msg_data      => x_msg_data
                                      ,p_agcv_rec      => p_agcv_rec
                                      ,p_agbv_tbl      => p_agbv_tbl
                                      ,x_agcv_rec      => x_agcv_rec
                                      ,x_agbv_tbl      => x_agbv_tbl);


END update_acc_group;



PROCEDURE update_acc_ccid(p_api_version                IN  NUMBER
                         ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                         ,x_return_status              OUT NOCOPY VARCHAR2
                         ,x_msg_count                  OUT NOCOPY NUMBER
                         ,x_msg_data                   OUT NOCOPY VARCHAR2
                         ,p_agcv_rec                   IN  agcv_rec_type
                         ,x_agcv_rec                   OUT NOCOPY agcv_rec_type) IS


BEGIN

   -- call complex entity API

    okl_acc_group_pub.update_acc_ccid(p_api_version   => p_api_version
                                     ,p_init_msg_list => p_init_msg_list
                                     ,x_return_status => x_return_status
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,p_agcv_rec      => p_agcv_rec
                                     ,x_agcv_rec      => x_agcv_rec);


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

    IF (l_agcv_tbl.COUNT > 0) THEN

      i := l_agcv_tbl.FIRST;

      LOOP

        update_acc_ccid( p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => l_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_agcv_rec      => l_agcv_tbl(i)
                        ,x_agcv_rec      => x_agcv_tbl(i));

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


  END update_acc_ccid;



  PROCEDURE delete_acc_ccid(p_api_version           IN  NUMBER
                           ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status         OUT NOCOPY VARCHAR2
                           ,x_msg_count             OUT NOCOPY NUMBER
                           ,x_msg_data              OUT NOCOPY VARCHAR2
                           ,p_agcv_rec              IN  agcv_rec_type) IS


  BEGIN


    okl_acc_group_pub.delete_acc_ccid(p_api_version   => p_api_version
                                     ,p_init_msg_list => p_init_msg_list
                                     ,x_return_status => x_return_status
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,p_agcv_rec      => p_agcv_rec);



 END delete_acc_ccid;



 PROCEDURE delete_acc_ccid(p_api_version           IN  NUMBER
                          ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_return_status         OUT NOCOPY VARCHAR2
                          ,x_msg_count             OUT NOCOPY NUMBER
                          ,x_msg_data              OUT NOCOPY VARCHAR2
                          ,p_agcv_tbl              IN  agcv_tbl_type) IS

    i                       NUMBER :=0;
    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_name              CONSTANT VARCHAR2(30)  := 'delete_acc_ccid';
    l_overall_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_agcv_tbl		    agcv_tbl_type := p_agcv_tbl;

  BEGIN

    IF (l_agcv_tbl.COUNT > 0) THEN

      i := l_agcv_tbl.FIRST;

      LOOP

        delete_acc_ccid(p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_return_status => l_return_status
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_agcv_rec      => l_agcv_tbl(i));

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

  END delete_acc_ccid;



  PROCEDURE create_acc_bal(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_agbv_rec                       IN  agbv_rec_type
    ,x_agbv_rec                       OUT NOCOPY agbv_rec_type)


IS

  BEGIN

    okl_acc_group_pub.create_acc_bal(p_api_version   => p_api_version
                                    ,p_init_msg_list => p_init_msg_list
                                    ,x_return_status => x_return_status
                                    ,x_msg_count     => x_msg_count
                                    ,x_msg_data      => x_msg_data
                                    ,p_agbv_rec      => p_agbv_rec
                                    ,x_agbv_rec      => x_agbv_rec);

  END create_acc_bal;



  PROCEDURE create_acc_bal(p_api_version                    IN  NUMBER
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


    IF (l_agbv_tbl.COUNT > 0) THEN

      i := l_agbv_tbl.FIRST;

      LOOP

        create_acc_bal(p_api_version   => p_api_version
                      ,p_init_msg_list => p_init_msg_list
                      ,x_return_status => l_return_status
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,p_agbv_rec      => l_agbv_tbl(i)
                      ,x_agbv_rec      => x_agbv_tbl(i));

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


  END create_acc_bal;



  PROCEDURE update_acc_bal(p_api_version                    IN  NUMBER
                          ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_return_status                  OUT NOCOPY VARCHAR2
                          ,x_msg_count                      OUT NOCOPY NUMBER
                          ,x_msg_data                       OUT NOCOPY VARCHAR2
                          ,p_agbv_rec                       IN  agbv_rec_type
                          ,x_agbv_rec                       OUT NOCOPY agbv_rec_type) IS

  BEGIN

    okl_acc_group_pub.update_acc_bal(p_api_version   => p_api_version
                                    ,p_init_msg_list => p_init_msg_list
                                    ,x_return_status => x_return_status
                                    ,x_msg_count     => x_msg_count
                                    ,x_msg_data      => x_msg_data
                                    ,p_agbv_rec      => p_agbv_rec
                                    ,x_agbv_rec      => x_agbv_rec);

  END update_acc_bal;




  PROCEDURE update_acc_bal(p_api_version                    IN  NUMBER
                          ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_return_status                  OUT NOCOPY VARCHAR2
                          ,x_msg_count                      OUT NOCOPY NUMBER
                          ,x_msg_data                       OUT NOCOPY VARCHAR2
                          ,p_agbv_tbl                       IN  agbv_tbl_type
                          ,x_agbv_tbl                       OUT NOCOPY agbv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acc_bal';
    i                                 NUMBER;
    l_overall_status                  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_agbv_tbl                        agbv_tbl_type := p_agbv_tbl;

  BEGIN

    IF (l_agbv_tbl.COUNT > 0) THEN

      i := l_agbv_tbl.FIRST;

      LOOP

        update_acc_bal(p_api_version   => p_api_version
                      ,p_init_msg_list => p_init_msg_list
                      ,x_return_status => l_return_status
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,p_agbv_rec      => l_agbv_tbl(i)
                      ,x_agbv_rec      => x_agbv_tbl(i));

		  -- store the highest degree of error
	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
		 	l_overall_status := l_return_status;
		END IF;
	  END IF;

        EXIT WHEN (i = l_agbv_tbl.LAST);

          i := l_agbv_tbl.NEXT(i);

      END LOOP;

   END IF;

	   -- return overall status
      l_return_status := l_overall_status;

  END update_acc_bal;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_acc_bal(p_api_version                    IN  NUMBER
                          ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_return_status                  OUT NOCOPY VARCHAR2
                          ,x_msg_count                      OUT NOCOPY NUMBER
                          ,x_msg_data                       OUT NOCOPY VARCHAR2
                          ,p_agbv_rec                       IN  agbv_rec_type) IS


  BEGIN


    okl_acc_group_pub.delete_acc_bal(p_api_version   => p_api_version
                                    ,p_init_msg_list => p_init_msg_list
                                    ,x_return_status => x_return_status
                                    ,x_msg_count     => x_msg_count
                                    ,x_msg_data      => x_msg_data
                                    ,p_agbv_rec      => p_agbv_rec);


  END delete_acc_bal;



  PROCEDURE delete_acc_bal(p_api_version                    IN  NUMBER
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

    IF (l_agbv_tbl.COUNT > 0) THEN

      i := l_agbv_tbl.FIRST;

      LOOP

        delete_acc_bal(p_api_version   => p_api_version
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


  END delete_acc_bal;

END okl_process_Acc_group_pvt;


/
