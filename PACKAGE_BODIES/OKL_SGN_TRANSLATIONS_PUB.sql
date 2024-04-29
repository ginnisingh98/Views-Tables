--------------------------------------------------------
--  DDL for Package Body OKL_SGN_TRANSLATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SGN_TRANSLATIONS_PUB" AS
/* $Header: OKLPSGTB.pls 120.3 2005/10/30 04:28:20 appldev noship $ */

  PROCEDURE add_language IS
  BEGIN
--    okl_sgn_pvt.add_language;
    NULL;
  END add_language;


  PROCEDURE insert_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN  sgnv_rec_type,
    x_sgnv_rec                     OUT NOCOPY sgnv_rec_type) IS

	l_sgnv_rec                        sgnv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_sgn_translations';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_sgn_translations;
    l_sgnv_rec := p_sgnv_rec;



    okl_sgt_pvt.insert_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_sgnv_rec      => l_sgnv_rec
                          ,x_sgnv_rec      => x_sgnv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','insert_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_sgn_translations;

  PROCEDURE insert_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type) IS

    l_sgnv_tbl                        sgnv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_sgn_translations';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status		          VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_sgn_translations;
    l_sgnv_tbl :=  p_sgnv_tbl;



    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;

      LOOP
        insert_sgn_translations (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => OKL_API.G_FALSE -- Bug Number: 3992148
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_sgnv_rec      => p_sgnv_tbl(i)
                          ,x_sgnv_rec      => x_sgnv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_sgnv_tbl.LAST);

          i := p_sgnv_tbl.NEXT(i);

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
      ROLLBACK TO insert_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','insert_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_sgn_translations;

  PROCEDURE lock_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN sgnv_rec_type) IS

    l_sgnv_rec                        sgnv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT lock_sgn_translations;
    l_sgnv_rec := p_sgnv_rec;

    okl_sgt_pvt.lock_row(p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => l_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_sgnv_rec      => l_sgnv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','lock_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_sgn_translations;

  PROCEDURE lock_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type) IS

    l_return_status                VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                              NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT lock_sgn_translations;

    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;

      LOOP
        lock_sgn_translations (p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => x_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_sgnv_rec      => p_sgnv_tbl(i));

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
 		 	    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_sgnv_tbl.LAST);

          i := p_sgnv_tbl.NEXT(i);

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
      ROLLBACK TO lock_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','lock_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_sgn_translations;

  PROCEDURE update_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN  sgnv_rec_type,
    x_sgnv_rec                     OUT NOCOPY sgnv_rec_type) IS

    l_sgnv_rec                        sgnv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_sgn_translations';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_sgn_translations;
    l_sgnv_rec := p_sgnv_rec;



    okl_sgt_pvt.update_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_sgnv_rec      => l_sgnv_rec
                          ,x_sgnv_rec      => x_sgnv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','update_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_sgn_translations;

  PROCEDURE update_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type) IS

    l_sgnv_tbl                        sgnv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_sgn_translations';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			      VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_sgn_translations;
    l_sgnv_tbl :=  p_sgnv_tbl;



    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;

      LOOP
        update_sgn_translations (p_api_version   => p_api_version
                                ,p_init_msg_list => p_init_msg_list
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                                ,p_sgnv_rec      => p_sgnv_tbl(i)
                                ,x_sgnv_rec      => x_sgnv_tbl(i));

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_sgnv_tbl.LAST);

          i := p_sgnv_tbl.NEXT(i);

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
      ROLLBACK TO update_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','update_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_sgn_translations;

  PROCEDURE delete_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN  sgnv_rec_type) IS

    l_sgnv_rec                        sgnv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_sgn_translations';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT delete_sgn_translations;
    l_sgnv_rec := p_sgnv_rec;



    okl_sgt_pvt.delete_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_sgnv_rec      => l_sgnv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','delete_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_sgn_translations;

  PROCEDURE delete_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type) IS

    l_sgnv_tbl                        sgnv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_sgn_translations';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			      VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT delete_sgn_translations;
    l_sgnv_tbl :=  p_sgnv_tbl;



    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;

      LOOP
        delete_sgn_translations (p_api_version   => p_api_version
                                ,p_init_msg_list => p_init_msg_list
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                                ,p_sgnv_rec      => p_sgnv_tbl(i));

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_sgnv_tbl.LAST);

          i := p_sgnv_tbl.NEXT(i);

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
      ROLLBACK TO delete_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','delete_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_sgn_translations;

  PROCEDURE validate_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN  sgnv_rec_type,
    x_sgnv_rec                     OUT NOCOPY sgnv_rec_type) IS
    l_sgnv_rec                        sgnv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_sgn_translations';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validate_sgn_translations;
    l_sgnv_rec := p_sgnv_rec;



    okl_sgt_pvt.validate_row(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_sgnv_rec      => l_sgnv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','validate_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_sgn_translations;

  PROCEDURE validate_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type) IS

    l_sgnv_tbl                        sgnv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_sgn_translations';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			      VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validate_sgn_translations;
    l_sgnv_tbl :=  p_sgnv_tbl;



    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;

      LOOP
        validate_sgn_translations (p_api_version   => p_api_version
                                ,p_init_msg_list => p_init_msg_list
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                                ,p_sgnv_rec      => p_sgnv_tbl(i)
                                ,x_sgnv_rec      => x_sgnv_tbl(i));

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_sgnv_tbl.LAST);

          i := p_sgnv_tbl.NEXT(i);

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
      ROLLBACK TO validate_sgn_translations;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_sgn_translations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SGN_TRANSLATIONS_PUB','validate_sgn_translations');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_sgn_translations;

END OKL_SGN_TRANSLATIONS_PUB;

/
