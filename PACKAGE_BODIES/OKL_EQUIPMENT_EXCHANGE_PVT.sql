--------------------------------------------------------
--  DDL for Package Body OKL_EQUIPMENT_EXCHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EQUIPMENT_EXCHANGE_PVT" AS
/* $Header: OKLREQXB.pls 120.5.12010000.2 2009/06/14 08:35:56 racheruv ship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN          CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN           CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_NO_PARENT_RECORD            CONSTANT  VARCHAR2(200) := 'NO_PARENT_RECORD';
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'REQUIRED_VALUE';

------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';

-----------------------------------------------------------------------------------
 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_EQUIPMENT_EXCHANGE';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;




  SUBTYPE instance_rec             IS CSI_DATASTRUCTURES_PUB.instance_rec;
  SUBTYPE extend_attrib_values_tbl IS CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
  SUBTYPE party_tbl                IS CSI_DATASTRUCTURES_PUB.party_tbl;
  SUBTYPE account_tbl              IS CSI_DATASTRUCTURES_PUB.party_account_tbl;
  SUBTYPE pricing_attribs_tbl      IS CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
  SUBTYPE organization_units_tbl   IS CSI_DATASTRUCTURES_PUB.organization_units_tbl;
  SUBTYPE instance_asset_tbl       IS CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
  SUBTYPE transaction_rec          IS CSI_DATASTRUCTURES_PUB.transaction_rec;
  SUBTYPE id_tbl                   IS CSI_DATASTRUCTURES_PUB.id_tbl;
  SUBTYPE cplv_rec_type 	   IS OKL_CREATE_KLE_PVT.cplv_rec_type;


  --l_instance_rec           instance_rec;
  l_ext_attrib_values_tbl  extend_attrib_values_tbl;
  l_party_tbl              party_tbl;
  l_account_tbl            account_tbl;
  l_pricing_attrib_tbl     pricing_attribs_tbl;
  l_org_assignments_tbl    organization_units_tbl;
  l_asset_assignment_tbl   instance_asset_tbl;
  l_txn_rec                transaction_rec;
  l_instance_id_lst        id_tbl;




 FUNCTION GET_TAS_HDR_REC
                (p_thpv_tbl IN thpv_tbl_type
                ,p_no_data_found                OUT NOCOPY BOOLEAN
                ) RETURN thpv_tbl_type aS
    CURSOR okl_tasv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ICA_ID,
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
            TAS_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            TSU_CODE,
            TRY_ID,
            DATE_TRANS_OCCURRED
	    ,TRANS_NUMBER
	    ,COMMENTS
      FROM OKL_TRX_ASSETS
     WHERE OKL_TRX_ASSETS.id  = p_id;
    l_okl_tasv_pk                  okl_tasv_pk_csr%ROWTYPE;
    l_thpv_tbl                     thpv_tbl_type;
  BEGIN
    p_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tasv_pk_csr (p_thpv_tbl(1).id);
    FETCH okl_tasv_pk_csr INTO
              l_thpv_tbl(1).ID,
              l_thpv_tbl(1).OBJECT_VERSION_NUMBER,
              l_thpv_tbl(1).ICA_ID,
              l_thpv_tbl(1).ATTRIBUTE_CATEGORY,
              l_thpv_tbl(1).ATTRIBUTE1,
              l_thpv_tbl(1).ATTRIBUTE2,
              l_thpv_tbl(1).ATTRIBUTE3,
              l_thpv_tbl(1).ATTRIBUTE4,
              l_thpv_tbl(1).ATTRIBUTE5,
              l_thpv_tbl(1).ATTRIBUTE6,
              l_thpv_tbl(1).ATTRIBUTE7,
              l_thpv_tbl(1).ATTRIBUTE8,
              l_thpv_tbl(1).ATTRIBUTE9,
              l_thpv_tbl(1).ATTRIBUTE10,
              l_thpv_tbl(1).ATTRIBUTE11,
              l_thpv_tbl(1).ATTRIBUTE12,
              l_thpv_tbl(1).ATTRIBUTE13,
              l_thpv_tbl(1).ATTRIBUTE14,
              l_thpv_tbl(1).ATTRIBUTE15,
              l_thpv_tbl(1).TAS_TYPE,
              l_thpv_tbl(1).CREATED_BY,
              l_thpv_tbl(1).CREATION_DATE,
              l_thpv_tbl(1).LAST_UPDATED_BY,
              l_thpv_tbl(1).LAST_UPDATE_DATE,
              l_thpv_tbl(1).LAST_UPDATE_LOGIN,
              l_thpv_tbl(1).TSU_CODE,
              l_thpv_tbl(1).TRY_ID,
              l_thpv_tbl(1).DATE_TRANS_OCCURRED,
	      l_thpv_tbl(1).TRANS_NUMBER,
	      l_thpv_tbl(1).COMMENTS;
    p_no_data_found := okl_tasv_pk_csr%NOTFOUND;
    CLOSE okl_tasv_pk_csr;
    RETURN(l_thpv_tbl);
 END GET_TAS_HDR_REC;

 FUNCTION get_status
        (p_status_code  IN      VARCHAR2)
        RETURN VARCHAR2 aS
        CURSOR okl_status_lkp_csr(p_st_code IN VARCHAR2) IS
        SELECT  MEANING
        FROM    FND_LOOKUPS
        WHERE   LOOKUP_TYPE='OKL_TRANSACTION_STATUS'
        AND     LOOKUP_CODE=p_st_Code;
        l_status_meaning        VARCHAR2(80);
 BEGIN
        OPEN okl_status_lkp_csr(p_status_code);
        FETCH okl_status_lkp_csr INTO l_status_meaning;
        CLOSE okl_status_lkp_csr;
        RETURN l_status_meaning;
 END get_status;

 FUNCTION get_instance_id (
    p_instance_number 		IN	VARCHAR2)
 RETURN NUMBER AS

   CURSOR okl_inst_id_csr(l_instance_number IN VARCHAR2)
   IS
   SELECT instance_id
   FROM okx_install_items_v
   where instance_number = l_instance_number;

   l_instance_id 	NUMBER;

  BEGIN

	OPEN okl_inst_id_csr(p_instance_number);
	FETCH okl_inst_id_csr INTO l_instance_id;
	CLOSE okl_inst_id_csr;

	RETURN l_instance_id;

  END get_instance_id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_ASSETS_V
  ---------------------------------------------------------------------------
  FUNCTION get_tal_rec (
    p_talv_tbl                     IN talv_tbl_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN talv_tbl_type aS
    CURSOR okl_talv_pk_csr (p_tas_id    IN NUMBER
                           ,p_tal_type  IN VARCHAR2) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           TAS_ID,
           ILO_ID,
           ILO_ID_OLD,
           IAY_ID,
           IAY_ID_NEW,
           KLE_ID,
           DNZ_KHR_ID,
           LINE_NUMBER,
           ORG_ID,
           TAL_TYPE,
           ASSET_NUMBER,
           DESCRIPTION,
           FA_LOCATION_ID,
           ORIGINAL_COST,
           CURRENT_UNITS,
           MANUFACTURER_NAME,
           YEAR_MANUFACTURED,
           SUPPLIER_ID,
           USED_ASSET_YN,
           TAG_NUMBER,
           MODEL_NUMBER,
           CORPORATE_BOOK,
           DATE_PURCHASED,
           DATE_DELIVERY,
           IN_SERVICE_DATE,
           LIFE_IN_MONTHS,
           DEPRECIATION_ID,
           DEPRECIATION_COST,
           DEPRN_METHOD,
           DEPRN_RATE,
           SALVAGE_VALUE,
           PERCENT_SALVAGE_VALUE,
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
           LAST_UPDATE_LOGIN,
           DEPRECIATE_YN,
           HOLD_PERIOD_DAYS,
           OLD_SALVAGE_VALUE,
           NEW_RESIDUAL_VALUE,
           OLD_RESIDUAL_VALUE,
           UNITS_RETIRED,
           COST_RETIRED,
           SALE_PROCEEDS,
           REMOVAL_COST,
           DNZ_ASSET_ID
	  ,DATE_DUE
      FROM Okl_Txl_Assets_V
     WHERE okl_txl_assets_v.tas_id  = p_tas_id
     AND   okl_txl_assets_v.tal_type = p_tal_type;
    l_okl_talv_pk                  okl_talv_pk_csr%ROWTYPE;
    l_talv_tbl                    talv_tbl_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_talv_pk_csr (p_talv_tbl(1).tas_id,p_talv_tbl(1).tal_type);
    FETCH okl_talv_pk_csr INTO
              l_talv_tbl(1).ID,
              l_talv_tbl(1).OBJECT_VERSION_NUMBER,
              l_talv_tbl(1).SFWT_FLAG,
              l_talv_tbl(1).TAS_ID,
              l_talv_tbl(1).ILO_ID,
              l_talv_tbl(1).ILO_ID_OLD,
              l_talv_tbl(1).IAY_ID,
              l_talv_tbl(1).IAY_ID_NEW,
              l_talv_tbl(1).KLE_ID,
              l_talv_tbl(1).DNZ_KHR_ID,
              l_talv_tbl(1).LINE_NUMBER,
              l_talv_tbl(1).ORG_ID,
              l_talv_tbl(1).TAL_TYPE,
              l_talv_tbl(1).ASSET_NUMBER,
              l_talv_tbl(1).DESCRIPTION,
              l_talv_tbl(1).FA_LOCATION_ID,
              l_talv_tbl(1).ORIGINAL_COST,
              l_talv_tbl(1).CURRENT_UNITS,
              l_talv_tbl(1).MANUFACTURER_NAME,
              l_talv_tbl(1).YEAR_MANUFACTURED,
              l_talv_tbl(1).SUPPLIER_ID,
              l_talv_tbl(1).USED_ASSET_YN,
              l_talv_tbl(1).TAG_NUMBER,
              l_talv_tbl(1).MODEL_NUMBER,
              l_talv_tbl(1).CORPORATE_BOOK,
              l_talv_tbl(1).DATE_PURCHASED,
              l_talv_tbl(1).DATE_DELIVERY,
              l_talv_tbl(1).IN_SERVICE_DATE,
              l_talv_tbl(1).LIFE_IN_MONTHS,
              l_talv_tbl(1).DEPRECIATION_ID,
              l_talv_tbl(1).DEPRECIATION_COST,
              l_talv_tbl(1).DEPRN_METHOD,
              l_talv_tbl(1).DEPRN_RATE,
              l_talv_tbl(1).SALVAGE_VALUE,
              l_talv_tbl(1).PERCENT_SALVAGE_VALUE,
              l_talv_tbl(1).ATTRIBUTE_CATEGORY,
              l_talv_tbl(1).ATTRIBUTE1,
              l_talv_tbl(1).ATTRIBUTE2,
              l_talv_tbl(1).ATTRIBUTE3,
              l_talv_tbl(1).ATTRIBUTE4,
              l_talv_tbl(1).ATTRIBUTE5,
              l_talv_tbl(1).ATTRIBUTE6,
              l_talv_tbl(1).ATTRIBUTE7,
              l_talv_tbl(1).ATTRIBUTE8,
              l_talv_tbl(1).ATTRIBUTE9,
              l_talv_tbl(1).ATTRIBUTE10,
              l_talv_tbl(1).ATTRIBUTE11,
              l_talv_tbl(1).ATTRIBUTE12,
              l_talv_tbl(1).ATTRIBUTE13,
              l_talv_tbl(1).ATTRIBUTE14,
              l_talv_tbl(1).ATTRIBUTE15,
              l_talv_tbl(1).CREATED_BY,
              l_talv_tbl(1).CREATION_DATE,
              l_talv_tbl(1).LAST_UPDATED_BY,
              l_talv_tbl(1).LAST_UPDATE_DATE,
              l_talv_tbl(1).LAST_UPDATE_LOGIN,
              l_talv_tbl(1).DEPRECIATE_YN,
              l_talv_tbl(1).HOLD_PERIOD_DAYS,
              l_talv_tbl(1).OLD_SALVAGE_VALUE,
              l_talv_tbl(1).NEW_RESIDUAL_VALUE,
              l_talv_tbl(1).OLD_RESIDUAL_VALUE,
              l_talv_tbl(1).UNITS_RETIRED,
              l_talv_tbl(1).COST_RETIRED,
              l_talv_tbl(1).SALE_PROCEEDS,
              l_talv_tbl(1).REMOVAL_COST,
              l_talv_tbl(1).DNZ_ASSET_ID,
              l_talv_tbl(1).DATE_DUE;
    x_no_data_found := okl_talv_pk_csr%NOTFOUND;
    CLOSE okl_talv_pk_csr;
    RETURN(l_talv_tbl);
  END get_tal_rec;

 FUNCTION get_vendor_name
        (p_vendor_id  IN      VARCHAR2)
        RETURN VARCHAR2 aS
        CURSOR okl_vendor_lkp_csr(p_vendor_id IN VARCHAR2) IS
        SELECT  NAME
        FROM    OKX_VENDORS_V
        WHERE   ID1=p_vendor_id;
        l_vendor_name   VARCHAR2(240);
 BEGIN
        OPEN okl_vendor_lkp_csr(p_vendor_id);
        FETCH okl_vendor_lkp_csr INTO l_vendor_name;
        CLOSE okl_vendor_lkp_csr;
        RETURN l_vendor_name;
 END get_vendor_name;

  FUNCTION get_item_rec (
    p_itiv_tbl                     IN itiv_tbl_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN itiv_tbl_type aS
    CURSOR okl_itiv_pk_csr (p_id IN NUMBER,p_tal_type IN VARCHAR2) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           TAS_ID,
           TAL_ID,
           KLE_ID,
           TAL_TYPE,
           LINE_NUMBER,
           INSTANCE_NUMBER_IB,
           OBJECT_ID1_NEW,
           OBJECT_ID2_NEW,
           JTOT_OBJECT_CODE_NEW,
           OBJECT_ID1_OLD,
           OBJECT_ID2_OLD,
           JTOT_OBJECT_CODE_OLD,
           INVENTORY_ORG_ID,
           SERIAL_NUMBER,
           MFG_SERIAL_NUMBER_YN,
           INVENTORY_ITEM_ID,
           INV_MASTER_ORG_ID,
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
    FROM OKL_TXL_ITM_INSTS iti
    WHERE iti.tas_id  = p_id
    AND   iti.tal_type = p_tal_type;
    l_okl_itiv_pk                  okl_itiv_pk_csr%ROWTYPE;
    l_itiv_tbl                     itiv_tbl_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_itiv_pk_csr (p_itiv_tbl(1).tas_id,p_itiv_tbl(1).tal_type);
    FETCH okl_itiv_pk_csr INTO
              l_itiv_tbl(1).ID,
              l_itiv_tbl(1).OBJECT_VERSION_NUMBER,
              l_itiv_tbl(1).TAS_ID,
              l_itiv_tbl(1).TAL_ID,
              l_itiv_tbl(1).KLE_ID,
              l_itiv_tbl(1).TAL_TYPE,
              l_itiv_tbl(1).LINE_NUMBER,
              l_itiv_tbl(1).INSTANCE_NUMBER_IB,
              l_itiv_tbl(1).OBJECT_ID1_NEW,
              l_itiv_tbl(1).OBJECT_ID2_NEW,
              l_itiv_tbl(1).JTOT_OBJECT_CODE_NEW,
              l_itiv_tbl(1).OBJECT_ID1_OLD,
              l_itiv_tbl(1).OBJECT_ID2_OLD,
              l_itiv_tbl(1).JTOT_OBJECT_CODE_OLD,
              l_itiv_tbl(1).INVENTORY_ORG_ID,
              l_itiv_tbl(1).SERIAL_NUMBER,
              l_itiv_tbl(1).MFG_SERIAL_NUMBER_YN,
              l_itiv_tbl(1).INVENTORY_ITEM_ID,
              l_itiv_tbl(1).INV_MASTER_ORG_ID,
              l_itiv_tbl(1).ATTRIBUTE_CATEGORY,
              l_itiv_tbl(1).ATTRIBUTE1,
              l_itiv_tbl(1).ATTRIBUTE2,
              l_itiv_tbl(1).ATTRIBUTE3,
              l_itiv_tbl(1).ATTRIBUTE4,
              l_itiv_tbl(1).ATTRIBUTE5,
              l_itiv_tbl(1).ATTRIBUTE6,
              l_itiv_tbl(1).ATTRIBUTE7,
              l_itiv_tbl(1).ATTRIBUTE8,
              l_itiv_tbl(1).ATTRIBUTE9,
              l_itiv_tbl(1).ATTRIBUTE10,
              l_itiv_tbl(1).ATTRIBUTE11,
              l_itiv_tbl(1).ATTRIBUTE12,
              l_itiv_tbl(1).ATTRIBUTE13,
              l_itiv_tbl(1).ATTRIBUTE14,
              l_itiv_tbl(1).ATTRIBUTE15,
              l_itiv_tbl(1).CREATED_BY,
              l_itiv_tbl(1).CREATION_DATE,
              l_itiv_tbl(1).LAST_UPDATED_BY,
              l_itiv_tbl(1).LAST_UPDATE_DATE,
              l_itiv_tbl(1).LAST_UPDATE_LOGIN;
    x_no_data_found := okl_itiv_pk_csr%NOTFOUND;
    CLOSE okl_itiv_pk_csr;
    RETURN(l_itiv_tbl);
  END get_item_rec;

FUNCTION get_exchange_type
        (p_tas_id  IN      NUMBER) RETURN VARCHAR2
aS
	l_exchange_type 	VARCHAR2(60);

	CURSOR c_exch_type IS
	SELECT TAS_TYPE
	FROM	OKL_TRX_ASSETS
	WHERE	ID=p_tas_id;
BEGIN

	OPEN c_exch_type;
	FETCH c_exch_type into l_exchange_type;
	CLOSE c_exch_type;
	RETURN l_exchange_type;
END get_exchange_type;

-----------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_trx_rec
  --Purpose               : Gets source transaction record for IB interface
  --Modification History  :
  --15-Jun-2001    ashish.singh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
------------------------------------------------------------------------------
  PROCEDURE get_trx_rec
    (p_api_version                  IN  NUMBER,
	 p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status                OUT NOCOPY VARCHAR2,
	 x_msg_count                    OUT NOCOPY NUMBER,
	 x_msg_data                     OUT NOCOPY VARCHAR2,
     p_cle_id                       IN  NUMBER,
     p_transaction_type             IN  VARCHAR2,
     x_trx_rec                      OUT NOCOPY transaction_rec) is

     l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_name          CONSTANT VARCHAR2(30) := 'GET_TRX_REC';
     l_api_version	     CONSTANT NUMBER	:= 1.0;

--Following cursor assumes that a transaction type called
--'OKL LINE ACTIVATION' and 'OKL SPLIT ASSET' will be seeded in IB
     -- Bug# 8459840  - Cursor changed to retrieve from base tables
     -- commenting the below, added the changed cursor.
     /*
     Cursor okl_trx_type_curs(p_transaction_type IN VARCHAR2)is
            select transaction_type_id
            from   CS_TRANSACTION_TYPES_V
            where  Name = p_transaction_type;
     */
	 -- Note: Not using Name column in tt as it can be null.
     Cursor okl_trx_type_curs(p_transaction_type IN VARCHAR2)is
       SELECT tt.transaction_type_id
         FROM  cs_transaction_types_b tt,
               cs_transaction_types_tl ttl
        WHERE  tt.transaction_type_id = ttl.transaction_type_id
           AND ttl.language = 'US'
           AND ttl.NAME = p_transaction_type;
    -- end bug 8459840

     l_trx_type_id NUMBER;
 Begin
    -- Bug# 8459840 - Start actvity
    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);
    --Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- end bug 8459840

     open okl_trx_type_curs(p_transaction_type);
        Fetch okl_trx_type_curs
        into  l_trx_type_id;
        If okl_trx_type_curs%NotFound Then
           --OKL LINE ACTIVATION not seeded as a source transaction in IB
           Raise OKL_API.G_EXCEPTION_ERROR;
        End If;
     close okl_trx_type_curs;
     --Assign transaction Type id to seeded value in cs_lookups
     x_trx_rec.transaction_type_id := l_trx_type_id;
     --Assign Source Line Ref id to contract line id of IB instance line
     x_trx_rec.source_line_ref_id := p_cle_id;
     x_trx_rec.transaction_date := sysdate;
     x_trx_rec.source_transaction_date := sysdate;
    Exception
    When OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END get_trx_rec;


