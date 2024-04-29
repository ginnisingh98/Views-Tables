--------------------------------------------------------
--  DDL for Package Body OKC_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PROCESS_PVT" as
/* $Header: OKCCPDFB.pls 120.0 2005/05/26 09:55:34 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE add_language IS
Begin
	okc_pdf_pvt.add_language;
	okc_pdp_pvt.add_language;
End;

--Object type procedure for insert
PROCEDURE create_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type,
    x_pdfv_rec              OUT NOCOPY pdfv_rec_type,
    x_pdpv_tbl              OUT NOCOPY pdpv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdfv_rec              pdfv_rec_type;
    l_pdpv_tbl              pdpv_tbl_type := p_pdpv_tbl;
    i			    NUMBER;
begin
    --Populate the Master
    create_proc_def(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_pdfv_rec,
    	x_pdfv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    -- Populate the foreign key for the detail
    IF (l_pdpv_tbl.COUNT > 0) THEN
       i := l_pdpv_tbl.FIRST;
       LOOP
          l_pdpv_tbl(i).pdf_id := x_pdfv_rec.id;
          EXIT WHEN (i = l_pdpv_tbl.LAST);
          i := l_pdpv_tbl.NEXT(i);
       END LOOP;
    END IF;

    --Populate the detail
    create_proc_def_parms(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
   	x_msg_count,
    	x_msg_data,
    	l_pdpv_tbl,
    	x_pdpv_tbl);
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
End create_process_def;

--Object type procedure for update
PROCEDURE update_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type,
    x_pdfv_rec              OUT NOCOPY pdfv_rec_type,
    x_pdpv_tbl              OUT NOCOPY pdpv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
    --Update the Master
    update_proc_def(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_pdfv_rec,
    	x_pdfv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    --Update the detail
    update_proc_def_parms(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_tbl,
    x_pdpv_tbl);
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
end update_process_def;

--Object type procedure for validate
PROCEDURE validate_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
    --Validate the Master
    validate_proc_def(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    --Validate the Detail
    validate_proc_def_parms(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_tbl);
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
End validate_process_def;

--Procedures for Process Definitions

PROCEDURE create_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    x_pdfv_rec              OUT NOCOPY pdfv_rec_type) IS
begin
    okc_pdf_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_rec,
    x_pdfv_rec);
End create_proc_def;

PROCEDURE create_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_tbl		    IN pdfv_tbl_type,
    x_pdfv_tbl              OUT NOCOPY pdfv_tbl_type) IS
begin
    okc_pdf_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_tbl,
    x_pdfv_tbl);
End create_proc_def;

PROCEDURE lock_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type) IS
begin
    okc_pdf_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_rec);
End lock_proc_def;

PROCEDURE lock_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_tbl		    IN pdfv_tbl_type) IS
begin
    okc_pdf_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_tbl);
End lock_proc_def;

PROCEDURE update_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    x_pdfv_rec              OUT NOCOPY pdfv_rec_type) IS
    l_pdpv_tbl              OKC_PROCESS_PUB.pdpv_tbl_type;
    v_pdpv_tbl              OKC_PROCESS_PUB.pdpv_tbl_type;
    l_api_version           NUMBER := 1;
    l_init_msg_list         VARCHAR2(1) := 'T';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(200);
    l_app_id1               NUMBER;
    l_cnt                   NUMBER := 0;
   CURSOR l_id_cur is
   SELECT *
   FROM okc_process_def_parameters_v
   WHERE pdf_id = p_pdfv_rec.id;
begin
    SELECT application_id INTO l_app_id1
    FROM OKC_PROCESS_DEFS_B
    WHERE id = p_pdfv_rec.id;

    okc_pdf_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_rec,
    x_pdfv_rec);
IF x_return_status = 'S' THEN
  If nvl(p_pdfv_rec.application_id,-99) <> nvl(l_app_id1,-99) THEN
        l_pdpv_tbl.delete;
        v_pdpv_tbl.delete;
        FOR l_pdpv_rec in l_id_cur
        LOOP
         l_cnt := l_cnt + 1;
         l_pdpv_tbl(l_cnt).id := l_pdpv_rec.id;
         l_pdpv_tbl(l_cnt).object_version_number := l_pdpv_rec.object_version_number;
         l_pdpv_tbl(l_cnt).sfwt_flag := l_pdpv_rec.sfwt_flag;
         l_pdpv_tbl(l_cnt).pdf_id := l_pdpv_rec.pdf_id;
         l_pdpv_tbl(l_cnt).name := l_pdpv_rec.name;
         l_pdpv_tbl(l_cnt).data_type := l_pdpv_rec.data_type;
         l_pdpv_tbl(l_cnt).default_value := l_pdpv_rec.default_value;
         l_pdpv_tbl(l_cnt).required_yn := l_pdpv_rec.required_yn;
         l_pdpv_tbl(l_cnt).description := l_pdpv_rec.description;
         l_pdpv_tbl(l_cnt).application_id := p_pdfv_rec.application_id;
         l_pdpv_tbl(l_cnt).seeded_flag := l_pdpv_rec.seeded_flag;
         l_pdpv_tbl(l_cnt).created_by := l_pdpv_rec.created_by;
         l_pdpv_tbl(l_cnt).creation_date := l_pdpv_rec.creation_date;
         l_pdpv_tbl(l_cnt).last_updated_by := l_pdpv_rec.last_updated_by;
         l_pdpv_tbl(l_cnt).last_update_date := l_pdpv_rec.last_update_date;
         l_pdpv_tbl(l_cnt).last_update_login := l_pdpv_rec.last_update_login;
         l_pdpv_tbl(l_cnt).jtot_object_code := l_pdpv_rec.jtot_object_code;
         l_pdpv_tbl(l_cnt).name_column := l_pdpv_rec.name_column;
         l_pdpv_tbl(l_cnt).description_column := l_pdpv_rec.description_column;
      END LOOP;
  okc_process_pub.update_proc_def_parms(
   p_api_version    =>  l_api_version,
   p_init_msg_list  =>  l_init_msg_list,
   x_return_status  =>  l_return_status,
   x_msg_count      =>  l_msg_count,
   x_msg_data       =>  l_msg_data,
   p_pdpv_tbl      =>   l_pdpv_tbl,
   x_pdpv_tbl      =>   v_pdpv_tbl);
 END IF;
END IF;
End update_proc_def;

PROCEDURE update_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_tbl		    IN pdfv_tbl_type,
    x_pdfv_tbl              OUT NOCOPY pdfv_tbl_type) IS
begin
    okc_pdf_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_tbl,
    x_pdfv_tbl);
End update_proc_def;

--Procedure for Cascade Delete
PROCEDURE delete_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;
    c                       NUMBER := 0;
    l_pdpv_tbl              pdpv_tbl_type;
    l_condition		    VARCHAR2(1) := '?';
    l_qa		    VARCHAR2(1) := '?';
    l_process		    VARCHAR2(1) := '?';

    --Fetch all the process definition parameter id's for a specific process definition
    Cursor p_cur is
    select pdp.id
    from okc_process_def_parameters_v pdp
    where pdp.pdf_id = p_pdfv_rec.id;

    --Check if the process definition is used by Conditions
    Cursor check_condition_csr(p_pdf_id IN NUMBER) is
    select '1'
    from okc_process_defs_v pdf,
	okc_outcomes_v out,
	okc_condition_headers_v cnh
    where pdf.id = out.pdf_id
    and pdf.id = p_pdf_id
    and out.cnh_id = cnh.id;

    Cursor check_qa_csr(p_pdf_id IN NUMBER) is
    select '1'
    from okc_process_defs_v pdf,
	okc_qa_list_processes qa
    where pdf.id = qa.pdf_id
    and pdf.id = p_pdf_id;

    Cursor check_k_process_csr(p_pdf_id IN NUMBER) is
    select '1'
    from okc_process_defs_v pdf,
	okc_k_processes k
    where pdf.id = k.pdf_id
    and pdf.id = p_pdf_id;

begin
      OPEN check_condition_csr(p_pdfv_rec.id);
      FETCH check_condition_csr INTO l_condition;
      CLOSE check_condition_csr;

      OPEN check_qa_csr(p_pdfv_rec.id);
      FETCH check_qa_csr INTO l_qa;
      CLOSE check_qa_csr;

      OPEN check_k_process_csr(p_pdfv_rec.id);
      FETCH check_k_process_csr INTO l_process;
      CLOSE check_k_process_csr;

      --Process definition cannot be deleted while being used in conditions
      IF l_condition = '1' OR l_qa = '1' OR l_process = '1' THEN
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                       	    p_msg_name     => g_delete_proc_def);
     		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
     ELSE
      --populate the Foreign key of the detail
      For p_rec in p_cur loop
	i := i + 1;
	l_pdpv_tbl(i).id := p_rec.id;
      End loop;

      --Delete the details
      -- call Public delete procedure
       	okc_process_pub.delete_proc_def_parms(
    			p_api_version,
    			p_init_msg_list,
    			x_return_status,
    			x_msg_count,
    			x_msg_data,
    			l_pdpv_tbl);
        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

	--Delete the Master
        okc_pdf_pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_pdfv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      	raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
        END IF;
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
End delete_proc_def;

PROCEDURE delete_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_tbl		    IN pdfv_tbl_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
      --Initialize the return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_pdfv_tbl.COUNT > 0) THEN
       	  i := p_pdfv_tbl.FIRST;
       LOOP
          delete_proc_def(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_pdfv_tbl(i));
          EXIT WHEN (i = p_pdfv_tbl.LAST);
          i := p_pdfv_tbl.NEXT(i);
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
End delete_proc_def;

PROCEDURE validate_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type) IS
begin
    okc_pdf_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_rec);
End validate_proc_def;

PROCEDURE validate_proc_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_tbl		    IN pdfv_tbl_type) IS
begin
    okc_pdf_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdfv_tbl);
End validate_proc_def;

--Procedures for Process Definition Parameters

PROCEDURE create_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_rec		    IN pdpv_rec_type,
    x_pdpv_rec              OUT NOCOPY pdpv_rec_type) IS
    l_app_id                NUMBER;
    l_pdpv_rec              pdpv_rec_type := p_pdpv_rec;
begin
   SELECT application_id into l_app_id
   FROM OKC_PROCESS_DEFS_B
   WHERE ID = l_pdpv_rec.pdf_id;
   l_pdpv_rec.application_id := l_app_id;
    okc_pdp_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_pdpv_rec,
    x_pdpv_rec);
End create_proc_def_parms;

PROCEDURE create_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_tbl		    IN pdpv_tbl_type,
    x_pdpv_tbl              OUT NOCOPY pdpv_tbl_type) IS
begin
    okc_pdp_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_tbl,
    x_pdpv_tbl);
End create_proc_def_parms;

PROCEDURE lock_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_rec		    IN pdpv_rec_type) IS
begin
    okc_pdp_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_rec);
End lock_proc_def_parms;

PROCEDURE lock_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_tbl		    IN pdpv_tbl_type) IS
begin
    okc_pdp_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_tbl);
End lock_proc_def_parms;

PROCEDURE update_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_rec		    IN pdpv_rec_type,
    x_pdpv_rec              OUT NOCOPY pdpv_rec_type) IS
begin
    okc_pdp_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_rec,
    x_pdpv_rec);
End update_proc_def_parms;

PROCEDURE update_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_tbl		    IN pdpv_tbl_type,
    x_pdpv_tbl              OUT NOCOPY pdpv_tbl_type) IS
begin
    okc_pdp_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_tbl,
    x_pdpv_tbl);
End update_proc_def_parms;

PROCEDURE delete_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_rec		    IN pdpv_rec_type) IS
begin
    okc_pdp_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_rec);
End delete_proc_def_parms;

PROCEDURE delete_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_tbl		    IN pdpv_tbl_type) IS
begin
    okc_pdp_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_tbl);
End delete_proc_def_parms;

PROCEDURE validate_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_rec		    IN pdpv_rec_type) IS
begin
    okc_pdp_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_rec);
End validate_proc_def_parms;

PROCEDURE validate_proc_def_parms(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdpv_tbl		    IN pdpv_tbl_type) IS
begin
    okc_pdp_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_pdpv_tbl);
End validate_proc_def_parms;

/* ===========================================================================
|   PROCEDURE validate_dbnames                                               |
|   INPUT:    process defintion record pdpv_rec_type                         |
|   PROCESS:  validates that either the workflow name and process name       |
|		   (WF_NAME and WF_PROCESS_NAME) exists in the WF_ACTIVITIES_VL)   |
|		   OR package/procedure name exists in ALL_ATTRIBUTES.             |
|   OUTPUT:  error message                                                   |
|               OKC_INVALID_WF_NAME
|               OKC_INVALID_PACK_NAME
|  ===========================================================================
*/

