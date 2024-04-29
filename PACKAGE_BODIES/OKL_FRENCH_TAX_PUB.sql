--------------------------------------------------------
--  DDL for Package Body OKL_FRENCH_TAX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FRENCH_TAX_PUB" AS
/* $Header: OKLPFWTB.pls 115.1 2002/07/29 22:17:07 avsingh noship $ */
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------


  PROCEDURE create_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type,
    x_fwtv_rec                     OUT NOCOPY fwtv_rec_type) is
begin
    null;
end create_french_tax;

  PROCEDURE create_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type) is
begin
    null;
end create_french_tax;


  PROCEDURE update_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type,
    x_fwtv_rec                     OUT NOCOPY fwtv_rec_type) is
begin
    null;
end update_french_tax;

  PROCEDURE update_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type) is
begin
    null;
end update_french_tax;

  PROCEDURE delete_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type) is
begin
    null;
end delete_french_tax;

  PROCEDURE delete_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type) is
begin
    null;
end delete_french_tax;

  PROCEDURE validate_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type) is
begin
    null;
end validate_french_tax;

  PROCEDURE validate_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type) is
begin
    null;
end validate_french_tax;

END OKL_FRENCH_TAX_PUB;

/