---------------------------------------------------------------------------------------------


PROCEDURE init_ib_rec(l_instance_rec    OUT NOCOPY     instance_rec)
AS
BEGIN
        l_instance_rec.INSTANCE_ID              :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INSTANCE_NUMBER          :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.EXTERNAL_REFERENCE       :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.INVENTORY_ITEM_ID        :=      OKL_API.G_MISS_NUM;
        l_instance_rec.VLD_ORGANIZATION_ID      :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INVENTORY_REVISION       :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.INV_MASTER_ORGANIZATION_ID       :=      OKL_API.G_MISS_NUM;
        l_instance_rec.SERIAL_NUMBER            :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.MFG_SERIAL_NUMBER_FLAG   :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.LOT_NUMBER               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.QUANTITY                 :=      OKL_API.G_MISS_NUM;
        l_instance_rec.UNIT_OF_MEASURE          :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ACCOUNTING_CLASS_CODE    :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.INSTANCE_CONDITION_ID    :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INSTANCE_STATUS_ID       :=      OKL_API.G_MISS_NUM;
        l_instance_rec.CUSTOMER_VIEW_FLAG       :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.MERCHANT_VIEW_FLAG       :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.SELLABLE_FLAG            :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.SYSTEM_ID                :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INSTANCE_TYPE_CODE       :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ACTIVE_START_DATE        :=      OKL_API.G_MISS_DATE;
        l_instance_rec.ACTIVE_END_DATE          :=      OKL_API.G_MISS_DATE;
        l_instance_rec.LOCATION_TYPE_CODE       :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.LOCATION_ID              :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INV_ORGANIZATION_ID      :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INV_SUBINVENTORY_NAME    :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.INV_LOCATOR_ID           :=      OKL_API.G_MISS_NUM;
        l_instance_rec.PA_PROJECT_ID            :=      OKL_API.G_MISS_NUM;
        l_instance_rec.PA_PROJECT_TASK_ID       :=      OKL_API.G_MISS_NUM;
        l_instance_rec.IN_TRANSIT_ORDER_LINE_ID :=      OKL_API.G_MISS_NUM;
        l_instance_rec.WIP_JOB_ID               :=      OKL_API.G_MISS_NUM;
        l_instance_rec.PO_ORDER_LINE_ID         :=      OKL_API.G_MISS_NUM;
        l_instance_rec.LAST_OE_ORDER_LINE_ID    :=      OKL_API.G_MISS_NUM;
        l_instance_rec.LAST_OE_RMA_LINE_ID      :=      OKL_API.G_MISS_NUM;
        l_instance_rec.LAST_PO_PO_LINE_ID       :=      OKL_API.G_MISS_NUM;
        l_instance_rec.LAST_OE_PO_NUMBER        :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.LAST_WIP_JOB_ID          :=      OKL_API.G_MISS_NUM;
        l_instance_rec.LAST_PA_PROJECT_ID       :=      OKL_API.G_MISS_NUM;
        l_instance_rec.LAST_PA_TASK_ID          :=      OKL_API.G_MISS_NUM;
        l_instance_rec.LAST_OE_AGREEMENT_ID     :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INSTALL_DATE             :=      OKL_API.G_MISS_DATE;
        l_instance_rec.MANUALLY_CREATED_FLAG    :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.RETURN_BY_DATE           :=      OKL_API.G_MISS_DATE;
        l_instance_rec.ACTUAL_RETURN_DATE       :=      OKL_API.G_MISS_DATE;
        l_instance_rec.CREATION_COMPLETE_FLAG   :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.COMPLETENESS_FLAG        :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.VERSION_LABEL            :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.VERSION_LABEL_DESCRIPTION        :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.CONTEXT                  :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE1               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE2               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE3               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE4               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE5               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE6               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE7               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE8               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE9               :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE10              :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE11              :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE12              :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE13              :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE14              :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.ATTRIBUTE15              :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.OBJECT_VERSION_NUMBER    :=      OKL_API.G_MISS_NUM;
        l_instance_rec.LAST_TXN_LINE_DETAIL_ID  :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INSTALL_LOCATION_TYPE_CODE       :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.INSTALL_LOCATION_ID      :=      OKL_API.G_MISS_NUM;
        l_instance_rec.INSTANCE_USAGE_CODE      :=      OKL_API.G_MISS_CHAR;
        l_instance_rec.CHECK_FOR_INSTANCE_EXPIRY        :=      OKL_API.G_TRUE;
