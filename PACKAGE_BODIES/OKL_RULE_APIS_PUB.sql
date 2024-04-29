--------------------------------------------------------
--  DDL for Package Body OKL_RULE_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RULE_APIS_PUB" As
/* $Header: OKLPRAPB.pls 115.9 2002/11/30 08:38:48 spillaip noship $ */
--Start of Comments
--Procedure Name :  Get_Contract_Rgs
--Description    :  Get Contract Rule Groups for a chr_id, cle_id
--                 if chr_id is given gets data for header
--                 if only cle_id or cle_id and chr_id(dnz_chr_id) are given
--                 fetches data for line
--End of comments
Procedure Get_Contract_Rgs(p_api_version    IN  NUMBER,
                           p_init_msg_list  IN  VARCHAR2,
                           p_chr_id		    IN  NUMBER,
                           p_cle_id         IN  NUMBER,
                           p_rgd_code       IN  VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_rgpv_tbl       OUT NOCOPY rgpv_tbl_type,
                           x_rg_count       OUT NOCOPY NUMBER) is
    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_CONTRACT_RGS';
    l_api_version		           CONSTANT NUMBER	:= 1.0;
BEGIN
--Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PUB',
                                         	   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_RULE_APIS_PVT.Get_Contract_Rgs(p_api_version    => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       p_chr_id		    => p_chr_id,
                                       p_cle_id         => p_cle_id,
                                       p_rgd_code       => p_rgd_code,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       x_rgpv_tbl       => x_rgpv_tbl,
                                       x_rg_count       => x_rg_count);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
    EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END Get_Contract_Rgs;

--Start of Comments
--Procedure    : Get Contract Rules
--Description  : Gets all or specific rules for a rule group
-- End of Comments

Procedure Get_Contract_Rules(p_api_version    IN  NUMBER,
                             p_init_msg_list  IN  VARCHAR2,
                             p_rgpv_rec       IN  rgpv_rec_type,
                             p_rdf_code       IN  VARCHAR2,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             x_rulv_tbl       OUT NOCOPY rulv_tbl_type,
                             x_rule_count     OUT NOCOPY NUMBER ) IS

    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_CONTRACT_RULES';
    l_api_version		           CONSTANT NUMBER	:= 1.0;
BEGIN
--Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PUB',
                                         	   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_RULE_APIS_PVT.Get_Contract_Rules(p_api_version  => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             p_rgpv_rec       => p_rgpv_rec,
                             p_rdf_code       => p_rdf_code,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_rulv_tbl       => x_rulv_tbl,
                             x_rule_count     => x_rule_count);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
    EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END Get_Contract_Rules;


-- Start of comments
--Procedure   : Get Rule Information
--Description : Fetches the display value (name) and select clause of the
--              rule information column in a rule if stored value(p_rule_info)
--              is provided else just returns the select clause
--              IN p_rdf_code      : rule_code
--                 p_appl_col_name : segment column name ('RULE_INFORMATION1',...)
--                 p_rule_info     : segment column value default Null
-- End of Comments

Procedure Get_rule_Information (p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2,
                                p_rdf_code       IN  VARCHAR2,
                                p_appl_col_name  IN  VARCHAR2,
                                p_rule_info      IN  VARCHAR2,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                x_name           OUT NOCOPY VARCHAR2,
                                x_select         OUT NOCOPY VARCHAR2) IS

    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_RULE_INFORMATION';
    l_api_version		           CONSTANT NUMBER	:= 1.0;
BEGIN
--Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PUB',
                                         	   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_RULE_APIS_PVT.Get_rule_Information (p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rdf_code,
                                p_appl_col_name  => p_appl_col_name,
                                p_rule_info      => p_rule_info,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => x_name,
                                x_select         => x_select);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
    EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END Get_rule_Information;

-- Start of comments
--Procedure   : Get_jtot_object
--Description : Fetches the display values (name,description)  and additional
--              columns status, start_date, end_date, org_id, inv_org_id,
--              book_type_code, if present if id1 and id2 are given
--              Also returns the select clause associated with the jtf_object
-- End of Comments

