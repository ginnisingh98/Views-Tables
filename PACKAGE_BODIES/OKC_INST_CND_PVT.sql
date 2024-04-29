--------------------------------------------------------
--  DDL for Package Body OKC_INST_CND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_INST_CND_PVT" AS
/* $Header: OKCRINCB.pls 120.0 2005/05/25 19:36:52 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  ***************************************/
  ----------------------------------------------------------------------------
  -- PROCEDURE inst_condition
  ----------------------------------------------------------------------------
  PROCEDURE inst_condition(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_instcnd_inp_rec              IN instcnd_inp_rec) IS

    l_api_name             CONSTANT VARCHAR2(30) := 'inst_condition';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_return_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_msg_data             VARCHAR2(1000) ;
    l_msg_count            NUMBER;
    l_cnhv_rec             OKC_CONDITIONS_PUB.CNHV_REC_TYPE;
    x_cnhv_rec             OKC_CONDITIONS_PUB.CNHV_REC_TYPE;
    l_cnlv_rec             OKC_CONDITIONS_PUB.CNLV_REC_TYPE;
    x_cnlv_rec             OKC_CONDITIONS_PUB.CNLV_REC_TYPE;
    l_fepv_rec             OKC_CONDITIONS_PUB.FEPV_REC_TYPE;
    x_fepv_rec             OKC_CONDITIONS_PUB.FEPV_REC_TYPE;
    l_ocev_rec             OKC_OUTCOME_PUB.OCEV_REC_TYPE;
    x_ocev_rec             OKC_OUTCOME_PUB.OCEV_REC_TYPE;
    l_oatv_rec             OKC_OUTCOME_PUB.OATV_REC_TYPE;
    x_oatv_rec             OKC_OUTCOME_PUB.OATV_REC_TYPE;

-- Cursor to get associated conditions related to that counter group id
    CURSOR ctr_cnh_cur(b_tmp_ctr_grp_id IN NUMBER
				   ,b_inv_item_id IN NUMBER) IS
    SELECT id
    FROM   okc_condition_headers_v
    WHERE  counter_group_id = b_tmp_ctr_grp_id
    AND    object_id        = b_inv_item_id
    AND    jtot_object_code = 'OKX_SYSITEM'
    AND    template_yn      = 'Y';

-- Cursor for Condition Header and related information
    CURSOR cnh_cur(b_cnh_id IN NUMBER) IS SELECT
     acn_id
    ,counter_group_id
    ,description
    ,short_description
    ,comments
    ,one_time_yn
    ,name
    ,condition_valid_yn
    ,before_after
    ,tracked_yn
    ,task_owner_id
    ,cnh_variance
    ,dnz_chr_id
    ,template_yn
    ,date_active
    ,object_id
    ,date_inactive
    ,jtot_object_code
    ,cnh_type
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    FROM okc_condition_headers_v
    WHERE id = b_cnh_id
    AND   template_yn = 'Y';


-- Cursor for Condition Lines and related information
    CURSOR cnl_cur(b_cnh_id IN NUMBER) IS SELECT
	cnl.id cnl_id
    ,cnl.cnh_id
    ,cnl.pdf_id
    ,cnl.aae_id
    ,cnl.left_ctr_master_id
    ,cnl.right_ctr_master_id
    ,cnl.left_counter_id
    ,cnl.right_counter_id
    ,cnl.dnz_chr_id
    ,cnl.sortseq
    ,cnl.cnl_type
    ,cnl.description
    ,cnl.left_parenthesis
    ,cnl.relational_operator
    ,cnl.right_parenthesis
    ,cnl.logical_operator
    ,cnl.start_at
    ,cnl.tolerance
    ,cnl.right_operand
    ,cnl.attribute_category
    ,cnl.attribute1
    ,cnl.attribute2
    ,cnl.attribute3
    ,cnl.attribute4
    ,cnl.attribute5
    ,cnl.attribute6
    ,cnl.attribute7
    ,cnl.attribute8
    ,cnl.attribute9
    ,cnl.attribute10
    ,cnl.attribute11
    ,cnl.attribute12
    ,cnl.attribute13
    ,cnl.attribute14
    ,cnl.attribute15
    FROM okc_condition_headers_v cnh,okc_condition_lines_v cnl
    WHERE cnh.id = cnl.cnh_id
    AND   cnh.id = b_cnh_id;

