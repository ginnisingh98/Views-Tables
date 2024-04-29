--------------------------------------------------------
--  DDL for Package Body OKL_INTEREST_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTEREST_MAINT_PVT" AS
/* $Header: OKLRINMB.pls 115.6 2003/05/03 17:38:14 hkpatel noship $ */


FUNCTION overlap_exists(p_idx_type  IN VARCHAR2,
                        p_idx_name  IN VARCHAR2,
                        p_datetime_valid IN DATE,
                        p_datetime_invalid IN DATE)

               RETURN VARCHAR2

  IS


  TYPE ref_cursor IS REF CURSOR;
  check_csr ref_cursor;


  l_dummy VARCHAR2(1);
  l_overlap_exists VARCHAR2(1) := OKL_API.G_FALSE;
  l_datetime_valid DATE;
  l_datetime_invalid DATE;

  l_stmt  VARCHAR2(2000);
  l_stmt_org VARCHAR2(2000);
  l_where VARCHAR2(2000);
  l_exist VARCHAR2(10);


  BEGIN



  l_stmt_org := ' SELECT datetime_valid,
              datetime_invalid
              FROM OKL_INDICES_V idx, OKL_INDEX_VALUES_V idxv
              WHERE idx.id = idxv.idx_id
              AND idx.name =     ' || '''' || ':1'   || '''' ||
            ' AND idx.idx_type = ' || '''' || ':2'   || '''' ;




   IF (p_datetime_invalid IS NOT NULL) THEN
       l_where := ' AND idxv.datetime_invalid IS NOT NULL
                   AND (( ' || '''' || ':3'|| '''' ||
                          ' BETWEEN idxv.datetime_valid AND idxv.datetime_invalid) OR
                ( ' || '''' || ':4' ||  '''' ||
                  ' BETWEEN idxv.datetime_valid AND idxv.datetime_invalid))';

      l_stmt := l_stmt_org || l_where;

      OPEN check_csr FOR l_stmt USING p_idx_name,
				      p_idx_type,
				      p_datetime_valid ,
				      p_datetime_invalid;

      FETCH check_csr INTO l_datetime_valid,
                           l_datetime_invalid;
      IF check_csr%NOTFOUND THEN
         CLOSE check_csr;
         l_where :=  ' AND idxv.datetime_invalid IS NULL
                  AND ' || '''' || ':5'  || '''' ||
                      ' > idxv.datetime_valid
                       AND ' || '''' || ':6'  || '''' || ' > idxv.datetime_valid';

         l_stmt := l_stmt_org || l_where;
         OPEN check_csr FOR l_stmt USING p_idx_name,
				      p_idx_type,
				      p_datetime_valid ,
				      p_datetime_invalid,
				      p_datetime_valid ,
				      p_datetime_invalid;

         FETCH check_csr INTO l_datetime_valid,
                                 l_datetime_invalid;
         IF (check_csr%NOTFOUND) THEN
             l_overlap_exists := OKL_API.G_FALSE;
         ELSE
             l_overlap_exists := OKL_API.G_TRUE;
         END IF;
         CLOSE check_csr;
      ELSE
         l_overlap_exists := OKL_API.G_TRUE;
         CLOSE check_csr;
      END IF;


   ELSE

      l_where := '  AND idxv.datetime_invalid IS NOT NULL
                    AND ( ' || '''' || ':3' || '''' ||
                  ' BETWEEN idxv.datetime_valid AND idxv.datetime_invalid)';

      l_stmt := l_stmt_org || l_where;

      OPEN check_csr FOR l_stmt USING p_idx_name,
				      p_idx_type,
				      p_datetime_valid;

      FETCH check_csr INTO l_datetime_valid,
                      l_datetime_invalid;
      IF check_csr%NOTFOUND THEN

          CLOSE check_csr;
          l_where := ' AND idxv.datetime_invalid IS NULL
                       AND ' || '''' || ':4'   || '''' ||
                       ' > idxv.datetime_valid' ;

          l_stmt := l_stmt_org || l_where;

          OPEN check_csr FOR l_stmt USING p_idx_name,
				          p_idx_type,
				          p_datetime_valid,
					  p_datetime_valid;

          FETCH check_csr INTO l_datetime_valid,
                              l_datetime_invalid;
          IF (check_csr%NOTFOUND) THEN

              l_overlap_exists := OKL_API.G_FALSE;
          ELSE

              l_overlap_exists := OKL_API.G_TRUE;
          END IF;

          CLOSE check_csr;

      ELSE

          l_overlap_exists := OKL_API.G_TRUE;
          CLOSE check_csr;

      END IF;

   END IF;


   RETURN(l_overlap_exists);


END overlap_exists;


FUNCTION overlap_exists  (p_idx_id      IN NUMBER,
                          p_datetime_valid    IN DATE,
                          p_datetime_invalid    IN DATE)

               RETURN VARCHAR2

 IS


TYPE ref_cursor IS REF CURSOR;
check_csr ref_cursor;




l_dummy VARCHAR2(1);
l_overlap_exists VARCHAR2(1) := OKL_API.G_FALSE;
l_datetime_valid DATE;
l_datetime_invalid DATE;

l_stmt  VARCHAR2(2000);
l_stmt_org VARCHAR2(2000);
l_where VARCHAR2(2000);
l_exist VARCHAR2(10);



BEGIN


   l_stmt_org := ' SELECT datetime_valid,
              datetime_invalid
              FROM OKL_INDICES_V idx, OKL_INDEX_VALUES_V idxv
              WHERE idx.id = idxv.idx_id
              AND idx.id  =     ' || ':1'  ;






   IF (p_datetime_invalid IS NOT NULL) THEN
       l_where := ' AND idxv.datetime_invalid IS NOT NULL
                   AND (( ' || '''' || ':2'  || '''' ||
                          ' BETWEEN idxv.datetime_valid AND idxv.datetime_invalid) OR
                ( ' || '''' || ':3'  ||  '''' ||
                  ' BETWEEN idxv.datetime_valid AND idxv.datetime_invalid))';

       l_stmt := l_stmt_org || l_where;

       OPEN check_csr FOR l_stmt USING p_idx_id,
				       p_datetime_valid,
			   	       p_datetime_invalid;


       FETCH check_csr INTO l_datetime_valid,
                           l_datetime_invalid;
       IF check_csr%NOTFOUND THEN
          CLOSE check_csr;
          l_where :=  ' AND idxv.datetime_invalid IS NULL
                  AND ' || '''' || ':4'   || '''' ||
                      ' > idxv.datetime_valid
                       AND ' || '''' || ':5' || '''' || ' > idxv.datetime_valid';

          l_stmt := l_stmt_org || l_where;

          OPEN check_csr FOR l_stmt USING p_idx_id,
				          p_datetime_valid,
			   	          p_datetime_invalid,
					  p_datetime_valid,
					  p_datetime_invalid ;

          FETCH check_csr INTO l_datetime_valid,
                                 l_datetime_invalid;
          IF (check_csr%NOTFOUND) THEN
             l_overlap_exists := OKL_API.G_FALSE;
          ELSE
             l_overlap_exists := OKL_API.G_TRUE;
          END IF;
          CLOSE check_csr;
       ELSE
          l_overlap_exists := OKL_API.G_TRUE;
          CLOSE check_csr;
       END IF;


   ELSE

      l_where := '  AND idxv.datetime_invalid IS NOT NULL
                    AND ( ' || '''' || ':2' || '''' ||
                  ' BETWEEN idxv.datetime_valid AND idxv.datetime_invalid)';

      l_stmt := l_stmt_org || l_where;

      OPEN check_csr FOR l_stmt USING p_idx_id,
				      p_datetime_valid ;

      FETCH check_csr INTO l_datetime_valid,
                      l_datetime_invalid;
      IF check_csr%NOTFOUND THEN

         CLOSE check_csr;
         l_where := ' AND idxv.datetime_invalid IS NULL
                       AND ' || '''' || ':3'   || '''' ||
                       ' > idxv.datetime_valid' ;

         l_stmt := l_stmt_org || l_where;

         OPEN check_csr FOR l_stmt USING p_idx_id,
				         p_datetime_valid,
					 p_datetime_valid ;

         FETCH check_csr INTO l_datetime_valid,
                          l_datetime_invalid;
         IF (check_csr%NOTFOUND) THEN

             l_overlap_exists := OKL_API.G_FALSE;
         ELSE

             l_overlap_exists := OKL_API.G_TRUE;
         END IF;
         CLOSE check_csr;
      ELSE
         l_overlap_exists := OKL_API.G_TRUE;
         CLOSE check_csr;
      END IF;

   END IF;


   RETURN(l_overlap_exists);


END overlap_exists;



PROCEDURE INT_HDR_INS_UPDT(p_api_version      IN     NUMBER,
                           p_init_msg_list    IN     VARCHAR2,
                           x_return_status    OUT    NOCOPY VARCHAR2,
                           x_msg_count        OUT    NOCOPY NUMBER,
                           x_msg_data         OUT    NOCOPY VARCHAR2,
                           p_idxv_rec         IN     idxv_rec_type)
IS

  l_idxv_rec_in      idxv_rec_type;
  l_idxv_rec_out     idxv_rec_type;

  l_init_msg_list    VARCHAR2(1) := p_init_msg_list;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_api_name         VARCHAR2(30) := 'INT_HDR_INS_UPDT';
  l_api_version      NUMBER := 1.0;
  l_idx_frequency    OKL_INDICES.IDX_FREQUENCY%TYPE;

  CURSOR freq_csr(v_idx_id NUMBER) IS
  SELECT idx_frequency
  FROM OKL_INDICES idx,
       OKL_INDEX_VALUES ive
  WHERE ive.idx_id = idx.id
  AND   idx.ID = v_idx_id;


BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PVT',
                                            x_return_status);
  IF (l_return_status = OKL_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_Api.G_EXCEPTION_ERROR;
  END IF;

  l_idxv_rec_in := p_idxv_rec;

  IF (p_idxv_rec.id = OKL_API.G_MISS_NUM) OR
     (p_idxv_rec.ID  IS NULL)  THEN

      OKL_INDICES_PUB.CREATE_INDICES(p_api_version   => 1.0,
		                     p_init_msg_list => l_init_msg_list,
                                     x_return_status => l_return_status,
                                     x_msg_count     => l_msg_count,
                                     x_msg_data      => l_msg_data,
                                     p_idxv_rec      => l_idxv_rec_in,
                                     x_idxv_rec      => l_idxv_rec_out);
  ELSE

     OPEN freq_csr(p_idxv_rec.ID);
     FETCH freq_csr INTO l_idx_frequency;

     IF (freq_csr%NOTFOUND) THEN
        NULL;
     ELSE
        IF (l_idx_frequency <> p_idxv_rec.idx_frequency) THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_INT_FREQ_CANNOT_CHANGE');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     CLOSE freq_csr;

     OKL_INDICES_PUB.UPDATE_INDICES(p_api_version            => 1.0,
                                    p_init_msg_list          => l_init_msg_list,
                                    x_return_status          => l_return_status,
                                    x_msg_count              => l_msg_count,
                                    x_msg_data               => l_msg_data,
                                    p_idxv_rec               => l_idxv_rec_in,
                                    x_idxv_rec               => l_idxv_rec_out);
  END IF;


  IF (l_return_status = OKL_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_Api.G_EXCEPTION_ERROR;
  END IF;

  OKL_Api.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
    WHEN OKL_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');

END INT_HDR_INS_UPDT;




PROCEDURE INT_HDR_INS_UPDT(p_api_version     IN    NUMBER,
                           p_init_msg_list   IN    VARCHAR2,
                           x_return_status   OUT   NOCOPY VARCHAR2,
                           x_msg_count       OUT   NOCOPY NUMBER,
                           x_msg_data        OUT   NOCOPY VARCHAR2,
                           p_idxv_tbl        IN    idxv_tbl_type)
IS

    l_api_version               CONSTANT NUMBER := 1.0;
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status            VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER := 0;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);



BEGIN

   IF (p_idxv_tbl.COUNT > 0) THEN

       i := p_idxv_tbl.FIRST;

       LOOP
             INT_HDR_INS_UPDT (
             p_api_version                  => l_api_version,
             p_init_msg_list                => OKL_API.G_FALSE,
             x_return_status                => l_return_status,
             x_msg_count                    => l_msg_count,
             x_msg_data                     => l_msg_data,
             p_idxv_rec                     => p_idxv_tbl(i));


           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
               IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  l_overall_status := l_return_status;
               END IF;
           END IF;

           EXIT WHEN (i = p_idxv_tbl.LAST);

           i := p_idxv_tbl.NEXT(i);

       END LOOP;

       x_return_status := l_overall_status;

   END IF;


END INT_HDR_INS_UPDT;





PROCEDURE INT_DTL_INS_UPDT(p_api_version       IN       NUMBER,
                           p_init_msg_list     IN       VARCHAR2,
                           x_return_status     OUT      NOCOPY VARCHAR2,
                           x_msg_count         OUT      NOCOPY NUMBER,
                           x_msg_data          OUT      NOCOPY VARCHAR2,
                           p_ivev_rec          IN       ivev_rec_type)
IS

  l_error_flag        VARCHAR2(1) := 'N';
  l_api_name          CONSTANT VARCHAR2(40) := 'OKL_INT_DTL_INS_UPDT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;


  l_ivev_rec_in       ivev_rec_type;
  l_ivev_rec_out      ivev_rec_type;



  l_init_msg_list     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_msg_text          VARCHAR2(50);

  i                   NUMBER := 0;


BEGIN


  l_ivev_rec_in := p_ivev_rec;

  IF (p_ivev_rec.datetime_valid IS NOT NULL) THEN

       IF (p_ivev_rec.datetime_invalid IS NOT NULL) THEN

           IF (p_ivev_rec.datetime_invalid < p_ivev_rec.datetime_valid) THEN

                   l_error_flag := 'Y';
                   l_msg_text   := 'OKL_INVALID_TO_DATE';

           END IF;

       END IF;
/*

       IF (overlap_exists(p_ivev_rec.idx_id,
                          p_ivev_rec.datetime_valid,
                          p_ivev_rec.datetime_invalid) = OKL_API.G_TRUE )
       AND (p_ivev_rec.ID = OKL_API.G_MISS_NUM) THEN

                l_error_flag := 'Y';
                l_msg_text := 'OKL_DATE_RANGE_OVERLAP';

       END IF;
*/

  ELSE

       l_error_flag := 'Y';
       l_msg_text := 'OKL_FROM_DATE_MANDATORY';

  END IF;


  IF (l_error_flag = 'N') THEN

        IF (l_ivev_rec_in.ID = OKL_API.G_MISS_NUM) OR
           (l_ivev_rec_in.ID IS NULL)  THEN

            OKL_INDICES_PUB.create_index_values(p_api_version      => 1.0,
                                                p_init_msg_list    => l_init_msg_list,
                                                x_return_status    => l_return_status,
                                                x_msg_count        => l_msg_count,
                                                x_msg_data         => l_msg_data,
                                                p_ivev_rec         => l_ivev_rec_in,
                                                x_ivev_rec         => l_ivev_rec_out);
        ELSE

            OKL_INDICES_PUB.update_index_values(p_api_version      => 1.0,
                                                p_init_msg_list    => l_init_msg_list,
                                                x_return_status    => l_return_status,
                                                x_msg_count        => l_msg_count,
                                                x_msg_data         => l_msg_data,
                                                p_ivev_rec         => l_ivev_rec_in,
                                                x_ivev_rec         => l_ivev_rec_out);
        END IF;


  ELSE

        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => l_msg_text);


  END IF;

  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;


END INT_DTL_INS_UPDT;



PROCEDURE INT_DTL_INS_UPDT(p_api_version              IN    NUMBER,
                           p_init_msg_list            IN    VARCHAR2,
                           x_return_status            OUT   NOCOPY VARCHAR2,
                           x_msg_count                OUT   NOCOPY NUMBER,
                           x_msg_data                 OUT   NOCOPY VARCHAR2,
                           p_ivev_tbl                 IN    ivev_tbl_type)
IS

  l_api_version               CONSTANT NUMBER := 1.0;
  l_api_name                  CONSTANT VARCHAR2(40) := 'INT_DTL_INS_UPDT';
  l_return_status             VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
  i                           NUMBER          := 0;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_ivev_tbl                  ivev_tbl_type;
  j                           NUMBER := 0;
  k                           NUMBER := 0;

  CURSOR ive_csr(v_idx_id NUMBER) IS
  SELECT datetime_valid,
         datetime_invalid
  FROM OKL_INDEX_VALUES
  WHERE idx_id = v_idx_id;


BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_Api.G_EXCEPTION_ERROR;
    END IF;

    IF (p_ivev_tbl.COUNT > 0) THEN

        i := p_ivev_tbl.FIRST;

        LOOP
             INT_DTL_INS_UPDT(p_api_version          => l_api_version,
                              p_init_msg_list        => p_init_msg_list,
                              x_return_status        => l_return_status,
                              x_msg_count            => l_msg_count,
                              x_msg_data             => l_msg_data,
                              p_ivev_rec             => p_ivev_tbl(i));

            IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            EXIT WHEN (i = p_ivev_tbl.LAST);

            i := p_ivev_tbl.NEXT(i);

        END LOOP;

-- The following logic inserted to check for overlapping

        FOR ive_rec IN ive_csr(p_ivev_tbl(i).idx_id)
        LOOP
            k := k + 1;
            l_ivev_tbl(k).datetime_valid   := ive_rec.datetime_valid;
            l_ivev_tbl(k).datetime_invalid := ive_rec.datetime_invalid;
        END LOOP;

        FOR i IN 1..l_ivev_tbl.COUNT
        LOOP
         IF (l_ivev_tbl(i).datetime_invalid is not null) THEN
            FOR j IN 1..l_ivev_tbl.COUNT
            LOOP
               IF (l_ivev_tbl(j).datetime_invalid is not null) AND (j <> i) THEN
                   IF (l_ivev_tbl(i).datetime_invalid between l_ivev_tbl(j).datetime_valid AND
                       l_ivev_tbl(j).datetime_invalid) THEN
                       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_DATE_RANGE_OVERLAP');
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;
               ELSIF (l_ivev_tbl(j).datetime_invalid is NULL) AND (j <> i) THEN
                   IF (l_ivev_tbl(i).datetime_invalid >= l_ivev_tbl(j).datetime_valid) THEN
                       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_DATE_RANGE_OVERLAP');
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;
               END IF;

            END LOOP;
         ELSE
            FOR j IN 1..l_ivev_tbl.COUNT
            LOOP
                IF (l_ivev_tbl(j).datetime_invalid is NULL) and (j <> i) THEN
                    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_DATE_RANGE_OVERLAP');
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

            END LOOP;
         END IF;
        END LOOP;

    END IF;

    OKL_Api.END_ACTIVITY(x_msg_count, x_msg_data);


EXCEPTION
    WHEN OKL_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END INT_DTL_INS_UPDT;

END OKL_INTEREST_MAINT_PVT;

/
