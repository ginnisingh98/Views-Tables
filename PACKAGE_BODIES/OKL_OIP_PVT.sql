--------------------------------------------------------
--  DDL for Package Body OKL_OIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OIP_PVT" AS
/* $Header: OKLSOIPB.pls 120.2 2006/07/11 10:24:11 dkagrawa noship $ */
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
  -- FUNCTION get_rec for: OKL_OPEN_INT_PRTY_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oipv_rec                     IN oipv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oipv_rec_type AS
    CURSOR OKL_OPEN_INT_PRTY_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            PARTY_ID,
            PARTY_NAME,
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
            PHONE_COUNTRY_CODE,
            PHONE_AREA_CODE,
            PHONE_NUMBER,
            PHONE_EXTENSION,
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
      FROM OKL_OPEN_INT_PRTY
     WHERE OKL_OPEN_INT_PRTY.id = p_id;
    l_OKL_OPEN_INT_PRTY_pk       OKL_OPEN_INT_PRTY_pk_csr%ROWTYPE;
    l_oipv_rec                     oipv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN OKL_OPEN_INT_PRTY_pk_csr (p_oipv_rec.id);
    FETCH OKL_OPEN_INT_PRTY_pk_csr INTO
              l_oipv_rec.id,
              l_oipv_rec.khr_id,
              l_oipv_rec.party_id,
              l_oipv_rec.party_name,
              l_oipv_rec.country,
              l_oipv_rec.address1,
              l_oipv_rec.address2,
              l_oipv_rec.address3,
              l_oipv_rec.address4,
              l_oipv_rec.city,
              l_oipv_rec.postal_code,
              l_oipv_rec.state,
              l_oipv_rec.province,
              l_oipv_rec.county,
              l_oipv_rec.po_box_number,
              l_oipv_rec.house_number,
              l_oipv_rec.street_suffix,
              l_oipv_rec.apartment_number,
              l_oipv_rec.street,
              l_oipv_rec.rural_route_number,
              l_oipv_rec.street_number,
              l_oipv_rec.building,
              l_oipv_rec.floor,
              l_oipv_rec.suite,
              l_oipv_rec.room,
              l_oipv_rec.postal_plus4_code,
              l_oipv_rec.phone_country_code,
              l_oipv_rec.phone_area_code,
              l_oipv_rec.phone_number,
              l_oipv_rec.phone_extension,
              l_oipv_rec.object_version_number,
              l_oipv_rec.org_id,
              l_oipv_rec.request_id,
              l_oipv_rec.program_application_id,
              l_oipv_rec.program_id,
              l_oipv_rec.program_update_date,
              l_oipv_rec.attribute_category,
              l_oipv_rec.attribute1,
              l_oipv_rec.attribute2,
              l_oipv_rec.attribute3,
              l_oipv_rec.attribute4,
              l_oipv_rec.attribute5,
              l_oipv_rec.attribute6,
              l_oipv_rec.attribute7,
              l_oipv_rec.attribute8,
              l_oipv_rec.attribute9,
              l_oipv_rec.attribute10,
              l_oipv_rec.attribute11,
              l_oipv_rec.attribute12,
              l_oipv_rec.attribute13,
              l_oipv_rec.attribute14,
              l_oipv_rec.attribute15,
              l_oipv_rec.created_by,
              l_oipv_rec.creation_date,
              l_oipv_rec.last_updated_by,
              l_oipv_rec.last_update_date,
              l_oipv_rec.last_update_login;
    x_no_data_found := OKL_OPEN_INT_PRTY_pk_csr%NOTFOUND;
    CLOSE OKL_OPEN_INT_PRTY_pk_csr;
    RETURN(l_oipv_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oipv_rec                     IN oipv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oipv_rec_type AS
    l_oipv_rec                     oipv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oipv_rec := get_rec(p_oipv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oipv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oipv_rec                     IN oipv_rec_type
  ) RETURN oipv_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oipv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPEN_INT_PRTY
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oip_rec                      IN oip_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oip_rec_type AS
    CURSOR okl_oip_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            PARTY_ID,
            PARTY_NAME,
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
            PHONE_COUNTRY_CODE,
            PHONE_AREA_CODE,
            PHONE_NUMBER,
            PHONE_EXTENSION,
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
      FROM Okl_Open_Int_Prty
     WHERE okl_open_int_prty.id = p_id;
    l_okl_oip_pk                   okl_oip_pk_csr%ROWTYPE;
    l_oip_rec                      oip_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_oip_pk_csr (p_oip_rec.id);
    FETCH okl_oip_pk_csr INTO
              l_oip_rec.id,
              l_oip_rec.khr_id,
              l_oip_rec.party_id,
              l_oip_rec.party_name,
              l_oip_rec.country,
              l_oip_rec.address1,
              l_oip_rec.address2,
              l_oip_rec.address3,
              l_oip_rec.address4,
              l_oip_rec.city,
              l_oip_rec.postal_code,
              l_oip_rec.state,
              l_oip_rec.province,
              l_oip_rec.county,
              l_oip_rec.po_box_number,
              l_oip_rec.house_number,
              l_oip_rec.street_suffix,
              l_oip_rec.apartment_number,
              l_oip_rec.street,
              l_oip_rec.rural_route_number,
              l_oip_rec.street_number,
              l_oip_rec.building,
              l_oip_rec.floor,
              l_oip_rec.suite,
              l_oip_rec.room,
              l_oip_rec.postal_plus4_code,
              l_oip_rec.phone_country_code,
              l_oip_rec.phone_area_code,
              l_oip_rec.phone_number,
              l_oip_rec.phone_extension,
              l_oip_rec.object_version_number,
              l_oip_rec.org_id,
              l_oip_rec.request_id,
              l_oip_rec.program_application_id,
              l_oip_rec.program_id,
              l_oip_rec.program_update_date,
              l_oip_rec.attribute_category,
              l_oip_rec.attribute1,
              l_oip_rec.attribute2,
              l_oip_rec.attribute3,
              l_oip_rec.attribute4,
              l_oip_rec.attribute5,
              l_oip_rec.attribute6,
              l_oip_rec.attribute7,
              l_oip_rec.attribute8,
              l_oip_rec.attribute9,
              l_oip_rec.attribute10,
              l_oip_rec.attribute11,
              l_oip_rec.attribute12,
              l_oip_rec.attribute13,
              l_oip_rec.attribute14,
              l_oip_rec.attribute15,
              l_oip_rec.created_by,
              l_oip_rec.creation_date,
              l_oip_rec.last_updated_by,
              l_oip_rec.last_update_date,
              l_oip_rec.last_update_login;
    x_no_data_found := okl_oip_pk_csr%NOTFOUND;
    CLOSE okl_oip_pk_csr;
    RETURN(l_oip_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oip_rec                      IN oip_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oip_rec_type AS
    l_oip_rec                      oip_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oip_rec := get_rec(p_oip_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oip_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oip_rec                      IN oip_rec_type
  ) RETURN oip_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oip_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_OPEN_INT_PRTY_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_oipv_rec   IN oipv_rec_type
  ) RETURN oipv_rec_type AS
    l_oipv_rec                     oipv_rec_type := p_oipv_rec;
  BEGIN
    IF (l_oipv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.id := NULL;
    END IF;
    IF (l_oipv_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.khr_id := NULL;
    END IF;
    IF (l_oipv_rec.party_id = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.party_id := NULL;
    END IF;
    IF (l_oipv_rec.party_name = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.party_name := NULL;
    END IF;
    IF (l_oipv_rec.country = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.country := NULL;
    END IF;
    IF (l_oipv_rec.address1 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.address1 := NULL;
    END IF;
    IF (l_oipv_rec.address2 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.address2 := NULL;
    END IF;
    IF (l_oipv_rec.address3 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.address3 := NULL;
    END IF;
    IF (l_oipv_rec.address4 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.address4 := NULL;
    END IF;
    IF (l_oipv_rec.city = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.city := NULL;
    END IF;
    IF (l_oipv_rec.postal_code = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.postal_code := NULL;
    END IF;
    IF (l_oipv_rec.state = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.state := NULL;
    END IF;
    IF (l_oipv_rec.province = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.province := NULL;
    END IF;
    IF (l_oipv_rec.county = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.county := NULL;
    END IF;
    IF (l_oipv_rec.po_box_number = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.po_box_number := NULL;
    END IF;
    IF (l_oipv_rec.house_number = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.house_number := NULL;
    END IF;
    IF (l_oipv_rec.street_suffix = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.street_suffix := NULL;
    END IF;
    IF (l_oipv_rec.apartment_number = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.apartment_number := NULL;
    END IF;
    IF (l_oipv_rec.street = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.street := NULL;
    END IF;
    IF (l_oipv_rec.rural_route_number = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.rural_route_number := NULL;
    END IF;
    IF (l_oipv_rec.street_number = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.street_number := NULL;
    END IF;
    IF (l_oipv_rec.building = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.building := NULL;
    END IF;
    IF (l_oipv_rec.floor = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.floor := NULL;
    END IF;
    IF (l_oipv_rec.suite = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.suite := NULL;
    END IF;
    IF (l_oipv_rec.room = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.room := NULL;
    END IF;
    IF (l_oipv_rec.postal_plus4_code = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.postal_plus4_code := NULL;
    END IF;
    IF (l_oipv_rec.phone_country_code = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.phone_country_code := NULL;
    END IF;
    IF (l_oipv_rec.phone_area_code = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.phone_area_code := NULL;
    END IF;
    IF (l_oipv_rec.phone_number = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.phone_number := NULL;
    END IF;
    IF (l_oipv_rec.phone_extension = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.phone_extension := NULL;
    END IF;
    IF (l_oipv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.object_version_number := NULL;
    END IF;
    IF (l_oipv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.org_id := NULL;
    END IF;
    IF (l_oipv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.request_id := NULL;
    END IF;
    IF (l_oipv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.program_application_id := NULL;
    END IF;
    IF (l_oipv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.program_id := NULL;
    END IF;
    IF (l_oipv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oipv_rec.program_update_date := NULL;
    END IF;
    IF (l_oipv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute_category := NULL;
    END IF;
    IF (l_oipv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute1 := NULL;
    END IF;
    IF (l_oipv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute2 := NULL;
    END IF;
    IF (l_oipv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute3 := NULL;
    END IF;
    IF (l_oipv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute4 := NULL;
    END IF;
    IF (l_oipv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute5 := NULL;
    END IF;
    IF (l_oipv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute6 := NULL;
    END IF;
    IF (l_oipv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute7 := NULL;
    END IF;
    IF (l_oipv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute8 := NULL;
    END IF;
    IF (l_oipv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute9 := NULL;
    END IF;
    IF (l_oipv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute10 := NULL;
    END IF;
    IF (l_oipv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute11 := NULL;
    END IF;
    IF (l_oipv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute12 := NULL;
    END IF;
    IF (l_oipv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute13 := NULL;
    END IF;
    IF (l_oipv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute14 := NULL;
    END IF;
    IF (l_oipv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_oipv_rec.attribute15 := NULL;
    END IF;
    IF (l_oipv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.created_by := NULL;
    END IF;
    IF (l_oipv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_oipv_rec.creation_date := NULL;
    END IF;
    IF (l_oipv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.last_updated_by := NULL;
    END IF;
    IF (l_oipv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oipv_rec.last_update_date := NULL;
    END IF;
    IF (l_oipv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_oipv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_oipv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oipv_rec.id = OKC_API.G_MISS_NUM OR
        p_oipv_rec.id IS NULL)
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
  -------------------------------------
  -- Validate_Attributes for: KHR_ID --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oipv_rec.khr_id = OKC_API.G_MISS_NUM OR
        p_oipv_rec.khr_id IS NULL)
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
  ---------------------------------------
  -- Validate_Attributes for: PARTY_ID --
  ---------------------------------------
  PROCEDURE validate_party_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oipv_rec.party_id = OKC_API.G_MISS_NUM OR
        p_oipv_rec.party_id IS NULL)
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
    p_oipv_rec                     IN oipv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oipv_rec.party_name = OKC_API.G_MISS_CHAR OR
        p_oipv_rec.party_name IS NULL)
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
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oipv_rec.object_version_number = OKC_API.G_MISS_NUM OR
        p_oipv_rec.object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
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
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_OPEN_INT_PRTY_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_oipv_rec                     IN oipv_rec_type
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
    validate_id(l_return_status, p_oipv_rec);
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
    validate_khr_id(l_return_status, p_oipv_rec);
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
    validate_party_id(l_return_status, p_oipv_rec);
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
    validate_party_name(l_return_status, p_oipv_rec);
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
    validate_object_version_number(x_return_status, p_oipv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */
    RETURN(x_return_status);
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
  ---------------------------------------------
  -- Validate Record for:OKL_OPEN_INT_PRTY_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_oipv_rec IN oipv_rec_type,
    p_db_oipv_rec IN oipv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_oipv_rec IN oipv_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_oipv_rec                  oipv_rec_type := get_rec(p_oipv_rec);
  BEGIN
    l_return_status := Validate_Record(p_oipv_rec => p_oipv_rec,
                                       p_db_oipv_rec => l_db_oipv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN oipv_rec_type,
    p_to   IN OUT NOCOPY oip_rec_type
  ) AS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.party_id := p_from.party_id;
    p_to.party_name := p_from.party_name;
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
    p_to.phone_country_code := p_from.phone_country_code;
    p_to.phone_area_code := p_from.phone_area_code;
    p_to.phone_number := p_from.phone_number;
    p_to.phone_extension := p_from.phone_extension;
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
    p_from IN oip_rec_type,
    p_to   IN OUT NOCOPY oipv_rec_type
  ) AS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.party_id := p_from.party_id;
    p_to.party_name := p_from.party_name;
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
    p_to.phone_country_code := p_from.phone_country_code;
    p_to.phone_area_code := p_from.phone_area_code;
    p_to.phone_number := p_from.phone_number;
    p_to.phone_extension := p_from.phone_extension;
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
  ------------------------------------------
  -- validate_row for:OKL_OPEN_INT_PRTY_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oipv_rec                     oipv_rec_type := p_oipv_rec;
    l_oip_rec                      oip_rec_type;
    l_oip_rec                      oip_rec_type;
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
    l_return_status := Validate_Attributes(l_oipv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_oipv_rec);
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
  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_OPEN_INT_PRTY_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      i := p_oipv_tbl.FIRST;
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
            p_oipv_rec                     => p_oipv_tbl(i));
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
        EXIT WHEN (i = p_oipv_tbl.LAST);
        i := p_oipv_tbl.NEXT(i);
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
  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_OPEN_INT_PRTY_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oipv_tbl                     => p_oipv_tbl,
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
  --------------------------------------
  -- insert_row for:OKL_OPEN_INT_PRTY --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oip_rec                      IN oip_rec_type,
    x_oip_rec                      OUT NOCOPY oip_rec_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oip_rec                      oip_rec_type := p_oip_rec;
    l_def_oip_rec                  oip_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_PRTY --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_oip_rec IN oip_rec_type,
      x_oip_rec OUT NOCOPY oip_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oip_rec := p_oip_rec;
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
      p_oip_rec,                         -- IN
      l_oip_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_OPEN_INT_PRTY(
      id,
      khr_id,
      party_id,
      party_name,
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
      phone_country_code,
      phone_area_code,
      phone_number,
      phone_extension,
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
      l_oip_rec.id,
      l_oip_rec.khr_id,
      l_oip_rec.party_id,
      l_oip_rec.party_name,
      l_oip_rec.country,
      l_oip_rec.address1,
      l_oip_rec.address2,
      l_oip_rec.address3,
      l_oip_rec.address4,
      l_oip_rec.city,
      l_oip_rec.postal_code,
      l_oip_rec.state,
      l_oip_rec.province,
      l_oip_rec.county,
      l_oip_rec.po_box_number,
      l_oip_rec.house_number,
      l_oip_rec.street_suffix,
      l_oip_rec.apartment_number,
      l_oip_rec.street,
      l_oip_rec.rural_route_number,
      l_oip_rec.street_number,
      l_oip_rec.building,
      l_oip_rec.floor,
      l_oip_rec.suite,
      l_oip_rec.room,
      l_oip_rec.postal_plus4_code,
      l_oip_rec.phone_country_code,
      l_oip_rec.phone_area_code,
      l_oip_rec.phone_number,
      l_oip_rec.phone_extension,
      l_oip_rec.object_version_number,
      l_oip_rec.org_id,
      l_oip_rec.request_id,
      l_oip_rec.program_application_id,
      l_oip_rec.program_id,
      l_oip_rec.program_update_date,
      l_oip_rec.attribute_category,
      l_oip_rec.attribute1,
      l_oip_rec.attribute2,
      l_oip_rec.attribute3,
      l_oip_rec.attribute4,
      l_oip_rec.attribute5,
      l_oip_rec.attribute6,
      l_oip_rec.attribute7,
      l_oip_rec.attribute8,
      l_oip_rec.attribute9,
      l_oip_rec.attribute10,
      l_oip_rec.attribute11,
      l_oip_rec.attribute12,
      l_oip_rec.attribute13,
      l_oip_rec.attribute14,
      l_oip_rec.attribute15,
      l_oip_rec.created_by,
      l_oip_rec.creation_date,
      l_oip_rec.last_updated_by,
      l_oip_rec.last_update_date,
      l_oip_rec.last_update_login);
    -- Set OUT values
    x_oip_rec := l_oip_rec;
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
  -----------------------------------------
  -- insert_row for :OKL_OPEN_INT_PRTY_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type,
    x_oipv_rec                     OUT NOCOPY oipv_rec_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oipv_rec                     oipv_rec_type := p_oipv_rec;
    l_def_oipv_rec                 oipv_rec_type;
    l_oip_rec                      oip_rec_type;
    lx_oip_rec                     oip_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oipv_rec IN oipv_rec_type
    ) RETURN oipv_rec_type AS
      l_oipv_rec oipv_rec_type := p_oipv_rec;
    BEGIN
      l_oipv_rec.CREATION_DATE := SYSDATE;
      l_oipv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_oipv_rec.LAST_UPDATE_DATE := l_oipv_rec.CREATION_DATE;
      l_oipv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oipv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oipv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_PRTY_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_oipv_rec IN oipv_rec_type,
      x_oipv_rec OUT NOCOPY oipv_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oipv_rec := p_oipv_rec;
      x_oipv_rec.OBJECT_VERSION_NUMBER := 1;

      -- Begin Post-Generation Change
      IF (x_oipv_rec.request_id IS NULL OR x_oipv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_oipv_rec.request_id,
	  	   x_oipv_rec.program_application_id,
	  	   x_oipv_rec.program_id,
	  	   x_oipv_rec.program_update_date
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
    l_oipv_rec := null_out_defaults(p_oipv_rec);
    -- Set primary key value
    l_oipv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_oipv_rec,                        -- IN
      l_def_oipv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oipv_rec := fill_who_columns(l_def_oipv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oipv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oipv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_oipv_rec, l_oip_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oip_rec,
      lx_oip_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oip_rec, l_def_oipv_rec);
    -- Set OUT values
    x_oipv_rec := l_def_oipv_rec;
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
  -- PL/SQL TBL insert_row for:OIPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type,
    x_oipv_tbl                     OUT NOCOPY oipv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      i := p_oipv_tbl.FIRST;
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
            p_oipv_rec                     => p_oipv_tbl(i),
            x_oipv_rec                     => x_oipv_tbl(i));
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
        EXIT WHEN (i = p_oipv_tbl.LAST);
        i := p_oipv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:OIPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type,
    x_oipv_tbl                     OUT NOCOPY oipv_tbl_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oipv_tbl                     => p_oipv_tbl,
        x_oipv_tbl                     => x_oipv_tbl,
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
  ------------------------------------
  -- lock_row for:OKL_OPEN_INT_PRTY --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oip_rec                      IN oip_rec_type) AS
    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oip_rec IN oip_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPEN_INT_PRTY
     WHERE ID = p_oip_rec.id
       AND OBJECT_VERSION_NUMBER = p_oip_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;
    CURSOR lchk_csr (p_oip_rec IN oip_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPEN_INT_PRTY
     WHERE ID = p_oip_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_OPEN_INT_PRTY.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_OPEN_INT_PRTY.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_oip_rec);
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
      OPEN lchk_csr(p_oip_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_oip_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_oip_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for: OKL_OPEN_INT_PRTY_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oip_rec                      oip_rec_type;
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
    migrate(p_oipv_rec, l_oip_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oip_rec
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
  -- PL/SQL TBL lock_row for:OIPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      i := p_oipv_tbl.FIRST;
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
            p_oipv_rec                     => p_oipv_tbl(i));
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
        EXIT WHEN (i = p_oipv_tbl.LAST);
        i := p_oipv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:OIPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oipv_tbl                     => p_oipv_tbl,
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
  --------------------------------------
  -- update_row for:OKL_OPEN_INT_PRTY --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oip_rec                      IN oip_rec_type,
    x_oip_rec                      OUT NOCOPY oip_rec_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oip_rec                      oip_rec_type := p_oip_rec;
    l_def_oip_rec                  oip_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oip_rec IN oip_rec_type,
      x_oip_rec OUT NOCOPY oip_rec_type
    ) RETURN VARCHAR2 AS
      l_oip_rec                      oip_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oip_rec := p_oip_rec;
      -- Get current database values
      l_oip_rec := get_rec(p_oip_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oip_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.id := l_oip_rec.id;
        END IF;
        IF (x_oip_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.khr_id := l_oip_rec.khr_id;
        END IF;
        IF (x_oip_rec.party_id = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.party_id := l_oip_rec.party_id;
        END IF;
        IF (x_oip_rec.party_name = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.party_name := l_oip_rec.party_name;
        END IF;
        IF (x_oip_rec.country = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.country := l_oip_rec.country;
        END IF;
        IF (x_oip_rec.address1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.address1 := l_oip_rec.address1;
        END IF;
        IF (x_oip_rec.address2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.address2 := l_oip_rec.address2;
        END IF;
        IF (x_oip_rec.address3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.address3 := l_oip_rec.address3;
        END IF;
        IF (x_oip_rec.address4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.address4 := l_oip_rec.address4;
        END IF;
        IF (x_oip_rec.city = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.city := l_oip_rec.city;
        END IF;
        IF (x_oip_rec.postal_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.postal_code := l_oip_rec.postal_code;
        END IF;
        IF (x_oip_rec.state = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.state := l_oip_rec.state;
        END IF;
        IF (x_oip_rec.province = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.province := l_oip_rec.province;
        END IF;
        IF (x_oip_rec.county = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.county := l_oip_rec.county;
        END IF;
        IF (x_oip_rec.po_box_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.po_box_number := l_oip_rec.po_box_number;
        END IF;
        IF (x_oip_rec.house_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.house_number := l_oip_rec.house_number;
        END IF;
        IF (x_oip_rec.street_suffix = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.street_suffix := l_oip_rec.street_suffix;
        END IF;
        IF (x_oip_rec.apartment_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.apartment_number := l_oip_rec.apartment_number;
        END IF;
        IF (x_oip_rec.street = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.street := l_oip_rec.street;
        END IF;
        IF (x_oip_rec.rural_route_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.rural_route_number := l_oip_rec.rural_route_number;
        END IF;
        IF (x_oip_rec.street_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.street_number := l_oip_rec.street_number;
        END IF;
        IF (x_oip_rec.building = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.building := l_oip_rec.building;
        END IF;
        IF (x_oip_rec.floor = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.floor := l_oip_rec.floor;
        END IF;
        IF (x_oip_rec.suite = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.suite := l_oip_rec.suite;
        END IF;
        IF (x_oip_rec.room = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.room := l_oip_rec.room;
        END IF;
        IF (x_oip_rec.postal_plus4_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.postal_plus4_code := l_oip_rec.postal_plus4_code;
        END IF;
        IF (x_oip_rec.phone_country_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.phone_country_code := l_oip_rec.phone_country_code;
        END IF;
        IF (x_oip_rec.phone_area_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.phone_area_code := l_oip_rec.phone_area_code;
        END IF;
        IF (x_oip_rec.phone_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.phone_number := l_oip_rec.phone_number;
        END IF;
        IF (x_oip_rec.phone_extension = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.phone_extension := l_oip_rec.phone_extension;
        END IF;
        IF (x_oip_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.object_version_number := l_oip_rec.object_version_number;
        END IF;
        IF (x_oip_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.org_id := l_oip_rec.org_id;
        END IF;
        IF (x_oip_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.request_id := l_oip_rec.request_id;
        END IF;
        IF (x_oip_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.program_application_id := l_oip_rec.program_application_id;
        END IF;
        IF (x_oip_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.program_id := l_oip_rec.program_id;
        END IF;
        IF (x_oip_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oip_rec.program_update_date := l_oip_rec.program_update_date;
        END IF;
        IF (x_oip_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute_category := l_oip_rec.attribute_category;
        END IF;
        IF (x_oip_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute1 := l_oip_rec.attribute1;
        END IF;
        IF (x_oip_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute2 := l_oip_rec.attribute2;
        END IF;
        IF (x_oip_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute3 := l_oip_rec.attribute3;
        END IF;
        IF (x_oip_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute4 := l_oip_rec.attribute4;
        END IF;
        IF (x_oip_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute5 := l_oip_rec.attribute5;
        END IF;
        IF (x_oip_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute6 := l_oip_rec.attribute6;
        END IF;
        IF (x_oip_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute7 := l_oip_rec.attribute7;
        END IF;
        IF (x_oip_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute8 := l_oip_rec.attribute8;
        END IF;
        IF (x_oip_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute9 := l_oip_rec.attribute9;
        END IF;
        IF (x_oip_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute10 := l_oip_rec.attribute10;
        END IF;
        IF (x_oip_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute11 := l_oip_rec.attribute11;
        END IF;
        IF (x_oip_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute12 := l_oip_rec.attribute12;
        END IF;
        IF (x_oip_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute13 := l_oip_rec.attribute13;
        END IF;
        IF (x_oip_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute14 := l_oip_rec.attribute14;
        END IF;
        IF (x_oip_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_oip_rec.attribute15 := l_oip_rec.attribute15;
        END IF;
        IF (x_oip_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.created_by := l_oip_rec.created_by;
        END IF;
        IF (x_oip_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oip_rec.creation_date := l_oip_rec.creation_date;
        END IF;
        IF (x_oip_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.last_updated_by := l_oip_rec.last_updated_by;
        END IF;
        IF (x_oip_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oip_rec.last_update_date := l_oip_rec.last_update_date;
        END IF;
        IF (x_oip_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oip_rec.last_update_login := l_oip_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_PRTY --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_oip_rec IN oip_rec_type,
      x_oip_rec OUT NOCOPY oip_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oip_rec := p_oip_rec;
      x_oip_rec.OBJECT_VERSION_NUMBER := p_oip_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_oip_rec,                         -- IN
      l_oip_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oip_rec, l_def_oip_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_OPEN_INT_PRTY
    SET KHR_ID = l_def_oip_rec.khr_id,
        PARTY_ID = l_def_oip_rec.party_id,
        PARTY_NAME = l_def_oip_rec.party_name,
        COUNTRY = l_def_oip_rec.country,
        ADDRESS1 = l_def_oip_rec.address1,
        ADDRESS2 = l_def_oip_rec.address2,
        ADDRESS3 = l_def_oip_rec.address3,
        ADDRESS4 = l_def_oip_rec.address4,
        CITY = l_def_oip_rec.city,
        POSTAL_CODE = l_def_oip_rec.postal_code,
        STATE = l_def_oip_rec.state,
        PROVINCE = l_def_oip_rec.province,
        COUNTY = l_def_oip_rec.county,
        PO_BOX_NUMBER = l_def_oip_rec.po_box_number,
        HOUSE_NUMBER = l_def_oip_rec.house_number,
        STREET_SUFFIX = l_def_oip_rec.street_suffix,
        APARTMENT_NUMBER = l_def_oip_rec.apartment_number,
        STREET = l_def_oip_rec.street,
        RURAL_ROUTE_NUMBER = l_def_oip_rec.rural_route_number,
        STREET_NUMBER = l_def_oip_rec.street_number,
        BUILDING = l_def_oip_rec.building,
        FLOOR = l_def_oip_rec.floor,
        SUITE = l_def_oip_rec.suite,
        ROOM = l_def_oip_rec.room,
        POSTAL_PLUS4_CODE = l_def_oip_rec.postal_plus4_code,
        PHONE_COUNTRY_CODE = l_def_oip_rec.phone_country_code,
        PHONE_AREA_CODE = l_def_oip_rec.phone_area_code,
        PHONE_NUMBER = l_def_oip_rec.phone_number,
        PHONE_EXTENSION = l_def_oip_rec.phone_extension,
        OBJECT_VERSION_NUMBER = l_def_oip_rec.object_version_number,
        ORG_ID = l_def_oip_rec.org_id,
        REQUEST_ID = l_def_oip_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_oip_rec.program_application_id,
        PROGRAM_ID = l_def_oip_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_oip_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_oip_rec.attribute_category,
        ATTRIBUTE1 = l_def_oip_rec.attribute1,
        ATTRIBUTE2 = l_def_oip_rec.attribute2,
        ATTRIBUTE3 = l_def_oip_rec.attribute3,
        ATTRIBUTE4 = l_def_oip_rec.attribute4,
        ATTRIBUTE5 = l_def_oip_rec.attribute5,
        ATTRIBUTE6 = l_def_oip_rec.attribute6,
        ATTRIBUTE7 = l_def_oip_rec.attribute7,
        ATTRIBUTE8 = l_def_oip_rec.attribute8,
        ATTRIBUTE9 = l_def_oip_rec.attribute9,
        ATTRIBUTE10 = l_def_oip_rec.attribute10,
        ATTRIBUTE11 = l_def_oip_rec.attribute11,
        ATTRIBUTE12 = l_def_oip_rec.attribute12,
        ATTRIBUTE13 = l_def_oip_rec.attribute13,
        ATTRIBUTE14 = l_def_oip_rec.attribute14,
        ATTRIBUTE15 = l_def_oip_rec.attribute15,
        CREATED_BY = l_def_oip_rec.created_by,
        CREATION_DATE = l_def_oip_rec.creation_date,
        LAST_UPDATED_BY = l_def_oip_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_oip_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_oip_rec.last_update_login
    WHERE ID = l_def_oip_rec.id;
    x_oip_rec := l_oip_rec;
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
  -- update_row for:OKL_OPEN_INT_PRTY_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type,
    x_oipv_rec                     OUT NOCOPY oipv_rec_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oipv_rec                     oipv_rec_type := p_oipv_rec;
    l_def_oipv_rec                 oipv_rec_type;
    l_db_oipv_rec                  oipv_rec_type;
    l_oip_rec                      oip_rec_type;
    lx_oip_rec                     oip_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oipv_rec IN oipv_rec_type
    ) RETURN oipv_rec_type AS
      l_oipv_rec oipv_rec_type := p_oipv_rec;
    BEGIN
      l_oipv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_oipv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oipv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oipv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oipv_rec IN oipv_rec_type,
      x_oipv_rec OUT NOCOPY oipv_rec_type
    ) RETURN VARCHAR2 AS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oipv_rec := p_oipv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_oipv_rec := get_rec(p_oipv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oipv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.id := l_db_oipv_rec.id;
        END IF;
        IF (x_oipv_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.khr_id := l_db_oipv_rec.khr_id;
        END IF;
        IF (x_oipv_rec.party_id = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.party_id := l_db_oipv_rec.party_id;
        END IF;
        IF (x_oipv_rec.party_name = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.party_name := l_db_oipv_rec.party_name;
        END IF;
        IF (x_oipv_rec.country = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.country := l_db_oipv_rec.country;
        END IF;
        IF (x_oipv_rec.address1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.address1 := l_db_oipv_rec.address1;
        END IF;
        IF (x_oipv_rec.address2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.address2 := l_db_oipv_rec.address2;
        END IF;
        IF (x_oipv_rec.address3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.address3 := l_db_oipv_rec.address3;
        END IF;
        IF (x_oipv_rec.address4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.address4 := l_db_oipv_rec.address4;
        END IF;
        IF (x_oipv_rec.city = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.city := l_db_oipv_rec.city;
        END IF;
        IF (x_oipv_rec.postal_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.postal_code := l_db_oipv_rec.postal_code;
        END IF;
        IF (x_oipv_rec.state = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.state := l_db_oipv_rec.state;
        END IF;
        IF (x_oipv_rec.province = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.province := l_db_oipv_rec.province;
        END IF;
        IF (x_oipv_rec.county = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.county := l_db_oipv_rec.county;
        END IF;
        IF (x_oipv_rec.po_box_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.po_box_number := l_db_oipv_rec.po_box_number;
        END IF;
        IF (x_oipv_rec.house_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.house_number := l_db_oipv_rec.house_number;
        END IF;
        IF (x_oipv_rec.street_suffix = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.street_suffix := l_db_oipv_rec.street_suffix;
        END IF;
        IF (x_oipv_rec.apartment_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.apartment_number := l_db_oipv_rec.apartment_number;
        END IF;
        IF (x_oipv_rec.street = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.street := l_db_oipv_rec.street;
        END IF;
        IF (x_oipv_rec.rural_route_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.rural_route_number := l_db_oipv_rec.rural_route_number;
        END IF;
        IF (x_oipv_rec.street_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.street_number := l_db_oipv_rec.street_number;
        END IF;
        IF (x_oipv_rec.building = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.building := l_db_oipv_rec.building;
        END IF;
        IF (x_oipv_rec.floor = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.floor := l_db_oipv_rec.floor;
        END IF;
        IF (x_oipv_rec.suite = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.suite := l_db_oipv_rec.suite;
        END IF;
        IF (x_oipv_rec.room = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.room := l_db_oipv_rec.room;
        END IF;
        IF (x_oipv_rec.postal_plus4_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.postal_plus4_code := l_db_oipv_rec.postal_plus4_code;
        END IF;
        IF (x_oipv_rec.phone_country_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.phone_country_code := l_db_oipv_rec.phone_country_code;
        END IF;
        IF (x_oipv_rec.phone_area_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.phone_area_code := l_db_oipv_rec.phone_area_code;
        END IF;
        IF (x_oipv_rec.phone_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.phone_number := l_db_oipv_rec.phone_number;
        END IF;
        IF (x_oipv_rec.phone_extension = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.phone_extension := l_db_oipv_rec.phone_extension;
        END IF;
        IF (x_oipv_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.object_version_number := l_db_oipv_rec.object_version_number;
        END IF;
        IF (x_oipv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.org_id := l_db_oipv_rec.org_id;
        END IF;
        IF (x_oipv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.request_id := l_db_oipv_rec.request_id;
        END IF;
        IF (x_oipv_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.program_application_id := l_db_oipv_rec.program_application_id;
        END IF;
        IF (x_oipv_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.program_id := l_db_oipv_rec.program_id;
        END IF;
        IF (x_oipv_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oipv_rec.program_update_date := l_db_oipv_rec.program_update_date;
        END IF;
        IF (x_oipv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute_category := l_db_oipv_rec.attribute_category;
        END IF;
        IF (x_oipv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute1 := l_db_oipv_rec.attribute1;
        END IF;
        IF (x_oipv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute2 := l_db_oipv_rec.attribute2;
        END IF;
        IF (x_oipv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute3 := l_db_oipv_rec.attribute3;
        END IF;
        IF (x_oipv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute4 := l_db_oipv_rec.attribute4;
        END IF;
        IF (x_oipv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute5 := l_db_oipv_rec.attribute5;
        END IF;
        IF (x_oipv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute6 := l_db_oipv_rec.attribute6;
        END IF;
        IF (x_oipv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute7 := l_db_oipv_rec.attribute7;
        END IF;
        IF (x_oipv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute8 := l_db_oipv_rec.attribute8;
        END IF;
        IF (x_oipv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute9 := l_db_oipv_rec.attribute9;
        END IF;
        IF (x_oipv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute10 := l_db_oipv_rec.attribute10;
        END IF;
        IF (x_oipv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute11 := l_db_oipv_rec.attribute11;
        END IF;
        IF (x_oipv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute12 := l_db_oipv_rec.attribute12;
        END IF;
        IF (x_oipv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute13 := l_db_oipv_rec.attribute13;
        END IF;
        IF (x_oipv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute14 := l_db_oipv_rec.attribute14;
        END IF;
        IF (x_oipv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_oipv_rec.attribute15 := l_db_oipv_rec.attribute15;
        END IF;
        IF (x_oipv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.created_by := l_db_oipv_rec.created_by;
        END IF;
        IF (x_oipv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oipv_rec.creation_date := l_db_oipv_rec.creation_date;
        END IF;
        IF (x_oipv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.last_updated_by := l_db_oipv_rec.last_updated_by;
        END IF;
        IF (x_oipv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oipv_rec.last_update_date := l_db_oipv_rec.last_update_date;
        END IF;
        IF (x_oipv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oipv_rec.last_update_login := l_db_oipv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_PRTY_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_oipv_rec IN oipv_rec_type,
      x_oipv_rec OUT NOCOPY oipv_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oipv_rec := p_oipv_rec;

      -- Begin Post-Generation Change
      IF (x_oipv_rec.request_id IS NULL OR x_oipv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
        SELECT NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID), x_oipv_rec.request_id),
             NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID), x_oipv_rec.program_application_id),
             NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID), x_oipv_rec.program_id),
             DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE), NULL,x_oipv_rec.program_update_date,SYSDATE)
        INTO
        x_oipv_rec.request_id,
        x_oipv_rec.program_application_id,
        x_oipv_rec.program_id,
        x_oipv_rec.program_update_date
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
      p_oipv_rec,                        -- IN
      x_oipv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(x_oipv_rec, l_def_oipv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oipv_rec := fill_who_columns(l_def_oipv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oipv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oipv_rec, l_db_oipv_rec);
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
      p_oipv_rec                     => p_oipv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    */
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_oipv_rec, l_oip_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oip_rec,
      lx_oip_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oip_rec, l_def_oipv_rec);
    x_oipv_rec := l_def_oipv_rec;
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
  -- PL/SQL TBL update_row for:oipv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type,
    x_oipv_tbl                     OUT NOCOPY oipv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      i := p_oipv_tbl.FIRST;
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
            p_oipv_rec                     => p_oipv_tbl(i),
            x_oipv_rec                     => x_oipv_tbl(i));
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
        EXIT WHEN (i = p_oipv_tbl.LAST);
        i := p_oipv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:OIPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type,
    x_oipv_tbl                     OUT NOCOPY oipv_tbl_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oipv_tbl                     => p_oipv_tbl,
        x_oipv_tbl                     => x_oipv_tbl,
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
  --------------------------------------
  -- delete_row for:OKL_OPEN_INT_PRTY --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oip_rec                      IN oip_rec_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oip_rec                      oip_rec_type := p_oip_rec;
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
    DELETE FROM OKL_OPEN_INT_PRTY
     WHERE ID = p_oip_rec.id;
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
  ----------------------------------------
  -- delete_row for:OKL_OPEN_INT_PRTY_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_rec                     IN oipv_rec_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oipv_rec                     oipv_rec_type := p_oipv_rec;
    l_oip_rec                      oip_rec_type;
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
    migrate(l_oipv_rec, l_oip_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oip_rec
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
  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_OPEN_INT_PRTY_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      i := p_oipv_tbl.FIRST;
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
            p_oipv_rec                     => p_oipv_tbl(i));
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
        EXIT WHEN (i = p_oipv_tbl.LAST);
        i := p_oipv_tbl.NEXT(i);
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
  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_OPEN_INT_PRTY_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oipv_tbl                     IN oipv_tbl_type) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oipv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oipv_tbl                     => p_oipv_tbl,
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
END OKL_OIP_PVT;

/
