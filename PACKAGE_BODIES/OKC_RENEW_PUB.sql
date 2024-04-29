--------------------------------------------------------
--  DDL for Package Body OKC_RENEW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RENEW_PUB" as
/* $Header: OKCPRENB.pls 120.4 2005/12/05 15:16:54 skekkar noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/* Procedure Auto_Renew( errbuf out nocopy varchar2,retcode out varchar2 ) is
begin

 OKC_RENEW_PVT.AUTO_RENEW(errbuf,retcode);

end; */

Procedure Auto_Renew(errbuf out nocopy varchar2,
		     retcode out nocopy varchar2,
		     p_chr_id IN Number ,
		     p_duration IN Number,
		     p_uom_code IN Varchar2 ,
		     p_renewal_called_from_ui    IN VARCHAR2 ,
                     p_contract_number IN Varchar2 ,
                     p_contract_number_modifier IN Varchar2
		    ) is

begin

 OKC_RENEW_PVT.AUTO_RENEW(errbuf, retcode, p_chr_id, p_duration, p_uom_code,p_renewal_called_from_ui, p_contract_number, p_contract_number_modifier); /* p_renewal_called_from_ui added for bugfix 2093117 */

end;

FUNCTION is_renew_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
    return OKC_RENEW_PVT.is_renew_allowed(p_chr_id,p_sts_code);
END is_renew_allowed;

PROCEDURE Renew(p_api_version                  IN NUMBER,
      	        p_init_msg_list                IN VARCHAR2 ,
                x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
	        p_renew_in_parameters_tbl      IN Renew_in_parameters_tbl,
                x_renew_out_parameters_tbl     OUT NOCOPY Renew_out_parameters_tbl,
		p_do_commit                    IN VARCHAR2 ,
		p_renewal_called_from_ui       IN VARCHAR2  /* added for bugfix 2093117 */
               ) is

	   l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_chr_id number;
        l_api_name constant varchar2(30) := 'Renew';

 begin

  okc_api.init_msg_list(p_init_msg_list);

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

 for i in p_renew_in_parameters_tbl.first..p_renew_in_parameters_tbl.last loop

   if p_renew_in_parameters_tbl.exists(i) then

         OKC_RENEW_PUB.RENEW(p_api_version   => 1,
                             p_init_msg_list => OKC_API.G_FALSE,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             x_contract_id   => l_chr_id,
                             p_renew_in_parameters_rec => p_renew_in_parameters_tbl(i) ,
	 		     p_do_commit               => OKC_API.G_FALSE, --p_do_commit,
			     p_renewal_called_from_ui => p_renewal_called_from_ui /* added for bugfix 2093117 */
			     );

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        ELSE
          x_renew_out_parameters_tbl(i).p_old_contract_id :=  p_renew_in_parameters_tbl(i).p_contract_id;
          x_renew_out_parameters_tbl(i).p_new_contract_id :=  l_chr_id;
        END IF;

   end if;  -- end if exists

 end loop;

 IF p_do_commit = okc_api.g_true then
    commit;
 END IF;
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


FUNCTION Validate_line(p_contract_id IN NUMBER) RETURN VARCHAR2
IS
BEGIN
return OKC_RENEW_PVT.Validate_line(p_contract_id);
END Validate_line;

