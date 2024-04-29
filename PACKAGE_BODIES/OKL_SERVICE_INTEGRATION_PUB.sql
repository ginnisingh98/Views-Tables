--------------------------------------------------------
--  DDL for Package Body OKL_SERVICE_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SERVICE_INTEGRATION_PUB" AS
/* $Header: OKLPSRIB.pls 115.1 2002/12/30 23:13:24 dedey noship $*/

-- Global Variables
   G_DEBUG       NUMBER := 1;
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_SERVICE_INTEGRATION_PUB';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PUB';

------------------------------------------------------------------------------
-- PROCEDURE create_link_service_line
--
--  This procedure creates and links service line under a given contract in OKL. The
--  service line information comes from OKS service contract number provided as
--  an input parameter.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_link_service_line(
                                         p_api_version         IN  NUMBER,
                                         p_init_msg_list       IN  VARCHAR2,
                                         x_return_status       OUT NOCOPY VARCHAR2,
                                         x_msg_count           OUT NOCOPY NUMBER,
                                         x_msg_data            OUT NOCOPY VARCHAR2,
                                         p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                         p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                         p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                         p_supplier_id         IN  NUMBER,
                                         x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE    -- Returns Lease Contract Service TOP Line ID
                               )IS

   l_api_name    VARCHAR2(35)    := 'create_link_service_line';
   l_proc_name   VARCHAR2(35)    := 'CREATE_LINK_SERVICE_LINE';
   l_api_version CONSTANT NUMBER := 1;

   l_okl_service_line_id OKC_K_HEADERS_V.ID%TYPE;
   BEGIN


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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      okl_service_integration_pvt.create_link_service_line(
                          p_api_version         => 1.0,
                          p_init_msg_list       => OKL_API.G_FALSE,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data,
                          p_okl_chr_id          => p_okl_chr_id,
                          p_oks_chr_id          => p_oks_chr_id,
                          p_oks_service_line_id => p_oks_service_line_id,
                          p_supplier_id         => p_supplier_id,
                          x_okl_service_line_id => x_okl_service_line_id
                         );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
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

   END create_link_service_line;
------------------------------------------------------------------------------
-- PROCEDURE create_service_line
--
--  This procedure creates a service line under a given contract in OKL. The
--  service line information comes from OKS service contract number provided as
--  an input parameter.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                p_supplier_id         IN  NUMBER,
                                x_okl_service_line_id OUT NOCOPY  OKC_K_LINES_V.ID%TYPE    -- Returns Lease Contract Service TOP Line ID
                               )IS
   l_api_name    VARCHAR2(35)    := 'create_service_line';
   l_proc_name   VARCHAR2(35)    := 'CREATE_SERVICE_LINE';
   l_api_version CONSTANT NUMBER := 1;

   BEGIN -- main process begins here

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      okl_service_integration_pvt.create_service_line(
                                                      p_api_version         => p_api_version,
                                                      p_init_msg_list       => p_init_msg_list,
                                                      x_return_status       => x_return_status,
                                                      x_msg_count           => x_msg_count,
                                                      x_msg_data            => x_msg_data,
                                                      p_okl_chr_id          => p_okl_chr_id,
                                                      p_oks_chr_id          => p_oks_chr_id,
                                                      p_oks_service_line_id => p_oks_service_line_id,
                                                      p_supplier_id         => p_supplier_id,
                                                      x_okl_service_line_id => x_okl_service_line_id
                                                     );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
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

   END create_service_line;

------------------------------------------------------------------------------
-- PROCEDURE link_service_line
--
--  This procedure links
--     1. Lease and Service Contract Header
--     2. Lease Contract Service Line and Service Contract service line
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE link_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_okl_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Lease Service Top Line ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE    -- Service Contract - Service TOP Line ID
                               ) IS

   l_api_name    VARCHAR2(35)    := 'link_service_line';
   l_proc_name   VARCHAR2(35)    := 'LINK_SERVICE_LINE';
   l_api_version CONSTANT NUMBER := 1;

   BEGIN

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      okl_service_integration_pvt.link_service_line(
                                                    p_api_version        => p_api_version,
                                                    p_init_msg_list      => p_init_msg_list,
                                                    x_return_status      => x_return_status,
                                                    x_msg_count          => x_msg_count,
                                                    x_msg_data           => x_msg_data,
                                                    p_okl_chr_id         => p_okl_chr_id,
                                                    p_oks_chr_id         => p_oks_chr_id,
                                                    p_okl_service_line_id => p_okl_service_line_id,
                                                    p_oks_service_line_id => p_oks_service_line_id
                                                   );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
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

  END link_service_line;

