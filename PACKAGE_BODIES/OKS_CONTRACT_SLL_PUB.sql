--------------------------------------------------------
--  DDL for Package Body OKS_CONTRACT_SLL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CONTRACT_SLL_PUB" AS
/* $Header: OKSPSLLB.pls 120.0 2005/05/25 18:31:51 appldev noship $ */
  PROCEDURE create_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type,
    x_sllv_rec                     OUT NOCOPY sllv_rec_type,
    p_validate_yn                  IN VARCHAR2) IS

    l_init_msg_list   VARCHAR2(10);
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_sll
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => l_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_rec       => p_sllv_rec
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_sll_pvt.insert_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_rec       => p_sllv_rec,
             x_sllv_rec       => x_sllv_rec
           );
    END IF;
  END create_sll;

  PROCEDURE create_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_sll
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl,
             px_error_tbl     => px_error_tbl
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_sll_pvt.insert_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl,
             x_sllv_tbl       => x_sllv_tbl,
             px_error_tbl     => px_error_tbl
           );
    END IF;
  END create_sll;

  PROCEDURE create_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_sll
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_sll_pvt.insert_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl,
             x_sllv_tbl       => x_sllv_tbl
           );
    END IF;
  END create_sll;

  PROCEDURE update_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type,
    x_sllv_rec                     OUT NOCOPY sllv_rec_type,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_sll
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_rec       => p_sllv_rec
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_sll_pvt.update_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_rec       => p_sllv_rec,
             x_sllv_rec       => x_sllv_rec
           );
    END IF;
  END update_sll;

  PROCEDURE update_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_sll
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl,
             px_error_tbl     => px_error_tbl
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_sll_pvt.update_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl,
             x_sllv_tbl       => x_sllv_tbl,
             px_error_tbl     => px_error_tbl
           );
    END IF;
  END update_sll;

  PROCEDURE update_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    p_validate_yn                  IN VARCHAR2) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF p_validate_yn = 'Y' THEN
      validate_sll
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl
           );
    END IF;
    IF x_return_status = G_RET_STS_SUCCESS THEN
      oks_sll_pvt.update_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl,
             x_sllv_tbl       => x_sllv_tbl
           );
    END IF;
  END update_sll;

  PROCEDURE lock_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type) IS
  BEGIN
    oks_sll_pvt.lock_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_rec       => p_sllv_rec
           );
  END lock_sll;

  PROCEDURE lock_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
  BEGIN
    oks_sll_pvt.lock_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl,
             px_error_tbl     => px_error_tbl
           );
  END lock_sll;

  PROCEDURE lock_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type) IS
  BEGIN
    oks_sll_pvt.lock_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl
           );
  END lock_sll;

  PROCEDURE delete_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type) IS
  BEGIN
    oks_sll_pvt.delete_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_rec       => p_sllv_rec
           );
  END delete_sll;

  PROCEDURE delete_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
  BEGIN
    oks_sll_pvt.delete_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl,
             px_error_tbl     => px_error_tbl
           );
  END delete_sll;

  PROCEDURE delete_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type) IS
  BEGIN
    oks_sll_pvt.delete_row
           (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_sllv_tbl       => p_sllv_tbl
           );
  END delete_sll;

  PROCEDURE validate_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
  END validate_sll;

  PROCEDURE validate_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
  END validate_sll;

  PROCEDURE validate_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type) IS
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
  END validate_sll;

PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,
                         p_sllv_tbl   IN sllv_tbl_type) IS

      l_tabsize NUMBER := p_sllv_tbl.COUNT;
      in_id                 OKC_DATATYPES.NumberTabTyp;
      in_chr_id             OKC_DATATYPES.NumberTabTyp;
      in_cle_id             OKC_DATATYPES.NumberTabTyp;
      in_dnz_chr_id         OKC_DATATYPES.NumberTabTyp;
      in_sequence_no        OKC_DATATYPES.NumberTabTyp;
      in_uom_code           OKC_DATATYPES.Var3TabTyp;
      in_start_date         OKC_DATATYPES.DateTabTyp;
      in_end_date           OKC_DATATYPES.DateTabTyp;
      in_level_periods      OKC_DATATYPES.NumberTabTyp;
      in_uom_per_period     OKC_DATATYPES.NumberTabTyp;
      in_advance_periods    OKC_DATATYPES.NumberTabTyp;
      in_level_amount       OKC_DATATYPES.NumberTabTyp;
      in_invoice_offset_days    OKC_DATATYPES.NumberTabTyp;
      in_interface_offset_days  OKC_DATATYPES.NumberTabTyp;
      in_comments               OKC_DATATYPES.Var1995TabTyp;
      in_due_arr_yn             OKC_DATATYPES.Var3TabTyp;
      in_amount                 OKC_DATATYPES.NumberTabTyp;
      in_lines_detailed_yn      OKC_DATATYPES.Var3TabTyp;
      in_object_version_number  OKC_DATATYPES.NumberTabTyp;
      in_request_id             OKC_DATATYPES.NumberTabTyp;
      in_created_by             OKC_DATATYPES.Number15TabTyp;
      in_creation_date          OKC_DATATYPES.DateTabTyp;
      in_last_updated_by        OKC_DATATYPES.Number15TabTyp;
      in_last_update_date       OKC_DATATYPES.DateTabTyp;
      in_last_update_login      OKC_DATATYPES.Number15TabTyp;
      i number;
      j number;