-- Cursor for Counter Group related information
   CURSOR ctr_grp_cur(b_ctr_grp_id IN NUMBER) IS SELECT
   counter_group_id
   FROM okx_counter_groups_v
   WHERE template_flag = 'N'
   AND   created_from_ctr_grp_tmpl_id = b_ctr_grp_id;

-- Cursor for Counter Template related information
   CURSOR ctr_cur(b_ctr_grp_id IN NUMBER) IS SELECT
   counter_id
   FROM okx_counters_v
   WHERE counter_group_id = b_ctr_grp_id
   AND   created_from_counter_tmpl_id IS NULL
   AND   source_counter_id IS NULL;

-- Cursor for Counter Instance related information
   CURSOR ctr_ins_cur(b_ctr_grp_id IN NUMBER,b_ctr_id IN NUMBER) IS SELECT
   counter_id
   FROM okx_counters_v
   WHERE counter_group_id = b_ctr_grp_id
   AND created_from_counter_tmpl_id = b_ctr_id;

-- Cursor for Function Expression Parameters and related information

    CURSOR fep_cur(b_cnh_id IN NUMBER) IS SELECT
	fep.id fep_id
    ,fep.cnl_id
    ,fep.pdp_id
    ,fep.aae_id
    ,fep.dnz_chr_id
    ,fep.value
    FROM okc_function_expr_params_v fep,okc_condition_headers_v cnh,
	    okc_condition_lines_v  cnl
    WHERE fep.cnl_id = cnl.id
    AND   cnl.cnh_id = cnh.id
    AND   cnh.id     = b_cnh_id;

-- Cursor for Outcomes and related information
    CURSOR oce_cur(b_cnh_id IN NUMBER) IS SELECT
	oce.id oce_id
    ,oce.pdf_id
    ,oce.cnh_id
    ,oce.dnz_chr_id
    ,oce.enabled_yn
    ,oce.comments
    ,oce.success_resource_id
    ,oce.failure_resource_id
    ,oce.attribute_category
    ,oce.attribute1
    ,oce.attribute2
    ,oce.attribute3
    ,oce.attribute4
    ,oce.attribute5
    ,oce.attribute6
    ,oce.attribute7
    ,oce.attribute8
    ,oce.attribute9
    ,oce.attribute10
    ,oce.attribute11
    ,oce.attribute12
    ,oce.attribute13
    ,oce.attribute14
    ,oce.attribute15
    FROM okc_outcomes_v oce,okc_condition_headers_v cnh
    WHERE oce.cnh_id = cnh.id
    AND   cnh.id = b_cnh_id;