------------------------------------------------------------------------------
-- PROCEDURE delete_service_line
--
--  This procedure deletes service line. It also checks for any existing links
--  with OKS Service contract, if so, it deltes the link too.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE delete_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_clev_rec            IN  clev_rec_type,
                                p_klev_rec            IN  klev_rec_type
                               ) IS
  l_api_name    VARCHAR2(35)    := 'delete_service_link';
  l_proc_name   VARCHAR2(35)    := 'DELETE_SERVICE_LINK';
  l_api_version CONSTANT NUMBER := 1;

  BEGIN -- main process begins here

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      okl_service_integration_pvt.delete_service_line(
                                            p_api_version       => p_api_version,
                                            p_init_msg_list     => OKL_API.G_FALSE,
                                            x_return_status     => x_return_status,
                                            x_msg_count         => x_msg_count,
                                            x_msg_data          => x_msg_data,
                                            p_clev_rec          => p_clev_rec,
                                            p_klev_rec          => p_klev_rec
                                           );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
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

  END delete_service_line;

------------------------------------------------------------------------------
-- PROCEDURE update_service_line
--
--  This procedure updates existing service line link. It deletes existing
--  OKL Service line and recreate the same from OKS service line. It re-establish
--  the link at the end.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
 PROCEDURE update_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                p_supplier_id         IN  NUMBER,
                                p_clev_rec            IN  clev_rec_type,
                                p_klev_rec            IN  klev_rec_type,
                                x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE
                              ) IS
  l_api_name    VARCHAR2(35)    := 'update_service_link';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_SERVICE_LINK';
  l_api_version CONSTANT NUMBER := 1;

  BEGIN -- main process begins here

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      okl_service_integration_pvt.update_service_line(
                             p_api_version         => p_api_version,
                             p_init_msg_list       => OKL_API.G_TRUE,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_okl_chr_id          => p_okl_chr_id,
                             p_oks_chr_id          => p_oks_chr_id,
                             p_oks_service_line_id => p_oks_service_line_id,
                             p_supplier_id         => p_supplier_id,
                             p_clev_rec            => p_clev_rec,
                             p_klev_rec            => p_klev_rec,
                             x_okl_service_line_id => x_okl_service_line_id
                            );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
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

  END update_service_line;


------------------------------------------------------------------------------
-- PROCEDURE check_service_link
--
--  This procedure checks whether a service contract is linked to the lease
--  contract.
--  If a link exists, the service contract information is returned back.
--  If no link exists, it returns NULL to service contract out variables.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE check_service_link (
                                p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                p_lease_contract_id       IN  OKC_K_HEADERS_V.ID%TYPE,
                                x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               ) IS
  l_api_name    VARCHAR2(35)    := 'check_service_link';
  l_proc_name   VARCHAR2(35)    := 'CHECK_SERVICE_LINK';
  l_api_version CONSTANT NUMBER := 1;


  BEGIN

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      okl_service_integration_pvt.check_service_link(
                                                     p_api_version          => p_api_version,
                                                     p_init_msg_list        => p_init_msg_list,
                                                     x_return_status        => x_return_status,
                                                     x_msg_count            => x_msg_count,
                                                     x_msg_data             => x_msg_data,
                                                     p_lease_contract_id    => p_lease_contract_id,
                                                     x_service_contract_id  => x_service_contract_id
                                                    );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
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

  END check_service_link;

------------------------------------------------------------------------------
-- PROCEDURE get_service_link_line
--
--  This procedure returns linked lease and service contract top lines ID.
--  It also returns linked OKS service contract header id
--  Note: Service contract id will be NULL in case lease contract is not
--        linked to a service contract.
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE get_service_link_line (
                                   p_api_version             IN  NUMBER,
                                   p_init_msg_list           IN  VARCHAR2,
                                   x_return_status           OUT NOCOPY VARCHAR2,
                                   x_msg_count               OUT NOCOPY NUMBER,
                                   x_msg_data                OUT NOCOPY VARCHAR2,
                                   p_lease_contract_id       IN  OKC_K_HEADERS_V.ID%TYPE,
                                   x_link_line_tbl           OUT NOCOPY LINK_LINE_TBL_TYPE,
                                   x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               ) IS
  l_api_name    VARCHAR2(35)    := 'get_service_link_line';
  l_proc_name   VARCHAR2(35)    := 'GET_SREVICE_LINK_LINE';
  l_api_version CONSTANT NUMBER := 1;

  BEGIN

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      okl_service_integration_pvt.get_service_link_line(
                             p_api_version         => p_api_version,
                             p_init_msg_list       => p_init_msg_list,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_lease_contract_id   => p_lease_contract_id,
                             x_link_line_tbl       => x_link_line_tbl,
                             x_service_contract_id => x_service_contract_id
                            );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
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

  END get_service_link_line;