Procedure Get_jtot_object(p_api_version     IN  NUMBER,
                          p_init_msg_list   IN  VARCHAR2,
                          p_object_code     IN  VARCHAR2,
                          p_id1             IN  VARCHAR2,
                          p_id2             IN  VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_id1             OUT NOCOPY VARCHAR2,
                          x_id2             OUT NOCOPY VARCHAR2,
                          x_name            OUT NOCOPY VARCHAR2,
                          x_description     OUT NOCOPY VARCHAR2,
                          x_status          OUT NOCOPY VARCHAR2,
                          x_start_date      OUT NOCOPY DATE,
                          x_end_date        OUT NOCOPY DATE,
                          x_org_id          OUT NOCOPY NUMBER,
                          x_inv_org_id      OUT NOCOPY NUMBER,
                          x_book_type_code  OUT NOCOPY VARCHAR2,
                          x_select          OUT NOCOPY VARCHAR2)IS

    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_JTOT_OBJECT';
    l_api_version		           CONSTANT NUMBER	:= 1.0;
BEGIN
--Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PUB',
                                         	   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_RULE_APIS_PVT.Get_jtot_object(p_api_version     => p_api_version,
                          p_init_msg_list   => p_init_msg_list,
                          p_object_code     => p_object_code,
                          p_id1             => p_id1,
                          p_id2             => p_id2,
                          x_return_status   => x_return_status,
                          x_msg_count       => x_msg_count,
                          x_msg_data        => x_msg_data,
                          x_id1             => x_id1,
                          x_id2             => x_id2,
                          x_name            => x_name,
                          x_description     => x_description,
                          x_status          => x_status,
                          x_start_date      => x_start_date,
                          x_end_date        => x_end_date,
                          x_org_id          => x_org_id,
                          x_inv_org_id      => x_inv_org_id,
                          x_book_type_code  => x_book_type_code,
                          x_select          => x_select);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
    EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
End Get_jtot_object;
--Start of Comments
--Procedure    : Get_Rule_disp_value
--Description  : Fetches the displayed values of all rule segments
--End of Comments

Procedure Get_Rule_disp_value    (p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2,
                                  p_rulv_rec       IN Rulv_rec_type,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  x_rulv_disp_rec  OUT  NOCOPY rulv_disp_rec_type)IS

    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_RULE_DISP_VALUE';
    l_api_version		           CONSTANT NUMBER	:= 1.0;