PROCEDURE PRE_Renew(p_api_version                  IN NUMBER,
      	            p_init_msg_list                IN VARCHAR2 ,
                    x_return_status                OUT NOCOPY VARCHAR2,
                    x_msg_count                    OUT NOCOPY NUMBER,
                    x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_renew_in_parameters_tbl      IN Renew_in_parameters_tbl,
                    x_renew_out_parameters_tbl     OUT NOCOPY Renew_out_parameters_tbl,
		    p_do_commit                    IN VARCHAR2 ,
		    p_renewal_called_from_ui       IN VARCHAR2  /* added for bugfix 2093117 */
                ) is

	   l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_chr_id number;
        l_api_name constant varchar2(30) := 'PRE_Renew';

 begin

  okc_api.init_msg_list(p_init_msg_list);

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

 for i in p_renew_in_parameters_tbl.first..p_renew_in_parameters_tbl.last loop

   if p_renew_in_parameters_tbl.exists(i) then

         OKC_RENEW_PUB.PRE_RENEW(p_api_version   => 1,
                                 p_init_msg_list => OKC_API.G_FALSE,
                                 x_return_status => l_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 x_contract_id   => l_chr_id,
                                 p_renew_in_parameters_rec => p_renew_in_parameters_tbl(i) ,
		        	 p_do_commit               =>  OKC_API.G_FALSE, --p_do_commit,
				 p_renewal_called_from_ui => p_renewal_called_from_ui /* added for bugfix 2093117 */
				 );
        /* commented because of bug 4569585
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        ELSE
          x_renew_out_parameters_tbl(i).p_old_contract_id :=  p_renew_in_parameters_tbl(i).p_contract_id;
          x_renew_out_parameters_tbl(i).p_new_contract_id :=  l_chr_id;
        END IF;
        */

        --begin bug 4569585 changes
        IF (l_return_status not in(OKC_API.G_RET_STS_SUCCESS, OKC_API.G_RET_STS_WARNING)) THEN
          --can only be E (error) or U (Unexpected error), we stop in both cases
          IF ((l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
            OR (l_return_status = OKC_API.G_RET_STS_ERROR))THEN
            x_return_status := l_return_status;
          ELSE
            --any other unrecognized status will be be treated as U
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          END IF;
          raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
          --if S (Success) or W (warning) continue
          x_renew_out_parameters_tbl(i).p_old_contract_id :=  p_renew_in_parameters_tbl(i).p_contract_id;
          x_renew_out_parameters_tbl(i).p_new_contract_id :=  l_chr_id;
          --if warning make the return status as warning
          IF (l_return_status = OKC_API.G_RET_STS_WARNING) THEN
            x_return_status := l_return_status;
          END IF;
        END IF;
        --end bug 4569585 changes

   end if;  -- end if exists

  -- Bug 3658108
  OKC_CVM_PVT.clear_g_transaction_id;

 end loop;

 IF p_do_commit = okc_api.g_true then
    commit;
 END IF;
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


PROCEDURE PRE_Renew( p_api_version                  IN NUMBER,
    	             p_init_msg_list                IN VARCHAR2 ,
                     x_return_status                OUT NOCOPY VARCHAR2,
                     x_msg_count                    OUT NOCOPY NUMBER,
                     x_msg_data                     OUT NOCOPY VARCHAR2,
                     x_contract_id                  OUT NOCOPY number,
	             p_renew_in_parameters_rec      IN Renew_in_parameters_rec,
		     p_do_commit                    IN VARCHAR2 ,
		     p_renewal_called_from_ui       IN VARCHAR2  /* added for bugfix 2093117 */
  	          ) is

 l_cls_code OKC_SUBCLASSES_B.CLS_CODE%TYPE:=OKC_API.G_MISS_CHAR;
 l_renew_in_parameters_rec        Renew_in_parameters_rec; -- this has to be empty
 l_proc varchar2(4000);

-- bug 4777431 , skekkar
 CURSOR cur_scs(p_chr_id number) is
   select cls_code
    from okc_k_headers_all_b,okc_subclasses_b  -- bug 4777431
	WHERE id=p_chr_id and code=scs_code;
 l_renew_not_found   exception;
 PRAGMA EXCEPTION_INIT(l_Renew_Not_found, -6550);
begin
   okc_api.init_msg_list(p_init_msg_list);

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   Open cur_scs(p_renew_in_parameters_rec.p_contract_id);
   fetch cur_scs into l_cls_code;
   close cur_scs;

   g_prerenew_in_parameters_rec :=l_renew_in_parameters_rec;
   g_prerenew_in_parameters_rec :=p_renew_in_parameters_rec;


   If l_cls_code = 'SERVICE' then
		  -- dbms_output.put_line('san dbms in pre ren if');
	BEGIN

		 -- bug 4777431
		 -- set org context
		    okc_context.set_okc_org_context(p_chr_id =>  p_renew_in_parameters_rec.p_contract_id);

		 -- change dynamic sql to static sql call (skekkar)
		    oks_renew_pub.renew
			(p_api_version              =>  1,
			 p_init_msg_list            =>  OKC_API.G_FALSE,
			 x_return_status            =>  x_return_status,
			 x_msg_count                =>  x_msg_count,
			 x_msg_data                 =>  x_msg_data,
			 x_contract_id              =>  x_contract_id,
			 p_do_commit                =>  OKC_API.G_FALSE,
			 p_renewal_called_from_ui   =>  p_renewal_called_from_ui
			 );

         /*
		   -- bug 4777431 , change dynamic sql call to static (skekkar)
		   --dbms_output.put_line('san dbms start immediate');
         l_proc:='BEGIN OKS_RENEW_PUB.RENEW(:a ,:b ,:c,:d,:e,:f,:g,:h); END; ';


         EXECUTE IMMEDIATE l_proc
	       using 1,OKC_API.G_FALSE, OUT x_return_status, OUT x_msg_count,
					OUT x_msg_data, OUT x_contract_id , OKC_API.G_FALSE, p_renewal_called_from_ui;
		 */


		   --dbms_output.put_line('san dbms end immeditae');
             g_prerenew_in_parameters_rec :=l_renew_in_parameters_rec;
        EXCEPTION

        --anjkumar from R12, if OKS_RENEW_PUB.RENEW is not defined/compiled
        --throw the error as it is, do not attempt to use OKC_RENEW_PUB.RENEW
        /*
		WHEN l_renew_not_found then
		   --dbms_output.put_line('san dbms l_renew_not_found');
		IF instr(UPPER(sqlerrm),'PLS-00302') <> 0 OR  instr(UPPER(sqlerrm),'PLS-00201') <> 0 then
		--dbms_output.put_line('san dbms going to ren in exception');

             OKC_RENEW_PUB.RENEW(p_api_version   => 1,
                             p_init_msg_list => OKC_API.G_FALSE,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             x_contract_id   => x_contract_id,
                             p_renew_in_parameters_rec => p_renew_in_parameters_rec,
			     p_do_commit               => p_do_commit,
			     p_renewal_called_from_ui => p_renewal_called_from_ui
			     );
          ELSE
			 --dbms_output.put_line('san dbms else in pls error');
		      RAISE l_renew_not_found;
	     END IF;

		  */
          WHEN OTHERS THEN
		   --dbms_output.put_line('san dbms others 1');
              OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);

               x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       END;
   ELSE
		   --dbms_output.put_line('san dbms in pre ren else');
         OKC_RENEW_PUB.RENEW(p_api_version   => 1,
                             p_init_msg_list => OKC_API.G_FALSE,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             x_contract_id   => x_contract_id,
                             p_renew_in_parameters_rec => p_renew_in_parameters_rec,
			     p_do_commit               => OKC_API.G_FALSE, --p_do_commit,
			     p_renewal_called_from_ui => p_renewal_called_from_ui /* added for bugfix 2093117 */
			     );


  END IF;

 IF p_do_commit = okc_api.g_true then
    commit;
 END IF;

