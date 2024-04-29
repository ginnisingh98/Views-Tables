--------------------------------------------------------
--  DDL for Package Body OKC_EXTEND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_EXTEND_PUB" as
/* $Header: OKCPEXTB.pls 120.0 2005/05/25 18:01:32 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

FUNCTION is_k_extend_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
   return OKC_EXTEND_PVT.is_k_extend_allowed(p_chr_id,p_sts_code);
END;

FUNCTION is_kl_extend_allowed(p_cle_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
   return OKC_EXTEND_PVT.is_kl_extend_allowed(p_cle_id,p_sts_code);
END;

PROCEDURE extend_chr(p_api_version                  IN  NUMBER,
        	           p_init_msg_list                IN  VARCHAR2 ,
                     x_return_status                OUT NOCOPY VARCHAR2,
                     x_msg_count                    OUT NOCOPY NUMBER,
                     x_msg_data                     OUT NOCOPY VARCHAR2,
	                p_extend_in_parameters_tbl     IN  extend_in_parameters_tbl,
				 p_do_commit                    IN  VARCHAR2
                    )is

    l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN

  OKC_API.init_msg_list(p_init_msg_list);

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  FOR i in p_extend_in_parameters_tbl.first..p_extend_in_parameters_tbl.last LOOP


   if p_extend_in_parameters_tbl.exists(i) then

       OKC_EXTEND_PUB.extend_chr(p_api_version              => 1,
                                 p_init_msg_list            => OKC_API.G_FALSE,
                                 x_return_status            => l_return_status,
                                 x_msg_count                => x_msg_count,
                                 x_msg_data                 => x_msg_data,
                                 p_extend_in_parameters_rec => p_extend_in_parameters_tbl(i),
						   p_do_commit                => p_do_commit);


     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

  END IF; -- if exists

  -- Bug 3658108
  OKC_CVM_PVT.clear_g_transaction_id;

 END LOOP;
 IF P_DO_COMMIT = OKC_API.G_TRUE THEN
   COMMIT;
 END IF;
OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
NULL;
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE extend_chr( p_api_version                  IN  NUMBER,
      	            p_init_msg_list                IN  VARCHAR2 ,
                      x_return_status                OUT NOCOPY VARCHAR2,
                      x_msg_count                    OUT NOCOPY NUMBER,
                      x_msg_data                     OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_rec     IN  extend_in_parameters_rec,
				  p_do_commit                    IN VARCHAR2
  	               ) is

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_extend_in_parameters_rec  extend_in_parameters_rec := p_extend_in_parameters_rec;
 l_api_name constant varchar2(30) := 'extend_chr';
 l_chr_id number;
BEGIN

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                               p_init_msg_list,
                               '_PUB',
                               x_return_status);

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     raise OKC_API.G_EXCEPTION_ERROR;
   END IF;

 -- Call user hook FOR BEFORE
    g_extend_in_parameters_rec := l_extend_in_parameters_rec;

    OKC_UTIL.call_user_hook(l_return_status, g_pkg_name, l_api_name, 'B');

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

  l_extend_in_parameters_rec 		   := g_extend_in_parameters_rec;
  l_extend_in_parameters_rec.p_contract_id := p_extend_in_parameters_rec.p_contract_id;


         OKC_EXTEND_PVT.extend_chr(p_api_version               => 1,
                                   p_init_msg_list             => OKC_API.G_FALSE,
                                   x_return_status             => l_return_status,
                                   x_msg_count                 => x_msg_count,
                                   x_msg_data                  => x_msg_data,
                                   p_extend_in_parameters_rec  => l_extend_in_parameters_rec );


        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


    OKC_UTIL.call_user_hook(l_return_status, g_pkg_name, l_api_name, 'A');

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

 IF P_DO_COMMIT = OKC_API.G_TRUE THEN
   COMMIT;
 END IF;

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                      'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
WHEN OTHERS THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
end;

PROCEDURE validate_chr( p_api_version                  IN NUMBER,
       	              p_init_msg_list                IN VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_tbl 	IN extend_in_parameters_tbl ) is

 l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN

    OKC_API.init_msg_list(p_init_msg_list);

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  FOR i in p_extend_in_parameters_tbl.first..p_extend_in_parameters_tbl.last
  LOOP

   IF p_extend_in_parameters_tbl.exists(i) THEN

     OKC_EXTEND_PVT.validate_chr(p_api_version              => p_api_version,
                                 p_init_msg_list            => OKC_API.G_FALSE,
                                 x_return_status            => l_return_status,
                                 x_msg_count                => x_msg_count,
                                 x_msg_data                 => x_msg_data,
                                 p_extend_in_parameters_rec => p_extend_in_parameters_tbl(i) );

     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

   END IF; -- if exists
 END LOOP;
EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
NULL;
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end;


PROCEDURE VALIDATE_CHR( p_api_version                  IN  NUMBER,
       	              p_init_msg_list                IN  VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_rec     IN  extend_in_parameters_rec ) is
BEGIN

   OKC_EXTEND_PVT.validate_chr(p_api_version              => p_api_version,
                               p_init_msg_list            => OKC_API.G_FALSE,
                               x_return_status            => x_return_status,
                               x_msg_count                => x_msg_count,
                               x_msg_data                 => x_msg_data,
                               p_extend_in_parameters_rec => p_extend_in_parameters_rec );

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end;

PROCEDURE extend_cle(p_api_version                  IN NUMBER,
        	     p_init_msg_list                IN VARCHAR2 ,
                     x_return_status                OUT NOCOPY VARCHAR2,
                     x_msg_count                    OUT NOCOPY NUMBER,
                     x_msg_data                     OUT NOCOPY VARCHAR2,
	             p_extend_in_parameters_tbl     IN extend_in_cle_tbl,
		     p_do_commit                    IN VARCHAR2
                    ) IS

  l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  rec_count number := 0;
  p_end_date_latest date;
  l_extend_in_parameters_rec okc_extend_pub.extend_in_parameters_rec;
  l_api_name constant varchar2(30) := 'extend_cle_tbl';
  l number;
  p_hdr_end_date date;
  l_new_end_date date;
  l_sts_code Varchar2(30);
  l_status_code VARCHAR2(30);

  l_chr_rec OKC_CONTRACT_PUB.chrv_rec_type;
  i_chr_rec OKC_CONTRACT_PUB.chrv_rec_type;

  cursor cur_hdr_enddate(p_cle_id number) is
  select k.id,k.end_date,k.object_version_number,k.contract_number,
         k.contract_number_modifier, k.sts_code
    from okc_k_headers_b k,
         okc_k_lines_b cle
   where cle.id = p_cle_id
     and cle.dnz_chr_id = k.id;

  CURSOR cur_status(p_sts_code varchar2) is
  SELECT ste_code
    FROM okc_statuses_b
   WHERE code = p_sts_code;

BEGIN

 okc_api.init_msg_list(p_init_msg_list);

 x_return_status := OKC_API.G_RET_STS_SUCCESS;

 l_return_status := OKC_API.START_ACTIVITY( l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     raise OKC_API.G_EXCEPTION_ERROR;
   END IF;

 OPEN cur_hdr_enddate(p_extend_in_parameters_tbl(1).p_cle_id);
 FETCH cur_hdr_enddate into l_extend_in_parameters_rec.p_contract_id,p_hdr_end_date,l_extend_in_parameters_rec.p_object_version_number,l_extend_in_parameters_rec.p_contract_number,l_extend_in_parameters_rec.p_contract_modifier, l_sts_code;
 CLOSE cur_hdr_enddate;

 FOR i in p_extend_in_parameters_tbl.first..p_extend_in_parameters_tbl.last LOOP

       -- If the lines are perpetual, set the end date for contract to null
	 If p_extend_in_parameters_tbl(i).p_perpetual_flag = OKC_API.G_TRUE Then
         p_end_date_latest := Null;
         Exit;
       End If;

       rec_count := rec_count + 1;

       IF p_extend_in_parameters_tbl(i).p_end_date is not null THEN
         l_new_end_date := p_extend_in_parameters_tbl(i).p_end_date;
       else
         l_new_end_date := okc_time_util_pub.get_enddate(p_extend_in_parameters_tbl(i).p_orig_end_date + 1,
	                           p_extend_in_parameters_tbl(i).p_uom_code,
	                           p_extend_in_parameters_tbl(i).p_duration);
       end IF;

       IF rec_count = 1 THEN
          p_end_date_latest :=l_new_end_date;
       ELSE
          IF l_new_end_date > p_end_date_latest THEN
            p_end_date_latest := l_new_end_date;
         END IF;
       END IF;
 END LOOP;

  -- The following IF changed for perpetual contracts
  -- IF (p_end_date_latest is NOT NULL and p_end_date_latest > p_hdr_end_date) Or
  IF (p_end_date_latest is NOT NULL and p_end_date_latest > p_hdr_end_date) Or
     (p_end_date_latest is null and p_hdr_end_date is Not Null) THEN

     OKC_EXTEND_PVT.g_called_from := 'LINES';

     l_extend_in_parameters_rec.p_orig_end_date := p_hdr_end_date;
     l_extend_in_parameters_rec.p_end_date      := p_end_date_latest;

     -- Make the contract perpetual if line is perpetual
     If p_end_date_latest Is Null Then
       l_extend_in_parameters_rec.p_perpetual_flag := OKC_API.G_TRUE;
     Else
       l_extend_in_parameters_rec.p_perpetual_flag := OKC_API.G_FALSE;
     End If;

    l_chr_rec.id                    := l_extend_in_parameters_rec.p_contract_id;
    l_chr_rec.object_version_number := l_extend_in_parameters_rec.p_object_version_number;
    l_chr_rec.end_date              := p_end_date_latest;
    l_chr_rec.sts_code := l_sts_code;
   IF p_end_date_latest >= trunc(sysdate) THEN
      OPEN cur_status(l_chr_rec.sts_code);
      FETCH cur_status into l_status_code;
      CLOSE cur_status;

      IF l_status_code = 'EXPIRED' then

         OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                         p_status_type   => 'ACTIVE',
                                         x_status_code   => l_status_code );

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          raise OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_chr_rec.sts_code := l_status_code;
        l_chr_rec.old_sts_code := 'EXPIRED';
        l_chr_rec.old_ste_code := 'EXPIRED';
        l_chr_rec.new_sts_code := l_status_code;
        l_chr_rec.new_ste_code := 'ACTIVE';
     END IF;
 END IF;
	  OKC_CONTRACT_PUB.update_contract_header ( p_api_version    => 1,
	                                   p_init_msg_list  => OKC_API.G_FALSE,
	                                   x_return_status  => l_return_status,
	                                   x_msg_count      => x_msg_count,
	                                   x_msg_data       => x_msg_data,
				    p_restricted_update => okc_api.g_true,
	                                   p_chrv_rec       => l_chr_rec,
	                                   x_chrv_rec       => i_chr_rec  );

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

	OKC_EXTEND_PUB.extend_chr(p_api_version              => 1,
                               p_init_msg_list            => OKC_API.G_FALSE,
                               x_return_status            => l_return_status,
                               x_msg_count                => x_msg_count,
                               x_msg_data                 => x_msg_data,
                               p_extend_in_parameters_rec => l_extend_in_parameters_rec );

       OKC_EXTEND_PVT.g_called_from := 'HEADER';

      IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

  END IF;

--san this needs to be set as g_lines_count is a global variable, so if not reset everytime
-- it keeps value 1 and next time extend is called, it does not go to
--validation of hdr even once

  OKC_EXTEND_PVT.g_lines_count :=0;

 FOR i in p_extend_in_parameters_tbl.first..p_extend_in_parameters_tbl.last LOOP

   IF p_extend_in_parameters_tbl.exists(i) then

     OKC_EXTEND_PUB.extend_cle(p_api_version              => p_api_version,
                               p_init_msg_list            => OKC_API.G_FALSE,
                               x_return_status            => l_return_status,
                               x_msg_count                => x_msg_count,
                               x_msg_data                 => x_msg_data,
                               p_extend_in_parameters_rec => p_extend_in_parameters_tbl(i));

       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.g_exception_unexpected_error;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         raise OKC_API.g_exception_error;
       END IF;

  END IF; -- if exists

 END LOOP;
IF p_do_commit = okc_api.g_true then
 COMMIT;
END IF;
OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
WHEN OTHERS THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
END;

PROCEDURE extend_cle( p_api_version                  IN  NUMBER,
      	            p_init_msg_list                IN  VARCHAR2 ,
                      x_return_status                OUT NOCOPY VARCHAR2,
                      x_msg_count                    OUT NOCOPY NUMBER,
                      x_msg_data                     OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_rec     IN  extend_in_cle_rec,
				  p_do_commit                    IN VARCHAR2
  	               ) is

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_extend_in_parameters_rec  extend_in_cle_rec := p_extend_in_parameters_rec;
 l_api_name constant varchar2(30) := 'extend_cle';
 l_chr_id number;

BEGIN

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                             p_init_msg_list,
                                             '_PUB',
                                              x_return_status);

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     raise OKC_API.G_EXCEPTION_ERROR;
   END IF;

 -- Call user hook FOR BEFORE
    g_extend_in_cle_rec := l_extend_in_parameters_rec;

    OKC_UTIL.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_extend_in_parameters_rec := g_extend_in_cle_rec;
    l_extend_in_parameters_rec.p_cle_id := p_extend_in_parameters_rec.p_cle_id;

         OKC_EXTEND_PVT.extend_cle(p_api_version              => p_api_version,
                                   p_init_msg_list            => OKC_API.G_FALSE,
                                   x_return_status            => l_return_status,
                                   x_msg_count                => x_msg_count,
                                   x_msg_data                 => x_msg_data,
                                   p_extend_in_parameters_rec => l_extend_in_parameters_rec );


        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


    OKC_UTIL.call_user_hook(l_return_status, g_pkg_name, l_api_name, 'A');

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

IF p_do_commit = okc_api.g_true then
 commit;
END IF;
OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                      'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
WHEN OTHERS THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PUB');
end;

PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
       	              p_init_msg_list                IN  VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_tbl 	IN  extend_in_cle_tbl) is

 l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN

  OKC_API.init_msg_list(p_init_msg_list);

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

--san this needs to be set as g_lines_count is a global variable, so if not reset everytime
-- it keeps value 1 and next time extend is called, it does not go to
--validation of hdr even once
  OKC_EXTEND_PVT.g_lines_count :=0;

  FOR i in p_extend_in_parameters_tbl.first..p_extend_in_parameters_tbl.last LOOP

   IF p_extend_in_parameters_tbl.exists(i) THEN

     OKC_EXTEND_PUB.validate_cle(p_api_version              => p_api_version,
                                 p_init_msg_list            => OKC_API.G_FALSE,
                                 x_return_status            => l_return_status,
                                 x_msg_count                => x_msg_count,
                                 x_msg_data                 => x_msg_data,
                                 p_extend_in_parameters_rec => p_extend_in_parameters_tbl(i) );

     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
  END IF; --if exists
 END LOOP;
EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
NULL;
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end;


PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
       	              p_init_msg_list                IN  VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_rec     IN  extend_in_cle_rec ) is
BEGIN

   OKC_EXTEND_PVT.validate_cle(p_api_version              => p_api_version,
                               p_init_msg_list            => OKC_API.G_FALSE,
                               x_return_status            => x_return_status,
                               x_msg_count                => x_msg_count,
                               x_msg_data                 => x_msg_data,
                               p_extend_in_parameters_rec => p_extend_in_parameters_rec );

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end;

end OKC_EXTEND_PUB;

/