BEGIN
--Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PUB',
                                         	   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_RULE_APIS_PVT.Get_Rule_disp_value(p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rulv_rec       => p_rulv_rec,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_rulv_disp_rec  => x_rulv_disp_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
    EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
End Get_Rule_disp_value;
--Start of Comments
--Procedure    : Get_Rule_Segment_value
--Description  : Fetches the displayed value and select clauses of
--               of specific rule segment.
--Note         : This API requires exact screen prompt label of the segment
--               to be passed as p_rdf_name
--End of Comments
Procedure Get_rule_Segment_Value(p_api_version     IN  NUMBER,
                                 p_init_msg_list   IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chr_id          IN  NUMBER,
                                 p_cle_id          IN  NUMBER,
                                 p_rgd_code        IN  VARCHAR2,
                                 p_rdf_code        IN  VARCHAR2,
                                 p_rdf_name        IN  VARCHAR2,
                                 x_id1             OUT NOCOPY VARCHAR2,
                                 x_id2             OUT NOCOPY VARCHAR2,
                                 x_name            OUT NOCOPY VARCHAR2,
                                 x_description     OUT NOCOPY VARCHAR2,
                                 x_status          OUT NOCOPY VARCHAR2,
                                 x_start_date      OUT NOCOPY DATE,
                                 x_end_date        OUT NOCOPY DATE,
                                 x_org_id          OUT NOCOPY NUMBER,
                                 x_inv_org_id      OUT NOCOPY NUMBER,
                                 x_book_type_code  OUT NOCOPY VARCHAR2,
                                 x_select          OUT NOCOPY VARCHAR2) is

    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_RULE_SEGMENT_VALUE';
    l_api_version		           CONSTANT NUMBER	:= 1.0;
Begin
    --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PUB',
                                         	   x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_RULE_APIS_PVT.Get_rule_Segment_Value(p_api_version     => p_api_version,
                                             p_init_msg_list   => p_init_msg_list,
                                             x_return_status   => x_return_status,
                                             x_msg_count       => x_msg_count,
                                             x_msg_data        => x_msg_data,
                                             p_chr_id          => p_chr_id,
                                             p_cle_id          => p_cle_id,
                                             p_rgd_code        => p_rgd_code,
                                             p_rdf_code        => p_rdf_code,
                                             p_rdf_name        => p_rdf_name,
                                             x_id1             => x_id1,
                                             x_id2             => x_id2,
                                             x_name            => x_name,
                                             x_description     => x_description,
                                             x_status          => x_status,
                                             x_start_date      => x_start_date,
                                             x_end_date        => x_end_date,
                                             x_org_id          => x_org_id,
                                             x_inv_org_id      => x_inv_org_id,
                                             x_book_type_code  => x_book_type_code,
                                             x_select          => x_select);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
   when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
End Get_Rule_Segment_Value;
--Start of Comments
--Bug#2525946   : overloaded to take rule segment numbers as input
--Procedure    : Get_Rule_Segment_value
--Description  : Fetches the displayed value and select clauses of
--               of specific rule segment.
--Note         : This API requires segment number
--               Segment number 1 to 15 are mapped to RULE_INFORMATION1 to
--               RULE_INFORMATION15. Segment Numbers 16, 17 and 18 are mapped
--               to jtot_object1, jtot_object2 and jtot_object3 respectively
--End of Comments
Procedure Get_rule_Segment_Value(p_api_version     IN  NUMBER,
                                 p_init_msg_list   IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chr_id          IN  NUMBER,
                                 p_cle_id          IN  NUMBER,
                                 p_rgd_code        IN  VARCHAR2,
                                 p_rdf_code        IN  VARCHAR2,
                                 p_segment_number  IN  NUMBER,
                                 x_id1             OUT NOCOPY VARCHAR2,
                                 x_id2             OUT NOCOPY VARCHAR2,
                                 x_name            OUT NOCOPY VARCHAR2,
                                 x_description     OUT NOCOPY VARCHAR2,
                                 x_status          OUT NOCOPY VARCHAR2,
                                 x_start_date      OUT NOCOPY DATE,
                                 x_end_date        OUT NOCOPY DATE,
                                 x_org_id          OUT NOCOPY NUMBER,
                                 x_inv_org_id      OUT NOCOPY NUMBER,
                                 x_book_type_code  OUT NOCOPY VARCHAR2,
                                 x_select          OUT NOCOPY VARCHAR2) is
    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_RULE_SEGMENT_VALUE';
    l_api_version		           CONSTANT NUMBER	:= 1.0;
Begin
    --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PUB',
                                         	   x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_RULE_APIS_PVT.Get_rule_Segment_Value(p_api_version     => p_api_version,
                                             p_init_msg_list   => p_init_msg_list,
                                             x_return_status   => x_return_status,
                                             x_msg_count       => x_msg_count,
                                             x_msg_data        => x_msg_data,
                                             p_chr_id          => p_chr_id,
                                             p_cle_id          => p_cle_id,
                                             p_rgd_code        => p_rgd_code,
                                             p_rdf_code        => p_rdf_code,
                                             p_segment_number  => p_segment_number,
                                             x_id1             => x_id1,
                                             x_id2             => x_id2,
                                             x_name            => x_name,
                                             x_description     => x_description,
                                             x_status          => x_status,
                                             x_start_date      => x_start_date,
                                             x_end_date        => x_end_date,
                                             x_org_id          => x_org_id,
                                             x_inv_org_id      => x_inv_org_id,
                                             x_book_type_code  => x_book_type_code,
                                             x_select          => x_select);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
   when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
End Get_Rule_Segment_Value;

End OKL_RULE_APIS_PUB;

/
