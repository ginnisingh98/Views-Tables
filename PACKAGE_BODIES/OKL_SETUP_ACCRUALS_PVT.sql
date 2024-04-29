--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_ACCRUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_ACCRUALS_PVT" AS
/* $Header: OKLRARUB.pls 120.3 2007/02/06 11:14:00 gkhuntet noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_ACCRUAL_GNRTNS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (p_agnv_rec IN agnv_rec_type,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_no_data_found OUT NOCOPY BOOLEAN,
                     x_agnv_rec OUT NOCOPY agnv_rec_type
  ) IS
    CURSOR okl_agnv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            LINE_NUMBER,
            VERSION,
            FROM_DATE,
                        ARO_CODE,
                        RIGHT_OPERAND_LITERAL,
                        ACRO_CODE,
                        NVL(ARLO_CODE, G_MISS_CHAR) ARLO_CODE,
                        NVL(LEFT_PARENTHESES, G_MISS_CHAR) LEFT_PARENTHESES,
                        NVL(RIGHT_PARENTHESES, G_MISS_CHAR) RIGHT_PARENTHESES,
            NVL(TO_DATE, G_MISS_DATE) TO_DATE,
            NVL(ORG_ID, G_MISS_NUM) ORG_ID,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN,G_MISS_NUM) LAST_UPDATE_LOGIN

     FROM OKL_ACCRUAL_GNRTNS
     WHERE id = p_id;

    l_okl_agnv_pk                  okl_agnv_pk_csr%ROWTYPE;
    l_agnv_rec                     agnv_rec_type;
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_agnv_pk_csr (p_agnv_rec.id);
    FETCH okl_agnv_pk_csr INTO
              l_agnv_rec.ID,
              l_agnv_rec.OBJECT_VERSION_NUMBER,
              l_agnv_rec.LINE_NUMBER,
              l_agnv_rec.VERSION,
              l_agnv_rec.FROM_DATE,
              l_agnv_rec.ARO_CODE,
              l_agnv_rec.RIGHT_OPERAND_LITERAL,
              l_agnv_rec.ACRO_CODE,
              l_agnv_rec.ARLO_CODE,
              l_agnv_rec.LEFT_PARENTHESES,
              l_agnv_rec.RIGHT_PARENTHESES,
              l_agnv_rec.TO_DATE,
              l_agnv_rec.ORG_ID,
              l_agnv_rec.CREATED_BY,
              l_agnv_rec.LAST_UPDATED_BY,
              l_agnv_rec.CREATION_DATE,
              l_agnv_rec.LAST_UPDATE_DATE,
              l_agnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_agnv_pk_csr%NOTFOUND;
    CLOSE okl_agnv_pk_csr;

    x_agnv_rec := l_agnv_rec;
    x_return_status := l_return_status;
  EXCEPTION
        WHEN OTHERS THEN

                -- store SQL error message on message stack
                OKL_API.SET_MESSAGE(p_app_name  =>      G_APP_NAME,
                                        p_msg_name      =>      G_UNEXPECTED_ERROR,
                                        p_token1        =>      G_SQLCODE_TOKEN,
                                        p_token1_value  =>      sqlcode,
                                        p_token2        =>      G_SQLERRM_TOKEN,
                                        p_token2_value  =>      sqlerrm);
                -- notify UNEXPECTED error for calling API.
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF (okl_agnv_pk_csr%ISOPEN) THEN
                  CLOSE okl_agnv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_changes_only for: OKL_ACCRUAL_GNRTNS_V
  -- To take care of the assumption that Everything except the Changed Fields
  -- have G_MISS values in them
  ---------------------------------------------------------------------------
  PROCEDURE get_changes_only (p_agnv_rec IN agnv_rec_type,
    p_db_rec                   IN agnv_rec_type,
    x_agnv_rec                 OUT NOCOPY agnv_rec_type )
  IS
    l_agnv_rec agnv_rec_type;
  BEGIN
        l_agnv_rec := p_agnv_rec;

        IF p_db_rec.LINE_NUMBER = p_agnv_rec.LINE_NUMBER THEN
                l_agnv_rec.LINE_NUMBER := G_MISS_NUM;
        END IF;

        IF p_db_rec.VERSION = p_agnv_rec.VERSION THEN
                l_agnv_rec.VERSION := G_MISS_CHAR;
        END IF;

        IF p_db_rec.ARO_CODE = p_agnv_rec.ARO_CODE THEN
                l_agnv_rec.ARO_CODE := G_MISS_CHAR;
        END IF;

        IF p_db_rec.ACRO_CODE = p_agnv_rec.ACRO_CODE THEN
                l_agnv_rec.ACRO_CODE := G_MISS_CHAR;
        END IF;

        IF p_db_rec.RIGHT_OPERAND_LITERAL = p_agnv_rec.RIGHT_OPERAND_LITERAL THEN
                l_agnv_rec.RIGHT_OPERAND_LITERAL := G_MISS_CHAR;
        END IF;

        IF p_db_rec.FROM_DATE = p_agnv_rec.FROM_DATE THEN
                l_agnv_rec.FROM_DATE := G_MISS_DATE;
        END IF;

        IF p_db_rec.TO_DATE IS NULL THEN
          IF p_agnv_rec.TO_DATE IS NULL THEN
            l_agnv_rec.TO_DATE := G_MISS_DATE;
          END IF;
        ELSIF p_db_rec.TO_DATE = p_agnv_rec.TO_DATE THEN
          l_agnv_rec.TO_DATE := G_MISS_DATE;
        END IF;

        IF p_db_rec.ARLO_CODE IS NULL THEN
          IF p_agnv_rec.ARLO_CODE IS NULL THEN
            l_agnv_rec.ARLO_CODE := G_MISS_CHAR;
          END IF;
        ELSIF p_db_rec.ARLO_CODE = p_agnv_rec.ARLO_CODE THEN
          l_agnv_rec.ARLO_CODE := G_MISS_CHAR;
        END IF;

        IF p_db_rec.LEFT_PARENTHESES IS NULL THEN
          IF p_agnv_rec.LEFT_PARENTHESES IS NULL THEN
            l_agnv_rec.LEFT_PARENTHESES := G_MISS_CHAR;
          END IF;
        ELSIF p_db_rec.LEFT_PARENTHESES = p_agnv_rec.LEFT_PARENTHESES THEN
          l_agnv_rec.LEFT_PARENTHESES := G_MISS_CHAR;
        END IF;

        IF p_db_rec.RIGHT_PARENTHESES IS NULL THEN
          IF p_agnv_rec.RIGHT_PARENTHESES IS NULL THEN
            l_agnv_rec.RIGHT_PARENTHESES := G_MISS_CHAR;
          END IF;
        ELSIF p_db_rec.RIGHT_PARENTHESES = p_agnv_rec.RIGHT_PARENTHESES THEN
          l_agnv_rec.RIGHT_PARENTHESES := G_MISS_CHAR;
        END IF;

        IF p_db_rec.ORG_ID IS NULL THEN
          IF p_agnv_rec.ORG_ID IS NULL THEN
            l_agnv_rec.ORG_ID := G_MISS_NUM;
          END IF;
        ELSIF p_db_rec.ORG_ID = p_agnv_rec.ORG_ID THEN
          l_agnv_rec.ORG_ID := G_MISS_NUM;
        END IF;

        x_agnv_rec := l_agnv_rec;
  END get_changes_only;



  ---------------------------------------------------------------------------
  -- PROCEDURE create_accrual_rules for: OKL_ACCRUAL_GNRTNS_V
  ---------------------------------------------------------------------------
  PROCEDURE create_accrual_rules(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_agnv_rec                     IN  agnv_rec_type,
                              x_agnv_rec                     OUT NOCOPY agnv_rec_type ) IS

    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_accrual_rules';
    l_no_data_found   BOOLEAN := TRUE;
        l_valid                   BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
        l_agnv_rec                agnv_rec_type;
        l_sysdate                 DATE := to_date(SYSDATE, 'DD-MM-RRRR');
        l_line_number           NUMBER := 1;
        l_tot_version     NUMBER :=1 ;
    CURSOR line_num_csr(p_version VARCHAR2) IS
        SELECT MAX(line_number)
        FROM OKL_ACCRUAL_GNRTNS
        WHERE ORG_ID = p_agnv_rec.ORG_ID AND version = p_version;

        /*TO FIND NO OF VERSION ON THE BASIS OF ID. */
        CURSOR ver_count_csr(p_orgId NUMBER) IS
        SELECT MAX(TO_NUMBER(VERSION))
        FROM OKL_ACCRUAL_GNRTNS
        WHERE ORG_ID = p_orgID;
  BEGIN
        l_agnv_rec := p_agnv_rec;

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name           => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version        => l_api_version,
                                              p_api_version        => p_api_version,
                                              p_api_type           => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /* validate aro_code */
        IF (l_agnv_rec.aro_code IS NULL OR l_agnv_rec.aro_code = G_MISS_CHAR) THEN
      OKL_API.SET_MESSAGE(p_app_name            => G_APP_NAME,
                                                  p_msg_name            => 'OKL_AGN_ARO_CODE_ERROR');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    /* validate on acro_code */
        IF (l_agnv_rec.acro_code IS NULL OR l_agnv_rec.acro_code = G_MISS_CHAR) THEN
      OKL_API.SET_MESSAGE(p_app_name            => G_APP_NAME,
                                                  p_msg_name            => 'OKL_AGN_ACRO_CODE_ERROR');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    /* validate on right operand literal */
        IF (l_agnv_rec.right_operand_literal IS NULL OR l_agnv_rec.right_operand_literal = G_MISS_CHAR) THEN
      OKL_API.SET_MESSAGE(p_app_name            => G_APP_NAME,
                                                  p_msg_name            => 'OKL_RIGHT_OPD_LITERAL_ERROR');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    /* Assign Start Date for the record */
        l_agnv_rec.from_date := l_sysdate;







       /* Validate Version for increment in case of update */
        IF l_agnv_rec.version IS NOT NULL THEN
          --IF l_agnv_rec.version <> '1' THEN
            l_agnv_rec.version := l_agnv_rec.version + 1;
        /* Line Number assignment -- sgiyer 03-05-02 */
            OPEN line_num_csr(l_agnv_rec.version);
            FETCH line_num_csr INTO l_line_number;
            IF l_line_number IS NOT NULL THEN
              l_agnv_rec.line_number := l_line_number + 1;
        END IF;
        CLOSE line_num_csr;
          --END IF;
        END IF;

        /* public api to insert accrual rules */
              OKL_ACCRUAL_RULES_PUB.insert_accrual_rules(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                               x_return_status   => l_return_status,
                                               x_msg_count       => x_msg_count,
                                               x_msg_data        => x_msg_data,
                                               p_agnv_rec        => l_agnv_rec,
                                               x_agnv_rec        => x_agnv_rec);

     IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                                                 x_msg_data       => x_msg_data);
        x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name   => l_api_name,
                   p_pkg_name   => G_PKG_NAME,
                   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
                   x_msg_count  => x_msg_count,
                   x_msg_data   => x_msg_data,
                   p_api_type   => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name   => l_api_name,
                 p_pkg_name   => G_PKG_NAME,
                 p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                 x_msg_count  => x_msg_count,
                 x_msg_data   => x_msg_data,
                 p_api_type   => '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name   => l_api_name,
                                                                                                   p_pkg_name   => G_PKG_NAME,
                                                                                                   p_exc_name   => 'OTHERS',
                                                                                                   x_msg_count  => x_msg_count,
                                                                                                   x_msg_data   => x_msg_data,
                                                                                                   p_api_type   => '_PVT');

  END create_accrual_rules;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_accrual_rules for: OKL_ACCRUAL_GNRTNS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_accrual_rules(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_agnv_rec                     IN  agnv_rec_type,
                              x_agnv_rec                     OUT NOCOPY agnv_rec_type
                              ) IS
    l_api_version               CONSTANT NUMBER := 1;
    l_api_name                  CONSTANT VARCHAR2(30)  := 'update_accrual_rules';
    l_no_data_found             BOOLEAN := TRUE;
        l_valid                                 BOOLEAN := TRUE;
        l_oldversion_enddate    DATE := to_date(SYSDATE, 'DD-MM-RRRR');
        l_sysdate                               DATE := to_date(SYSDATE, 'DD-MM-RRRR');
    l_db_agnv_rec               agnv_rec_type; /* database copy */
        l_upd_agnv_rec                  agnv_rec_type; /* input copy */
        l_agnv_rec                              agnv_rec_type := p_agnv_rec; /* latest with the retained changes */
        l_tmp_agnv_rec                  agnv_rec_type; /* for any other purposes */
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_action                                VARCHAR2(1);
        l_new_version                   VARCHAR2(100);
    l_attrib_tbl                okl_accounting_util.overlap_attrib_tbl_type;
        l_line_number           NUMBER := 1;

    CURSOR line_num_csr(p_version VARCHAR2 , p_orgID Number) IS
        SELECT MAX(line_number)
        FROM OKL_ACCRUAL_GNRTNS
        WHERE version = p_version and ORG_ID = p_orgID;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name           => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version        => l_api_version,
                                              p_api_version        => p_api_version,
                                              p_api_type           => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    /* fetch old details from the database */
    get_rec(p_agnv_rec => p_agnv_rec,
            x_return_status => l_return_status,
                x_no_data_found => l_no_data_found,
            x_agnv_rec => l_db_agnv_rec);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS OR
       l_no_data_found = TRUE THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


    /* retain the details that has been changed only */
    get_changes_only(p_agnv_rec => p_agnv_rec,
                     p_db_rec => l_db_agnv_rec,
                     x_agnv_rec => l_upd_agnv_rec);


           /* for old version */
           IF l_upd_agnv_rec.from_date <> G_MISS_DATE THEN
                  l_oldversion_enddate := l_upd_agnv_rec.from_date - 1;
           ELSE
         IF to_date(l_db_agnv_rec.from_date, 'DD-MM-RRRR') = l_sysdate THEN
                  l_oldversion_enddate := l_sysdate;
         ELSE
                  l_oldversion_enddate := l_sysdate - 1;
         END IF;
           END IF;

           l_agnv_rec := l_db_agnv_rec;
           l_agnv_rec.to_date := l_oldversion_enddate;

           /* public api to update provisions */
              OKL_ACCRUAL_RULES_PUB.update_accrual_rules(p_api_version     => l_api_version,
                                                         p_init_msg_list   => p_init_msg_list,
                                                         x_return_status   => l_return_status,
                                                         x_msg_count       => x_msg_count,
                                                         x_msg_data        => x_msg_data,
                                                         p_agnv_rec        => l_agnv_rec,
                                                         x_agnv_rec        => x_agnv_rec);

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

           /* for new version */
           /* create a temporary record with all relevant details from db and upd records */
       /* removed call to default_to_actuals sgiyer 02-06-02 */
           l_agnv_rec := p_agnv_rec;

