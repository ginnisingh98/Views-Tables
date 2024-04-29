--------------------------------------------------------
--  DDL for Package Body OKL_INTEREST_IMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTEREST_IMP_PVT" AS
/* $Header: OKLRITFB.pls 115.1 2002/02/06 20:32:05 pkm ship       $ */



PROCEDURE INT_RATE_IMPORT(p_api_version      IN     NUMBER,
                         p_init_msg_list    IN     VARCHAR2,
                         x_return_status    OUT    NOCOPY VARCHAR2,
                         x_msg_count        OUT    NOCOPY NUMBER,
                         x_msg_data         OUT    NOCOPY VARCHAR2)

IS

  l_api_name          CONSTANT VARCHAR2(40) := 'INT_RATE_IMPORT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_idxv_rec_in       idxv_rec_type;
  l_idxv_rec_out      idxv_rec_type;

  l_ivev_rec_in       ivev_rec_type;
  l_ivev_rec_out      ivev_rec_type;

  l_idiv_tbl_in       idiv_tbl_type;
  l_idiv_tbl_out      idiv_tbl_type;


  l_init_msg_list     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  i    NUMBER := 0;
  l_name OKL_INDICES.name%TYPE;
  l_idx  OKL_INDICES.id%TYPE;
  l_error_flag   VARCHAR2(1);


  CURSOR  interface_csr IS
  SELECT id,
         idi_type,
         process_flag,
         index_name,
         description,
         value,
         datetime_valid,
         datetime_invalid
  FROM OKL_INDX_INTERFACES_V
  WHERE process_flag IS NULL
  ORDER BY idi_type, datetime_valid
  FOR UPDATE;


  CURSOR idx_csr(v_name okl_indices_v.name%TYPE,
                 v_idx_type OKL_INDICES_V.idx_type%TYPE) IS
  SELECT name,
      id
  FROM okl_indices_v
  WHERE name = v_name
  AND   idx_type = v_idx_type;





 BEGIN


    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                              ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,l_return_status);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    FOR interface_csr_rec IN interface_csr

    LOOP

        l_error_flag := 'N';


        IF (interface_csr_rec.datetime_valid IS NOT NULL) THEN


            IF (interface_csr_rec.datetime_invalid IS NOT NULL) THEN

                IF (interface_csr_rec.datetime_invalid < interface_csr_rec.datetime_valid) THEN


                   l_error_flag := 'Y';

                END IF;

            END IF;

            IF OKL_INTEREST_MAINT_PVT.overlap_exists(   interface_csr_rec.idi_type,
                                       interface_csr_rec.index_name,
                                       interface_csr_rec.datetime_valid,
                                       interface_csr_rec.datetime_invalid) = OKC_API.G_TRUE THEN

                l_error_flag := 'Y';

            END IF;

       ELSE

              l_error_flag := 'Y';

       END IF;


       IF (l_error_flag = 'N') THEN


            i := i + 1;

            l_idxv_rec_in.name              := interface_csr_rec.index_name;
            l_idxv_rec_in.idx_type          := interface_csr_rec.idi_type;
            l_idxv_rec_in.description       := interface_csr_rec.description;

            l_ivev_rec_in.value             := interface_csr_rec.value;
            l_ivev_rec_in.datetime_valid    := interface_csr_rec.datetime_valid;
            l_ivev_rec_in.datetime_invalid  := interface_csr_rec.datetime_invalid;

            l_idiv_tbl_in(i).id             := interface_csr_rec.id;
            l_idiv_tbl_in(i).process_flag   := 1;


            OPEN idx_csr(l_idxv_rec_in.name, l_idxv_rec_in.idx_type);
            FETCH idx_csr INTO l_name, l_idx;
            IF idx_csr%NOTFOUND THEN


                   OKL_INDICES_PUB.create_indices(p_api_version   => 1.0,
				                                  p_init_msg_list => l_init_msg_list,
                                                  x_return_status => l_return_status,
                                                  x_msg_count     => l_msg_count,
                                                  x_msg_data      => l_msg_data,
                                                  p_idxv_rec      => l_idxv_rec_in,
                                                  x_idxv_rec      => l_idxv_rec_out);

                   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

                   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;

                   END IF;

                   l_ivev_rec_in.idx_id := l_idxv_rec_out.id;

            ELSE
                   l_ivev_rec_in.idx_id := l_idx;

            END IF;

            CLOSE idx_csr;


            OKL_INDICES_PUB.create_index_values(p_api_version      => 1.0,
                                                p_init_msg_list    => l_init_msg_list,
                                                x_return_status    => l_return_status,
                                                x_msg_count        => l_msg_count,
                                                x_msg_data         => l_msg_data,
                                                p_ivev_rec         => l_ivev_rec_in,
                                                x_ivev_rec         => l_ivev_rec_out);


            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

                 RAISE OKL_API.G_EXCEPTION_ERROR;

            END IF;

       END IF;

    END LOOP;


-- Update the Index Interface table with process flag = 1.


    OKL_INDEX_INTERFACES_PUB.update_index_interfaces(p_api_version   => 1.0,
                                                     p_init_msg_list => l_init_msg_list,
                                                     x_return_status => l_return_status,
                                                     x_msg_count     => l_msg_count,
                                                     x_msg_data      => l_msg_data,
                                                     p_idiv_tbl      => l_idiv_tbl_in,
                                                     x_idiv_tbl      => l_idiv_tbl_out);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

         RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;


    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    COMMIT WORK;


    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN

          x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                              ,g_pkg_name
                              ,'OKL_API.G_RET_STS_ERROR'
                              ,x_msg_count
                              ,x_msg_data
                                   ,'_PVT'
                                                                   );

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

          x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                          ,g_pkg_name
                          ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                          ,x_msg_count
                          ,x_msg_data
                          ,'_PVT'
                          );

      WHEN OTHERS THEN

          x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                          ,g_pkg_name
                          ,'OTHERS'
                             ,x_msg_count
                                  ,x_msg_data
                          ,'_PVT'
                          );

END INT_RATE_IMPORT;


END OKL_INTEREST_IMP_PVT;

/