EXCEPTION
WHEN OTHERS THEN
		   --dbms_output.put_line('san dbms others 2');
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end;


PROCEDURE Renew( p_api_version                  IN NUMBER,
    	         p_init_msg_list                IN VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
                 x_contract_id                  OUT NOCOPY number,
	         p_renew_in_parameters_rec      IN Renew_in_parameters_rec,
		 p_do_commit                    IN VARCHAR2 ,
		 p_renewal_called_from_ui       IN VARCHAR2 /* added for bugfix 2093117 */
  	       ) is



CURSOR cur_rules(p_chr_id number) is
  SELECT nvl(rul.rule_information1,OKC_API.G_MISS_CHAR) renew_type,
					   nvl(rul.rule_information2,OKC_API.G_MISS_CHAR) contact
  FROM okc_rules_b rul,okc_rule_groups_b rgp
  WHERE    rgp.dnz_chr_id = p_chr_id
           and   rgp.id=rul.rgp_id
	    --and   rgp.rgd_code='RENEW'
		 and   rul.rule_information_category='REN' ;

--rules migration
CURSOR cur_header(p_chr_id number) is
  SELECT * from okc_k_headers_b
  where id = p_chr_id;
--


  CURSOR cur_user(p_user_id number)
    is select fnd.user_name from okx_resources_v res, fnd_user fnd
    where fnd.user_id=res.user_id and res.id1=p_user_id;

 l_ren_type  okc_rules_v.rule_information1%type:=OKC_API.G_MISS_CHAR;
 l_contact  okc_rules_v.rule_information2%type:=OKC_API.G_MISS_CHAR;

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_renew_in_parameters_rec  renew_in_parameters_rec := p_renew_in_parameters_rec;
 lx_renew_in_parameters_rec  renew_in_parameters_rec ;
 l_api_name constant varchar2(30) := 'Renew_rec';
 l_chr_id number;
 cur_header_rec cur_header%rowtype;
begin


  --dbms_output.put_line('san dbms in 1');
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

---/rules migration/
    Open cur_header(p_renew_in_parameters_rec.p_contract_id);
    Fetch cur_header into cur_header_rec;
    Close cur_header;

    If cur_header_rec.application_id in (510,871) then
      open cur_rules(p_renew_in_parameters_rec.p_contract_id);
      fetch cur_rules into l_ren_type,l_contact;
      close cur_rules;
    Else
         l_ren_type := nvl(cur_header_rec.renewal_type_code,OKC_API.G_MISS_CHAR);
         If cur_header_rec.renewal_notify_to is not null Then
           l_contact := cur_header_rec.renewal_notify_to;
         Else
           l_contact  := OKC_API.G_MISS_CHAR;
         End If;
    End If;

