--------------------------------------------------------
--  DDL for Package Body OKC_RULE_DEF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RULE_DEF_PVT" AS
/* $Header: OKCCRGDB.pls 120.0 2005/05/25 22:48:18 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_EXCEPTION_CANNOT_DELETE    EXCEPTION;
  G_CANNOT_DELETE_MASTER       CONSTANT VARCHAR2(200) := 'OKC_CANNOT_DELETE_MASTER';
  G_CANNOT_DELETE_RULE_DEF     CONSTANT VARCHAR2(200) := 'OKC_CANNOT_DELETE_RULE_DEF';

  --------------------------------------
  --PROCEDURE create_rg_def_rule
  --------------------------------------
  PROCEDURE create_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type,
     x_rgrv_rec                     OUT NOCOPY rgrv_rec_type) IS
  BEGIN
     OKC_RGR_PVT.insert_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rgrv_rec,
                         x_rgrv_rec);
  END create_rg_def_rule;

  --------------------------------------
  --PROCEDURE update_rg_def_rule
  --------------------------------------
  PROCEDURE update_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type,
     x_rgrv_rec                     OUT NOCOPY rgrv_rec_type) IS
  BEGIN
     OKC_RGR_PVT.update_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rgrv_rec,
                         x_rgrv_rec);
  END update_rg_def_rule;

  --------------------------------------
  --PROCEDURE delete_rg_def_rule
  --------------------------------------
  PROCEDURE delete_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type) IS

    l_dummy_var VARCHAR(1) := NULL;
-- The following cursor was modified  by MSENGUPT on 12/09/2001 to include rownum and FIRST_ROWS hint for perf.
    CURSOR l_rul_csr IS
      SELECT /*+ FIRST_ROWS */
         'x'
        FROM OKC_RULES_B rul,
             OKC_RULE_GROUPS_B rgp
       WHERE rul.rule_information_category = p_rgrv_rec.rdf_code
         AND rul.rgp_id                    = rgp.id
         AND rgp.rgd_code                  = p_rgrv_rec.rgd_code
         AND rownum < 2;

  BEGIN
    -- check whether rule records exists
     OPEN l_rul_csr;
    FETCH l_rul_csr into l_dummy_var;
    CLOSE l_rul_csr;
    IF l_dummy_var = 'x' THEN
      RAISE G_EXCEPTION_CANNOT_DELETE;
    END IF;

    OKC_RGR_PVT.delete_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rgrv_rec);
  EXCEPTION
  WHEN G_EXCEPTION_CANNOT_DELETE THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_CANNOT_DELETE_RULE_DEF);
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_rul_csr%ISOPEN THEN
      CLOSE l_rul_csr;
    END IF;
  END delete_rg_def_rule;

  --------------------------------------
  --PROCEDURE validate_rg_def_rule
  --------------------------------------
  PROCEDURE validate_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type) IS
  BEGIN
     OKC_RGR_PVT.validate_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rgrv_rec);
  END validate_rg_def_rule;

  --------------------------------------
  --PROCEDURE lock_rg_def_rule
  --------------------------------------
  PROCEDURE lock_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type) IS
  BEGIN
     OKC_RGR_PVT.lock_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rgrv_rec);
  END lock_rg_def_rule;

  --------------------------------------
  --PROCEDURE create_rd_source
  --------------------------------------
  PROCEDURE create_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type,
     x_rdsv_rec                     OUT NOCOPY rdsv_rec_type) IS
  BEGIN
     OKC_RDS_PVT.insert_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rdsv_rec,
                         x_rdsv_rec);
  END create_rd_source;

  --------------------------------------
  --PROCEDURE update_rd_source
  --------------------------------------
  PROCEDURE update_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type,
     x_rdsv_rec                     OUT NOCOPY rdsv_rec_type) IS
  BEGIN
     OKC_RDS_PVT.update_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rdsv_rec,
                         x_rdsv_rec);
  END update_rd_source;

  --------------------------------------
  --PROCEDURE delete_rd_source
  --------------------------------------
  PROCEDURE delete_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type) IS
  BEGIN
     OKC_RDS_PVT.delete_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rdsv_rec);
  END delete_rd_source;

  --------------------------------------
  --PROCEDURE validate_rd_source
  --------------------------------------
  PROCEDURE validate_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type) IS
  BEGIN
     OKC_RDS_PVT.validate_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rdsv_rec);
  END validate_rd_source;

  --------------------------------------
  --PROCEDURE lock_rd_source
  --------------------------------------
  PROCEDURE lock_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type) IS
  BEGIN
     OKC_RDS_PVT.lock_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_rdsv_rec);
  END lock_rd_source;

END okc_rule_def_pvt;

/
