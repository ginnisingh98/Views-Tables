--------------------------------------------------------
--  DDL for Package Body OKC_QA_CHECK_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QA_CHECK_LIST_PVT" AS
/* $Header: OKCCQCLB.pls 120.0 2005/05/25 22:31:22 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE create_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type,
    x_qclv_rec                     OUT NOCOPY qclv_rec_type)
  IS
  BEGIN
    OKC_QCL_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => p_qclv_rec,
      x_qclv_rec      => x_qclv_rec);
  END create_qa_check_list;

  PROCEDURE update_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type,
    x_qclv_rec                     OUT NOCOPY qclv_rec_type) IS
  BEGIN
    OKC_QCL_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => p_qclv_rec,
      x_qclv_rec      => x_qclv_rec);
  END update_qa_check_list;

  PROCEDURE delete_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type) IS
  BEGIN
    OKC_QCL_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => p_qclv_rec);
  END delete_qa_check_list;

  PROCEDURE lock_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type) IS
  BEGIN
    OKC_QCL_PVT.lock_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => p_qclv_rec);
  END lock_qa_check_list;

  PROCEDURE validate_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type) IS
  BEGIN
    OKC_QCL_PVT.validate_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => p_qclv_rec);
  END validate_qa_check_list;

  PROCEDURE create_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type,
    x_qlpv_rec                     OUT NOCOPY qlpv_rec_type)
  IS
  BEGIN
    OKC_QLP_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => p_qlpv_rec,
      x_qlpv_rec      => x_qlpv_rec);
  END create_qa_process;

  PROCEDURE update_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type,
    x_qlpv_rec                     OUT NOCOPY qlpv_rec_type) IS
  BEGIN
    OKC_QLP_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => p_qlpv_rec,
      x_qlpv_rec      => x_qlpv_rec);
  END update_qa_process;

  PROCEDURE delete_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type) IS
  BEGIN
    OKC_QLP_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => p_qlpv_rec);
  END delete_qa_process;

  PROCEDURE lock_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type) IS
  BEGIN
    OKC_QLP_PVT.lock_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => p_qlpv_rec);
  END lock_qa_process;

  PROCEDURE validate_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type) IS
  BEGIN
    OKC_QLP_PVT.validate_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => p_qlpv_rec);
  END validate_qa_process;

  PROCEDURE create_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type,
    x_qppv_rec                     OUT NOCOPY qppv_rec_type)
  IS
  BEGIN
    OKC_QPP_PVT.insert_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => p_qppv_rec,
      x_qppv_rec      => x_qppv_rec);
  END create_qa_parm;

  PROCEDURE update_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type,
    x_qppv_rec                     OUT NOCOPY qppv_rec_type) IS
  BEGIN
    OKC_QPP_PVT.update_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => p_qppv_rec,
      x_qppv_rec      => x_qppv_rec);
  END update_qa_parm;

  PROCEDURE delete_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type) IS
  BEGIN
    OKC_QPP_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => p_qppv_rec);
  END delete_qa_parm;

  PROCEDURE lock_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type) IS
  BEGIN
    OKC_QPP_PVT.lock_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => p_qppv_rec);
  END lock_qa_parm;

  PROCEDURE validate_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type) IS
  BEGIN
    OKC_QPP_PVT.validate_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => p_qppv_rec);
  END validate_qa_parm;

  PROCEDURE add_language IS
  BEGIN
    OKC_QCL_PVT.add_language;
  END add_language;

END OKC_QA_CHECK_LIST_PVT;

/
