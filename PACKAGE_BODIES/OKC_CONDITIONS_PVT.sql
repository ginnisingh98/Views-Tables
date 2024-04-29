--------------------------------------------------------
--  DDL for Package Body OKC_CONDITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONDITIONS_PVT" as
/* $Header: OKCCCNHB.pls 120.0 2005/05/25 23:07:45 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE add_language IS
Begin
	okc_cnh_pvt.add_language;
	okc_cnl_pvt.add_language;
End;

--Object type procedure for insert
PROCEDURE create_cond_hdrs(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		        IN cnhv_rec_type,
    p_cnlv_tbl              IN cnlv_tbl_type,
    x_cnhv_rec              OUT NOCOPY cnhv_rec_type,
    x_cnlv_tbl              OUT NOCOPY cnlv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnhv_rec              cnhv_rec_type;
    l_cnlv_tbl              cnlv_tbl_type := p_cnlv_tbl;
    i			    NUMBER;
begin
    --Populate the Master
    create_cond_hdrs(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_cnhv_rec,
    	x_cnhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    -- Populate the foreign key for the detail
    IF (l_cnlv_tbl.COUNT > 0) THEN
       i := l_cnlv_tbl.FIRST;
       LOOP
          l_cnlv_tbl(i).cnh_id := x_cnhv_rec.id;
          EXIT WHEN (i = l_cnlv_tbl.LAST);
          i := l_cnlv_tbl.NEXT(i);
       END LOOP;
    END IF;

    --Populate the detail
    create_cond_lines(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
   	x_msg_count,
    	x_msg_data,
    	l_cnlv_tbl,
    	x_cnlv_tbl);
	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	Null;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End create_cond_hdrs;

--Object type procedure for update
PROCEDURE update_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type,
    p_cnlv_tbl              IN cnlv_tbl_type,
    x_cnhv_rec              OUT NOCOPY cnhv_rec_type,
    x_cnlv_tbl              OUT NOCOPY cnlv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
    --Update the Master
    update_cond_hdrs(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_cnhv_rec,
    	x_cnhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    --Update the detail
    update_cond_lines(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_tbl,
    x_cnlv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
	Null;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end update_cond_hdrs;

--Object type procedure for validate
PROCEDURE validate_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type,
    p_cnlv_tbl              IN cnlv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
    --Validate the Master
    validate_cond_hdrs(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    --Validate the Detail
    validate_cond_lines(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	Null;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End validate_cond_hdrs;

-- Procedure for updating the minor version

PROCEDURE update_minor_version(p_chr_id IN NUMBER) IS
  l_api_version          NUMBER := 1;
  l_init_msg_list        VARCHAR2(1) := 'F';
  x_return_status        VARCHAR2(1);
  x_msg_count            NUMBER ;
  x_msg_data             VARCHAR2(2000);
  x_out_rec              OKC_CVM_PVT.cvmv_rec_type;
  l_cvmv_rec             OKC_CVM_PVT.cvmv_rec_type;
  l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
  -- assign/populate contract header id
	l_cvmv_rec.chr_id := p_chr_id;

	OKC_CVM_PVT.update_contract_version(
	p_api_version               => l_api_version,
	p_init_msg_list             => l_init_msg_list,
	x_return_status             => x_return_status,
	x_msg_count                 => x_msg_count,
	x_msg_data                  => x_msg_data,
	p_cvmv_rec                  => l_cvmv_rec,
	x_cvmv_rec                  => x_out_rec);

	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE G_EXCEPTION_HALT_VALIDATION;
     ELSE
	   IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		 l_return_status := x_return_status;
        END IF;
     END IF;
EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;
	WHEN OTHERS THEN
	OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
					p_msg_name      => g_unexpected_error,
					p_token1        => g_sqlcode_token,
					p_token1_value  => sqlcode,
					p_token2        => g_sqlerrm_token,
					p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END update_minor_version;

--Procedures for Condition Header

PROCEDURE create_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type,
    x_cnhv_rec              OUT NOCOPY cnhv_rec_type) IS
begin
    okc_cnh_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_rec,
    x_cnhv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_cnhv_rec.dnz_chr_id);
    END IF;

End create_cond_hdrs;

PROCEDURE create_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_tbl		    IN cnhv_tbl_type,
    x_cnhv_tbl              OUT NOCOPY cnhv_tbl_type) IS
begin
    okc_cnh_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_tbl,
    x_cnhv_tbl);
End create_cond_hdrs;

PROCEDURE lock_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type) IS
begin
    okc_cnh_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_rec);
End lock_cond_hdrs;

PROCEDURE lock_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_tbl		    IN cnhv_tbl_type) IS
begin
    okc_cnh_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_tbl);
End lock_cond_hdrs;

PROCEDURE update_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type,
    x_cnhv_rec              OUT NOCOPY cnhv_rec_type) IS
begin
    okc_cnh_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_rec,
    x_cnhv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_cnhv_rec.dnz_chr_id);
    END IF;
End update_cond_hdrs;

PROCEDURE update_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_tbl		    IN cnhv_tbl_type,
    x_cnhv_tbl              OUT NOCOPY cnhv_tbl_type) IS
begin
    okc_cnh_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_tbl,
    x_cnhv_tbl);
End update_cond_hdrs;

--Procedure for Cascade Delete
PROCEDURE delete_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type) IS

    l_dummy                 VARCHAR2(1) ;
    l_row_found             BOOLEAN := TRUE ;
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;
    l_cnlv_tbl              cnlv_tbl_type;
    l_ocev_tbl              ocev_tbl_type;
--Bug 3122962
    Cursor tve_cur is
    select '1'
    from okc_timevalues tve
    where tve.cnh_id = p_cnhv_rec.id
    and   tve.tve_type = 'TGN';

    Cursor cnl_cur is
    select cnl.id
    from okc_condition_lines_v cnl
    where cnl.cnh_id = p_cnhv_rec.id;

    Cursor oce_cur is
    select oce.id
    from okc_outcomes_v oce
    where oce.cnh_id = p_cnhv_rec.id;

begin
 -- check if condition has time value attached to it, if it is attached
 -- then raise error message
 OPEN tve_cur;
 FETCH tve_cur INTO l_dummy;
 l_row_found := tve_cur%FOUND;
 CLOSE tve_cur;
  IF (l_row_found) THEN
    -- put error message
      OKC_API.set_message(G_APP_NAME, 'OKC_TIMEVALUE_EXIST');
      x_return_status := OKC_API.G_RET_STS_ERROR ;
    raise G_EXCEPTION_HALT_VALIDATION;
 ELSE
      --populate the Foreign key of the outcomes
      For oce_rec in oce_cur loop
	  i := i + 1;
	  l_ocev_tbl(i).id := oce_rec.id;
      End loop;

      --Delete outcomes
      IF l_ocev_tbl.COUNT > 0 THEN
      -- call Public delete procedure for outcomes
       	okc_outcome_pub.delete_outcome(
    			p_api_version,
    			p_init_msg_list,
    			x_return_status,
    			x_msg_count,
    			x_msg_data,
    			l_ocev_tbl);
        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;
      END IF;

      --populate the Foreign key of the detail
      For cnl_rec in cnl_cur loop
	i := i + 1;
	l_cnlv_tbl(i).id := cnl_rec.id;
      End loop;

      --Delete the details
      -- call Public delete procedure
      IF l_cnlv_tbl.COUNT > 0 THEN
       	okc_conditions_pub.delete_cond_lines(
    			p_api_version,
    			p_init_msg_list,
    			x_return_status,
    			x_msg_count,
    			x_msg_data,
    			l_cnlv_tbl);
        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;
      END IF;

	--Delete the Master
        okc_cnh_pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_cnhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      	raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
        END IF;
    END IF;
 END IF;

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_cnhv_rec.dnz_chr_id);
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	Null;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End delete_cond_hdrs;

PROCEDURE delete_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_tbl		    IN cnhv_tbl_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
      --Initialize the return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_cnhv_tbl.COUNT > 0) THEN
       	  i := p_cnhv_tbl.FIRST;
       LOOP
          delete_cond_hdrs(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_cnhv_tbl(i));
          EXIT WHEN (i = p_cnhv_tbl.LAST);
          i := p_cnhv_tbl.NEXT(i);
       END LOOP;
    END IF;
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;
EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	Null;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End delete_cond_hdrs;

PROCEDURE validate_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type) IS
begin
    okc_cnh_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_rec);
End validate_cond_hdrs;

PROCEDURE validate_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_tbl		    IN cnhv_tbl_type) IS
begin
    okc_cnh_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnhv_tbl);
End validate_cond_hdrs;

/*****************************************************************/
--Procedures for Condition Lines