END init_ib_rec;


  PROCEDURE update_serial_number(
       p_api_version                    IN  NUMBER,
       p_init_msg_list                  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
       p_instance_id                 	IN  NUMBER,
       p_instance_name                 	IN  VARCHAR2,
       p_serial_number                  IN  VARCHAR2,
       p_inventory_item_id		IN  NUMBER,
       x_return_status                  OUT NOCOPY VARCHAR2,
       x_msg_count                      OUT NOCOPY NUMBER,
       x_msg_data                       OUT NOCOPY VARCHAR2)
  AS


	l_api_name            CONSTANT VARCHAR2(30)  := 'UPDATE_SERIAL_NUMBER';
	l_object_version_number	NUMBER;
	l_instance_rec		instance_rec;
  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--Doing this temporarily, need to talk Ashish about some patch to be installed.

		select object_version_number into l_object_version_number from csi_item_instances
		where instance_id = p_instance_id;
	init_ib_rec(l_instance_rec);

          l_instance_rec.instance_id     	:= to_number(p_instance_id);
          l_instance_rec.serial_number     	:= p_serial_number;
          l_instance_rec.object_version_number 	:= l_object_version_number;
 	  l_instance_rec.MFG_SERIAL_NUMBER_FLAG := 'N';


                  get_trx_rec(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_cle_id        => NULL,
                              p_transaction_type => 'New',
                              x_trx_rec       => l_txn_rec);

        csi_item_instance_pub.update_item_instance(p_api_version           =>  p_api_version,
                                                   p_commit                =>  fnd_api.g_false,
                                                   p_init_msg_list         =>  p_init_msg_list,
                                                   p_instance_rec          =>  l_instance_rec,
                                                   p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
                                                   p_party_tbl             =>  l_party_tbl,
                                                   p_account_tbl           =>  l_account_tbl,
                                                   p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
                                                   p_org_assignments_tbl   =>  l_org_assignments_tbl,
                                                   p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
                                                   p_txn_rec               =>  l_txn_rec,
                                                   x_instance_id_lst       =>  l_instance_id_lst,
                                                   x_return_status         =>  x_return_status,
                                                   x_msg_count             =>  x_msg_count,
                                                   x_msg_data              =>  x_msg_data);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');

  END update_serial_number;




  PROCEDURE Update_item_description(
                      p_api_version            IN  NUMBER,
                      p_init_msg_list          IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                      x_return_status          OUT NOCOPY VARCHAR2,
                      x_msg_count              OUT NOCOPY NUMBER,
                      x_msg_data               OUT NOCOPY VARCHAR2,
                      p_dnz_chr_id             IN  NUMBER,
                      p_parent_line_id         IN  NUMBER,
                      p_item_description       IN  VARCHAR2) AS

   subtype klev_rec_type is okl_CONTRACT_PVT.klev_rec_type;

    l_klev_rec       klev_rec_type;
    l_clev_rec       okl_okc_migration_pvt.clev_rec_type;
    lx_klev_rec      klev_rec_type;
    lx_clev_rec      okl_okc_migration_pvt.clev_rec_type;

    l_api_name            CONSTANT VARCHAR2(30)  := 'UPDATE_ITEM_DESCRIPTION';

    --akrangan bug 5362977  start
       CURSOR cr_parent_line_id (c_line_id IN NUMBER)
       IS
       SELECT parent_line_id
       FROM OKX_ASSET_LINES_V
       WHERE id1=c_line_id;
       l_parent_line_id  NUMBER;
       --akrangan bug 5362977  end

 BEGIN
   x_return_status    := OKL_API.G_RET_STS_SUCCESS;


    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_klev_rec.id                   := p_parent_line_id;

    l_clev_rec.id                   := p_parent_line_id;
    l_clev_rec.dnz_chr_id           := p_dnz_chr_id;
    l_clev_rec.item_description     := p_item_description;

    OKL_CONTRACT_PUB.update_contract_line(
                                          p_api_version        => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_clev_rec           => l_clev_rec,
                                          p_klev_rec           => l_klev_rec,
                                          x_clev_rec           => lx_clev_rec,
                                          x_klev_rec           => lx_klev_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
        --akrangan bug 5362977  start
       OPEN cr_parent_line_id(p_parent_line_id);
       FETCH cr_parent_line_id INTO l_parent_line_id;
       CLOSE cr_parent_line_id;

       l_klev_rec.id                   := l_parent_line_id;
       l_clev_rec.id                   := l_parent_line_id;

       OKL_CONTRACT_PUB.update_contract_line(
                                             p_api_version        => p_api_version,
                                             p_init_msg_list      => p_init_msg_list,
                                             x_return_status      => x_return_status,
                                             x_msg_count          => x_msg_count,
                                             x_msg_data           => x_msg_data,
                                             p_clev_rec           => l_clev_rec,
                                             p_klev_rec           => l_klev_rec,
                                             x_clev_rec           => lx_clev_rec,
                                             x_klev_rec           => lx_klev_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
        --akrangan bug 5362977  end

   OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );


  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');

 END Update_item_description;

PROCEDURE parse_desc(
                p_desc          IN      VARCHAR2
                ,p_asset_desc   OUT NOCOPY     VARCHAR2
                ,p_item_desc    OUT NOCOPY     VARCHAR2)
AS
	l_token	VARCHAR2(5) := '|||';
BEGIN

        p_asset_desc := substr(p_desc,0,instr(p_desc,l_token,1,1) - 1);
        p_item_desc  := substr(p_desc,-(length(p_desc)- instr(p_desc,l_token,1,1) - 2));

END parse_desc;



---------------------------------------------------------------

   PROCEDURE store_exchange_details (
                        p_api_version                    IN  NUMBER,
                        p_init_msg_list                  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        p_thpv_tbl                       IN  thpv_tbl_type,
                        p_old_tlpv_tbl                   IN  tlpv_tbl_type,
                        p_new_tlpv_tbl                   IN  tlpv_tbl_type,
                        p_old_iipv_tbl                   IN  iipv_tbl_type,
                        p_new_iipv_tbl                   IN  iipv_tbl_type,
                        x_thpv_tbl                       OUT NOCOPY  thpv_tbl_type,
                        x_old_tlpv_tbl                   OUT NOCOPY  tlpv_tbl_type,
                        x_new_tlpv_tbl                   OUT NOCOPY  tlpv_tbl_type,
                        x_old_iipv_tbl                   OUT NOCOPY  iipv_tbl_type,
                        x_new_iipv_tbl                   OUT NOCOPY  iipv_tbl_type,
                        x_return_status                  OUT NOCOPY VARCHAR2,
                        x_msg_count                      OUT NOCOPY NUMBER,
                        x_msg_data                       OUT NOCOPY VARCHAR2)
    AS
    	l_api_name            	CONSTANT VARCHAR2(30)  := 'STORE_EXCHANGE_DETAILS';
	l_old_tlpv_tbl		tlpv_tbl_type := p_old_tlpv_tbl;
	l_new_tlpv_tbl		tlpv_tbl_type := p_new_tlpv_tbl;
	l_old_iipv_tbl		iipv_tbl_type := p_old_iipv_tbl;
	l_new_iipv_tbl		iipv_tbl_type := p_new_iipv_tbl;
	l_thpv_tbl		thpv_tbl_type := p_thpv_tbl;

	--dkagrawa added for Bug# 4723820 starts
        l_conv_type     OKL_K_HEADERS.CURRENCY_CONVERSION_TYPE%TYPE;
        l_conv_rate     OKL_K_HEADERS.CURRENCY_CONVERSION_RATE%TYPE;
	CURSOR l_conv_rate_csr ( cp_khr_id IN NUMBER ) IS
        SELECT currency_conversion_type,
               currency_conversion_rate
        FROM   OKL_K_HEADERS
        WHERE  id = cp_khr_id;
        --dkagrawa for Bug# 4723820 ends

	CURSOR okl_trn_c IS
	SELECT okl_trn_seq.nextval
	FROM   dual;


    BEGIN
   	x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    	--Call start_activity to create savepoint, check compatibility and initialize message list

    	x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    	--Check if activity started successfully

    	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    	END IF;

	-- Create the Header Row

	OPEN okl_trn_c;
	FETCH okl_trn_c INTO l_thpv_tbl(1).trans_number;
	CLOSE okl_trn_c;
	okl_trx_assets_pub.create_trx_ass_h_def(
                                p_api_version	=> p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count	=> x_msg_count,
                                x_msg_data	=> x_msg_data,
                                p_thpv_tbl	=> l_thpv_tbl,
                                x_thpv_tbl  	=> x_thpv_tbl);

	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	--populate the TAS_Id to the old lines plsql table.
	l_old_tlpv_tbl(1).TAS_ID := x_thpv_tbl(1).ID;

	--dkagrawa added for Bug# 4723820 starts
        OPEN l_conv_rate_csr (l_old_tlpv_tbl(1).dnz_khr_id);
        FETCH l_conv_rate_csr INTO l_conv_type,l_conv_rate;
        CLOSE l_conv_rate_csr;
        IF l_conv_type = 'User' THEN
          FOR i IN 1..l_old_tlpv_tbl.COUNT LOOP
            l_old_tlpv_tbl(i).currency_conversion_rate := l_conv_rate;
          END LOOP;
        END IF;
        --dkagrawa for Bug# 4723820 ends

	--Create the old line in the okl_txl_assets table
	okl_txl_assets_pub.create_txl_asset_def(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count	=> x_msg_count,
                                x_msg_data	=> x_msg_data,
                                p_tlpv_tbl	=> l_old_tlpv_tbl,
                                x_tlpv_tbl  	=> x_old_tlpv_tbl);

	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	 --Change done for making serial number optional.
     IF l_old_iipv_tbl(1).serial_number is not NULL THEN

	--populate the TAS_Id to the old items plsql table.
	l_old_iipv_tbl(1).TAS_ID := x_thpv_tbl(1).ID;

	--Create a old line in item instances also.
	okl_txl_itm_insts_pub.create_txl_itm_insts(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
    				p_iipv_tbl      => l_old_iipv_tbl,
    				x_iipv_tbl      => x_old_iipv_tbl);

	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;
	--populate the TAS_Id to the new lines plsql table.
    	l_new_tlpv_tbl(1).TAS_ID := x_thpv_tbl(1).ID;

	--dkagrawa added for Bug# 4723820 starts
        IF l_conv_type = 'User' THEN
          FOR i IN 1..l_new_tlpv_tbl.COUNT LOOP
            l_new_tlpv_tbl(i).currency_conversion_rate := l_conv_rate;
          END LOOP;
        END IF;
        --dkagrawa for Bug# 4723820 ends

	--Create the new line in the okl_txl_assets table
	okl_txl_assets_pub.create_txl_asset_def(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_tlpv_tbl      => l_new_tlpv_tbl,
                                x_tlpv_tbl      => x_new_tlpv_tbl);

	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


	 --Change done for making serial number optional
       IF l_new_iipv_tbl(1).serial_number is not NULL THEN

	--populate the TAS_Id to the new items plsql table.
	l_new_iipv_tbl(1).TAS_ID := x_thpv_tbl(1).ID;

	--Create a new line in item instances also.
	okl_txl_itm_insts_pub.create_txl_itm_insts(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
    				p_iipv_tbl      => l_new_iipv_tbl,
    				x_iipv_tbl      => x_new_iipv_tbl);

	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');

   END store_exchange_details;







   PROCEDURE exchange(
		p_api_version		IN	NUMBER,
		p_init_msg_list		IN	VARCHAR2 := OKL_API.G_FALSE,
		p_tas_id                IN  	NUMBER,
       		x_return_status         OUT NOCOPY VARCHAR2,
	 	x_msg_count             OUT NOCOPY NUMBER,
	 	x_msg_data              OUT NOCOPY VARCHAR2)
   AS

	p_talv_tbl		talv_tbl_type;
	x_talv_tbl		talv_tbl_type;

	p_thpv_tbl		thpv_tbl_type;
	x_thpv_tbl		thpv_tbl_type;
	p_no_data_found            BOOLEAN;

	p_itiv_tbl		itiv_tbl_type;
	x_itiv_tbl		itiv_tbl_type;

	p_cplv_rec		cplv_rec_type;
	x_cplv_rec		cplv_rec_type;

	p_cvmv_rec		cvmv_rec_type;
	x_cvmv_rec		cvmv_rec_type;

	x_year			NUMBER;
        l_api_name              CONSTANT VARCHAR2(30)  := 'EXCHANGE';

	l_ct_line_id		NUMBER;
	l_vendor_id1		NUMBER;
	l_vendor_id2		VARCHAR2(30);
	l_okc_party_roles_id	NUMBER;
	l_instance_id		NUMBER;
	l_asset_desc		VARCHAR2(80);
	l_item_desc		VARCHAR2(1995);
	l_id1_okx_asset_lines   NUMBER;

    CURSOR c_model_line(c_parent_line_id NUMBER) IS
    SELECT A.ID
    FROM   OKC_K_LINES_V A,
           OKC_LINE_STYLES_B B
    WHERE  A.CLE_ID = c_parent_line_id
    AND    A.LSE_ID = B.ID
    AND    B.LTY_CODE = 'ITEM';

    CURSOR c_vendor(c_model_line_id NUMBER) IS
    SELECT B.ID
    FROM   AP_SUPPLIERS A,
      	   OKC_K_PARTY_ROLES_B B
    WHERE  A.VENDOR_ID = B.OBJECT1_ID1
      	   AND B.RLE_CODE  = 'OKL_VENDOR'
           AND B.CLE_ID = c_model_line_id;

    CURSOR c_new_vendor(c_id NUMBER) IS
    SELECT ID2
    FROM   OKX_VENDORS_V
    where id1=c_id;

     CURSOR c_asset_id1 (c_khr_id NUMBER,c_asset_id NUMBER,c_Asset_number VARCHAR2) IS
     SELECT CLE.ID ID1
     FROM OKC_K_LINES_B CLE,
          OKC_K_ITEMS CIM
     WHERE  CLE.DNZ_CHR_ID=c_khr_id
            AND CIM.CLE_ID = CLE.ID
            AND CIM.JTOT_OBJECT1_CODE = 'OKX_ASSET'
            AND CIM.DNZ_CHR_ID = CLE.DNZ_CHR_ID
            AND CIM.Object1_id1 = c_asset_id
            AND CLE.STS_CODE <> 'ABANDONED';


   BEGIN

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	-- probably i might have to take the transaction id/request id and
	--  use it to get the relevant asset details for the new asset and then
	--  use this info to update the FA tables
	-- update all the asset details
	p_talv_tbl(1).tas_id    := p_tas_id;
        p_talv_tbl(1).tal_type  := 'NAS';
        x_talv_tbl              := OKL_EQUIPMENT_EXCHANGE_PVT.GET_TAL_REC(p_talv_tbl,p_no_data_found);
	parse_desc(x_talv_tbl(1).description,l_asset_desc,l_item_desc);

--Have to version the contract before doing any of the following tasks.
	p_cvmv_rec.chr_id	:= x_talv_tbl(1).dnz_khr_id;

	okl_version_pub.version_contract(p_api_version   => p_api_version,
                                p_init_msg_list          => p_init_msg_list,
                                x_return_status          => x_return_status,
                                x_msg_count              => x_msg_count,
                                x_msg_data               => x_msg_data,
				p_cvmv_rec		 => p_cvmv_rec,
				x_cvmv_rec		 => x_cvmv_rec,
				p_commit		 => 'T');

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


-- This piece of code is added to fix Bug 2477684
-- FA has changed their APIs as per the new standards of treating NULL as FND_API.G_MISS
-- So we have to pass these constants if we want to update the values to NULL.

If (x_talv_tbl(1).model_number is NULL) THEN
   x_talv_tbl(1).model_number := FND_API.G_MISS_CHAR;
END IF;

If (x_talv_tbl(1).manufacturer_name is NULL) THEN
   x_talv_tbl(1).manufacturer_name := FND_API.G_MISS_CHAR;
END IF;


	 okl_asset_details_pub.update_asset(p_api_version             => p_api_version,
                         	p_init_msg_list          => p_init_msg_list,
                         	x_return_status          => x_return_status,
                         	x_msg_count              => x_msg_count,
                         	x_msg_data               => x_msg_data,
                         	p_asset_id               => to_number(x_talv_tbl(1).dnz_asset_id),
                         	p_asset_number           => x_talv_tbl(1).asset_number,
				px_asset_desc		 => l_asset_desc,
                         	px_model_no              => x_talv_tbl(1).model_number,
                         	px_manufacturer          => x_talv_tbl(1).manufacturer_name);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


     OPEN c_asset_id1(x_talv_tbl(1).dnz_khr_id,x_talv_tbl(1).dnz_asset_id,x_talv_tbl(1).asset_number);
     FETCH c_asset_id1 into l_id1_okx_asset_lines;
     CLOSE c_asset_id1;

-- This piece of code is changed to fix Bug 2477684
-- The year should be updated even if it is NULL.. so remove this check.

--	IF x_talv_tbl(1).year_manufactured IS NOT NULL then
         okl_asset_details_pub.update_year(p_api_version             => p_api_version,
                                p_init_msg_list          => p_init_msg_list,
                                x_return_status          => x_return_status,
                                x_msg_count              => x_msg_count,
                                x_msg_data               => x_msg_data,
				p_dnz_chr_id		 => x_talv_tbl(1).dnz_khr_id,
				p_parent_line_id         => l_id1_okx_asset_lines,
                      		p_year                   => x_talv_tbl(1).year_manufactured,
                      		x_year                   => x_year);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
--	END IF;


         update_item_description(p_api_version             => p_api_version,
                                p_init_msg_list          => p_init_msg_list,
                                x_return_status          => x_return_status,
                                x_msg_count              => x_msg_count,
                                x_msg_data               => x_msg_data,
                                p_dnz_chr_id             => x_talv_tbl(1).dnz_khr_id,
                                --p_parent_line_id         => x_itiv_tbl(1).kle_id,
                                p_parent_line_id         => l_id1_okx_asset_lines,
                                --akrangan bug 5362977 start
				--p_item_description       => l_item_desc);
                                p_item_description       => l_asset_desc);
				--akrangan bug 5362977 end
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


 --change for making sno optional
    	p_itiv_tbl(1).tas_id    := p_tas_id;
         p_itiv_tbl(1).tal_type  := 'NAS';
         x_itiv_tbl              := OKL_EQUIPMENT_EXCHANGE_PVT.GET_ITEM_REC(p_itiv_tbl,p_no_data_found);
     If not p_no_data_found then

	l_instance_id := get_instance_id( x_itiv_tbl(1).instance_number_ib);
   	update_serial_number(p_api_version       => p_api_version,
                        p_init_msg_list          => p_init_msg_list,
       			p_instance_id            => l_instance_id,
       			p_instance_name          => x_itiv_tbl(1).instance_number_ib,
       			p_serial_number          => x_itiv_tbl(1).serial_number,
			p_inventory_item_id	 => x_itiv_tbl(1).inventory_item_id,
                        x_return_status          => x_return_status,
                        x_msg_count              => x_msg_count,
                        x_msg_data               => x_msg_data);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      end if; -- for p_no_data_found
