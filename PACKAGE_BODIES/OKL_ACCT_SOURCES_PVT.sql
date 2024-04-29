--------------------------------------------------------
--  DDL for Package Body OKL_ACCT_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCT_SOURCES_PVT" AS
/* $Header: OKLRASEB.pls 120.4.12010000.3 2008/10/01 23:45:32 rkuttiya ship $ */


  PROCEDURE insert_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_rec                     IN  asev_rec_type
                        ,x_asev_rec                     OUT NOCOPY asev_rec_type
                        ) IS
    l_asev_rec                        asev_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_acct_sources';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT insert_acct_sources;
    l_asev_rec := p_asev_rec;

    Okl_Ase_Pvt.insert_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_asev_rec      => l_asev_rec
                              ,x_asev_rec      => x_asev_rec
                              );

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_asev_rec := x_asev_rec;


  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO insert_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','insert_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END insert_acct_sources;


  PROCEDURE insert_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_tbl                     IN  asev_tbl_type
                        ,x_asev_tbl                     OUT NOCOPY asev_tbl_type
                        ) IS
    l_asev_tbl                        asev_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_acct_sources';
    l_return_status                   VARCHAR2(1)   := Fnd_Api.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := Fnd_Api.G_RET_STS_SUCCESS;
    i                        NUMBER;

  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT insert_acct_sources;
    l_asev_tbl :=  p_asev_tbl;

    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;

      LOOP
       -- Insert if the amount <> 0

         IF p_asev_tbl(i).amount <> 0 THEN

          insert_acct_sources (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_asev_rec      => p_asev_tbl(i)
                          ,x_asev_rec      => x_asev_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          END IF;

          EXIT WHEN (i = p_asev_tbl.LAST);

          i := p_asev_tbl.NEXT(i);



       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local asele structure using output asele from pvt api */
    l_asev_tbl := x_asev_tbl;

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO insert_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','insert_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END insert_acct_sources;


     --Added by gboomina on 14-Oct-2005 for Accruals Performance Improvement
     --Bug 4662173 - Start of Changes

     PROCEDURE insert_acct_sources_bulk(
                            p_api_version                  IN  NUMBER
                           ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                           ,x_return_status                OUT NOCOPY VARCHAR2
                           ,x_msg_count                    OUT NOCOPY NUMBER
                           ,x_msg_data                     OUT NOCOPY VARCHAR2
                           ,p_asev_tbl                     IN  asev_tbl_type
                           ,x_asev_tbl                     OUT NOCOPY asev_tbl_type
                           ) IS
       l_asev_tbl                        asev_tbl_type;
       l_data                            VARCHAR2(100);
       l_count                           NUMBER ;
       l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_acct_sources_bulk';
       l_return_status                   VARCHAR2(1)   := Fnd_Api.G_RET_STS_SUCCESS;
       l_overall_status                          VARCHAR2(1)   := Fnd_Api.G_RET_STS_SUCCESS;
       i                                 NUMBER;

     BEGIN
       x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
       SAVEPOINT insert_acct_sources;
       l_asev_tbl :=  p_asev_tbl;

       IF (p_asev_tbl.COUNT > 0) THEN
           --Modified by kthiruva on 27-Oct-2005.
           --Ensure that the x_return_Status is stored in l_return_Status
           --as it is the parameter being compared.
           Okl_Ase_Pvt.insert_row_bulk (
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => l_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_asev_tbl      => p_asev_tbl
                             ,x_asev_tbl      => x_asev_tbl
                             );

          IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
             RAISE Fnd_Api.G_EXC_ERROR;
          ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

        END IF;

     EXCEPTION
       WHEN Fnd_Api.G_EXC_ERROR THEN
         ROLLBACK TO insert_acct_sources;
         x_return_status := Fnd_Api.G_RET_STS_ERROR;

         Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                                  ,p_count   => x_msg_count
                                  ,p_data    => x_msg_data);

       WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO insert_acct_sources;
         x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
         Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                                  ,p_count   => x_msg_count
                                  ,p_data    => x_msg_data);

       WHEN OTHERS THEN
         Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','insert_acct_sources_bulk');
         -- store SQL error message on message stack for caller
         Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                                  ,p_count   => x_msg_count
                                  ,p_data    => x_msg_data);
         -- notify caller of an UNEXPECTED error
         x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     END insert_acct_sources_bulk;
     --Bug 4662173 - End of Changes

  PROCEDURE lock_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_rec                     IN  asev_rec_type
                        ) IS

    l_asev_rec                        asev_rec_type;
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT lock_acct_sources;
    l_asev_rec := p_asev_rec;

    Okl_Ase_Pvt.lock_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_asev_rec      => l_asev_rec
                              );

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO lock_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','lock_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END lock_acct_sources;

  PROCEDURE lock_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_tbl                     IN  asev_tbl_type
                        ) IS

    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := Fnd_Api.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT lock_acct_sources;

    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;

      LOOP
        lock_acct_sources (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_asev_rec      => p_asev_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
 		 	    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_asev_tbl.LAST);

          i := p_asev_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO lock_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','lock_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END lock_acct_sources;

  PROCEDURE update_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_rec                     IN  asev_rec_type
                        ,x_asev_rec                     OUT NOCOPY asev_rec_type
                        ) IS
    l_asev_rec                        asev_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acct_sources';
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT update_acct_sources;
    l_asev_rec := p_asev_rec;

    /* consulting pre-processing user hook call */

    /* vertical user pre-processing hook call */

    Okl_Ase_Pvt.update_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_asev_rec      => l_asev_rec
                              ,x_asev_rec      => x_asev_rec
                              );

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_asev_rec := x_asev_rec;

    /* vertical user post-processing hook call */

    /* consulting post-processing user hook call */

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','update_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END update_acct_sources;


  PROCEDURE update_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_tbl                     IN  asev_tbl_type
                        ,x_asev_tbl                     OUT NOCOPY asev_tbl_type
                        ) IS
    l_asev_tbl                        asev_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acct_sources';
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := Fnd_Api.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT update_acct_sources;
    l_asev_tbl :=  p_asev_tbl;

    /* consulting pre-processing user hook call */

    /* vertical user pre-processing hook call */

    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;

      LOOP
        update_acct_sources (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_asev_rec      => p_asev_tbl(i)
                          ,x_asev_rec      => x_asev_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_asev_tbl.LAST);

          i := p_asev_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local asele structure using output asele from pvt api */
    l_asev_tbl := x_asev_tbl;

    /* vertical user post-processing hook call */

    /* consulting post-processing user hook call */

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','update_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END update_acct_sources;

  PROCEDURE delete_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_rec                     IN  asev_rec_type
                        ) IS
    l_asev_rec                        asev_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_acct_sources';
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;