PROCEDURE create_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_rec		    IN cnlv_rec_type,
    x_cnlv_rec              OUT NOCOPY cnlv_rec_type) IS
begin
    okc_cnl_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_rec,
    x_cnlv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_cnlv_rec.dnz_chr_id);
    END IF;
End create_cond_lines;

PROCEDURE create_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_tbl		    IN cnlv_tbl_type,
    x_cnlv_tbl              OUT NOCOPY cnlv_tbl_type) IS
begin
    okc_cnl_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_tbl,
    x_cnlv_tbl);
End create_cond_lines;

PROCEDURE lock_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_rec		    IN cnlv_rec_type) IS
begin
    okc_cnl_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_rec);
End lock_cond_lines;

PROCEDURE lock_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_tbl		    IN cnlv_tbl_type) IS
begin
    okc_cnl_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_tbl);
End lock_cond_lines;

PROCEDURE update_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_rec		    IN cnlv_rec_type,
    x_cnlv_rec              OUT NOCOPY cnlv_rec_type) IS
begin
    okc_cnl_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_rec,
    x_cnlv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_cnlv_rec.dnz_chr_id);
    END IF;
End update_cond_lines;

PROCEDURE update_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_tbl		    IN cnlv_tbl_type,
    x_cnlv_tbl              OUT NOCOPY cnlv_tbl_type) IS