---/rules migration/

   If l_ren_type = 'DNR' then
		  OKC_API.set_message(p_app_name      => g_app_name,
						  p_msg_name      => 'OKC_RENEW_NOT_ALLOWED');
		  RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;
   IF l_contact <> OKC_API.G_MISS_CHAR then
      open cur_user(to_number(l_contact));
      FETCH cur_user into l_contact;
      close cur_user;
   END IF;
  --dbms_output.put_line('san dbms in 2');

 -- Call user hook for BEFORE
    g_renew_in_parameters_rec := l_renew_in_parameters_rec;

    okc_util.call_user_hook(l_return_status, g_pkg_name, l_api_name, 'B');

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_renew_in_parameters_rec := g_renew_in_parameters_rec;
    l_renew_in_parameters_rec.p_contract_id := p_renew_in_parameters_rec.p_contract_id;


  --dbms_output.put_line('san dbms in 3');
         OKC_RENEW_PUB.CREATE_RENEWED_CONTRACT( p_api_version     => 1,
                              p_init_msg_list   => OKC_API.G_FALSE,
                              x_return_status   => l_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              x_contract_id     => x_contract_id,
                              p_renew_in_parameters_rec => l_renew_in_parameters_rec,
                              x_renew_in_parameters_rec => lx_renew_in_parameters_rec ,
                              p_ren_type                => l_ren_type ,
			      p_renewal_called_from_ui => p_renewal_called_from_ui /* added for bugfix 2093117 */
			      );
      /*    IF l_return_status = 'W' then
		   x_return_status := 'W';
          END IF;
       */

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR  OR l_return_status = 'W' THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

  --dbms_output.put_line('san dbms in 4');
         OKC_RENEW_PUB.POST_RENEWED_CONTRACT( p_api_version     => 1,
                              p_init_msg_list   => OKC_API.G_FALSE,
                              x_return_status   => l_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_renew_chr_id    => x_contract_id,
                              p_renew_in_parameters_rec => lx_renew_in_parameters_rec ,
                              p_ren_type                => l_ren_type ,
                              p_contact                 => l_contact );
        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

  -- Call user hook for AFTER
     g_new_contract_id := x_contract_id;

    okc_util.call_user_hook(l_return_status, g_pkg_name, l_api_name, 'A');

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

PROCEDURE Create_Renewed_contract
			( p_api_version                  IN NUMBER,
    	                  p_init_msg_list                IN VARCHAR2 ,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          x_contract_id                  OUT NOCOPY number,
	                  p_renew_in_parameters_rec      IN Renew_in_parameters_rec,
	                  x_renew_in_parameters_rec      OUT NOCOPY Renew_in_parameters_rec,
	                  p_ren_type                     IN varchar2 ,
		          p_renewal_called_from_ui       IN VARCHAR2  /* added for bugfix 2093117 */
  	          ) is

 l_renew_in_parameters_rec  renew_in_parameters_rec := p_renew_in_parameters_rec;
 l_api_name constant varchar2(30) := 'Create_renewed_contract';
 l_chr_id number;
begin
         okc_api.init_msg_list(p_init_msg_list);
         x_return_status  := OKC_API.G_RET_STS_SUCCESS;
         OKC_RENEW_PVT.CREATE_RENEWED_CONTRACT( p_api_version     => 1,
                              p_init_msg_list   => OKC_API.G_FALSE,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              x_contract_id     => x_contract_id,
                              p_renew_in_parameters_rec => l_renew_in_parameters_rec ,
                              x_renew_in_parameters_rec => x_renew_in_parameters_rec  ,
                              p_ren_type                => p_ren_type,
			      p_renewal_called_from_ui => p_renewal_called_from_ui /* added for bugfix 2093117 */
			);

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

PROCEDURE Post_Renewed_Contract
			( p_api_version                  IN NUMBER,
    	            p_init_msg_list                IN VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
                 p_renew_chr_id                 IN   number,
	            p_renew_in_parameters_rec      IN Renew_in_parameters_rec,
  		       p_ren_type                     IN VARCHAR2 ,
			  p_contact                      IN  VARCHAR2
  	          ) is

 l_api_name constant varchar2(30) := 'Post_renewed_contract';