PROCEDURE validate_dbnames(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type) IS

CURSOR wf (wfname  VARCHAR2,  wfproc  VARCHAR2) IS
		SELECT    RUNNABLE_FLAG
		 FROM     wf_activities_vl w
           WHERE    w.item_type = UPPER(wfname)
		   AND    w.name = UPPER(wfproc)
		   AND    w.version = (SELECT max(version)
							FROM wf_activities_vl sq
                                  WHERE sq.item_type = UPPER(wfname)
							 AND sq.name = UPPER(wfproc) );

CURSOR pp (packname  VARCHAR2, procname  VARCHAR2) IS
		SELECT    1
		  FROM    user_arguments a,
				user_objects o
           WHERE    o.object_type = 'PACKAGE'
		   and    o.object_name = UPPER(packname)
		   and    a.object_id = o.object_id
		   AND    a.object_name = UPPER(procname);

     l_pack_count              NUMBER := 0;
	l_run_flag                VARCHAR2(4);

BEGIN
--
--   Setup the successful message
--
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    FND_MESSAGE.SET_NAME(application   => g_app_name,
					name          => g_validate_dbname_success);

    x_msg_count := 0;
    x_msg_data := null;
    l_run_flag := null;
    l_pack_count := 0;

    IF (p_pdfv_rec.wf_name IS NOT NULL) AND (p_pdfv_rec.wf_process_name IS NOT NULL) THEN
	    OPEN wf (p_pdfv_rec.wf_name, p_pdfv_rec.wf_process_name);
	    FETCH wf INTO l_run_flag;
	    IF wf%NOTFOUND THEN
		    CLOSE wf;
		    FND_MESSAGE.SET_NAME(application   => g_app_name,
							name          => g_validate_dbname_notfound);
              FND_MESSAGE.SET_TOKEN(token        => 'DATANAME',
							 value        => g_validate_dbname_wf_pair,
							 translate    => TRUE);
     	    x_return_status := OKC_API.G_RET_STS_ERROR;
         ELSE
	         CLOSE wf;
	         IF l_run_flag <> 'Y' THEN
     	         x_return_status := OKC_API.G_RET_STS_ERROR;
		         FND_MESSAGE.SET_NAME(application   => g_app_name,
			     				name          => g_validate_dbname_notrun);
                   FND_MESSAGE.SET_TOKEN(token        => 'DATANAME',
			     				 value        => g_validate_dbname_wf_pair,
			     				 translate    => TRUE);
              END IF;
         END IF;

    ELSIF (p_pdfv_rec.procedure_name IS NOT NULL) AND (p_pdfv_rec.package_name IS NOT NULL) THEN
	    OPEN pp(p_pdfv_rec.package_name, p_pdfv_rec.procedure_name);
	    FETCH pp INTO l_pack_count;
	    IF pp%NOTFOUND THEN
     	         x_return_status := OKC_API.G_RET_STS_ERROR;
		         FND_MESSAGE.SET_NAME(application   => g_app_name,
			     				name          => g_validate_dbname_notfound);
                   FND_MESSAGE.SET_TOKEN(token        => 'DATANAME',
			     				 value        => g_validate_dbname_pp_pair,
			     				 translate    => TRUE);
         END IF;

	    CLOSE pp;

    END IF;

EXCEPTION
   WHEN OTHERS THEN
	 IF wf%ISOPEN THEN
		CLOSE wf;
      ELSIF pp%ISOPEN THEN
		CLOSE pp;
      END IF;

      FND_MESSAGE.SET_NAME(application   => g_app_name,
                           name          => g_unexpected_error);
      FND_MESSAGE.SET_TOKEN(token        => g_sqlcode_token,
                           value        => sqlcode);
      FND_MESSAGE.SET_TOKEN(token        => g_sqlerrm_token,
                           value        => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END  validate_dbnames;




END okc_process_pvt;

/