begin
    okc_cnl_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_tbl,
    x_cnlv_tbl);
End update_cond_lines;

PROCEDURE delete_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_rec		    IN cnlv_rec_type) IS

    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                   NUMBER := 0;
    l_fepv_tbl        fepv_tbl_type;

    Cursor fep_cur is
    select fep.id
    from okc_function_expr_params_v fep
    where fep.cnl_id = p_cnlv_rec.id;
begin
    -- Populate the Foreign key of the detail
    For fep_rec in fep_cur loop
	i := i + 1;
	l_fepv_tbl(i).id := fep_rec.id;
    End loop;
     --Delete the fep details
     --call public delete procedure
    IF l_fepv_tbl.COUNT > 0 THEN
	  okc_conditions_pub.delete_func_exprs(
			  p_api_version,
			  p_init_msg_list,
			  x_return_status,
			  x_msg_count,
			  x_msg_data,
			  l_fepv_tbl);
	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       	   raise G_EXCEPTION_HALT_VALIDATION;
	ELSE
	   IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	      l_return_status := x_return_status;
	   END IF;
	END IF;
     END IF;

	 --Delete the condition lines
    okc_cnl_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_rec);
	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
           raise G_EXCEPTION_HALT_VALIDATION;
	ELSE
	   IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	      l_return_status := x_return_status;
	   END IF;
	END IF;

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_cnlv_rec.dnz_chr_id);
    END IF;
EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    Null;

   WHEN OTHERS THEN
	   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
	                       p_token1        => g_sqlcode_token,
			       p_token1_value  => sqlcode,
			       p_token2        => g_sqlerrm_token,
			       p_token2_value  => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End delete_cond_lines;

PROCEDURE delete_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_tbl		    IN cnlv_tbl_type) IS
begin
    okc_cnl_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_tbl);

End delete_cond_lines;

PROCEDURE validate_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_rec		    IN cnlv_rec_type) IS
begin
    okc_cnl_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_rec);
End validate_cond_lines;

PROCEDURE validate_cond_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnlv_tbl		    IN cnlv_tbl_type) IS
begin
    okc_cnl_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cnlv_tbl);
End validate_cond_lines;

/*****************************************************************/
--Procedures for Action Attribute Values

PROCEDURE create_act_att_vals(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aavv_rec		    IN aavv_rec_type,
    x_aavv_rec              OUT NOCOPY aavv_rec_type) IS
begin
    okc_aav_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aavv_rec,
    x_aavv_rec);
End create_act_att_vals;

PROCEDURE create_act_att_vals(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aavv_tbl		    IN aavv_tbl_type,
    x_aavv_tbl              OUT NOCOPY aavv_tbl_type) IS
begin
    okc_aav_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aavv_tbl,
    x_aavv_tbl);
End create_act_att_vals;

PROCEDURE delete_act_att_vals(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aavv_rec		    IN aavv_rec_type) IS
begin
    okc_aav_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aavv_rec);
End delete_act_att_vals;

PROCEDURE delete_act_att_vals(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aavv_tbl		    IN aavv_tbl_type) IS
begin
    okc_aav_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aavv_tbl);
End delete_act_att_vals;

PROCEDURE validate_act_att_vals(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aavv_rec		    IN aavv_rec_type) IS
begin
    okc_aav_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aavv_rec);
End validate_act_att_vals;

PROCEDURE validate_act_att_vals(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aavv_tbl		    IN aavv_tbl_type) IS
begin
    okc_aav_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aavv_tbl);
End validate_act_att_vals;

/*****************************************************************/
--Procedures for Condition Occurrence

PROCEDURE create_cond_occurs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_coev_rec		    IN coev_rec_type,
    x_coev_rec              OUT NOCOPY coev_rec_type) IS
begin
    okc_coe_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_coev_rec,
    x_coev_rec);
End create_cond_occurs;

PROCEDURE create_cond_occurs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_coev_tbl		    IN coev_tbl_type,
    x_coev_tbl              OUT NOCOPY coev_tbl_type) IS
begin
    okc_coe_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_coev_tbl,
    x_coev_tbl);
End create_cond_occurs;

PROCEDURE delete_cond_occurs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_coev_rec		    IN coev_rec_type) IS
begin
    okc_coe_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_coev_rec);
End delete_cond_occurs;

PROCEDURE delete_cond_occurs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_coev_tbl		    IN coev_tbl_type) IS
begin
    okc_coe_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_coev_tbl);
End delete_cond_occurs;

PROCEDURE validate_cond_occurs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_coev_rec		    IN coev_rec_type) IS
begin
    okc_coe_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_coev_rec);
End validate_cond_occurs;

PROCEDURE validate_cond_occurs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_coev_tbl		    IN coev_tbl_type) IS
begin
    okc_coe_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_coev_tbl);
End validate_cond_occurs;

/*****************************************************************/
--Procedures for Action Attribute Lookups

PROCEDURE create_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_rec		    IN aalv_rec_type,
    x_aalv_rec              OUT NOCOPY aalv_rec_type) IS
begin
    okc_aal_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_rec,
    x_aalv_rec);
End create_act_att_lkps;

PROCEDURE create_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_tbl		    IN aalv_tbl_type,
    x_aalv_tbl              OUT NOCOPY aalv_tbl_type) IS
