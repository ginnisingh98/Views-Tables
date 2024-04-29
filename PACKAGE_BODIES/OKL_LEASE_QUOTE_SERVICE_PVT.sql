--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_SERVICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_SERVICE_PVT" AS
/* $Header: OKLRQUSB.pls 120.7.12010000.2 2009/11/09 23:56:40 sechawla ship $ */

  ----------------------------
  -- PROCEDURE validate_header
  ----------------------------
  PROCEDURE validate_header(
     p_service_rec             IN  okl_svc_pvt.svcv_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'validate_header';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_header;


  ------------------------------
  -- PROCEDURE get_currency_code
  ------------------------------
  PROCEDURE get_currency_code (
     p_parent_object_id        IN  NUMBER
    ,x_currency_code           OUT NOCOPY VARCHAR2
    ,x_return_status           OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_currency_code';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_parent_object_code   VARCHAR2(30);

  BEGIN

    SELECT parent_object_code
    INTO   l_parent_object_code
    FROM   okl_lease_quotes_b
    WHERE  id = p_parent_object_id;

    IF (l_parent_object_code = 'LEASEOPP') THEN
      SELECT currency_code
      INTO   x_currency_code
      FROM   okl_lease_opportunities_b lop,
             okl_lease_quotes_b lsq
      WHERE  lsq.parent_object_code = l_parent_object_code
      AND    lsq.parent_object_id = lop.id
      AND    lsq.id = p_parent_object_id;
    ELSIF (l_parent_object_code = 'LEASEAPP') THEN
      SELECT currency_code
      INTO   x_currency_code
      FROM   okl_lease_applications_b lap,
             okl_lease_quotes_b lsq
      WHERE  lsq.parent_object_code = l_parent_object_code
      AND    lsq.parent_object_id = lap.id
      AND    lsq.id = p_parent_object_id;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_currency_code;


  ----------------------------
  -- PROCEDURE get_service_rec
  ----------------------------
  PROCEDURE get_service_rec (
    p_service_id              IN  NUMBER
   ,x_service_rec             OUT NOCOPY okl_svc_pvt.svcv_rec_type
   ,x_return_status           OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_service_rec';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    SELECT
       attribute_category
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
      ,inv_item_id
      ,parent_object_code
      ,parent_object_id
      ,effective_from
      ,supplier_id
      ,short_description
      ,description
      ,comments
    INTO
       x_service_rec.attribute_category
      ,x_service_rec.attribute1
      ,x_service_rec.attribute2
      ,x_service_rec.attribute3
      ,x_service_rec.attribute4
      ,x_service_rec.attribute5
      ,x_service_rec.attribute6
      ,x_service_rec.attribute7
      ,x_service_rec.attribute8
      ,x_service_rec.attribute9
      ,x_service_rec.attribute10
      ,x_service_rec.attribute11
      ,x_service_rec.attribute12
      ,x_service_rec.attribute13
      ,x_service_rec.attribute14
      ,x_service_rec.attribute15
      ,x_service_rec.inv_item_id
      ,x_service_rec.parent_object_code
      ,x_service_rec.parent_object_id
      ,x_service_rec.effective_from
      ,x_service_rec.supplier_id
      ,x_service_rec.short_description
      ,x_service_rec.description
      ,x_service_rec.comments
    FROM okl_services_v
    WHERE id = p_service_id;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_service_rec;


  ---------------------------------
  -- PROCEDURE validate_link_assets
  ---------------------------------
  PROCEDURE validate_link_assets (p_service_amount   IN NUMBER,
                                  p_assoc_assets_tbl IN line_relation_tbl_type,
                                  x_derive_assoc_amt OUT NOCOPY VARCHAR2,
                                  x_return_status    OUT NOCOPY VARCHAR2) IS

  l_program_name         CONSTANT VARCHAR2(30) := 'validate_link_assets';
  l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  l_link_exists_yn    VARCHAR2(1);
  l_assoc_total       NUMBER;
  l_amt_flag          VARCHAR2(1);

  BEGIN

    l_assoc_total      := 0;
    l_amt_flag         := 'N';

    FOR i IN p_assoc_assets_tbl.FIRST .. p_assoc_assets_tbl.LAST LOOP
      IF p_assoc_assets_tbl.EXISTS(i) THEN
        IF p_assoc_assets_tbl(i).amount IS NOT NULL THEN
          l_amt_flag       := 'Y';
          l_assoc_total    := l_assoc_total + p_assoc_assets_tbl(i).amount;
        END IF;
        IF (p_assoc_assets_tbl(i).amount IS NULL) AND l_amt_flag = 'Y' THEN
          OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LINKASSET_NULL_FOUND');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END LOOP;

    IF l_amt_flag = 'Y' AND l_assoc_total <> p_service_amount THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LINKASSET_AMT_MISMATCH',
                           p_token1       => 'LINE_COST',
                           p_token1_value => p_service_amount,
                           p_token2       => 'ASSOC_TOTAL',
                           p_token2_value => l_assoc_total);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_amt_flag = 'Y' THEN
      x_derive_assoc_amt := 'N';
    ELSE
      x_derive_assoc_amt := 'Y';
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_link_assets;


  ---------------------------------------
  -- PROCEDURE process_link_asset_amounts
  ---------------------------------------
  PROCEDURE process_link_asset_amounts (
    p_quote_id			 IN  NUMBER
   ,p_currency_code      IN  VARCHAR2
   ,p_service_amount     IN  NUMBER
   ,p_link_asset_tbl     IN  OUT NOCOPY line_relation_tbl_type
   ,p_derive_assoc_amt   IN  VARCHAR2
   ,p_override_pricing_type  IN  VARCHAR2 DEFAULT 'N'
   ,x_return_status      OUT NOCOPY VARCHAR2
   ,x_msg_count          OUT NOCOPY NUMBER
   ,x_msg_data           OUT NOCOPY VARCHAR2
   ) IS

    l_program_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'process_link_asset_amounts';

    l_link_asset_tbl            line_relation_tbl_type;

    l_line_amount               NUMBER;
    l_asset_oec                 NUMBER;
    l_oec_total                 NUMBER;
    l_assoc_amount              NUMBER;
    l_assoc_total               NUMBER;
    l_currency_code             VARCHAR2(15);
    lv_parent_object_code       VARCHAR2(30);
    l_compare_amt               NUMBER;
    l_diff                      NUMBER;
    l_adj_rec                   BINARY_INTEGER;
    lx_return_status            VARCHAR2(1);
    lv_pricing_method	   		OKL_LEASE_QUOTES_B.PRICING_METHOD%TYPE;

  BEGIN

    l_link_asset_tbl  := p_link_asset_tbl;
    l_line_amount     := p_service_amount;

    SELECT PRICING_METHOD
    INTO lv_pricing_method
    FROM OKL_LEASE_QUOTES_B
    WHERE ID = p_quote_id;

    -- Service Asset amount will be null in case of 'Solve for Financed Amount' pricing
    -- method .. the values will be populated after the Pricing call is made
    IF (lv_pricing_method = 'SF' AND p_override_pricing_type = 'N') THEN
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP
        IF l_link_asset_tbl.EXISTS(i) THEN
          l_link_asset_tbl(i).amount := null;
        END IF;
      END LOOP;

	  p_link_asset_tbl := l_link_asset_tbl;
	  RETURN;
    END IF;

    ------------------------------------------------------------------
    -- 1. Loop through to get OEC total of all assets being associated
    ------------------------------------------------------------------
    FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

      IF l_link_asset_tbl.EXISTS(i) THEN

        SELECT NVL(OEC, 0)
        INTO   l_asset_oec
        FROM   okl_assets_b
        WHERE  id = l_link_asset_tbl(i).source_line_id;

        l_oec_total := l_oec_total + l_asset_oec;

      END IF;

    END LOOP;

    ----------------------------------------------------------------------------
    -- 2. Loop through to determine associated amounts and round off the amounts
    ----------------------------------------------------------------------------
    FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

      IF l_link_asset_tbl.EXISTS(i) THEN

        IF p_derive_assoc_amt = 'N' THEN

          l_assoc_amount := l_link_asset_tbl(i).amount;

        ELSIF l_oec_total = 0 THEN

          l_assoc_amount := l_line_amount / l_link_asset_tbl.COUNT;

        ELSE

          SELECT NVL(OEC, 0)
          INTO   l_asset_oec
          FROM   okl_assets_b
          WHERE  id = l_link_asset_tbl(i).source_line_id;

          IF l_link_asset_tbl.COUNT = 1 THEN

            l_assoc_amount := l_line_amount;

          ELSE

            l_assoc_amount := l_line_amount * l_asset_oec / l_oec_total;

          END IF;
        END IF;

        l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                           p_currency_code => p_currency_code);

        l_assoc_total := l_assoc_total + l_assoc_amount;


        l_link_asset_tbl(i).amount := l_assoc_amount;

      END IF;

    END LOOP;

    ----------------------------------------------------------------------------------------------------
    -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
    ----------------------------------------------------------------------------------------------------
    IF l_assoc_total <> l_line_amount THEN

      l_diff := ABS(l_assoc_total - l_line_amount);

      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP

        IF l_link_asset_tbl.EXISTS(i) THEN

          -- if the total split amount is less than line amount add the difference amount to the
          -- asset with less amount and if the total split amount is greater than the line amount
          -- than subtract the difference amount from the asset with highest amount

          IF i = l_link_asset_tbl.FIRST THEN

            l_adj_rec     := i;
            l_compare_amt := l_link_asset_tbl(i).amount;

          ELSIF (l_assoc_total < l_line_amount) AND (l_link_asset_tbl(i).amount <= l_compare_amt) OR
                (l_assoc_total > l_line_amount) AND (l_link_asset_tbl(i).amount >= l_compare_amt) THEN

              l_adj_rec     := i;
              l_compare_amt := l_link_asset_tbl(i).amount;

          END IF;

        END IF;

      END LOOP;

      IF l_assoc_total < l_line_amount THEN

        l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount + l_diff;

      ELSE

        l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount - l_diff;

      END IF;

    END IF;

    p_link_asset_tbl := l_link_asset_tbl;
    x_return_status  := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END process_link_asset_amounts;


  -------------------------------------
  -- PROCEDURE get_deleted_assoc_assets
  -------------------------------------
  PROCEDURE get_deleted_assoc_assets (p_service_id              IN  NUMBER,
                                      p_assoc_asset_tbl         IN  line_relation_tbl_type,
                                      x_deleted_assoc_asset_tbl OUT NOCOPY okl_lre_pvt.lrev_tbl_type,
                                      x_return_status           OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_deleted_assoc_assets';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR c_db_assoc_assets IS
    SELECT id
    FROM   okl_line_relationships_b
    WHERE  related_line_type = 'SERVICE'
    AND    related_line_id = p_service_id;

    l_assoc_asset_tbl      okl_lre_pvt.lrev_tbl_type;
    l_delete_flag          VARCHAR2(1);
    i                      BINARY_INTEGER := 0;

  BEGIN
    IF (p_assoc_asset_tbl.COUNT > 0) THEN
      FOR l_db_assoc_assets IN c_db_assoc_assets LOOP
        l_delete_flag := 'Y';
        FOR j IN p_assoc_asset_tbl.FIRST .. p_assoc_asset_tbl.LAST LOOP
          IF p_assoc_asset_tbl.EXISTS(j) THEN
            IF l_db_assoc_assets.id = p_assoc_asset_tbl(j).id THEN
              l_delete_flag := 'N';
            END IF;
          END IF;
        END LOOP;

        IF l_delete_flag = 'Y' THEN
          l_assoc_asset_tbl(i).id := l_db_assoc_assets.id;
          i := i + 1;
        END IF;
      END LOOP;
    ELSE
      FOR l_db_assoc_assets IN c_db_assoc_assets LOOP
        l_assoc_asset_tbl(i).id := l_db_assoc_assets.id;
        i := i + 1;
      END LOOP;
    END IF;

    x_deleted_assoc_asset_tbl := l_assoc_asset_tbl;
    x_return_status           := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_deleted_assoc_assets;


  -------------------------------------
  -- PROCEDURE create_line_associations
  -------------------------------------
  PROCEDURE create_line_associations (
     p_service_id              IN  NUMBER
    ,p_assoc_assets_tbl        IN  line_relation_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_line_associations';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_assoc_assets_tbl   okl_lre_pvt.lrev_tbl_type;
    lx_assoc_assets_tbl  okl_lre_pvt.lrev_tbl_type;

    l_line_relation_tbl  line_relation_tbl_type;

  BEGIN

    l_line_relation_tbl := p_assoc_assets_tbl;

    FOR i IN l_line_relation_tbl.FIRST .. l_line_relation_tbl.LAST LOOP
      IF l_line_relation_tbl.EXISTS(i) THEN
        l_assoc_assets_tbl(i).related_line_id   := p_service_id;
        l_assoc_assets_tbl(i).related_line_type := l_line_relation_tbl(i).related_line_type;
        l_assoc_assets_tbl(i).source_line_type  := l_line_relation_tbl(i).source_line_type;
        l_assoc_assets_tbl(i).source_line_id    := l_line_relation_tbl(i).source_line_id;
        l_assoc_assets_tbl(i).amount            := l_line_relation_tbl(i).amount;
        l_assoc_assets_tbl(i).short_description := l_line_relation_tbl(i).short_description;
        l_assoc_assets_tbl(i).description       := l_line_relation_tbl(i).description;
        l_assoc_assets_tbl(i).comments          := l_line_relation_tbl(i).comments;
      END IF;
    END LOOP;

    okl_lre_pvt.insert_row (
      p_api_version   => G_API_VERSION
     ,p_init_msg_list => G_FALSE
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_lrev_tbl      => l_assoc_assets_tbl
     ,x_lrev_tbl      => lx_assoc_assets_tbl
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_line_associations;


  -------------------------------------
  -- PROCEDURE update_line_associations
  -------------------------------------
  PROCEDURE update_line_associations (
     p_service_id                  IN  NUMBER
    ,p_assoc_assets_tbl        IN  line_relation_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_line_associations';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_assoc_create_tbl          okl_lre_pvt.lrev_tbl_type;
    l_assoc_update_tbl          okl_lre_pvt.lrev_tbl_type;
    lx_assoc_assets_tbl         okl_lre_pvt.lrev_tbl_type;

    l_line_relation_tbl         line_relation_tbl_type;
    l_deleted_assoc_assets_tbl  okl_lre_pvt.lrev_tbl_type;

  BEGIN

    l_line_relation_tbl := p_assoc_assets_tbl;

    get_deleted_assoc_assets (
      p_service_id              => p_service_id
     ,p_assoc_asset_tbl         => l_line_relation_tbl
     ,x_deleted_assoc_asset_tbl => l_deleted_assoc_assets_tbl
     ,x_return_status           => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_deleted_assoc_assets_tbl.COUNT > 0 THEN
      okl_lre_pvt.delete_row (
                              p_api_version   => G_API_VERSION
                             ,p_init_msg_list => G_FALSE
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_lrev_tbl      => l_deleted_assoc_assets_tbl );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF l_line_relation_tbl.COUNT > 0 THEN

      FOR i IN l_line_relation_tbl.FIRST .. l_line_relation_tbl.LAST LOOP

        IF l_line_relation_tbl.EXISTS(i) THEN

          IF UPPER(l_line_relation_tbl(i).record_mode) = 'UPDATE' THEN

            l_assoc_update_tbl(i).id                    := l_line_relation_tbl(i).id;
            l_assoc_update_tbl(i).object_version_number := l_line_relation_tbl(i).object_version_number;
            l_assoc_update_tbl(i).related_line_id       := p_service_id;
            l_assoc_update_tbl(i).related_line_type     := l_line_relation_tbl(i).related_line_type;
            l_assoc_update_tbl(i).source_line_type      := l_line_relation_tbl(i).source_line_type;
            l_assoc_update_tbl(i).source_line_id        := l_line_relation_tbl(i).source_line_id;
            l_assoc_update_tbl(i).amount                := l_line_relation_tbl(i).amount;

          ELSIF UPPER(l_line_relation_tbl(i).record_mode) = 'CREATE' THEN

            l_assoc_create_tbl(i).related_line_id   := p_service_id;
            l_assoc_create_tbl(i).related_line_type := l_line_relation_tbl(i).related_line_type;
            l_assoc_create_tbl(i).source_line_type  := l_line_relation_tbl(i).source_line_type;
            l_assoc_create_tbl(i).source_line_id    := l_line_relation_tbl(i).source_line_id;
            l_assoc_create_tbl(i).amount            := l_line_relation_tbl(i).amount;

          END IF;

        END IF;

      END LOOP;

    END IF;

    IF l_assoc_update_tbl.COUNT > 0 THEN

      okl_lre_pvt.update_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_lrev_tbl      => l_assoc_update_tbl
       ,x_lrev_tbl      => lx_assoc_assets_tbl
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF l_assoc_create_tbl.COUNT > 0 THEN

      okl_lre_pvt.insert_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_lrev_tbl      => l_assoc_create_tbl
       ,x_lrev_tbl      => lx_assoc_assets_tbl
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_line_associations;


  -------------------------------
  -- PROCEDURE get_lrship_tbl
  -------------------------------
  PROCEDURE get_lrship_tbl (p_source_service_id           IN  NUMBER
  						   ,p_target_service_id			  IN  NUMBER
						   ,x_lrship_tbl              OUT NOCOPY lr_tbl_type
						   ,x_return_status           OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_lrship_tbl';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    i                      BINARY_INTEGER := 0;

    CURSOR c_db_lrships IS
      SELECT
         attribute_category
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
        ,source_line_type
        ,source_line_id
        ,related_line_type
        ,related_line_id
        ,amount
        ,short_description
        ,description
        ,comments
      from okl_line_relationships_v
      where source_line_type = 'ASSET'
  	  and related_line_id = p_source_service_id;

  BEGIN
    FOR l_db_lrships IN c_db_lrships LOOP
      x_lrship_tbl(i).attribute_category := l_db_lrships.attribute_category;
      x_lrship_tbl(i).attribute1 := l_db_lrships.attribute1;
      x_lrship_tbl(i).attribute2 := l_db_lrships.attribute2;
      x_lrship_tbl(i).attribute3 := l_db_lrships.attribute3;
      x_lrship_tbl(i).attribute4 := l_db_lrships.attribute4;
      x_lrship_tbl(i).attribute5 := l_db_lrships.attribute5;
      x_lrship_tbl(i).attribute6 := l_db_lrships.attribute6;
      x_lrship_tbl(i).attribute7 := l_db_lrships.attribute7;
      x_lrship_tbl(i).attribute8 := l_db_lrships.attribute8;
      x_lrship_tbl(i).attribute9 := l_db_lrships.attribute9;
      x_lrship_tbl(i).attribute10 := l_db_lrships.attribute10;
      x_lrship_tbl(i).attribute11 := l_db_lrships.attribute11;
      x_lrship_tbl(i).attribute12 := l_db_lrships.attribute12;
      x_lrship_tbl(i).attribute13 := l_db_lrships.attribute13;
      x_lrship_tbl(i).attribute14 := l_db_lrships.attribute14;
      x_lrship_tbl(i).attribute15 := l_db_lrships.attribute15;
      x_lrship_tbl(i).source_line_type := l_db_lrships.source_line_type;
      x_lrship_tbl(i).source_line_id  := l_db_lrships.source_line_id ;
      x_lrship_tbl(i).related_line_type := l_db_lrships.related_line_type;
      x_lrship_tbl(i).related_line_id := p_target_service_id;
      x_lrship_tbl(i).amount := l_db_lrships.amount;
      x_lrship_tbl(i).short_description := l_db_lrships.short_description;
      x_lrship_tbl(i).description := l_db_lrships.description;
      x_lrship_tbl(i).comments := l_db_lrships.comments;
      i := i + 1;
    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_lrship_tbl;

  -----------------------------------
  -- PROCEDURE copy_line_associations
  -----------------------------------
  PROCEDURE copy_line_associations( p_source_service_id   IN NUMBER,
  									p_target_service_id   IN NUMBER,
				            		x_return_status   OUT NOCOPY VARCHAR2,
					        		x_msg_count       OUT NOCOPY VARCHAR2,
					        		x_msg_data       OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'copy_line_associations';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lrship_tbl	lr_tbl_type;
    lx_lrship_tbl	lr_tbl_type;


   --05-Nov-2009 sechawla 9004863
 /*
  CURSOR c_get_new_asset_id (p_source_asset_id IN NUMBER) IS
  SELECT id
  FROM OKL_ASSETS_B
  WHERE ORIG_ASSET_ID = p_source_asset_id;
  */
  --05-Nov-2009 sechawla 9004863 : Modified the cursor to get asset id based on the new lease quote
  CURSOR c_get_new_asset_id (p_source_asset_id IN NUMBER) IS
  SELECT AST.id
    FROM OKL_ASSETS_B AST,
         OKL_SERVICES_B SRV
   WHERE SRV.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND SRV.PARENT_OBJECT_ID = AST.PARENT_OBJECT_ID
     AND SRV.ID = p_target_service_id
     AND AST.ORIG_ASSET_ID = p_source_asset_id;


  BEGIN
	-- Get line relationships table
    get_lrship_tbl (p_source_service_id    => p_source_service_id,
    				p_target_service_id    => p_target_service_id,
  					x_lrship_tbl       => l_lrship_tbl,
					x_return_status    => x_return_status);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set the original asset id for the records
    IF (l_lrship_tbl.COUNT > 0) THEN
      FOR i IN l_lrship_tbl.FIRST .. l_lrship_tbl.LAST LOOP
        IF l_lrship_tbl.EXISTS(i) THEN
          OPEN c_get_new_asset_id(p_source_asset_id	 => l_lrship_tbl(i).source_line_id);
          FETCH c_get_new_asset_id INTO l_lrship_tbl(i).source_line_id;
    	  CLOSE c_get_new_asset_id;
        END IF;
      END LOOP;

      okl_lre_pvt.insert_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_lrev_tbl      => l_lrship_tbl
       ,x_lrev_tbl      => lx_lrship_tbl );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END copy_line_associations;


  --------------------------
  -- PROCEDURE create_header
  --------------------------
  PROCEDURE create_header (
    p_service_rec             IN  okl_svc_pvt.svcv_rec_type
   ,x_service_id              OUT NOCOPY NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_header';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    lx_service_rec         okl_svc_pvt.svcv_rec_type;

  BEGIN

    okl_svc_pvt.insert_row (
      p_api_version    => G_API_VERSION
     ,p_init_msg_list  => G_FALSE
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_svcv_rec       => p_service_rec
     ,x_svcv_rec       => lx_service_rec
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_service_id := lx_service_rec.id;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_header;


  --------------------------
  -- PROCEDURE update_header
  --------------------------
  PROCEDURE update_header (
    p_service_rec             IN  okl_svc_pvt.svcv_rec_type
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_header';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    lx_service_rec         okl_svc_pvt.svcv_rec_type;

  BEGIN

    okl_svc_pvt.update_row (
      p_api_version    => G_API_VERSION
     ,p_init_msg_list  => G_FALSE
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_svcv_rec       => p_service_rec
     ,x_svcv_rec       => lx_service_rec
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_header;


  ---------------------------
  -- PROCEDURE create_payment
  ---------------------------
  PROCEDURE create_payment (
     p_service_id              IN  NUMBER
    ,p_payment_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_payment_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_payment';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_payment_header_rec   okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    l_payment_level_tbl    okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

  BEGIN

    l_payment_header_rec                    := p_payment_header_rec;
    l_payment_header_rec.parent_object_id   := p_service_id;
    l_payment_header_rec.parent_object_code := 'QUOTED_SERVICE';
    l_payment_level_tbl                     := p_payment_level_tbl;

    okl_lease_quote_cashflow_pvt.create_cashflow (
      p_api_version          => G_API_VERSION
     ,p_init_msg_list        => G_FALSE
     ,p_transaction_control  => G_FALSE
     ,p_cashflow_header_rec  => l_payment_header_rec
     ,p_cashflow_level_tbl   => l_payment_level_tbl
     ,x_return_status        => x_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_payment;


  ---------------------------
  -- PROCEDURE update_payment
  ---------------------------
  PROCEDURE update_payment (
     p_service_id                  IN  NUMBER
    ,p_payment_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_payment_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_payment';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_payment_header_rec   okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    l_payment_level_tbl    okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

  BEGIN

    l_payment_header_rec := p_payment_header_rec;
    l_payment_level_tbl  := p_payment_level_tbl;

    okl_lease_quote_cashflow_pvt.update_cashflow (
      p_api_version          => G_API_VERSION
     ,p_init_msg_list        => G_FALSE
     ,p_transaction_control  => G_FALSE
     ,p_cashflow_header_rec  => l_payment_header_rec
     ,p_cashflow_level_tbl   => l_payment_level_tbl
     ,x_return_status        => x_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_payment;


  ---------------------------
  -- PROCEDURE create_expense
  ---------------------------
  PROCEDURE create_expense (
     p_service_id              IN  NUMBER
    ,p_expense_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_expense_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_expense';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_expense_header_rec   okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    l_expense_level_tbl    okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

  BEGIN

    l_expense_header_rec                  := p_expense_header_rec;
    l_expense_header_rec.parent_object_id := p_service_id;
    l_expense_level_tbl                   := p_expense_level_tbl;

    okl_lease_quote_cashflow_pvt.create_cashflow (
      p_api_version          => G_API_VERSION
     ,p_init_msg_list        => G_FALSE
     ,p_transaction_control  => G_FALSE
     ,p_cashflow_header_rec  => l_expense_header_rec
     ,p_cashflow_level_tbl   => l_expense_level_tbl
     ,x_return_status        => x_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_expense;


  ---------------------------
  -- PROCEDURE update_expense
  ---------------------------
  PROCEDURE update_expense (
     p_service_id              IN  NUMBER
    ,p_expense_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_expense_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_expense';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_expense_header_rec   okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    l_expense_level_tbl    okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

  BEGIN

    l_expense_header_rec := p_expense_header_rec;
    l_expense_level_tbl  := p_expense_level_tbl;

    okl_lease_quote_cashflow_pvt.update_cashflow (
      p_api_version          => G_API_VERSION
     ,p_init_msg_list        => G_FALSE
     ,p_transaction_control  => G_FALSE
     ,p_cashflow_header_rec  => l_expense_header_rec
     ,p_cashflow_level_tbl   => l_expense_level_tbl
     ,x_return_status        => x_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_expense;


  ---------------------------
  -- PROCEDURE create_service
  ---------------------------
  PROCEDURE create_service (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_service_rec             IN  okl_svc_pvt.svcv_rec_type
    ,p_assoc_asset_tbl         IN  line_relation_tbl_type
    ,p_payment_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_payment_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,p_expense_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_expense_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_service_id              OUT NOCOPY NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_service';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_line_relation_tbl    line_relation_tbl_type;

    l_periodic_amount      NUMBER;
    l_service_amount       NUMBER;
    l_currency_code        VARCHAR2(15);

    l_return_status        VARCHAR2(1);
    l_derive_assoc_amt     VARCHAR2(1);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    get_currency_code (
     p_parent_object_id  => p_service_rec.parent_object_id
    ,x_currency_code     => l_currency_code
    ,x_return_status     => l_return_status
    );

    IF p_expense_level_tbl(p_expense_level_tbl.FIRST).periods <>
       TRUNC (p_expense_level_tbl(p_expense_level_tbl.FIRST).periods) THEN

      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_RECEXP_PERIODS_INVALID');
      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    l_periodic_amount :=
      okl_accounting_util.round_amount( p_amount        => p_expense_level_tbl(p_expense_level_tbl.FIRST).periodic_amount
                                       ,p_currency_code => l_currency_code);

    l_service_amount := l_periodic_amount * p_expense_level_tbl(p_expense_level_tbl.FIRST).periods;

    validate_header (
      p_service_rec   => p_service_rec
     ,x_return_status => l_return_status
     );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_assoc_asset_tbl.COUNT > 0 THEN

      l_line_relation_tbl := p_assoc_asset_tbl;

      validate_link_assets (
        p_service_amount   => l_service_amount
       ,p_assoc_assets_tbl => l_line_relation_tbl
       ,x_derive_assoc_amt => l_derive_assoc_amt
       ,x_return_status    => l_return_status
       );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_derive_assoc_amt = 'Y') THEN

        process_link_asset_amounts (
          p_quote_id           => p_service_rec.parent_object_id
         ,p_currency_code      => l_currency_code
         ,p_service_amount     => l_service_amount
         ,p_link_asset_tbl     => l_line_relation_tbl
         ,p_derive_assoc_amt   => 'Y'
         ,x_return_status      => l_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
        );

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    END IF;

    create_header (
      p_service_rec   => p_service_rec
     ,x_service_id    => x_service_id
     ,x_return_status => l_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_line_relation_tbl.COUNT > 0 THEN

      create_line_associations (
        p_service_id         => x_service_id
       ,p_assoc_assets_tbl   => l_line_relation_tbl
       ,x_return_status      => l_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF (p_payment_level_tbl.COUNT > 0 AND p_payment_header_rec.stream_type_id IS NULL) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_SALES_NO_PAYMENTHEAD');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (p_payment_header_rec.stream_type_id IS NOT NULL AND p_payment_level_tbl.COUNT = 0 ) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_SALES_NO_PAYMENTLINES');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_payment_level_tbl.COUNT > 0 THEN

      create_payment (
        p_service_id          => x_service_id
       ,p_payment_header_rec  => p_payment_header_rec
       ,p_payment_level_tbl   => p_payment_level_tbl
       ,x_return_status       => l_return_status
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
       );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    create_expense (
      p_service_id          => x_service_id
     ,p_expense_header_rec  => p_expense_header_rec
     ,p_expense_level_tbl   => p_expense_level_tbl
     ,x_return_status       => l_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_service;

  -----------------------------------
  -- PROCEDURE get_line_relations_tbl
  -----------------------------------
  PROCEDURE get_line_relations_tbl (
    p_service_id               IN  NUMBER
   ,x_line_relation_tbl        OUT NOCOPY line_relation_tbl_type
   ,x_return_status            OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_line_relations_tbl';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    i                      BINARY_INTEGER := 0;

    CURSOR c_db_line_relations IS
      SELECT
      	 id
        ,object_version_number
        ,source_line_type
		,source_line_id
		,related_line_type
		,related_line_id
		,amount
        ,short_description
        ,description
        ,comments
      FROM okl_line_relationships_v
      WHERE related_line_id = p_service_id;
  BEGIN
    FOR l_db_line_relations IN c_db_line_relations LOOP
      x_line_relation_tbl(i).id := l_db_line_relations.id;
      x_line_relation_tbl(i).object_version_number := l_db_line_relations.object_version_number;
      x_line_relation_tbl(i).source_line_type := l_db_line_relations.source_line_type;
      x_line_relation_tbl(i).source_line_id := l_db_line_relations.source_line_id;
      x_line_relation_tbl(i).related_line_type := l_db_line_relations.related_line_type;
      x_line_relation_tbl(i).related_line_id := l_db_line_relations.related_line_id;
      x_line_relation_tbl(i).amount := l_db_line_relations.amount;
      x_line_relation_tbl(i).short_description := l_db_line_relations.short_description;
      x_line_relation_tbl(i).description := l_db_line_relations.description;
      x_line_relation_tbl(i).comments := l_db_line_relations.comments;
      i := i + 1;
    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_line_relations_tbl;

  ----------------------------------
  -- PROCEDURE update_service_assets
  ----------------------------------
  PROCEDURE update_service_assets (
    p_api_version             IN  NUMBER
   ,p_init_msg_list           IN  VARCHAR2
   ,p_transaction_control     IN  VARCHAR2
   ,p_quote_id                IN  NUMBER
   ,p_service_id              IN  NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2 ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_service_assets';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_copy_relation_tbl   line_relation_tbl_type;

    l_line_relation_tbl   lr_tbl_type;
    lx_line_relation_tbl  lr_tbl_type;

    ln_service_amount		NUMBER;
    lv_currency_code		VARCHAR2(30);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Fetch Line Relationships info
    get_line_relations_tbl (p_service_id        => p_service_id
   	             	       ,x_line_relation_tbl => l_copy_relation_tbl
					       ,x_return_status     => x_return_status);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	SELECT LVL.AMOUNT * LVL.NUMBER_OF_PERIODS
	INTO ln_service_amount
	FROM OKL_CASH_FLOW_OBJECTS CFO,
    	 OKL_CASH_FLOWS CFL,
	     OKL_CASH_FLOW_LEVELS LVL
	WHERE CFO.SOURCE_ID =    p_service_id
	AND CFO.OTY_CODE = 'QUOTED_SERVICE'
	AND CFO.SOURCE_TABLE = 'OKL_SERVICES_B'
	AND CFL.CFT_CODE = 'OUTFLOW_SCHEDULE'
	AND CFL.CFO_ID = CFO.ID
	AND LVL.CAF_ID = CFL.ID;

    get_currency_code ( p_parent_object_id   => p_quote_id
					    ,x_currency_code     => lv_currency_code
					    ,x_return_status     => x_return_status );

    IF (l_copy_relation_tbl.COUNT > 0) THEN
      process_link_asset_amounts (
          p_quote_id           => p_quote_id
         ,p_currency_code      => lv_currency_code
         ,p_service_amount     => ln_service_amount
         ,p_link_asset_tbl     => l_copy_relation_tbl
         ,p_derive_assoc_amt   => 'Y'
         ,p_override_pricing_type  =>  'Y'
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      FOR i IN l_copy_relation_tbl.FIRST .. l_copy_relation_tbl.LAST LOOP
        IF l_copy_relation_tbl.EXISTS(i) THEN
          l_line_relation_tbl(i).id := l_copy_relation_tbl(i).id;
          l_line_relation_tbl(i).object_version_number := l_copy_relation_tbl(i).object_version_number;
          l_line_relation_tbl(i).source_line_type := l_copy_relation_tbl(i).source_line_type;
          l_line_relation_tbl(i).source_line_id := l_copy_relation_tbl(i).source_line_id;
          l_line_relation_tbl(i).related_line_type := l_copy_relation_tbl(i).related_line_type;
          l_line_relation_tbl(i).related_line_id := l_copy_relation_tbl(i).related_line_id;
          l_line_relation_tbl(i).amount := l_copy_relation_tbl(i).amount;
        END IF;
      END LOOP;

      IF (l_line_relation_tbl.COUNT > 0) THEN
        okl_lre_pvt.update_row (
         	 p_api_version    => G_API_VERSION
	         ,p_init_msg_list => G_FALSE
    	     ,x_return_status => x_return_status
        	 ,x_msg_count     => x_msg_count
	         ,x_msg_data      => x_msg_data
    	     ,p_lrev_tbl      => l_line_relation_tbl
        	 ,x_lrev_tbl      => lx_line_relation_tbl);

        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_service_assets ;

  ---------------------------
  -- PROCEDURE update_service
  ---------------------------
  PROCEDURE update_service (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_service_rec             IN  okl_svc_pvt.svcv_rec_type
    ,p_assoc_asset_tbl         IN  line_relation_tbl_type
    ,p_payment_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_payment_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,p_expense_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_expense_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_service';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_line_relation_tbl    line_relation_tbl_type;

    l_periodic_amount      NUMBER;
    l_service_amount       NUMBER;
    l_currency_code        VARCHAR2(15);

    l_return_status        VARCHAR2(1);
    l_derive_assoc_amt     VARCHAR2(1);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    get_currency_code (
     p_parent_object_id  => p_service_rec.parent_object_id
    ,x_currency_code     => l_currency_code
    ,x_return_status     => l_return_status
    );

    IF p_expense_level_tbl(p_expense_level_tbl.FIRST).periods <>
       TRUNC (p_expense_level_tbl(p_expense_level_tbl.FIRST).periods) THEN

      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_RECEXP_PERIODS_INVALID');
      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    l_periodic_amount :=
      okl_accounting_util.round_amount( p_amount        => p_expense_level_tbl(p_expense_level_tbl.FIRST).periodic_amount
                                       ,p_currency_code => l_currency_code);

    l_service_amount := l_periodic_amount * p_expense_level_tbl(p_expense_level_tbl.FIRST).periods;

    validate_header (
      p_service_rec   => p_service_rec
     ,x_return_status => l_return_status
     );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_assoc_asset_tbl.COUNT > 0 THEN

      l_line_relation_tbl := p_assoc_asset_tbl;

      validate_link_assets (
        p_service_amount   => l_service_amount
       ,p_assoc_assets_tbl => l_line_relation_tbl
       ,x_derive_assoc_amt => l_derive_assoc_amt
       ,x_return_status    => l_return_status
       );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_derive_assoc_amt = 'Y') THEN

        process_link_asset_amounts (
          p_quote_id           => p_service_rec.parent_object_id
         ,p_currency_code      => l_currency_code
         ,p_service_amount     => l_service_amount
         ,p_link_asset_tbl     => l_line_relation_tbl
         ,p_derive_assoc_amt   => 'Y'
         ,x_return_status      => l_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
        );

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    END IF;

    update_header (
      p_service_rec   => p_service_rec
     ,x_return_status => l_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_line_relation_tbl.COUNT > 0 THEN

      update_line_associations (
        p_service_id         => p_service_rec.id
       ,p_assoc_assets_tbl   => l_line_relation_tbl
       ,x_return_status      => l_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF (p_payment_level_tbl.COUNT > 0 AND p_payment_header_rec.stream_type_id IS NULL) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_SALES_NO_PAYMENTHEAD');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (p_payment_header_rec.stream_type_id IS NOT NULL AND p_payment_level_tbl.COUNT = 0 ) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_SALES_NO_PAYMENTLINES');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_payment_level_tbl.COUNT > 0 THEN

      update_payment (
        p_service_id          => p_service_rec.id
       ,p_payment_header_rec  => p_payment_header_rec
       ,p_payment_level_tbl   => p_payment_level_tbl
       ,x_return_status       => l_return_status
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
       );

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    update_expense (
      p_service_id          => p_service_rec.id
     ,p_expense_header_rec  => p_expense_header_rec
     ,p_expense_level_tbl   => p_expense_level_tbl
     ,x_return_status       => l_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_service;


  --------------------------
  -- PROCEDURE duplicate_service
  --------------------------
  PROCEDURE duplicate_service (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_service_id       IN  NUMBER
    ,p_service_rec             IN  okl_svc_pvt.svcv_rec_type
    ,p_assoc_asset_tbl         IN  line_relation_tbl_type
    ,p_payment_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_payment_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,p_expense_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_expense_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_service_id              OUT NOCOPY NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'duplicate_service';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    create_service (
      p_api_version         => G_API_VERSION
     ,p_init_msg_list       => G_FALSE
     ,p_transaction_control => G_FALSE
     ,p_service_rec         => p_service_rec
     ,p_assoc_asset_tbl     => p_assoc_asset_tbl
     ,p_payment_header_rec  => p_payment_header_rec
     ,p_payment_level_tbl   => p_payment_level_tbl
     ,p_expense_header_rec  => p_expense_header_rec
     ,p_expense_level_tbl   => p_expense_level_tbl
     ,x_service_id          => x_service_id
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END duplicate_service;


  --------------------------
  -- PROCEDURE duplicate_service
  --------------------------
  PROCEDURE duplicate_service (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_service_id       IN  NUMBER
    ,p_target_quote_id         IN  NUMBER
    ,x_service_id              OUT NOCOPY NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

      l_program_name         CONSTANT VARCHAR2(30) := 'duplicate_service2';
      l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

      l_service_rec              okl_svc_pvt.svcv_rec_type;
      lx_service_rec             okl_svc_pvt.svcv_rec_type;

      lb_copy_cashflow 			 BOOLEAN  := TRUE;
      lb_copy_lr		 	 	 BOOLEAN  := TRUE;
      ld_src_start_date			 DATE;
      ld_tgt_start_date			 DATE;
      ln_src_pdt_id				 NUMBER;
      ln_tgt_pdt_id				 NUMBER;
      ln_src_eot_id		   		 NUMBER;
      ln_tgt_eot_id		   		 NUMBER;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    get_service_rec (
      p_service_id        => p_source_service_id
     ,x_service_rec       => l_service_rec
     ,x_return_status     => x_return_status);

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_service_rec.parent_object_id := p_target_quote_id;

    create_header (
      p_service_rec       => l_service_rec
     ,x_service_id        => x_service_id
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Validation to check if the product and expected start date for source
    -- and target contracts are equal, if not cash flows are not copied.
    SELECT quote.expected_start_date,
           quote.product_id,
           quote.end_of_term_option_id
    INTO ld_src_start_date, ln_src_pdt_id, ln_src_eot_id
    FROM
           okl_services_b srv,
           okl_lease_quotes_b quote
    WHERE
       	 srv.id = p_source_service_id
     AND srv.parent_object_id = quote.id
     AND srv.parent_object_code = 'LEASEQUOTE';

    SELECT expected_start_date,
           product_id,
           end_of_term_option_id
    INTO ld_tgt_start_date, ln_tgt_pdt_id, ln_tgt_eot_id
    FROM
         okl_lease_quotes_b
    WHERE
       	 id = p_target_quote_id;

    IF ((ld_src_start_date <> ld_tgt_start_date) OR (ln_src_pdt_id <> ln_tgt_pdt_id)) THEN
      lb_copy_cashflow := FALSE;
    END IF;
    -- End

    IF (ln_src_eot_id <> ln_tgt_eot_id) THEN
      lb_copy_lr := FALSE;
    END IF;

    IF (lb_copy_cashflow) THEN
      copy_line_associations( p_source_service_id	  => p_source_service_id,
    					      p_target_service_id   => x_service_id,
				              x_return_status   => x_return_status,
					          x_msg_count       => x_msg_count,
					          x_msg_data        => x_msg_data );
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF (lb_copy_cashflow) THEN
      okl_lease_quote_cashflow_pvt.duplicate_cashflows (
      p_api_version          => G_API_VERSION
     ,p_init_msg_list        => G_FALSE
     ,p_transaction_control  => G_FALSE
     ,p_source_object_code   => 'QUOTED_SERVICE'
     ,p_source_object_id     => p_source_service_id
     ,p_target_object_id     => x_service_id
     ,p_quote_id             => p_target_quote_id
     ,x_return_status        => x_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END duplicate_service;


  -----------------------
  -- PROCEDURE delete_service
  -----------------------
  PROCEDURE delete_service (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_service_id              IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_service';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lrev_tbl             okl_lre_pvt.lrev_tbl_type;
    l_svcv_rec             okl_svc_pvt.svcv_rec_type;
    i                      BINARY_INTEGER;

    CURSOR c_sublines IS
      SELECT id
      FROM   okl_line_relationships_b
      WHERE  related_line_type = 'SERVICE'
      AND    related_line_id = p_service_id;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    i := 0;
    FOR l_subline IN c_sublines LOOP
      l_lrev_tbl(i).id := l_subline.id;
      i := i + 1;
    END LOOP;

    IF l_lrev_tbl.COUNT > 0 THEN

      okl_lre_pvt.delete_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_lrev_tbl      => l_lrev_tbl
       );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    okl_lease_quote_cashflow_pvt.delete_cashflows (
      p_api_version          => G_API_VERSION
     ,p_init_msg_list        => G_FALSE
     ,p_transaction_control  => G_FALSE
     ,p_source_object_code   => 'QUOTED_SERVICE'
     ,p_source_object_id     => p_service_id
     ,x_return_status        => x_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
    );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_svcv_rec.id := p_service_id;

    okl_svc_pvt.delete_row (
      p_api_version   => G_API_VERSION
     ,p_init_msg_list => G_FALSE
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_svcv_rec      => l_svcv_rec
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_service;

END OKL_LEASE_QUOTE_SERVICE_PVT;

/
