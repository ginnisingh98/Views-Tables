--------------------------------------------------------
--  DDL for Package Body OKL_PDT_OPT_VALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PDT_OPT_VALS_PUB" AS
/* $Header: OKLPPOVB.pls 115.9 2004/04/13 10:57:44 rnaik noship $ */

  PROCEDURE add_language IS
  BEGIN
--    okl_pov_pvt.add_language;
    NULL;
  END add_language;


  PROCEDURE insert_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_rec                     IN  povv_rec_type
                        ,x_povv_rec                     OUT NOCOPY povv_rec_type
                        ) IS
    l_povv_rec                        povv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_pdt_opt_vals';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_pdt_opt_vals;
    l_povv_rec := p_povv_rec;



    okl_pov_pvt.insert_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_povv_rec      => l_povv_rec
                              ,x_povv_rec      => x_povv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_povv_rec := x_povv_rec;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','insert_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_pdt_opt_vals;


  PROCEDURE insert_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_tbl                     IN  povv_tbl_type
                        ,x_povv_tbl                     OUT NOCOPY povv_tbl_type
                        ) IS
    l_povv_tbl                        povv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_pdt_opt_vals';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                        NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_pdt_opt_vals;
    l_povv_tbl :=  p_povv_tbl;



    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;

      LOOP
        insert_pdt_opt_vals (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_povv_rec      => p_povv_tbl(i)
                          ,x_povv_rec      => x_povv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_povv_tbl.LAST);

          i := p_povv_tbl.NEXT(i);

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
    l_povv_tbl := x_povv_tbl;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','insert_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_pdt_opt_vals;

  PROCEDURE lock_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_rec                     IN  povv_rec_type
                        ) IS

    l_povv_rec                        povv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT lock_pdt_opt_vals;
    l_povv_rec := p_povv_rec;

    okl_pov_pvt.lock_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_povv_rec      => l_povv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','lock_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_pdt_opt_vals;

  PROCEDURE lock_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_tbl                     IN  povv_tbl_type
                        ) IS

    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT lock_pdt_opt_vals;

    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;

      LOOP
        lock_pdt_opt_vals (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_povv_rec      => p_povv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
 		 	    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_povv_tbl.LAST);

          i := p_povv_tbl.NEXT(i);

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
      ROLLBACK TO lock_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','lock_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_pdt_opt_vals;

  PROCEDURE update_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_rec                     IN  povv_rec_type
                        ,x_povv_rec                     OUT NOCOPY povv_rec_type
                        ) IS
    l_povv_rec                        povv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_pdt_opt_vals';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_pdt_opt_vals;
    l_povv_rec := p_povv_rec;



    okl_pov_pvt.update_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_povv_rec      => l_povv_rec
                              ,x_povv_rec      => x_povv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_povv_rec := x_povv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','update_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_pdt_opt_vals;


  PROCEDURE update_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_tbl                     IN  povv_tbl_type
                        ,x_povv_tbl                     OUT NOCOPY povv_tbl_type
                        ) IS
    l_povv_tbl                        povv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_pdt_opt_vals';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_pdt_opt_vals;
    l_povv_tbl :=  p_povv_tbl;



    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;

      LOOP
        update_pdt_opt_vals (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_povv_rec      => p_povv_tbl(i)
                          ,x_povv_rec      => x_povv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_povv_tbl.LAST);

          i := p_povv_tbl.NEXT(i);

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
    l_povv_tbl := x_povv_tbl;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','update_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_pdt_opt_vals;

  PROCEDURE delete_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_rec                     IN  povv_rec_type
                        ) IS
    l_povv_rec                        povv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_pdt_opt_vals';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT delete_pdt_opt_vals;
    l_povv_rec := p_povv_rec;



    okl_pov_pvt.delete_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_povv_rec      => l_povv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','delete_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_pdt_opt_vals;


  PROCEDURE delete_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_tbl                     IN  povv_tbl_type
                        ) IS
    l_povv_tbl                        povv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_pdt_opt_vals';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT delete_pdt_opt_vals;
    l_povv_tbl :=  p_povv_tbl;



    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;

      LOOP
        delete_pdt_opt_vals (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_povv_rec      => p_povv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_povv_tbl.LAST);

          i := p_povv_tbl.NEXT(i);

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
      ROLLBACK TO delete_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','delete_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_pdt_opt_vals;

  PROCEDURE validate_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_rec                     IN  povv_rec_type
                        ) IS
    l_povv_rec                        povv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_pdt_opt_vals';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validate_pdt_opt_vals;
    l_povv_rec := p_povv_rec;



    okl_pov_pvt.validate_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_povv_rec      => l_povv_rec
                              );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','validate_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_pdt_opt_vals;


  PROCEDURE validate_pdt_opt_vals(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_povv_tbl                     IN  povv_tbl_type
                        ) IS
    l_povv_tbl                        povv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_pdt_opt_vals';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validate_pdt_opt_vals;
    l_povv_tbl :=  p_povv_tbl;



    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;

      LOOP
        validate_pdt_opt_vals (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_povv_rec      => p_povv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_povv_tbl.LAST);

          i := p_povv_tbl.NEXT(i);

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
      ROLLBACK TO validate_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_pdt_opt_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_OPT_VALS_PUB','validate_pdt_opt_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_pdt_opt_vals;


END OKL_PDT_OPT_VALS_PUB;

/