/*         IF l_upd_agnv_rec.from_date = G_MISS_DATE THEN
                  l_agnv_rec.from_date := l_sysdate;
           END IF; */

       l_agnv_rec.from_date := l_sysdate;
       l_agnv_rec.to_date := G_MISS_DATE;
       l_agnv_rec.version := p_agnv_rec.version + 1;
           l_agnv_rec.id := G_MISS_NUM;

       /* Line Number assignment -- sgiyer 03-05-02 */
           OPEN line_num_csr(l_agnv_rec.version ,l_agnv_rec.ORG_ID);
           FETCH line_num_csr INTO l_line_number;
           IF l_line_number IS NULL THEN
             l_agnv_rec.line_number := 1;
           ELSE
             l_agnv_rec.line_number := l_line_number + 1;
           END IF;
           CLOSE line_num_csr;

           /* public api to insert provisions */
              OKL_ACCRUAL_RULES_PUB.insert_accrual_rules(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                                                               x_return_status   => l_return_status,
                                                                                   x_msg_count       => x_msg_count,
                                                                                   x_msg_data        => x_msg_data,
                                                                                   p_agnv_rec        => l_agnv_rec,
                                                                                   x_agnv_rec        => x_agnv_rec);

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

           /* copy output to input structure to get the id */
           l_agnv_rec := x_agnv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                                                 x_msg_data       => x_msg_data);
        x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name   => l_api_name,
                                                                                                   p_pkg_name   => G_PKG_NAME,
                                                                                                   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
                                                                                                   x_msg_count  => x_msg_count,
                                                                                                   x_msg_data   => x_msg_data,
                                                                                                   p_api_type   => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name   => l_api_name,
                                                                                                   p_pkg_name   => G_PKG_NAME,
                                                                                                   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                                                                                   x_msg_count  => x_msg_count,
                                                                                                   x_msg_data   => x_msg_data,
                                                                                                   p_api_type   => '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name   => l_api_name,
                                                                                                   p_pkg_name   => G_PKG_NAME,
                                                                                                   p_exc_name   => 'OTHERS',
                                                                                                   x_msg_count  => x_msg_count,
                                                                                                   x_msg_data   => x_msg_data,
                                                                                                   p_api_type   => '_PVT');

  END update_accrual_rules;

  PROCEDURE create_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type)

        IS

        l_api_version NUMBER := 1.0;

        BEGIN

              OKL_ACCRUAL_RULES_PUB.insert_accrual_rules(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                                                               x_return_status   => x_return_Status,
                                                                                   x_msg_count       => x_msg_count,
                                                                                   x_msg_data        => x_msg_data,
                                                                                   p_agnv_tbl        => p_agnv_tbl,
                                                                                   x_agnv_tbl        => x_agnv_tbl);

        END create_accrual_rules;

  PROCEDURE update_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type)

        IS
        l_api_version NUMBER := 1.0;

        BEGIN

              OKL_ACCRUAL_RULES_PUB.update_accrual_rules(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                                                               x_return_status   => x_return_Status,
                                                                                   x_msg_count       => x_msg_count,
                                                                                   x_msg_data        => x_msg_data,
                                                                                   p_agnv_tbl        => p_agnv_tbl,
                                                                                   x_agnv_tbl        => x_agnv_tbl);

        END update_accrual_rules;


  PROCEDURE delete_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN  agnv_rec_type)

        IS


        l_api_version NUMBER := 1;
    l_api_name                  CONSTANT VARCHAR2(30)  := 'delete_accrual_rules';
    l_no_data_found             BOOLEAN := TRUE;
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy                 NUMBER;
        l_oldversion_enddate    DATE := to_date(SYSDATE, 'DD-MM-RRRR');
        l_sysdate                               DATE := to_date(SYSDATE, 'DD-MM-RRRR');
    l_db_agnv_rec               agnv_rec_type; /* database copy */
        l_upd_agnv_rec                  agnv_rec_type; /* input copy */
        l_agnv_rec                              agnv_rec_type := p_agnv_rec; /* latest with the retained changes */
    x_agnv_rec              agnv_rec_type; /*update return copy */

    CURSOR check_rule_csr(p_id NUMBER) IS
        SELECT COUNT(*)
        FROM OKL_ACCRUAL_GNRTNS
        WHERE version = (SELECT version
                         FROM OKL_ACCRUAL_GNRTNS
                                         WHERE id = p_id)
        AND to_date IS NULL;

        BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name           => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version        => l_api_version,
                                              p_api_version        => p_api_version,
                                              p_api_type           => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    /* check if record being deleted is the last */
   -- OPEN check_rule_csr(p_agnv_rec.id);
        --FETCH check_rule_csr INTO l_dummy;
