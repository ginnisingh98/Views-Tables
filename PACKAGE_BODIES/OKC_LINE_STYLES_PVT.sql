--------------------------------------------------------
--  DDL for Package Body OKC_LINE_STYLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_LINE_STYLES_PVT" AS
/* $Header: OKCCLSEB.pls 120.0 2005/05/25 19:34:48 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_YES         VARCHAR2(3):='Y';
G_NO          VARCHAR2(3):='N';
G_UPD_IN_K          VARCHAR2(30):='OKC_UPD_IN_K_LINES';
G_UPD_IN_S          VARCHAR2(30):='OKC_UPD_IN_SETUPS';
G_DEL_IN_K          VARCHAR2(30):='OKC_DEL_IN_K_LINES';
G_DEL_IN_S          VARCHAR2(30):='OKC_DEL_IN_SETUPS';


 PROCEDURE add_language IS
 BEGIN
    OKC_LSE_PVT.add_language;
 END add_language;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_LINE_STYLES
 --------------------------------------------------------------------------

PROCEDURE CHANGE_PRICED_FOR_CHILDREN(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		        IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    lx_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;

    CURSOR loc_bot_csr (p_id IN NUMBER) is
	 select id, priced_yn from okc_line_styles_b
	 Connect by prior id = lse_parent_id
	 start with id = p_id;

    BEGIN
         x_return_status :=OKC_API.G_RET_STS_SUCCESS;
         for l_rec in loc_bot_csr(p_lsev_rec.id) loop
			 IF l_rec.priced_yn=G_Yes  and l_rec.id<>p_lsev_rec.id then
				 l_lsev_rec.id:=l_rec.id;
				 l_lsev_rec.priced_yn:=G_NO;
				 OKC_LINE_STYLES_PUB.UPDATE_LINE_STYLES(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_lsev_rec,
                                 lx_lsev_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
               END IF;
          END LOOP;

 EXCEPTION

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
		 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END CHANGE_PRICED_FOR_CHILDREN;



PROCEDURE CHANGE_PRICED_FOR_PARENT(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		        IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    lx_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    CURSOR loc_top_csr (p_id IN NUMBER) is
	 select id, priced_yn from okc_line_styles_b
	 connect by prior lse_parent_id = id
	 start with id = p_id;

    BEGIN
         x_return_status :=OKC_API.G_RET_STS_SUCCESS;
         for l_rec in loc_top_csr(p_lsev_rec.id) loop
			 IF l_rec.priced_yn=G_Yes  and l_rec.id<>p_lsev_rec.id then
				 l_lsev_rec.id:=l_rec.id;
				 l_lsev_rec.priced_yn:=G_NO;
				 OKC_LINE_STYLES_PUB.UPDATE_LINE_STYLES(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_lsev_rec,
                                 lx_lsev_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
               END IF;
          END LOOP;

 EXCEPTION

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
	    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END CHANGE_PRICED_FOR_PARENT;




PROCEDURE CHANGE_ITEM_TO_PRICE_CHILDREN(
    p_api_version               IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec                  IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    lx_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;

    CURSOR loc_bot_ip_csr (p_id IN NUMBER) is
         select id, item_to_price_yn from okc_line_styles_b
         Connect by prior id = lse_parent_id
         start with id = p_id;

    BEGIN
         x_return_status :=OKC_API.G_RET_STS_SUCCESS;
         for l_rec in loc_bot_ip_csr(p_lsev_rec.id) loop
                         IF l_rec.item_to_price_yn=G_Yes  and l_rec.id<>p_lsev_rec.id then
                                 l_lsev_rec.id:=l_rec.id;
                                 l_lsev_rec.item_to_price_yn:=G_NO;
                                 OKC_LINE_STYLES_PUB.UPDATE_LINE_STYLES(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_lsev_rec,
                                 lx_lsev_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
                         exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
               END IF;
          END LOOP;

 EXCEPTION

          WHEN OTHERS THEN
                   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                      p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
                 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END CHANGE_ITEM_TO_PRICE_CHILDREN;



PROCEDURE CHANGE_ITEM_TO_PRICE_PARENT(
    p_api_version               IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec                  IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    lx_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    CURSOR loc_top_ip_csr (p_id IN NUMBER) is
         select id, item_to_price_yn from okc_line_styles_b
         connect by prior lse_parent_id = id
         start with id = p_id;

  BEGIN
         x_return_status :=OKC_API.G_RET_STS_SUCCESS;
         for l_rec in loc_top_ip_csr(p_lsev_rec.id) loop
                         IF l_rec.item_to_price_yn=G_Yes  and l_rec.id<>p_lsev_rec.id then
                                 l_lsev_rec.id:=l_rec.id;
                                 l_lsev_rec.item_to_price_yn:=G_NO;
                                 OKC_LINE_STYLES_PUB.UPDATE_LINE_STYLES(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_lsev_rec,
                                 lx_lsev_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
               END IF;
          END LOOP;

 EXCEPTION

          WHEN OTHERS THEN
                   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                      p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END CHANGE_ITEM_TO_PRICE_PARENT;


PROCEDURE CHANGE_PRICE_BASIS_CHILDREN(
    p_api_version               IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec                  IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    lx_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;

    CURSOR loc_bot_pb_csr (p_id IN NUMBER) is
         select id, price_basis_yn from okc_line_styles_b
         Connect by prior id = lse_parent_id
         start with id = p_id;

    BEGIN
         x_return_status :=OKC_API.G_RET_STS_SUCCESS;
         for l_rec in loc_bot_pb_csr(p_lsev_rec.id) loop
                         IF l_rec.price_basis_yn = G_Yes  and l_rec.id<>p_lsev_rec.id then
                                 l_lsev_rec.id:=l_rec.id;
                                 l_lsev_rec.price_basis_yn:=G_NO;
                                 OKC_LINE_STYLES_PUB.UPDATE_LINE_STYLES(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_lsev_rec,
                                 lx_lsev_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
                         exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
                     END IF;
          END LOOP;

 EXCEPTION

          WHEN OTHERS THEN
                   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                      p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
                 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END CHANGE_PRICE_BASIS_CHILDREN;



PROCEDURE CHANGE_PRICE_BASIS_PARENT(
    p_api_version               IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec                  IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    lx_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    CURSOR loc_top_pb_csr (p_id IN NUMBER) is
         select id, price_basis_yn from okc_line_styles_b
         connect by prior lse_parent_id = id
         start with id = p_id;

  BEGIN
         x_return_status :=OKC_API.G_RET_STS_SUCCESS;
         for l_rec in loc_top_pb_csr(p_lsev_rec.id) loop
                       IF l_rec.price_basis_yn = G_Yes  and l_rec.id<>p_lsev_rec.id then
                                 l_lsev_rec.id:=l_rec.id;
                                 l_lsev_rec.price_basis_yn :=G_NO;
                                 OKC_LINE_STYLES_PUB.UPDATE_LINE_STYLES(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_lsev_rec,
                                 lx_lsev_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
               END IF;
          END LOOP;

 EXCEPTION

          WHEN OTHERS THEN
                   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                      p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END CHANGE_PRICE_BASIS_PARENT;




FUNCTION USED_IN_K_LINES(p_id    IN number)
    RETURN VARCHAR2 IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;

    CURSOR c1 (p_id IN NUMBER) is
	 select OKC_API.G_RET_STS_ERROR from okc_k_lines_b where lse_id=p_id;

    BEGIN
           Open c1(p_id);
		 fetch c1 into l_return_status;
		 close c1;
		 return l_return_status;

 EXCEPTION

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
		 l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END USED_IN_K_LINES;

FUNCTION USED_IN_SETUPS(p_id IN number)
    RETURN VARCHAR2 IS
    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_excp_error                  EXCEPTION;
    CURSOR c3 (p_id IN NUMBER) is
	 select OKC_API.G_RET_STS_ERROR from okc_line_style_roles where lse_id=p_id;
    CURSOR c4 (p_id IN NUMBER) is
	 select OKC_API.G_RET_STS_ERROR from okc_lse_rule_groups where lse_id=p_id;
    CURSOR c5 (p_id IN NUMBER) is
	 select OKC_API.G_RET_STS_ERROR from okc_subclass_top_line where lse_id=p_id;

    BEGIN
           Open c3(p_id);
		 fetch c3 into l_return_status;
		 close c3;
		 IF l_return_status=OKC_API.G_RET_STS_ERROR then
			raise l_excp_error;
           END IF;
           Open c4(p_id);
		 fetch c4 into l_return_status;
		 close c4;
		 IF l_return_status=OKC_API.G_RET_STS_ERROR then
			raise l_excp_error;
           END IF;
           Open c5(p_id);
		 fetch c5 into l_return_status;
		 close c5;
		 IF l_return_status=OKC_API.G_RET_STS_ERROR then
			raise l_excp_error;
           END IF;
		 return l_return_status;

 EXCEPTION

      WHEN l_excp_error then
		  return l_return_status;
	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
		 l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END USED_IN_SETUPS;


FUNCTION USED_IN_SRC_OPS(p_id IN number)
    RETURN VARCHAR2 IS
    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_excp_error                  EXCEPTION;
    CURSOR c1 (p_id IN NUMBER) is
	 select OKC_API.G_RET_STS_ERROR from okc_line_style_sources where lse_id=p_id;
    CURSOR c2 (p_id IN NUMBER) is
	 select OKC_API.G_RET_STS_ERROR from okc_val_line_operations where lse_id=p_id;

    BEGIN
           Open c1(p_id);
		 fetch c1 into l_return_status;
		 close c1;
		 IF l_return_status=OKC_API.G_RET_STS_ERROR then
			raise l_excp_error;
           END IF;
           Open c2(p_id);
		 fetch c2 into l_return_status;
		 close c2;
		 IF l_return_status=OKC_API.G_RET_STS_ERROR then
			raise l_excp_error;
           END IF;
		 return l_return_status;

 EXCEPTION

      WHEN l_excp_error then
		  return l_return_status;
	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
		 l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END USED_IN_SRC_OPS;


PROCEDURE DELETE_SUB_LINES(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		        IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    CURSOR c1(p_id IN NUMBER) is
	 select id from okc_line_styles_b where lse_parent_id=p_id;

    BEGIN
         for l_rec in c1(p_lsev_rec.id) loop
				 l_lsev_rec.id:=l_rec.id;
				 OKC_LINE_STYLES_PUB.DELETE_LINE_STYLES(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_lsev_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
          END LOOP;

 EXCEPTION

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
	    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END DELETE_SUB_LINES;


PROCEDURE DELETE_SOURCES(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		        IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lssv_rec                    OKC_LINE_STYLES_PUB.lssv_rec_type;
    CURSOR c1(p_id IN NUMBER) is
	 select lse_id,jtot_object_code from okc_line_style_sources where lse_id=p_id;

    BEGIN
         for l_rec in c1(p_lsev_rec.id) loop
				 l_lssv_rec.lse_id:=l_rec.lse_id;
				 l_lssv_rec.jtot_object_code:=l_rec.jtot_object_code;
				 OKC_LINE_STYLES_PUB.DELETE_LINE_STYLE_SOURCES(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_lssv_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
          END LOOP;

 EXCEPTION

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
	    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END DELETE_SOURCES;


PROCEDURE DELETE_VAL_OPS(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		        IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_vlov_rec                    OKC_LINE_STYLES_PUB.vlov_rec_type;
    CURSOR c1(p_id IN NUMBER) is
	 select lse_id from okc_val_line_operations where lse_id=p_id;

    BEGIN
         for l_rec in c1(p_lsev_rec.id) loop
				 l_vlov_rec.lse_id:=l_rec.lse_id;
				 OKC_LINE_STYLES_PUB.DELETE_VAL_LINE_OPERATION(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_vlov_rec);
                    exit when x_return_status <> OKC_API.G_RET_STS_SUCCESS;
          END LOOP;

 EXCEPTION

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
	    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END DELETE_VAL_OPS;


  PROCEDURE CREATE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type,
    x_lsev_rec              OUT NOCOPY lsev_rec_type) IS
  BEGIN
    okc_lse_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lsev_rec,
    x_lsev_rec);
    --If the new line has priced_yn set to 'Y' then set its parent's to 'N'
    IF x_return_status=OKC_API.G_RET_STS_SUCCESS and x_lsev_rec.priced_yn=G_YES then

          CHANGE_PRICED_FOR_PARENT(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
    END IF;

   IF x_return_status=OKC_API.G_RET_STS_SUCCESS and x_lsev_rec.item_to_price_yn=G_YES then

          CHANGE_ITEM_TO_PRICE_PARENT(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
    END IF;

    IF x_return_status=OKC_API.G_RET_STS_SUCCESS and x_lsev_rec.price_basis_yn=G_YES then

          CHANGE_PRICE_BASIS_PARENT(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
    END IF;
 EXCEPTION

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
	    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END CREATE_LINE_STYLES;

  PROCEDURE UPDATE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type,
    x_lsev_rec              OUT NOCOPY lsev_rec_type) IS
    l_excp_error            EXCEPTION;
    l_lsev_rec              lsev_rec_type;
  BEGIN
    IF  p_lsev_rec.lty_code<>OKC_API.G_MISS_CHAR then
	   x_return_status:=USED_IN_K_LINES(p_lsev_rec.id);
	   IF x_return_status=OKC_API.G_RET_STS_ERROR then
		OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      =>G_UPD_IN_K);
		raise l_excp_error;
        END IF;

        IF p_lsev_rec.lty_code='FREE_FORM' then
             DELETE_SOURCES(
                 p_api_version,
                 p_init_msg_list,
                 x_return_status,
                 x_msg_count,
                 x_msg_data,
                 p_lsev_rec);

               IF x_return_status=OKC_API.G_RET_STS_ERROR then
	           	raise l_excp_error;
               END IF;
        END IF;

    END IF;
    okc_lse_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lsev_rec,
    x_lsev_rec);
    --If the updated line has priced_yn set to 'Y' then set its children's to 'N'
    IF x_return_status=OKC_API.G_RET_STS_SUCCESS and x_lsev_rec.priced_yn=G_YES then
          CHANGE_PRICED_FOR_CHILDREN(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
		--If the updated line has priced_yn set to 'Y' then set its parent's to 'N'
          CHANGE_PRICED_FOR_PARENT(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
   END IF;

 IF x_return_status=OKC_API.G_RET_STS_SUCCESS and x_lsev_rec.item_to_price_yn=G_YES then
          CHANGE_ITEM_TO_PRICE_CHILDREN(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
                --If the updated line has item_to_price_yn set to 'Y' then set its parent's to 'N'
          CHANGE_ITEM_TO_PRICE_PARENT(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
  END IF;

  IF x_return_status=OKC_API.G_RET_STS_SUCCESS and x_lsev_rec.price_basis_yn=G_YES then
          CHANGE_PRICE_BASIS_CHILDREN(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
                --If the updated line has price_basis_yn set to 'Y' then set its parent's to 'N'
          CHANGE_PRICE_BASIS_PARENT(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        x_lsev_rec);
    END IF;


 EXCEPTION
	 WHEN l_excp_error then
	  x_return_status := OKC_API.G_RET_STS_ERROR;

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
			  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END UPDATE_LINE_STYLES;

PROCEDURE DELETE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) IS

    l_excp_error            EXCEPTION;
  BEGIN
    x_return_status:=USED_IN_K_LINES(p_lsev_rec.id);
    IF x_return_status=OKC_API.G_RET_STS_ERROR then
	 OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => G_DEL_IN_K);
	 raise l_excp_error;
    END IF;
    x_return_status:=USED_IN_SETUPS(p_lsev_rec.id);
    IF x_return_status=OKC_API.G_RET_STS_ERROR then
	 OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => G_DEL_IN_S);
	raise l_excp_error;
    END IF;

    DELETE_SUB_LINES(
                 p_api_version,
                 p_init_msg_list,
                 x_return_status,
                 x_msg_count,
                 x_msg_data,
                 p_lsev_rec);
    IF x_return_status=OKC_API.G_RET_STS_ERROR then
		raise l_excp_error;
    END IF;

    DELETE_VAL_OPS(
                 p_api_version,
                 p_init_msg_list,
                 x_return_status,
                 x_msg_count,
                 x_msg_data,
                 p_lsev_rec);

    IF x_return_status=OKC_API.G_RET_STS_ERROR then
		raise l_excp_error;
    END IF;

    DELETE_SOURCES(
                 p_api_version,
                 p_init_msg_list,
                 x_return_status,
                 x_msg_count,
                 x_msg_data,
                 p_lsev_rec);

    IF x_return_status=OKC_API.G_RET_STS_ERROR then
		raise l_excp_error;
    END IF;

    okc_lse_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lsev_rec);
 EXCEPTION
	 WHEN l_excp_error then
	  x_return_status := OKC_API.G_RET_STS_ERROR;

	  WHEN OTHERS THEN
		   OKC_API.set_message(p_app_name      => g_app_name,
			    p_msg_name      => g_unexpected_error,
 	              p_token1        => g_sqlcode_token,
			    p_token1_value  => sqlcode,
			    p_token2        => g_sqlerrm_token,
		         p_token2_value  => sqlerrm);
			  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END DELETE_LINE_STYLES;

  PROCEDURE LOCK_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) IS
  BEGIN
    okc_lse_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lsev_rec);
  END LOCK_LINE_STYLES;

  PROCEDURE VALID_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) IS
  BEGIN
    okc_lse_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lsev_rec);
  END VALID_LINE_STYLES;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_LINE_STYLE_SOURCES
 --------------------------------------------------------------------------

  PROCEDURE CREATE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type,
    x_lssv_rec              OUT NOCOPY lssv_rec_type) IS
  BEGIN
    okc_lss_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lssv_rec,
    x_lssv_rec);
  END CREATE_LINE_STYLE_SOURCES;

  PROCEDURE UPDATE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type,
    x_lssv_rec              OUT NOCOPY lssv_rec_type) IS
  BEGIN
    okc_lss_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lssv_rec,
    x_lssv_rec);
  END UPDATE_LINE_STYLE_SOURCES;

  PROCEDURE DELETE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) IS
  BEGIN
    okc_lss_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lssv_rec);
  END DELETE_LINE_STYLE_SOURCES;

  PROCEDURE LOCK_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) IS
  BEGIN
    okc_lss_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lssv_rec);
  END LOCK_LINE_STYLE_SOURCES;

  PROCEDURE VALID_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) IS
  BEGIN
    okc_lss_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lssv_rec);
  END VALID_LINE_STYLE_SOURCES;


--added by smhanda

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_VAL_LINE_OPERATION
 --------------------------------------------------------------------------

  PROCEDURE CREATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type,
    x_vlov_rec              OUT NOCOPY vlov_rec_type) IS
  BEGIN
    okc_vlo_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_vlov_rec,
    x_vlov_rec);
  END CREATE_VAL_LINE_OPERATION;

  PROCEDURE UPDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type,
    x_vlov_rec              OUT NOCOPY vlov_rec_type) IS
  BEGIN
    okc_vlo_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_vlov_rec,
    x_vlov_rec);
  END UPDATE_VAL_LINE_OPERATION;

  PROCEDURE DELETE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) IS
  BEGIN
    okc_vlo_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_vlov_rec);
  END DELETE_VAL_LINE_OPERATION;

  PROCEDURE LOCK_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) IS
  BEGIN
    okc_vlo_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_vlov_rec);
  END LOCK_VAL_LINE_OPERATION;

  PROCEDURE VALIDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) IS
  BEGIN
    okc_vlo_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_vlov_rec);
  END VALIDATE_VAL_LINE_OPERATION;


END OKC_LINE_STYLES_PVT;

/