Begin
  -- Initialize return status
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  i := p_sllv_tbl.FIRST;
  j:=0;

  while i is not null
  LOOP
      j:= j+1;
      in_id(j) := 	              p_sllv_tbl(i).id;
      in_chr_id(j) := 	          p_sllv_tbl(i).chr_id;
      in_cle_id(j) := 	          p_sllv_tbl(i).cle_id;
      in_dnz_chr_id(j) := 	      p_sllv_tbl(i).dnz_chr_id;
      in_sequence_no(j) := 	      p_sllv_tbl(i).sequence_no;
      in_uom_code(j) := 	      p_sllv_tbl(i).uom_code;
      in_start_date(j) := 	      p_sllv_tbl(i).start_date;
      in_end_date(j) := 	      p_sllv_tbl(i).end_date;
      in_level_periods(j) := 	      p_sllv_tbl(i).level_periods;
      in_uom_per_period(j) := 	      p_sllv_tbl(i).uom_per_period;
      in_advance_periods(j) := 	      p_sllv_tbl(i).advance_periods;
      in_level_amount(j) := 	      p_sllv_tbl(i).level_amount;
      in_invoice_offset_days(j) := 	  p_sllv_tbl(i).invoice_offset_days;
      in_interface_offset_days(j) :=  p_sllv_tbl(i).interface_offset_days;
      in_comments(j) := 	      p_sllv_tbl(i).comments;
      in_due_arr_yn(j) := 	      p_sllv_tbl(i).due_arr_yn;
      in_amount(j) := 	          p_sllv_tbl(i).amount;
      in_lines_detailed_yn(j) := 	      p_sllv_tbl(i).lines_detailed_yn;
      in_object_version_number(j) := 	  p_sllv_tbl(i).object_version_number;
      in_request_id(j) := 	      p_sllv_tbl(i).request_id;
      in_created_by(j) := 	      p_sllv_tbl(i).created_by;
      in_creation_date(j) := 	  p_sllv_tbl(i).creation_date;
      in_last_updated_by(j) := 	  p_sllv_tbl(i).last_updated_by;
      in_last_update_date(j) :=   p_sllv_tbl(i).last_update_date;
      in_last_update_login (j) := p_sllv_tbl(i).last_update_login;
      i:= p_sllv_tbl.next(i);
  End Loop;

  FORALL i in 1..l_tabsize
    INSERT
    INTO OKS_STREAM_LEVELS_B(
      id,
      chr_id,
      cle_id,
      dnz_chr_id,
      sequence_no,
      uom_code,
      start_date,
      end_date,
      level_periods,
      uom_per_period,
      advance_periods,
      level_amount,
      invoice_offset_days,
      interface_offset_days,
      comments,
      due_arr_yn,
      amount,
      lines_detailed_yn,
      object_version_number,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
    ) VALUES (
      in_id(i),
      in_chr_id(i),
      in_cle_id(i),
      in_dnz_chr_id(i),
      in_sequence_no(i),
      in_uom_code(i),
      in_start_date(i),
      in_end_date(i),
      in_level_periods(i),
      in_uom_per_period(i),
      in_advance_periods(i),
      in_level_amount(i),
      in_invoice_offset_days(i),
      in_interface_offset_days(i),
      in_comments(i),
      in_due_arr_yn(i),
      in_amount(i),
      in_lines_detailed_yn(i),
      in_object_version_number(i),
      in_request_id(i),
      in_created_by(i),
      in_creation_date(i),
      in_last_updated_by(i),
      in_last_update_date(i),
      in_last_update_login(i)
      );

EXCEPTION
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

END INSERT_ROW_UPG;

END oks_contract_sll_pub;


/