-- Cursor for Outcome parameters and related information
    CURSOR oat_cur(b_cnh_id IN NUMBER) IS SELECT
	oat.id oat_id
    ,oat.pdp_id
    ,oat.oce_id
    ,oat.aae_id
    ,oat.dnz_chr_id
    ,oat.value
    FROM okc_outcome_arguments_v oat,okc_outcomes_v oce,
	    okc_condition_headers_v cnh
    WHERE oat.oce_id = oce.id
    AND   oce.cnh_id = cnh.id
    AND   cnh.id     = b_cnh_id;

    BEGIN

    -- call start_activity to create savepoint, check comptability
    -- and initialize message list
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PROCESS'
                                                ,x_return_status
                                                );
    -- check if activity started successfully
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
    -- Put Functionality here regarding the gathering of extra information
    -- related to the condition

    -- Create Condition Header Instance

       FOR ctr_cnh_cur_rec IN ctr_cnh_cur(p_instcnd_inp_rec.tmp_ctr_grp_id,p_instcnd_inp_rec.inv_item_id)LOOP
	  SELECT
	   id
       ,acn_id
       ,counter_group_id
       ,description
       ,short_description
       ,comments
       ,one_time_yn
       ,name
       ,condition_valid_yn
       ,before_after
       ,tracked_yn
       ,task_owner_id
       ,cnh_variance
       ,dnz_chr_id
       ,date_active
	  ,object_id
       ,date_inactive
       ,template_yn
       ,jtot_object_code
       ,cnh_type
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
	  INTO
	   l_cnhv_rec.id
	  ,l_cnhv_rec.acn_id
       ,l_cnhv_rec.counter_group_id
       ,l_cnhv_rec.description
       ,l_cnhv_rec.short_description
       ,l_cnhv_rec.comments
       ,l_cnhv_rec.one_time_yn
       ,l_cnhv_rec.name
       ,l_cnhv_rec.condition_valid_yn
       ,l_cnhv_rec.before_after
       ,l_cnhv_rec.tracked_yn
       ,l_cnhv_rec.task_owner_id
       ,l_cnhv_rec.cnh_variance
       ,l_cnhv_rec.dnz_chr_id
       ,l_cnhv_rec.date_active
       ,l_cnhv_rec.object_id
       ,l_cnhv_rec.date_inactive
       ,l_cnhv_rec.template_yn
       ,l_cnhv_rec.jtot_object_code
       ,l_cnhv_rec.cnh_type
       ,l_cnhv_rec.attribute_category
       ,l_cnhv_rec.attribute1
       ,l_cnhv_rec.attribute2
       ,l_cnhv_rec.attribute3
       ,l_cnhv_rec.attribute4
       ,l_cnhv_rec.attribute5
       ,l_cnhv_rec.attribute6
       ,l_cnhv_rec.attribute7
       ,l_cnhv_rec.attribute8
       ,l_cnhv_rec.attribute9
       ,l_cnhv_rec.attribute10
       ,l_cnhv_rec.attribute11
       ,l_cnhv_rec.attribute12
       ,l_cnhv_rec.attribute13
       ,l_cnhv_rec.attribute14
       ,l_cnhv_rec.attribute15
       FROM okc_condition_headers_v
       WHERE id = ctr_cnh_cur_rec.id
	  AND   template_yn = 'Y';

	  l_cnhv_rec.counter_group_id := p_instcnd_inp_rec.ins_ctr_grp_id;
	  l_cnhv_rec.object_id  := p_instcnd_inp_rec.cle_id;
	  l_cnhv_rec.jtot_object_code  := p_instcnd_inp_rec.jtot_object_code;
	  l_cnhv_rec.dnz_chr_id := p_instcnd_inp_rec.chr_id;
	  l_cnhv_rec.template_yn := 'N';

	  OKC_CONDITIONS_PUB.create_cond_hdrs(
	  p_api_version      => 1.0,
	  p_init_msg_list    => 'T',
	  x_return_status    => x_return_status,
	  x_msg_count        => x_msg_count,
	  x_msg_data         => x_msg_data,
	  p_cnhv_rec         => l_cnhv_rec,
	  x_cnhv_rec         => x_cnhv_rec);

	  FOR cnl_cur_rec in cnl_cur(ctr_cnh_cur_rec.id) LOOP

	  l_cnlv_rec.cnh_id              := x_cnhv_rec.id;
       l_cnlv_rec.pdf_id              := cnl_cur_rec.pdf_id;
       l_cnlv_rec.aae_id              := cnl_cur_rec.aae_id;
       l_cnlv_rec.left_ctr_master_id  := cnl_cur_rec.left_ctr_master_id;
       l_cnlv_rec.right_ctr_master_id := cnl_cur_rec.right_ctr_master_id;
       l_cnlv_rec.left_counter_id     := cnl_cur_rec.left_counter_id;
       l_cnlv_rec.right_counter_id    := cnl_cur_rec.right_counter_id;
       l_cnlv_rec.dnz_chr_id          := cnl_cur_rec.dnz_chr_id;
       l_cnlv_rec.sortseq             := cnl_cur_rec.sortseq;
       l_cnlv_rec.cnl_type            := cnl_cur_rec.cnl_type;
       l_cnlv_rec.description         := cnl_cur_rec.description;
       l_cnlv_rec.left_parenthesis    := cnl_cur_rec.left_parenthesis;
       l_cnlv_rec.right_parenthesis   := cnl_cur_rec.right_parenthesis;
       l_cnlv_rec.logical_operator    := cnl_cur_rec.logical_operator;
       l_cnlv_rec.relational_operator := cnl_cur_rec.relational_operator;
       l_cnlv_rec.start_at            := cnl_cur_rec.start_at;
       l_cnlv_rec.tolerance           := cnl_cur_rec.tolerance;
       l_cnlv_rec.right_operand       := cnl_cur_rec.right_operand;
       l_cnlv_rec.attribute_category  := cnl_cur_rec.attribute_category;
       l_cnlv_rec.attribute1          := cnl_cur_rec.attribute1;
       l_cnlv_rec.attribute2          := cnl_cur_rec.attribute2;
       l_cnlv_rec.attribute3          := cnl_cur_rec.attribute3;
       l_cnlv_rec.attribute4          := cnl_cur_rec.attribute4;
       l_cnlv_rec.attribute5          := cnl_cur_rec.attribute5;
       l_cnlv_rec.attribute6          := cnl_cur_rec.attribute6;
       l_cnlv_rec.attribute7          := cnl_cur_rec.attribute7;
       l_cnlv_rec.attribute8          := cnl_cur_rec.attribute8;
       l_cnlv_rec.attribute9          := cnl_cur_rec.attribute9;
       l_cnlv_rec.attribute10         := cnl_cur_rec.attribute10;
       l_cnlv_rec.attribute11         := cnl_cur_rec.attribute11;
       l_cnlv_rec.attribute12         := cnl_cur_rec.attribute12;
       l_cnlv_rec.attribute13         := cnl_cur_rec.attribute13;
       l_cnlv_rec.attribute14         := cnl_cur_rec.attribute14;
       l_cnlv_rec.attribute15         := cnl_cur_rec.attribute15;

	  IF cnl_cur_rec.cnl_type = 'CEX'
	  THEN
	    IF cnl_cur_rec.left_ctr_master_id IS NOT NULL THEN
		  SELECT counter_id INTO l_cnlv_rec.left_counter_id
            FROM okx_counters_v
            WHERE counter_group_id = p_instcnd_inp_rec.ins_ctr_grp_id
            AND created_from_counter_tmpl_id = cnl_cur_rec.left_ctr_master_id;
         END IF;
	    IF cnl_cur_rec.right_ctr_master_id IS NOT NULL THEN
		  SELECT counter_id INTO l_cnlv_rec.right_counter_id
            FROM okx_counters_v
            WHERE counter_group_id = p_instcnd_inp_rec.ins_ctr_grp_id
            AND created_from_counter_tmpl_id = cnl_cur_rec.right_ctr_master_id;
         END IF;
	    IF cnl_cur_rec.left_counter_id IS NOT NULL THEN
		  SELECT counter_id INTO l_cnlv_rec.left_counter_id
            FROM okx_counters_v
            WHERE counter_group_id = p_instcnd_inp_rec.ins_ctr_grp_id
            AND created_from_counter_tmpl_id = cnl_cur_rec.left_counter_id;
         END IF;
	    IF cnl_cur_rec.right_counter_id IS NOT NULL THEN
		  SELECT counter_id INTO l_cnlv_rec.right_counter_id
            FROM okx_counters_v
            WHERE counter_group_id = p_instcnd_inp_rec.ins_ctr_grp_id
            AND created_from_counter_tmpl_id = cnl_cur_rec.right_counter_id;
         END IF;
       END IF;

	  l_cnlv_rec.dnz_chr_id := p_instcnd_inp_rec.chr_id;

	  OKC_CONDITIONS_PUB.create_cond_lines(
	  p_api_version      => 1.0,
	  p_init_msg_list    => 'T',
	  x_return_status    => x_return_status,
	  x_msg_count        => x_msg_count,
	  x_msg_data         => x_msg_data,
	  p_cnlv_rec         => l_cnlv_rec,
	  x_cnlv_rec         => x_cnlv_rec);

	  FOR fep_cur_rec in fep_cur(ctr_cnh_cur_rec.id) LOOP
       l_fepv_rec.cnl_id              := x_cnlv_rec.id;
       l_fepv_rec.pdp_id              := fep_cur_rec.pdp_id;
       l_fepv_rec.aae_id              := fep_cur_rec.aae_id;
       l_fepv_rec.dnz_chr_id          := fep_cur_rec.dnz_chr_id;
       l_fepv_rec.value               := fep_cur_rec.value;

	  l_fepv_rec.dnz_chr_id := p_instcnd_inp_rec.chr_id;

	  OKC_CONDITIONS_PUB.create_func_exprs(
	  p_api_version      => 1.0,
	  p_init_msg_list    => 'T',
	  x_return_status    => x_return_status,
	  x_msg_count        => x_msg_count,
	  x_msg_data         => x_msg_data,
	  p_fepv_rec         => l_fepv_rec,
	  x_fepv_rec         => x_fepv_rec);

	  END LOOP;

	  END LOOP;

	  FOR oce_cur_rec in oce_cur(ctr_cnh_cur_rec.id) LOOP
       l_ocev_rec.pdf_id              := oce_cur_rec.pdf_id;
       l_ocev_rec.cnh_id              := x_cnhv_rec.id;
       l_ocev_rec.dnz_chr_id          := oce_cur_rec.dnz_chr_id;
       l_ocev_rec.enabled_yn          := oce_cur_rec.enabled_yn;
       l_ocev_rec.comments            := oce_cur_rec.comments;
       l_ocev_rec.success_resource_id := oce_cur_rec.success_resource_id;
       l_ocev_rec.failure_resource_id := oce_cur_rec.failure_resource_id;
       l_ocev_rec.attribute_category  := oce_cur_rec.attribute_category;
       l_ocev_rec.attribute1          := oce_cur_rec.attribute1;
       l_ocev_rec.attribute2          := oce_cur_rec.attribute2;
       l_ocev_rec.attribute3          := oce_cur_rec.attribute3;
       l_ocev_rec.attribute4          := oce_cur_rec.attribute4;
       l_ocev_rec.attribute5          := oce_cur_rec.attribute5;
       l_ocev_rec.attribute6          := oce_cur_rec.attribute6;
       l_ocev_rec.attribute7          := oce_cur_rec.attribute7;
       l_ocev_rec.attribute8          := oce_cur_rec.attribute8;
       l_ocev_rec.attribute9          := oce_cur_rec.attribute9;
       l_ocev_rec.attribute10         := oce_cur_rec.attribute10;
       l_ocev_rec.attribute11         := oce_cur_rec.attribute11;
       l_ocev_rec.attribute12         := oce_cur_rec.attribute12;
       l_ocev_rec.attribute13         := oce_cur_rec.attribute13;
       l_ocev_rec.attribute14         := oce_cur_rec.attribute14;
       l_ocev_rec.attribute15         := oce_cur_rec.attribute15;

	  l_ocev_rec.dnz_chr_id := p_instcnd_inp_rec.chr_id;

	  OKC_OUTCOME_PUB.create_outcome(
	  p_api_version      => 1.0,
	  p_init_msg_list    => 'T',
	  x_return_status    => x_return_status,
	  x_msg_count        => x_msg_count,
	  x_msg_data         => x_msg_data,
	  p_ocev_rec         => l_ocev_rec,
	  x_ocev_rec         => x_ocev_rec);

	  FOR oat_cur_rec in oat_cur(ctr_cnh_cur_rec.id) LOOP
       l_oatv_rec.pdp_id              := oat_cur_rec.pdp_id;
       l_oatv_rec.oce_id              := x_ocev_rec.id;
       l_oatv_rec.aae_id              := oat_cur_rec.aae_id;
       l_oatv_rec.dnz_chr_id          := oat_cur_rec.dnz_chr_id;
       l_oatv_rec.value               := oat_cur_rec.value;

	  l_oatv_rec.dnz_chr_id := p_instcnd_inp_rec.chr_id;

	  OKC_OUTCOME_PUB.create_out_arg(
	  p_api_version      => 1.0,
	  p_init_msg_list    => 'T',
	  x_return_status    => x_return_status,
	  x_msg_count        => x_msg_count,
	  x_msg_data         => x_msg_data,
	  p_oatv_rec         => l_oatv_rec,
	  x_oatv_rec         => x_oatv_rec);

	  END LOOP;

	  END LOOP;

	  END LOOP;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
	  WHEN NO_DATA_FOUND THEN
       NULL;
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PROCESS');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PROCESS');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PROCESS');

END INST_CONDITION;

END OKC_INST_CND_PVT;

/
