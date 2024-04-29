--------------------------------------------------------
--  DDL for Package Body POS_TAX_REPORT_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_TAX_REPORT_BO_PKG" AS
  /* $Header: POSSPTXRB.pls 120.0.12010000.1 2010/02/02 07:30:46 ntungare noship $ */

  PROCEDURE get_pos_tax_report_bo_tbl
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_pos_tax_report_bo_tbl OUT NOCOPY pos_tax_report_bo_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS

    l_pos_tax_report_bo_tbl pos_tax_report_bo_tbl := pos_tax_report_bo_tbl();

    l_party_id NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count     := 0;
    x_msg_data      := '';

    IF p_party_id IS NULL OR p_party_id = 0 THEN

      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;
    SELECT pos_tax_report_bo(reporting_code_assoc_id,
                             entity_code,
                             entity_id,
                             exception_code,
                             effective_from,
                             effective_to,
                             created_by,
                             creation_date,
                             last_updated_by,
                             last_update_date,
                             last_update_login,
                             reporting_code_char_value,
                             reporting_code_date_value,
                             reporting_code_num_value,
                             reporting_type_id,
                             reporting_code_id,
                             object_version_number) BULK COLLECT
    INTO   l_pos_tax_report_bo_tbl
    FROM   zx_report_codes_assoc
    WHERE  entity_id = l_party_id;

    x_pos_tax_report_bo_tbl := l_pos_tax_report_bo_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      x_msg_count := 1;
      x_msg_data  := SQLCODE || SQLERRM;

  END get_pos_tax_report_bo_tbl;

  PROCEDURE create_pos_tax_report_bo_row
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    p_create_update_flag    IN VARCHAR2,
    p_pos_tax_report_bo     IN pos_tax_report_bo_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS

    l_row_exists        NUMBER := 0;
    l_party_id          NUMBER := 0;
    l_reporting_code_id NUMBER;
  BEGIN
    l_row_exists    := 0;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count     := 0;
    x_msg_data      := '';

    IF p_party_id IS NULL OR p_party_id = 0 THEN

      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;

    FOR i IN p_pos_tax_report_bo.first .. p_pos_tax_report_bo.last LOOP
      IF p_create_update_flag = 'U' THEN
        --update the existing row;
        UPDATE zx_report_codes_assoc
        SET    reporting_code_assoc_id   = p_pos_tax_report_bo(i)
                                           .reporting_code_assoc_id,
               entity_code               = p_pos_tax_report_bo(i).entity_code,
               exception_code            = p_pos_tax_report_bo(i)
                                           .exception_code,
               effective_from            = p_pos_tax_report_bo(i)
                                           .effective_from,
               effective_to              = p_pos_tax_report_bo(i)
                                           .effective_to,
               last_updated_by           = p_pos_tax_report_bo(i)
                                           .last_updated_by,
               last_update_date          = SYSDATE,
               last_update_login         = p_pos_tax_report_bo(i)
                                           .last_update_login,
               reporting_code_char_value = p_pos_tax_report_bo(i)
                                           .reporting_code_char_value,
               reporting_code_date_value = p_pos_tax_report_bo(i)
                                           .reporting_code_date_value,
               reporting_code_num_value  = p_pos_tax_report_bo(i)
                                           .reporting_code_num_value,
               reporting_type_id         = p_pos_tax_report_bo(i)
                                           .reporting_type_id,
               reporting_code_id         = p_pos_tax_report_bo(i)
                                           .reporting_code_id,
               object_version_number     = p_pos_tax_report_bo(i)
                                           .object_version_number
        WHERE  entity_id = l_party_id;

      ELSIF p_create_update_flag = 'C' THEN
        SELECT zx_reporting_codes_b_s.nextval
        INTO   l_reporting_code_id
        FROM   dual;
        IF l_party_id IS NULL THEN
          l_party_id := p_pos_tax_report_bo(i).entity_id;
        END IF;
        INSERT INTO zx_report_codes_assoc
          (reporting_code_assoc_id,
           entity_code,
           entity_id,
           exception_code,
           effective_from,
           effective_to,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           reporting_code_char_value,
           reporting_code_date_value,
           reporting_code_num_value,
           reporting_type_id,
           reporting_code_id,
           object_version_number)
        VALUES
          (l_reporting_code_id,
           p_pos_tax_report_bo(i).entity_code,
           p_pos_tax_report_bo(i).entity_id,
           p_pos_tax_report_bo(i).exception_code,
           p_pos_tax_report_bo(i).effective_from,
           p_pos_tax_report_bo(i).effective_to,
           p_pos_tax_report_bo(i).created_by,
           SYSDATE,
           p_pos_tax_report_bo(i).last_updated_by,
           SYSDATE,
           p_pos_tax_report_bo(i).last_update_login,
           p_pos_tax_report_bo(i).reporting_code_char_value,
           p_pos_tax_report_bo(i).reporting_code_date_value,
           p_pos_tax_report_bo(i).reporting_code_num_value,
           p_pos_tax_report_bo(i).reporting_type_id,
           p_pos_tax_report_bo(i).reporting_code_id,
           p_pos_tax_report_bo(i).object_version_number);

      END IF;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      x_msg_count := 1;
      x_msg_data  := SQLCODE || SQLERRM;
  END create_pos_tax_report_bo_row;

END pos_tax_report_bo_pkg;

/
