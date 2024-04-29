--------------------------------------------------------
--  DDL for Package Body OKL_OVD_RUL_TMLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OVD_RUL_TMLS_PUB" AS
/* $Header: OKLPOVTB.pls 115.10 2004/04/13 10:54:47 rnaik noship $ */

  PROCEDURE add_language IS
  BEGIN
--    okl_ovt_pvt.add_language;
    NULL;
  END add_language;


  PROCEDURE insert_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_rec                     IN  ovtv_rec_type
                        ,x_ovtv_rec                     OUT NOCOPY ovtv_rec_type
                        ) IS
    l_ovtv_rec                        ovtv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_ovd_rul_tmls';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_ovd_rul_tmls;
    l_ovtv_rec := p_ovtv_rec;



    okl_ovt_pvt.insert_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_ovtv_rec      => l_ovtv_rec
                              ,x_ovtv_rec      => x_ovtv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_ovtv_rec := x_ovtv_rec;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','insert_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_ovd_rul_tmls;


  PROCEDURE insert_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_tbl                     IN  ovtv_tbl_type
                        ,x_ovtv_tbl                     OUT NOCOPY ovtv_tbl_type
                        ) IS
    l_ovtv_tbl                        ovtv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_ovd_rul_tmls';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                        NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_ovd_rul_tmls;
    l_ovtv_tbl :=  p_ovtv_tbl;



    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;

      LOOP
        insert_ovd_rul_tmls (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovtv_rec      => p_ovtv_tbl(i)
                          ,x_ovtv_rec      => x_ovtv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_ovtv_tbl.LAST);

          i := p_ovtv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local table structure using output table from pvt api */
    l_ovtv_tbl := x_ovtv_tbl;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','insert_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_ovd_rul_tmls;

  PROCEDURE lock_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_rec                     IN  ovtv_rec_type
                        ) IS

    l_ovtv_rec                        ovtv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT lock_ovd_rul_tmls;
    l_ovtv_rec := p_ovtv_rec;

    okl_ovt_pvt.lock_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_ovtv_rec      => l_ovtv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','lock_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_ovd_rul_tmls;

  PROCEDURE lock_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_tbl                     IN  ovtv_tbl_type
                        ) IS

    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT lock_ovd_rul_tmls;

    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;

      LOOP
        lock_ovd_rul_tmls (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovtv_rec      => p_ovtv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
 		 	    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_ovtv_tbl.LAST);

          i := p_ovtv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','lock_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_ovd_rul_tmls;

  PROCEDURE update_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_rec                     IN  ovtv_rec_type
                        ,x_ovtv_rec                     OUT NOCOPY ovtv_rec_type
                        ) IS
    l_ovtv_rec                        ovtv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_ovd_rul_tmls';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_ovd_rul_tmls;
    l_ovtv_rec := p_ovtv_rec;



    okl_ovt_pvt.update_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_ovtv_rec      => l_ovtv_rec
                              ,x_ovtv_rec      => x_ovtv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_ovtv_rec := x_ovtv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','update_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_ovd_rul_tmls;


  PROCEDURE update_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_tbl                     IN  ovtv_tbl_type
                        ,x_ovtv_tbl                     OUT NOCOPY ovtv_tbl_type
                        ) IS
    l_ovtv_tbl                        ovtv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_ovd_rul_tmls';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_ovd_rul_tmls;
    l_ovtv_tbl :=  p_ovtv_tbl;



    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;

      LOOP
        update_ovd_rul_tmls (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovtv_rec      => p_ovtv_tbl(i)
                          ,x_ovtv_rec      => x_ovtv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_ovtv_tbl.LAST);

          i := p_ovtv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local table structure using output table from pvt api */
    l_ovtv_tbl := x_ovtv_tbl;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','update_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_ovd_rul_tmls;

  PROCEDURE delete_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_rec                     IN  ovtv_rec_type
                        ) IS
    l_ovtv_rec                        ovtv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_ovd_rul_tmls';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT delete_ovd_rul_tmls;
    l_ovtv_rec := p_ovtv_rec;



    okl_ovt_pvt.delete_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_ovtv_rec      => l_ovtv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','delete_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_ovd_rul_tmls;


  PROCEDURE delete_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_tbl                     IN  ovtv_tbl_type
                        ) IS
    l_ovtv_tbl                        ovtv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_ovd_rul_tmls';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT delete_ovd_rul_tmls;
    l_ovtv_tbl :=  p_ovtv_tbl;



    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;

      LOOP
        delete_ovd_rul_tmls (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovtv_rec      => p_ovtv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_ovtv_tbl.LAST);

          i := p_ovtv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','delete_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_ovd_rul_tmls;

  PROCEDURE validate_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_rec                     IN  ovtv_rec_type
                        ) IS
    l_ovtv_rec                        ovtv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_ovd_rul_tmls';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validate_ovd_rul_tmls;
    l_ovtv_rec := p_ovtv_rec;



    okl_ovt_pvt.validate_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_ovtv_rec      => l_ovtv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','validate_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_ovd_rul_tmls;


  PROCEDURE validate_ovd_rul_tmls(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_ovtv_tbl                     IN  ovtv_tbl_type
                        ) IS
    l_ovtv_tbl                        ovtv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_ovd_rul_tmls';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validate_ovd_rul_tmls;
    l_ovtv_tbl :=  p_ovtv_tbl;



    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;

      LOOP
        validate_ovd_rul_tmls (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovtv_rec      => p_ovtv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_ovtv_tbl.LAST);

          i := p_ovtv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_ovd_rul_tmls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_OVD_RUL_TMLS_PUB','validate_ovd_rul_tmls');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_ovd_rul_tmls;


END OKL_OVD_RUL_TMLS_PUB;

/
