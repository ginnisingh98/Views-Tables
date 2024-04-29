--------------------------------------------------------
--  DDL for Package Body CS_TXNGRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TXNGRP_PVT" AS
/* $Header: csctxngb.pls 115.1 99/07/16 08:56:05 porting ship $ */
  FUNCTION get_seq_id RETURN NUMBER IS
    CURSOR get_seq_id_csr IS
      SELECT CS_COVERAGE_TXN_GROUPS_S.nextval FROM SYS.DUAL;
      l_seq_id                       NUMBER := 0;
  BEGIN
    OPEN get_seq_id_csr;
    FETCH get_seq_id_csr INTO l_seq_id;
    CLOSE get_seq_id_csr;
    RETURN(l_seq_id);
  END get_seq_id;


  -- Validation
  FUNCTION Validate_Item_Attributes
  (
    p_txngrp_rec IN  TxnGrp_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_txngrp_rec.coverage_id = TAPI_DEV_KIT.G_MISS_NUM OR
       p_txngrp_rec.coverage_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'coverage_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_txngrp_rec.business_process_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_txngrp_rec.business_process_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'business_process_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_txngrp_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_txngrp_rec.last_update_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_txngrp_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_txngrp_rec.last_updated_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_updated_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_txngrp_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_txngrp_rec.creation_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_txngrp_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_txngrp_rec.created_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Item_Attributes;


  ----- Default
  FUNCTION Default_Item_Attributes
  (
    p_txngrp_rec IN  TxnGrp_Rec_Type,
    l_def_txngrp_rec OUT  TxnGrp_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status 	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_def_txngrp_rec := p_txngrp_rec;
    l_def_txngrp_rec.OBJECT_VERSION_NUMBER := NVL(l_def_txngrp_rec.OBJECT_VERSION_NUMBER, 0) + 1;
    RETURN(l_return_status);
  End Default_Item_attributes;


  FUNCTION Validate_Item_Record (
    p_txngrp_rec IN TxnGrp_Rec_Type
  )
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    FUNCTION validate_foreign_keys (
      p_txngrp_rec IN TxnGrp_Rec_Type
    )
    RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR cc_pk_csr (p_coverage_id        IN NUMBER) IS
      SELECT *
        FROM Cs_Coverages
       WHERE cs_coverages.coverage_id = p_coverage_id;
      l_cc_pk                        cc_pk_csr%ROWTYPE;
      CURSOR csbp_pk_csr (p_business_process_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Business_Processes
       WHERE cs_business_processes.business_process_id = p_business_process_id;
      l_csbp_pk                      csbp_pk_csr%ROWTYPE;
      CURSOR cs_time_zones_pk_csr (p_time_zone_id       IN NUMBER) IS
      SELECT *
        FROM Cs_Time_Zones
       WHERE cs_time_zones.time_zone_id = p_time_zone_id;
      l_cs_time_zones_pk             cs_time_zones_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_txngrp_rec.COVERAGE_ID IS NOT NULL)
      THEN
        OPEN cc_pk_csr(p_txngrp_rec.COVERAGE_ID);
        FETCH cc_pk_csr INTO l_cc_pk;
        l_row_notfound := cc_pk_csr%NOTFOUND;
        CLOSE cc_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'COVERAGE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_txngrp_rec.BUSINESS_PROCESS_ID IS NOT NULL)
      THEN
        OPEN csbp_pk_csr(p_txngrp_rec.BUSINESS_PROCESS_ID);
        FETCH csbp_pk_csr INTO l_csbp_pk;
        l_row_notfound := csbp_pk_csr%NOTFOUND;
        CLOSE csbp_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BUSINESS_PROCESS_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_txngrp_rec.TIME_ZONE_ID IS NOT NULL)
      THEN
        OPEN cs_time_zones_pk_csr(p_txngrp_rec.TIME_ZONE_ID);
        FETCH cs_time_zones_pk_csr INTO l_cs_time_zones_pk;
        l_row_notfound := cs_time_zones_pk_csr%NOTFOUND;
        CLOSE cs_time_zones_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TIME_ZONE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_txngrp_rec);
    RETURN (l_return_status);
  END Validate_Item_Record;


  PROCEDURE migrate (
    p_from	IN TxnGrp_Val_Rec_Type,
    p_to	OUT TxnGrp_Rec_Type
  ) IS
  BEGIN
    p_to.coverage_txn_group_id := p_from.coverage_txn_group_id;
    p_to.offset_duration := p_from.offset_duration;
    p_to.offset_period := p_from.offset_period;
    p_to.coverage_start_date := p_from.coverage_start_date;
    p_to.coverage_end_date := p_from.coverage_end_date;
    p_to.price_list_id := p_from.price_list_id;
    p_to.manufacturing_org_id := p_from.manufacturing_org_id;
    p_to.subinventory_code := p_from.subinventory_code;
    p_to.coverage_id := p_from.coverage_id;
    p_to.discount_id := p_from.discount_id;
    p_to.business_process_id := p_from.business_process_id;
    p_to.sunday_end_time := p_from.sunday_end_time;
    p_to.sunday_start_time := p_from.sunday_start_time;
    p_to.monday_start_time := p_from.monday_start_time;
    p_to.monday_end_time := p_from.monday_end_time;
    p_to.tuesday_start_time := p_from.tuesday_start_time;
    p_to.tuesday_end_time := p_from.tuesday_end_time;
    p_to.wednesday_start_time := p_from.wednesday_start_time;
    p_to.wednesday_end_time := p_from.wednesday_end_time;
    p_to.thursday_start_time := p_from.thursday_start_time;
    p_to.thursday_end_time := p_from.thursday_end_time;
    p_to.friday_start_time := p_from.friday_start_time;
    p_to.friday_end_time := p_from.friday_end_time;
    p_to.saturday_start_time := p_from.saturday_start_time;
    p_to.saturday_end_time := p_from.saturday_end_time;
    p_to.preferred_engineer1 := p_from.preferred_engineer1;
    p_to.time_zone_id := p_from.time_zone_id;
    p_to.preferred_engineer2 := p_from.preferred_engineer2;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.context := p_from.context;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  PROCEDURE migrate (
    p_from	IN TxnGrp_Rec_Type,
    p_to	OUT TxnGrp_Val_Rec_Type
  ) IS
  BEGIN
    p_to.coverage_txn_group_id := p_from.coverage_txn_group_id;
    p_to.offset_duration := p_from.offset_duration;
    p_to.offset_period := p_from.offset_period;
    p_to.coverage_start_date := p_from.coverage_start_date;
    p_to.coverage_end_date := p_from.coverage_end_date;
    p_to.price_list_id := p_from.price_list_id;
    p_to.manufacturing_org_id := p_from.manufacturing_org_id;
    p_to.subinventory_code := p_from.subinventory_code;
    p_to.coverage_id := p_from.coverage_id;
    p_to.discount_id := p_from.discount_id;
    p_to.business_process_id := p_from.business_process_id;
    p_to.sunday_end_time := p_from.sunday_end_time;
    p_to.sunday_start_time := p_from.sunday_start_time;
    p_to.monday_start_time := p_from.monday_start_time;
    p_to.monday_end_time := p_from.monday_end_time;
    p_to.tuesday_start_time := p_from.tuesday_start_time;
    p_to.tuesday_end_time := p_from.tuesday_end_time;
    p_to.wednesday_start_time := p_from.wednesday_start_time;
    p_to.wednesday_end_time := p_from.wednesday_end_time;
    p_to.thursday_start_time := p_from.thursday_start_time;
    p_to.thursday_end_time := p_from.thursday_end_time;
    p_to.friday_start_time := p_from.friday_start_time;
    p_to.friday_end_time := p_from.friday_end_time;
    p_to.saturday_start_time := p_from.saturday_start_time;
    p_to.saturday_end_time := p_from.saturday_end_time;
    p_to.preferred_engineer1 := p_from.preferred_engineer1;
    p_to.time_zone_id := p_from.time_zone_id;
    p_to.preferred_engineer2 := p_from.preferred_engineer2;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.context := p_from.context;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  PROCEDURE insert_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_txngrp_rec                   IN TxnGrp_Rec_Type := G_MISS_TXNGRP_REC,
    x_coverage_txn_group_id        OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_txngrp_rec                   TxnGrp_Rec_Type;
    l_def_txngrp_rec               TxnGrp_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_txngrp_rec := p_txngrp_rec;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_txngrp_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_txngrp_rec,    ---- IN
      l_def_txngrp_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_txngrp_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- Set primary key value
    l_def_txngrp_rec.coverage_txn_group_id := get_seq_id;
    INSERT INTO CS_COVERAGE_TXN_GROUPS(
        coverage_txn_group_id,
        offset_duration,
        offset_period,
        coverage_start_date,
        coverage_end_date,
        price_list_id,
        manufacturing_org_id,
        subinventory_code,
        coverage_id,
        discount_id,
        business_process_id,
        sunday_end_time,
        sunday_start_time,
        monday_start_time,
        monday_end_time,
        tuesday_start_time,
        tuesday_end_time,
        wednesday_start_time,
        wednesday_end_time,
        thursday_start_time,
        thursday_end_time,
        friday_start_time,
        friday_end_time,
        saturday_start_time,
        saturday_end_time,
        preferred_engineer1,
        time_zone_id,
        preferred_engineer2,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
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
        context,
        object_version_number)
      VALUES (
        l_def_txngrp_rec.coverage_txn_group_id,
        l_def_txngrp_rec.offset_duration,
        l_def_txngrp_rec.offset_period,
        l_def_txngrp_rec.coverage_start_date,
        l_def_txngrp_rec.coverage_end_date,
        l_def_txngrp_rec.price_list_id,
        l_def_txngrp_rec.manufacturing_org_id,
        l_def_txngrp_rec.subinventory_code,
        l_def_txngrp_rec.coverage_id,
        l_def_txngrp_rec.discount_id,
        l_def_txngrp_rec.business_process_id,
        l_def_txngrp_rec.sunday_end_time,
        l_def_txngrp_rec.sunday_start_time,
        l_def_txngrp_rec.monday_start_time,
        l_def_txngrp_rec.monday_end_time,
        l_def_txngrp_rec.tuesday_start_time,
        l_def_txngrp_rec.tuesday_end_time,
        l_def_txngrp_rec.wednesday_start_time,
        l_def_txngrp_rec.wednesday_end_time,
        l_def_txngrp_rec.thursday_start_time,
        l_def_txngrp_rec.thursday_end_time,
        l_def_txngrp_rec.friday_start_time,
        l_def_txngrp_rec.friday_end_time,
        l_def_txngrp_rec.saturday_start_time,
        l_def_txngrp_rec.saturday_end_time,
        l_def_txngrp_rec.preferred_engineer1,
        l_def_txngrp_rec.time_zone_id,
        l_def_txngrp_rec.preferred_engineer2,
        l_def_txngrp_rec.last_update_date,
        l_def_txngrp_rec.last_updated_by,
        l_def_txngrp_rec.creation_date,
        l_def_txngrp_rec.created_by,
        l_def_txngrp_rec.last_update_login,
        l_def_txngrp_rec.attribute1,
        l_def_txngrp_rec.attribute2,
        l_def_txngrp_rec.attribute3,
        l_def_txngrp_rec.attribute4,
        l_def_txngrp_rec.attribute5,
        l_def_txngrp_rec.attribute6,
        l_def_txngrp_rec.attribute7,
        l_def_txngrp_rec.attribute8,
        l_def_txngrp_rec.attribute9,
        l_def_txngrp_rec.attribute10,
        l_def_txngrp_rec.attribute11,
        l_def_txngrp_rec.attribute12,
        l_def_txngrp_rec.attribute13,
        l_def_txngrp_rec.attribute14,
        l_def_txngrp_rec.attribute15,
        l_def_txngrp_rec.context,
        l_def_txngrp_rec.object_version_number);
    -- Set OUT values
    x_coverage_txn_group_id := l_def_txngrp_rec.coverage_txn_group_id;
    x_object_version_number       := l_def_txngrp_rec.OBJECT_VERSION_NUMBER;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_row;
  PROCEDURE insert_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_offset_duration              IN NUMBER := NULL,
    p_offset_period                IN CS_COVERAGE_TXN_GROUPS.OFFSET_PERIOD%TYPE := NULL,
    p_coverage_start_date          IN CS_COVERAGE_TXN_GROUPS.COVERAGE_START_DATE%TYPE := NULL,
    p_coverage_end_date            IN CS_COVERAGE_TXN_GROUPS.COVERAGE_END_DATE%TYPE := NULL,
    p_price_list_id                IN NUMBER := NULL,
    p_manufacturing_org_id         IN NUMBER := NULL,
    p_subinventory_code            IN CS_COVERAGE_TXN_GROUPS.SUBINVENTORY_CODE%TYPE := NULL,
    p_coverage_id                  IN NUMBER := NULL,
    p_discount_id                  IN NUMBER := NULL,
    p_business_process_id          IN NUMBER := NULL,
    p_sunday_end_time              IN CS_COVERAGE_TXN_GROUPS.SUNDAY_END_TIME%TYPE := NULL,
    p_sunday_start_time            IN CS_COVERAGE_TXN_GROUPS.SUNDAY_START_TIME%TYPE := NULL,
    p_monday_start_time            IN CS_COVERAGE_TXN_GROUPS.MONDAY_START_TIME%TYPE := NULL,
    p_monday_end_time              IN CS_COVERAGE_TXN_GROUPS.MONDAY_END_TIME%TYPE := NULL,
    p_tuesday_start_time           IN CS_COVERAGE_TXN_GROUPS.TUESDAY_START_TIME%TYPE := NULL,
    p_tuesday_end_time             IN CS_COVERAGE_TXN_GROUPS.TUESDAY_END_TIME%TYPE := NULL,
    p_wednesday_start_time         IN CS_COVERAGE_TXN_GROUPS.WEDNESDAY_START_TIME%TYPE := NULL,
    p_wednesday_end_time           IN CS_COVERAGE_TXN_GROUPS.WEDNESDAY_END_TIME%TYPE := NULL,
    p_thursday_start_time          IN CS_COVERAGE_TXN_GROUPS.THURSDAY_START_TIME%TYPE := NULL,
    p_thursday_end_time            IN CS_COVERAGE_TXN_GROUPS.THURSDAY_END_TIME%TYPE := NULL,
    p_friday_start_time            IN CS_COVERAGE_TXN_GROUPS.FRIDAY_START_TIME%TYPE := NULL,
    p_friday_end_time              IN CS_COVERAGE_TXN_GROUPS.FRIDAY_END_TIME%TYPE := NULL,
    p_saturday_start_time          IN CS_COVERAGE_TXN_GROUPS.SATURDAY_START_TIME%TYPE := NULL,
    p_saturday_end_time            IN CS_COVERAGE_TXN_GROUPS.SATURDAY_END_TIME%TYPE := NULL,
    p_preferred_engineer1          IN CS_COVERAGE_TXN_GROUPS.PREFERRED_ENGINEER1%TYPE := NULL,
    p_time_zone_id                 IN NUMBER := NULL,
    p_preferred_engineer2          IN CS_COVERAGE_TXN_GROUPS.PREFERRED_ENGINEER2%TYPE := NULL,
    p_last_update_date             IN CS_COVERAGE_TXN_GROUPS.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_COVERAGE_TXN_GROUPS.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_attribute1                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_COVERAGE_TXN_GROUPS.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_coverage_txn_group_id        OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_txngrp_rec                   TxnGrp_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_txngrp_rec.OFFSET_DURATION := p_offset_duration;
    l_txngrp_rec.OFFSET_PERIOD := p_offset_period;
    l_txngrp_rec.COVERAGE_START_DATE := p_coverage_start_date;
    l_txngrp_rec.COVERAGE_END_DATE := p_coverage_end_date;
    l_txngrp_rec.PRICE_LIST_ID := p_price_list_id;
    l_txngrp_rec.MANUFACTURING_ORG_ID := p_manufacturing_org_id;
    l_txngrp_rec.SUBINVENTORY_CODE := p_subinventory_code;
    l_txngrp_rec.COVERAGE_ID := p_coverage_id;
    l_txngrp_rec.DISCOUNT_ID := p_discount_id;
    l_txngrp_rec.BUSINESS_PROCESS_ID := p_business_process_id;
    l_txngrp_rec.SUNDAY_END_TIME := p_sunday_end_time;
    l_txngrp_rec.SUNDAY_START_TIME := p_sunday_start_time;
    l_txngrp_rec.MONDAY_START_TIME := p_monday_start_time;
    l_txngrp_rec.MONDAY_END_TIME := p_monday_end_time;
    l_txngrp_rec.TUESDAY_START_TIME := p_tuesday_start_time;
    l_txngrp_rec.TUESDAY_END_TIME := p_tuesday_end_time;
    l_txngrp_rec.WEDNESDAY_START_TIME := p_wednesday_start_time;
    l_txngrp_rec.WEDNESDAY_END_TIME := p_wednesday_end_time;
    l_txngrp_rec.THURSDAY_START_TIME := p_thursday_start_time;
    l_txngrp_rec.THURSDAY_END_TIME := p_thursday_end_time;
    l_txngrp_rec.FRIDAY_START_TIME := p_friday_start_time;
    l_txngrp_rec.FRIDAY_END_TIME := p_friday_end_time;
    l_txngrp_rec.SATURDAY_START_TIME := p_saturday_start_time;
    l_txngrp_rec.SATURDAY_END_TIME := p_saturday_end_time;
    l_txngrp_rec.PREFERRED_ENGINEER1 := p_preferred_engineer1;
    l_txngrp_rec.TIME_ZONE_ID := p_time_zone_id;
    l_txngrp_rec.PREFERRED_ENGINEER2 := p_preferred_engineer2;
    l_txngrp_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_txngrp_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_txngrp_rec.CREATION_DATE := p_creation_date;
    l_txngrp_rec.CREATED_BY := p_created_by;
    l_txngrp_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_txngrp_rec.ATTRIBUTE1 := p_attribute1;
    l_txngrp_rec.ATTRIBUTE2 := p_attribute2;
    l_txngrp_rec.ATTRIBUTE3 := p_attribute3;
    l_txngrp_rec.ATTRIBUTE4 := p_attribute4;
    l_txngrp_rec.ATTRIBUTE5 := p_attribute5;
    l_txngrp_rec.ATTRIBUTE6 := p_attribute6;
    l_txngrp_rec.ATTRIBUTE7 := p_attribute7;
    l_txngrp_rec.ATTRIBUTE8 := p_attribute8;
    l_txngrp_rec.ATTRIBUTE9 := p_attribute9;
    l_txngrp_rec.ATTRIBUTE10 := p_attribute10;
    l_txngrp_rec.ATTRIBUTE11 := p_attribute11;
    l_txngrp_rec.ATTRIBUTE12 := p_attribute12;
    l_txngrp_rec.ATTRIBUTE13 := p_attribute13;
    l_txngrp_rec.ATTRIBUTE14 := p_attribute14;
    l_txngrp_rec.ATTRIBUTE15 := p_attribute15;
    l_txngrp_rec.CONTEXT := p_context;
    l_txngrp_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    insert_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_txngrp_rec,
      x_coverage_txn_group_id,
      x_object_version_number
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_row;
  Procedure lock_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_coverage_txn_group_id        IN NUMBER,
    p_object_version_number        IN NUMBER) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_COVERAGE_TXN_GROUPS
    WHERE
      COVERAGE_TXN_GROUP_ID = p_coverage_txn_group_id AND
      OBJECT_VERSION_NUMBER = p_object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_COVERAGE_TXN_GROUPS
    WHERE
      COVERAGE_TXN_GROUP_ID = p_coverage_txn_group_id
      ;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_object_version_number       CS_COVERAGE_TXN_GROUPS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      CS_COVERAGE_TXN_GROUPS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr;
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr;
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number > p_object_version_number THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number <> p_object_version_number THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END lock_row;
  Procedure update_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_txngrp_val_rec               IN TxnGrp_Val_Rec_Type := G_MISS_TXNGRP_VAL_REC,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_txngrp_rec                   TxnGrp_Rec_Type;
    l_def_txngrp_rec               TxnGrp_Rec_Type;
    FUNCTION populate_new_record (
      p_txngrp_rec	IN TxnGrp_Rec_Type,
      x_txngrp_rec	OUT TxnGrp_Rec_Type
    ) RETURN VARCHAR2 IS
      CURSOR cs_coverage_txn_groups_pk_csr (p_coverage_txn_group_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Coverage_Txn_Groups
       WHERE cs_coverage_txn_groups.coverage_txn_group_id = p_coverage_txn_group_id;
      l_cs_coverage_txn_groups_pk    cs_coverage_txn_groups_pk_csr%ROWTYPE;
      l_row_notfound		BOOLEAN := TRUE;
      l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      x_txngrp_rec := p_txngrp_rec;
      -- Get current database values
      OPEN cs_coverage_txn_groups_pk_csr (p_txngrp_rec.coverage_txn_group_id);
      FETCH cs_coverage_txn_groups_pk_csr INTO l_cs_coverage_txn_groups_pk;
      l_row_notfound := cs_coverage_txn_groups_pk_csr%NOTFOUND;
      CLOSE cs_coverage_txn_groups_pk_csr;
      IF (l_row_notfound) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF (x_txngrp_rec.coverage_txn_group_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.coverage_txn_group_id := l_cs_coverage_txn_groups_pk.coverage_txn_group_id;
      END IF;
      IF (x_txngrp_rec.offset_duration = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.offset_duration := l_cs_coverage_txn_groups_pk.offset_duration;
      END IF;
      IF (x_txngrp_rec.offset_period = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.offset_period := l_cs_coverage_txn_groups_pk.offset_period;
      END IF;
      IF (x_txngrp_rec.coverage_start_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.coverage_start_date := l_cs_coverage_txn_groups_pk.coverage_start_date;
      END IF;
      IF (x_txngrp_rec.coverage_end_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.coverage_end_date := l_cs_coverage_txn_groups_pk.coverage_end_date;
      END IF;
      IF (x_txngrp_rec.price_list_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.price_list_id := l_cs_coverage_txn_groups_pk.price_list_id;
      END IF;
      IF (x_txngrp_rec.manufacturing_org_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.manufacturing_org_id := l_cs_coverage_txn_groups_pk.manufacturing_org_id;
      END IF;
      IF (x_txngrp_rec.subinventory_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.subinventory_code := l_cs_coverage_txn_groups_pk.subinventory_code;
      END IF;
      IF (x_txngrp_rec.coverage_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.coverage_id := l_cs_coverage_txn_groups_pk.coverage_id;
      END IF;
      IF (x_txngrp_rec.discount_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.discount_id := l_cs_coverage_txn_groups_pk.discount_id;
      END IF;
      IF (x_txngrp_rec.business_process_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.business_process_id := l_cs_coverage_txn_groups_pk.business_process_id;
      END IF;
      IF (x_txngrp_rec.sunday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.sunday_end_time := l_cs_coverage_txn_groups_pk.sunday_end_time;
      END IF;
      IF (x_txngrp_rec.sunday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.sunday_start_time := l_cs_coverage_txn_groups_pk.sunday_start_time;
      END IF;
      IF (x_txngrp_rec.monday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.monday_start_time := l_cs_coverage_txn_groups_pk.monday_start_time;
      END IF;
      IF (x_txngrp_rec.monday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.monday_end_time := l_cs_coverage_txn_groups_pk.monday_end_time;
      END IF;
      IF (x_txngrp_rec.tuesday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.tuesday_start_time := l_cs_coverage_txn_groups_pk.tuesday_start_time;
      END IF;
      IF (x_txngrp_rec.tuesday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.tuesday_end_time := l_cs_coverage_txn_groups_pk.tuesday_end_time;
      END IF;
      IF (x_txngrp_rec.wednesday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.wednesday_start_time := l_cs_coverage_txn_groups_pk.wednesday_start_time;
      END IF;
      IF (x_txngrp_rec.wednesday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.wednesday_end_time := l_cs_coverage_txn_groups_pk.wednesday_end_time;
      END IF;
      IF (x_txngrp_rec.thursday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.thursday_start_time := l_cs_coverage_txn_groups_pk.thursday_start_time;
      END IF;
      IF (x_txngrp_rec.thursday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.thursday_end_time := l_cs_coverage_txn_groups_pk.thursday_end_time;
      END IF;
      IF (x_txngrp_rec.friday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.friday_start_time := l_cs_coverage_txn_groups_pk.friday_start_time;
      END IF;
      IF (x_txngrp_rec.friday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.friday_end_time := l_cs_coverage_txn_groups_pk.friday_end_time;
      END IF;
      IF (x_txngrp_rec.saturday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.saturday_start_time := l_cs_coverage_txn_groups_pk.saturday_start_time;
      END IF;
      IF (x_txngrp_rec.saturday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.saturday_end_time := l_cs_coverage_txn_groups_pk.saturday_end_time;
      END IF;
      IF (x_txngrp_rec.preferred_engineer1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.preferred_engineer1 := l_cs_coverage_txn_groups_pk.preferred_engineer1;
      END IF;
      IF (x_txngrp_rec.time_zone_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.time_zone_id := l_cs_coverage_txn_groups_pk.time_zone_id;
      END IF;
      IF (x_txngrp_rec.preferred_engineer2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.preferred_engineer2 := l_cs_coverage_txn_groups_pk.preferred_engineer2;
      END IF;
      IF (x_txngrp_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.last_update_date := l_cs_coverage_txn_groups_pk.last_update_date;
      END IF;
      IF (x_txngrp_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.last_updated_by := l_cs_coverage_txn_groups_pk.last_updated_by;
      END IF;
      IF (x_txngrp_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_txngrp_rec.creation_date := l_cs_coverage_txn_groups_pk.creation_date;
      END IF;
      IF (x_txngrp_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.created_by := l_cs_coverage_txn_groups_pk.created_by;
      END IF;
      IF (x_txngrp_rec.last_update_login = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.last_update_login := l_cs_coverage_txn_groups_pk.last_update_login;
      END IF;
      IF (x_txngrp_rec.attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute1 := l_cs_coverage_txn_groups_pk.attribute1;
      END IF;
      IF (x_txngrp_rec.attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute2 := l_cs_coverage_txn_groups_pk.attribute2;
      END IF;
      IF (x_txngrp_rec.attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute3 := l_cs_coverage_txn_groups_pk.attribute3;
      END IF;
      IF (x_txngrp_rec.attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute4 := l_cs_coverage_txn_groups_pk.attribute4;
      END IF;
      IF (x_txngrp_rec.attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute5 := l_cs_coverage_txn_groups_pk.attribute5;
      END IF;
      IF (x_txngrp_rec.attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute6 := l_cs_coverage_txn_groups_pk.attribute6;
      END IF;
      IF (x_txngrp_rec.attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute7 := l_cs_coverage_txn_groups_pk.attribute7;
      END IF;
      IF (x_txngrp_rec.attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute8 := l_cs_coverage_txn_groups_pk.attribute8;
      END IF;
      IF (x_txngrp_rec.attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute9 := l_cs_coverage_txn_groups_pk.attribute9;
      END IF;
      IF (x_txngrp_rec.attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute10 := l_cs_coverage_txn_groups_pk.attribute10;
      END IF;
      IF (x_txngrp_rec.attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute11 := l_cs_coverage_txn_groups_pk.attribute11;
      END IF;
      IF (x_txngrp_rec.attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute12 := l_cs_coverage_txn_groups_pk.attribute12;
      END IF;
      IF (x_txngrp_rec.attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute13 := l_cs_coverage_txn_groups_pk.attribute13;
      END IF;
      IF (x_txngrp_rec.attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute14 := l_cs_coverage_txn_groups_pk.attribute14;
      END IF;
      IF (x_txngrp_rec.attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.attribute15 := l_cs_coverage_txn_groups_pk.attribute15;
      END IF;
      IF (x_txngrp_rec.context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_txngrp_rec.context := l_cs_coverage_txn_groups_pk.context;
      END IF;
      IF (x_txngrp_rec.object_version_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_txngrp_rec.object_version_number := l_cs_coverage_txn_groups_pk.object_version_number;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    migrate(p_txngrp_val_rec, l_txngrp_rec);
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_txngrp_rec,    ---- IN
      l_def_txngrp_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_return_status := populate_new_record(l_def_txngrp_rec, l_def_txngrp_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_def_txngrp_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_txngrp_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    UPDATE  CS_COVERAGE_TXN_GROUPS
    SET
        COVERAGE_TXN_GROUP_ID = l_def_txngrp_rec.coverage_txn_group_id ,
        OFFSET_DURATION = l_def_txngrp_rec.offset_duration ,
        OFFSET_PERIOD = l_def_txngrp_rec.offset_period ,
        COVERAGE_START_DATE = l_def_txngrp_rec.coverage_start_date ,
        COVERAGE_END_DATE = l_def_txngrp_rec.coverage_end_date ,
        PRICE_LIST_ID = l_def_txngrp_rec.price_list_id ,
        MANUFACTURING_ORG_ID = l_def_txngrp_rec.manufacturing_org_id ,
        SUBINVENTORY_CODE = l_def_txngrp_rec.subinventory_code ,
        COVERAGE_ID = l_def_txngrp_rec.coverage_id ,
        DISCOUNT_ID = l_def_txngrp_rec.discount_id ,
        BUSINESS_PROCESS_ID = l_def_txngrp_rec.business_process_id ,
        SUNDAY_END_TIME = l_def_txngrp_rec.sunday_end_time ,
        SUNDAY_START_TIME = l_def_txngrp_rec.sunday_start_time ,
        MONDAY_START_TIME = l_def_txngrp_rec.monday_start_time ,
        MONDAY_END_TIME = l_def_txngrp_rec.monday_end_time ,
        TUESDAY_START_TIME = l_def_txngrp_rec.tuesday_start_time ,
        TUESDAY_END_TIME = l_def_txngrp_rec.tuesday_end_time ,
        WEDNESDAY_START_TIME = l_def_txngrp_rec.wednesday_start_time ,
        WEDNESDAY_END_TIME = l_def_txngrp_rec.wednesday_end_time ,
        THURSDAY_START_TIME = l_def_txngrp_rec.thursday_start_time ,
        THURSDAY_END_TIME = l_def_txngrp_rec.thursday_end_time ,
        FRIDAY_START_TIME = l_def_txngrp_rec.friday_start_time ,
        FRIDAY_END_TIME = l_def_txngrp_rec.friday_end_time ,
        SATURDAY_START_TIME = l_def_txngrp_rec.saturday_start_time ,
        SATURDAY_END_TIME = l_def_txngrp_rec.saturday_end_time ,
        PREFERRED_ENGINEER1 = l_def_txngrp_rec.preferred_engineer1 ,
        TIME_ZONE_ID = l_def_txngrp_rec.time_zone_id ,
        PREFERRED_ENGINEER2 = l_def_txngrp_rec.preferred_engineer2 ,
        LAST_UPDATE_DATE = l_def_txngrp_rec.last_update_date ,
        LAST_UPDATED_BY = l_def_txngrp_rec.last_updated_by ,
        CREATION_DATE = l_def_txngrp_rec.creation_date ,
        CREATED_BY = l_def_txngrp_rec.created_by ,
        LAST_UPDATE_LOGIN = l_def_txngrp_rec.last_update_login ,
        ATTRIBUTE1 = l_def_txngrp_rec.attribute1 ,
        ATTRIBUTE2 = l_def_txngrp_rec.attribute2 ,
        ATTRIBUTE3 = l_def_txngrp_rec.attribute3 ,
        ATTRIBUTE4 = l_def_txngrp_rec.attribute4 ,
        ATTRIBUTE5 = l_def_txngrp_rec.attribute5 ,
        ATTRIBUTE6 = l_def_txngrp_rec.attribute6 ,
        ATTRIBUTE7 = l_def_txngrp_rec.attribute7 ,
        ATTRIBUTE8 = l_def_txngrp_rec.attribute8 ,
        ATTRIBUTE9 = l_def_txngrp_rec.attribute9 ,
        ATTRIBUTE10 = l_def_txngrp_rec.attribute10 ,
        ATTRIBUTE11 = l_def_txngrp_rec.attribute11 ,
        ATTRIBUTE12 = l_def_txngrp_rec.attribute12 ,
        ATTRIBUTE13 = l_def_txngrp_rec.attribute13 ,
        ATTRIBUTE14 = l_def_txngrp_rec.attribute14 ,
        ATTRIBUTE15 = l_def_txngrp_rec.attribute15 ,
        CONTEXT = l_def_txngrp_rec.context ,
        OBJECT_VERSION_NUMBER = l_def_txngrp_rec.object_version_number
        WHERE
          COVERAGE_TXN_GROUP_ID = l_def_txngrp_rec.coverage_txn_group_id
          ;
    x_object_version_number := l_def_txngrp_rec.OBJECT_VERSION_NUMBER;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END update_row;
  Procedure update_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_coverage_txn_group_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_offset_duration              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_offset_period                IN CS_COVERAGE_TXN_GROUPS.OFFSET_PERIOD%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_start_date          IN CS_COVERAGE_TXN_GROUPS.COVERAGE_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_coverage_end_date            IN CS_COVERAGE_TXN_GROUPS.COVERAGE_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_manufacturing_org_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_subinventory_code            IN CS_COVERAGE_TXN_GROUPS.SUBINVENTORY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_discount_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_business_process_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_sunday_end_time              IN CS_COVERAGE_TXN_GROUPS.SUNDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_sunday_start_time            IN CS_COVERAGE_TXN_GROUPS.SUNDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_monday_start_time            IN CS_COVERAGE_TXN_GROUPS.MONDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_monday_end_time              IN CS_COVERAGE_TXN_GROUPS.MONDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_tuesday_start_time           IN CS_COVERAGE_TXN_GROUPS.TUESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_tuesday_end_time             IN CS_COVERAGE_TXN_GROUPS.TUESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_wednesday_start_time         IN CS_COVERAGE_TXN_GROUPS.WEDNESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_wednesday_end_time           IN CS_COVERAGE_TXN_GROUPS.WEDNESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_thursday_start_time          IN CS_COVERAGE_TXN_GROUPS.THURSDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_thursday_end_time            IN CS_COVERAGE_TXN_GROUPS.THURSDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_friday_start_time            IN CS_COVERAGE_TXN_GROUPS.FRIDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_friday_end_time              IN CS_COVERAGE_TXN_GROUPS.FRIDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_saturday_start_time          IN CS_COVERAGE_TXN_GROUPS.SATURDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_saturday_end_time            IN CS_COVERAGE_TXN_GROUPS.SATURDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_preferred_engineer1          IN CS_COVERAGE_TXN_GROUPS.PREFERRED_ENGINEER1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_time_zone_id                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_preferred_engineer2          IN CS_COVERAGE_TXN_GROUPS.PREFERRED_ENGINEER2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_COVERAGE_TXN_GROUPS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COVERAGE_TXN_GROUPS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COVERAGE_TXN_GROUPS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_txngrp_rec                   TxnGrp_Val_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_txngrp_rec.COVERAGE_TXN_GROUP_ID := p_coverage_txn_group_id;
    l_txngrp_rec.OFFSET_DURATION := p_offset_duration;
    l_txngrp_rec.OFFSET_PERIOD := p_offset_period;
    l_txngrp_rec.COVERAGE_START_DATE := p_coverage_start_date;
    l_txngrp_rec.COVERAGE_END_DATE := p_coverage_end_date;
    l_txngrp_rec.PRICE_LIST_ID := p_price_list_id;
    l_txngrp_rec.MANUFACTURING_ORG_ID := p_manufacturing_org_id;
    l_txngrp_rec.SUBINVENTORY_CODE := p_subinventory_code;
    l_txngrp_rec.COVERAGE_ID := p_coverage_id;
    l_txngrp_rec.DISCOUNT_ID := p_discount_id;
    l_txngrp_rec.BUSINESS_PROCESS_ID := p_business_process_id;
    l_txngrp_rec.SUNDAY_END_TIME := p_sunday_end_time;
    l_txngrp_rec.SUNDAY_START_TIME := p_sunday_start_time;
    l_txngrp_rec.MONDAY_START_TIME := p_monday_start_time;
    l_txngrp_rec.MONDAY_END_TIME := p_monday_end_time;
    l_txngrp_rec.TUESDAY_START_TIME := p_tuesday_start_time;
    l_txngrp_rec.TUESDAY_END_TIME := p_tuesday_end_time;
    l_txngrp_rec.WEDNESDAY_START_TIME := p_wednesday_start_time;
    l_txngrp_rec.WEDNESDAY_END_TIME := p_wednesday_end_time;
    l_txngrp_rec.THURSDAY_START_TIME := p_thursday_start_time;
    l_txngrp_rec.THURSDAY_END_TIME := p_thursday_end_time;
    l_txngrp_rec.FRIDAY_START_TIME := p_friday_start_time;
    l_txngrp_rec.FRIDAY_END_TIME := p_friday_end_time;
    l_txngrp_rec.SATURDAY_START_TIME := p_saturday_start_time;
    l_txngrp_rec.SATURDAY_END_TIME := p_saturday_end_time;
    l_txngrp_rec.PREFERRED_ENGINEER1 := p_preferred_engineer1;
    l_txngrp_rec.TIME_ZONE_ID := p_time_zone_id;
    l_txngrp_rec.PREFERRED_ENGINEER2 := p_preferred_engineer2;
    l_txngrp_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_txngrp_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_txngrp_rec.CREATION_DATE := p_creation_date;
    l_txngrp_rec.CREATED_BY := p_created_by;
    l_txngrp_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_txngrp_rec.ATTRIBUTE1 := p_attribute1;
    l_txngrp_rec.ATTRIBUTE2 := p_attribute2;
    l_txngrp_rec.ATTRIBUTE3 := p_attribute3;
    l_txngrp_rec.ATTRIBUTE4 := p_attribute4;
    l_txngrp_rec.ATTRIBUTE5 := p_attribute5;
    l_txngrp_rec.ATTRIBUTE6 := p_attribute6;
    l_txngrp_rec.ATTRIBUTE7 := p_attribute7;
    l_txngrp_rec.ATTRIBUTE8 := p_attribute8;
    l_txngrp_rec.ATTRIBUTE9 := p_attribute9;
    l_txngrp_rec.ATTRIBUTE10 := p_attribute10;
    l_txngrp_rec.ATTRIBUTE11 := p_attribute11;
    l_txngrp_rec.ATTRIBUTE12 := p_attribute12;
    l_txngrp_rec.ATTRIBUTE13 := p_attribute13;
    l_txngrp_rec.ATTRIBUTE14 := p_attribute14;
    l_txngrp_rec.ATTRIBUTE15 := p_attribute15;
    l_txngrp_rec.CONTEXT := p_context;
    l_txngrp_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    update_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_txngrp_rec,
      x_object_version_number
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END update_row;
  Procedure delete_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_coverage_txn_group_id        IN NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    DELETE  FROM CS_COVERAGE_TXN_GROUPS
    WHERE
      COVERAGE_TXN_GROUP_ID = p_coverage_txn_group_id
      ;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END delete_row;
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_txngrp_val_rec               IN TxnGrp_Val_Rec_Type := G_MISS_TXNGRP_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_txngrp_rec                   TxnGrp_Rec_Type;
    l_def_txngrp_rec               TxnGrp_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    migrate(p_txngrp_val_rec, l_txngrp_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_txngrp_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_txngrp_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END validate_row;
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_coverage_txn_group_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_offset_duration              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_offset_period                IN CS_COVERAGE_TXN_GROUPS.OFFSET_PERIOD%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_start_date          IN CS_COVERAGE_TXN_GROUPS.COVERAGE_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_coverage_end_date            IN CS_COVERAGE_TXN_GROUPS.COVERAGE_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_manufacturing_org_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_subinventory_code            IN CS_COVERAGE_TXN_GROUPS.SUBINVENTORY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_discount_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_business_process_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_sunday_end_time              IN CS_COVERAGE_TXN_GROUPS.SUNDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_sunday_start_time            IN CS_COVERAGE_TXN_GROUPS.SUNDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_monday_start_time            IN CS_COVERAGE_TXN_GROUPS.MONDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_monday_end_time              IN CS_COVERAGE_TXN_GROUPS.MONDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_tuesday_start_time           IN CS_COVERAGE_TXN_GROUPS.TUESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_tuesday_end_time             IN CS_COVERAGE_TXN_GROUPS.TUESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_wednesday_start_time         IN CS_COVERAGE_TXN_GROUPS.WEDNESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_wednesday_end_time           IN CS_COVERAGE_TXN_GROUPS.WEDNESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_thursday_start_time          IN CS_COVERAGE_TXN_GROUPS.THURSDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_thursday_end_time            IN CS_COVERAGE_TXN_GROUPS.THURSDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_friday_start_time            IN CS_COVERAGE_TXN_GROUPS.FRIDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_friday_end_time              IN CS_COVERAGE_TXN_GROUPS.FRIDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_saturday_start_time          IN CS_COVERAGE_TXN_GROUPS.SATURDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_saturday_end_time            IN CS_COVERAGE_TXN_GROUPS.SATURDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_preferred_engineer1          IN CS_COVERAGE_TXN_GROUPS.PREFERRED_ENGINEER1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_time_zone_id                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_preferred_engineer2          IN CS_COVERAGE_TXN_GROUPS.PREFERRED_ENGINEER2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_COVERAGE_TXN_GROUPS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COVERAGE_TXN_GROUPS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COVERAGE_TXN_GROUPS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COVERAGE_TXN_GROUPS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_txngrp_rec                   TxnGrp_Val_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_txngrp_rec.COVERAGE_TXN_GROUP_ID := p_coverage_txn_group_id;
    l_txngrp_rec.OFFSET_DURATION := p_offset_duration;
    l_txngrp_rec.OFFSET_PERIOD := p_offset_period;
    l_txngrp_rec.COVERAGE_START_DATE := p_coverage_start_date;
    l_txngrp_rec.COVERAGE_END_DATE := p_coverage_end_date;
    l_txngrp_rec.PRICE_LIST_ID := p_price_list_id;
    l_txngrp_rec.MANUFACTURING_ORG_ID := p_manufacturing_org_id;
    l_txngrp_rec.SUBINVENTORY_CODE := p_subinventory_code;
    l_txngrp_rec.COVERAGE_ID := p_coverage_id;
    l_txngrp_rec.DISCOUNT_ID := p_discount_id;
    l_txngrp_rec.BUSINESS_PROCESS_ID := p_business_process_id;
    l_txngrp_rec.SUNDAY_END_TIME := p_sunday_end_time;
    l_txngrp_rec.SUNDAY_START_TIME := p_sunday_start_time;
    l_txngrp_rec.MONDAY_START_TIME := p_monday_start_time;
    l_txngrp_rec.MONDAY_END_TIME := p_monday_end_time;
    l_txngrp_rec.TUESDAY_START_TIME := p_tuesday_start_time;
    l_txngrp_rec.TUESDAY_END_TIME := p_tuesday_end_time;
    l_txngrp_rec.WEDNESDAY_START_TIME := p_wednesday_start_time;
    l_txngrp_rec.WEDNESDAY_END_TIME := p_wednesday_end_time;
    l_txngrp_rec.THURSDAY_START_TIME := p_thursday_start_time;
    l_txngrp_rec.THURSDAY_END_TIME := p_thursday_end_time;
    l_txngrp_rec.FRIDAY_START_TIME := p_friday_start_time;
    l_txngrp_rec.FRIDAY_END_TIME := p_friday_end_time;
    l_txngrp_rec.SATURDAY_START_TIME := p_saturday_start_time;
    l_txngrp_rec.SATURDAY_END_TIME := p_saturday_end_time;
    l_txngrp_rec.PREFERRED_ENGINEER1 := p_preferred_engineer1;
    l_txngrp_rec.TIME_ZONE_ID := p_time_zone_id;
    l_txngrp_rec.PREFERRED_ENGINEER2 := p_preferred_engineer2;
    l_txngrp_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_txngrp_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_txngrp_rec.CREATION_DATE := p_creation_date;
    l_txngrp_rec.CREATED_BY := p_created_by;
    l_txngrp_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_txngrp_rec.ATTRIBUTE1 := p_attribute1;
    l_txngrp_rec.ATTRIBUTE2 := p_attribute2;
    l_txngrp_rec.ATTRIBUTE3 := p_attribute3;
    l_txngrp_rec.ATTRIBUTE4 := p_attribute4;
    l_txngrp_rec.ATTRIBUTE5 := p_attribute5;
    l_txngrp_rec.ATTRIBUTE6 := p_attribute6;
    l_txngrp_rec.ATTRIBUTE7 := p_attribute7;
    l_txngrp_rec.ATTRIBUTE8 := p_attribute8;
    l_txngrp_rec.ATTRIBUTE9 := p_attribute9;
    l_txngrp_rec.ATTRIBUTE10 := p_attribute10;
    l_txngrp_rec.ATTRIBUTE11 := p_attribute11;
    l_txngrp_rec.ATTRIBUTE12 := p_attribute12;
    l_txngrp_rec.ATTRIBUTE13 := p_attribute13;
    l_txngrp_rec.ATTRIBUTE14 := p_attribute14;
    l_txngrp_rec.ATTRIBUTE15 := p_attribute15;
    l_txngrp_rec.CONTEXT := p_context;
    l_txngrp_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    validate_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_txngrp_rec
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END validate_row;
END CS_TXNGRP_PVT;

/
