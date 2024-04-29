--------------------------------------------------------
--  DDL for Package Body OKL_RGRP_RULES_PROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RGRP_RULES_PROCESS_PUB" as
/* $Header: OKLPRGRB.pls 115.13 2002/11/30 08:39:40 spillaip noship $ */

   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_RGRP_RULES_PROCESS_PUB';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PUB';


PROCEDURE process_rule_group_rules(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_chr_id                  IN  NUMBER,
      p_line_id                 IN  NUMBER,
      p_cpl_id                       IN  NUMBER,
      p_rrd_id                       IN  NUMBER,
      p_rgr_tbl                      IN  rgr_tbl_type) IS
      l_return_status VARCHAR2(1) := '0';
      l_init_msg_list CONSTANT VARCHAR2(30) := p_init_msg_list;
      l_msg_count NUMBER := 0;
      l_msg_data  varchar2(2000);
      l_msg_index_out NUMBER;

      l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';
      l_proc_name   VARCHAR2(35)    := 'PROCESS_RULE_GROUP_RULES';
      l_api_version CONSTANT VARCHAR2(30) := p_api_version;

      BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;


  OKL_RGRP_RULES_PROCESS_PVT.process_rule_group_rules(
                p_api_version        => p_api_version,
                        p_init_msg_list      => p_init_msg_list,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                    p_chr_id             => p_chr_id,
                    p_line_id            => p_line_id,
            p_cpl_id        => p_cpl_id,
            p_rrd_id        => p_rrd_id,
                        p_rgr_tbl            => p_rgr_tbl);

IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END process_rule_group_rules;

PROCEDURE process_template_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                       IN  NUMBER,
    p_rgr_tbl                      IN  rgr_tbl_type,
    x_rgr_tbl              OUT NOCOPY rgr_out_tbl_type) IS
    l_return_status VARCHAR2(1) := '0';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;
    l_init_msg_list CONSTANT VARCHAR2(30) := p_init_msg_list;
    l_msg_count NUMBER := 0;
    l_msg_data  varchar2(2000);
    l_msg_index_out NUMBER;

    l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';
    l_proc_name   VARCHAR2(35)    := 'PROCESS_TEMPLATE_RULES';

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;


    OKL_RGRP_RULES_PROCESS_PVT.process_template_rules(
                p_api_version        => p_api_version,
                        p_init_msg_list      => p_init_msg_list,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                    p_id                 => p_id,
                    p_rgr_tbl            => p_rgr_tbl,
                    x_rgr_tbl        => x_rgr_tbl);


IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END process_template_rules;

FUNCTION get_header_rule_group_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rgd_code                     IN  VARCHAR2)
RETURN OKC_RULE_GROUPS_B.ID%TYPE IS
    rule_group_id NUMBER := null;
    BEGIN
        rule_group_id := OKL_RGRP_RULES_PROCESS_PVT.get_header_rule_group_id(
                        p_api_version        => p_api_version,
                        p_init_msg_list      => p_init_msg_list,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_chr_id             => p_chr_id,
                        p_rgd_code           => p_rgd_code);
        return rule_group_id;
    END get_header_rule_group_id;
END OKL_RGRP_RULES_PROCESS_PUB;

/
