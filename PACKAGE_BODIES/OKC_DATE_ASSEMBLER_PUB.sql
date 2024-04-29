--------------------------------------------------------
--  DDL for Package Body OKC_DATE_ASSEMBLER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DATE_ASSEMBLER_PUB" AS
/* $Header: OKCPDASB.pls 120.0 2005/05/25 22:35:33 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--
g_package  varchar2(33) := '  OKC_DATE_ASSEMBLER_PUB.';



 PROCEDURE conc_mgr(errbuf  OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY VARCHAR2) IS

  l_api_name        CONSTANT VARCHAR2(30) := 'conc_mgr';
  l_api_version     CONSTANT VARCHAR2(30) := 1.0;
  l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  x_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(1000);
  l_init_msg_list   VARCHAR2(3) := 'F';
  E_Resource_Busy   EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy,  -00054);

   --
   l_proc varchar2(72) := g_package||'conc_mgr';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

       -- call start_activity to create savepoint, check comptability
       -- and initialize message list
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,l_init_msg_list
                                                ,'_PUBLIC'
                                                ,x_return_status
                                                );
    --Initialize the return code
    retcode := 0;
    OKC_DATE_ASSEMBLER_PUB.date_assemble(
             p_api_version   => l_api_version
                 ,p_init_msg_list => l_init_msg_list
                 ,x_return_status => l_return_status
                 ,x_msg_count     => l_msg_count
                 ,x_msg_data      => l_msg_data);


    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

 OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
   WHEN E_Resource_Busy THEN
      l_return_status := okc_api.g_ret_sts_error;
      RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
      IF (l_debug = 'Y') THEN
         okc_debug.Log('2000: Leaving ',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
      retcode := 2;
      errbuf  := substr(sqlerrm,1,200);
       l_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        '_PUBLIC');
      IF (l_debug = 'Y') THEN
         okc_debug.Log('3000: Leaving ',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       retcode := 2;
       errbuf  := substr(sqlerrm,1,200);
       l_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        '_PUBLIC');
      IF (l_debug = 'Y') THEN
         okc_debug.Log('4000: Leaving ',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OTHERS THEN
        retcode := 2;
        errbuf  := substr(sqlerrm,1,200);
       l_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        '_PUBLIC');
      IF (l_debug = 'Y') THEN
         okc_debug.Log('5000: Leaving ',2);
         okc_debug.Reset_Indentation;
      END IF;
  END conc_mgr;

  PROCEDURE date_assemble(
    p_api_version                  IN NUMBER ,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'date_assemble';
    --l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    --l_msg_count           NUMBER;
    --l_msg_data            VARCHAR2(1000);
    l_cnhv_rec             OKC_CNH_PVT.cnhv_rec_type;
    i_cnhv_rec             OKC_CNH_PVT.cnhv_rec_type;


    --Get all the action and condition details
    --Bug#4033775 check if action is enabled 12/09/2004
    CURSOR acn_csr IS
    SELECT acn.correlation, acn.acn_type, cnh.name,cnh.id, cnh.dnz_chr_id,
           cnh.cnh_variance, cnh.before_after,
           nvl(cnh.last_rundate,sysdate-1) last_rundate,
           acn.enabled_yn
    FROM okc_condition_headers_v cnh, okc_actions_v acn
    WHERE cnh.acn_id = acn.id
    AND acn.acn_type = 'DBA'
    AND condition_valid_yn = 'Y'
    AND template_yn = 'N'
    AND sysdate between date_active and nvl(date_inactive,sysdate)
    ORDER BY cnh.name;

    acn_rec    acn_csr%ROWTYPE;

   --
   l_proc varchar2(72) := g_package||'date_assemble';
   --

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(l_proc);
       okc_debug.Log('10: Entering ',2);
    END IF;

    -- call start_activity to create savepoint, check comptability
    -- and initialize message list
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUBLIC'
                                                ,x_return_status
                                                );
       -- check if activity started successfully
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       fnd_message.set_name('OKC','OKC_EXPIRY_DATE_CONTRACTS');
       fnd_file.put_line(fnd_file.log,fnd_message.get);

       --If the action type is date based action and the correlation is Contract expiry date
       --then call the date assembler to process all the contracts expiring before or after
       --the given variance

       FOR acn_rec IN acn_csr LOOP

            --Bug#4033775 check if action is enabled 12/09/2004
            IF acn_rec.acn_type = 'DBA' and acn_rec.correlation = 'KEXPIRE'
            and acn_rec.enabled_yn = 'Y' THEN

               fnd_message.set_name('OKC','OKC_EDA_CONDITIONS');
               fnd_message.set_token('NAME',acn_rec.name);
               fnd_file.put_line(fnd_file.log,fnd_message.get);

            --Call the date assembler for contract expiry date
                OKC_EXP_DATE_ASMBLR_PVT.exp_date_assemble(
                                            p_api_version   => 1
                                           ,p_init_msg_list => 'F'
                                           ,x_return_status => l_return_status
                                           ,x_msg_count     => x_msg_count
                                           ,x_msg_data      => x_msg_data
                                           ,p_cnh_id        => acn_rec.id
                                           ,p_dnz_chr_id    => acn_rec.dnz_chr_id
                                           ,p_cnh_variance  => acn_rec.cnh_variance
                                           ,p_before_after  => acn_rec.before_after
                                           ,p_last_rundate  => acn_rec.last_rundate);

                            IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                              RAISE OKC_API.G_EXCEPTION_ERROR;
                            ELSIF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                              l_cnhv_rec.id           := acn_rec.id;
                              l_cnhv_rec.last_rundate := sysdate;

                                --
                                -- Update the Last Run date for the picked condition
                                --
                                OKC_CONDITIONS_PUB.update_cond_hdrs(p_api_version => 1,
                                                    p_init_msg_list => okc_api.g_false,
                                                    x_return_status => l_return_status,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data  => x_msg_data,
                                                    p_cnhv_rec  => l_cnhv_rec,
                                                    x_cnhv_rec  => i_cnhv_rec);

                                        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                                            RAISE OKC_API.G_EXCEPTION_ERROR;
                                        END IF; -- Update the Last Run date

                               COMMIT;

                            END IF; -- Call the date assembler for contract expiry date



            --Bug#4033775 check if action is enabled 12/09/2004
            ELSIF acn_rec.acn_type = 'DBA' and acn_rec.correlation = 'KLEXPIRE'
            and acn_rec.enabled_yn = 'Y' THEN
             -- for contract LINES

               fnd_message.set_name('OKC','OKC_EDA_CONDITIONS');
               fnd_message.set_token('NAME',acn_rec.name);
               fnd_file.put_line(fnd_file.log,fnd_message.get);

            --Call the date assembler for contract LINES expiry date
                OKC_EXP_DATE_ASMBLR_PVT.exp_lines_date_assemble(
                                            p_api_version   => 1
                                           ,p_init_msg_list => 'F'
                                           ,x_return_status => l_return_status
                                           ,x_msg_count     => x_msg_count
                                           ,x_msg_data      => x_msg_data
                                           ,p_cnh_id        => acn_rec.id
                                           ,p_dnz_chr_id    => acn_rec.dnz_chr_id
                                           ,p_cnh_variance  => acn_rec.cnh_variance
                                           ,p_before_after  => acn_rec.before_after
                                           ,p_last_rundate  => acn_rec.last_rundate);

                            IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                              RAISE OKC_API.G_EXCEPTION_ERROR;
                            ELSIF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                              l_cnhv_rec.id           := acn_rec.id;
                              l_cnhv_rec.last_rundate := sysdate;

                                --
                                -- Update the Last Run date for the picked condition
                                --
                                OKC_CONDITIONS_PUB.update_cond_hdrs(p_api_version => 1,
                                                    p_init_msg_list => okc_api.g_false,
                                                    x_return_status => l_return_status,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data  => x_msg_data,
                                                    p_cnhv_rec  => l_cnhv_rec,
                                                    x_cnhv_rec  => i_cnhv_rec);

                                        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                                            RAISE OKC_API.G_EXCEPTION_ERROR;
                                        END IF; -- Update the Last Run date
                               COMMIT;

                            END IF; -- Call the date assembler for contract LINES expiry date

            END IF; -- acn_rec.acn_type = 'DBA' and acn_rec.correlation = 'KEXPIRE'

      END LOOP;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUBLIC');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUBLIC');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUBLIC');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

    END date_assemble;

END OKC_DATE_ASSEMBLER_PUB;

/
