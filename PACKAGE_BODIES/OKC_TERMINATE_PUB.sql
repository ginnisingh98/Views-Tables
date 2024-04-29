--------------------------------------------------------
--  DDL for Package Body OKC_TERMINATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMINATE_PUB" as
/* $Header: OKCPTERB.pls 120.0 2005/05/25 22:39:09 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


FUNCTION is_k_term_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
   return OKC_TERMINATE_PVT.is_k_term_allowed(p_chr_id,p_sts_code);
END;

FUNCTION is_kl_term_allowed(p_cle_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
   return OKC_TERMINATE_PVT.is_kl_term_allowed(p_cle_id,p_sts_code);
END;


PROCEDURE terminate_chr(p_api_version                  IN  NUMBER,
        	    	         p_init_msg_list                IN  VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_terminate_in_parameters_tbl   IN terminate_in_parameters_tbl,
				    p_do_commit                     IN VARCHAR2
                       ) is

    l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count  number := 0;

 BEGIN

   OKC_API.init_msg_list(p_init_msg_list);

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

  FOR i IN p_terminate_in_parameters_tbl.first..p_terminate_in_parameters_tbl.last LOOP

   IF p_terminate_in_parameters_tbl.exists(i) THEN

         OKC_TERMINATE_PUB.terminate_chr(p_api_version                 => 1,
                                         p_init_msg_list               => OKC_API.G_FALSE,
                                         x_return_status               => l_return_status,
                                         x_msg_count                   => x_msg_count,
                                         x_msg_data                    => x_msg_data,
                                         p_terminate_in_parameters_rec => p_terminate_in_parameters_tbl(i),
								 p_do_commit                   => p_do_commit);


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

PROCEDURE terminate_chr( p_api_version                  IN  NUMBER,
      	               p_init_msg_list                IN  VARCHAR2 ,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_rec   IN  terminate_in_parameters_rec,
				     p_do_commit                     IN VARCHAR2
  	                  ) is

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_terminate_in_parameters_rec  terminate_in_parameters_rec := p_terminate_in_parameters_rec;
 l_api_name constant varchar2(30) := 'terminate_chr';
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
    g_terminate_in_parameters_rec := l_terminate_in_parameters_rec;

    OKC_UTIL.call_user_hook(l_return_status, g_pkg_name, l_api_name, 'B');

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_terminate_in_parameters_rec := g_terminate_in_parameters_rec;
    l_terminate_in_parameters_rec.p_contract_id := p_terminate_in_parameters_rec.p_contract_id;


         OKC_TERMINATE_PVT.terminate_chr(p_api_version                 => 1,
                                         p_init_msg_list               => OKC_API.G_FALSE,
                                         x_return_status               => l_return_status,
                                         x_msg_count                   => x_msg_count,
                                         x_msg_data                    => x_msg_data,
                                         p_terminate_in_parameters_rec => l_terminate_in_parameters_rec );

        IF l_return_status = 'W' then
		 x_return_status := 'W';
        END IF;

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
	                   p_terminate_in_parameters_tbl 	IN terminate_in_parameters_tbl ) is

 l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN

  okc_api.init_msg_list(p_init_msg_list);

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  FOR i IN p_terminate_in_parameters_tbl.first..p_terminate_in_parameters_tbl.last
  LOOP

   IF p_terminate_in_parameters_tbl.exists(i) THEN

     OKC_TERMINATE_PVT.validate_chr(p_api_version                 => p_api_version,
                                    p_init_msg_list               => OKC_API.G_FALSE,
                                    x_return_status               => l_return_status,
                                    x_msg_count                   => x_msg_count,
                                    x_msg_data                    => x_msg_data,
                                    p_terminate_in_parameters_rec => p_terminate_in_parameters_tbl(i) );


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
null;
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
	                   p_terminate_in_parameters_rec  IN  terminate_in_parameters_rec ) is
BEGIN

   okc_terminate_pvt.validate_chr(p_api_version                 => p_api_version,
                                  p_init_msg_list               => OKC_API.G_FALSE,
                                  x_return_status               => x_return_status,
                                  x_msg_count                   => x_msg_count,
                                  x_msg_data                    => x_msg_data,
                                  p_terminate_in_parameters_rec => p_terminate_in_parameters_rec);

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE terminate_cle( p_api_version                  IN  NUMBER,
        	               p_init_msg_list                IN  VARCHAR2 ,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_tbl   IN terminate_in_cle_tbl,
					p_do_commit                     IN VARCHAR2
                       ) IS

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;

 cursor cur_lock_header(p_id okc_k_headers_v.id%type) is
 select id
 from okc_k_headers_b
 where id = p_id
 FOR update of id nowait;

 l_id number;

 cursor cur_lock_rules (p_id okc_k_headers_v.id%type) is
 select id
 from okc_rules_b
 where dnz_chr_id = p_id
 FOR update of attribute1 nowait;

 E_Resource_Busy               EXCEPTION;
 PRAGMA EXCEPTION_init(E_Resource_Busy, -00054);
 l_api_name constant varchar2(30) := 'terminate_cle_pub';
BEGIN

  OKC_API.init_msg_list(p_init_msg_list);

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

   l_return_status := OKC_API.START_ACTIVITY( l_api_name,
	                               	      p_init_msg_list,
                               		      '_PUB',
                               		      x_return_status );

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

  l_id := p_terminate_in_parameters_tbl.first;

  OPEN  cur_lock_header(p_terminate_in_parameters_tbl(l_id).p_dnz_chr_id);
  FETCH cur_lock_header INto l_id;
  CLOSE cur_lock_header;

  l_id := p_terminate_in_parameters_tbl.first;

  OPEN cur_lock_rules(p_terminate_in_parameters_tbl(l_id).p_dnz_chr_id);
  FETCH cur_lock_rules INto l_id;
  CLOSE cur_lock_rules;

 FOR i IN p_terminate_in_parameters_tbl.first..p_terminate_in_parameters_tbl.last LOOP

   if p_terminate_in_parameters_tbl.exists(i) then

     OKC_TERMINATE_PUB.terminate_cle(p_api_version                 => 1,
                                     p_init_msg_list               => OKC_API.G_FALSE,
                                     x_return_status               => l_return_status,
                                     x_msg_count                   => x_msg_count,
                                     x_msg_data                    => x_msg_data,
                                     p_terminate_in_parameters_rec => p_terminate_in_parameters_tbl(i));

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

  END IF; -- if exists

 END LOOP;

 IF P_DO_COMMIT = OKC_API.G_TRUE THEN
  COMMIT;
 END IF;
EXCEPTION
WHEN E_Resource_Busy THEN

   x_return_status := okc_api.g_ret_sts_error;

    OKC_API.set_message(G_FND_APP,
                            G_FORM_UNABLE_TO_RESERVE_REC);
    RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;

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

PROCEDURE terminate_cle( p_api_version                  IN  NUMBER,
      	               p_init_msg_list                IN  VARCHAR2 ,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_rec   IN terminate_in_cle_rec,
					p_do_commit                     IN varchar2
  	                  ) is

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_terminate_in_parameters_rec  terminate_in_cle_rec := p_terminate_in_parameters_rec;
 l_api_name constant varchar2(30) := 'terminate_cle';
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
    g_terminate_in_cle_rec := l_terminate_in_parameters_rec;

    OKC_UTIL.call_user_hook(l_return_status, g_pkg_name, l_api_name, 'B');

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_terminate_in_parameters_rec := g_terminate_in_cle_rec;
    l_terminate_in_parameters_rec.p_cle_id := p_terminate_in_parameters_rec.p_cle_id;

         OKC_TERMINATE_PVT.terminate_cle(p_api_version                 => 1,
                                         p_init_msg_list               => OKC_API.G_FALSE,
                                         x_return_status               => l_return_status,
                                         x_msg_count                   => x_msg_count,
                                         x_msg_data                    => x_msg_data,
                                         p_terminate_in_parameters_rec => l_terminate_in_parameters_rec );


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

PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
       	              p_init_msg_list                IN  VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_terminate_in_parameters_tbl 	IN  terminate_in_cle_tbl) is

 l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN

  okc_api.init_msg_list(p_init_msg_list);

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  FOR i IN p_terminate_in_parameters_tbl.first..p_terminate_in_parameters_tbl.last LOOP

   IF p_terminate_in_parameters_tbl.exists(i) THEN

     OKC_TERMINATE_PUB.validate_cle(p_api_version              => p_api_version,
                                 p_init_msg_list               => OKC_API.G_FALSE,
                                 x_return_status               => l_return_status,
                                 x_msg_count                   => x_msg_count,
                                 x_msg_data                    => x_msg_data,
                                 p_terminate_in_parameters_rec => p_terminate_in_parameters_tbl(i) );

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
	                   p_terminate_in_parameters_rec  IN  terminate_in_cle_rec ) is
BEGIN

   OKC_TERMINATE_PVT.validate_cle(p_api_version                 => p_api_version,
                                  p_init_msg_list               => OKC_API.G_FALSE,
                                  x_return_status               => x_return_status,
                                  x_msg_count                   => x_msg_count,
                                  x_msg_data                    => x_msg_data,
                                  p_terminate_in_parameters_rec => p_terminate_in_parameters_rec );

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END;

END OKC_TERMINATE_PUB;

/