--      IF l_dummy = 1 THEN
   --   OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
--                                                p_msg_name            => 'OKL_AGN_RULE_DEL_ERROR');
--        RAISE OKL_API.G_EXCEPTION_ERROR;
 --   ELSE
     /* update records with end date */
     /* fetch old details from the database */
      get_rec(p_agnv_rec => p_agnv_rec,
            x_return_status => l_return_status,
                x_no_data_found => l_no_data_found,
            x_agnv_rec => l_db_agnv_rec);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS OR
         l_no_data_found = TRUE THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      /* retain the details that has been changed only */
      get_changes_only(p_agnv_rec => p_agnv_rec,
                           p_db_rec => l_db_agnv_rec,
                           x_agnv_rec => l_upd_agnv_rec);

           /* for old version */
           IF l_upd_agnv_rec.from_date <> G_MISS_DATE THEN
         IF to_date(l_upd_agnv_rec.from_date, 'DD-MM-RRRR') = l_sysdate THEN
                  l_oldversion_enddate := l_sysdate;
         ELSE
                  l_oldversion_enddate := l_upd_agnv_rec.from_date - 1;
         END IF;
           ELSE
         IF to_date(l_db_agnv_rec.from_date, 'DD-MM-RRRR') = l_sysdate THEN
                  l_oldversion_enddate := l_sysdate;
         ELSE
                  l_oldversion_enddate := l_sysdate - 1;
         END IF;
