--------------------------------------------------------
--  DDL for Package Body OKL_OIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OIA_PVT" AS
/* $Header: OKLSOIAB.pls 120.2 2006/07/11 10:22:42 dkagrawa noship $ */
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
  -- FUNCTION get_rec for: OKL_OPEN_INT_ASST_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oiav_rec                     IN oiav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oiav_rec_type AS
    CURSOR okl_oiav_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            INSTANCE_NUMBER,
            ASSET_ID,
            ASSET_NUMBER,
            DESCRIPTION,
            ASSET_TYPE,
            MANUFACTURER_NAME,
            MODEL_NUMBER,
            SERIAL_NUMBER,
            TAG_NUMBER,
            ORIGINAL_COST,
            QUANTITY,
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
      FROM OKL_OPEN_INT_ASST
     WHERE OKL_OPEN_INT_ASST.id = p_id;
    l_okl_oiav_pk                  okl_oiav_pk_csr%ROWTYPE;
    l_oiav_rec                     oiav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_oiav_pk_csr (p_oiav_rec.id);
    FETCH okl_oiav_pk_csr INTO
              l_oiav_rec.id,
              l_oiav_rec.khr_id,
              l_oiav_rec.instance_number,
              l_oiav_rec.asset_id,
              l_oiav_rec.asset_number,
              l_oiav_rec.description,
              l_oiav_rec.asset_type,
              l_oiav_rec.manufacturer_name,
              l_oiav_rec.model_number,
              l_oiav_rec.serial_number,
              l_oiav_rec.tag_number,
              l_oiav_rec.original_cost,
              l_oiav_rec.quantity,
              l_oiav_rec.country,
              l_oiav_rec.address1,
              l_oiav_rec.address2,
              l_oiav_rec.address3,
              l_oiav_rec.address4,
              l_oiav_rec.city,
              l_oiav_rec.postal_code,
              l_oiav_rec.state,
              l_oiav_rec.province,
              l_oiav_rec.county,
              l_oiav_rec.po_box_number,
              l_oiav_rec.house_number,
              l_oiav_rec.street_suffix,
              l_oiav_rec.apartment_number,
              l_oiav_rec.street,
              l_oiav_rec.rural_route_number,
              l_oiav_rec.street_number,
              l_oiav_rec.building,
              l_oiav_rec.floor,
              l_oiav_rec.suite,
              l_oiav_rec.room,
              l_oiav_rec.postal_plus4_code,
              l_oiav_rec.object_version_number,
              l_oiav_rec.org_id,
              l_oiav_rec.request_id,
              l_oiav_rec.program_application_id,
              l_oiav_rec.program_id,
              l_oiav_rec.program_update_date,
              l_oiav_rec.attribute_category,
              l_oiav_rec.attribute1,
              l_oiav_rec.attribute2,
              l_oiav_rec.attribute3,
              l_oiav_rec.attribute4,
              l_oiav_rec.attribute5,
              l_oiav_rec.attribute6,
              l_oiav_rec.attribute7,
              l_oiav_rec.attribute8,
              l_oiav_rec.attribute9,
              l_oiav_rec.attribute10,
              l_oiav_rec.attribute11,
              l_oiav_rec.attribute12,
              l_oiav_rec.attribute13,
              l_oiav_rec.attribute14,
              l_oiav_rec.attribute15,
              l_oiav_rec.created_by,
              l_oiav_rec.creation_date,
              l_oiav_rec.last_updated_by,
              l_oiav_rec.last_update_date,
              l_oiav_rec.last_update_login;
    x_no_data_found := okl_oiav_pk_csr%NOTFOUND;
    CLOSE okl_oiav_pk_csr;
    RETURN(l_oiav_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oiav_rec                     IN oiav_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oiav_rec_type AS
    l_oiav_rec                     oiav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oiav_rec := get_rec(p_oiav_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oiav_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oiav_rec                     IN oiav_rec_type
  ) RETURN oiav_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oiav_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPEN_INT_ASST
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oia_rec                      IN oia_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oia_rec_type AS
    CURSOR okl_oia_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            INSTANCE_NUMBER,
            ASSET_ID,
            ASSET_NUMBER,
            DESCRIPTION,
            ASSET_TYPE,
            MANUFACTURER_NAME,
            MODEL_NUMBER,
            SERIAL_NUMBER,
            TAG_NUMBER,
            ORIGINAL_COST,
            QUANTITY,
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
      FROM Okl_Open_Int_Asst
     WHERE okl_open_int_asst.id = p_id;
    l_okl_oia_pk                   okl_oia_pk_csr%ROWTYPE;
    l_oia_rec                      oia_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_oia_pk_csr (p_oia_rec.id);
    FETCH okl_oia_pk_csr INTO
              l_oia_rec.id,
              l_oia_rec.khr_id,
              l_oia_rec.instance_number,
              l_oia_rec.asset_id,
              l_oia_rec.asset_number,
              l_oia_rec.description,
              l_oia_rec.asset_type,
              l_oia_rec.manufacturer_name,
              l_oia_rec.model_number,
              l_oia_rec.serial_number,
              l_oia_rec.tag_number,
              l_oia_rec.original_cost,
              l_oia_rec.quantity,
              l_oia_rec.country,
              l_oia_rec.address1,
              l_oia_rec.address2,
              l_oia_rec.address3,
              l_oia_rec.address4,
              l_oia_rec.city,
              l_oia_rec.postal_code,
              l_oia_rec.state,
              l_oia_rec.province,
              l_oia_rec.county,
              l_oia_rec.po_box_number,
              l_oia_rec.house_number,
              l_oia_rec.street_suffix,
              l_oia_rec.apartment_number,
              l_oia_rec.street,
              l_oia_rec.rural_route_number,
              l_oia_rec.street_number,
              l_oia_rec.building,
              l_oia_rec.floor,
              l_oia_rec.suite,
              l_oia_rec.room,
              l_oia_rec.postal_plus4_code,
              l_oia_rec.object_version_number,
              l_oia_rec.org_id,
              l_oia_rec.request_id,
              l_oia_rec.program_application_id,
              l_oia_rec.program_id,
              l_oia_rec.program_update_date,
              l_oia_rec.attribute_category,
              l_oia_rec.attribute1,
              l_oia_rec.attribute2,
              l_oia_rec.attribute3,
              l_oia_rec.attribute4,
              l_oia_rec.attribute5,
              l_oia_rec.attribute6,
              l_oia_rec.attribute7,
              l_oia_rec.attribute8,
              l_oia_rec.attribute9,
              l_oia_rec.attribute10,
              l_oia_rec.attribute11,
              l_oia_rec.attribute12,
              l_oia_rec.attribute13,
              l_oia_rec.attribute14,
              l_oia_rec.attribute15,
              l_oia_rec.created_by,
              l_oia_rec.creation_date,
              l_oia_rec.last_updated_by,
              l_oia_rec.last_update_date,
              l_oia_rec.last_update_login;
    x_no_data_found := okl_oia_pk_csr%NOTFOUND;
    CLOSE okl_oia_pk_csr;
    RETURN(l_oia_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oia_rec                      IN oia_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oia_rec_type AS
    l_oia_rec                      oia_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oia_rec := get_rec(p_oia_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oia_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oia_rec                      IN oia_rec_type
  ) RETURN oia_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oia_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_OPEN_INT_ASST_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_oiav_rec   IN oiav_rec_type
  ) RETURN oiav_rec_type AS
    l_oiav_rec                     oiav_rec_type := p_oiav_rec;
  BEGIN
    IF (l_oiav_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.id := NULL;
    END IF;
    IF (l_oiav_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.khr_id := NULL;
    END IF;
    IF (l_oiav_rec.instance_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.instance_number := NULL;
    END IF;
    IF (l_oiav_rec.asset_id = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.asset_id := NULL;
    END IF;
    IF (l_oiav_rec.asset_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.asset_number := NULL;
    END IF;
    IF (l_oiav_rec.description = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.description := NULL;
    END IF;
    IF (l_oiav_rec.asset_type = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.asset_type := NULL;
    END IF;
    IF (l_oiav_rec.manufacturer_name = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.manufacturer_name := NULL;
    END IF;
    IF (l_oiav_rec.model_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.model_number := NULL;
    END IF;
    IF (l_oiav_rec.serial_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.serial_number := NULL;
    END IF;
    IF (l_oiav_rec.tag_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.tag_number := NULL;
    END IF;
    IF (l_oiav_rec.original_cost = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.original_cost := NULL;
    END IF;
    IF (l_oiav_rec.quantity = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.quantity := NULL;
    END IF;
    IF (l_oiav_rec.country = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.country := NULL;
    END IF;
    IF (l_oiav_rec.address1 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.address1 := NULL;
    END IF;
    IF (l_oiav_rec.address2 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.address2 := NULL;
    END IF;
    IF (l_oiav_rec.address3 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.address3 := NULL;
    END IF;
    IF (l_oiav_rec.address4 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.address4 := NULL;
    END IF;
    IF (l_oiav_rec.city = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.city := NULL;
    END IF;
    IF (l_oiav_rec.postal_code = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.postal_code := NULL;
    END IF;
    IF (l_oiav_rec.state = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.state := NULL;
    END IF;
    IF (l_oiav_rec.province = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.province := NULL;
    END IF;
    IF (l_oiav_rec.county = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.county := NULL;
    END IF;
    IF (l_oiav_rec.po_box_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.po_box_number := NULL;
    END IF;
    IF (l_oiav_rec.house_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.house_number := NULL;
    END IF;
    IF (l_oiav_rec.street_suffix = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.street_suffix := NULL;
    END IF;
    IF (l_oiav_rec.apartment_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.apartment_number := NULL;
    END IF;
    IF (l_oiav_rec.street = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.street := NULL;
    END IF;
    IF (l_oiav_rec.rural_route_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.rural_route_number := NULL;
    END IF;
    IF (l_oiav_rec.street_number = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.street_number := NULL;
    END IF;
    IF (l_oiav_rec.building = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.building := NULL;
    END IF;
    IF (l_oiav_rec.floor = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.floor := NULL;
    END IF;
    IF (l_oiav_rec.suite = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.suite := NULL;
    END IF;
    IF (l_oiav_rec.room = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.room := NULL;
    END IF;
    IF (l_oiav_rec.postal_plus4_code = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.postal_plus4_code := NULL;
    END IF;
    IF (l_oiav_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.object_version_number := NULL;
    END IF;
    IF (l_oiav_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.org_id := NULL;
    END IF;
    IF (l_oiav_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.request_id := NULL;
    END IF;
    IF (l_oiav_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.program_application_id := NULL;
    END IF;
    IF (l_oiav_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.program_id := NULL;
    END IF;
    IF (l_oiav_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oiav_rec.program_update_date := NULL;
    END IF;
    IF (l_oiav_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute_category := NULL;
    END IF;
    IF (l_oiav_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute1 := NULL;
    END IF;
    IF (l_oiav_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute2 := NULL;
    END IF;
    IF (l_oiav_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute3 := NULL;
    END IF;
    IF (l_oiav_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute4 := NULL;
    END IF;
    IF (l_oiav_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute5 := NULL;
    END IF;
    IF (l_oiav_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute6 := NULL;
    END IF;
    IF (l_oiav_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute7 := NULL;
    END IF;
    IF (l_oiav_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute8 := NULL;
    END IF;
    IF (l_oiav_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute9 := NULL;
    END IF;
    IF (l_oiav_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute10 := NULL;
    END IF;
    IF (l_oiav_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute11 := NULL;
    END IF;
    IF (l_oiav_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute12 := NULL;
    END IF;
    IF (l_oiav_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute13 := NULL;
    END IF;
    IF (l_oiav_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute14 := NULL;
    END IF;
    IF (l_oiav_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_oiav_rec.attribute15 := NULL;
    END IF;
    IF (l_oiav_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.created_by := NULL;
    END IF;
    IF (l_oiav_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_oiav_rec.creation_date := NULL;
    END IF;
    IF (l_oiav_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.last_updated_by := NULL;
    END IF;
    IF (l_oiav_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oiav_rec.last_update_date := NULL;
    END IF;
    IF (l_oiav_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_oiav_rec.last_update_login := NULL;
    END IF;
    RETURN(l_oiav_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oiav_rec.id = OKC_API.G_MISS_NUM OR
        p_oiav_rec.id IS NULL)
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
    p_oiav_rec                     IN oiav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oiav_rec.khr_id = OKC_API.G_MISS_NUM OR
        p_oiav_rec.khr_id IS NULL)
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
  -- Validate_Attributes for: INSTANCE_NUMBER --
  ----------------------------------------------
  PROCEDURE validate_instance_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oiav_rec.instance_number = OKC_API.G_MISS_CHAR OR
        p_oiav_rec.instance_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'instance_number');
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
  END validate_instance_number;
  ---------------------------------------
  -- Validate_Attributes for: ASSET_ID --
  ---------------------------------------
  PROCEDURE validate_asset_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_oiav_rec.asset_id = OKC_API.G_MISS_NUM OR
        p_oiav_rec.asset_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'asset_id');
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
  END validate_asset_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  /*
    IF (p_oiav_rec.object_version_number = OKC_API.G_MISS_NUM OR
        p_oiav_rec.object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
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
  -------------------------------------------------
  -- Validate_Attributes for:OKL_OPEN_INT_ASST_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_oiav_rec                     IN oiav_rec_type
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
    validate_id(l_return_status, p_oiav_rec);
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
    validate_khr_id(l_return_status, p_oiav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- instance_number
    -- ***
    validate_instance_number(l_return_status, p_oiav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- asset_id
    -- ***
    validate_asset_id(l_return_status, p_oiav_rec);
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
    validate_object_version_number(x_return_status, p_oiav_rec.object_version_number);
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
  ---------------------------------------------
  -- Validate Record for:OKL_OPEN_INT_ASST_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_oiav_rec IN oiav_rec_type,
    p_db_oiav_rec IN oiav_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_oiav_rec IN oiav_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_oiav_rec                  oiav_rec_type := get_rec(p_oiav_rec);
  BEGIN
    l_return_status := Validate_Record(p_oiav_rec => p_oiav_rec,
                                       p_db_oiav_rec => l_db_oiav_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN oiav_rec_type,
    p_to   IN OUT NOCOPY oia_rec_type
  ) AS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.instance_number := p_from.instance_number;
    p_to.asset_id := p_from.asset_id;
    p_to.asset_number := p_from.asset_number;
    p_to.description := p_from.description;
    p_to.asset_type := p_from.asset_type;
    p_to.manufacturer_name := p_from.manufacturer_name;
    p_to.model_number := p_from.model_number;
    p_to.serial_number := p_from.serial_number;
    p_to.tag_number := p_from.tag_number;
    p_to.original_cost := p_from.original_cost;
    p_to.quantity := p_from.quantity;
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
    p_from IN oia_rec_type,
    p_to   IN OUT NOCOPY oiav_rec_type
  ) AS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.instance_number := p_from.instance_number;
    p_to.asset_id := p_from.asset_id;
    p_to.asset_number := p_from.asset_number;
    p_to.description := p_from.description;
    p_to.asset_type := p_from.asset_type;
    p_to.manufacturer_name := p_from.manufacturer_name;
    p_to.model_number := p_from.model_number;
    p_to.serial_number := p_from.serial_number;
    p_to.tag_number := p_from.tag_number;
    p_to.original_cost := p_from.original_cost;
    p_to.quantity := p_from.quantity;
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
  -- validate_row for:OKL_OPEN_INT_ASST_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oiav_rec                     oiav_rec_type := p_oiav_rec;
    l_oia_rec                      oia_rec_type;
    l_oia_rec                      oia_rec_type;
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
    l_return_status := Validate_Attributes(l_oiav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_oiav_rec);
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
  -- PL/SQL TBL validate_row for:OKL_OPEN_INT_ASST_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      i := p_oiav_tbl.FIRST;
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
            p_oiav_rec                     => p_oiav_tbl(i));
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
        EXIT WHEN (i = p_oiav_tbl.LAST);
        i := p_oiav_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKL_OPEN_INT_ASST_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oiav_tbl                     => p_oiav_tbl,
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
  -- insert_row for:OKL_OPEN_INT_ASST --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oia_rec                      IN oia_rec_type,
    x_oia_rec                      OUT NOCOPY oia_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oia_rec                      oia_rec_type := p_oia_rec;
    l_def_oia_rec                  oia_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_ASST --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_oia_rec IN oia_rec_type,
      x_oia_rec OUT NOCOPY oia_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oia_rec := p_oia_rec;
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
      p_oia_rec,                         -- IN
      l_oia_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_OPEN_INT_ASST(
      id,
      khr_id,
      instance_number,
      asset_id,
      asset_number,
      description,
      asset_type,
      manufacturer_name,
      model_number,
      serial_number,
      tag_number,
      original_cost,
      quantity,
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
      l_oia_rec.id,
      l_oia_rec.khr_id,
      l_oia_rec.instance_number,
      l_oia_rec.asset_id,
      l_oia_rec.asset_number,
      l_oia_rec.description,
      l_oia_rec.asset_type,
      l_oia_rec.manufacturer_name,
      l_oia_rec.model_number,
      l_oia_rec.serial_number,
      l_oia_rec.tag_number,
      l_oia_rec.original_cost,
      l_oia_rec.quantity,
      l_oia_rec.country,
      l_oia_rec.address1,
      l_oia_rec.address2,
      l_oia_rec.address3,
      l_oia_rec.address4,
      l_oia_rec.city,
      l_oia_rec.postal_code,
      l_oia_rec.state,
      l_oia_rec.province,
      l_oia_rec.county,
      l_oia_rec.po_box_number,
      l_oia_rec.house_number,
      l_oia_rec.street_suffix,
      l_oia_rec.apartment_number,
      l_oia_rec.street,
      l_oia_rec.rural_route_number,
      l_oia_rec.street_number,
      l_oia_rec.building,
      l_oia_rec.floor,
      l_oia_rec.suite,
      l_oia_rec.room,
      l_oia_rec.postal_plus4_code,
      l_oia_rec.object_version_number,
      l_oia_rec.org_id,
      l_oia_rec.request_id,
      l_oia_rec.program_application_id,
      l_oia_rec.program_id,
      l_oia_rec.program_update_date,
      l_oia_rec.attribute_category,
      l_oia_rec.attribute1,
      l_oia_rec.attribute2,
      l_oia_rec.attribute3,
      l_oia_rec.attribute4,
      l_oia_rec.attribute5,
      l_oia_rec.attribute6,
      l_oia_rec.attribute7,
      l_oia_rec.attribute8,
      l_oia_rec.attribute9,
      l_oia_rec.attribute10,
      l_oia_rec.attribute11,
      l_oia_rec.attribute12,
      l_oia_rec.attribute13,
      l_oia_rec.attribute14,
      l_oia_rec.attribute15,
      l_oia_rec.created_by,
      l_oia_rec.creation_date,
      l_oia_rec.last_updated_by,
      l_oia_rec.last_update_date,
      l_oia_rec.last_update_login);
    -- Set OUT values
    x_oia_rec := l_oia_rec;
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
  -- insert_row for :OKL_OPEN_INT_ASST_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type,
    x_oiav_rec                     OUT NOCOPY oiav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oiav_rec                     oiav_rec_type := p_oiav_rec;
    l_def_oiav_rec                 oiav_rec_type;
    l_oia_rec                      oia_rec_type;
    lx_oia_rec                     oia_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oiav_rec IN oiav_rec_type
    ) RETURN oiav_rec_type AS
      l_oiav_rec oiav_rec_type := p_oiav_rec;
    BEGIN
      l_oiav_rec.CREATION_DATE := SYSDATE;
      l_oiav_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_oiav_rec.LAST_UPDATE_DATE := l_oiav_rec.CREATION_DATE;
      l_oiav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oiav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oiav_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_ASST_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_oiav_rec IN oiav_rec_type,
      x_oiav_rec OUT NOCOPY oiav_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oiav_rec := p_oiav_rec;
      x_oiav_rec.OBJECT_VERSION_NUMBER := 1;

      -- Begin Post-Generation Change
      IF (x_oiav_rec.request_id IS NULL OR x_oiav_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_oiav_rec.request_id,
	  	   x_oiav_rec.program_application_id,
	  	   x_oiav_rec.program_id,
	  	   x_oiav_rec.program_update_date
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
    l_oiav_rec := null_out_defaults(p_oiav_rec);
    -- Set primary key value
    l_oiav_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_oiav_rec,                        -- IN
      l_def_oiav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oiav_rec := fill_who_columns(l_def_oiav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oiav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oiav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_oiav_rec, l_oia_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oia_rec,
      lx_oia_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oia_rec, l_def_oiav_rec);
    -- Set OUT values
    x_oiav_rec := l_def_oiav_rec;
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
  -- PL/SQL TBL insert_row for:OIAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    x_oiav_tbl                     OUT NOCOPY oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      i := p_oiav_tbl.FIRST;
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
            p_oiav_rec                     => p_oiav_tbl(i),
            x_oiav_rec                     => x_oiav_tbl(i));
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
        EXIT WHEN (i = p_oiav_tbl.LAST);
        i := p_oiav_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:OIAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    x_oiav_tbl                     OUT NOCOPY oiav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oiav_tbl                     => p_oiav_tbl,
        x_oiav_tbl                     => x_oiav_tbl,
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
  -- lock_row for:OKL_OPEN_INT_ASST --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oia_rec                      IN oia_rec_type) AS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oia_rec IN oia_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPEN_INT_ASST
     WHERE ID = p_oia_rec.id
       AND OBJECT_VERSION_NUMBER = p_oia_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_oia_rec IN oia_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPEN_INT_ASST
     WHERE ID = p_oia_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_OPEN_INT_ASST.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_OPEN_INT_ASST.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_oia_rec);
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
      OPEN lchk_csr(p_oia_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_oia_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_oia_rec.object_version_number THEN
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
  -- lock_row for: OKL_OPEN_INT_ASST_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oia_rec                      oia_rec_type;
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
    migrate(p_oiav_rec, l_oia_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oia_rec
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
  -- PL/SQL TBL lock_row for:OIAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      i := p_oiav_tbl.FIRST;
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
            p_oiav_rec                     => p_oiav_tbl(i));
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
        EXIT WHEN (i = p_oiav_tbl.LAST);
        i := p_oiav_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:OIAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oiav_tbl                     => p_oiav_tbl,
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
  -- update_row for:OKL_OPEN_INT_ASST --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oia_rec                      IN oia_rec_type,
    x_oia_rec                      OUT NOCOPY oia_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oia_rec                      oia_rec_type := p_oia_rec;
    l_def_oia_rec                  oia_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oia_rec IN oia_rec_type,
      x_oia_rec OUT NOCOPY oia_rec_type
    ) RETURN VARCHAR2 AS
      l_oia_rec                      oia_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oia_rec := p_oia_rec;
      -- Get current database values
      l_oia_rec := get_rec(p_oia_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oia_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.id := l_oia_rec.id;
        END IF;
        IF (x_oia_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.khr_id := l_oia_rec.khr_id;
        END IF;
        IF (x_oia_rec.instance_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.instance_number := l_oia_rec.instance_number;
        END IF;
        IF (x_oia_rec.asset_id = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.asset_id := l_oia_rec.asset_id;
        END IF;
        IF (x_oia_rec.asset_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.asset_number := l_oia_rec.asset_number;
        END IF;
        IF (x_oia_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.description := l_oia_rec.description;
        END IF;
        IF (x_oia_rec.asset_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.asset_type := l_oia_rec.asset_type;
        END IF;
        IF (x_oia_rec.manufacturer_name = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.manufacturer_name := l_oia_rec.manufacturer_name;
        END IF;
        IF (x_oia_rec.model_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.model_number := l_oia_rec.model_number;
        END IF;
        IF (x_oia_rec.serial_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.serial_number := l_oia_rec.serial_number;
        END IF;
        IF (x_oia_rec.tag_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.tag_number := l_oia_rec.tag_number;
        END IF;
        IF (x_oia_rec.original_cost = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.original_cost := l_oia_rec.original_cost;
        END IF;
        IF (x_oia_rec.quantity = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.quantity := l_oia_rec.quantity;
        END IF;
        IF (x_oia_rec.country = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.country := l_oia_rec.country;
        END IF;
        IF (x_oia_rec.address1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.address1 := l_oia_rec.address1;
        END IF;
        IF (x_oia_rec.address2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.address2 := l_oia_rec.address2;
        END IF;
        IF (x_oia_rec.address3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.address3 := l_oia_rec.address3;
        END IF;
        IF (x_oia_rec.address4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.address4 := l_oia_rec.address4;
        END IF;
        IF (x_oia_rec.city = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.city := l_oia_rec.city;
        END IF;
        IF (x_oia_rec.postal_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.postal_code := l_oia_rec.postal_code;
        END IF;
        IF (x_oia_rec.state = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.state := l_oia_rec.state;
        END IF;
        IF (x_oia_rec.province = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.province := l_oia_rec.province;
        END IF;
        IF (x_oia_rec.county = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.county := l_oia_rec.county;
        END IF;
        IF (x_oia_rec.po_box_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.po_box_number := l_oia_rec.po_box_number;
        END IF;
        IF (x_oia_rec.house_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.house_number := l_oia_rec.house_number;
        END IF;
        IF (x_oia_rec.street_suffix = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.street_suffix := l_oia_rec.street_suffix;
        END IF;
        IF (x_oia_rec.apartment_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.apartment_number := l_oia_rec.apartment_number;
        END IF;
        IF (x_oia_rec.street = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.street := l_oia_rec.street;
        END IF;
        IF (x_oia_rec.rural_route_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.rural_route_number := l_oia_rec.rural_route_number;
        END IF;
        IF (x_oia_rec.street_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.street_number := l_oia_rec.street_number;
        END IF;
        IF (x_oia_rec.building = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.building := l_oia_rec.building;
        END IF;
        IF (x_oia_rec.floor = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.floor := l_oia_rec.floor;
        END IF;
        IF (x_oia_rec.suite = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.suite := l_oia_rec.suite;
        END IF;
        IF (x_oia_rec.room = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.room := l_oia_rec.room;
        END IF;
        IF (x_oia_rec.postal_plus4_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.postal_plus4_code := l_oia_rec.postal_plus4_code;
        END IF;
        IF (x_oia_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.object_version_number := l_oia_rec.object_version_number;
        END IF;
        IF (x_oia_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.org_id := l_oia_rec.org_id;
        END IF;
        IF (x_oia_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.request_id := l_oia_rec.request_id;
        END IF;
        IF (x_oia_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.program_application_id := l_oia_rec.program_application_id;
        END IF;
        IF (x_oia_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.program_id := l_oia_rec.program_id;
        END IF;
        IF (x_oia_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oia_rec.program_update_date := l_oia_rec.program_update_date;
        END IF;
        IF (x_oia_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute_category := l_oia_rec.attribute_category;
        END IF;
        IF (x_oia_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute1 := l_oia_rec.attribute1;
        END IF;
        IF (x_oia_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute2 := l_oia_rec.attribute2;
        END IF;
        IF (x_oia_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute3 := l_oia_rec.attribute3;
        END IF;
        IF (x_oia_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute4 := l_oia_rec.attribute4;
        END IF;
        IF (x_oia_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute5 := l_oia_rec.attribute5;
        END IF;
        IF (x_oia_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute6 := l_oia_rec.attribute6;
        END IF;
        IF (x_oia_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute7 := l_oia_rec.attribute7;
        END IF;
        IF (x_oia_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute8 := l_oia_rec.attribute8;
        END IF;
        IF (x_oia_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute9 := l_oia_rec.attribute9;
        END IF;
        IF (x_oia_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute10 := l_oia_rec.attribute10;
        END IF;
        IF (x_oia_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute11 := l_oia_rec.attribute11;
        END IF;
        IF (x_oia_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute12 := l_oia_rec.attribute12;
        END IF;
        IF (x_oia_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute13 := l_oia_rec.attribute13;
        END IF;
        IF (x_oia_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute14 := l_oia_rec.attribute14;
        END IF;
        IF (x_oia_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_oia_rec.attribute15 := l_oia_rec.attribute15;
        END IF;
        IF (x_oia_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.created_by := l_oia_rec.created_by;
        END IF;
        IF (x_oia_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oia_rec.creation_date := l_oia_rec.creation_date;
        END IF;
        IF (x_oia_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.last_updated_by := l_oia_rec.last_updated_by;
        END IF;
        IF (x_oia_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oia_rec.last_update_date := l_oia_rec.last_update_date;
        END IF;
        IF (x_oia_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oia_rec.last_update_login := l_oia_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_ASST --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_oia_rec IN oia_rec_type,
      x_oia_rec OUT NOCOPY oia_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oia_rec := p_oia_rec;
      x_oia_rec.OBJECT_VERSION_NUMBER := p_oia_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_oia_rec,                         -- IN
      l_oia_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oia_rec, l_def_oia_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_OPEN_INT_ASST
    SET KHR_ID = l_def_oia_rec.khr_id,
        INSTANCE_NUMBER = l_def_oia_rec.instance_number,
        ASSET_ID = l_def_oia_rec.asset_id,
        ASSET_NUMBER = l_def_oia_rec.asset_number,
        DESCRIPTION = l_def_oia_rec.description,
        ASSET_TYPE = l_def_oia_rec.asset_type,
        MANUFACTURER_NAME = l_def_oia_rec.manufacturer_name,
        MODEL_NUMBER = l_def_oia_rec.model_number,
        SERIAL_NUMBER = l_def_oia_rec.serial_number,
        TAG_NUMBER = l_def_oia_rec.tag_number,
        ORIGINAL_COST = l_def_oia_rec.original_cost,
        QUANTITY = l_def_oia_rec.quantity,
        COUNTRY = l_def_oia_rec.country,
        ADDRESS1 = l_def_oia_rec.address1,
        ADDRESS2 = l_def_oia_rec.address2,
        ADDRESS3 = l_def_oia_rec.address3,
        ADDRESS4 = l_def_oia_rec.address4,
        CITY = l_def_oia_rec.city,
        POSTAL_CODE = l_def_oia_rec.postal_code,
        STATE = l_def_oia_rec.state,
        PROVINCE = l_def_oia_rec.province,
        COUNTY = l_def_oia_rec.county,
        PO_BOX_NUMBER = l_def_oia_rec.po_box_number,
        HOUSE_NUMBER = l_def_oia_rec.house_number,
        STREET_SUFFIX = l_def_oia_rec.street_suffix,
        APARTMENT_NUMBER = l_def_oia_rec.apartment_number,
        STREET = l_def_oia_rec.street,
        RURAL_ROUTE_NUMBER = l_def_oia_rec.rural_route_number,
        STREET_NUMBER = l_def_oia_rec.street_number,
        BUILDING = l_def_oia_rec.building,
        FLOOR = l_def_oia_rec.floor,
        SUITE = l_def_oia_rec.suite,
        ROOM = l_def_oia_rec.room,
        POSTAL_PLUS4_CODE = l_def_oia_rec.postal_plus4_code,
        OBJECT_VERSION_NUMBER = l_def_oia_rec.object_version_number,
        ORG_ID = l_def_oia_rec.org_id,
        REQUEST_ID = l_def_oia_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_oia_rec.program_application_id,
        PROGRAM_ID = l_def_oia_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_oia_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_oia_rec.attribute_category,
        ATTRIBUTE1 = l_def_oia_rec.attribute1,
        ATTRIBUTE2 = l_def_oia_rec.attribute2,
        ATTRIBUTE3 = l_def_oia_rec.attribute3,
        ATTRIBUTE4 = l_def_oia_rec.attribute4,
        ATTRIBUTE5 = l_def_oia_rec.attribute5,
        ATTRIBUTE6 = l_def_oia_rec.attribute6,
        ATTRIBUTE7 = l_def_oia_rec.attribute7,
        ATTRIBUTE8 = l_def_oia_rec.attribute8,
        ATTRIBUTE9 = l_def_oia_rec.attribute9,
        ATTRIBUTE10 = l_def_oia_rec.attribute10,
        ATTRIBUTE11 = l_def_oia_rec.attribute11,
        ATTRIBUTE12 = l_def_oia_rec.attribute12,
        ATTRIBUTE13 = l_def_oia_rec.attribute13,
        ATTRIBUTE14 = l_def_oia_rec.attribute14,
        ATTRIBUTE15 = l_def_oia_rec.attribute15,
        CREATED_BY = l_def_oia_rec.created_by,
        CREATION_DATE = l_def_oia_rec.creation_date,
        LAST_UPDATED_BY = l_def_oia_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_oia_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_oia_rec.last_update_login
    WHERE ID = l_def_oia_rec.id;

    x_oia_rec := l_oia_rec;
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
  -- update_row for:OKL_OPEN_INT_ASST_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type,
    x_oiav_rec                     OUT NOCOPY oiav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oiav_rec                     oiav_rec_type := p_oiav_rec;
    l_def_oiav_rec                 oiav_rec_type;
    l_db_oiav_rec                  oiav_rec_type;
    l_oia_rec                      oia_rec_type;
    lx_oia_rec                     oia_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oiav_rec IN oiav_rec_type
    ) RETURN oiav_rec_type AS
      l_oiav_rec oiav_rec_type := p_oiav_rec;
    BEGIN
      l_oiav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_oiav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oiav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oiav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oiav_rec IN oiav_rec_type,
      x_oiav_rec OUT NOCOPY oiav_rec_type
    ) RETURN VARCHAR2 AS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oiav_rec := p_oiav_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_oiav_rec := get_rec(p_oiav_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oiav_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.id := l_db_oiav_rec.id;
        END IF;
        IF (x_oiav_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.khr_id := l_db_oiav_rec.khr_id;
        END IF;
        IF (x_oiav_rec.instance_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.instance_number := l_db_oiav_rec.instance_number;
        END IF;
        IF (x_oiav_rec.asset_id = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.asset_id := l_db_oiav_rec.asset_id;
        END IF;
        IF (x_oiav_rec.asset_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.asset_number := l_db_oiav_rec.asset_number;
        END IF;
        IF (x_oiav_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.description := l_db_oiav_rec.description;
        END IF;
        IF (x_oiav_rec.asset_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.asset_type := l_db_oiav_rec.asset_type;
        END IF;
        IF (x_oiav_rec.manufacturer_name = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.manufacturer_name := l_db_oiav_rec.manufacturer_name;
        END IF;
        IF (x_oiav_rec.model_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.model_number := l_db_oiav_rec.model_number;
        END IF;
        IF (x_oiav_rec.serial_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.serial_number := l_db_oiav_rec.serial_number;
        END IF;
        IF (x_oiav_rec.tag_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.tag_number := l_db_oiav_rec.tag_number;
        END IF;
        IF (x_oiav_rec.original_cost = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.original_cost := l_db_oiav_rec.original_cost;
        END IF;
        IF (x_oiav_rec.quantity = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.quantity := l_db_oiav_rec.quantity;
        END IF;
        IF (x_oiav_rec.country = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.country := l_db_oiav_rec.country;
        END IF;
        IF (x_oiav_rec.address1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.address1 := l_db_oiav_rec.address1;
        END IF;
        IF (x_oiav_rec.address2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.address2 := l_db_oiav_rec.address2;
        END IF;
        IF (x_oiav_rec.address3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.address3 := l_db_oiav_rec.address3;
        END IF;
        IF (x_oiav_rec.address4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.address4 := l_db_oiav_rec.address4;
        END IF;
        IF (x_oiav_rec.city = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.city := l_db_oiav_rec.city;
        END IF;
        IF (x_oiav_rec.postal_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.postal_code := l_db_oiav_rec.postal_code;
        END IF;
        IF (x_oiav_rec.state = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.state := l_db_oiav_rec.state;
        END IF;
        IF (x_oiav_rec.province = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.province := l_db_oiav_rec.province;
        END IF;
        IF (x_oiav_rec.county = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.county := l_db_oiav_rec.county;
        END IF;
        IF (x_oiav_rec.po_box_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.po_box_number := l_db_oiav_rec.po_box_number;
        END IF;
        IF (x_oiav_rec.house_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.house_number := l_db_oiav_rec.house_number;
        END IF;
        IF (x_oiav_rec.street_suffix = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.street_suffix := l_db_oiav_rec.street_suffix;
        END IF;
        IF (x_oiav_rec.apartment_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.apartment_number := l_db_oiav_rec.apartment_number;
        END IF;
        IF (x_oiav_rec.street = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.street := l_db_oiav_rec.street;
        END IF;
        IF (x_oiav_rec.rural_route_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.rural_route_number := l_db_oiav_rec.rural_route_number;
        END IF;
        IF (x_oiav_rec.street_number = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.street_number := l_db_oiav_rec.street_number;
        END IF;
        IF (x_oiav_rec.building = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.building := l_db_oiav_rec.building;
        END IF;
        IF (x_oiav_rec.floor = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.floor := l_db_oiav_rec.floor;
        END IF;
        IF (x_oiav_rec.suite = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.suite := l_db_oiav_rec.suite;
        END IF;
        IF (x_oiav_rec.room = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.room := l_db_oiav_rec.room;
        END IF;
        IF (x_oiav_rec.postal_plus4_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.postal_plus4_code := l_db_oiav_rec.postal_plus4_code;
        END IF;
        IF (x_oiav_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.object_version_number := l_db_oiav_rec.object_version_number;
        END IF;
        IF (x_oiav_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.org_id := l_db_oiav_rec.org_id;
        END IF;
        IF (x_oiav_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.request_id := l_db_oiav_rec.request_id;
        END IF;
        IF (x_oiav_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.program_application_id := l_db_oiav_rec.program_application_id;
        END IF;
        IF (x_oiav_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.program_id := l_db_oiav_rec.program_id;
        END IF;
        IF (x_oiav_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oiav_rec.program_update_date := l_db_oiav_rec.program_update_date;
        END IF;
        IF (x_oiav_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute_category := l_db_oiav_rec.attribute_category;
        END IF;
        IF (x_oiav_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute1 := l_db_oiav_rec.attribute1;
        END IF;
        IF (x_oiav_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute2 := l_db_oiav_rec.attribute2;
        END IF;
        IF (x_oiav_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute3 := l_db_oiav_rec.attribute3;
        END IF;
        IF (x_oiav_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute4 := l_db_oiav_rec.attribute4;
        END IF;
        IF (x_oiav_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute5 := l_db_oiav_rec.attribute5;
        END IF;
        IF (x_oiav_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute6 := l_db_oiav_rec.attribute6;
        END IF;
        IF (x_oiav_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute7 := l_db_oiav_rec.attribute7;
        END IF;
        IF (x_oiav_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute8 := l_db_oiav_rec.attribute8;
        END IF;
        IF (x_oiav_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute9 := l_db_oiav_rec.attribute9;
        END IF;
        IF (x_oiav_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute10 := l_db_oiav_rec.attribute10;
        END IF;
        IF (x_oiav_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute11 := l_db_oiav_rec.attribute11;
        END IF;
        IF (x_oiav_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute12 := l_db_oiav_rec.attribute12;
        END IF;
        IF (x_oiav_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute13 := l_db_oiav_rec.attribute13;
        END IF;
        IF (x_oiav_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute14 := l_db_oiav_rec.attribute14;
        END IF;
        IF (x_oiav_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_oiav_rec.attribute15 := l_db_oiav_rec.attribute15;
        END IF;
        IF (x_oiav_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.created_by := l_db_oiav_rec.created_by;
        END IF;
        IF (x_oiav_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oiav_rec.creation_date := l_db_oiav_rec.creation_date;
        END IF;
        IF (x_oiav_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.last_updated_by := l_db_oiav_rec.last_updated_by;
        END IF;
        IF (x_oiav_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oiav_rec.last_update_date := l_db_oiav_rec.last_update_date;
        END IF;
        IF (x_oiav_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oiav_rec.last_update_login := l_db_oiav_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_OPEN_INT_ASST_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_oiav_rec IN oiav_rec_type,
      x_oiav_rec OUT NOCOPY oiav_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oiav_rec := p_oiav_rec;

      -- Begin Post-Generation Change
      IF (x_oiav_rec.request_id IS NULL OR x_oiav_rec.request_id = Okl_Api.G_MISS_NUM) THEN
        SELECT NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID), x_oiav_rec.request_id),
             NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID), x_oiav_rec.program_application_id),
             NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID), x_oiav_rec.program_id),
             DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE), NULL,x_oiav_rec.program_update_date,SYSDATE)
        INTO
        x_oiav_rec.request_id,
        x_oiav_rec.program_application_id,
        x_oiav_rec.program_id,
        x_oiav_rec.program_update_date
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
      p_oiav_rec,                        -- IN
      x_oiav_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(x_oiav_rec, l_def_oiav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oiav_rec := fill_who_columns(l_def_oiav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oiav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oiav_rec, l_db_oiav_rec);
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
      p_oiav_rec                     => p_oiav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    */

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_oiav_rec, l_oia_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oia_rec,
      lx_oia_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oia_rec, l_def_oiav_rec);
    x_oiav_rec := l_def_oiav_rec;
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
  -- PL/SQL TBL update_row for:oiav_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    x_oiav_tbl                     OUT NOCOPY oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      i := p_oiav_tbl.FIRST;
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
            p_oiav_rec                     => p_oiav_tbl(i),
            x_oiav_rec                     => x_oiav_tbl(i));
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
        EXIT WHEN (i = p_oiav_tbl.LAST);
        i := p_oiav_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:OIAV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    x_oiav_tbl                     OUT NOCOPY oiav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oiav_tbl                     => p_oiav_tbl,
        x_oiav_tbl                     => x_oiav_tbl,
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
  -- delete_row for:OKL_OPEN_INT_ASST --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oia_rec                      IN oia_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oia_rec                      oia_rec_type := p_oia_rec;
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

    DELETE FROM OKL_OPEN_INT_ASST
     WHERE ID = p_oia_rec.id;

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
  -- delete_row for:OKL_OPEN_INT_ASST_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oiav_rec                     oiav_rec_type := p_oiav_rec;
    l_oia_rec                      oia_rec_type;
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
    migrate(l_oiav_rec, l_oia_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oia_rec
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
  -- PL/SQL TBL delete_row for:OKL_OPEN_INT_ASST_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      i := p_oiav_tbl.FIRST;
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
            p_oiav_rec                     => p_oiav_tbl(i));
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
        EXIT WHEN (i = p_oiav_tbl.LAST);
        i := p_oiav_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKL_OPEN_INT_ASST_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiav_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oiav_tbl                     => p_oiav_tbl,
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

END OKL_OIA_PVT;

/
