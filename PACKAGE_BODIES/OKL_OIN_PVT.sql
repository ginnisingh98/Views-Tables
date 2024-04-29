--------------------------------------------------------
--  DDL for Package Body OKL_OIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OIN_PVT" AS
/* $Header: OKLSOINB.pls 120.2 2006/07/11 10:23:28 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKL_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKL_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER AS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc AS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version AS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy AS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPEN_INT_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oinv_rec                     IN oinv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oinv_rec_type AS
    CURSOR OKL_OPEN_INT_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            PARTY_ID,
            PARTY_NAME,
            PARTY_TYPE,
            DATE_OF_BIRTH,
            PLACE_OF_BIRTH,
            PERSON_IDENTIFIER,
            PERSON_IDEN_TYPE,
            COUNTRY,
            ADDRESS1,
            ADDRESS2,
            ADDRESS3,
            ADDRESS4,
            CITY,
            POSTAL_CODE,
            STATE,
            PROVINCE,
            COUNTY,
            PO_BOX_NUMBER,
            HOUSE_NUMBER,
            STREET_SUFFIX,
            APARTMENT_NUMBER,
            STREET,
            RURAL_ROUTE_NUMBER,
            STREET_NUMBER,
            BUILDING,
            FLOOR,
            SUITE,
            ROOM,
            POSTAL_PLUS4_CODE,
            CAS_ID,
            CASE_NUMBER,
            KHR_ID,
            CONTRACT_NUMBER,
            CONTRACT_TYPE,
            CONTRACT_STATUS,
            ORIGINAL_AMOUNT,
            START_DATE,
            CLOSE_DATE,
            TERM_DURATION,
            MONTHLY_PAYMENT_AMOUNT,
            LAST_PAYMENT_DATE,
            DELINQUENCY_OCCURANCE_DATE,
            PAST_DUE_AMOUNT,
            REMAINING_AMOUNT,
            CREDIT_INDICATOR,
            NOTIFICATION_DATE,
            CREDIT_BUREAU_REPORT_DATE,
            EXTERNAL_AGENCY_TRANSFER_DATE,
            EXTERNAL_AGENCY_RECALL_DATE,
            REFERRAL_NUMBER,
            CONTACT_ID,
            CONTACT_NAME,
            CONTACT_PHONE,
            CONTACT_EMAIL,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_OPEN_INT
     WHERE OKL_OPEN_INT.id    = p_id;
    l_OKL_OPEN_INT_pk            OKL_OPEN_INT_pk_csr%ROWTYPE;
    l_oinv_rec                     oinv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN OKL_OPEN_INT_pk_csr (p_oinv_rec.id);
    FETCH OKL_OPEN_INT_pk_csr INTO
              l_oinv_rec.id,
              l_oinv_rec.party_id,
              l_oinv_rec.party_name,
              l_oinv_rec.party_type,
              l_oinv_rec.date_of_birth,
              l_oinv_rec.place_of_birth,
              l_oinv_rec.person_identifier,
              l_oinv_rec.person_iden_type,
              l_oinv_rec.country,
              l_oinv_rec.address1,
              l_oinv_rec.address2,
              l_oinv_rec.address3,
              l_oinv_rec.address4,
              l_oinv_rec.city,
              l_oinv_rec.postal_code,
              l_oinv_rec.state,
              l_oinv_rec.province,
              l_oinv_rec.county,
              l_oinv_rec.po_box_number,
              l_oinv_rec.house_number,
              l_oinv_rec.street_suffix,
              l_oinv_rec.apartment_number,
              l_oinv_rec.street,
              l_oinv_rec.rural_route_number,
              l_oinv_rec.street_number,
              l_oinv_rec.building,
              l_oinv_rec.floor,
              l_oinv_rec.suite,
              l_oinv_rec.room,
              l_oinv_rec.postal_plus4_code,
              l_oinv_rec.cas_id,
              l_oinv_rec.case_number,
              l_oinv_rec.khr_id,
              l_oinv_rec.contract_number,
              l_oinv_rec.contract_type,
              l_oinv_rec.contract_status,
              l_oinv_rec.original_amount,
              l_oinv_rec.start_date,
              l_oinv_rec.close_date,
              l_oinv_rec.term_duration,
              l_oinv_rec.monthly_payment_amount,
              l_oinv_rec.last_payment_date,
              l_oinv_rec.delinquency_occurance_date,
              l_oinv_rec.past_due_amount,
              l_oinv_rec.remaining_amount,
              l_oinv_rec.credit_indicator,
              l_oinv_rec.notification_date,
              l_oinv_rec.credit_bureau_report_date,
              l_oinv_rec.external_agency_transfer_date,
              l_oinv_rec.external_agency_recall_date,
              l_oinv_rec.referral_number,
              l_oinv_rec.contact_id,
              l_oinv_rec.contact_name,
              l_oinv_rec.contact_phone,
              l_oinv_rec.contact_email,
              l_oinv_rec.object_version_number,
              l_oinv_rec.org_id,
              l_oinv_rec.request_id,
              l_oinv_rec.program_application_id,
              l_oinv_rec.program_id,
              l_oinv_rec.program_update_date,
              l_oinv_rec.attribute_category,
              l_oinv_rec.attribute1,
              l_oinv_rec.attribute2,
              l_oinv_rec.attribute3,
              l_oinv_rec.attribute4,
              l_oinv_rec.attribute5,
              l_oinv_rec.attribute6,
              l_oinv_rec.attribute7,
              l_oinv_rec.attribute8,
              l_oinv_rec.attribute9,
              l_oinv_rec.attribute10,
              l_oinv_rec.attribute11,
              l_oinv_rec.attribute12,
              l_oinv_rec.attribute13,
              l_oinv_rec.attribute14,
              l_oinv_rec.attribute15,
              l_oinv_rec.created_by,
              l_oinv_rec.creation_date,
              l_oinv_rec.last_updated_by,
              l_oinv_rec.last_update_date,
              l_oinv_rec.last_update_login;
    x_no_data_found := OKL_OPEN_INT_pk_csr%NOTFOUND;
    CLOSE OKL_OPEN_INT_pk_csr;
    RETURN(l_oinv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oinv_rec                     IN oinv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oinv_rec_type AS
    l_oinv_rec                     oinv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oinv_rec := get_rec(p_oinv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oinv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oinv_rec                     IN oinv_rec_type
  ) RETURN oinv_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oinv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPEN_INT
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oin_rec                      IN oin_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oin_rec_type AS
    CURSOR oin_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            PARTY_ID,
            PARTY_NAME,
            PARTY_TYPE,
            DATE_OF_BIRTH,
            PLACE_OF_BIRTH,
            PERSON_IDENTIFIER,
            PERSON_IDEN_TYPE,
            COUNTRY,
            ADDRESS1,
            ADDRESS2,
            ADDRESS3,
            ADDRESS4,
            CITY,
            POSTAL_CODE,
            STATE,
            PROVINCE,
            COUNTY,
            PO_BOX_NUMBER,
            HOUSE_NUMBER,
            STREET_SUFFIX,
            APARTMENT_NUMBER,
            STREET,
            RURAL_ROUTE_NUMBER,
            STREET_NUMBER,
            BUILDING,
            FLOOR,
            SUITE,
            ROOM,
            POSTAL_PLUS4_CODE,
            CAS_ID,
            CASE_NUMBER,
            KHR_ID,
            CONTRACT_NUMBER,
            CONTRACT_TYPE,
            CONTRACT_STATUS,
            ORIGINAL_AMOUNT,
            START_DATE,
            CLOSE_DATE,
            TERM_DURATION,
            MONTHLY_PAYMENT_AMOUNT,
            LAST_PAYMENT_DATE,
            DELINQUENCY_OCCURANCE_DATE,
            PAST_DUE_AMOUNT,
            REMAINING_AMOUNT,
            CREDIT_INDICATOR,
            NOTIFICATION_DATE,
            CREDIT_BUREAU_REPORT_DATE,
            EXTERNAL_AGENCY_TRANSFER_DATE,
            EXTERNAL_AGENCY_RECALL_DATE,
            REFERRAL_NUMBER,
            CONTACT_ID,
            CONTACT_NAME,
            CONTACT_PHONE,
            CONTACT_EMAIL,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Open_Int
     WHERE okl_open_int.id      = p_id;
    l_oin_b_pk                     oin_b_pk_csr%ROWTYPE;
    l_oin_rec                      oin_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oin_b_pk_csr (p_oin_rec.id);
    FETCH oin_b_pk_csr INTO
              l_oin_rec.id,
              l_oin_rec.party_id,
              l_oin_rec.party_name,
              l_oin_rec.party_type,
              l_oin_rec.date_of_birth,
              l_oin_rec.place_of_birth,
              l_oin_rec.person_identifier,
              l_oin_rec.person_iden_type,
              l_oin_rec.country,
              l_oin_rec.address1,
              l_oin_rec.address2,
              l_oin_rec.address3,
              l_oin_rec.address4,
              l_oin_rec.city,
              l_oin_rec.postal_code,
              l_oin_rec.state,
              l_oin_rec.province,
              l_oin_rec.county,
              l_oin_rec.po_box_number,
              l_oin_rec.house_number,
              l_oin_rec.street_suffix,
              l_oin_rec.apartment_number,
              l_oin_rec.street,
              l_oin_rec.rural_route_number,
              l_oin_rec.street_number,
              l_oin_rec.building,
              l_oin_rec.floor,
              l_oin_rec.suite,
              l_oin_rec.room,
              l_oin_rec.postal_plus4_code,
              l_oin_rec.cas_id,
              l_oin_rec.case_number,
              l_oin_rec.khr_id,
              l_oin_rec.contract_number,
              l_oin_rec.contract_type,
              l_oin_rec.contract_status,
              l_oin_rec.original_amount,
              l_oin_rec.start_date,
              l_oin_rec.close_date,
              l_oin_rec.term_duration,
              l_oin_rec.monthly_payment_amount,
              l_oin_rec.last_payment_date,
              l_oin_rec.delinquency_occurance_date,
              l_oin_rec.past_due_amount,
              l_oin_rec.remaining_amount,
              l_oin_rec.credit_indicator,
              l_oin_rec.notification_date,
              l_oin_rec.credit_bureau_report_date,
              l_oin_rec.external_agency_transfer_date,
              l_oin_rec.external_agency_recall_date,
              l_oin_rec.referral_number,
              l_oin_rec.contact_id,
              l_oin_rec.contact_name,
              l_oin_rec.contact_phone,
              l_oin_rec.contact_email,
              l_oin_rec.object_version_number,
              l_oin_rec.org_id,
              l_oin_rec.request_id,
              l_oin_rec.program_application_id,
              l_oin_rec.program_id,
              l_oin_rec.program_update_date,
              l_oin_rec.attribute_category,
              l_oin_rec.attribute1,
              l_oin_rec.attribute2,
              l_oin_rec.attribute3,
              l_oin_rec.attribute4,
              l_oin_rec.attribute5,
              l_oin_rec.attribute6,
              l_oin_rec.attribute7,
              l_oin_rec.attribute8,
              l_oin_rec.attribute9,
              l_oin_rec.attribute10,
              l_oin_rec.attribute11,
              l_oin_rec.attribute12,
              l_oin_rec.attribute13,
              l_oin_rec.attribute14,
              l_oin_rec.attribute15,
              l_oin_rec.created_by,
              l_oin_rec.creation_date,
              l_oin_rec.last_updated_by,
              l_oin_rec.last_update_date,
              l_oin_rec.last_update_login;
    x_no_data_found := oin_b_pk_csr%NOTFOUND;
    CLOSE oin_b_pk_csr;
    RETURN(l_oin_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oin_rec                      IN oin_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oin_rec_type AS
    l_oin_rec                      oin_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oin_rec := get_rec(p_oin_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oin_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oin_rec                      IN oin_rec_type
  ) RETURN oin_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oin_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_OPEN_INT_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_oinv_rec   IN oinv_rec_type
  ) RETURN oinv_rec_type AS
    l_oinv_rec                     oinv_rec_type := p_oinv_rec;
  BEGIN
    IF (l_oinv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.id := NULL;
    END IF;
    IF (l_oinv_rec.party_id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.party_id := NULL;
    END IF;
    IF (l_oinv_rec.party_name = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.party_name := NULL;
    END IF;
    IF (l_oinv_rec.party_type = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.party_type := NULL;
    END IF;
    IF (l_oinv_rec.date_of_birth = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.date_of_birth := NULL;
    END IF;
    IF (l_oinv_rec.place_of_birth = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.place_of_birth := NULL;
    END IF;
    IF (l_oinv_rec.person_identifier = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.person_identifier := NULL;
    END IF;
    IF (l_oinv_rec.person_iden_type = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.person_iden_type := NULL;
    END IF;
    IF (l_oinv_rec.country = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.country := NULL;
    END IF;
    IF (l_oinv_rec.address1 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.address1 := NULL;
    END IF;
    IF (l_oinv_rec.address2 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.address2 := NULL;
    END IF;
    IF (l_oinv_rec.address3 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.address3 := NULL;
    END IF;
    IF (l_oinv_rec.address4 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.address4 := NULL;
    END IF;
    IF (l_oinv_rec.city = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.city := NULL;
    END IF;
    IF (l_oinv_rec.postal_code = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.postal_code := NULL;
    END IF;
    IF (l_oinv_rec.state = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.state := NULL;
    END IF;
    IF (l_oinv_rec.province = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.province := NULL;
    END IF;
    IF (l_oinv_rec.county = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.county := NULL;
    END IF;
    IF (l_oinv_rec.po_box_number = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.po_box_number := NULL;
    END IF;
    IF (l_oinv_rec.house_number = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.house_number := NULL;
    END IF;
    IF (l_oinv_rec.street_suffix = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.street_suffix := NULL;
    END IF;
    IF (l_oinv_rec.apartment_number = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.apartment_number := NULL;
    END IF;
    IF (l_oinv_rec.street = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.street := NULL;
    END IF;
    IF (l_oinv_rec.rural_route_number = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.rural_route_number := NULL;
    END IF;
    IF (l_oinv_rec.street_number = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.street_number := NULL;
    END IF;
    IF (l_oinv_rec.building = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.building := NULL;
    END IF;
    IF (l_oinv_rec.floor = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.floor := NULL;
    END IF;
    IF (l_oinv_rec.suite = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.suite := NULL;
    END IF;
    IF (l_oinv_rec.room = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.room := NULL;
    END IF;
    IF (l_oinv_rec.postal_plus4_code = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.postal_plus4_code := NULL;
    END IF;
    IF (l_oinv_rec.cas_id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.cas_id := NULL;
    END IF;
    IF (l_oinv_rec.case_number = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.case_number := NULL;
    END IF;
    IF (l_oinv_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.khr_id := NULL;
    END IF;
    IF (l_oinv_rec.contract_number = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.contract_number := NULL;
    END IF;
    IF (l_oinv_rec.contract_type = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.contract_type := NULL;
    END IF;
    IF (l_oinv_rec.contract_status = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.contract_status := NULL;
    END IF;
    IF (l_oinv_rec.original_amount = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.original_amount := NULL;
    END IF;
    IF (l_oinv_rec.start_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.start_date := NULL;
    END IF;
    IF (l_oinv_rec.close_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.close_date := NULL;
    END IF;
    IF (l_oinv_rec.term_duration = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.term_duration := NULL;
    END IF;
    IF (l_oinv_rec.monthly_payment_amount = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.monthly_payment_amount := NULL;
    END IF;
    IF (l_oinv_rec.last_payment_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.last_payment_date := NULL;
    END IF;
    IF (l_oinv_rec.delinquency_occurance_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.delinquency_occurance_date := NULL;
    END IF;
    IF (l_oinv_rec.past_due_amount = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.past_due_amount := NULL;
    END IF;
    IF (l_oinv_rec.remaining_amount = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.remaining_amount := NULL;
    END IF;
    IF (l_oinv_rec.credit_indicator = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.credit_indicator := NULL;
    END IF;
    IF (l_oinv_rec.notification_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.notification_date := NULL;
    END IF;
    IF (l_oinv_rec.credit_bureau_report_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.credit_bureau_report_date := NULL;
    END IF;
    IF (l_oinv_rec.external_agency_transfer_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.external_agency_transfer_date := NULL;
    END IF;
    IF (l_oinv_rec.external_agency_recall_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.external_agency_recall_date := NULL;
    END IF;
    IF (l_oinv_rec.referral_number = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.referral_number := NULL;
    END IF;
    IF (l_oinv_rec.contact_id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.contact_id := NULL;
    END IF;
    IF (l_oinv_rec.contact_name = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.contact_name := NULL;
    END IF;
    IF (l_oinv_rec.contact_phone = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.contact_phone := NULL;
    END IF;
    IF (l_oinv_rec.contact_email = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.contact_email := NULL;
    END IF;
    IF (l_oinv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.object_version_number := NULL;
    END IF;
    IF (l_oinv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.org_id := NULL;
    END IF;
    IF (l_oinv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.request_id := NULL;
    END IF;
    IF (l_oinv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.program_application_id := NULL;
    END IF;
    IF (l_oinv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.program_id := NULL;
    END IF;
    IF (l_oinv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.program_update_date := NULL;
    END IF;
    IF (l_oinv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute_category := NULL;
    END IF;
    IF (l_oinv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute1 := NULL;
    END IF;
    IF (l_oinv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute2 := NULL;
    END IF;
    IF (l_oinv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute3 := NULL;
    END IF;
    IF (l_oinv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute4 := NULL;
    END IF;
    IF (l_oinv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute5 := NULL;
    END IF;
    IF (l_oinv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute6 := NULL;
    END IF;
    IF (l_oinv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute7 := NULL;
    END IF;
    IF (l_oinv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute8 := NULL;
    END IF;
    IF (l_oinv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute9 := NULL;
    END IF;
    IF (l_oinv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute10 := NULL;
    END IF;
    IF (l_oinv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute11 := NULL;
    END IF;
    IF (l_oinv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute12 := NULL;
    END IF;
    IF (l_oinv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute13 := NULL;
    END IF;
    IF (l_oinv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute14 := NULL;
    END IF;
    IF (l_oinv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_oinv_rec.attribute15 := NULL;
    END IF;
    IF (l_oinv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.created_by := NULL;
    END IF;
    IF (l_oinv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.creation_date := NULL;
    END IF;
    IF (l_oinv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.last_updated_by := NULL;
    END IF;
    IF (l_oinv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oinv_rec.last_update_date := NULL;
    END IF;
    IF (l_oinv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_oinv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_oinv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.id = OKC_API.G_MISS_NUM OR
        p_oinv_rec.id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ---------------------------------------
  -- Validate_Attributes for: PARTY_ID --
  ---------------------------------------
  PROCEDURE validate_party_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.party_id = OKC_API.G_MISS_NUM OR
        p_oinv_rec.party_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'party_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_party_id;
  -----------------------------------------
  -- Validate_Attributes for: PARTY_NAME --
  -----------------------------------------
  PROCEDURE validate_party_name(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.party_name = OKC_API.G_MISS_CHAR OR
        p_oinv_rec.party_name IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'party_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_party_name;
  -----------------------------------------
  -- Validate_Attributes for: PARTY_TYPE --
  -----------------------------------------
  PROCEDURE validate_party_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.party_type = OKC_API.G_MISS_CHAR OR
        p_oinv_rec.party_type IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'party_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_party_type;
  -------------------------------------
  -- Validate_Attributes for: CAS_ID --
  -------------------------------------
  PROCEDURE validate_cas_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.cas_id = OKC_API.G_MISS_NUM OR
        p_oinv_rec.cas_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cas_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_cas_id;
  ------------------------------------------
  -- Validate_Attributes for: CASE_NUMBER --
  ------------------------------------------
  PROCEDURE validate_case_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.case_number = OKC_API.G_MISS_CHAR OR
        p_oinv_rec.case_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'case_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_case_number;
  -------------------------------------
  -- Validate_Attributes for: KHR_ID --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.khr_id = OKC_API.G_MISS_NUM OR
        p_oinv_rec.khr_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'khr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_khr_id;
  ----------------------------------------------
  -- Validate_Attributes for: CONTRACT_NUMBER --
  ----------------------------------------------
  PROCEDURE validate_contract_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.contract_number = OKC_API.G_MISS_CHAR OR
        p_oinv_rec.contract_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'contract_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_contract_number;
  --------------------------------------------
  -- Validate_Attributes for: CONTRACT_TYPE --
  --------------------------------------------
  PROCEDURE validate_contract_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.contract_type = OKC_API.G_MISS_CHAR OR
        p_oinv_rec.contract_type IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'contract_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_contract_type;
  ----------------------------------------------
  -- Validate_Attributes for: CONTRACT_STATUS --
  ----------------------------------------------
  PROCEDURE validate_contract_status(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oinv_rec.contract_status = OKC_API.G_MISS_CHAR OR
        p_oinv_rec.contract_status IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'contract_status');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_contract_status;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /*
    IF (p_object_version_number = OKC_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_OPEN_INT_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_oinv_rec                     IN oinv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- party_id
    -- ***
    validate_party_id(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- party_name
    -- ***
    validate_party_name(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- party_type
    -- ***
    validate_party_type(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- cas_id
    -- ***
    validate_cas_id(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- case_number
    -- ***
    validate_case_number(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- khr_id
    -- ***
    validate_khr_id(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- contract_number
    -- ***
    validate_contract_number(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- contract_type
    -- ***
    validate_contract_type(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- contract_status
    -- ***
    validate_contract_status(l_return_status, p_oinv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    /*
    validate_object_version_number(x_return_status, p_oinv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate Record for:OKL_OPEN_INT_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_oinv_rec IN oinv_rec_type,
    p_db_oinv_rec IN oinv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_oinv_rec IN oinv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_oinv_rec                  oinv_rec_type := get_rec(p_oinv_rec);
  BEGIN
    l_return_status := Validate_Record(p_oinv_rec => p_oinv_rec,
                                       p_db_oinv_rec => l_db_oinv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN oinv_rec_type,
    p_to   IN OUT NOCOPY oin_rec_type
  ) AS
  BEGIN
    p_to.id := p_from.id;
    p_to.party_id := p_from.party_id;
    p_to.party_name := p_from.party_name;
    p_to.party_type := p_from.party_type;
    p_to.date_of_birth := p_from.date_of_birth;
    p_to.place_of_birth := p_from.place_of_birth;
    p_to.person_identifier := p_from.person_identifier;
    p_to.person_iden_type := p_from.person_iden_type;
    p_to.country := p_from.country;
    p_to.address1 := p_from.address1;
    p_to.address2 := p_from.address2;
    p_to.address3 := p_from.address3;
    p_to.address4 := p_from.address4;
    p_to.city := p_from.city;
    p_to.postal_code := p_from.postal_code;
    p_to.state := p_from.state;
    p_to.province := p_from.province;
    p_to.county := p_from.county;
    p_to.po_box_number := p_from.po_box_number;
    p_to.house_number := p_from.house_number;
    p_to.street_suffix := p_from.street_suffix;
    p_to.apartment_number := p_from.apartment_number;
    p_to.street := p_from.street;
    p_to.rural_route_number := p_from.rural_route_number;
    p_to.street_number := p_from.street_number;
    p_to.building := p_from.building;
    p_to.floor := p_from.floor;
    p_to.suite := p_from.suite;
    p_to.room := p_from.room;
    p_to.postal_plus4_code := p_from.postal_plus4_code;
    p_to.cas_id := p_from.cas_id;
    p_to.case_number := p_from.case_number;
    p_to.khr_id := p_from.khr_id;
    p_to.contract_number := p_from.contract_number;
    p_to.contract_type := p_from.contract_type;
    p_to.contract_status := p_from.contract_status;
    p_to.original_amount := p_from.original_amount;
    p_to.start_date := p_from.start_date;
    p_to.close_date := p_from.close_date;
    p_to.term_duration := p_from.term_duration;
    p_to.monthly_payment_amount := p_from.monthly_payment_amount;
    p_to.last_payment_date := p_from.last_payment_date;
    p_to.delinquency_occurance_date := p_from.delinquency_occurance_date;
    p_to.past_due_amount := p_from.past_due_amount;
    p_to.remaining_amount := p_from.remaining_amount;
    p_to.credit_indicator := p_from.credit_indicator;
    p_to.notification_date := p_from.notification_date;
    p_to.credit_bureau_report_date := p_from.credit_bureau_report_date;
    p_to.external_agency_transfer_date := p_from.external_agency_transfer_date;
    p_to.external_agency_recall_date := p_from.external_agency_recall_date;
    p_to.referral_number := p_from.referral_number;
    p_to.contact_id := p_from.contact_id;
    p_to.contact_name := p_from.contact_name;
    p_to.contact_phone := p_from.contact_phone;
    p_to.contact_email := p_from.contact_email;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN oin_rec_type,
    p_to   IN OUT NOCOPY oinv_rec_type
  ) AS
  BEGIN
    p_to.id := p_from.id;
    p_to.party_id := p_from.party_id;
    p_to.party_name := p_from.party_name;
    p_to.party_type := p_from.party_type;
    p_to.date_of_birth := p_from.date_of_birth;
    p_to.place_of_birth := p_from.place_of_birth;
    p_to.person_identifier := p_from.person_identifier;
    p_to.person_iden_type := p_from.person_iden_type;
    p_to.country := p_from.country;
    p_to.address1 := p_from.address1;
    p_to.address2 := p_from.address2;
    p_to.address3 := p_from.address3;
    p_to.address4 := p_from.address4;
    p_to.city := p_from.city;
    p_to.postal_code := p_from.postal_code;
    p_to.state := p_from.state;
    p_to.province := p_from.province;
    p_to.county := p_from.county;
    p_to.po_box_number := p_from.po_box_number;
    p_to.house_number := p_from.house_number;
    p_to.street_suffix := p_from.street_suffix;
    p_to.apartment_number := p_from.apartment_number;
    p_to.street := p_from.street;
    p_to.rural_route_number := p_from.rural_route_number;
    p_to.street_number := p_from.street_number;
    p_to.building := p_from.building;
    p_to.floor := p_from.floor;
    p_to.suite := p_from.suite;
    p_to.room := p_from.room;
    p_to.postal_plus4_code := p_from.postal_plus4_code;
    p_to.cas_id := p_from.cas_id;
    p_to.case_number := p_from.case_number;
    p_to.khr_id := p_from.khr_id;
    p_to.contract_number := p_from.contract_number;
    p_to.contract_type := p_from.contract_type;
    p_to.contract_status := p_from.contract_status;
    p_to.original_amount := p_from.original_amount;
    p_to.start_date := p_from.start_date;
    p_to.close_date := p_from.close_date;
    p_to.term_duration := p_from.term_duration;
    p_to.monthly_payment_amount := p_from.monthly_payment_amount;
    p_to.last_payment_date := p_from.last_payment_date;
    p_to.delinquency_occurance_date := p_from.delinquency_occurance_date;
    p_to.past_due_amount := p_from.past_due_amount;
    p_to.remaining_amount := p_from.remaining_amount;
    p_to.credit_indicator := p_from.credit_indicator;
    p_to.notification_date := p_from.notification_date;
    p_to.credit_bureau_report_date := p_from.credit_bureau_report_date;
    p_to.external_agency_transfer_date := p_from.external_agency_transfer_date;
    p_to.external_agency_recall_date := p_from.external_agency_recall_date;
    p_to.referral_number := p_from.referral_number;
    p_to.contact_id := p_from.contact_id;
    p_to.contact_name := p_from.contact_name;
    p_to.contact_phone := p_from.contact_phone;
    p_to.contact_email := p_from.contact_email;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKL_OPEN_INT_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oinv_rec                     oinv_rec_type := p_oinv_rec;
    l_oin_rec                      oin_rec_type;
    l_oin_rec                      oin_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_oinv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_oinv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_OPEN_INT_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      i := p_oinv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_oinv_rec                     => p_oinv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_oinv_tbl.LAST);
        i := p_oinv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_OPEN_INT_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oinv_tbl                     => p_oinv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ---------------------------------
  -- insert_row for:OKL_OPEN_INT --
  ---------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oin_rec                      IN oin_rec_type,
    x_oin_rec                      OUT NOCOPY oin_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oin_rec                      oin_rec_type := p_oin_rec;
    l_def_oin_rec                  oin_rec_type;
    -------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_oin_rec IN oin_rec_type,
      x_oin_rec OUT NOCOPY oin_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oin_rec := p_oin_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_oin_rec,                         -- IN
      l_oin_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_OPEN_INT(
      id,
      party_id,
      party_name,
      party_type,
      date_of_birth,
      place_of_birth,
      person_identifier,
      person_iden_type,
      country,
      address1,
      address2,
      address3,
      address4,
      city,
      postal_code,
      state,
      province,
      county,
      po_box_number,
      house_number,
      street_suffix,
      apartment_number,
      street,
      rural_route_number,
      street_number,
      building,
      floor,
      suite,
      room,
      postal_plus4_code,
      cas_id,
      case_number,
      khr_id,
      contract_number,
      contract_type,
      contract_status,
      original_amount,
      start_date,
      close_date,
      term_duration,
      monthly_payment_amount,
      last_payment_date,
      delinquency_occurance_date,
      past_due_amount,
      remaining_amount,
      credit_indicator,
      notification_date,
      credit_bureau_report_date,
      external_agency_transfer_date,
      external_agency_recall_date,
      referral_number,
      contact_id,
      contact_name,
      contact_phone,
      contact_email,
      object_version_number,
      org_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_oin_rec.id,
      l_oin_rec.party_id,
      l_oin_rec.party_name,
      l_oin_rec.party_type,
      l_oin_rec.date_of_birth,
      l_oin_rec.place_of_birth,
      l_oin_rec.person_identifier,
      l_oin_rec.person_iden_type,
      l_oin_rec.country,
      l_oin_rec.address1,
      l_oin_rec.address2,
      l_oin_rec.address3,
      l_oin_rec.address4,
      l_oin_rec.city,
      l_oin_rec.postal_code,
      l_oin_rec.state,
      l_oin_rec.province,
      l_oin_rec.county,
      l_oin_rec.po_box_number,
      l_oin_rec.house_number,
      l_oin_rec.street_suffix,
      l_oin_rec.apartment_number,
      l_oin_rec.street,
      l_oin_rec.rural_route_number,
      l_oin_rec.street_number,
      l_oin_rec.building,
      l_oin_rec.floor,
      l_oin_rec.suite,
      l_oin_rec.room,
      l_oin_rec.postal_plus4_code,
      l_oin_rec.cas_id,
      l_oin_rec.case_number,
      l_oin_rec.khr_id,
      l_oin_rec.contract_number,
      l_oin_rec.contract_type,
      l_oin_rec.contract_status,
      l_oin_rec.original_amount,
      l_oin_rec.start_date,
      l_oin_rec.close_date,
      l_oin_rec.term_duration,
      l_oin_rec.monthly_payment_amount,
      l_oin_rec.last_payment_date,
      l_oin_rec.delinquency_occurance_date,
      l_oin_rec.past_due_amount,
      l_oin_rec.remaining_amount,
      l_oin_rec.credit_indicator,
      l_oin_rec.notification_date,
      l_oin_rec.credit_bureau_report_date,
      l_oin_rec.external_agency_transfer_date,
      l_oin_rec.external_agency_recall_date,
      l_oin_rec.referral_number,
      l_oin_rec.contact_id,
      l_oin_rec.contact_name,
      l_oin_rec.contact_phone,
      l_oin_rec.contact_email,
      l_oin_rec.object_version_number,
      l_oin_rec.org_id,
      l_oin_rec.request_id,
      l_oin_rec.program_application_id,
      l_oin_rec.program_id,
      l_oin_rec.program_update_date,
      l_oin_rec.attribute_category,
      l_oin_rec.attribute1,
      l_oin_rec.attribute2,
      l_oin_rec.attribute3,
      l_oin_rec.attribute4,
      l_oin_rec.attribute5,
      l_oin_rec.attribute6,
      l_oin_rec.attribute7,
      l_oin_rec.attribute8,
      l_oin_rec.attribute9,
      l_oin_rec.attribute10,
      l_oin_rec.attribute11,
      l_oin_rec.attribute12,
      l_oin_rec.attribute13,
      l_oin_rec.attribute14,
      l_oin_rec.attribute15,
      l_oin_rec.created_by,
      l_oin_rec.creation_date,
      l_oin_rec.last_updated_by,
      l_oin_rec.last_update_date,
      l_oin_rec.last_update_login);
    -- Set OUT values
    x_oin_rec := l_oin_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ------------------------------------
  -- insert_row for :OKL_OPEN_INT_V --
  ------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type,
    x_oinv_rec                     OUT NOCOPY oinv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oinv_rec                     oinv_rec_type := p_oinv_rec;
    l_def_oinv_rec                 oinv_rec_type;
    l_oin_rec                      oin_rec_type;
    lx_oin_rec                     oin_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oinv_rec IN oinv_rec_type
    ) RETURN oinv_rec_type AS
      l_oinv_rec oinv_rec_type := p_oinv_rec;
    BEGIN
      l_oinv_rec.CREATION_DATE := SYSDATE;
      l_oinv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_oinv_rec.LAST_UPDATE_DATE := l_oinv_rec.CREATION_DATE;
      l_oinv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oinv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oinv_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_oinv_rec IN oinv_rec_type,
      x_oinv_rec OUT NOCOPY oinv_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oinv_rec := p_oinv_rec;
      x_oinv_rec.OBJECT_VERSION_NUMBER := 1;

      -- Begin Post-Generation Change
      IF (x_oinv_rec.request_id IS NULL OR x_oinv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_oinv_rec.request_id,
	  	   x_oinv_rec.program_application_id,
	  	   x_oinv_rec.program_id,
	  	   x_oinv_rec.program_update_date
	  FROM dual;
      END IF;
      -- End Post-Generation Change

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_oinv_rec := null_out_defaults(p_oinv_rec);
    -- Set primary key value
    l_oinv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_oinv_rec,                        -- IN
      l_def_oinv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oinv_rec := fill_who_columns(l_def_oinv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oinv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oinv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_oinv_rec, l_oin_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oin_rec,
      lx_oin_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oin_rec, l_def_oinv_rec);
    -- Set OUT values
    x_oinv_rec := l_def_oinv_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:OINV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    x_oinv_tbl                     OUT NOCOPY oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      i := p_oinv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_oinv_rec                     => p_oinv_tbl(i),
            x_oinv_rec                     => x_oinv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_oinv_tbl.LAST);
        i := p_oinv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ----------------------------------------
  -- PL/SQL TBL insert_row for:OINV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    x_oinv_tbl                     OUT NOCOPY oinv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oinv_tbl                     => p_oinv_tbl,
        x_oinv_tbl                     => x_oinv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  -------------------------------
  -- lock_row for:OKL_OPEN_INT --
  -------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oin_rec                      IN oin_rec_type) AS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oin_rec IN oin_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPEN_INT
     WHERE ID = p_oin_rec.id
       AND OBJECT_VERSION_NUMBER = p_oin_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_oin_rec IN oin_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPEN_INT
     WHERE ID = p_oin_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_OPEN_INT.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_OPEN_INT.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_oin_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_oin_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_oin_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_oin_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------
  -- lock_row for: OKL_OPEN_INT_V --
  ----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oin_rec                      oin_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_oinv_rec, l_oin_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oin_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:OINV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      i := p_oinv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_oinv_rec                     => p_oinv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_oinv_tbl.LAST);
        i := p_oinv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:OINV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oinv_tbl                     => p_oinv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ---------------------------------
  -- update_row for:OKL_OPEN_INT --
  ---------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oin_rec                      IN oin_rec_type,
    x_oin_rec                      OUT NOCOPY oin_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oin_rec                      oin_rec_type := p_oin_rec;
    l_def_oin_rec                  oin_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oin_rec IN oin_rec_type,
      x_oin_rec OUT NOCOPY oin_rec_type
    ) RETURN VARCHAR2 AS
      l_oin_rec                      oin_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oin_rec := p_oin_rec;
      -- Get current database values
      l_oin_rec := get_rec(p_oin_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oin_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.id := l_oin_rec.id;
        END IF;
        IF (x_oin_rec.party_id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.party_id := l_oin_rec.party_id;
        END IF;
        IF (x_oin_rec.party_name = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.party_name := l_oin_rec.party_name;
        END IF;
        IF (x_oin_rec.party_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.party_type := l_oin_rec.party_type;
        END IF;
        IF (x_oin_rec.date_of_birth = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.date_of_birth := l_oin_rec.date_of_birth;
        END IF;
        IF (x_oin_rec.place_of_birth = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.place_of_birth := l_oin_rec.place_of_birth;
        END IF;
        IF (x_oin_rec.person_identifier = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.person_identifier := l_oin_rec.person_identifier;
        END IF;
        IF (x_oin_rec.person_iden_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.person_iden_type := l_oin_rec.person_iden_type;
        END IF;
        IF (x_oin_rec.country = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.country := l_oin_rec.country;
        END IF;
        IF (x_oin_rec.address1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.address1 := l_oin_rec.address1;
        END IF;
        IF (x_oin_rec.address2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.address2 := l_oin_rec.address2;
        END IF;
        IF (x_oin_rec.address3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.address3 := l_oin_rec.address3;
        END IF;
        IF (x_oin_rec.address4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.address4 := l_oin_rec.address4;
        END IF;
        IF (x_oin_rec.city = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.city := l_oin_rec.city;
        END IF;
        IF (x_oin_rec.postal_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.postal_code := l_oin_rec.postal_code;
        END IF;
        IF (x_oin_rec.state = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.state := l_oin_rec.state;
        END IF;
        IF (x_oin_rec.province = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.province := l_oin_rec.province;
        END IF;
        IF (x_oin_rec.county = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.county := l_oin_rec.county;
        END IF;
        IF (x_oin_rec.po_box_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.po_box_number := l_oin_rec.po_box_number;
        END IF;
        IF (x_oin_rec.house_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.house_number := l_oin_rec.house_number;
        END IF;
        IF (x_oin_rec.street_suffix = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.street_suffix := l_oin_rec.street_suffix;
        END IF;
        IF (x_oin_rec.apartment_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.apartment_number := l_oin_rec.apartment_number;
        END IF;
        IF (x_oin_rec.street = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.street := l_oin_rec.street;
        END IF;
        IF (x_oin_rec.rural_route_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.rural_route_number := l_oin_rec.rural_route_number;
        END IF;
        IF (x_oin_rec.street_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.street_number := l_oin_rec.street_number;
        END IF;
        IF (x_oin_rec.building = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.building := l_oin_rec.building;
        END IF;
        IF (x_oin_rec.floor = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.floor := l_oin_rec.floor;
        END IF;
        IF (x_oin_rec.suite = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.suite := l_oin_rec.suite;
        END IF;
        IF (x_oin_rec.room = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.room := l_oin_rec.room;
        END IF;
        IF (x_oin_rec.postal_plus4_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.postal_plus4_code := l_oin_rec.postal_plus4_code;
        END IF;
        IF (x_oin_rec.cas_id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.cas_id := l_oin_rec.cas_id;
        END IF;
        IF (x_oin_rec.case_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.case_number := l_oin_rec.case_number;
        END IF;
        IF (x_oin_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.khr_id := l_oin_rec.khr_id;
        END IF;
        IF (x_oin_rec.contract_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.contract_number := l_oin_rec.contract_number;
        END IF;
        IF (x_oin_rec.contract_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.contract_type := l_oin_rec.contract_type;
        END IF;
        IF (x_oin_rec.contract_status = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.contract_status := l_oin_rec.contract_status;
        END IF;
        IF (x_oin_rec.original_amount = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.original_amount := l_oin_rec.original_amount;
        END IF;
        IF (x_oin_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.start_date := l_oin_rec.start_date;
        END IF;
        IF (x_oin_rec.close_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.close_date := l_oin_rec.close_date;
        END IF;
        IF (x_oin_rec.term_duration = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.term_duration := l_oin_rec.term_duration;
        END IF;
        IF (x_oin_rec.monthly_payment_amount = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.monthly_payment_amount := l_oin_rec.monthly_payment_amount;
        END IF;
        IF (x_oin_rec.last_payment_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.last_payment_date := l_oin_rec.last_payment_date;
        END IF;
        IF (x_oin_rec.delinquency_occurance_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.delinquency_occurance_date := l_oin_rec.delinquency_occurance_date;
        END IF;
        IF (x_oin_rec.past_due_amount = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.past_due_amount := l_oin_rec.past_due_amount;
        END IF;
        IF (x_oin_rec.remaining_amount = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.remaining_amount := l_oin_rec.remaining_amount;
        END IF;
        IF (x_oin_rec.credit_indicator = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.credit_indicator := l_oin_rec.credit_indicator;
        END IF;
        IF (x_oin_rec.notification_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.notification_date := l_oin_rec.notification_date;
        END IF;
        IF (x_oin_rec.credit_bureau_report_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.credit_bureau_report_date := l_oin_rec.credit_bureau_report_date;
        END IF;
        IF (x_oin_rec.external_agency_transfer_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.external_agency_transfer_date := l_oin_rec.external_agency_transfer_date;
        END IF;
        IF (x_oin_rec.external_agency_recall_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.external_agency_recall_date := l_oin_rec.external_agency_recall_date;
        END IF;
        IF (x_oin_rec.referral_number = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.referral_number := l_oin_rec.referral_number;
        END IF;
        IF (x_oin_rec.contact_id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.contact_id := l_oin_rec.contact_id;
        END IF;
        IF (x_oin_rec.contact_name = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.contact_name := l_oin_rec.contact_name;
        END IF;
        IF (x_oin_rec.contact_phone = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.contact_phone := l_oin_rec.contact_phone;
        END IF;
        IF (x_oin_rec.contact_email = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.contact_email := l_oin_rec.contact_email;
        END IF;
        IF (x_oin_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.object_version_number := l_oin_rec.object_version_number;
        END IF;
        IF (x_oin_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.org_id := l_oin_rec.org_id;
        END IF;
        IF (x_oin_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.request_id := l_oin_rec.request_id;
        END IF;
        IF (x_oin_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.program_application_id := l_oin_rec.program_application_id;
        END IF;
        IF (x_oin_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.program_id := l_oin_rec.program_id;
        END IF;
        IF (x_oin_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.program_update_date := l_oin_rec.program_update_date;
        END IF;
        IF (x_oin_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute_category := l_oin_rec.attribute_category;
        END IF;
        IF (x_oin_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute1 := l_oin_rec.attribute1;
        END IF;
        IF (x_oin_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute2 := l_oin_rec.attribute2;
        END IF;
        IF (x_oin_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute3 := l_oin_rec.attribute3;
        END IF;
        IF (x_oin_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute4 := l_oin_rec.attribute4;
        END IF;
        IF (x_oin_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute5 := l_oin_rec.attribute5;
        END IF;
        IF (x_oin_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute6 := l_oin_rec.attribute6;
        END IF;
        IF (x_oin_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute7 := l_oin_rec.attribute7;
        END IF;
        IF (x_oin_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute8 := l_oin_rec.attribute8;
        END IF;
        IF (x_oin_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute9 := l_oin_rec.attribute9;
        END IF;
        IF (x_oin_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute10 := l_oin_rec.attribute10;
        END IF;
        IF (x_oin_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute11 := l_oin_rec.attribute11;
        END IF;
        IF (x_oin_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute12 := l_oin_rec.attribute12;
        END IF;
        IF (x_oin_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute13 := l_oin_rec.attribute13;
        END IF;
        IF (x_oin_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute14 := l_oin_rec.attribute14;
        END IF;
        IF (x_oin_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_oin_rec.attribute15 := l_oin_rec.attribute15;
        END IF;
        IF (x_oin_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.created_by := l_oin_rec.created_by;
        END IF;
        IF (x_oin_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.creation_date := l_oin_rec.creation_date;
        END IF;
        IF (x_oin_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.last_updated_by := l_oin_rec.last_updated_by;
        END IF;
        IF (x_oin_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oin_rec.last_update_date := l_oin_rec.last_update_date;
        END IF;
        IF (x_oin_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oin_rec.last_update_login := l_oin_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_oin_rec IN oin_rec_type,
      x_oin_rec OUT NOCOPY oin_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oin_rec := p_oin_rec;
      x_oin_rec.OBJECT_VERSION_NUMBER := p_oin_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_oin_rec,                         -- IN
      l_oin_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oin_rec, l_def_oin_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_OPEN_INT
    SET PARTY_ID = l_def_oin_rec.party_id,
        PARTY_NAME = l_def_oin_rec.party_name,
        PARTY_TYPE = l_def_oin_rec.party_type,
        DATE_OF_BIRTH = l_def_oin_rec.date_of_birth,
        PLACE_OF_BIRTH = l_def_oin_rec.place_of_birth,
        PERSON_IDENTIFIER = l_def_oin_rec.person_identifier,
        PERSON_IDEN_TYPE = l_def_oin_rec.person_iden_type,
        COUNTRY = l_def_oin_rec.country,
        ADDRESS1 = l_def_oin_rec.address1,
        ADDRESS2 = l_def_oin_rec.address2,
        ADDRESS3 = l_def_oin_rec.address3,
        ADDRESS4 = l_def_oin_rec.address4,
        CITY = l_def_oin_rec.city,
        POSTAL_CODE = l_def_oin_rec.postal_code,
        STATE = l_def_oin_rec.state,
        PROVINCE = l_def_oin_rec.province,
        COUNTY = l_def_oin_rec.county,
        PO_BOX_NUMBER = l_def_oin_rec.po_box_number,
        HOUSE_NUMBER = l_def_oin_rec.house_number,
        STREET_SUFFIX = l_def_oin_rec.street_suffix,
        APARTMENT_NUMBER = l_def_oin_rec.apartment_number,
        STREET = l_def_oin_rec.street,
        RURAL_ROUTE_NUMBER = l_def_oin_rec.rural_route_number,
        STREET_NUMBER = l_def_oin_rec.street_number,
        BUILDING = l_def_oin_rec.building,
        FLOOR = l_def_oin_rec.floor,
        SUITE = l_def_oin_rec.suite,
        ROOM = l_def_oin_rec.room,
        POSTAL_PLUS4_CODE = l_def_oin_rec.postal_plus4_code,
        CAS_ID = l_def_oin_rec.cas_id,
        CASE_NUMBER = l_def_oin_rec.case_number,
        KHR_ID = l_def_oin_rec.khr_id,
        CONTRACT_NUMBER = l_def_oin_rec.contract_number,
        CONTRACT_TYPE = l_def_oin_rec.contract_type,
        CONTRACT_STATUS = l_def_oin_rec.contract_status,
        ORIGINAL_AMOUNT = l_def_oin_rec.original_amount,
        START_DATE = l_def_oin_rec.start_date,
        CLOSE_DATE = l_def_oin_rec.close_date,
        TERM_DURATION = l_def_oin_rec.term_duration,
        MONTHLY_PAYMENT_AMOUNT = l_def_oin_rec.monthly_payment_amount,
        LAST_PAYMENT_DATE = l_def_oin_rec.last_payment_date,
        DELINQUENCY_OCCURANCE_DATE = l_def_oin_rec.delinquency_occurance_date,
        PAST_DUE_AMOUNT = l_def_oin_rec.past_due_amount,
        REMAINING_AMOUNT = l_def_oin_rec.remaining_amount,
        CREDIT_INDICATOR = l_def_oin_rec.credit_indicator,
        NOTIFICATION_DATE = l_def_oin_rec.notification_date,
        CREDIT_BUREAU_REPORT_DATE = l_def_oin_rec.credit_bureau_report_date,
        EXTERNAL_AGENCY_TRANSFER_DATE = l_def_oin_rec.external_agency_transfer_date,
        EXTERNAL_AGENCY_RECALL_DATE = l_def_oin_rec.external_agency_recall_date,
        REFERRAL_NUMBER = l_def_oin_rec.referral_number,
        CONTACT_ID = l_def_oin_rec.contact_id,
        CONTACT_NAME = l_def_oin_rec.contact_name,
        CONTACT_PHONE = l_def_oin_rec.contact_phone,
        CONTACT_EMAIL = l_def_oin_rec.contact_email,
        OBJECT_VERSION_NUMBER = l_def_oin_rec.object_version_number,
        ORG_ID = l_def_oin_rec.org_id,
        REQUEST_ID = l_def_oin_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_oin_rec.program_application_id,
        PROGRAM_ID = l_def_oin_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_oin_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_oin_rec.attribute_category,
        ATTRIBUTE1 = l_def_oin_rec.attribute1,
        ATTRIBUTE2 = l_def_oin_rec.attribute2,
        ATTRIBUTE3 = l_def_oin_rec.attribute3,
        ATTRIBUTE4 = l_def_oin_rec.attribute4,
        ATTRIBUTE5 = l_def_oin_rec.attribute5,
        ATTRIBUTE6 = l_def_oin_rec.attribute6,
        ATTRIBUTE7 = l_def_oin_rec.attribute7,
        ATTRIBUTE8 = l_def_oin_rec.attribute8,
        ATTRIBUTE9 = l_def_oin_rec.attribute9,
        ATTRIBUTE10 = l_def_oin_rec.attribute10,
        ATTRIBUTE11 = l_def_oin_rec.attribute11,
        ATTRIBUTE12 = l_def_oin_rec.attribute12,
        ATTRIBUTE13 = l_def_oin_rec.attribute13,
        ATTRIBUTE14 = l_def_oin_rec.attribute14,
        ATTRIBUTE15 = l_def_oin_rec.attribute15,
        CREATED_BY = l_def_oin_rec.created_by,
        CREATION_DATE = l_def_oin_rec.creation_date,
        LAST_UPDATED_BY = l_def_oin_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_oin_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_oin_rec.last_update_login
    WHERE ID = l_def_oin_rec.id;

    x_oin_rec := l_oin_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------
  -- update_row for:OKL_OPEN_INT_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type,
    x_oinv_rec                     OUT NOCOPY oinv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oinv_rec                     oinv_rec_type := p_oinv_rec;
    l_def_oinv_rec                 oinv_rec_type;
    l_db_oinv_rec                  oinv_rec_type;
    l_oin_rec                      oin_rec_type;
    lx_oin_rec                     oin_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oinv_rec IN oinv_rec_type
    ) RETURN oinv_rec_type AS
      l_oinv_rec oinv_rec_type := p_oinv_rec;
    BEGIN
      l_oinv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_oinv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oinv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oinv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oinv_rec IN oinv_rec_type,
      x_oinv_rec OUT NOCOPY oinv_rec_type
    ) RETURN VARCHAR2 AS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oinv_rec := p_oinv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_oinv_rec := get_rec(p_oinv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oinv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.id := l_db_oinv_rec.id;
        END IF;
        IF (x_oinv_rec.party_id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.party_id := l_db_oinv_rec.party_id;
        END IF;
        IF (x_oinv_rec.party_name = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.party_name := l_db_oinv_rec.party_name;
        END IF;
        IF (x_oinv_rec.party_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.party_type := l_db_oinv_rec.party_type;
        END IF;
        IF (x_oinv_rec.date_of_birth = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.date_of_birth := l_db_oinv_rec.date_of_birth;
        END IF;
        IF (x_oinv_rec.place_of_birth = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.place_of_birth := l_db_oinv_rec.place_of_birth;
        END IF;
        IF (x_oinv_rec.person_identifier = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.person_identifier := l_db_oinv_rec.person_identifier;
        END IF;
        IF (x_oinv_rec.person_iden_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.person_iden_type := l_db_oinv_rec.person_iden_type;
        END IF;
        IF (x_oinv_rec.country = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.country := l_db_oinv_rec.country;
        END IF;
        IF (x_oinv_rec.address1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.address1 := l_db_oinv_rec.address1;
        END IF;
        IF (x_oinv_rec.address2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.address2 := l_db_oinv_rec.address2;
        END IF;
        IF (x_oinv_rec.address3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.address3 := l_db_oinv_rec.address3;
        END IF;
        IF (x_oinv_rec.address4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.address4 := l_db_oinv_rec.address4;
        END IF;
        IF (x_oinv_rec.city = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.city := l_db_oinv_rec.city;
        END IF;
        IF (x_oinv_rec.postal_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.postal_code := l_db_oinv_rec.postal_code;
        END IF;
        IF (x_oinv_rec.state = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.state := l_db_oinv_rec.state;
        END IF;
        IF (x_oinv_rec.province = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.province := l_db_oinv_rec.province;
        END IF;
        IF (x_oinv_rec.county = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.county := l_db_oinv_rec.county;
        END IF;
        IF (x_oinv_rec.po_box_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.po_box_number := l_db_oinv_rec.po_box_number;
        END IF;
        IF (x_oinv_rec.house_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.house_number := l_db_oinv_rec.house_number;
        END IF;
        IF (x_oinv_rec.street_suffix = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.street_suffix := l_db_oinv_rec.street_suffix;
        END IF;
        IF (x_oinv_rec.apartment_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.apartment_number := l_db_oinv_rec.apartment_number;
        END IF;
        IF (x_oinv_rec.street = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.street := l_db_oinv_rec.street;
        END IF;
        IF (x_oinv_rec.rural_route_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.rural_route_number := l_db_oinv_rec.rural_route_number;
        END IF;
        IF (x_oinv_rec.street_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.street_number := l_db_oinv_rec.street_number;
        END IF;
        IF (x_oinv_rec.building = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.building := l_db_oinv_rec.building;
        END IF;
        IF (x_oinv_rec.floor = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.floor := l_db_oinv_rec.floor;
        END IF;
        IF (x_oinv_rec.suite = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.suite := l_db_oinv_rec.suite;
        END IF;
        IF (x_oinv_rec.room = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.room := l_db_oinv_rec.room;
        END IF;
        IF (x_oinv_rec.postal_plus4_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.postal_plus4_code := l_db_oinv_rec.postal_plus4_code;
        END IF;
        IF (x_oinv_rec.cas_id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.cas_id := l_db_oinv_rec.cas_id;
        END IF;
        IF (x_oinv_rec.case_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.case_number := l_db_oinv_rec.case_number;
        END IF;
        IF (x_oinv_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.khr_id := l_db_oinv_rec.khr_id;
        END IF;
        IF (x_oinv_rec.contract_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.contract_number := l_db_oinv_rec.contract_number;
        END IF;
        IF (x_oinv_rec.contract_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.contract_type := l_db_oinv_rec.contract_type;
        END IF;
        IF (x_oinv_rec.contract_status = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.contract_status := l_db_oinv_rec.contract_status;
        END IF;
        IF (x_oinv_rec.original_amount = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.original_amount := l_db_oinv_rec.original_amount;
        END IF;
        IF (x_oinv_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.start_date := l_db_oinv_rec.start_date;
        END IF;
        IF (x_oinv_rec.close_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.close_date := l_db_oinv_rec.close_date;
        END IF;
        IF (x_oinv_rec.term_duration = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.term_duration := l_db_oinv_rec.term_duration;
        END IF;
        IF (x_oinv_rec.monthly_payment_amount = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.monthly_payment_amount := l_db_oinv_rec.monthly_payment_amount;
        END IF;
        IF (x_oinv_rec.last_payment_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.last_payment_date := l_db_oinv_rec.last_payment_date;
        END IF;
        IF (x_oinv_rec.delinquency_occurance_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.delinquency_occurance_date := l_db_oinv_rec.delinquency_occurance_date;
        END IF;
        IF (x_oinv_rec.past_due_amount = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.past_due_amount := l_db_oinv_rec.past_due_amount;
        END IF;
        IF (x_oinv_rec.remaining_amount = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.remaining_amount := l_db_oinv_rec.remaining_amount;
        END IF;
        IF (x_oinv_rec.credit_indicator = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.credit_indicator := l_db_oinv_rec.credit_indicator;
        END IF;
        IF (x_oinv_rec.notification_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.notification_date := l_db_oinv_rec.notification_date;
        END IF;
        IF (x_oinv_rec.credit_bureau_report_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.credit_bureau_report_date := l_db_oinv_rec.credit_bureau_report_date;
        END IF;
        IF (x_oinv_rec.external_agency_transfer_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.external_agency_transfer_date := l_db_oinv_rec.external_agency_transfer_date;
        END IF;
        IF (x_oinv_rec.external_agency_recall_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.external_agency_recall_date := l_db_oinv_rec.external_agency_recall_date;
        END IF;
        IF (x_oinv_rec.referral_number = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.referral_number := l_db_oinv_rec.referral_number;
        END IF;
        IF (x_oinv_rec.contact_id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.contact_id := l_db_oinv_rec.contact_id;
        END IF;
        IF (x_oinv_rec.contact_name = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.contact_name := l_db_oinv_rec.contact_name;
        END IF;
        IF (x_oinv_rec.contact_phone = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.contact_phone := l_db_oinv_rec.contact_phone;
        END IF;
        IF (x_oinv_rec.contact_email = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.contact_email := l_db_oinv_rec.contact_email;
        END IF;
        IF (x_oinv_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.object_version_number := l_db_oinv_rec.object_version_number;
        END IF;
        IF (x_oinv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.org_id := l_db_oinv_rec.org_id;
        END IF;
        IF (x_oinv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.request_id := l_db_oinv_rec.request_id;
        END IF;
        IF (x_oinv_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.program_application_id := l_db_oinv_rec.program_application_id;
        END IF;
        IF (x_oinv_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.program_id := l_db_oinv_rec.program_id;
        END IF;
        IF (x_oinv_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.program_update_date := l_db_oinv_rec.program_update_date;
        END IF;
        IF (x_oinv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute_category := l_db_oinv_rec.attribute_category;
        END IF;
        IF (x_oinv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute1 := l_db_oinv_rec.attribute1;
        END IF;
        IF (x_oinv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute2 := l_db_oinv_rec.attribute2;
        END IF;
        IF (x_oinv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute3 := l_db_oinv_rec.attribute3;
        END IF;
        IF (x_oinv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute4 := l_db_oinv_rec.attribute4;
        END IF;
        IF (x_oinv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute5 := l_db_oinv_rec.attribute5;
        END IF;
        IF (x_oinv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute6 := l_db_oinv_rec.attribute6;
        END IF;
        IF (x_oinv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute7 := l_db_oinv_rec.attribute7;
        END IF;
        IF (x_oinv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute8 := l_db_oinv_rec.attribute8;
        END IF;
        IF (x_oinv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute9 := l_db_oinv_rec.attribute9;
        END IF;
        IF (x_oinv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute10 := l_db_oinv_rec.attribute10;
        END IF;
        IF (x_oinv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute11 := l_db_oinv_rec.attribute11;
        END IF;
        IF (x_oinv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute12 := l_db_oinv_rec.attribute12;
        END IF;
        IF (x_oinv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute13 := l_db_oinv_rec.attribute13;
        END IF;
        IF (x_oinv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute14 := l_db_oinv_rec.attribute14;
        END IF;
        IF (x_oinv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_oinv_rec.attribute15 := l_db_oinv_rec.attribute15;
        END IF;
        IF (x_oinv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.created_by := l_db_oinv_rec.created_by;
        END IF;
        IF (x_oinv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.creation_date := l_db_oinv_rec.creation_date;
        END IF;
        IF (x_oinv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.last_updated_by := l_db_oinv_rec.last_updated_by;
        END IF;
        IF (x_oinv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oinv_rec.last_update_date := l_db_oinv_rec.last_update_date;
        END IF;
        IF (x_oinv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oinv_rec.last_update_login := l_db_oinv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_oinv_rec IN oinv_rec_type,
      x_oinv_rec OUT NOCOPY oinv_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oinv_rec := p_oinv_rec;

      -- Begin Post-Generation Change
      IF (x_oinv_rec.request_id IS NULL OR x_oinv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
        SELECT NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID), x_oinv_rec.request_id),
             NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID), x_oinv_rec.program_application_id),
             NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID), x_oinv_rec.program_id),
             DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE), NULL,x_oinv_rec.program_update_date,SYSDATE)
        INTO
        x_oinv_rec.request_id,
        x_oinv_rec.program_application_id,
        x_oinv_rec.program_id,
        x_oinv_rec.program_update_date
        FROM   dual;
      END IF;
      -- End Post-Generation Change

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_oinv_rec,                        -- IN
      x_oinv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(x_oinv_rec, l_def_oinv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oinv_rec := fill_who_columns(l_def_oinv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oinv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oinv_rec, l_db_oinv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    /*
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_oinv_rec                     => p_oinv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    */

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_oinv_rec, l_oin_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oin_rec,
      lx_oin_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oin_rec, l_def_oinv_rec);
    x_oinv_rec := l_def_oinv_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:oinv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    x_oinv_tbl                     OUT NOCOPY oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      i := p_oinv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_oinv_rec                     => p_oinv_tbl(i),
            x_oinv_rec                     => x_oinv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_oinv_tbl.LAST);
        i := p_oinv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ----------------------------------------
  -- PL/SQL TBL update_row for:OINV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    x_oinv_tbl                     OUT NOCOPY oinv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oinv_tbl                     => p_oinv_tbl,
        x_oinv_tbl                     => x_oinv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ---------------------------------
  -- delete_row for:OKL_OPEN_INT --
  ---------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oin_rec                      IN oin_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oin_rec                      oin_rec_type := p_oin_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_OPEN_INT
     WHERE ID = p_oin_rec.id;

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------
  -- delete_row for:OKL_OPEN_INT_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oinv_rec                     oinv_rec_type := p_oinv_rec;
    l_oin_rec                      oin_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_oinv_rec, l_oin_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oin_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_OPEN_INT_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      i := p_oinv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_oinv_rec                     => p_oinv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_oinv_tbl.LAST);
        i := p_oinv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ----------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_OPEN_INT_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oinv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oinv_tbl                     => p_oinv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_OIN_PVT;

/
