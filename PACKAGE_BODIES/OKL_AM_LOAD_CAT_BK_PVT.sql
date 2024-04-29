--------------------------------------------------------
--  DDL for Package Body OKL_AM_LOAD_CAT_BK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_LOAD_CAT_BK_PVT" AS
/* $Header: OKLRLCBB.pls 120.4 2006/07/11 09:49:40 dkagrawa noship $ */

-- Start of comments
--
-- Procedure Name  : create_hold_setup_trx
-- Description     : The main body of the package. This procedure finds all the unique combinations of
--                   category_id and book_type_code from fa_category_book_defaults and loads them into
--                   okl_amort_hold_setups_v. Before loading the data into okl_amort_hold_setups_v, API
--                   queries this view to make sure that the category and book type code combination
--                   does not already exist.
-- Business Rules  :
-- Version         : 1.0
-- History         : SECHAWLA 05-MAY-04 3578894 : Added 'TAX' book class in cursor l_facatbookdef_csr
-- End of comments


   PROCEDURE create_hold_setup_trx(   p_api_version           IN   NUMBER,
                                  p_init_msg_list         IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  p_book_type_code        IN   fa_book_controls.book_type_code%TYPE,
                                  x_return_status         OUT  NOCOPY VARCHAR2,
                                  x_msg_count             OUT  NOCOPY NUMBER,
                                  x_msg_data              OUT  NOCOPY VARCHAR2,
                                  x_amhv_tbl              OUT  NOCOPY amhv_tbl_type
                                  ) IS



   l_return_status                   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_dummy                           VARCHAR2(1);


   lp_amhv_tbl                       amhv_tbl_type;
   lx_amhv_tbl                       amhv_tbl_type;
   i                                 NUMBER ;

   l_api_version                     CONSTANT NUMBER := 1;
   l_api_name                        CONSTANT VARCHAR2(30) := 'create_hold_setup_trx';

   -- This cursor selects all unique combinations of category_id and book_type_code from fa_category_book_defaults
   CURSOR l_facatbookdef_csr(p_book_type_code fa_book_controls.book_type_code%TYPE) IS
   -- SECHAWLA 05-MAY-04 3578894 : fetch category/book combinations for both corporate and tax books
   SELECT DISTINCT fac.category_id, fac.book_type_code
   FROM   fa_category_book_defaults fac, fa_book_controls fbc
   WHERE fac.book_type_code = fbc.book_type_code AND fbc.book_class IN ('CORPORATE','TAX')
   AND   fbc.distribution_source_book = NVL(p_book_type_code, fbc.distribution_source_book);

   -- This cursor is used to check if the unique combination of category_id and book_type_code from
   -- fa_category_book_defaults already exists in okl_amort_hold_setups_v
   CURSOR l_amortholdsetup_csr(p_id number, p_code varchar2) IS
   SELECT 'x'
   FROM   OKL_AMORT_HOLD_SETUPS
   WHERE  category_id = p_id
   AND    book_type_code = p_code;


   BEGIN

      l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);



      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      i := 0;

      --  loop thru all the rows from cursor l_facatbookdef_csr and put them in the table lp_amhv_tbl if
      --  those rows don't already exist in okl_amort_hold_setups_v
      FOR l_facatbookdef_rec IN l_facatbookdef_csr(p_book_type_code) LOOP
          OPEN  l_amortholdsetup_csr(l_facatbookdef_rec.category_id, l_facatbookdef_rec.book_type_code);
          FETCH l_amortholdsetup_csr INTO l_dummy;

          IF l_amortholdsetup_csr%NOTFOUND THEN
             lp_amhv_tbl(i).book_type_code := l_facatbookdef_rec.book_type_code ;
             lp_amhv_tbl(i).category_id := l_facatbookdef_rec.category_id;
             i := i + 1;


          END IF;
          CLOSE l_amortholdsetup_csr;

      END LOOP;


      IF (lp_amhv_tbl.COUNT > 0 ) THEN
             okl_amort_hold_setups_pub.insert_amort_hold_setups(
                                    p_api_version                  => 1.0
                                    ,p_init_msg_list                => FND_API.G_FALSE
                                    ,x_return_status                => x_return_status
                                    ,x_msg_count                    => x_msg_count
                                    ,x_msg_data                     => x_msg_data
                                    ,p_amhv_tbl                     => lp_amhv_tbl
                                    ,x_amhv_tbl                     => lx_amhv_tbl);

             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;

             x_amhv_tbl := lx_amhv_tbl;
      END IF;



      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF l_amortholdsetup_csr%ISOPEN THEN
           CLOSE l_amortholdsetup_csr;
        END IF;
        IF l_facatbookdef_csr%ISOPEN THEN
           CLOSE l_facatbookdef_csr;
        END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF l_amortholdsetup_csr%ISOPEN THEN
           CLOSE l_amortholdsetup_csr;
        END IF;
        IF l_facatbookdef_csr%ISOPEN THEN
           CLOSE l_facatbookdef_csr;
        END IF;
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        IF l_amortholdsetup_csr%ISOPEN THEN
           CLOSE l_amortholdsetup_csr;
        END IF;
        IF l_facatbookdef_csr%ISOPEN THEN
           CLOSE l_facatbookdef_csr;
        END IF;
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
   END create_hold_setup_trx;
END OKL_AM_LOAD_CAT_BK_PVT;

/