begin
    okc_aal_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_tbl,
    x_aalv_tbl);
End create_act_att_lkps;

PROCEDURE lock_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_rec		    IN aalv_rec_type) IS
begin
    okc_aal_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_rec);
End lock_act_att_lkps;

PROCEDURE lock_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_tbl		    IN aalv_tbl_type) IS
begin
    okc_aal_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_tbl);
End lock_act_att_lkps;

PROCEDURE update_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_rec		    IN aalv_rec_type,
    x_aalv_rec              OUT NOCOPY aalv_rec_type) IS
begin
    okc_aal_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_rec,
    x_aalv_rec);
End update_act_att_lkps;

PROCEDURE update_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_tbl		    IN aalv_tbl_type,
    x_aalv_tbl              OUT NOCOPY aalv_tbl_type) IS
begin
    okc_aal_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_tbl,
    x_aalv_tbl);
End update_act_att_lkps;

PROCEDURE delete_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_rec		    IN aalv_rec_type) IS
begin
    okc_aal_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_rec);
End delete_act_att_lkps;

PROCEDURE delete_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_tbl		    IN aalv_tbl_type) IS
begin
    okc_aal_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_tbl);
End delete_act_att_lkps;

PROCEDURE validate_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_rec		    IN aalv_rec_type) IS
begin
    okc_aal_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_rec);
End validate_act_att_lkps;

PROCEDURE validate_act_att_lkps(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aalv_tbl		    IN aalv_tbl_type) IS
begin
    okc_aal_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aalv_tbl);
End validate_act_att_lkps;

/*****************************************************************/
--Procedures for Function Expression Parameters

PROCEDURE create_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_rec		    IN fepv_rec_type,
    x_fepv_rec              OUT NOCOPY fepv_rec_type) IS
begin
    okc_fep_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_rec,
    x_fepv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_fepv_rec.dnz_chr_id);
    END IF;
End create_func_exprs;

PROCEDURE create_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_tbl		    IN fepv_tbl_type,
    x_fepv_tbl              OUT NOCOPY fepv_tbl_type) IS
begin
    okc_fep_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_tbl,
    x_fepv_tbl);
End create_func_exprs;

PROCEDURE lock_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_rec		    IN fepv_rec_type) IS
begin
    okc_fep_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_rec);
End lock_func_exprs;

PROCEDURE lock_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_tbl		    IN fepv_tbl_type) IS
begin
    okc_fep_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_tbl);
End lock_func_exprs;

PROCEDURE update_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_rec		    IN fepv_rec_type,
    x_fepv_rec              OUT NOCOPY fepv_rec_type) IS
begin
    okc_fep_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_rec,
    x_fepv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_fepv_rec.dnz_chr_id);
    END IF;
End update_func_exprs;

PROCEDURE update_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_tbl		    IN fepv_tbl_type,
    x_fepv_tbl              OUT NOCOPY fepv_tbl_type) IS
begin
    okc_fep_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_tbl,
    x_fepv_tbl);
End update_func_exprs;

PROCEDURE delete_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_rec		    IN fepv_rec_type) IS
begin
    okc_fep_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       Update_Minor_Version(p_fepv_rec.dnz_chr_id);
    END IF;
End delete_func_exprs;

PROCEDURE delete_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_tbl		    IN fepv_tbl_type) IS
begin
    okc_fep_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_tbl);
End delete_func_exprs;

PROCEDURE validate_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_rec		    IN fepv_rec_type) IS
begin
    okc_fep_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_rec);
End validate_func_exprs;

PROCEDURE validate_func_exprs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fepv_tbl		    IN fepv_tbl_type) IS
begin
    okc_fep_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_fepv_tbl);
End validate_func_exprs;