------------------------------------------------------------------------------
-- PROCEDURE create_cov_asset_line
--
--  This procedure validates covered asset and creates covered asset line
--  under OKL service top line.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
 PROCEDURE create_cov_asset_line(
                                 p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_clev_tbl       IN  clev_tbl_type,
                                 p_klev_tbl       IN  klev_tbl_type,
                                 p_cimv_tbl       IN  cimv_tbl_type,
                                 p_cov_tbl        IN  srv_cov_tbl_type,
                                 x_clev_tbl       OUT NOCOPY clev_tbl_type,
                                 x_klev_tbl       OUT NOCOPY klev_tbl_type,
                                 x_cimv_tbl       OUT NOCOPY cimv_tbl_type
                                ) IS
  l_api_name    VARCHAR2(35)    := 'create_cov_asset_line';
  l_proc_name   VARCHAR2(35)    := 'CREATE_COV_ASSET_LINE';
  l_api_version CONSTANT NUMBER := 1;


  BEGIN -- main process begins here

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

      OKL_SERVICE_INTEGRATION_PVT.CREATE_COV_ASSET_LINE (
                              p_api_version    => p_api_version,
                              p_init_msg_list  => OKL_API.G_FALSE,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_clev_tbl       => p_clev_tbl,
                              p_klev_tbl       => p_klev_tbl,
                              p_cimv_tbl       => p_cimv_tbl,
                              p_cov_tbl        => p_cov_tbl,
                              x_clev_tbl       => x_clev_tbl,
                              x_klev_tbl       => x_klev_tbl,
                              x_cimv_tbl       => x_cimv_tbl
                             );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

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

  END create_cov_asset_line;

------------------------------------------------------------------------------
-- PROCEDURE update_cov_asset_line
--
--  This procedure validates covered asset and updates covered asset line
--  under OKL service top line.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
 PROCEDURE update_cov_asset_line(
                                 p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_clev_tbl       IN  clev_tbl_type,
                                 p_klev_tbl       IN  klev_tbl_type,
                                 p_cimv_tbl       IN  cimv_tbl_type,
                                 p_cov_tbl        IN  srv_cov_tbl_type,
                                 x_clev_tbl       OUT NOCOPY clev_tbl_type,
                                 x_klev_tbl       OUT NOCOPY klev_tbl_type,
                                 x_cimv_tbl       OUT NOCOPY cimv_tbl_type
                                ) IS
  l_api_name    VARCHAR2(35)    := 'update_cov_asset_line';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_COV_ASSET_LINE';
  l_api_version CONSTANT NUMBER := 1;


  BEGIN -- main process begins here

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

      OKL_SERVICE_INTEGRATION_PVT.UPDATE_COV_ASSET_LINE (
                              p_api_version    => p_api_version,
                              p_init_msg_list  => OKL_API.G_FALSE,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_clev_tbl       => p_clev_tbl,
                              p_klev_tbl       => p_klev_tbl,
                              p_cimv_tbl       => p_cimv_tbl,
                              p_cov_tbl        => p_cov_tbl,
                              x_clev_tbl       => x_clev_tbl,
                              x_klev_tbl       => x_klev_tbl,
                              x_cimv_tbl       => x_cimv_tbl
                             );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

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

  END update_cov_asset_line;

------------------------------------------------------------------------------
-- PROCEDURE initiate_service_booking
--
--  This procedure is being called from activate API. It checks for service
--  link and associates IB instances from OKS service line with
--  corresponding IB line instances at lease contract.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE initiate_service_booking(
                                    p_api_version    IN  NUMBER,
                                    p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id     IN  OKC_K_HEADERS_B.ID%TYPE
                                ) IS
  l_api_name    VARCHAR2(35)    := 'initiate_service_booking';
  l_proc_name   VARCHAR2(35)    := 'INITIATE_SERVICE_BOOKING';
  l_api_version CONSTANT NUMBER := 1;

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
      --************************************************

      okl_service_integration_pvt.initiate_service_booking(
                                    p_api_version    => p_api_version,
                                    p_init_msg_list  => p_init_msg_list,
                                    x_return_status  => x_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data,
                                    p_okl_chr_id     => p_okl_chr_id
                                );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --************************************************

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

  END initiate_service_booking;
END OKL_SERVICE_INTEGRATION_PUB;

/