--         END IF;

           l_agnv_rec := l_db_agnv_rec;
           l_agnv_rec.to_date := l_oldversion_enddate;

           /* public api to update provisions */
              OKL_ACCRUAL_RULES_PUB.update_accrual_rules(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                                                               x_return_status   => l_return_status,
                                                                                   x_msg_count       => x_msg_count,
                                                                                   x_msg_data        => x_msg_data,
                                                                                   p_agnv_rec        => l_agnv_rec,
                                                                                   x_agnv_rec        => x_agnv_rec);

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN RAISE
       OKL_API.G_EXCEPTION_ERROR; ELSIF l_return_status =
       OKL_API.G_RET_STS_UNEXP_ERROR THEN RAISE
       OKL_API.G_EXCEPTION_UNEXPECTED_ERROR; END IF; x_return_status :=
       l_return_status; END IF; EXCEPTION WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
       p_pkg_name       => G_PKG_NAME, p_exc_name   =>
       'OKL_API.G_RET_STS_ERROR', x_msg_count   => x_msg_count, x_msg_data
       => x_msg_data, p_api_type        => '_PVT'); WHEN
       OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN x_return_status :=
       OKL_API.HANDLE_EXCEPTIONS(p_api_name     => l_api_name, p_pkg_name
       => G_PKG_NAME, p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
       x_msg_count      => x_msg_count, x_msg_data      => x_msg_data,
       p_api_type       => '_PVT'); WHEN OTHERS THEN x_return_status :=
       OKL_API.HANDLE_EXCEPTIONS(p_api_name     => l_api_name, p_pkg_name
       => G_PKG_NAME, p_exc_name   => 'OTHERS', x_msg_count     => x_msg_count,
       x_msg_data       => x_msg_data, p_api_type       => '_PVT'); END
       delete_accrual_rules;

  PROCEDURE delete_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type)

  IS

        l_api_version NUMBER := 1.0;

  BEGIN

              OKL_ACCRUAL_RULES_PUB.delete_accrual_rules(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                               x_return_status   => x_return_Status,
                                               x_msg_count       => x_msg_count,
                                               x_msg_data        => x_msg_data,
                                               p_agnv_tbl        => p_agnv_tbl);

  END delete_accrual_rules;


END OKL_SETUP_ACCRUALS_PVT;

/