-- Added by Santonyr to fix the bug 3089327 on 07th Aug, 2003

  l_tcn_id OKL_TRX_CONTRACTS.ID%TYPE;
  l_tsu_code OKL_TRX_CONTRACTS.TSU_CODE%TYPE;

  CURSOR tcl_csr(v_source_id NUMBER) IS
  SELECT tcn_id
  FROM OKL_TXL_CNTRCT_LNS
  WHERE ID = v_source_id;

  CURSOR tcn_csr(v_tcn_id NUMBER) IS
  SELECT tsu_code
  FROM OKL_TRX_CONTRACTS
  WHERE ID = v_tcn_id;

  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT delete_acct_sources;
    l_asev_rec := p_asev_rec;

    /* consulting pre-processing user hook call */

    /* vertical user pre-processing hook call */

-- Added by Santonyr to fix the bug 3089327 on 07th Aug, 2003

   OPEN tcl_csr(l_asev_rec.source_id);
   FETCH tcl_csr INTO l_tcn_id;
   CLOSE tcl_csr;

   OPEN tcn_csr(l_tcn_id);
   FETCH tcn_csr INTO l_tsu_code;
   CLOSE tcn_csr;

   IF (l_tsu_code = 'CANCELED') THEN

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_TRX_CANCELED');

      RAISE Okl_Api.G_EXCEPTION_ERROR;

   END IF;


    Okl_Ase_Pvt.delete_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_asev_rec      => l_asev_rec
                              );

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* vertical user post-processing hook call */

    /* consulting post-processing user hook call */

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO delete_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','delete_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END delete_acct_sources;


  PROCEDURE delete_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_tbl                     IN  asev_tbl_type
                        ) IS
    l_asev_tbl                        asev_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_acct_sources';
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := Fnd_Api.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT delete_acct_sources;
    l_asev_tbl :=  p_asev_tbl;

    /* consulting pre-processing user hook call */

    /* vertical user pre-processing hook call */

    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;

      LOOP
        delete_acct_sources (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_asev_rec      => p_asev_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_asev_tbl.LAST);

          i := p_asev_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* vertical user post-processing hook call */

    /* consulting post-processing user hook call */

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO delete_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','delete_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END delete_acct_sources;

  PROCEDURE validate_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_rec                     IN  asev_rec_type
                        ) IS
    l_asev_rec                        asev_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_acct_sources';
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT validate_acct_sources;
    l_asev_rec := p_asev_rec;

    /* consulting pre-processing user hook call */

    /* vertical user pre-processing hook call */

    Okl_Ase_Pvt.validate_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_asev_rec      => l_asev_rec
                              );

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* vertical user post-processing hook call */

    /* consulting post-processing user hook call */

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO validate_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','validate_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END validate_acct_sources;


  PROCEDURE validate_acct_sources(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_asev_tbl                     IN  asev_tbl_type
                        ) IS
    l_asev_tbl                        asev_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_acct_sources';
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := Fnd_Api.G_RET_STS_SUCCESS;
    i                                 NUMBER;

  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT validate_acct_sources;
    l_asev_tbl :=  p_asev_tbl;

    /* consulting pre-processing user hook call */

    /* vertical user pre-processing hook call */

    IF (p_asev_tbl.COUNT > 0) THEN
      i := p_asev_tbl.FIRST;

      LOOP
        validate_acct_sources (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_asev_rec      => p_asev_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_asev_tbl.LAST);

          i := p_asev_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* vertical user post-processing hook call */

    /* consulting post-processing user hook call */


  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO validate_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_sources;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','validate_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  END validate_acct_sources;

  PROCEDURE update_acct_src_custom_status(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN  asev_rec_type,
    x_asev_rec                     OUT NOCOPY asev_rec_type) IS

    l_asev_rec                        asev_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acct_src_custom_status';
    l_return_status                   VARCHAR2(1)    := Fnd_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT update_acct_src_custom_status;
    l_asev_rec:= p_asev_rec;

    /* consulting pre-processing user hook call */

    /* vertical user pre-processing hook call */

    Okl_Ase_Pvt.update_row(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_asev_rec      => l_asev_rec
                              ,x_asev_rec      => x_asev_rec
                              );

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_asev_rec := x_asev_rec;

    /* vertical user post-processing hook call */

    /* consulting post-processing user hook call */

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_src_custom_status;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_src_custom_status;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_acct_sources_Pvt','update_acct_sources');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

  END   update_acct_src_custom_status;


END Okl_acct_sources_Pvt;

/