PROCEDURE valid_condition_lines(
    p_cnh_id                IN  okc_condition_headers_b.id%TYPE,
    x_string                OUT NOCOPY VARCHAR2,
    x_valid_flag            OUT NOCOPY VARCHAR2)
    IS

    CURSOR cnl_cur
    IS
    SELECT cnl.sortseq sortseq,
	   cnl.cnl_type cnl_type,
	   cnl.aae_id aae_id,
	   cnl.pdf_id pdf_id,
	   cnl.cnh_id cnh_id,
	   cnl.left_parenthesis left_parenthesis,
	   cnl.left_ctr_master_id left_ctr_master_id,
	   cnl.left_counter_id left_counter_id,
	   cnl.relational_operator relational_operator,
	   cnl.right_ctr_master_id right_ctr_master_id,
	   cnl.right_counter_id right_counter_id,
	   cnl.right_operand right_operand,
	   cnl.right_parenthesis right_parenthesis,
	   cnl.logical_operator logical_operator
   FROM    okc_condition_lines_b cnl
   WHERE   cnl.cnh_id = p_cnh_id
   ORDER   BY cnl.sortseq;
   cnl_rec cnl_cur%ROWTYPE;

   CURSOR aae_cur( a IN NUMBER)
   IS
   SELECT  name
   FROM    okc_action_attributes_v
   WHERE   id = a;
   aae_rec aae_cur%ROWTYPE;

   CURSOR pdf_cur(b IN NUMBER)
   IS
   SELECT  name
   FROM    okc_process_defs_v
   WHERE   id = b;
   pdf_rec pdf_cur%ROWTYPE;

   CURSOR ctr_cur(x IN NUMBER)
   IS
   SELECT  name
   FROM    okx_counters_v
   WHERE   counter_id = x;
   ctr_rec ctr_cur%ROWTYPE;

   l_string      VARCHAR2(32000):= 'select sysdate from dual where ';
   l_cursor      NUMBER;
   left_value    VARCHAR2(100);
   right_value   VARCHAR2(100);
   l_valid_flag  VARCHAR2(1);
   l_dummy       INTEGER;
   line_found    boolean := FALSE;

   BEGIN

   --build a string of expressions from the condition lines,
   --sorted by sequence number.
   -- assign constant values to the variable
   --parse all condition lines for the current record's header id and
   --return Y/N

   ------------------------------------------
   ------------------------------------------
   l_cursor := DBMS_SQL.open_cursor;
   ------------------------------------------
   ------------------------------------------

   OPEN cnl_cur;
   LOOP
   FETCH cnl_cur INTO cnl_rec;
   IF cnl_cur%NOTFOUND THEN
      IF line_found THEN
      -- open cursor and parse the string
       DBMS_SQL.parse (l_cursor,l_string,DBMS_SQL.native);
       DBMS_SQL.close_cursor(l_cursor);
      x_valid_flag := 'Y';
	EXIT;
      ELSE
      -- if there are no lines then set the flag to Y
      x_valid_flag := 'Y';
	EXIT;
      END IF;
   ELSE
     line_found := TRUE;
       IF cnl_rec.cnl_type IN ('GEX','CEX') THEN
         l_string := l_string||nvl(cnl_rec.left_parenthesis,' ')||
                   ':left_value'||'='||
                   ':right_value'||nvl(cnl_rec.right_parenthesis,' ')||
                   nvl(cnl_rec.logical_operator,' ');
       ELSIF cnl_rec.cnl_type = 'FEX' THEN
	 l_string := l_string||nvl(cnl_rec.left_parenthesis,' ')||
		    ':left_value'||'='||
	            ':right_value'||nvl(cnl_rec.right_parenthesis,' ')||
	            nvl(cnl_rec.logical_operator,' ');
       END IF;
   END IF;
   END LOOP;
   CLOSE cnl_cur;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_SQL.close_cursor(l_cursor);
      -- if the string is not valid then set the flag to N
      l_valid_flag := 'N';
      x_valid_flag := l_valid_flag;
END valid_condition_lines;

END okc_conditions_pvt;

/
