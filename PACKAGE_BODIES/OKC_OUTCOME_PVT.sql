--------------------------------------------------------
--  DDL for Package Body OKC_OUTCOME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OUTCOME_PVT" as
/* $Header: OKCCOCEB.pls 120.0 2005/05/25 19:28:25 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE add_language IS
Begin
	okc_oce_pvt.add_language;
End;

--Object type procedure for insert
PROCEDURE create_outcomes_args(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type,
    p_oatv_tbl              IN oatv_tbl_type,
    x_ocev_rec              OUT NOCOPY ocev_rec_type,
    x_oatv_tbl              OUT NOCOPY oatv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ocev_rec              ocev_rec_type;
    l_oatv_tbl              oatv_tbl_type := p_oatv_tbl;
    i			    NUMBER;
begin
    --Populate the Master
    create_outcome(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_ocev_rec,
    	x_ocev_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    -- Populate the foreign key for the detail
    IF (l_oatv_tbl.COUNT > 0) THEN
       i := l_oatv_tbl.FIRST;
       LOOP
          l_oatv_tbl(i).oce_id := x_ocev_rec.id;
          EXIT WHEN (i = l_oatv_tbl.LAST);
          i := l_oatv_tbl.NEXT(i);
       END LOOP;
    END IF;

    --Populate the detail
    create_out_arg(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
   	x_msg_count,
    	x_msg_data,
    	l_oatv_tbl,
    	x_oatv_tbl);
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
End create_outcomes_args;

--Object type procedure for update
PROCEDURE update_outcomes_args(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type,
    p_oatv_tbl              IN oatv_tbl_type,
    x_ocev_rec              OUT NOCOPY ocev_rec_type,
    x_oatv_tbl              OUT NOCOPY oatv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
    --Update the Master
    update_outcome(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_ocev_rec,
    	x_ocev_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    --Update the detail
    update_out_arg(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_tbl,
    x_oatv_tbl);
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
end update_outcomes_args;

--Object type procedure for validate
PROCEDURE validate_outcomes_args(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type,
    p_oatv_tbl              IN oatv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
    --Validate the Master
    validate_outcome(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    --Validate the Detail
    validate_out_arg(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_tbl);
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
End validate_outcomes_args;

--Procedure to update minor version number

 Procedure  Update_Minor_Version(p_chr_id NUMBER) Is
     l_api_version                NUMBER := 1;
     l_init_msg_list              VARCHAR2(1) := 'F';
     x_return_status              VARCHAR2(1);
     x_msg_count                  NUMBER;
     x_msg_data                   VARCHAR2(2000);
     x_out_rec                    OKC_CVM_PVT.cvmv_rec_type;
     l_cvmv_rec                   OKC_CVM_PVT.cvmv_rec_type;
	 l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 Begin
    -- assign/populate contract header id
     l_cvmv_rec.chr_id := p_chr_id;

     OKC_CVM_PVT.update_contract_version(
          p_api_version     => l_api_version,
          p_init_msg_list   => l_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cvmv_rec        => l_cvmv_rec,
          x_cvmv_rec        => x_out_rec);
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
 End update_minor_version;

--Procedures for Outcomes

PROCEDURE create_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type,
    x_ocev_rec              OUT NOCOPY ocev_rec_type) IS
begin
    okc_oce_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_rec,
    x_ocev_rec);

    --Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
    	update_minor_version(p_ocev_rec.dnz_chr_id);
    End if;
End create_outcome;

PROCEDURE create_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_tbl		    IN ocev_tbl_type,
    x_ocev_tbl              OUT NOCOPY ocev_tbl_type) IS
begin
    okc_oce_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_tbl,
    x_ocev_tbl);
End create_outcome;

PROCEDURE lock_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type) IS
begin
    okc_oce_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_rec);
End lock_outcome;

PROCEDURE lock_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_tbl		    IN ocev_tbl_type) IS
begin
    okc_oce_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_tbl);
End lock_outcome;

PROCEDURE update_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type,
    x_ocev_rec              OUT NOCOPY ocev_rec_type) IS
begin
    okc_oce_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_rec,
    x_ocev_rec);
    --Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
    	update_minor_version(p_ocev_rec.dnz_chr_id);
    End if;
End update_outcome;

PROCEDURE update_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_tbl		    IN ocev_tbl_type,
    x_ocev_tbl              OUT NOCOPY ocev_tbl_type) IS
begin
    okc_oce_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_tbl,
    x_ocev_tbl);
End update_outcome;

--Procedure for Cascade Delete
PROCEDURE delete_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;
    l_oatv_tbl              oatv_tbl_type;

    Cursor p_cur is
    select oat.id
    from okc_outcome_arguments_v oat
    where oat.oce_id = p_ocev_rec.id;
begin
      --populate the Foreign key of the detail
      For p_rec in p_cur loop
	i := i + 1;
	l_oatv_tbl(i).id := p_rec.id;
      End loop;

      --Delete the details
      -- call Public delete procedure
       		okc_outcome_pub.delete_out_arg(
    			p_api_version,
    			p_init_msg_list,
    			x_return_status,
    			x_msg_count,
    			x_msg_data,
    			l_oatv_tbl);
       	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

	--Delete the Master
    	okc_oce_pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_ocev_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      	raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
  	   --Update minor version
    	   update_minor_version(p_ocev_rec.dnz_chr_id);
    	End if;
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
End delete_outcome;

PROCEDURE delete_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_tbl		    IN ocev_tbl_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
      --Initialize the return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_ocev_tbl.COUNT > 0) THEN
       	  i := p_ocev_tbl.FIRST;
       LOOP
          delete_outcome(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_ocev_tbl(i));
          EXIT WHEN (i = p_ocev_tbl.LAST);
          i := p_ocev_tbl.NEXT(i);
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
End delete_outcome;

PROCEDURE validate_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type) IS
begin
    okc_oce_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_rec);
End validate_outcome;

PROCEDURE validate_outcome(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_tbl		    IN ocev_tbl_type) IS
begin
    okc_oce_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_ocev_tbl);
End validate_outcome;

--Procedures for Outcome arguments

PROCEDURE create_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_rec		    IN oatv_rec_type,
    x_oatv_rec              OUT NOCOPY oatv_rec_type) IS
begin
    okc_oat_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_rec,
    x_oatv_rec);
    --Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
    	update_minor_version(p_oatv_rec.dnz_chr_id);
    End if;
End create_out_arg;

PROCEDURE create_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_tbl		    IN oatv_tbl_type,
    x_oatv_tbl              OUT NOCOPY oatv_tbl_type) IS
begin
    okc_oat_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_tbl,
    x_oatv_tbl);
End create_out_arg;

PROCEDURE lock_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_rec		    IN oatv_rec_type) IS
begin
    okc_oat_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_rec);
End lock_out_arg;

PROCEDURE lock_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_tbl		    IN oatv_tbl_type) IS
begin
    okc_oat_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_tbl);
End lock_out_arg;

PROCEDURE update_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_rec		    IN oatv_rec_type,
    x_oatv_rec              OUT NOCOPY oatv_rec_type) IS
begin
    okc_oat_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_rec,
    x_oatv_rec);
    --Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
    	update_minor_version(p_oatv_rec.dnz_chr_id);
    End if;
End update_out_arg;

PROCEDURE update_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_tbl		    IN oatv_tbl_type,
    x_oatv_tbl              OUT NOCOPY oatv_tbl_type) IS
begin
    okc_oat_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_tbl,
    x_oatv_tbl);
End update_out_arg;

PROCEDURE delete_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_rec		    IN oatv_rec_type) IS
begin
    okc_oat_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_rec);
    --Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
    	update_minor_version(p_oatv_rec.dnz_chr_id);
    End if;
End delete_out_arg;

PROCEDURE delete_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_tbl		    IN oatv_tbl_type) IS
begin
    okc_oat_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_tbl);
End delete_out_arg;

PROCEDURE validate_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_rec		    IN oatv_rec_type) IS
begin
    okc_oat_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_rec);
End validate_out_arg;

PROCEDURE validate_out_arg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_oatv_tbl		    IN oatv_tbl_type) IS
begin
    okc_oat_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_oatv_tbl);
End validate_out_arg;

END okc_outcome_pvt;

/