---------------------------------------------------------
   OPEN c_model_line(x_talv_tbl(1).kle_id);
   FETCH c_model_line INTO l_ct_line_id;
   CLOSE c_model_line;

   IF l_ct_line_id IS NOT NULL THEN
      OPEN c_vendor(l_ct_line_id);
      FETCH c_vendor INTO l_okc_party_roles_id;
      CLOSE c_vendor;
   END IF;

	l_vendor_id1 := x_talv_tbl(1).supplier_id;
   IF l_okc_party_roles_id IS NOT NULL  AND l_vendor_id1 IS NOT NULL THEN

	OPEN c_new_vendor(x_talv_tbl(1).supplier_id);
	FETCH c_new_vendor INTO l_vendor_id2;
	CLOSE c_new_vendor;

	p_cplv_rec.id			:=	l_okc_party_roles_id;
	p_cplv_rec.object1_id1		:=	l_vendor_id1;
	p_cplv_rec.object1_id2		:=	l_vendor_id2;

	okl_create_kle_pub.Update_party_roles_rec(p_api_version         => p_api_version,
                                		p_init_msg_list          => p_init_msg_list,
                                		x_return_status          => x_return_status,
                                		x_msg_count              => x_msg_count,
                                		x_msg_data               => x_msg_data,
                              			p_cplv_rec		 => p_cplv_rec,
                              			x_cplv_rec		 => x_cplv_rec);



          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
   ELSE
		NULL;

   END IF;


	-- update the transaction table and set the status to processed or whatever
	--If the trx failed then i have to record the reason for failure and send message to the
	--concerned person abt this. How do we do this?
	IF x_return_status =  OKL_API.G_RET_STS_SUCCESS THEN
		p_thpv_tbl(1).id	:= p_tas_id;
		p_thpv_tbl(1).tsu_code := 'PROCESSED';
		okl_trx_assets_pub.update_trx_ass_h_def(
                                p_api_version	=> p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count	=> x_msg_count,
                                x_msg_data	=> x_msg_data,
                                p_thpv_tbl	=> p_thpv_tbl,
                                x_thpv_tbl  	=> x_thpv_tbl);
	END IF;



  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');

END exchange;

END okl_equipment_exchange_pvt;


/