begin
         okc_api.init_msg_list(p_init_msg_list);
         x_return_status  := OKC_API.G_RET_STS_SUCCESS;
         OKC_RENEW_PVT.POST_RENEWED_CONTRACT( p_api_version     => 1,
                              p_init_msg_list   => OKC_API.G_FALSE,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_renew_chr_id    => p_renew_chr_id,
	                         p_renew_in_parameters_rec=>  p_renew_in_parameters_rec,
  		                    p_ren_type               => p_ren_type,
			               p_contact                => p_contact
						);

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


PROCEDURE validate( p_api_version                  IN  NUMBER,
       	            p_init_msg_list                IN  VARCHAR2 ,
                    x_return_status                OUT NOCOPY VARCHAR2,
                    x_msg_count                    OUT NOCOPY NUMBER,
                    x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_renew_in_parameters_tbl 	   IN  Renew_in_parameters_tbl,
		    p_renewal_called_from_ui       IN VARCHAR2  /* added for bugfix 2093117 */
		  ) is

 l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin

  okc_api.init_msg_list(p_init_msg_list);

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  for i in p_renew_in_parameters_tbl.first..p_renew_in_parameters_tbl.last loop

   if p_renew_in_parameters_tbl.exists(i) then

     OKC_RENEW_PUB.validate( p_api_version    => p_api_version,
                             p_init_msg_list  => OKC_API.G_FALSE,
                             x_return_status  => l_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_renew_in_parameters_rec => p_renew_in_parameters_tbl(i) ,
			     p_renewal_called_from_ui => p_renewal_called_from_ui /* added for bugfix 2093117 */
			     );

     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
   end if;
 end loop;
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

PROCEDURE VALIDATE( p_api_version                  IN  NUMBER,
       	            p_init_msg_list                IN  VARCHAR2 ,
                    x_return_status                OUT NOCOPY VARCHAR2,
                    x_msg_count                    OUT NOCOPY NUMBER,
                    x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_renew_in_parameters_rec 	   IN  Renew_in_parameters_rec ,
		    p_renewal_called_from_ui       IN VARCHAR2  /* added for bugfix 2093117 */
		    ) is

begin

   okc_api.init_msg_list(p_init_msg_list);
   OKC_RENEW_PVT.validate(  p_api_version   => p_api_version,
                            p_init_msg_list => OKC_API.G_FALSE,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_renew_in_parameters_rec => p_renew_in_parameters_rec ,
			    p_renewal_called_from_ui => p_renewal_called_from_ui /* added for bugfix 2093117 */
					 );

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

Procedure Update_Parents_Date_Renewed( p_api_version        IN  NUMBER,
                                       p_init_msg_list      IN  VARCHAR2 ,
                                       x_return_status      OUT NOCOPY VARCHAR2,
                                       x_msg_count          OUT NOCOPY NUMBER,
                                       x_msg_data           OUT NOCOPY VARCHAR2,
                                       p_chr_id             IN NUMBER
                                      ) is

     l_api_name constant varchar2(30) := 'upd_parents_date_rnwd';
begin
         okc_api.init_msg_list(p_init_msg_list);
         x_return_status  := OKC_API.G_RET_STS_SUCCESS;
         OKC_RENEW_PVT.UPDATE_PARENTS_DATE_RENEWED( p_api_version  => 1,
                              p_init_msg_list   => OKC_API.G_FALSE,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_chr_id          => p_chr_id
						);

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

-- Bug 3580442 Overloaded is_already_not_renewed to accept only two parameters. This API is used in some events.
FUNCTION is_already_not_renewed(p_chr_id IN NUMBER, p_contract_number IN VARCHAR2) RETURN VARCHAR2 IS
l_msg_name VARCHAR2(1);
l_condition VARCHAR2(1);
BEGIN
       l_condition := OKC_RENEW_PVT.is_already_not_renewed(p_chr_id,p_contract_number,l_msg_name, 'N');
       --x_msg_name := l_msg_name;
       return l_condition;
END is_already_not_renewed;

-- Bug 3386577 Added an OUT parameter
FUNCTION is_already_not_renewed(p_chr_id IN NUMBER,p_contract_number IN VARCHAR2, x_msg_name OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
l_msg_name VARCHAR2(1);
l_condition VARCHAR2(1);
BEGIN

     l_condition := OKC_RENEW_PVT.is_already_not_renewed(p_chr_id, p_contract_number,l_msg_name);
     x_msg_name := l_msg_name;
     return l_condition;

END is_already_not_renewed;

end OKC_RENEW_PUB;

/
